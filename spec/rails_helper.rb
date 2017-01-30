ENV["RAILS_ENV"] ||= "test"

require File.expand_path("../../config/environment", __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "spec_helper"
require "rspec/rails"
require "capybara/rspec"

Capybara.register_driver :selenium_chrome do |app|
 Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.javascript_driver = :selenium_chrome

RSpec.configure do |config|
end
