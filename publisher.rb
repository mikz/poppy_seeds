
 
require 'rack'
require 'pry'
 
require 'redis'

require 'securerandom'
require 'json'

redis = Redis.new

app = ->(env) do
  request = Rack::Request.new(env)
  def request.headers
    headers = @env.keys.grep(/^HTTP_/)
    headers.zip @env.values_at(*headers)
  end
  uuid = SecureRandom.uuid
  serialize = [request.request_method, request.fullpath, request.headers, request.body.read]

  
  response = nil
  redis.subscribe(uuid) do |on|
    on.message do |channel, msg|
      response = JSON.parse(msg)
      redis.unsubscribe
    end

    redis.rpush "requests", [ uuid, serialize ].to_json
  end

  response
end
 
Rack::Handler::WEBrick.run app
