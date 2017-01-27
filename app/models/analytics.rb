class Analytics
  
  def self.track_event(event, request)
    $redis.sadd("#{event}:#{request.remote_ip}", request.query_parameters[:q])
    $redis.rpush("#{event}:processing-queue", request.remote_ip)
  end
end
