require 'json'
require 'redis'

redis = Redis.new

while job = redis.blpop('requests')
  list, element = job
  uuid, request = JSON.parse(element)

  redis.lpush "response/#{uuid}", ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']].to_json
end
