require_relative '../lib/fzeet'
require 'minitest'
require 'minitest/autorun'

class FzeetTest < Minitest::Test
  def test_version
    refute_nil Fzeet::VERSION

    # TODO: convert to test methods
    require_relative 'RunAll'
  end
end
