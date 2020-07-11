# MongoDB Replica Set on Docker

Ready-to-use MongoDB replication set with 3 nodes running on Docker.

It is most useful for testing and development, providing a local cluster that more closely resembles a production environment (e.g. [MongoDB Atlas](https://https://atlas.mongodb.com/)), which enables features not available on a single server instance (e.g. transactions).

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

\* This setup was tested only on Ubuntu 18.04, but should also work on other versions and variants. Usage on Windows or MacOS are not within the scope, so manual adjustments may be required or it may outright not work.

## Usage

### Configuration

Configurations are made using environment variables. They can be set in the host machine environment or using the `.env` file, which will be auto loaded by Docker Compose when present.

#### MongoDB image version

MongoDB image version can be specified using `$MONGODB_IMAGE_VERSION`. Default version is `latest`. See all available versions in [MongoDB Official Docker image](https://hub.docker.com/_/mongo).

#### Volumes

Containers are ephemeral, but you can preserve data even after they are destroyed using Docker volumes, which maps a container folder to a folder in the host machine. The folder location in the host machine can be set with `$DATA_PATH` and has `./.local` as default location.

With this feature you can destroy and recreate the cluster while preserving database data and configuration. If that is not desired, the volume folder should be manually removed after the container is destroyed:

```Shell
$ rm -rf ./.local
```

#### Networking

The cluster will be created within a new Docker network, whose subnet CIDR can be set with `$MONGODB_SUBNET_CIDR`. The default value is `172.33.0.0/16`.

#### MongoDB hosts and IP

MongoDB hosts ports can be set with `$MONGO1_PORT`,  `$MONGO2_PORT` and  `$MONGO3_PORT`. Default values are `27017`, `27018` and `27019`, respectively. Since these ports are exposed to the host machine they cannot be the same and should be available in the host machine.

MongoDB hosts address don't have defaults and are, therefore, required. They can be set with `$MONGO1_HOST`, `$MONGO2_HOST` and `$MONGO3_HOST`.

There are two usage modes for hosts address:

#### Using IP addresses

Using docker host machine IP address on all nodes allows a setup where hostname mapping is not required.

There are several ways to determine the Docker host IP address:

```Shell
# method 1
$ ip addr show docker0 # example output below
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:6d:8f:8a:b9 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:6dff:fe8f:8ab9/64 scope link 
       valid_lft forever preferred_lft forever

# method 2
$ docker network list # example output below  
NETWORK ID          NAME                       DRIVER              SCOPE
efb0ad43a2c6        bridge                     bridge              local
b3efee9eb3d2        host                       host                local
16a2978e41f9        none                       null                local

$ docker network inspect efb0ad43a2c6 -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' # example output below
172.17.0.1

# in this example the target ip is 172.17.0.1
```

Using the default [networking config](#networking) usually results in the ip being `172.33.0.1`.

The obtained IP should be set the same for all three cluster nodes.

The resulting [connection string](#connecting) will use this ip address.

#### Using hostnames

In this method hostnames should be added to `/etc/hosts`.

Since all three nodes ports are exposed to the host, it is enough that all hostnames point to the host loopback address:

```Shell
# /etc/hosts
127.0.0.1 mongo1 mongo2 mongo3
```

In the above example hostnames were set as `mongo1`, `mongo2` and `mongo3` and then added to `/etc/hosts` in the host machine.

The resulting [connection string](#connecting) will use the defined hostnames.

### Starting cluster

```Shell
$ docker-compose up -d
```

### Destroying cluster

```Shell
$ docker-compose down
```

See what happen to existing data in [volumes](#volumes).

### Connecting

```Shell
# connect from within a container
$ docker exec -it mongo1 mongo

# connect from host machine (requires mongo shell)
$ ./utils/mongo # same as below
$ mongo $(./utils/getConnString)

# get connection string to use elsewhere
$ ./utils/getConnString
```
