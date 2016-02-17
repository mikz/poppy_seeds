local disque = require 'disque'

assert(disque.connect())

while true do

  local job_id, request = disque.pop('poppy-seeds') 
  local method, headers, body = unpack(request)

  assert(disque.ack(job_id))

  local response = { 200, { ['Status'] = 'OK', ['X-Request-ID'] = job_id }, { job_id } }

  assert(disque.push(job_id, response))

  ngx.say(job_id)
end

