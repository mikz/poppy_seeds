URL = http://127.0.0.1:8080/

ruby:
	$(MAKE) -j2 ruby-worker ruby-server

ruby-worker:
	ruby worker.rb -n 3

ruby-server: SERVER = thin
ruby-server:
	rackup --server=$(SERVER) server.rb


nginx-server:
	nginx -p . -c server.conf

benchmark: ab

ab:
	ab -n 5000 $(URL)

vegeta: DURATION = 60s
vegeta:
	 echo "GET $(URL)" | vegeta attack -rate=900 -duration=$(DURATION) | vegeta report

test:
	curl -v $(URL)
