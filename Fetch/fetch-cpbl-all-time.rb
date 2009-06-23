#!/usr/bin/ruby -Ku

require 'open-uri'
require 'CPBLStatExtractor'
require '../Stat'


$TeamName = {
    :C01 => '時報', :A01 => '第一', :B01 => '俊國', :B02 => '興農',
    :G01 => '誠泰', :G02 => '米迪亞', :E01 => '兄弟', :W01 => '中信',
    :L01 => '統一', :A02 => 'La New', :D01 => '味全', :T01 => '三商'
}
$TeamCode = $TeamName.invert

def fetch_team_players(team, year, kind)
    players = CPBLStatExtractor::collect_players_from_team_in_year("http://www.cpbl.com.tw/teams/Team_#{kind}.aspx?Tno=#{team}&qyear=#{year}")
    puts "#{team} in #{year} has #{players.size} #{kind}"
    players
end

def cached(filename, &b)
    if File.exists? filename
        puts "cache hit! #{filename}"
        File.open(filename, 'r') do |f|
            return Marshal.load(f)
        end
    else
        result = b.call
        if result
            File.open(filename, 'w') do |f|  
                Marshal.dump(result, f)  
            end
        end
        return result
    end
end

def fix_it(filename, &b)
    data = nil
    if File.exists? filename
        puts "cache hit! #{filename}"
        File.open(filename, 'r') do |f|
            data = Marshal.load(f)
        end

        b.call(data)
        File.open(filename, 'w') do |f|  
            Marshal.dump(data, f)  
        end 
    end
end

def fetch_player(id)
    cached("data/raw/personal/#{id}") {
        stat = CPBLStatExtractor::collect_player_stat("http://www.cpbl.com.tw/personal_Rec/pbat_personal.aspx?Pno=#{id}")
        stat2 = CPBLStatExtractor::collect_player_stat("http://www.cpbl.com.tw/personal_Rec/pbat_personal.aspx?Pno=#{id}&pbatpage=2")
        if stat2.has_key? :pitching
            stat[:pitching2] = stat2[:pitching]
        elsif stat2.has_key? :batting
            stat[:batting2] = stat2[:batting]
        else
            p "how come!? (#{id})", stat2
        end
        sleep 0.5
        stat
    }
end

#def sum_vectors_group_by(column, vectors)
#    v = vectors.shift
#    v.zip(*vectors).maps {|xs| p xs}
#end

def fetch_fielding_detail(id)
    cached("data/raw/fielding/#{id}") {
        results = []
        stat = fetch_player(id)
        return [] unless stat[:fileding]

        stat[:fielding].map {|stat| stat[0] + 1989}.each {|year|
            stat = CPBLStatExtractor::collect_fielding_detail("http://www.cpbl.com.tw/personal_Rec/pdf_detail.aspx?pbyear=#{year}&Pno=#{id}")
            results.push stat unless stat.empty?
        }
        sleep 0.5
        results
    }
end

def cpbl_all_players
    cached('data/players.data') {
        all_players = []
        $TeamName.each_key {|team|
            1990.upto(2009) {|year|
                hitters = fetch_team_players(team, year, 'Hitter')
                all_players.push *hitters unless hitters.empty?

                pitchers = fetch_team_players(team, year, 'Pitcher')
                all_players.push *pitchers unless hitters.empty?
            }
        }
#        all_players.delete 'C035'
        all_players.uniq!
    }
end

def fetch_pitcher_stat_by_game_in_year(id)
    cached("data/raw/pitcher_by_game/#{id}") {
        stat = fetch_player(id)
        if stat.has_key?(:pitching)
            result = {:page1 => [], :page2 => []}
            stat[:pitching].map {|s| s[0].to_s.rjust(2, '0')}.each {|year|
                puts "http://www.cpbl.com.tw/personal_Rec/ppitch_single.aspx?Gno=01&pbyear=#{year}&Pno=#{id}"
                stats = CPBLStatExtractor::collect_pitcher_by_game_in_year("http://www.cpbl.com.tw/personal_Rec/ppitch_single.aspx?Gno=01&pbyear=#{year}&Pno=#{id}")
                stats2 = CPBLStatExtractor::collect_pitcher_by_game_in_year("http://www.cpbl.com.tw/personal_Rec/ppitch_single.aspx?Gno=01&pbyear=#{year}&Pno=#{id}&pbatpage=2")
                result[:page1].push stats
                result[:page2].push stats2
            }
            sleep 0.3
            result
        else
            nil
        end
    }
end

def fetch_player_stats_by_team_year(dir, kind, team, year)
    cached("data/raw/#{dir}/#{team}-#{year}") {
        stats = {}
        stats[:page1] = CPBLStatExtractor::collect_players_stats_from_team_in_year("http://www.cpbl.com.tw/teams/Team_#{kind}.aspx?Tno=#{team}&page=1&qyear=#{year}")
        stats[:page2] = CPBLStatExtractor::collect_players_stats_from_team_in_year("http://www.cpbl.com.tw/teams/Team_#{kind}.aspx?Tno=#{team}&page=2&qyear=#{year}")
        sleep 0.3
        stats
    }
end

def fetch_pitcher_stats_by_team_year(team, year)
    fetch_player_stats_by_team_year("team_pitching", "Pitcher", team, year)
end

def fetch_batter_stats_by_team_year(team, year)
    fetch_player_stats_by_team_year("team_batting", "Hitter", team, year)
end
