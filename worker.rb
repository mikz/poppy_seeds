require 'json'
require 'redis'

require 'optparse'
require_relative 'protocol'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: worker.rb [options]'

  opts.on('-nWORKERS', '--workers=WORKERS', 'Spawn given number of workers') do |n|
    options[:workers] = n.to_i
  end
end.parse!

def exit_gracefully(children)
  proc do
    puts "Stopping #{children.size} workers"

    children.map do |pid|
      puts "Sending QUIT to #{pid}"
      Process.kill('QUIT', pid)
    end
  end
end

if (workers = options[:workers])
  children = workers.times.map { fork }

  if children.all?
    trap('INT', exit_gracefully(children))
    trap('QUIT', exit_gracefully(children))

    puts 'Starting supervising children processes'
    statuses = Process.waitall.map{|(_pid, status)| status }
    exit statuses.all?(&:success?)
  end
end

protocol = Protocol.new(Redis.new)

while (job = protocol.request)
  uuid, _request = job
  protocol.respond(uuid,
                   status: 200,
                   headers: {'Content-Type' => 'text/html'},
                   body: ['A barebones rack app.'])
end
