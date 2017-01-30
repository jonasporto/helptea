$redis = if Rails.env.production?
           Redis.new(url: ENV["REDIS_URL"])
         else
           Redis.new
         end

$redis = Redis::Namespace.new(:helptea, :redis => $redis)