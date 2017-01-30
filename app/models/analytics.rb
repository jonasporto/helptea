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
