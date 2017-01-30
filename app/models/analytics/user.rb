class Analytics::User
  include Redis::Objects

  attr_reader :id

  set :query

  # stores processed queries for current user to avoid
  # multiple hits for queries already processed
  set :processed

  def initialize(id)
    @id = id || 0
  end

  def queries
    @_queries ||= query.members.sort - processed.members
  end

  def clear_queries!
    processed << queries
    processed.expire(1800)
    query.clear
    @_queries = nil
  end

  def self.find(user_id)
  	new(user_id)
  end
end
