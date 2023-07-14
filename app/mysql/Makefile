.PHONY: dump imp adapt admin

ifneq (,$(wildcard ./.env))
    include .env
    export
endif

MYSQL_CMD=docker run --rm -i --network host dukewebservices/mysql-cli:1.0 bash -c
DATABASES=freshrss nextcloud photoprism
DUMP_PATH=import/dump.sql

dump:
	$(MYSQL_CMD) 'mysqldump -h127.0.0.1 -uroot -p${DB_PASSWORD} --databases $(DATABASES)' > $(DUMP_PATH)
	cp import/dump.sql import/$$(date -u +%Y-%m-%dT%H:%M:%S%Z).sql

imp:
	$(MYSQL_CMD) 'mysql -h127.0.0.1 -P3306 -p${DB_PASSWORD} -u urie' < $(DUMP_PATH)

admin:
	$(MYSQL_CMD) 'mysql -h127.0.0.1 -P3306 -p${DB_PASSWORD} -u root' < import/admin.sql

adapt:
	sed -i 's/utf8mb4_0900_ai_ci/uca1400_as_ci/g' $(DUMP_PATH)
	# sed -i 's/CHARSET=utf8mb4/CHARSET=utf8/g' $(DUMP_PATH)