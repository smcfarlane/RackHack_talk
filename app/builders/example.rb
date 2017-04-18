require 'rack'
require 'pry'
require_relative '../middleware/append_to_body'
require_relative '../middleware/parse_query_params'

module Slides
  class Example
    def self.builder
      Rack::Builder.new do
        run lambda { |env|
          body = <<~BODY
            <h1>
            hello world,
            path_info = #{env['PATH_INFO']}
            </h1>
          BODY
          [200, {}, [body]]
        }
      end
    end

    def self.middleware_builder
      Rack::Builder.new do
        use Slides::ParseQueryParams
        use Slides::AppendToBody, ' this was added by middleware'
        run lambda { |env|
          content = "<h1>the path: #{env['PATH_INFO']}</h1>"
          env['clean_params'].each do |key, value|
            content << "<br><h1>  key: #{key}, value: #{value}</h1><br>"
          end
          [200, {}, [content]]
        }
      end
    end
  end
end
