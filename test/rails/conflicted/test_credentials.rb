# frozen_string_literal: true

require "test_helper"

class Rails::Conflicted::TestCredentials < Minitest::Test
  def test_that_it_has_a_version_number
    assert ::Rails::Conflicted::Credentials::VERSION != nil
  end
end
