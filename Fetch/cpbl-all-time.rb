#!/usr/bin/ruby -Ku

def collect_players_from_team_in_year(page)
    open(page, 'r') do |f|
        f.to_enum.grep(/Pno=/).map {|line| line.match(/Pno=(\w+)/); $1}
    end
end
