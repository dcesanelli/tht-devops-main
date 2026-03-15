THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
COMPOSE_DIR      := $(dir $(realpath $(THIS_MAKEFILE)))

.PHONY: compose-all compose-build compose-stop compose-start 

compose-all: compose-stop compose-build compose-start 

compose-stop:
	@cd $(COMPOSE_DIR) && docker compose down 

compose-start:
	@cd $(COMPOSE_DIR) && docker compose up -d 

compose-build:
	@cd $(COMPOSE_DIR) && docker compose build --no-cache
