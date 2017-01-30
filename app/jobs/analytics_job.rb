class AnalyticsJob
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  
  sidekiq_options retry: false
  recurrence { secondly(10) }

  def perform
    Analytics.update_stats!
  end
end
