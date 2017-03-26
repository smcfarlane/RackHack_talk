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
          run lambda {|_env|
            [200, {}, ['The backstage file is not blocking this from being shown']]
          }
        end
        run lambda {|env|
          case env['PATH_INFO']
          when /create-file/
            File.write('public/backstage.html', '<h1>Backstage File</h1>')
            [200, {}, ['backstage file created']]
          when /delete-file/
            File.delete('public/backstage.html')
            [200, {}, ['backstage file deleted']]
          else
            html = '
<html>
  <body>
    <h3>Backstage Example</h3>
    <ul>
      <li><a href="/backstage-example/test">test</a></li>
      <li><a href="/backstage-example/create-file">Create file</a></li>
      <li><a href="/backstage-example/delete-file">Delete File</a></li>
    </ul>
  </body>
</html>'
            [200, {}, [html]]
          end
        }
      end
    end

    def self.timezone_builder
      Rack::Builder.new do
        use Rack::TimeZone
        run lambda {|env|
          content = "
<h1>
  timezone offset: #{env['rack.timezone.utc_offset'] / 60 / 60} hours
</h1>"
          content += "
<script>#{Rack::TimeZone::Javascript}\nsetTimezoneCookie()</script>"
          [200, {}, [content]]
        }
      end
    end
  end
end
