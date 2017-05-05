#!/bin/bash

java -jar -d64 -Xms$TDM_XMS_SIZE -Xmx$TDM_XMX_SIZE  -DbbTdm=1 \
     -Dtds.content.root.path=$TDS_CONTENT_ROOT_PATH $TDM_HOME/tdm.jar \
     -nthreads 1 -cred tdm:$TDM_PW -tds $TDS_HOST
