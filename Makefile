install:
	npm install

build:
	docker build -t jbgutierrez/node-resizer-server .

run:
	coffee cluster.coffee

run-container:
	docker run -p 49160:8080 -d -name node-resizer-server jbgutierrez/node-resizer-server

stop-container:
	docker kill node-resizer-server

test:
	curl localhost

clean:
	rm -rf node_modules

.PHONY: install build run test clean
