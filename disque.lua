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
  return red:connect(host or "127.0.0.1", port or 7711)
end

_M.push = function(queue, data)
  assert(queue, 'missing queue parameter')
  
  local payload = cjson.encode(data)

  local job_id,err = assert(red:addjob(queue, payload, 100))
  return job_id
end

_M.request = function()
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

_M.call = function()
  assert(_M.connect())

  local job_id = _M.push('poppy-seeds', _M.request())

  local response_id, response =  _M.pop(job_id)
  local status, headers, body = unpack(response)
  
  for h, v in pairs(headers) do
    ngx.header[h] = v
  end

  assert(headers['X-Request-ID'] == job_id, 'job_id does not match')

  ngx.print(body)
  ngx.exit(status)
end

return _M
