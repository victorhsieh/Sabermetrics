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
                stats[kind] = read_personal_stat_by_row(f) if kind
            end
        rescue EOFError
        end
    end
    stats
end

private

def self.read_until(f, pattern)
    until f.readline.match(pattern); end
    $1
end

def self.smart_type_casting(value)
    value.match(/^\d+$/) ? value.to_i : value
end

def self.read_personal_stat_by_row(f)
    results = []
    while f.readline.match(/<tr class="Report_.*Item"/)
        stat = []
        while f.readline.match(/<td>(.*)<\/td>/)
            stat.push smart_type_casting $1
        end
        results.push stat
    end
    results.pop # drop the "total" line
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
