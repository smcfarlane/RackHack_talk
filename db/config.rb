require 'sequel'
require 'fileutils'

APP_NAME = 'hack'.freeze
module Database
  DB_MODES = %w(dev live test).freeze

  def self.url(mode)
    raise "Unsupported runtime mode: #{mode.inspect}" unless DB_MODES.include?(mode.to_s)
    "postgres://localhost/#{APP_NAME}_#{mode}"
  end
end
