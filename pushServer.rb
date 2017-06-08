$LOAD_PATH << '.'
require 'Bot'
loop do
    sleep 60
     t=Time.now
     if t.hour == 9 and t.min == 30
        LCBot::QQ.new(:req=>nil,:res=>nil).push_articles
     end
end
