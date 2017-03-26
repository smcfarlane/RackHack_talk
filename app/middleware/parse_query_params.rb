
module Slides
  class ParseQueryParams
    def initialize(app)
      @app = app
    end

    def call(env)
      env['clean_params'] = parse_query_params(env['QUERY_STRING'])
      @app.call(env)
    end

    private

    def parse_query_params(params)
      parts = params.split('&')
      parts.each_with_object({}) do |part, hash|
        key, value = part.split('=')
        hash[key] = value
      end
    end
  end
end
