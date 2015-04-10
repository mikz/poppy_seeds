
URL = 127.0.0.1:8080
ruby:
	$(MAKE) -j2 ruby-worker ruby-server

ruby-worker:
	ruby worker.rb

ruby-server: SERVER = thin
ruby-server:
	rackup --server=$(SERVER) server.rb


nginx-server:
	nginx -p . -c server.conf

benchmark:
	ab -n 5000 http://$(URL)/

test:
	curl -v $(URL)
