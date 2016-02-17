local redis = require 'redis'

local connection = assert(redis.connect())

while true do

  local job_id, request = redis.pop(connection, 'poppy-seeds')
  local method, headers, body = unpack(request)

  assert(redis.ack(connection, job_id))

  local response = { 200, { ['Status'] = 'OK', ['X-Request-ID'] = job_id }, { job_id } }

  assert(redis.push(connection, job_id, response))

  ngx.say(job_id)
end


