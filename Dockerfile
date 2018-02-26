FROM java:8

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

ENV GOSU_VERSION 1.10

ENV GOSU_URL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64

RUN gpg --keyserver pgp.mit.edu --recv-keys \
	B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& curl -sSL $GOSU_URL -o /bin/gosu \
	&& chmod +x /bin/gosu \
	&& curl -sSL $GOSU_URL.asc -o /tmp/gosu.asc \
	&& gpg --verify /tmp/gosu.asc /bin/gosu \
	&& rm /tmp/gosu.asc

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

ENV TDM_VERSION 5.0.0
ENV TDM_SNAPSHOT_VERSION ${TDM_VERSION}-20170608.124350-197

###
# Grab the TDM
###

RUN curl -SL \
   https://artifacts.unidata.ucar.edu/repository/unidata-snapshots/edu/ucar/tdmFat/${TDM_VERSION}-SNAPSHOT/${TDM_SNAPSHOT_VERSION}.jar \
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
