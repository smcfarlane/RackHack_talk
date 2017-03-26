require 'pry'

module Slides
  class Router
    def initialize(app)
      @app = app
    end

    def call(env)
      env['route_match'] = self.check_path(env['PATH_INFO'])
      @app.call(env)
    end

    def check_path(path)
      case path
      when /\/$/
        ['Pages', :index]
      when /\/slides$/
        ['Api', :slides]
      else
        [nil, nil]
      end
    end
  end
end
