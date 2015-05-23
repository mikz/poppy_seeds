

require 'rack'
require 'pry'

require 'redis'

require_relative 'protocol'

protocol = Protocol.new(Redis.new)

app = ->(env) do
  request = Rack::Request.new(env)
  def request.headers
    headers = @env.keys.grep(/^HTTP_/)
    headers.zip @env.values_at(*headers)
  end

  uuid = protocol.push(method: request.request_method,
                       path: request.fullpath,
                       headers: request.headers,
                       body: request.body.read)

  protocol.response(uuid)
end

static = ->(env) do
   ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']]
end



Rack::Handler::WEBrick.run ENV['REDIS'] ? app : static
