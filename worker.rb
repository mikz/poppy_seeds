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

def exit_gracefully(pids)
  pids = Array(pids)
  puts "Stopping #{pids.size} workers"

  pids.map do |pid|
    puts "Sending QUIT to #{pid}"
    Process.kill('QUIT', pid)
  end
end

def title(title)
  title << " (supervisor: #{Process.ppid})" if @supervisor
  Process.setproctitle "poppy_seeds: #{title}"
end

def run_loop!(supervisor = Process.ppid)
  puts "Worker (pid: #{Process.pid}) entering run loop"

  protocol = Protocol.worker(Redis.new)

  running = true

  trap('WINCH') do
    puts "Worker (pid: #{Process.pid}) stopping work"
    running = false
  end

  trap('HUP') do
    puts "Worker (pid: #{Process.pid}) resuming work"
    running = true
  end

  wait_loop = -> do
    loop do
      title 'Worker not running'
      sleep 0.01
      break if running
    end unless running

    true
  end

  @processed = 0
  at_exit do
    puts "Worker #{Process.pid} processed #{@processed} requests"
  end
  loop do
    title 'Worker processing requests'

    while wait_loop.call && (job = protocol.request)
      uuid, _request = job
      protocol.respond(uuid,
                       status: 200,
                       headers: {'Content-Type' => 'text/html'},
                       body: ['A barebones rack app.'])
      @processed += 1
    end
  end
rescue Interrupt
  exit
end

if (workers = options[:workers])
  puts "Starting #{workers} workers"
  @supervisor = Process.pid

  children = workers.times.map do
    fork { at_exit { run_loop! } }
  end

  master = true

  trap('INT') { exit_gracefully(children) if master }
  trap('QUIT') { master ? exit_gracefully(children) : exit }

  trap('WINCH') { children.map{|pid| Process.kill('WINCH', pid) } }
  trap('HUP') { children.map{|pid| Process.kill('HUP', pid) } }

  trap('TTIN') do
    if (pid = fork)
      children << pid
      title "Supervisor monitoring: #{children.join(',')}"
    else
      master = false
      at_exit { run_loop! }
    end
  end
  trap('TTOU') { exit_gracefully(children.pop) if master }

  puts "Supervisor (pid: #{Process.pid}) supervising children processes"
  title "Supervisor monitoring: #{children.join(',')}"
  statuses = Process.waitall.map{|(_pid, status)| status }
  exit statuses.all?(&:success?)
else
  run_loop!
end


