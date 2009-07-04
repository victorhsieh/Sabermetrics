#!/usr/bin/ruby -Ku

require 'test/unit'
require 'fetch-cpbl-all-time'

class TestStat < Test::Unit::TestCase
    def setup
        @cpbl = CPBLProxy.new
    end

    def test_team_players
        players = @cpbl.team_players(:C01, 1995, 'Hitter')
        assert_equal(20, players.size)
    end

    def test_batter_stats_by_team_year
        stats = @cpbl.batter_stats_by_team_year('E01', 1995)
        assert_equal(18, stats.size)
        assert_equal(1995, stats[0][:Year])
        assert_equal(97, stats[0][:G])
        assert_equal(23, stats[1][:DP])
        assert_equal(20, stats[5][:BB])
        assert_equal(9, stats[0][:CS])
    end

    def test_pitcher_stats_by_team_year
        stats = @cpbl.pitcher_stats_by_team_year('E01', 1995)
        assert_equal(13, stats.size)
        assert_equal("陳義信", stats[0][:Name])
        assert_equal(26, stats[0][:G])
        assert_equal(24, stats[0][:GS])
        assert_equal(3, stats[0][:NOBB])
        assert_equal(0, stats[0][:HLDO])
        assert_in_delta(180 + 1.0/3, stats[0][:IP], 0.000001)
        assert_equal(2457, stats[0][:NP])
        assert_equal(0, stats[0][:BK])
        assert_equal(83, stats[0][:R])
        assert_equal(63, stats[0][:ER])
        assert_equal(20, stats[0][:HR])
    end

    def test_personal_fielding_detail_of_multi_position
        stats = @cpbl.personal_fielding_detail('A013').select {|s| s[:Year] == 2007}
        assert_equal(5, stats.size)
        assert_equal(3, stats[1][:G])
        assert_equal(24, stats[4][:PO])
    end

    def test_personal_fielding_detail_in_year
        stats = @cpbl.personal_fielding('A037')
        assert_equal(18, stats[0][:G])
        assert_equal(3, stats[5][:G])
        assert_equal('統一', stats[6][:Team])
        assert_equal(2009, stats[5][:Year])
        assert_equal(2009, stats[6][:Year])
        assert_equal(0, stats[6][:SB])
        assert_equal(1, stats[0][:DP])
        assert_equal(1, stats[3][:DP])
        assert_equal(1, stats[3][:E])
        assert_equal(10, stats[4][:A])
    end
end
