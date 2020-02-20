#! make

bibmon.db:
	@echo "Bring in the bibmon database SQLite3 file from ABM"
	cp ~/.config/bibmon/bibmon.db .

shell:
	@echo "A shell on the postgres db service: (pg_dump etc)"
	docker-compose exec db \
		bash

dbshell:
	@echo "Get a db shell on the postgres db service: (issue \dt etc)"
	docker-compose exec db \
		psql -U postgres

migrate: bibmon.db
	@echo "Migrate a sqlite3 db into the postgres db"
	docker-compose run pgloader \
		pgloader /tmp/bibmon.db postgresql://postgres:example@db/

pgdump:
	@echo "Dump the postgres default db to the host"
	docker-compose exec db \
		pg_dump -U postgres > ./bibmon.sql
