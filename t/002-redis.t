use Test::Nginx::Socket::Lua 'no_plan';
use Cwd qw(cwd);


my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/?.lua;;";
};

our $server_pid;

unless ($server_pid = fork) {
	exec("resty redis-server.lua");
}

add_cleanup_handler(sub {
    kill INT => $server_pid;
});

repeat_each(100);
run_tests();

__DATA__

=== TEST 1: hello, world
This is just a simple demonstration of the
echo directive provided by ngx_http_echo_module.
--- http_config eval: $::HttpConfig
--- config
location = /t {
    content_by_lua_block { require('redis').call() }
}
--- request
GET /t
--- response_headers
Status: OK
--- response_body_like chomp
^[A-Z0-9]{8}-\w{4}\-\w{4}-\w{4}-\w{12}$
--- error_code: 200
