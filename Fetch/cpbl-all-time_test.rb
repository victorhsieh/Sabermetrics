#!/usr/bin/ruby

require 'test/unit'
require 'cpbl-all-time'

class TestStat < Test::Unit::TestCase
    def test_collect_players
        assert_equal(['C016', 'C011', 'C023', 'C077', 'C048', 'C039', 'C007', 'C017', 'C001', 'C009', 'C012'].sort, collect_players_from_team_in_year('test/93-eagle-pitcher.html').sort)
        assert_equal(['E002', 'E033', 'B009', 'E026', 'E044', 'E019', 'E022', 'E001', 'E035', 'E032', 'E043', 'E024', 'E025', 'E029', 'E009', 'E020', 'E021'].sort, collect_players_from_team_in_year('test/90-elephant-hitter.html').sort)
    end
end
