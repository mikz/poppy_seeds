local redis = require 'resty.redis'
local cjson = require 'cjson'

redis.add_commands(
  "addjob", "getjob", "ackjob",
  "fastack", "working", "nack",
  "hello", "qlen", "qstat",
  "qpeek", "enqueue", "dequeue",
  "deljob", "show", "qscan",
  "jscan", "pause"
)


local red = redis:new()

assert(red:connect("127.0.0.1", 7711))


-- consider using ngx.req.get_body_data() instead
-- local request = { ngx.req.get_method(), ngx.req.get_headers(), ngx.var.request_body }
local request = { 'GET', { ['Host'] = 'example.com' }, 'body' }

-- red:set_keepalive(10000, 100)
while true do
  local res, err = red:getjob('from', 'poppy-seeds')

  res = unpack(res)
  if err then
  	ngx.say(err)
  	ngx.exit(500)
  end

  local queue, job_id, payload = unpack(res)
  local request = cjson.decode(payload)

  local response = { 200, { ['Status'] = 'OK' }, { 'body', 'part 2' } } 

  local job_id,err = red:addjob(job_id, cjson.encode(response), 100)

  ngx.say(job_id)
end

