#!/usr/bin/ruby

require 'csv'
require 'Stat'

class CSVStatReader
    attr_accessor :stats

    def initialize
        @stats = []
    end

    def read_batting(file)
        read_csv_with_header(file, :batting, 'League,Team,ID,Name,Year,G,PA,AB,RBI,R,H,H2B,H3B,HR,TB,DP,SH,SF,BB,HBP,SO,SB,CS'.split(',')) {|bbstat| bbstat.batting.IBB = 0}
    end


    private

    def read_csv_with_header(file, stat_type, header, drop_first_line=true)
        reader = CSV.open(file, 'r')
        reader.shift if drop_first_line

        while row = reader.shift and not row.empty?
            bbstat = row_to_bbstat(header, row, stat_type)
            yield bbstat if block_given?
            @stats.push bbstat
        end
    end

    def smart_type_casting(value)
        value.match(/^\d+$/) ? value.to_i : value
    end

    def row_to_bbstat(header, row, stat_type)
        bbstat = BaseballStat.new
        stat = bbstat.send stat_type
        header.zip(row).each do |key,value|
            if stat.has_stat? key
                stat.set_stats(key => value)
            else
                bbstat.set_attr(key, smart_type_casting(value))
            end
        end
        bbstat
    end
end
