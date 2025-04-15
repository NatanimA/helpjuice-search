class AnalyticsController < ApplicationController
  def index
    @user_id = request.remote_ip
    @user_analytics = SearchQuery.user_stats(@user_id)
    @overall_analytics = SearchQuery.global_stats(10)
  rescue => e
    Rails.logger.error "Failed to load analytics data: #{e.message}"
    @user_analytics = []
    @overall_analytics = []
  end
end
