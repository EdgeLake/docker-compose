# Makefile

EDGELAKE_TYPE := generic
ifneq ($(filter check,$(MAKECMDGOALS)), )
        EDGELAKE_TYPE = $(EDGLAKE_TYPE)
else
        EDGELAKE_TYPE := generic
endif

export TAG := latest
ifeq ($(shell uname -m), aarch64)
	export TAG := latest-arm64
endif

DOCKER_COMPOSE=$(shell command -v docker-compose 2>/dev/null || echo "docker compose")

all: help
dry:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
build:
	docker pull anylogco/edgelake:latest
up:
	@echo "Deploy AnyLog with config file: anylog_$(EDGELAKE_TYPE).env"
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
	@echo ${DOCKER_COMPOSE} -f docker-makefiles/docker-compose.yaml up -d
	@${DOCKER_COMPOSE} -f docker-makefiles/docker-compose.yaml up -d
	@rm -rf docker-makefiles/docker-compose.yaml
down:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
	@${DOCKER_COMPOSE} -f docker-makefiles/docker-compose.yaml down
	@rm -rf docker-makefiles/docker-compose.yaml
clean-volume:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
	@${DOCKER_COMPOSE} -f docker-makefiles/docker-compose.yaml down -v
clean:
	EDGELAKE_TYPE=$(EDGELAKE_TYPE) envsubst < docker-makefiles/docker-compose-template.yaml > docker-makefiles/docker-compose.yaml
	@${DOCKER_COMPOSE} -f docker-makefiles/docker-compose.yaml down -v --rmi all
	@rm -rf docker-makefiles/docker-compose.yaml
attach:
	docker attach --detach-keys=ctrl-d edgelake-$(EDGELAKE_TYPE)
test-conn:
	@echo "REST Connection Info for testing (Example: 127.0.0.1:32149):"
	@read CONN; \
	echo $$CONN > conn.tmp
test-node: test-conn
	@CONN=$$(cat conn.tmp); \
	echo "Node State against $$CONN"; \
	curl -X GET http://$$CONN -H "command: get status"    -H "User-Agent: AnyLog/1.23" -w "\n"; \
	curl -X GET http://$$CONN -H "command: test node"     -H "User-Agent: AnyLog/1.23" -w "\n"; \
	curl -X GET http://$$CONN -H "command: get processes" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	rm -rf conn.tmp
test-network: test-conn
	@CONN=$$(cat conn.tmp); \
	echo "Test Network Against: $$CONN"; \
	curl -X GET http://$$CONN -H "command: test network" -H "User-Agent: AnyLog/1.23" -w "\n"; \
	rm -rf conn.tmp
exec:
	docker exec -it edgelake-$(EDGELAKE_TYPE) bash
logs:
	docker logs edgelake-$(EDGELAKE_TYPE)
help:
	@echo "Usage: make [target] [edgelake-type]"
	@echo "Targets:"
	@echo "  build       Pull the docker image"
	@echo "  up          Start the containers"
	@echo "  attach      Attach to EdgeLake instance"
	@echo "  test		 Using cURL validate node is running"
	@echo "  exec        Attach to shell interface for container"
	@echo "  down        Stop and remove the containers"
	@echo "  logs        View logs of the containers"
	@echo "  clean       Clean up volumes and network"
	@echo "  help        Show this help message"
	@echo "  supported EdgeLake types: generic, master, operator, and query"
	@echo "Sample calls: make up master | make attach master | make clean master"
