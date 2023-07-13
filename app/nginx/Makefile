# SHELL := /bin/bash

.PHONY: reload gen

reload=docker-compose exec nginx nginx -s reload

reload:
	$(reload)

gen:
	env $$(cat .env) go run ./gen/main.go ./gen/gen-server.gtpl conf.d/gen-server.conf
	$(reload)

gzip:
	find ./html/ -type f -size +5k | grep -E "\.(js|css|html|svg|md)$$" | xargs -I {} sh -c 'gzip --best -c "{}" > "{}".gz && echo "{}.gz"'|tee /dev/tty | wc -l | xargs -I {} echo "{} files compressed"

clean:
	fd '[js|css|html|svg|md].gz' ./html|xargs rm