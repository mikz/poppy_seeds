local resty_redis = require 'resty.redis'
local cjson = require 'cjson'
local resty_uuid  = require 'resty.uuid'
local inspect = require 'inspect'
local _M = {}

-- this is really shitty way to do it, but keepalive does not work
_M.connect = function(host, port) 
  local redis = resty_redis:new()
  assert(redis:connect(host or "127.0.0.1", port or 6379))
  return redis
end

_M.push = function(redis, queue, data)
  assert(queue, 'missing queue parameter')
  
  local uuid = resty_uuid.generate()
  local payload = cjson.encode{uuid, data}

  local res,err = assert(redis:rpush(queue, payload))

  return uuid
end

_M.request = function()
  -- consider using ngx.req.get_body_data() instead
  -- local request = { ngx.req.get_method(), ngx.req.get_headers(), ngx.var.request_body }
  return { 'GET', { ['Host'] = 'example.com' }, {'body'} }
end

_M.ack = function(redis, job_id) 
  return redis:publish("ack", job_id)
end

_M.pop = function(redis, queue) 
    assert(queue, 'missing queue parameter')

    local res, err = assert(redis:blpop(queue, 0))
    local queue, data = unpack(res)
    local job_id, payload = unpack(cjson.decode(data))

    return job_id, payload
end

_M.disconnect = function(redis)
-- return redis:close()
  return redis:set_keepalive(10000, 100)
end

_M.call = function()
  local redis = assert(_M.connect())

  local job_id = _M.push(redis, 'poppy-seeds', _M.request())

  local response_id, response =  _M.pop(redis, job_id)

  assert(_M.disconnect(redis))

  local status, headers, body = unpack(response)
  
  for h, v in pairs(headers) do
    ngx.header[h] = v
  end

  assert(headers['X-Request-ID'] == job_id, 'job_id does not match')

  ngx.print(body)
  ngx.exit(status)
end

return _M

