require 'pry'
require 'pp'
require 'digest'
require_relative './spam_fighter'
require_relative './spam_record'

class Hack::SpamChecker
  attr_reader :request

  def initialize(request, timeout, max_count)
    @request = request
    @timeout = timeout
    @max_count = max_count
  end

  def allow?
    spam_record.inc.set
    request.env['spam_count'] = spam_record.count
    check?
  end

  private

  def request_key
    key = "#{request.user_agent}#{request.ip}"
    @request_key ||= Digest::SHA1.digest(key)
  end

  def spam_record
    @spam_record ||= Hack::SpamRecord.new(
      @request_key,
      @timeout,
      @max_count
    ).get
  end

  def check?
    spam_record.count < @max_count
  end
end
