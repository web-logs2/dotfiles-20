.PHONY: dump imp adapt

MYSQL_CMD=docker run --rm -it -v ./import:/import --network host mysql bash -c
DATABASES=freshrss nextcloud photoprism
DUMP_PATH=/import/dump.sql

dump:
	$(MYSQL_CMD) 'mysqldump -h127.0.0.1 -uroot -p --databases $(DATABASES) > $(DUMP_PATH);'
	cp import/dump.sql import/$$(date -u +%Y-%m-%dT%H:%M:%S%Z).sql

imp:
	$(MYSQL_CMD) 'mysql -h127.0.0.1 -P3306 -u urie -p < $(DUMP_PATH)'

adapt:
	sed -i 's/utf8mb4_0900_ai_ci/uca1400_as_ci/g' import/dump.sql
	# sed -i 's/CHARSET=utf8mb4/CHARSET=utf8/g' import/dump.sql