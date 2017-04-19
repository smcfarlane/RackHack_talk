require 'rack'
require 'rack/contrib'
require 'rack/contrib/backstage'
require 'rack/contrib/time_zone'
require 'pry'

module Slides
  class RackContribExample
    def self.backstage_builder
      Rack::Builder.new do
        map '/test' do
          use Rack::Backstage, 'public/backstage.html'
          run lambda { |_env|
            [200, {}, ['<html><h1 style="font-size: 4em;">The backstage file is not blocking this from being shown</h1></html>']]
          }
        end
        run lambda { |env|
          case env['PATH_INFO']
          when /create-file/
            File.write('public/backstage.html', '<h1 style="font-size: 4em;">Backstage File :)</h1>')
            [200, {}, ['<html><h1 style="font-size: 4em;">Backstage file created</h1></html>']]
          when /delete-file/
            File.delete('public/backstage.html')
            [200, {}, ['<html><h1 style="font-size: 4em;">Backstage file deleted</h1></html>']]
          else
            html = <<~HTML
              <html>
                <style>
                  body {
                    font-size: 2em;
                  }
                </style>
                <body>
                  <h1>Backstage Example</h1>
                  <ul>
                    <li><a href="/backstage-example/test">Test</a></li>
                    <li><a href="/backstage-example/create-file">Create File</a></li>
                    <li><a href="/backstage-example/delete-file">Delete File</a></li>
                  </ul>
                </body>
              </html>
            HTML
            [200, {}, [html]]
          end
        }
      end
    end

    def self.timezone_builder
      Rack::Builder.new do
        use Rack::TimeZone
        run lambda { |env|
          offset = env['rack.timezone.utc_offset'].to_i
          body = <<~BODY
            <html>
              <h1>
                timezone offset = #{offset / 60 / 60} hours
              </h1>
              <script>
                #{Rack::TimeZone::Javascript}
                setTimezoneCookie()
              </script>
            </html>
          BODY
          [200, {}, [body]]
        }
      end
    end
  end
end
