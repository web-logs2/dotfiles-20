.PHONY: sync book init gen copy

OCC_COMMAND=docker-compose exec -u www-data app php occ

sync:
	$(OCC_COMMAND) files:scan --all

gen:
	docker-compose exec -u www-data app php occ preview:generate-all -vvv

book:
	cd ./files/电子书 && tree . > README.md

init:
	sudo cp ./config.php ./nextcloud/config/
	# sudo chmod 777 nextcloud/data nextcloud/data/urie/files
	# docker-compose exec app chown -R www-data:www-data /var/www/html/data
	# ln -s ./nextcloud/data/urie/files ./files
	$(OCC_COMMAND) app:disable dashboard circles contactsinteraction firstrunwizard nextcloud_announcements notifications password_policy recommendations sharebymail support updatenotification survey_client user_status weather_status
	$(OCC_COMMAND) app:install -- previewgenerator
	# $(OCC_COMMAND) app:install -- imagemagick-common
	docker-compose exec --user root app apk add ffmpeg

temp:
	$(OCC_COMMAND) maintenance:mode --off

copy:
	# sudo cp ./nextcloud/config/config.php .
	sudo cp ./config.php ./nextcloud/config/
	sudo chown "$$(id -u)" ./config.php

token:
	$(OCC_COMMAND) config:app:set serverinfo token --value xx
