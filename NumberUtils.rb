#!/usr/bin/ruby

module NumberUtils
    # Fix inning notation of two cases:
    #  1. 1.66 -> 1.6666...
    #  2. 1.2  -> 1.6666...
    def fix_inning_rounding(ip)
        decimal = ip - ip.floor
        if decimal > 0.5 or (decimal - 0.2).abs <= 0.0000001
            ip.floor + 2.0/3
        elsif decimal > 0
            ip.floor + 1.0/3
        else
            ip
        end
    end

    module_function :fix_inning_rounding
end
