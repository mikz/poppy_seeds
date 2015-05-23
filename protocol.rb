require 'securerandom'
require 'json'
require 'redis'

class Protocol
  LIST = 'requests'.freeze

  def initialize(redis)
    @redis = redis
  end

  def push(method:, path:, headers:, body:)
    uuid = SecureRandom.uuid
    request = [ method, path, headers, body ]
    payload = [ uuid, request ].to_json

    @redis.rpush(LIST, payload)

    uuid
  end

  def reset
    @redis.del(LIST)
  end

  def requests
    @redis.llen(LIST)
  end

  def request
    _list, job = @redis.blpop(LIST)

    _uuid, _request = JSON.parse(job)
  end

  def respond(uuid, status:, headers:, body:)
    payload = [status, headers, body].to_json

    @redis.lpush("response/#{uuid}", payload)
  end

  def response(uuid)
    _uuid, payload = @redis.blpop("response/#{uuid}")

    _status, _headers, _body = JSON.parse(payload)
  end
end
