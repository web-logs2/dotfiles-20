# SHELL := /bin/bash

.PHONY: reload gen

reload=docker-compose exec nginx nginx -s reload

reload:
	$(reload)

gen:
	env $$(cat .env) go run ./gen/main.go ./gen/gen-server.gtpl conf.d/gen-server.conf
	$(reload)