#!/usr/bin/ruby

require 'test/unit'
require 'Stat'

class MockContext
    def initialize(player)
        @player = player
    end

    def each_players(&b)
        @player.do {|x| yield x}
    end
end

class TestStat < Test::Unit::TestCase
    def setup
        @player = BaseballStat.new(:Name => 'Foo Bar')
        @player.batting.set_stats(
            :G => 66, :PA => 279, :AB => 240, :H => 88, :H2B=> 17, :H3B => 2,
            :HR => 16, :RBI => 39, :SAC => 0, :SF => 6, :SO => 53, :BB => 28,
            :HBP => 2, :IBB => 3, :GIDP => 4, :R => 52,
            :SB => 4, :CS => 1
            )
        @player.pitching.set_stats(
            :W => 16, :L => 11, :H => 138, :BB => 61, :IP => 150, :HR => 3
            )
        @player.fielding.set_stats(
            :PO => 256, :A => 473, :E => 20
            )
        @batting, @pitching, @fielding = @player.batting, @player.pitching, @player.fielding
    end

    def test_batting
        assert_equal(66, @batting.G)
        assert_equal(88, @batting.H)
        assert_equal(16, @batting.HR)
        assert_equal(4, @batting.SB)
        assert_equal(53, @batting.H1B)
        assert_equal(157, @batting.TB)
        assert_equal(279, @batting.TPA)
        assert_equal(279, @batting.PA)

        assert_in_delta(0.367, @batting.AVG, 0.0005)
        assert_in_delta(0.434, @batting.OBP, 0.0005)
        assert_in_delta(0.654, @batting.SLG, 0.0005)
        assert_in_delta(1.088, @batting.OPS, 0.0005)

        @batting.IBB = 0
        assert_equal(0, @batting.IBB)
    end

    def test_pitching
        assert_equal(16, @pitching.W)
        assert_equal(3, @pitching.HR)
        assert_equal(138, @pitching.H)
        assert_in_delta(1.33, @pitching.WHIP, 0.005)
        assert_in_delta(0.593, @pitching.WPCT, 0.0005)
    end

    def test_fielding
        assert_equal(256, @fielding.PO)
        assert_equal(256, @fielding.putout)
        assert_in_delta(0.973, @fielding.FPCT, 0.0005)
    end

    def test_player_attribute
        assert_equal('Foo Bar', @player.Name)

        @player.Team = 'GoodTeam'
        assert_equal('GoodTeam', @player.Team)

        @player.set_attr(:Year, 2008)
        assert_equal(2008, @player.Year)

        @player.set_attr('League', 'CPBL')
        assert_equal('CPBL', @player.League)
    end

    def test_delegate
        league = MockContext.new(@batting)
        league.each_players {|p|
            puts self
            puts p
        }
    end
end
