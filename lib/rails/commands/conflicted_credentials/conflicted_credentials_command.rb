# frozen_string_literal: true

require "rails/command"
require "rails/commands/credentials/credentials_command"

module Rails
  module Command
    class ConflictedCredentialsCommand < ::Rails::Command::CredentialsCommand
      require_relative "conflicted_credentials_command/conflicted_credentials"

      desc "edit", "Open the decrypted credentials in `$VISUAL` or `$EDITOR` for editing even if there are conflicts"
      def edit
        begin
          load_environment_config!
        rescue ActiveSupport::MessageEncryptor::InvalidMessage
          # It's ok because they were conflicted
        end

        load_generators

        if environment_specified?
          @content_path = "config/credentials/#{environment}.yml.enc" unless config.overridden?(:content_path)
          @key_path = "config/credentials/#{environment}.key" unless config.overridden?(:key_path)
        end

        conflicted_credentials = ConflictedCredentials.new(content_path, key_path)
        conflicted_credentials.internalise_conflicts if conflicted_credentials.conflicts?

        ensure_encryption_key_has_been_added
        ensure_credentials_have_been_added
        ensure_diffing_driver_is_configured

        change_credentials_in_system_editor
      end
    end
  end
end
