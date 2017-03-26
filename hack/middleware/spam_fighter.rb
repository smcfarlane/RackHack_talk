require 'pry'
require 'pp'
require 'rack'
require 'digest'
require 'redis'

class Hack::SpamFighter
  attr_reader :request

  def initialize(app, max_count, timeout, watched_routes)
    @app = app
    @max_count = max_count
    @timeout = timeout
    @watched_routes = watched_routes
    @methods = @watched_routes.map { |r| r[:method] }.uniq
    @set = false
  end

  def call(env)
    @request = Rack::Request.new(env)
    return done(env) unless checked_request?
    spam_record.inc.set
    env['spam_count'] = spam_record.count
    return done(env) if allow?
    clear
    [418, {}, [File.read('./public/im_a_teapot.html')]]
  end

  private

  def done(env)
    clear
    @app.call(env)
  end

  def clear
    @request_key = nil
    @spam_record = nil
  end

  def path
    request.path_info
  end

  def method
    request.request_method.downcase.to_sym
  end

  def request_key
    key = "#{request.user_agent}#{request.ip}"
    @request_key ||= Digest::SHA1.digest(key)
  end

  def spam_record
    @spam_record ||= SpamRecord.new(
      @request_key,
      @timeout,
      @max_count
    ).get
  end

  def allow?
    spam_record.count < @max_count
  end

  def checked_request?
    !@watched_routes.detect do |route|
      next unless route[:method] == method
      path =~ route[:path]
    end.nil?
  end
end

class SpamRecord
  attr_reader :count
  def initialize(key, timeout, max_count)
    @key = key
    @max_count = max_count
    @timeout = timeout
  end

  def self.redis
    @redis ||= Redis.new
  end

  def get
    fetch_from_redis
    puts "get was fired #{count} #{timestamp}"
    if expired?
      delete
      @count = 0
    end
    self
  end

  def set
    self.class.redis.set(@key, current_value)
    self
  end

  def inc
    @count += 1 if @count < @max_count
    self
  end

  def delete
    self.class.redis.del(@key)
    self
  end

  def timestamp
    @timestamp_time ||= Time.at(@timestamp.to_i)
  end

  private

  def fetch_from_redis
    value = self.class.redis.get(@key)
    return false if value.nil? || value == ''
    count_str, @timestamp = value.split('::')
    @count = count_str.to_i
  end

  def reset
    set
  end

  def expired?
    now = Time.now
    puts "#{timestamp} < #{now} is #{timestamp < now}"
    timestamp < now
  end

  def current_value
    puts "current value #{@count} #{Time.now + @timeout}"
    "#{@count}::#{(Time.now + @timeout).to_i}"
  end
end
