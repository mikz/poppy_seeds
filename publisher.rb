
 
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

  redis.rpush "requests", [ uuid, serialize ].to_json
  uuid, payload = redis.blpop "response/#{uuid}"

  JSON.parse(payload)
end

static = ->(env) do
   ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
end


 
Rack::Handler::WEBrick.run ENV['REDIS'] ? app : static
