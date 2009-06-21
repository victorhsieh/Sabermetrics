class BaseStat
    def initialize(stats={})
        set_stats stats
    end

    def set_stats(stats={})
        stats.each_pair do |key, value|
            key = to_canonical key.to_sym
            instance_variable_set("@#{key}", value.to_f)
        end
    end

    def has_stat?(name); self.class.has_stat? name.to_sym; end


    private

    def self.inherited(derived)
        derived.class_eval {
            @abbr_map = {}
        }
    end

    def self.def_stat(*names, &formula)
        stat = names.pop
        if block_given?
            define_method stat, formula
        else
            attr_reader stat
        end

        alias_stat stat, names
    end

    def self.alias_stat(stat, names)
        names.each do |name|
            alias_method name, stat
            @abbr_map[name] = stat
        end
    end

    def self.stat(name); @abbr_map[name]; end

    def self.has_stat?(name); @abbr_map.has_key? name; end

    def to_canonical(name)
        if self.class.has_stat? name
            self.class.stat name
        elsif respond_to? name
            name
        else
            nil
        end
    end

    def method_missing(name, *args)
        if name.to_s.match(/=$/)
            value = *args
            set_stats(name.to_s.chop.to_sym => value)
        end
    end

    def do
        yield self
    end
end

class BattingStat < BaseStat
    def_stat :G, :game
    def_stat :PA, :TPA, :plateAppearance, :totalPlateAppearance
    def_stat :AB, :atBase
    def_stat :H, :hit # do single + double + triple + homeRun end
# may need to replace attr_reader with our own return-attr-if-exist-prior-to-function getter
    def_stat :H2B, :double
    def_stat :H3B, :triple
    def_stat :HR, :homeRun
    def_stat :GS, :grandSlam
    def_stat :RBI, :runsBattedIn
    def_stat :SAC, :SH, :sacrificeBunt
    def_stat :SF, :sacrificeFly
    def_stat :LOB, :leftOnBase

    def_stat :SO, :strikeOut
    def_stat :BB, :baseOnBall
    def_stat :HBP, :hitByPitch
    def_stat :IBB, :intentionalWalk
    def_stat :GO, :groundOut
    def_stat :AO, :flyOut
    def_stat :GIDP, :DP, :groundIntoDoublePlay
    def_stat :TP, :triplePlay

    def_stat :NP, :numberOfPitch
    def_stat :R, :runScored
    def_stat :SB, :stolenBase
    def_stat :CS, :caughtStealing

    def_stat :LIPS, :lateInningPresureSituation

    def_stat :H1B, :single do hit - double - triple - homeRun end
    def_stat :TB, :totalBase do single + 2 * double + 3 * triple + 4 * homeRun end
    def_stat :XBH, :extraBaseHit do double + triple + homeRun end


    def_stat :AVG, :batAverage do hit / atBase end
    def_stat :OBP, :onBasePercentage do
        (hit + baseOnBall + hitByPitch + intentionalWalk) /
        (atBase + baseOnBall + hitByPitch + sacrificeFly + intentionalWalk)
    end
    def_stat :SLG, :sluggingPercentage do totalBase / atBase end
    def_stat :OPS, :onBasePercentagePlusSluggingPercentage do
        onBasePercentage + sluggingPercentage
    end
end

