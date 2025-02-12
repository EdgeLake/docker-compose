# Deploying EdgeLake

The following provides direction to deploy EdgeLake using [_makefile_](Makefile) for Docker-based deployment.

* [EdgeLake Source Code](https://github.com/EdgeLake/EdgeLake)

**Requirements**
* _Docker_
* _docker-compose_
* _Makefile_
```shell
sudo snap install docker
sudo apt-get -y install docker-compose 
sudo apt-get -y install make
 
# Grant non-root user permissions to use docker
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker
```

## Prepare Machine
Clone _docker-compose_ from EdgeLake repository
```shell
git clone https://github.com/EdgeLake/docker-compose
cd docker-compose
```

## Deploy EdgeLake via Docker 
1. Edit LEDGER_CONN in query and operator using IP address of master node
2. Update `.env` configurations for the node(s) being deployed 
   * [docker_makefile/edgelake_master.env](docker_makefile/edgelake_master.env)
   * [docker_makefile/edgelake_operator.env](docker_makefile/edgelake_operator.env)
   * [docker_makefile/edgelake_qauery.env](docker_makefile/edgelake_query.env)

```dotenv
#--- General ---
# Information regarding which AnyLog node configurations to enable. By default, even if everything is disabled, AnyLog starts TCP and REST connection protocols
NODE_TYPE=master
# Name of the AnyLog instance
NODE_NAME=anylog-master
# Owner of the AnyLog instance
COMPANY_NAME=New Company

#--- Networking ---
# Port address used by AnyLog's TCP protocol to communicate with other nodes in the network
ANYLOG_SERVER_PORT=32048
# Port address used by AnyLog's REST protocol
ANYLOG_REST_PORT=32049
# A bool value that determines if to bind to a specific IP and Port (a false value binds to all IPs)
TCP_BIND=false
# A bool value that determines if to bind to a specific IP and Port (a false value binds to all IPs)
REST_BIND=false

#--- Blockchain ---
# TCP connection information for Master Node
LEDGER_CONN=127.0.0.1:32048

#--- Advanced Settings ---
# Whether to automatically run a local (or personalized) script at the end of the process
DEPLOY_LOCAL_SCRIPT=false
```

3. Start Node using _makefile_
```shell
make up EDGELAKE_TYPE=[NODE_TYPE]
```

## Advanced configurations
Provides a subset of the configurations required to deploy a node. A full list of the configurations can be found in
AnyLog's [Docker Compose repository](https://github.com/AnyLog-co/docker-compose/tree/main/docker-makefile). 

Configurations include: 
* Blockchain sync time
* manually set geolocation 
* threading and pool sizes


### Overlay Network 
One of the things we offer a fully integrated connection to <a href="https://nebula.defined.net/docs" target="_blank">Nebula Overlay Network</a>.

* [Nebula - In General](https://github.com/AnyLog-co/documentation/blob/master/deployments/Networking%20%26%20Security/nebula.md)
* [Preparing for Nebula](https://github.com/AnyLog-co/documentation/blob/master/deployments/Networking%20%26%20Security/nebula_through_anylog.md)
* [Configuring Overlay Network](https://github.com/AnyLog-co/documentation/blob/master/deployments/Networking%20%26%20Security/Configuring%20Overlay%20with%20AnyLog.md)

To deploy, update configurations with the following params
```dotenv
# Overlay IP address - if set, will replace local IP address when connecting to network
OVERLAY_IP=""

# whether to enable Lighthouse
ENABLE_NEBULA=false
# create new nebula keys
NEBULA_NEW_KEYS=false
# whether node is type lighthouse
IS_LIGHTHOUSE=false
# Nebula CIDR IP address for itself - the IP component should be the same as the OVERLAY_IP (ex. 10.10.1.15/24)
CIDR_OVERLAY_ADDRESS=10.10.1.1/24
# Nebula IP address for Lighthouse node (ex. 10.10.1.15)
LIGHTHOUSE_IP=10.10.1.1
# External physical IP of the node associated with Nebula lighthouse
LIGHTHOUSE_NODE_IP=172.232.250.209
```

### Makefile Commands for Docker
* help
```shell
Usage: make [target] EDGELAKE_TYPE=[anylog-type]
Targets:
  build       Pull the docker image
  up          Start the containers
  attach      Attach to EdgeLake instance
  exec        Attach to shell interface for container
  down        Stop and remove the containers
  logs        View logs of the containers
  clean       Clean up volumes and network
  help        Show this help message
         supported EdgeLake types: master, operator and query
Sample calls: make up EDGELAKE_TYPE=master | make attach EDGELAKE_TYPE=master | make clean EDGELAKE_TYPE=master
```

* Bring up a _query_ node
```shell
make up EDGELAKE_TYPE=query
```

* Attach to _query_ node
```shell
# to detach: ctrl-d
make attach EDGELAKE_TYPE=query  
```

* Bring down _query_ node
```shell
make down EDGELAKE_TYPE=query
```
If a _node-type_ is not set, then a generic node would automatically be used

## Makefile Commands 
* `build` - pull docker image 
* `up` - Using _docker-compose_, start a container of AnyLog based on node type
* `attach` - Attach to an AnyLog docker container based on node type
* `exec` - Attach to the shell interface of an AnyLog docker container, based on the node type 
* `log` - check docker container logs based on container type
* `down` - Stop container based on node type 
* `clean` - remove everything associated with container (including volume and image) based on node type
 


