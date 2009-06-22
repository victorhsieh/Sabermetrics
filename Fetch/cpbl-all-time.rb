#!/usr/bin/ruby

def collect_players_from_team_in_year(page)
    open(page, 'r') do |f|
        f.to_enum.grep(/Pno=/).map {|line| line.match(/Pno=(\w+)/); $1}
    end
end

def _read_until(f, pattern)
    until f.readline.match(pattern); end
    $1
end

def smart_type_casting(value)
    value.match(/^\d+$/) ? value.to_i : value
end

def _read_personal_stat_by_row(f)
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

def collect_player_stat(page)
    stats = {}
    open(page, 'r') do |f|
    begin
        until f.eof?
            type = _read_until(f, /images\/hd\/player(\d)\.gif/)
            f.readline
            _read_until f, /<\/tr>/
            case type.to_i
            when 1; kind = :pitching
            when 2; kind = :batting
            when 3; kind = :fielding
            else; next
            end
            stats[kind] = _read_personal_stat_by_row f
        end
    rescue EOFError
    end
    end
    stats
end
