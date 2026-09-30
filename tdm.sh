#!/bin/bash
set -euo pipefail

: "${TDM_PW:?TDM_PW must be set}"
: "${TDS_HOST:?TDS_HOST must be set}"
: "${TDS_CONTENT_ROOT_PATH:?TDS_CONTENT_ROOT_PATH must be set}"
: "${TDM_XMS_SIZE:?TDM_XMS_SIZE must be set}"
: "${TDM_XMX_SIZE:?TDM_XMX_SIZE must be set}"

exec java "-Dlog4j.configurationFile=file://${TDM_HOME}/log4j2.xml" \
     "-Xms${TDM_XMS_SIZE}" "-Xmx${TDM_XMX_SIZE}" -DbbTdm=1 \
     "-Djava.util.prefs.userRoot=${TDM_HOME}/.java" \
     "-Dtds.content.root.path=${TDS_CONTENT_ROOT_PATH}" \
     -jar "${TDM_HOME}/tdm.jar" \
     -nthreads 1 -cred "tdm:${TDM_PW}" -tds "${TDS_HOST}"
