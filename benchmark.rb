require 'benchmark/ips'
require_relative 'protocol'

require 'pry'

class WorkerSuite
  def initialize(protocol)
    @protocol = protocol
    @workers = {}
  end

  def warming(label, warmup)
    stop_workers
    @protocol.reset
    worker = start_worker(label)
    at_exit { quit_worker(worker) }

    @workers[label] = worker
  end

  def running(label, time)
    resume_worker(@workers[label])
  end

  def warmup_stats(time, timing)
    stop_workers
  end

  def add_report(report, stack)
    label = report.label
    quit_worker @workers[label]
    @workers.delete(label)
  end

  private

  def stop_workers
    @workers.values.map do |pid|
      Process.kill('WINCH', pid)
    end
    sleep 1
  end

  def resume_worker(pid)
    Process.kill('HUP', pid)
    sleep 1
  end

  def output
    ENV['DEBUG'] ? {} : { out: '/dev/null' }
  end

  def debug?
    ENV['DEBUG']
  end

  def debug
    yield if debug?
  end

  def start_worker(command)
    pid = spawn(command, output)
    debug { puts "Started worker #{command} (pid: #{pid})" }
    pid
  end

  def quit_worker(pid)
    Process.kill('QUIT', pid)
    Process.wait(pid)
  rescue Errno::ESRCH
    # it was quit already
  end

end

workers = $stdin.isatty ? ['ruby worker.rb'] : ARGF.readlines.map(&:strip)
protocol = Protocol.server(Redis.new)
worker_suite = WorkerSuite.new(protocol)

protocol.extend(Protocol::Benchmark)

request = proc {
  protocol.push
  protocol.response
}

Benchmark.ips do |x|
  x.config(time: 60, warmup: 5, suite: worker_suite)

  workers.each do |worker|
    x.report(worker, &request)
  end
end
