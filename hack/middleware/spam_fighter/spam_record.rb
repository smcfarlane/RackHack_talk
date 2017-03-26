require 'pry'
require 'pp'
require 'redis'
require_relative './spam_fighter'

class Hack::SpamRecord
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
    delete if expired?
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
    @count = 0
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

  def expired?
    timestamp < Time.now
  end

  def current_value
    "#{@count}::#{(Time.now + @timeout).to_i}"
  end
end
