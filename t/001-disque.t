use Test::Nginx::Socket::Lua 'no_plan';
use Cwd qw(cwd);


my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/?.lua;;";
};

our $server_pid;

unless ($server_pid = fork) {
	exec("resty disque-server.lua");
}

add_cleanup_handler(sub {
    kill INT => $server_pid;
});

repeat_each(2);
run_tests();

__DATA__

=== TEST 1: request, response
--- http_config eval: $::HttpConfig
--- config
location = /t {
  content_by_lua_block { require('disque').call() }
}
--- request
GET /t
---- response_headers
Status: OK
--- response_body_like chomp
^D\-\w{8}\-.{24}\-\w{4}$
--- error_code: 200

=== TEST 2: queue ack
--- http_config eval: $::HttpConfig
--- config
location = /t {
    content_by_lua_block {
      local disque = require('disque')
      disque.response()
      ngx.say('jobs: ' .. disque.jobs())
    }
}
--- request
GET /t
--- response_body
jobs: 0
--- error_code: 200


=== TEST 3: timeout
--- http_config eval: $::HttpConfig
--- config
location = /t {
    content_by_lua_block {
      local disque = require('disque')
      --disque.connect()
      local job_id = disque.request()

      ngx.say('jobs: ' .. disque.jobs())

      ngx.sleep(5)

      ngx.say('jobs: ' .. disque.jobs())
    }
}
--- timeout: 10
--- request
GET /t
--- response_body
jobs: 1
jobs: 0
--- error_code: 200
