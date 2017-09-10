require 'test_helper'

# Test presence of version for RubyPayler gem
class VersionTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::RubyPayler::VERSION
  end
end
