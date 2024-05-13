include make/ocaml/main.mk

DEVENV = \
	RELIC_LINK_DOMAIN=aoe-api.worldsedgelink.com \
	DB_PATH=/tmp/relic-store.db

run: 
	make build
	RELIC_LINK_DOMAIN=aoe-api.worldsedgelink.com \
	DB_PATH=/tmp/relic-store.db \
	./_build/default/bin/main.exe