class PitchingStat < BaseStat
    def_stat :AO, :flyOut
    def_stat :APP, :appearance
    def_stat :BB, :baseOnBall
    def_stat :BK, :balk
    def_stat :BS, :blownSave
    def_stat :CG, :completeGame
    def_stat :CGL, :completeGameLose
    def_stat :CS, :caughtStealing
    def_stat :ER, :earnedRun
    def_stat :G, :gamesPlayed
    def_stat :GF, :gamesFinished
    def_stat :GIDP, :DP, :groundIntoDoublePlay
    def_stat :GO, :groundOut
    def_stat :GS, :gameStarted
    def_stat :GSH, :grandSlam
    def_stat :H, :hit
    def_stat :HB, :hitBatsmen
    def_stat :HLD, :hold
    def_stat :HR, :homeRun
    def_stat :IBB, :intentionalWalk
    def_stat :IP, :inningPitched
    def_stat :IRA, :inheritedRunAllowed
    def_stat :L, :loss
    def_stat :LOB, :leftOnBase
    def_stat :NP, :numberOfPitchThrown
    def_stat :PA, :plateAppearance
    def_stat :PK, :pickoff
    def_stat :R, :run
    def_stat :RW, :reliefWin
    def_stat :SB, :stolenBase
    def_stat :SHO, :shutout
    def_stat :SO, :strikeOut
    def_stat :SV, :save
    def_stat :SVO, :saveOpportunity
    def_stat :TB, :totalBase
    def_stat :TP, :triplePlay
    def_stat :UR, :unearnedRun
    def_stat :W, :win
    def_stat :WP, :wildPitch
    def_stat :XBA, :extraBaseHitAllowed


    def_stat :AVG, :opponentsBattingAverage do hit / batterFaced end # not precise
    def_stat :BB9, :walksPerNineInnings do baserunnerPer9Innings / inningPitched * 9 end
    def_stat :BF, :batterFaced do inningPitched * 3 + hit + baseOnBall + hitBatsmen end # + number of batters that reached base on error against the pitcher
    def_stat :ERA, :earnedRunAverage do earnedRun / inningPitched * 9 end
    def_stat :GO_AO, :groundOutFlyOutRatio do groundOut / flyOut end
    def_stat :H9, :hitPerNineInnings do hit / inningPitched * 9 end
#    def_stat :I_GS, :inningPerGamesStarted do inningPitched(as starter) / gameStarted end
    def_stat :K_9, :strikeOutsPerNineInnings do strikeOut / inningPitched * 9 end
    def_stat :K_BB, :strikeOutOverWalkRatio do strikeOut / baseOnBall end
    def_stat :LIPS, :lateInningPressureSituations # The batting average allowed by the pitcher to opposing hitters in Late Inning Pressure Situations, which is any at-bat in the seventh inning or later, with the batting team either leading by one run, tied, or has the potential tying run on base, at bat, or on deck.
    def_stat :MB_9, :baserunnerPer9Innings do (hit + baseOnBall) / inningPitched * 9 end
    def_stat :OBA, :onBaseAgainst do (hit + baseOnBall + hitBatsmen) / batterFaced end # not precisely
#    def_stat :P_GS, :pitchesPerStart
    def_stat :P_IP, :pitchesPerInningsPitched do numberOfPitchThrown / inningPitched end
    def_stat :SLG, :sluggingPercentage do totalBase / batterFaced end # not precise
    def_stat :WHIP, :walksPlusHitsOverInningsPitched do (hit + baseOnBall) / inningPitched end 
    def_stat :WPCT, :winningPercentage do win / (win + loss) end
end

class FieldingStat < BaseStat
    def_stat :A, :assist
    def_stat :CS, :caughtStealing
    def_stat :DP, :doublePlayer
    def_stat :E, :error
    def_stat :G, :gamesPlayed
    def_stat :INN, :inningPlayed
    def_stat :OFA, :outfieldAssist
    def_stat :PB, :passedBall
    def_stat :PO, :putout
    def_stat :SB, :stolenBase
    def_stat :TC, :totalChance
    def_stat :TP, :triplePlay

    def_stat :FPCT, :fieldingPercentage do (putout + assist) / (putout + assist + error) end

    # FIXME it uses batting stat!
    def_stat :DEF, :defensiveEfficiencyRating do 1 - (hit - homeRun) / (plateAppearance - homeRun - baseOnBall - hitByPitch - strikeOut) end

    def_stat :RF, :rangeFactor do (putout + assist) * 9 / inning end
end

class BaseballStat # < BaseStat
    attr_accessor :batting, :pitching, :fielding

    # TODO switch hitter, utility man stat
    def initialize(attr={})
        @batting, @pitching, @fielding = BattingStat.new, PitchingStat.new, FieldingStat.new
        @attr = attr
    end

    def set_attr(name, value)
        @attr[name.to_sym] = value
    end

    def method_missing(name, *args)
        if name.to_s.match(/=$/)
            set_attr(name.to_s.chop, *args)
        else
            @attr.has_key?(name) ? @attr[name] : nil
        end
    end
end
