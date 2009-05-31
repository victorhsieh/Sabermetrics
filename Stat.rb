class BaseStat
    def initialize(stats)
        set_stats stats
    end

    def self.inherited(derived)
        derived.class_eval {
            @abbr_map = {}
        }
    end

    def self.def_stat(abbr, stat, &formula)
        @abbr_map[abbr] = stat
        if block_given?
            define_method stat, formula
        else
            attr_reader stat
        end
        alias_method abbr, stat
    end

    def self.to_canonical(name)
        @abbr_map.has_key?(name) ? @abbr_map[name] : name
    end

    def set_stats(stats={})
        stats.each_pair do |key, value|
            key = self.class.to_canonical key
#use instance_set
            eval "@#{key} = #{value}.to_f"
        end
    end
end

class BattingStat < BaseStat
    def_stat :G, :game
    def_stat :TPA, :totalPlateApperance
    def_stat :AB, :atBase
    def_stat :H, :hit # do single + double + triple + homeRun end
# may need to replace attr_reader with our own return-attr-if-exist-prior-to-function getter
    def_stat :H2B, :double
    def_stat :H3B, :triple
    def_stat :HR, :homeRun
    def_stat :GS, :grandSlamHomeRun
    def_stat :RBI, :runsBattedIn
    def_stat :SAC, :sacrificeBunt
    def_stat :SF, :sacrificeFly
    def_stat :LOB, :leftOnBase

    def_stat :SO, :strikeOut
    def_stat :BB, :basesOnBall
    def_stat :HBP, :hitByPitch
    def_stat :IBB, :intentionalWalks
    def_stat :GO, :groundOut
    def_stat :AO, :flyOut
    def_stat :GIDP, :groundIntoDoublePlay
    def_stat :TP, :triplePlay

    def_stat :NP, :numberOfPitch
    def_stat :R, :runsScored
    def_stat :SB, :stolenBase
    def_stat :CS, :caughtStealing

    def_stat :LIPS, :lateInningPresureSituation

    def_stat :H1B, :single do hit - double - triple - homeRun end
    def_stat :TB, :totalBase do single + 2 * double + 3 * triple + 4 * homeRun end


    def_stat :AVG, :batAverage do hit / atBase end
    def_stat :OBP, :onBasePercentage do
        # XXX intentionalWalks doesn't counts in MLB
        (hit + basesOnBall + hitByPitch + intentionalWalks) /
        (atBase + basesOnBall + hitByPitch + sacrificeFly + intentionalWalks)
    end
    def_stat :SLG, :sluggingPercentage do totalBase / atBase end
    def_stat :OPS, :onBasePercentagePlusSluggingPercentage do
        onBasePercentage + sluggingPercentage
    end
end
