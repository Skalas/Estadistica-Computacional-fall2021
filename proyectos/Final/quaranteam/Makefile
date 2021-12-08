terminal:
	sudo docker-compose exec api sh

build:
	sudo docker-compose build

up:
	sudo docker-compose up

down:
	sudo docker-compose down

migrate:
	docker-compose exec api flask db init
	docker-compose exec api flask db migrate
	docker-compose exec api flask db upgrade
