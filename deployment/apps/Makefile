up:
	docker compose -v --env-file .env --env-file .env.prod up -d

ps:
	docker compose -v --env-file .env --env-file .env.prod ps

down:
	docker compose -v --env-file .env --env-file .env.prod down

clean:
	docker compose -v --env-file .env --env-file .env.prod down -v

logs:
	docker compose -v --env-file .env --env-file .env.prod logs -f

config:
	docker compose -v --env-file .env --env-file .env.prod config

.PHONY: up ps down clean logs config
