#!/bin/bash
set -e

if [ "$1" = 'tdm.sh' ]; then

    USER_ID=${TDM_USER_ID:-1000}
    GROUP_ID=${TDM_GROUP_ID:-1000}

    ###
    # Tomcat user
    ###
    groupadd -r tomcat -g ${GROUP_ID} && \
    useradd -u ${USER_ID} -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin \
        -c "Tomcat user" tomcat

    ###
    # Change CATALINA_HOME ownership to tomcat user and tomcat group
    # Restrict permissions on conf
    ###

    chown -R tomcat:tomcat ${TDM_HOME}
    sync
    exec gosu tomcat "$@"
fi

exec "$@"
