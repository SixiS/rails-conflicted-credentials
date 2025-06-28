# frozen_string_literal: true

require_relative "lib/rails/conflicted/credentials/version"

Gem::Specification.new do |spec|
  spec.name = "rails-conflicted-credentials"
  spec.version = Rails::Conflicted::Credentials::VERSION
  spec.authors = ["Matthew Hirst"]
  spec.email = ["hirst.mat@gmail.com"]

  spec.summary = "A gem to help editing rails credentials files with git merge conflicts."
  spec.homepage = "https://github.com/SixiS/rails-conflicted-credentials"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/SixiS/rails-conflicted-credentials"
  spec.metadata["changelog_uri"] = "https://github.com/SixiS/rails-conflicted-credentials/blob/main/CHANGELOG.md"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0"
end
