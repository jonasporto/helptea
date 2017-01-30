
uri = URI.parse(ENV["REDISTOGO_URL"])

$redis = if Rails.env.production?
           Redis::Namespace.new(:helptea, Redis.new(:host => uri.host, :port => uri.port, :password => uri.password))
         else
           Redis::Namespace.new(:helptea, :redis => Redis.new)
         end