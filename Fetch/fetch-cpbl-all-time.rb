#!/usr/bin/ruby -Ku

require 'open-uri'
require 'CPBLStatExtractor'
require '../Stat'
require '../BaseballUtils'


$TeamName = {
    :C01 => '時報', :A01 => '第一', :B01 => '俊國', :B02 => '興農',
    :G01 => '誠泰', :G02 => '米迪亞', :E01 => '兄弟', :W01 => '中信',
    :L01 => '統一', :A02 => 'La New', :D01 => '味全', :T01 => '三商'
}
$TeamCode = $TeamName.invert

def fetch_team_players(team, year, kind)
    players = CPBLStatExtractor::collect_players_from_team_in_year("http://www.cpbl.com.tw/teams/Team_#{kind}.aspx?Tno=#{team}&qyear=#{year}")
    players
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
    BaseballUtils::cached("data/raw/personal/#{id}") {
        stat = CPBLStatExtractor::collect_player_career_stat("http://www.cpbl.com.tw/personal_Rec/pbat_personal.aspx?Pno=#{id}")
        stat2 = CPBLStatExtractor::collect_player_career_stat("http://www.cpbl.com.tw/personal_Rec/pbat_personal.aspx?Pno=#{id}&pbatpage=2")
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

def fetch_fielding_position_detail(id)
    BaseballUtils::cached("data/raw/fielding/#{id}") {
        results = []
        stat = fetch_player(id)
        unless stat[:fielding]
            p "Player #{id} has no fielding stat"
            return [] 
        end

        stat[:fielding].map {|stat| stat[0] + 1989}.each {|year|
            stat = CPBLStatExtractor::collect_fielding_detail("http://www.cpbl.com.tw/personal_Rec/pdf_detail.aspx?pbyear=#{year}&Pno=#{id}")
            results.push *stat unless stat.empty?
        }
        sleep 0.5
        results
    }
end

def cpbl_all_players
    BaseballUtils::cached('data/players.data') {
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

def fetch_pitcher_stat(id)
    BaseballUtils::cached("data/raw/pitcher/#{id}") {
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

def get_pitcher_stat(id)
    stats = fetch_pitcher_stat(id)
    translate_stats_pair(stats, \
            'Name,G,PA,AB,RBI,R,H,H1B,H2B,H3B,HR,TB,DP', \
            'Name,SH,SF,BB,IBB,TOTAL_BB,SO,SB,CS') {|s|
        s[:HBP] = s[:TOTAL_BB] - s[:BB] - s[:IBB]
        s.delete(:TOTAL_BB)
        s.delete(:H1B)
    }
end

def get_personal_fielding_detail(id)
    stats = fetch_fielding_position_detail(id)
    translate_stats(stats, 'Year,Pos,G,TC,PO,A,E,DP,TP,PB,CS,SB') {|s|
        s[:Year] += 1989
    }
end

def get_personal_fielding(id)
    stats = fetch_player(id)[:fielding]
    translate_stats(stats, 'Year,Team,G,TC,PO,A,E,DP,TP,PB,CS,SB') {|s|
        s[:Year] += 1989
    }
end

def fetch_player_stats_by_team_year(dir, kind, team, year)
    BaseballUtils::cached("data/raw/#{dir}/#{team}-#{year}") {
        stats = {}
        stats[:page1] = CPBLStatExtractor::collect_players_stats_from_team_in_year("http://www.cpbl.com.tw/teams/Team_#{kind}.aspx?Tno=#{team}&page=1&qyear=#{year}")
        stats[:page2] = CPBLStatExtractor::collect_players_stats_from_team_in_year("http://www.cpbl.com.tw/teams/Team_#{kind}.aspx?Tno=#{team}&page=2&qyear=#{year}")
        sleep 0.3
        stats
    }
end

def csv_to_syms(csv)
    csv.split(',').map {|x| x.empty? ? nil : x.to_sym}
end

def merge_csv_and_stats(csv, stats)
    stats.map {|stat| Hash[csv_to_syms(csv).zip(stat)]}
end

def fix_stat(stat)
    stat[:Name].gsub!(/ /, '') if stat.has_key? :Name
    stat.delete(nil)
    stat
end

def translate_stats(stats, header, additional={})
    merge_csv_and_stats(header, stats).map {|stat|
        s = fix_stat(stat.merge additional)
        yield s if block_given?
        s
    }
end

def translate_stats_pair(stats, header1, header2, additional={})
    merge_csv_and_stats(header1, stats[:page1]).zip(
            merge_csv_and_stats(header2, stats[:page2])).map {|s1,s2|
        yield s = fix_stat(s1.merge s2.merge additional)
        s
    }
end

def get_batter_stats_by_team_year(team, year)
    stats = fetch_player_stats_by_team_year("team_batting", "Hitter", team, year)
    translate_stats_pair(stats,
            'Name,G,PA,AB,RBI,R,H,H1B,H2B,H3B,HR,TB,DP',
            'Name,SH,SF,BB,IBB,TOTAL_BB,SO,SB,CS', \
            {:Year => year, :Team => team}) {|s|
        s[:HBP] = s[:TOTAL_BB] - s[:BB] - s[:IBB]
        s.delete(:TOTAL_BB)
        s.delete(:H1B)
    }
end

def get_pitcher_stats_by_team_year(team, year)
    stats = fetch_player_stats_by_team_year("team_pitching", "Pitcher", team, year)
    translate_stats_pair(stats,
            'Name,G,GS,HLDO,SVO,W,L,TIE,SV,SVO_SV,HLD,,CG,SHO,NOBB',
            'Name,IP,PA,NP,H,HR,SAC,SF,BB,IBB,HBP,SO,WP,BK,R,ER', \
            {:Year => year, :Team => team}) {|s|
        s[:SVO] = s[:SV] + s[:SVO_SV]
        s[:IP] = BaseballUtils::fix_inning_rounding(s[:IP])
        s.delete(:SVO_SV)
    }
end
