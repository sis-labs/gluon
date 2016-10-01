#!/bin/sh

SITE_CONFIG_LUA=scripts/site_config.lua
CHECK_SITE_LIB=scripts/check_site_lib.lua

exec "${STAGING_DIR}/host/bin/lua" -e "site = dofile(os.getenv('GLUONDIR') .. '/${SITE_CONFIG_LUA}'); dofile(os.getenv('GLUONDIR') .. '/${CHECK_SITE_LIB}'); dofile()"
