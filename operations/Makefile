#! make

shell:
	docker-compose exec db \
		bash

dbshell:
	docker-compose exec db \
		psql -U postgres

migrate:
	docker-compose run pgloader \
		pgloader /tmp/bibmon.db postgresql://postgres:example@db/

pgdump:
	docker-compose exec db \
		pg_dump -U postgres > ./bibmon.sql
