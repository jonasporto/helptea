$redis = if Rails.env.production?
           uri = URI.parse(ENV["REDISTOGO_URL"])
           Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
         else
           Redis.new
         end

#$redis = Redis::Namespace.new(:helptea, :redis => $redis)