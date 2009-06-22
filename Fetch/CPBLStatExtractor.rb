#!/usr/bin/ruby

module CPBLStatExtractor

def self.collect_players_from_team_in_year(page)
    open(page, 'r') do |f|
        f.to_enum.grep(/Pno=/).map {|line| line.match(/Pno=(\w+)/); $1}
    end
end

def self.collect_player_stat(page)
    stats = {}
    open(page, 'r') do |f|
        begin
            until f.eof?
                type = read_until(f, /images\/hd\/player(\d)\.gif/)
                f.readline
                read_until f, /<\/tr>/
                kind = type_number_to_kind_symbol(type.to_i)
                if kind
                    stats[kind] = read_personal_stats_of_rows(f)
                    stats[kind].pop # drop the "total" line
                end
            end
        rescue EOFError
        end
    end
    stats
end

def self.collect_fielding_detail(page)
    open(page, 'r') do |f|
        read_until(f, /class="Report_Table_pdf"/)
        read_until(f, /<\/tr/)
        return read_personal_stats_of_rows(f)
    end
end

private

def self.read_until(f, pattern)
    until f.readline.match(pattern); end
    $1
end

def self.smart_type_casting(value)
    value.match(/^\d+$/) ? value.to_i : value
end

def self.read_personal_stats_of_rows(f)
    results = []
    while f.readline.match(/<tr class="Report_.*Item"/)
        stat = []
        while f.readline.match(/<td>(.*)<\/td>/)
            stat.push smart_type_casting $1
        end
        results.push stat
    end
    results
end

def self.type_number_to_kind_symbol(num)
    case num
    when 1; kind = :pitching
    when 2; kind = :batting
    when 3; kind = :fielding
    else; nil
    end
end

end
