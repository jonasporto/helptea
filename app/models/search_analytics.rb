class SearchAnalytics
  
  def self.track_event(event_type, request)
  	 self.new(request.remote_ip, request.query_parameters[event_type][:query])
  end

  private
  def initialize(user_id, query)
  	p user_id
  	p query

  end
end