class SearchController < ApplicationController

  after_action :track, only: :index

  def index
    @stats = Analytics.stats_all
  end

  private
  
  def track
    Analytics.track(
      id:  request.remote_ip,
      query:  request.query_parameters[:query],
      results_count: 0
    )
  end
end
