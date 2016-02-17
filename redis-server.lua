local redis = require 'redis'

assert(redis.connect())

while true do

  local job_id, request = redis.pop('poppy-seeds') 
  local method, headers, body = unpack(request)

  assert(redis.ack(job_id))

  local response = { 200, { ['Status'] = 'OK', ['X-Request-ID'] = job_id }, { job_id } }

  assert(redis.push(job_id, response))

  ngx.say(job_id)
end


