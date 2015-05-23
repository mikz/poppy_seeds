URL = http://127.0.0.1:8080/

ruby:
	$(MAKE) -j2 ruby-worker ruby-server

ruby-worker: N = 3
ruby-worker:
	ruby worker.rb -n $(N)

ruby-server: SERVER = thin
ruby-server:
	rackup --server=$(SERVER) server.rb


nginx-server:
	nginx -p . -c server.conf

benchmark: ab

ab:
	ab -n 5000 $(URL)

vegeta: DURATION = 60s
vegeta: RATE = 900
vegeta:
	 echo "GET $(URL)" | vegeta attack -rate=$(RATE) -duration=$(DURATION) | vegeta report

test:
	curl -v $(URL)
