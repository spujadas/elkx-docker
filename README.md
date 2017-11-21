# Elasticsearch, Logstash, Kibana, X-Pack (ELKX) Docker image

[![](https://badge.imagelayers.io/sebp/elkx:latest.svg)](https://imagelayers.io/?images=sebp/elkx:latest 'Get your own badge on imagelayers.io')

This Docker image provides a convenient centralised log server and log management web interface, by packaging Elasticsearch, Logstash, and Kibana, collectively known as ELK, and extends this stack with [X-Pack](https://www.elastic.co/products/x-pack), which bundles security, alerting, monitoring, reporting, and graph capabilities.

This image is hosted on Docker Hub at [https://hub.docker.com/r/sebp/elkx/](https://hub.docker.com/r/sebp/elkx/).

The following tags are available:

- `latest`, `600`: ELKX 6.0.0.

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

## Usage notes

This image extends the [sebp/elk](https://hub.docker.com/r/sebp/elk/) image, so unless otherwise noted below the [documentation for the seb/elk image](http://elk-docker.readthedocs.org/) applies.

### Bootstrap mode

This image uses the default configuration of X-Pack, meaning that out of the box, as from version 6, the built-in users (especially the `elastic` superuser, and the basic `kibana` user) no longer have default passwords.

To define passwords (and create additional users as needed), a container first needs to be started in *bootstrap mode* in order to assign a bootstrap password to the `elastic` superuser.

As described in the [official X-Pack documentation](https://www.elastic.co/guide/en/x-pack/6.0/setting-up-authentication.html#bootstrap-elastic-passwords):

> The bootstrap password is a transient password that enables you to run the tools that set all the built-in user passwords.

To set the bootstrap password for `elastic`, start a container with the `ELASTIC_BOOTSTRAP_PASSWORD` environment variable set to the chosen password.

Once the container has started, only Elasticsearch will be running, and the user can use the `elastic` account (with the bootstrap password) to change its own password and assign passwords to the built-in users, for instance:

- by manually `docker exec`-ing into the running container and [using the `setup-passwords` tool](https://www.elastic.co/guide/en/x-pack/6.0/setting-up-authentication.html#set-built-in-user-passwords),

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

### Security considerations

X-Pack allows for a secured set-up of the ELK stack, but by default this image is insecure (no message authentication, no auditing, default certificates).

See the X-Pack documentation on [Getting Started with Security](https://www.elastic.co/guide/en/x-pack/current/security-getting-started.html) for guidance on how to secure ELK with X-Pack.

## About

Written by [Sébastien Pujadas](https://pujadas.net), released under the [Apache 2 license](https://www.apache.org/licenses/LICENSE-2.0).
