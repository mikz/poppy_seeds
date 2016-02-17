local redis = require 'resty.redis'
local cjson = require 'cjson'
local resty_uuid  = require 'resty.uuid'
local inspect = require 'inspect'
local _M = {}
local red

-- this is really shitty way to do it, but keepalive does not work
_M.connect = function(host, port) 
  red = redis:new()
  return red:connect(host or "127.0.0.1", port or 6379)
end

_M.push = function(queue, data)
  assert(queue, 'missing queue parameter')
  
  local uuid = resty_uuid.generate()
  local payload = cjson.encode{uuid, data}

  local res,err = assert(red:rpush(queue, payload))

  return uuid
end

_M.request = function()
  -- consider using ngx.req.get_body_data() instead
  -- local request = { ngx.req.get_method(), ngx.req.get_headers(), ngx.var.request_body }
  return { 'GET', { ['Host'] = 'example.com' }, {'body'} }
end

_M.ack = function(job_id) 
  return red:publish("ack", job_id)
end

_M.pop = function(queue) 
    assert(queue, 'missing queue parameter')

    local res, err = assert(red:blpop(queue, 0))
    local queue, data = unpack(res)
    local job_id, payload = unpack(cjson.decode(data))

    return job_id, payload
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

