 # Deploying Apps

<!-- use MarkdownTOC package in sublime text to update automatically on save -->
<!-- MarkdownTOC depth=5 autolink=true bracket=round -->

- [Marathon](#marathon)
  - [Application definiations](#application-definiations)
    - [Inward Facing](#inward-facing)
    - [Outward Facing](#outward-facing)
      - [External Service](#external-service)
      - [Frontend Service](#frontend-service)
    - [Using Custom Registry With Credentials](#using-custom-registry-with-credentials)
  - [Deploying](#deploying)
  - [Tips](#tips)
- [Databases](#databases)
  - [DNS](#dns)
  - [Credentials](#credentials)

<!-- /MarkdownTOC -->


## Marathon
To run any services on Marathon, you have to create a JSON configuration file
for your app.


### Application definiations

#### Inward Facing

This is an example config for a backend app:

```json
{
  "id": "backend-birds",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "saulshanabrook/webserver-debug:0.1",
      "network": "BRIDGE",
      "portMappings": [
        {"containerPort": 8080, "protocol": "tcp"}
      ]
    }
  },
  "env": {
    "SERVICE_NAME": "birds",
    "SERVICE_TAGS": "backend,http",
    "TEXT": "birds service",
    "SERVE_PORT": "8080"
  }
}
```

The only special part here are the `SERVE_` environmental variables. They are
[used by registrator](https://github.com/gliderlabs/registrator#how-it-works)
to register the app in consul, so that [consul template](https://github.com/hashicorp/consul-template),
can generate routes for it.

If it has the `SERVICE_TAGS` "backend" and "http" or "wsgi", it knows that it is a backend app.
That means it accible internally on every resource machines (those running the
mesos jobs) at port `8008`. Each backend job is acceible on the subpath equal
to its `SERVICE_NAME`. They are also loadbalanced by NGINX, so two instances
running with the same service name will each got roughly half the internal traffic.

This app would be accesible at `http://<any mesos resource ip>:8008/birds/`.

To test the app, we can get the first mesos resource IP address from terraform
and send a GET request to the `/` path of this app:

```shell
curl http://$(terraform output -state=terraform/terraform.tfstate resource.ip):8008/birds/
```

From any other app, we could access this microservice at `localhost:8008/birds/`.

#### Outward Facing
Outward facing services can be either `uwsgi` or `http`.


##### External Service

Outward facing external services are all on a subdomain of `jangl.com`.

Let's say you have a an app `cats.jangl.com`.

Here our definition might look like this:

```json
{
  "id": "cats.jangl.com",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "saulshanabrook/webserver-debug:0.1",
      "network": "BRIDGE",
      "portMappings": [
        {"containerPort": 8080, "protocol": "tcp"}
      ]
    }
  },
  "env": {
    "SERVICE_NAME": "cats",
    "SERVICE_TAGS": "external,http",
    "TEXT": "cats service",
    "SERVE_PORT": "8080"
  }
}
```

Any service with the `SERVICE_TAGS` env variable set to `external` will be
register as an outward facing service. Now this service will be accessible
on all controller nodes on port 80, when coming from subdomain of `jangl.com` specified
in the `SERVICE_NAME` variable.

To test that functionality, we can get the first controller machine from
terraform and pretend we are hitting that domain:

```shell
curl --resolve cats.jangl.com:80:$(terraform output -state=terraform/terraform.tfstate controller.ip)  http://cats.jangl.com/
```

It will also be accesible on the load balancer, when coming from that domain.
That will load balance it (obviously) accross all controllers.


```shell
curl --resolve cats.jangl..com:80:$(dig +short $(terraform output -state=terraform/terraform.tfstate elb.external.domain) | head -n 1) http://cats.jangl.com/
```

##### Frontend Service

It is also true that some subdomains of jangl.com are for the frontend service.
All subdomains that are not explicitly mapped should be routed to the
service named `jangl-frontend`. This service could look like:

```json
{
  "id": "jangl-frontend",
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "saulshanabrook/webserver-debug:0.1",
      "network": "BRIDGE",
      "portMappings": [
        {"containerPort": 8080, "protocol": "tcp"}
      ]
    }
  },
  "env": {
    "SERVICE_NAME": "jangl-frontend",
    "SERVICE_TAGS": "http",
    "TEXT": "frontend service",
    "SERVE_PORT": "8080"
  }
}
```

This means that any incoming traffic from `*.jangl.com` that isn't hard coded
to point to a specific service will hit this address.

This app is selected only based on it's name. So the `jangl-frontend` name is
special.

So this should hit this service:

```bash
curl http://some-werid-thing.jangl.com/
```

#### Using Custom Registry With Credentials

To use a private image in a custom registry add the domain of the registry before
the app name. For example `docker.jangle.com/saul/my-app:0.0.1`

### Deploying
To deploy and manage our apps we could interact directly with the Marathon API,
but it is a lot more pleasent to use the [`marathonctl`](https://github.com/shoenig/marathonctl).

First we can configure our marathon host so that it won't ask us every time.

```bash
echo marathon.host: http://$(terraform output -state=terraform/terraform.tfstate controller.ip):8080 > marathonctl.properties
```

To create our app, we save our marathon app config into a JSON file and
tell it to create it:

```
marathonctl -c marathonctl.properties app create cats.com.json
```

If we wanna see what workers are running for a certain service:

```
marathonctl -c marathonctl.properties task list cats.com
```


And to destroy an app:

```
marathonctl -c marathonctl.properties app destroy cats.com
```


### Tips

I would always tag all releases and specify that tags in the marathon config.
That way it will force marathon to pull a new image, whenever you change it.

## Databases

### DNS
In order to access the amazon provided databases and caches, you can use
some custom DNS routes set up through route53.

You can look at the default TLD for the internal subnet access in
`./terraform/variables`.

The new domains are in the form `<service type>-<application name>.<TLD>`

For example `postgres-accounts.jangl-new.rpm`.

### Credentials
All PG username and passwords are `rootroot`. Redis has a password of `rootroot`
as well.

For redis, the URL would be `redis-frontend.jangl-new.rpm`
