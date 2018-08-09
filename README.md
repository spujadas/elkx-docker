# Elasticsearch, Logstash, Kibana, X-Pack (ELKX) Docker image

[![](https://images.microbadger.com/badges/image/sebp/elkx.svg)](https://microbadger.com/images/sebp/elkx "Get your own image badge on microbadger.com")

This Docker image provides a convenient centralised log server and log management web interface, by packaging Elasticsearch, Logstash, and Kibana, collectively known as ELK, and extends this stack with [X-Pack](https://www.elastic.co/products/x-pack), which bundles security, alerting, monitoring, reporting, and graph capabilities.

This image is hosted on Docker Hub at [https://hub.docker.com/r/sebp/elkx/](https://hub.docker.com/r/sebp/elkx/).

The following tags are available:

- `latest`, `632`: ELKX 6.3.2.

- `631`: ELKX 6.3.1.

- `630`: ELKX 6.3.0.

- `624`: ELKX 6.2.4.

- `623`: ELKX 6.2.3.

- `622`: ELKX 6.2.2.

- `621`: ELKX 6.2.1.

- `620`: ELKX 6.2.0.

- `613`: ELKX 6.1.3.

- `612`: ELKX 6.1.2.

- `611`: ELKX 6.1.1.

- `610`: ELKX 6.1.0.

- `601`: ELKX 6.0.1.

- `600`: ELKX 6.0.0.

- `562`: ELKX 5.6.2.

- `561`: ELKX 5.6.1.

- `560`: ELKX 5.6.0.

- `553`: ELKX 5.5.3.

- `552`: ELKX 5.5.2.

- `551`: ELKX 5.5.1.

- `550`: ELKX 5.5.0.

- `543`: ELKX 5.4.3.

- `542`: ELKX 5.4.2.

- `541`: ELKX 5.4.1.

- `540`: ELKX 5.4.0.

- `532`: ELKX 5.3.2.

- `531`: ELKX 5.3.1.

- `530`: ELKX 5.3.0.

- `522`: ELKX 5.2.2.

- `521`: ELKX 5.2.1.

- `520`: ELKX 5.2.0.

- `512`: ELKX 5.1.2.

- `511`: ELKX 5.1.1.

- `502`: ELKX 5.0.2.

## Quickstart using Docker Compose

Create the following docker-compose.yml file.

	elkx:
	  image: sebp/elkx
	  ports:
	    - "5601:5601"
	    - "9200:9200"
	    - "5044:5044"
	  environment:
	    - ELASTIC_BOOTSTRAP_PASSWORD="changeme"

Start a container using docker-compose.

	$ docker-compose up
	Creating elkxdocker_elkx_1
	Attaching to elkxdocker_elkx_1
	elkx_1  | ERROR: Setting [bootstrap.pass] does not exist in the keystore.
	elkx_1  |  * Starting periodic command scheduler cron
	elkx_1  |    ...done.
	elkx_1  |  * Starting Elasticsearch Server
	elkx_1  |    ...done.
	elkx_1  | waiting for Elasticsearch to be up (1/30)
	...

In another shell, open a bash session in the running container (replacing `<name of the running container>` with the right value), and use X-Pack's `setup-passwords` tool (located in `$ES_HOME/bin/x-pack`) to set the passwords for the built-in users.

	$ docker exec -it <name of the running container> bash
	# $ES_HOME/bin/x-pack/setup-passwords interactive
	Initiating the setup of reserved user elastic,kibana,logstash_system passwords.
	You will be prompted to enter passwords as the process progresses.
	Please confirm that you would like to continue [y/N]y


	Enter password for [elastic]: changeme
	Reenter password for [elastic]: changeme
	Enter password for [kibana]: changeme
	Reenter password for [kibana]: changeme
	Enter password for [logstash_system]: changeme
	Reenter password for [logstash_system]: changeme
	Changed password for user [kibana]
	Changed password for user [logstash_system]
	Changed password for user [elastic]

Stop the container, then edit the docker-compose.yml as follows:

	elkx:
	  image: sebp/elkx
	  ports:
	    - "5601:5601"
	    - "9200:9200"
	    - "5044:5044"
	  environment:
	    - ELASTICSEARCH_USER=elastic
	    - ELASTICSEARCH_PASSWORD=changeme
	    - LOGSTASH_USER=elastic
	    - LOGSTASH_PASSWORD=changeme
	    - KIBANA_USER=kibana
	    - KIBANA_PASSWORD=changeme

Then start the container again using docker-compose up.

## Usage notes

This image extends the [sebp/elk](https://hub.docker.com/r/sebp/elk/) image, so unless otherwise noted below the [documentation for the seb/elk image](http://elk-docker.readthedocs.org/) applies.

### Bootstrap mode

This image uses the default configuration of X-Pack, meaning that out of the box, as from version 6, the built-in users (especially the `elastic` superuser, and the basic `kibana` user) no longer have default passwords.

To define passwords (and create additional users as needed), a container first needs to be started in *bootstrap mode* in order to assign a bootstrap password to the `elastic` superuser.

As described in the [official X-Pack documentation](https://www.elastic.co/guide/en/x-pack/6.0/setting-up-authentication.html#bootstrap-elastic-passwords):

> The bootstrap password is a transient password that enables you to run the tools that set all the built-in user passwords.

To set the bootstrap password for `elastic`, start a container with the `ELASTIC_BOOTSTRAP_PASSWORD` environment variable set to the chosen password.

Once the container has started, only Elasticsearch will be running, and the user can use the `elastic` account (with the bootstrap password) to change its own password and assign passwords to the built-in users, for instance:

- by manually `docker exec`-ing into the running container and [using the `setup-passwords` tool](https://www.elastic.co/guide/en/x-pack/6.0/setting-up-authentication.html#set-built-in-user-passwords) located in `$ES_HOME/bin/x-pack`,

- or by manually or programmatically [using the user management REST APIs](https://www.elastic.co/guide/en/elasticsearch/reference/6.0/security-api-users.html).

Once all the passwords have been assigned, stop the container, and start the container in _normal mode_ as described below.

### Running the container in normal mode

In order to start up and run normally, the container needs to have two users that are authorised to connect to Elasticsearch's and Kibana's interfaces (JSON and web, respectively), and their credentials must be set using the following environment variables: `ELASTICSEARCH_USER`, `ELASTICSEARCH_PASSWORD`, `KIBANA_USER`, and `KIBANA_PASSWORD`.

In addition, the default Logstash configuration (in `/etc/logstash/conf.d/30-output.conf`) uses the user defined by the `LOGSTASH_USER` and `LOGSTASH_PASSWORD` environment variables to sends logs to Elasticsearch.

To get an idea of how this works, **in a non-production environment**, first set passwords for the built-in `elastic` and `kibana` users to `changeme` in bootstrap mode as described above, then re-run the container with:

- `ELASTICSEARCH_USER` and `LOGSTASH_USER` both set to `elastic` (i.e. we'll be using the built-in superuser to monitor Elasticsearch and send it logs from Logstash),

- `KIBANA_USER` set to `kibana`,

- `ELASTICSEARCH_PASSWORD`, `LOGSTASH_PASSWORD`, and `KIBANA_PASSWORD` all set to `changeme`.

### Creating a dummy log entry

Building on the previous example, in order to create a dummy log entry in Elasticsearch using the `elastic` superuser account, `docker exec` inside the running container (see the [Creating a dummy log entry section](http://elk-docker.readthedocs.io/#creating-dummy-log-entry) of the ELK Docker image documentation), and use the following command instead of the original one (replace the password with the one you set for the `elastic` user):

	# /opt/logstash/bin/logstash --path.data /tmp/logstash/data \
		-e 'input { stdin { } } output { elasticsearch { hosts => ["localhost"] user => "elastic" password => "changeme" } }'

This entry can then be viewed by logging into Kibana as `elastic`.

### Forwarding logs with Filebeat: example set-up and configuration

To run the [example Filebeat set-up](http://elk-docker.readthedocs.io/#forwarding-logs-filebeat) with ELKX, use the `nginx-filebeat` subdirectory of the [source Git repository on GitHub](https://github.com/spujadas/elkx-docker), and update the credentials to connect to Elasticsearch in `start.sh` before building the image.

### Development mode

The `latest` image includes a development mode, which disables X-Pack security in Elasticsearch and Kibana, thereby eliminating the need to set up user credentials as described above.

To start a container in development mode, set the `DEVELOPMENT_MODE` environment variable to `1`.

### Security considerations

X-Pack allows for a secured set-up of the ELK stack, but by default this image is insecure (no message authentication, no auditing, default certificates).

See the X-Pack documentation on [Getting Started with Security](https://www.elastic.co/guide/en/x-pack/current/security-getting-started.html) for guidance on how to secure ELK with X-Pack.

## About

Written by [Sébastien Pujadas](https://pujadas.net), released under the [Apache 2 license](https://www.apache.org/licenses/LICENSE-2.0).
