require 'minitest'
require 'minitest/autorun'

require_relative '../lib/fzeet'

class FzeetTest < Minitest::Test
  def test_FZEET_xxx
    assert_match %r{^\d+\.\d+\.\d+(\.\d+)?$}, FZEET_VERSION
  end

  def test_All
    # TODO: convert to test methods
    require_relative 'RunAll'
  end
end
