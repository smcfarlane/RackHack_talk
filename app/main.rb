require 'pry'
require 'rack'
require_relative 'controllers/pages_controller'
require_relative 'controllers/api_controller'

module Slides
  class App
    attr_reader :request, :root

    def initialize(env)
      @request = Rack::Request.new(env)
      @root = Pathname.new(__FILE__).dirname.parent
    end

    def self.call(env)
      @route_match = env['route_match']
      klass = Object.const_get( "Slides::#{@route_match.first}Controller" )
      controller = klass.new(self.new(env))
      controller.send(@route_match[1])
    end
  end
end
