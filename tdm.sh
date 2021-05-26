#!/bin/bash

java -Dlog4j.configurationFile=file://${TDM_HOME}/log4j2.xml \
     -jar -Xms$TDM_XMS_SIZE -Xmx$TDM_XMX_SIZE  -DbbTdm=1 \
     -Dtds.content.root.path=$TDS_CONTENT_ROOT_PATH $TDM_HOME/tdm.jar \
     -nthreads 1 -cred tdm:$TDM_PW -tds $TDS_HOST
