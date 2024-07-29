FROM eclipse-temurin:11-jdk

USER root

ENV CATALINA_HOME /usr/local/tomcat
ENV TDM_HOME ${CATALINA_HOME}/content/tdm
ENV HOME $TDM_HOME
ENV PATH $HOME:$PATH

WORKDIR $HOME

RUN apt-get update && \
    apt-get install -y --no-install-recommends  \
        gosu \
        curl \
        && \
    # Cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p $TDM_HOME/logs && \
    curl -SL https://downloads.unidata.ucar.edu/tds/5.5/tdm-5.5.jar -o tdm.jar

COPY tdm.sh $HOME
COPY log4j2.xml $HOME
COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["tdm.sh"]
