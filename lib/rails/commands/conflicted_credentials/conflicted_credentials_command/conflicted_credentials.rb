# frozen_string_literal: true

require "tempfile"

module Rails
  module Command
    class ConflictedCredentialsCommand
      class ConflictedCredentials
        GIT_CONFLICT_MARKER = /^<{7} (?:(?!={7})[\s\S])*={7}(?:(?!>{7} \w+)[\s\S])*>{7} .+/

        def initialize(content_path, key_path)
          @content_path = content_path
          @key_path = key_path
          return if content_path.blank? || !File.exist?(content_path)

          @file_data = File.binread(content_path).strip
        end

        def conflicts?
          return false if @file_data.nil?

          @file_data.match?(GIT_CONFLICT_MARKER)
        end

        def internalise_conflicts
          left_unencrypted_string, right_unencrypted_string = decrypt_individual_files
          return if right_unencrypted_string.nil?

          conflicted_unencrypted_string = merge_conflicted_strings(
            left_unencrypted_string,
            right_unencrypted_string
          )

          ActiveSupport::EncryptedFile.new(
            content_path: @content_path,
            key_path: @key_path,
            env_key: "RAILS_MASTER_KEY",
            raise_if_missing_key: true
          ).write(conflicted_unencrypted_string)
        end

        private
          def decrypt_individual_files
            left_encrypted_string, right_encrypted_string = split_conflict(@file_data)
            return nil if right_encrypted_string.nil?

            left_encrypted_file = Tempfile.new("encrypted-left")
            left_encrypted_file.write(left_encrypted_string)
            left_encrypted_file.close

            right_encrypted_file = Tempfile.new("encrypted-right")
            right_encrypted_file.write(right_encrypted_string)
            right_encrypted_file.close

            unencrypted_left_string = ActiveSupport::EncryptedFile.new(
              content_path: left_encrypted_file.path,
              key_path: @key_path,
              env_key: "RAILS_MASTER_KEY",
              raise_if_missing_key: true
            ).read

            unencrypted_right_string = ActiveSupport::EncryptedFile.new(
              content_path: right_encrypted_file.path,
              key_path: @key_path,
              env_key: "RAILS_MASTER_KEY",
              raise_if_missing_key: true
            ).read

            [unencrypted_left_string, unencrypted_right_string]
          ensure
            [left_encrypted_file, right_encrypted_file].each do |f|
              f.unlink if f&.path && File.exist?(f.path)
            end
          end

          def split_conflict(content)
            if content.match?(GIT_CONFLICT_MARKER)
              @conflict_type = :git
              split_git_conflict(content)
            else
              @conflict_type = :unknown
              [content, nil]
            end
          end

          def split_git_conflict(content)
            left_lines = []
            right_lines = []

            state = :common
            content.each_line do |line|
              if line.start_with?("<<<<<<< ")
                @head_left ||= line.split("<<<<<<< ").last.strip
                state = :in_left
              elsif line.start_with?("=======")
                state = :in_right
              elsif line.start_with?(">>>>>>> ")
                @head_right ||= line.split(">>>>>>> ").last.strip
                state = :common
              elsif state == :in_left
                left_lines << line
              elsif state == :in_right
                right_lines << line
              else
                left_lines << line
                right_lines << line
              end
            end

            [left_lines.join.strip, right_lines.join.strip]
          end

          def merge_conflicted_strings(left_string, right_string)
            if @conflict_type == :git
              git_merge_strings(left_string, right_string)
            else
              default_merge_strings(left_string, right_string)
            end
          end

          def git_merge_strings(local_str, remote_str, base_str = "")
            base_file = Tempfile.new("git-merge-base")
            base_file.write(base_str)
            base_file.close
            local_file = Tempfile.new("git-merge-local")
            local_file.write(local_str)
            local_file.close
            remote_file = Tempfile.new("git-merge-remote")
            remote_file.write(remote_str)
            remote_file.close

            cmd = [
              "git merge-file -p",
              local_file.path,
              base_file.path,
              remote_file.path,
              "2>&1"
            ].join(" ")

            merged = `#{cmd}`
            status = $?

            unless status.success? || status.exitstatus == 1
              return default_merge_strings(local_str, remote_str)
            end

            merged.strip
              .gsub(local_file.path, @head_left)
              .gsub(remote_file.path, @head_right)
          ensure
            [base_file, local_file, remote_file].each do |f|
              f.unlink if f&.path && File.exist?(f.path)
            end
          end

          def default_merge_strings(local_str, remote_str)
            [
              "<<<<<<< #{@head_left}",
              local_str,
              "=======",
              remote_str,
              ">>>>>> #{@head_right}"
            ].compact.join("\n")
          end
      end
    end
  end
end
