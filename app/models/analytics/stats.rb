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
