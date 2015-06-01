

if redis_disabled then
	ngx.print "redis not enabled"
	return
end

local redis = require 'resty.redis'
local cjson = require 'cjson'
local resty_uuid  = require 'resty.uuid'
local inspect = require 'inspect'


local red = redis:new()

assert(red:connect("127.0.0.1", 6379))


-- red:set_timeout(0) -- 1 sec

ngx.req.read_body()

local request = {
	path = ngx.var.uri,
	method = ngx.var.request_method,
	headers = ngx.req.get_headers(),
	body = ngx.req.get_post_args()
}

local uuid = resty_uuid.generate()


local res = red:rpush('requests', cjson.encode{ uuid, request })

local response = red:blpop('response/'..uuid, 0)
local payload = response[2]

red:set_keepalive(10000, 100)

local response = cjson.decode(payload)

ngx.status = response[1]
for h,v in pairs(response[2]) do ngx.header[h] = v end
ngx.print(response[3])
