class SearchController < ApplicationController

  after_action :track, only: :index

  def index; end

  def stats
    @stats = Analytics.stats_all
  end

  def clear
    Analytics.clear_stats!
    redirect_to action: :stats
  end

  private
  
  def track
    Analytics.track(
      id:  request.remote_ip,
      query:  request.query_parameters[:query],
      results_count: 0
    )

    Analytics.update_stats!
  end
end
