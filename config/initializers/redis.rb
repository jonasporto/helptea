uri = ENV["REDIS_URL"] || "redis://localhost:6379/"
$redis = Redis::Namespace.new(:helptea, redis: Redis.new(:url => uri))