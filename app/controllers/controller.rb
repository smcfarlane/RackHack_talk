require 'pry'

module Slides
  class Controller
    attr_reader :app, :request

    def initialize(app)
      @app = app
      @request = app.request
    end

    def render(body: '', status: 200, headers: {})
      [status, headers, body.respond_to?(:each) ? body : [body]]
    end
  end
end
