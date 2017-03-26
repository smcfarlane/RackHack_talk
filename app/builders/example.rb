require 'rack'
require 'pry'
require_relative '../middleware/append_to_body'
require_relative '../middleware/parse_query_params'

module Slides
  class Example
    def self.builder
      Rack::Builder.new do
        run lambda { |env|
          hello_world = "hello world, path_info: #{env['PATH_INFO']}\n"
          env.each do |(k, v)|
            hello_world << "\n    #{k}: #{v}"
          end
          [200, {}, [hello_world]]
        }
      end
    end

    def self.middleware_builder
      Rack::Builder.new do
        use Slides::ParseQueryParams
        use Slides::AppendToBody, ' this was added by middleware'
        run lambda { |env|
          content = "this is the path: #{env['PATH_INFO']}\n"
          env['clean_params'].each do |key, value|
            content << "  key: #{key}, value: #{value}\n"
          end
          [200, {}, [content]]
        }
      end
    end
  end
end
