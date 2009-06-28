#!/usr/bin/ruby

module BaseballUtils
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

    module_function :fix_inning_rounding, :cached
end
