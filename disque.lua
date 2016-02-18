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

local _M = {}
local red

-- this is really shitty way to do it, but keepalive does not work
_M.connect = function(host, port)
  red = redis:new()
  local ret, err = red:connect(host or "127.0.0.1", port or 7711)
  red:set_timeout(10000)
  return red, err
end

_M.push = function(queue, data)
  assert(queue, 'missing queue parameter')
  local payload = cjson.encode(data)

  local job_id,err = assert(red:addjob(queue, payload, 100, 'ttl', 3, 'retry', 1))
  return job_id
end

_M.request_data = function()
  -- consider using ngx.req.get_body_data() instead
  -- local request = { ngx.req.get_method(), ngx.req.get_headers(), ngx.var.request_body }
  return { 'GET', { ['Host'] = 'example.com' }, {'body'} }
end

_M.ack = function(job_id)
  return red:ackjob(job_id)
end

_M.pop = function(queue)
    assert(queue, 'missing queue parameter')

    local res, err = assert(red:getjob('from', queue))

    local job = unpack(res)
    local queue, job_id, payload = unpack(job)

    return job_id, cjson.decode(payload)
end

local inspect = require 'inspect'

_M.respond = function(status, headers, body)
  for h, v in pairs(headers) do
    ngx.header[h] = v
  end

  ngx.print(body)
  ngx.exit(status)
end

_M.call = function()
   local job_id, status, headers, body = _M.response()

   assert(headers['X-Request-ID'] == job_id, 'job_id does not match')

   return _M.respond(status, headers, body)
end

_M.request = function()
  assert(_M.connect())
  local job_id = _M.push('request:poppy-seeds', _M.request_data())

  return job_id
end

_M.response = function()
  local job_id = _M.request()

  local response_id, response =  _M.pop('response:'..job_id)
  local status, headers, body = unpack(response)

   -- We should ack the response_id to avoid leaving active jobs.
   _M.ack(response_id)

  return job_id, status, headers, body
end

_M.jobs = function(queue)
  if queue then
    queue = { 'queue', queue }
  else
    queue = {}
  end

  local ret, err = assert(red:jscan())

  local _, jobs = unpack(ret)

  return #jobs
end

return _M
