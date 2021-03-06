#!/usr/bin/env ruby

require 'benchmark'
require 'optparse'
require_relative 'protocol'

options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage: test.rb [options]'
  options[:requests] = 100
  options[:warmup] = options[:requests] / 10

  opts.on('-rREQUESTS', '--requests=REQUESTS', 'Test given number of requests') do |n|
    options[:requests] = n.to_i
  end

  opts.on('-wWARMUP', '--warmup=WARMUP', 'Number of requests to warmup the worker') do |n|
    options[:warmup] = n.to_i
  end
end.parse!

$protocol = Protocol.server(Redis.new)

def protocol
  $protocol
end

def fake_request
  {
      method: 'GET',
      headers: { 'HTTP_CONTENT_TYPE' =>  'text/plain' },
      path: '/',
      body: ''
  }
end

def enqueue_requests(n)
  n.times.map{ protocol.push(**fake_request) }
end

def benchmark
  format '%.fms' % (1000 * Benchmark.realtime { yield })
end

def process(uuids)
  response = protocol.method(:response)
  uuids.each do |uuid|
    response.call(uuid)
    uuids.delete(uuid)
  end
end

@worker = $stdin.isatty ? 'ruby worker.rb' : ARGF.read
requests = options.fetch(:requests)
warmup = options.fetch(:warmup)

uuids = []

puts "Will test: #{@worker}"


def start_worker
  $worker ||= begin
    pid = spawn(@worker)
    puts "Started worker: #{@worker} (pid: #{pid})"
    pid
  end
end

protocol.reset

at_exit {
  Process.kill('QUIT', $worker) if $worker
  Process.waitall
}

if warmup > 0
  puts "Enqueuing #{warmup} warmup requests"
  time = benchmark { uuids.concat enqueue_requests(warmup) }
  puts "Enqueued #{warmup} warmup requests in #{time}"

  unless uuids.size == (enqueued = protocol.requests)
    puts "Enqueued #{warmup} but found #{enqueued}. Exiting."
    exit 1
  end

  start_worker

  time = benchmark do
    process(uuids)
  end


  puts "Took #{time} to process #{warmup} warmup requests"
end

## Real benchmark
puts "Enqueuing #{requests} requests"
time = benchmark { uuids.concat enqueue_requests(requests) }

puts "Enqueued #{requests} requests in #{time}"

start_worker

time = benchmark do
  process(uuids)
end

puts "Took #{time} to process #{requests} requests"
