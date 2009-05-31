#!/usr/bin/ruby

require 'test/unit'
require 'Stat'

class TestStat < Test::Unit::TestCase
    def setup
        @batting = BattingStat.new(
            :G => 66, :PA => 279, :AB => 240, :H => 88, :H2B=> 17, :H3B => 2,
            :HR => 16, :RBI => 39, :SAC => 0, :SF => 6, :SO => 53, :BB => 28,
            :HBP => 2, :IBB => 3, :GIDP => 4, :R => 52,
            :SB => 4, :CS => 1
        )
    end

    def test_batting
        assert_equal(66, @batting.G)
        assert_equal(88, @batting.H)
        assert_equal(16, @batting.HR)
        assert_equal(4, @batting.SB)
        assert_equal(53, @batting.H1B)
        assert_equal(157, @batting.TB)

        assert_in_delta(0.367, @batting.AVG, 0.0005)
        assert_in_delta(0.434, @batting.OBP, 0.0005)
        assert_in_delta(0.654, @batting.SLG, 0.0005)
        assert_in_delta(1.088, @batting.OPS, 0.0005)
    end
end
