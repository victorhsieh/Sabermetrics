#!/usr/bin/ruby -Ku

require 'test/unit'
require 'Stat'
require 'CSVStatReader'

class TestCSVStatReader < Test::Unit::TestCase
    def setup
    end

    def testReading
        @reader = CSVStatReader.new
        @reader.read_batting('test/batting.csv') 
#        @reader.read_fielding('test/fielding.csv') 
        stats = @reader.stats

        result_stats = []
        float_result_stats = []
        stats.select {|p| p.Name == '陳金鋒'} .each do |p|
            stat = p.batting
            result_stats.push [p.Year, stat.AB, stat.HR]
            float_result_stats.push stat.OPS
        end
        assert_equal([[2006,344,21], [2007,301,26], [2008,240,16]].sort, result_stats.sort)
        [0.958, 1.195, 1.088].sort.zip(float_result_stats.sort) do |x,y|
            assert_in_delta(x, y, 0.0005)
        end
#.stat(:AB, :HR, :SLG)
    end
end
