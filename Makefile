.PHONY: local-up
local-up:
	docker-compose -f docker-compose.dev.yml up -d

.PHONY: local-web-bash
local-web-bash:
	docker exec -it  weather-app-web-1 bash

.PHONY: local-rebuild
local-rebuild:
	docker-compose -f docker-compose.dev.yml up --build --force-recreate --renew-anon-volumes --no-deps -d

.PHONY: local-setup
local-setup:
	bundle install
	bundle exec rails db:migrate



