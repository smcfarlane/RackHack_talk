require 'pry'
require 'pp'
require 'rack'
require_relative './spam_checker'

class Hack::SpamFighter
  attr_reader :request

  def initialize(app, max, timeout, watched_routes)
    @app = app
    @max_count = max
    @timeout = timeout
    @watched_routes = watched_routes
  end

  def call(env)
    @request = Rack::Request.new(env)
    return done unless checked_request?
    spam_checker = Hack::SpamChecker.new(
      request,
      @timeout,
      @max_count
    )
    return done if spam_checker.allow?
    error_page = File.read('./public/im_a_teapot.html')
    [418, {}, [error_page]]
  end

  private

  def done
    @app.call(request.env)
  end

  def path
    request.path_info
  end

  def method
    request.request_method.downcase.to_sym
  end

  def checked_request?
    !@watched_routes.detect do |route|
      next unless route[:method] == method
      path =~ route[:path]
    end.nil?
  end
end
