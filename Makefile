WEB_CONTAINER=gta-web
BEHAT_FLAGS=--stop-on-failure
PHPUNIT_FLAGS=--stop-on-failure

help:
	@printf "💾  \e[1;1mGTA API development environment\e[0m\n"
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

docker-build:       ## Build Docker environment
	@./scripts/docker-build.sh

docker-reset:       ## Kill all containers
	@./scripts/docker-reset.sh

bash:               ## Run /bin/bash
	docker exec -it ${WEB_CONTAINER} /bin/bash
