#!/bin/bash
set -e

if [ "$1" = 'tdm.sh' ]; then

    USER_ID=${TDM_USER_ID:-1000}
    GROUP_ID=${TDM_GROUP_ID:-1000}

    ###
    # Tomcat user
    ###
    if ! getent group $GROUP_ID &> /dev/null; then
      groupadd -r tomcat -g $GROUP_ID
    fi
    # create user for USER_ID if one doesn't already exist
    if ! getent passwd $USER_ID &> /dev/null; then
      useradd -u $USER_ID -g $GROUP_ID tomcat
    fi
    # alter USER_ID with nologin shell and CATALINA_HOME home directory
    usermod -d "${CATALINA_HOME}" -s /sbin/nologin $(id -u -n $USER_ID)
    groupadd -r tomcat -g ${GROUP_ID} && \
    useradd -u ${USER_ID} -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin \
        -c "Tomcat user" tomcat

    ###
    # Change CATALINA_HOME ownership to tomcat user and tomcat group
    # Restrict permissions on conf
    ###

    chown -R $USER_ID:$GROUP_ID ${TDM_HOME}
    sync
    exec gosu $USER_ID "$@"
fi

exec "$@"
