make-migrations:
	$(MAKE) -C backend make-migrations

migrate:
	$(MAKE) -C backend migrate

db-login:
	$(MAKE) -C backend db-login

run-server:
	$(MAKE) -C backend run-server

run-tests:
	$(MAKE) -C backend run-tests
	$(MAKE) -C frontend run-tests

lint:
	$(MAKE) -C backend lint
	$(MAKE) -C frontend lint

format:
	$(MAKE) -C backend format
	$(MAKE) -C frontend format

pipenv-run:
	$(MAKE) -C backend pipenv-run

shell:
	$(MAKE) -C backend shell
