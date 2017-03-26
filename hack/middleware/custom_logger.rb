require 'pry'
require 'pp'
require 'rack'

class Hack::Logger
  attr_accessor :request, :logger

  def initialize(app, file_logger: nil, std_out_logger: nil)
    @app = app
    @file_logger = file_logger
    # default logger to file in ./log/app.log, split at 10mb
    # keep 10 files
    @file_logger ||= Logger.new('./log/app.log', 10, 10_485_760)
    @std_out_logger = std_out_logger
    @std_out_logger ||= Logger.new(STDOUT)
    @logger = Multilogger.new(@file_logger, @std_out_logger)
  end

  def call(env)
    env[Rack::RACK_LOGGER] = @logger
    @request = Rack::Request.new(env)
    log
    response = @app.call(env)
    request.logger.info('--- Request Ended ---')
    response
  end

  def log
    stdmsg = "[#{request.request_method}] #{request.url}"
    request.logger.info(stdmsg)
  end
end

class Multilogger
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
