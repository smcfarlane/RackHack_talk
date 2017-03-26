require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'rack'
require 'rack/contrib'
require 'rack/lobster'
require 'rack/protection'
require_relative 'app/builders/example'
require_relative 'app/builders/rack_contrib_example'
require_relative 'app/middleware/router'
require_relative 'app/main'
require_relative 'hack/app'
require_relative 'hack/middleware/spam_fighter'
require_relative 'hack/middleware/custom_logger'

class Integer
  def minutes
    self
  end

  def ago
    Time.now - self
  end
end

use Rack::BounceFavicon

use Rack::TryStatic,
    root: 'public',
    urls: ['/assets', '/components', '/images', '/fonts'],
    try: ['']

map '/example' do
  run Slides::Example.builder
end

map '/middleware-example' do
  run Slides::Example.middleware_builder
end

map '/backstage-example' do
  run Slides::RackContribExample.backstage_builder
end

map '/timezone-example' do
  run Slides::RackContribExample.timezone_builder
end

map '/lobster' do
  run Rack::Lobster.new
end

map '/hack-app' do
  use Rack::NestedParams
  use Hack::Logger
  use Hack::SpamFighter, 3, 120, [
    { method: :get, path: %r{/for/spammers} }
  ]
  use Rack::Session::Pool, expire_after: 2_592_000
  use Rack::Protection::RemoteToken
  use Rack::Protection::SessionHijacking
  run Hack::App
end

use Slides::Router

run Slides::App
