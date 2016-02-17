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

local job_id,err = red:addjob('poppy-seeds', cjson.encode(request), 100)

local res, err = red:getjob('from', job_id)

local job = unpack(res)

local queue, job_id, payload = unpack(job)

local status, headers, body = unpack(cjson.decode(payload))

for h, v in pairs(headers) do
	ngx.header[h] = v
end

ngx.print(body)
ngx.exit(status)
