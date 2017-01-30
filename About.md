This repository was a technical challenge with some goals that I'll describe bellow.

# Goals

- To create a real-time search box, where users search articles. 
- Record their input in real-time and ultimately display analytics & trends on what people are searching for the most. 
- Expect thousands of requests per hour, so think of scalability. 

## User starts typing: 
 
1. Ho 
2. How do 
3. How do I canc 
4. How do I cancel my acc 
5. How do I cancel my subscription 
 
Your goal is to generate clean analytics where you only keep the final search query instead of 
incomplete sentences, all of this should be ordered by the highest frequency. 


Good Example of Analytics: 
 
● How do I cancel my subscription (32 searches) 
● What is my account number (12 searches) 
● How do I signup (6 searches) 
 
Bad Example of Analytics: 
 
● How do I cancel my subscription (32 searches) 
● How do I  (32 searches) 
● How do  (32 searches) 
● What is my account number (12 searches) 
● What i​  (12 searches) 


# Enviroment Summary

- Rails 5.0.1
- Rspec
- Redis
- Sidekiq

Concerned about record realtime search segments and scalability I pick Redis as a primary storage for search queries because Redis is fast enough ([and with good benchmarks](https://redis.io/topics/benchmarks)) and already ready to scale horizontally.

It store search segments that will be processed later (each 10 seconds) by Sidekiq.

```
app/jobs/analytics_job.rb
```
```ruby
class AnalyticsJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  
  sidekiq_options retry: false
  recurrence { secondly(10) }

  def perform
    Analytics.update_stats!
  end
end
```

By the way, Analytics class was intended to be a extracted in to a gem in future , due the logic of processing search doesn't belong to a web Rails app at all.

```
app/models/analytics.rb
```
```ruby
class Analytics
  include Redis::Objects
  private_class_method :new

  class << self

    def track(id: 0, query:, results_count:)
      Analytics::Query.track(
        id: id, 
        query: query, 
        results_count: results_count
      )
    end

    def update_stats!
      stats.update_stats!
    end

    def clear_stats!
      stats.clear_stats!
    end

    def stats_all
      stats.all
    end

    private
    
    def stats
      @@_stats ||= Analytics::Stats.new
    end
  end
end
```
The query class handles all query records, it saves and associate query to a given user and put in the queue, a metadata to be handled by Stats class later.

```
app/models/analytics/query.rb
```

```ruby
class Analytics::Query
  include Redis::Objects

  private_class_method :new

  set :queue

  def self.track(id: 0, query:, results_count:)
    user = Analytics::User.new(id)
    user.query << query.to_s.downcase
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
```
The User class, has the association of User x Query handling new queries to a given user, and stores for a time (half hour) queries already processed from this user, to decrease double hits stats for a same user.
```
app/models/analytics/user.rb
```

```ruby

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
    @_queries ||= query.members - processed.members
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
```

The last but now least class in the hierarchy is the Stats class, this processes and store stats verifying the user queries and the already stored classes. is a part from your responsibility remove segments and build correct sentences.

```
app/models/analytics/stats.rb
```

```ruby

class Analytics::Stats
  include Redis::Objects
  
  sorted_set :query_hits, :global => true

  def all
    query_hits.revrange(0, -1, with_scores: true)
  end

  def update_stats!
    until (user_id = Analytics::Query.next) == nil
      update_stats_from_user user_id
    end

    update_query_stats
    'OK'
  end

  def clear_stats!
    query_hits.clear
  end

  private

  def update_stats_from_user(user_id)
    user = Analytics::User.find(user_id)
    update_stats_for_queries user.queries
    user.clear_queries!
  end
  
  def update_stats_for_queries(queries)
    queries.each_with_index do |el, i|
      nxt_q = queries[i + 1] || ''
      incr(el) unless nxt_q.start_with? el
    end
  end

  def update_query_stats
    query_hits.sort.tap do |stats|
      stats.each_with_index do |el, i|
        nxt = stats[i + 1] || ''
        remove_from_stats(el) if nxt.start_with? el
      end
    end
  end

  def remove_from_stats(item)
    query_hits.delete(item)
  end

  def incr(*args)
    query_hits.incr(*args)
  end
end

```

Check a live version at [Heroku](https://helptea.herokuapp.com)
