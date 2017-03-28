# Elasticsearch, Logstash, Kibana, X-Pack (ELKX) Docker image

[![](https://badge.imagelayers.io/sebp/elkx:latest.svg)](https://imagelayers.io/?images=sebp/elkx:latest 'Get your own badge on imagelayers.io')

This Docker image provides a convenient centralised log server and log management web interface, by packaging Elasticsearch, Logstash, and Kibana, collectively known as ELK, and extends this stack with [X-Pack](https://www.elastic.co/products/x-pack), which bundles security, alerting, monitoring, reporting, and graph capabilities.

This image is hosted on Docker Hub at [https://hub.docker.com/r/sebp/elkx/](https://hub.docker.com/r/sebp/elkx/).

The following tags are available:

- `522`, `latest`: ELKX 5.2.2.

- `521`: ELKX 5.2.1.

- `520`: ELKX 5.2.0.

- `512`: ELKX 5.1.2.

- `511`: ELKX 5.1.1.

- `502`: ELKX 5.0.2.

## Usage notes

This image extends the [sebp/elk](https://hub.docker.com/r/sebp/elk/) image, so unless otherwise noted below the [documentation for the seb/elk image](http://elk-docker.readthedocs.org/) applies.

### Changes

This image uses the default configuration of X-Pack, meaning that out of the box, two users are built in:

- `elastic`, a superuser,

- `kibana`, a basic Kibana user.

Their default password is `changeme`.

In order to create a dummy log entry using the `elastic` superuser account, `docker exec` inside the running container (see the [Creating a dummy log entry section](http://elk-docker.readthedocs.io/#creating-dummy-log-entry) of the ELK Docker image documentation), and use the following command instead of the original one:

	# /opt/logstash/bin/logstash -e 'input { stdin { } } output { elasticsearch { hosts => ["localhost"] user => "elastic" password => "changeme" } }'

This entry can then be viewed by logging into Kibana as `elastic` (password: `changeme`).

### Security considerations

X-Pack allows for a secured set-up of the ELK stack, but by default this image is insecure (default passwords, no message authentication, no auditing, default certificates).

See the X-Pack documentation on [Getting Started with Security](https://www.elastic.co/guide/en/x-pack/current/security-getting-started.html) for guidance on how to secure ELK with X-Pack.

### Caveats

In order for the container to display the proper log files for the running Elasticsearch cluster, it retrieves the name of the cluster by querying Elasticsearch at start-up (in the `start.sh` start-up script). With an X-Pack-enabled set-up, this request needs to be authenticated, and uses `elastic` with the default password to do this.

Therefore, if the password is changed, the start-up script will fail. Possible workarounds include :

- Extending the image to dynamically use an environment-variable-provided password.

- Setting the cluster name with the `CLUSTER_NAME` environment variable (see documentation for the sebp/elk image), to avoid querying Elasticsearch at start-up time.

In the same way, the Elasticsearch output Logstash plugin configuration file (`30-output.conf`) contains the hardcoded username and password for `elastic` to send log data to Elasticsearch, and will no longer work if another user/password needs to be used. Similar means as those suggested above can be used.   

## About

Written by [Sébastien Pujadas](https://pujadas.net), released under the [Apache 2 license](https://www.apache.org/licenses/LICENSE-2.0).
