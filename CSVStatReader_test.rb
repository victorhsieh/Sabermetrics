#!/usr/bin/ruby -Ku

require 'test/unit'
require 'Stat'
require 'CSVStatReader'

class TestCSVStatReader < Test::Unit::TestCase
    def setup
        @reader = CSVStatReader.new
    end

    def test_read_batting
        @reader.read_batting('test/batting.csv') 
        stats = @reader.stats

        result_stats = []
        float_result_stats = []
        stats.select {|p| p.Name == '陳金鋒'} .each do |p|
            stat = p.batting
            result_stats.push [p.Year, stat.AB, stat.HR]
            float_result_stats.push stat.OPS
        end
        assert_equal([[2006,344,21], [2007,301,26], [2008,240,16]].sort, result_stats.sort)
        assert_float_array_in_delta([0.958, 1.195, 1.088].sort, float_result_stats.sort, 0.0005)
#.stat(:AB, :HR, :SLG)
    end

    def test_read_fielding
        @reader.read_fielding('test/fielding.csv') 
        stats = @reader.stats

        result_stats = []
        stats.select {|p| p.Name == '林易增' and p.Team == '味全'} .each do |p|
            result_stats.push [p.Year, p.fielding.PO]
        end
        assert_equal([[1990, 185], [1991, 185]].sort, result_stats)
    end

    def test_read_pitching
        @reader.read_pitching('test/pitching.csv') 
        stats = @reader.stats

        assert_equal(3, stats[-1].pitching.SHO)

        result_stats = []
        float_result_stats = []
        stats.select {|p| p.Name == '賈西'} .each do |p|
            result_stats.push [p.Year, p.pitching.GS]
            float_result_stats.push p.pitching.ERA
        end
        assert_equal([[1990, 19], [1991, 18], [1992, 7], [1996, 2], [1997, 1], [1998, 1]].sort, result_stats.sort)
        assert_float_array_in_delta([3.01, 1.89, 2.09, 3.69, 2.66, 2.63].sort, float_result_stats.sort, 0.005)
    end

    def assert_float_array_in_delta(expected, actual, epsilon)
        expected.zip(actual.sort) do |x,y|
            assert_in_delta(x, y, epsilon)
        end
    end
end
