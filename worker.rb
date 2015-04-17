require 'json'
require 'redis'

require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: worker.rb [options]"

  opts.on("-nWORKERS", "--workers=WORKERS", "Spawn given number of workers") do |n|
    options[:workers] = n.to_i
  end
end.parse!

if workers = options[:workers]
  children = workers.times.map { fork }

  if children.all?
    trap('INT') do
      puts "Stopping #{children.size} workers"

      children.map do |pid|
        puts "Sending QUIT to #{pid}"
        Process.kill('QUIT', pid)
      end
    end

    puts 'Starting supervising children processes'
    statuses = Process.waitall.map{|(_pid, status)| status }
    exit statuses.all?(&:success?)
  end
end

redis = Redis.new

while job = redis.blpop('requests')
  list, element = job
  uuid, request = JSON.parse(element)

  redis.lpush "response/#{uuid}", ['200', {'Content-Type' => 'text/html'}, ['A barebones rack app.']].to_json
end
