require 'pry'
require 'pp'
require 'rack'

class Hack::Logger
  attr_accessor :request, :logger

  def initialize(app, file_log: nil, stdout_log: nil)
    @app = app
    @file_log = file_log
    # default logger to file
    # in ./log/app.log, split at 10mb
    # keep 10 files
    @file_log ||= Logger.new(
      './log/app.log',
      10,
      10_485_760
    )
    @stdout_log = stdout_log
    @stdout_log ||= Logger.new(STDOUT)
    @logger = Hack::Multilogger.new(
      @file_log,
      @stdout_log
    )
  end

  def call(env)
    env[Rack::RACK_LOGGER] = @logger
    @request = Rack::Request.new(env)
    request.logger.info(standard_message)
    @app.call(env)
  end

  def standard_message
    "[#{request.request_method}] #{request.url}"
  end
end

class Hack::Multilogger
  def initialize(*loggers)
    @loggers = loggers
  end

  def info(msg)
    @loggers.each { |l| l.info(msg) }
  end

  def warn(msg)
    @loggers.each { |l| l.warn(msg) }
  end

  def error(msg)
    @loggers.each { |l| l.warn(msg) }
  end
end
