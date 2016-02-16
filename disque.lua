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

local job_id,err = red:addjob('foo', cjson.encode(request), 100)

ngx.print(job_id)
