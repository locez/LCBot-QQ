require 'webrick'
require 'json'
require 'net/http'
$api_addr = "http://127.0.0.1:5000"
module LCBot
    class QQ
        def initialize(param)
            get_config
            generate_config
            req = param[:req]
            res = param[:res]
            unless req.nil?
        	    obj = JSON.parse(req.body)
                @event,@uid,@name = get_event_uid_name(obj)
            end
        end

        def get_config
            @configtext = File.readlines("LCBot.conf").join
        end

        def generate_config
            config = eval(@configtext)
            @@group_list = config[:group_list]
            @@welcome_message = config[:welcome_message]
            @@special_message = config[:special_message]
        end
        
        def deal_event
			case @event
		    when 'new_group_member'
			    welcome()
		    when 'push_articles'
                send_group_message(@uid,get_articles)
            end
    	end

    	def welcome
	    	if @@group_list.include?(@uid)
                generate_config
                welcome_message = @@special_message[@uid].nil? ? @@welcome_message : @@special_message[@uid]
			    send_group_message(@uid,welcome_message)
	    	end
    	end

        def push_articles
            send_all_group_message(get_articles)
        end

        def get_articles
            content = Net::HTTP.get_response(URI.parse("https://linux.cn")).body.force_encoding('utf-8')
	       	content.sub!(/.+?<ul class="article-list leftpic">/m,'')
            content.sub!(/ <\/li><\/ul>.+$/m,'')
            articles = "今天的文章推送是：\n"
            content.scan(/<span class="title"><a href=\"(.+?)".+?title=\"(.+?)"/) { |m|
			    articles += m[1] + "\n"
			    articles += m[0] + "\n"
            }
		    articles 
	    end


        def send_group_message(uid, content)
		    url = URI.parse([$api_addr,"/openqq","/send_group_message?"].join)
		    response = Net::HTTP.post_form(url,{"uid"=> uid,"content" => content})
	    end

        def send_all_group_message(content)
		    @@group_list.each do |uid|
			    send_group_message(uid, content + "现在的时间是：\n" + `date`)
                sleep(20)
		    end
	    end

    	def get_event_uid_name(obj)
	    	name = ""
		    case obj['post_type']
	    	when 'event'
		    	case obj['event']
			    when 'new_group_member'
				    event = 'new_group_member'
			    	uid = obj['params'].last['uid']
				    name = obj['params'][0]['name']
			    end
    		when 'receive_message'
	    		if obj['content'].include?("!欢迎新人")
		    		event = 'new_group_member'
			    	uid = obj['group_uid']
		            name = "Hello"
		    	elsif obj['content'].include?("!推送")
			    	event = 'push_articles'
				    uid = obj['group_uid']
    			end
	    	end	
		    [event,uid,name]
    	end
    end

    
    class Servlet <WEBrick::HTTPServlet::AbstractServlet
	    def do_POST(req,res)
		    bot = QQ.new(:req=>req,:res=>res)
	    	bot.deal_event
	    end
    end
    
    class Server
        
        def initialize(param)
            @server = WEBrick::HTTPServer.new(param)
            trap("INT"){
	            @server.shutdown
            }
            @server.mount "/",Servlet
            @server
        end

        def start
            @server.start 
        end
    end
end

