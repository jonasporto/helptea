class Analytics::Query
  include Redis::Objects

  private_class_method :new

  set :queue

  def self.track(id: 0, query:, results_count:)
    user = Analytics::User.new(id)
    user.query << query
    self << id
  end
  
  def self.<<(value)
    query_instance << value
  end

  def self.next
    query_instance.queue.pop
  end
    
  def self.query_instance
    @@_query_instance ||= new
  end

  def id; 0 end
  
  def <<(value)
    queue << value
  end
end