#!/bin/bash
#
# /usr/local/bin/startx.sh
# Bootstrap mode and additional tests before starting Elasticsearch, Logstash
# and Kibana with X-Pack
#


## development mode (disables X-Pack security)

if [ "$DEVELOPMENT_MODE" == "1" ]; then
    if ! grep -q xpack.security.enabled ${ES_PATH_CONF}/elasticsearch.yml
    then
        echo xpack.security.enabled: false >> ${ES_PATH_CONF}/elasticsearch.yml
        echo xpack.security.enabled: false >> ${KIBANA_HOME}/config/kibana.yml
    fi
    /usr/local/bin/start.sh
    exit 0
fi


## bootstrap mode (if ELASTIC_BOOTSTRAP_PASSWORD is defined)

if [ "$ELASTIC_BOOTSTRAP_PASSWORD" ]; then
  # set Elasticsearch configuration path
  export ES_PATH_CONF=/etc/elasticsearch
  
  # create Elasticsearch keystore if it doesn't exist
  if [ ! -f $ES_PATH_CONF/elasticsearch.keystore ]; then
    ${ES_HOME}/bin/elasticsearch-keystore create
  fi

  # remove bootstrap.password setting
  ${ES_HOME}/bin/elasticsearch-keystore remove bootstrap.password > /dev/null

  # set bootstrap.password
  echo $ELASTIC_BOOTSTRAP_PASSWORD \
    | ${ES_HOME}/bin/elasticsearch-keystore add --stdin bootstrap.password

  # fix permissions
  chown elasticsearch:elasticsearch ${ES_PATH_CONF}/elasticsearch.keystore

  # only start Elasticsearch
  export ELASTICSEARCH_START=1
  export LOGSTASH_START=0
  export KIBANA_START=0

  export ELASTICSEARCH_USER=elastic
  export ELASTICSEARCH_PASSWORD=${ELASTIC_BOOTSTRAP_PASSWORD}
fi


### if Elasticsearch is to be started...

if [ -z "$ELASTICSEARCH_START" ] || [ "$ELASTICSEARCH_START" == "1" ]; then
  # exit if no credentials have been set to monitor it
  if [ -z "$ELASTICSEARCH_USER" ] || [ -z "$ELASTICSEARCH_PASSWORD" ]; then
    echo "You must set the ELASTICSEARCH_USER and ELASTICSEARCH_PASSWORD environment"
    echo "variables (see documentation)."
    exit 1
  fi

  export ELASTICSEARCH_URL=${ES_PROTOCOL:-http}://${ELASTICSEARCH_USER}:${ELASTICSEARCH_PASSWORD}@localhost:9200
fi


### if Logstash is to be started...

if [ -z "$LOGSTASH_START" ] || [ "$LOGSTASH_START" == "1" ]; then
  # export the LOGSTASH_USER and LOGSTASH_PASSWORD env vars to Logstash
  touch /etc/default/logstash
  if grep -Eq "^export LOGSTASH_USER=" /etc/default/logstash; then
    awk -v LINE="export LOGSTASH_USER=${LOGSTASH_USER}" '{ sub(/^export LOGSTASH_USER=.*/, LINE); print; }' \
      /etc/default/logstash > /etc/default/logstash.new \
      && mv /etc/default/logstash.new /etc/default/logstash
  else
    echo export LOGSTASH_USER=${LOGSTASH_USER} >> /etc/default/logstash
  fi
  
  if grep -Eq "^export LOGSTASH_PASSWORD=" /etc/default/logstash; then
    awk -v LINE="export LOGSTASH_PASSWORD=${LOGSTASH_PASSWORD}" '{ sub(/^export LOGSTASH_PASSWORD=.*/, LINE); print; }' \
      /etc/default/logstash > /etc/default/logstash.new \
      && mv /etc/default/logstash.new /etc/default/logstash
  else
    echo export LOGSTASH_PASSWORD=${LOGSTASH_PASSWORD} >> /etc/default/logstash
  fi

  chmod +x /etc/default/logstash
fi


### if Kibana is to be started...

if [ -z "$KIBANA_START" ] || [ "$KIBANA_START" == "1" ]; then

  # if credentials to connect Kibana to Elasticsearch have been defined...
  if [ "$KIBANA_USER" ] && [ "$KIBANA_PASSWORD" ]; then

    # add credentials to kibana.yml
    if grep -Eq ^#?elasticsearch.username: ${KIBANA_HOME}/config/kibana.yml; then
      awk -v LINE="elasticsearch.username: \"${KIBANA_USER}\"" '{ sub(/^#?elasticsearch.username:.*/, LINE); print; }' \
        ${KIBANA_HOME}/config/kibana.yml > ${KIBANA_HOME}/config/kibana.yml.new \
        && mv ${KIBANA_HOME}/config/kibana.yml.new ${KIBANA_HOME}/config/kibana.yml
    else
      echo elasticsearch.username: \"${KIBANA_USER}\" >> ${KIBANA_HOME}/config/kibana.yml
    fi

    if grep -Eq ^#?elasticsearch.password: ${KIBANA_HOME}/config/kibana.yml; then
      awk -v LINE="elasticsearch.password: \"${KIBANA_PASSWORD}\"" '{ sub(/^#?elasticsearch.password:.*/, LINE); print; }' \
        ${KIBANA_HOME}/config/kibana.yml > ${KIBANA_HOME}/config/kibana.yml.new \
        && mv ${KIBANA_HOME}/config/kibana.yml.new ${KIBANA_HOME}/config/kibana.yml
    else
      echo elasticsearch.password: \"${KIBANA_PASSWORD}\" >> ${KIBANA_HOME}/config/kibana.yml
    fi

    chmod +r ${KIBANA_HOME}/config/kibana.yml

    export KIBANA_URL=http://${KIBANA_USER}:${KIBANA_PASSWORD}@localhost:5601

  fi 
fi


### run start-up script

/usr/local/bin/start.sh
