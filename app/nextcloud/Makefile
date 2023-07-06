.PHONY: sync book init

sync:
	docker-compose exec -u www-data app php occ files:scan --all

book:
	cd ./files/电子书 && tree . > README.md

init:
	sudo chmod 777 nextcloud/data nextcloud/data/urie/files
	docker-compose exec app chown -R www-data:www-data /var/www/html/data
	# ln -s ./nextcloud/data/urie/files ./files
	docker-compose exec -u www-data app php occ app:disable dashboard circles contactsinteraction federatedfilesharing firstrunwizard nextcloud_announcements notifications password_policy recommendations sharebymail support updatenotification survey_client user_status weather_status