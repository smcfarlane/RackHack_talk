
module Slides
  class AppendToBody
    def initialize(app, value)
      @app = app
      @value = value
    end

    def call(env)
      status, headers, body = @app.call(env)
      content = body.last + @value
      [status, headers, [content]]
    end
  end
end
