#!/usr/bin/ruby -Ku

require 'test/unit'
require 'fetch-cpbl-all-time'

class TestStat < Test::Unit::TestCase
    def test_fetch_team_players
        players = fetch_team_players(:C01, 1995, 'Hitter')
        assert_equal(20, players.size)
    end

    def test_fetch_batter_stats_by_team_year
        stats = get_batter_stats_by_team_year('E01', 1995)
        assert_equal(18, stats.size)
        assert_equal(1995, stats[0][:Year])
        assert_equal(97, stats[0][:G])
        assert_equal(23, stats[1][:DP])
        assert_equal(20, stats[5][:BB])
        assert_equal(9, stats[0][:CS])
    end

    def test_fetch_pitcher_stats_by_team_year
        stats = get_pitcher_stats_by_team_year('E01', 1995)
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

    def test_fetch_personal_fielding_detail_of_multi_position
        stats = get_personal_fielding_detail('A013')
#        y2007 = stats.select {|s| s.Year == 2007}
#        assert_equal(5, y2007.size)
    end

    def test_fetch_personal_fielding_detail_in_year
        stats = get_personal_fielding('A037')
        assert_equal(7, stats.size)
        assert_equal(18, stats[0][:G])
        assert_equal(3, stats[5][:G])
        assert_equal(19, stats[6][:G])
        assert_equal(20, stats[5][:Year])
        assert_equal(20, stats[6][:Year])
        assert_equal(0, stats[6][:SB])
        assert_equal(1, stats[0][:DP])
        assert_equal(1, stats[3][:DP])
        assert_equal(1, stats[3][:E])
        assert_equal(10, stats[4][:A])
    end
end