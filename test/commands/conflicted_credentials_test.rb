# frozen_string_literal: true

require "isolation/abstract_unit"
require "env_helpers"
require "rails/command"
require "fileutils"

class Rails::Command::ConflictedCredentialsTest < ActiveSupport::TestCase
  include EnvHelpers
  include ActiveSupport::Testing::Isolation

  setup :build_app
  teardown :teardown_app

  test "edit command works with git conflicts" do
    run_edit_command(environment: "development")

    write_credentials "baz: foo\nfoo: bar\nbar: baz", environment: "development"
    left_file = File.read(app_path("config", "credentials", "development.yml.enc"))

    write_credentials "baz: foo\nfoo: baz\nbar: baz", environment: "development"
    right_file = File.read(app_path("config", "credentials", "development.yml.enc"))

    merge_conflict = <<~CONFLICT
      <<<<<<< HEAD
      #{left_file}
      =======
      #{right_file}
      >>>>>>> @{-1}
    CONFLICT
    File.write(app_path("config", "credentials", "development.yml.enc"), merge_conflict)

    decrypted_conflict = <<~CONFLICT
      baz: foo
      <<<<<<< HEAD
      foo: bar
      =======
      foo: baz
      >>>>>>> @{-1}
      bar: baz
    CONFLICT

    assert_includes(run_edit_command(environment: "development"), decrypted_conflict.strip)
  end

  private
    DEFAULT_CREDENTIALS_PATTERN = /access_key_id: 123\n.*secret_key_base: \h{128}\n/m

    def run_edit_command(visual: "cat", editor: "cat", environment: nil, **options)
      switch_env("VISUAL", visual) do
        switch_env("EDITOR", editor) do
          args = []
          args << ["--environment", environment] if environment
          rails "conflicted_credentials:edit", args, **options
        end
      end
    end

    def write_credentials(content, **options)
      switch_env("CONTENT", content) do
        run_edit_command(visual: %(ruby -e "File.write ARGV[0], ENV['CONTENT']"), **options)
      end
    end
end
