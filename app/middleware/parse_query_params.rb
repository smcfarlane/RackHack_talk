
module Slides
  class ParseQueryParams
    def initialize(app)
      @app = app
    end

    def call(env)
      params = parse_query(env['QUERY_STRING'])
      env['clean_params'] = params
      @app.call(env)
    end

    private

    def parse_query(params)
      parts = params.split('&')
      parts.each_with_object({}) do |part, hash|
        key, value = part.split('=')
        hash[key] = value
      end
    end
  end
end
