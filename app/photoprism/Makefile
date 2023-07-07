.PHONY: all index

COMMAND=docker-compose exec photoprism photoprism

all:
	$(COMMAND) show config

index:
	$(COMMAND) index -f