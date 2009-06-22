#!/usr/bin/ruby -Ku

require 'test/unit'
require 'cpbl-all-time'
#require '../Stat'

class TestStat < Test::Unit::TestCase
    def test_collect_players
        assert_equal(['C016', 'C011', 'C023', 'C077', 'C048', 'C039', 'C007', 'C017', 'C001', 'C009', 'C012'].sort, collect_players_from_team_in_year('test/93-eagle-pitcher.html').sort)
        assert_equal(['E002', 'E033', 'B009', 'E026', 'E044', 'E019', 'E022', 'E001', 'E035', 'E032', 'E043', 'E024', 'E025', 'E029', 'E009', 'E020', 'E021'].sort, collect_players_from_team_in_year('test/90-elephant-hitter.html').sort)
    end

    def test_collect_hitter_stat
        stats = collect_player_stat('test/hitter_career.html')
        assert_equal(4, stats[:batting][0][0])
        assert_equal(90, stats[:batting][0][2])
        assert_equal(5, stats[:batting].size)

        assert_equal(195, stats[:fielding][0][3])
        assert_equal(94, stats[:fielding][4][4])
        assert_equal(5, stats[:fielding].size)
    end

    def test_collect_pitcher_stat
        stats = collect_player_stat('test/pitcher_career.html')
        assert_equal(26, stats[:pitching][0][2])
        assert_equal(12, stats[:pitching][5][7])
        assert_equal(7, stats[:pitching].size)

        assert_equal(42, stats[:fielding][0][3])
        assert_equal(9, stats[:fielding][4][4])
        assert_equal(7, stats[:fielding].size)
    end
end
