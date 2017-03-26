require 'rack'

module Slides
  class SlideManager
    def self.build
      Rack::Builder.new do
        map '/slides' do
          run lambda { |env|
            
          }
        end
      end
    end

    def collect_slides

    end
  end
end
