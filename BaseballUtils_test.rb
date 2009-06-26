#!/usr/bin/ruby

require 'test/unit'
require 'BaseballUtils'

class TestBaseballUtils < Test::Unit::TestCase
    def test_fix_inning_of_precision_case
        assert_in_delta(0, BaseballUtils::fix_inning_rounding(0), 0.0000001)
        assert_in_delta(10, BaseballUtils::fix_inning_rounding(10), 0.0000001)
        assert_in_delta(1.0/3, BaseballUtils::fix_inning_rounding(0.33), 0.0000001)
        assert_in_delta(1.0/3, BaseballUtils::fix_inning_rounding(0.33), 0.0000001)
        assert_in_delta(1.0/3, BaseballUtils::fix_inning_rounding(0.34), 0.0000001)
        assert_in_delta(1.0/3, BaseballUtils::fix_inning_rounding(0.3), 0.0000001)
        assert_in_delta(2.0/3, BaseballUtils::fix_inning_rounding(0.6), 0.0000001)
        assert_in_delta(1+2.0/3, BaseballUtils::fix_inning_rounding(1.66), 0.0000001)
        assert_in_delta(2+2.0/3, BaseballUtils::fix_inning_rounding(2.67), 0.0000001)
        assert_in_delta(3+2.0/3, BaseballUtils::fix_inning_rounding(3.7), 0.0000001)
    end

    def test_fix_inning_of_unpreferred_notation
        assert_in_delta(1.0/3, BaseballUtils::fix_inning_rounding(0.1), 0.0000001)
        assert_in_delta(2.0/3, BaseballUtils::fix_inning_rounding(0.2), 0.0000001)
        assert_in_delta(10+2.0/3, BaseballUtils::fix_inning_rounding(10.2), 0.0000001)
    end
end
