FROM openjdk:8

MAINTAINER Unidata Cloud Team

###
# Usual maintenance
###

USER root

RUN apt-get update

RUN apt-get install -y curl

###
# gosu is a non-optimal way to deal with the mismatches between Unix user and
# group IDs inside versus outside the container resulting in permission
# headaches when writing to directory outside the container.
###

# Installation instructions copy/pasted from
# https://github.com/tianon/gosu/blob/master/INSTALL.md
# minus ca-certificates which we are inheriting from parent container and more
# robust key verification.

ENV GOSU_VERSION 1.12

RUN set -eux; \
# save list of currently installed packages for later so we can clean up
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends wget; \
	if ! command -v gpg; then \
		apt-get install -y --no-install-recommends gnupg2 dirmngr; \
	elif gpg --version | grep -q '^gpg (GnuPG) 1\.'; then \
# "This package provides support for HKPS keyservers." (GnuPG 1.x only)
		apt-get install -y --no-install-recommends gnupg-curl; \
	fi; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
        export KEY=B42F6819007F00F88E364FD4036A9C25BF357DD4; \
        for server in $(shuf -e ha.pool.sks-keyservers.net \
                                hkp://p80.pool.sks-keyservers.net:80 \
                                keyserver.ubuntu.com \
                                hkp://keyserver.ubuntu.com:80 \
                                keyserver.pgp.com \
                                pgp.mit.edu) ; do \
            gpg --batch --keyserver "$server" --recv-keys $KEY && break || : ; \
        done; \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
# clean up fetch dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu --version; \
	gosu nobody true

###
# CATALINA_HOME
###

ENV CATALINA_HOME /usr/local/tomcat

ENV TDM_HOME ${CATALINA_HOME}/content/tdm

RUN mkdir -p $TDM_HOME

ENV HOME $TDM_HOME

##
# Set the path
##

ENV PATH $HOME:$PATH

###
# Create content/tdm directory
###

WORKDIR $HOME

ENV TDM_VERSION 4.6.17

###
# Grab the TDM
###

RUN curl -SL \
    https://artifacts.unidata.ucar.edu/repository/unidata-releases/edu/ucar/tdmFat/${TDM_VERSION}/tdmFat-${TDM_VERSION}.jar \
    -o tdm.jar

###
# Copy the TDM executable inside the container
###

COPY tdm.sh $HOME
COPY entrypoint.sh /

###
# Start container
###
ENTRYPOINT ["/entrypoint.sh"]

CMD ["tdm.sh"]
