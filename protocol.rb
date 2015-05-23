require 'securerandom'
require 'json'
require 'redis'

class Protocol
  LIST = 'requests'.freeze
  TIMEOUT = 1

  def initialize(redis)
    @redis = redis
  end

  def self.server(redis)
    new(redis).extend(Server)
  end

  def self.worker(redis)
    new(redis).extend(Worker)
  end

  module Worker
    def request
      response = @redis.blpop(LIST, TIMEOUT) or return

      _list, job = response

      _uuid, _request = JSON.parse(job)
    end

    def respond(uuid, status:, headers:, body:)
      payload = [status, headers, body].to_json

      @redis.lpush("response/#{uuid}", payload)
    end

  end

  module Server
    def push(method:, path:, headers:, body:)
      uuid = SecureRandom.uuid
      request = [ method, path, headers, body ]
      payload = [ uuid, request ].to_json

      @redis.rpush(LIST, payload)

      uuid
    end

    def response(uuid)
      _uuid, payload = @redis.blpop("response/#{uuid}")

      _status, _headers, _body = JSON.parse(payload)
    end
  end

  module Benchmark
    UUID = SecureRandom.uuid

    PAYLOAD = [
        UUID,
        [ 'GET', '/', {}, '']
    ].to_json.freeze

    RESPONSE = "response/#{UUID}".freeze

    def push(**)
      @redis.rpush(LIST, PAYLOAD)
    end

    def response(*)
      @redis.blpop(RESPONSE)
    end

    def reset
      super
      @redis.del(RESPONSE)
    end
  end

  def reset
    @redis.del(LIST)
  end

  def requests
    @redis.llen(LIST)
  end
end
