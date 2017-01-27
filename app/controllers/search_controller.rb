class SearchController < ApplicationController
  def index
    track_event(:search, request)
  end

  private
  def track_event(event, request)
    Analytics.track_event(event, request)
  end
end
