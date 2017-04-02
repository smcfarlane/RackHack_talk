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
            hello world,
            path_info = #{env['PATH_INFO']}
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
          content = "the path: #{env['PATH_INFO']}\n"
          env['clean_params'].each do |key, value|
            content << "  key: #{key}, value: #{value}\n"
          end
          [200, {}, [content]]
        }
      end
    end
  end
end
