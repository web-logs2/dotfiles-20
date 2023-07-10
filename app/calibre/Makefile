.PHONY: add init

add:
	docker-compose exec calibre calibredb add --library-path=/books -r /books_to_add/

init:
	docker-compose exec calibre calibredb restore_database --really-do-it --with-library /books
	docker-compose exec calibre chmod 755 /books/metadata.db
