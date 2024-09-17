# Deploying EdgeLake

The following provides direction to deploy EdgeLake using [_makefile_](Makefile) for Docker-based deployment.

* [EdgeLake Source Code](https://github.com/EdgeLake/EdgeLake)

#### Requirements
* _[Docker & Docker Compose](https://docs.docker.com/desktop/install/linux/)_
* _Makefile_

**Direction for Ubuntu**: For Ubuntu we've noticed that version 22.04LTS is much more stable as compared to 24.04LTS. 
```shell
# Add Docker's official GPG key:
sudo apt-get -y update
sudo apt-get install -y ca-certificates curl make git curl 
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin make 

# Grant non-root user permissions to use docker
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker
```

**CentOS**: The directions for CentOS download the package for CentOS9 directly from [Docker Downloads](https://download.docker.com/). 
Users can utilize the same process to install _Docker_ / _Docker Compose_ on any operating system. 

```shell
# Install Dependencies
sudo yum install -y curl wget make git yum-utils device-mapper-persistent-data lvm2

# Manually Download rpm packages 
mkdir $HOME/rpm-pkgs ; cd $HOME/rpm-pkgs
curl https://download.docker.com/linux/centos/9/x86_64/stable/Packages/docker-ce-27.2.1-1.el9.x86_64.rpm -o docker-ce.rpm 
curl https://download.docker.com/linux/centos/9/x86_64/stable/Packages/docker-ce-cli-27.2.1-1.el9.x86_64.rpm -o docker-ce-cli.rpm
curl https://download.docker.com/linux/centos/9/x86_64/stable/Packages/containerd.io-1.7.22-3.1.el9.x86_64.rpm -o containerd.io.rpm

# Install packages
sudo yum -y install ./docker-ce.rpm
sudo yum -y install ./docker-ce-cli.rpm
sudo yum -y install ./containerd.io.rpm

# Enable Docker Service
sudo systemctl start docker
sudo systemctl enable docker

# Grant non-root user permissions to use docker
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker
```

**Suse**: These are the directions to install for Suse Leap Enterprise Server 15.6.  The directions for CentOS download the package for CentOS9 directly from [Docker Downloads](https://download.docker.com/). 
Users can utilize the same process to install _Docker_ / _Docker Compose_ on any operating system. 

```shell
# Install Dependencies
sudo zypper install git-core make

# Run Yast to install docker, docker-compose and dependencies from Software->Software Management
sudo yast

# Enable Docker Service
sudo systemctl start docker
sudo systemctl enable docker

# Grant non-root user permissions to use docker
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker
```

**RHEL**: These are the directions to install for RedHat Enterprise Linux 8.10.  The directions for Redhat download the package for Redhat directly from [Docker Downloads](https://download.docker.com/). 
Users can utilize the same process to install _Docker_ / _Docker Compose_ on any operating system.

```shell
# Install Dependencies
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Run yum to install docker, docker-compose and dependencies 
sudo yum --allowerasing install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install docker compose
sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.4/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Enable Docker Service
sudo systemctl start docker
sudo systemctl enable docker

# Grant non-root user permissions to use docker
USER=`whoami` 
sudo groupadd docker 
sudo usermod -aG docker ${USER} 
newgrp docker
```

**Direction for Debian**: 
```shell
# Add Docker's official GPG key:
sudo apt-get -y update
sudo apt-get install -y ca-certificates curl make git curl 
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin make 

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
 

## Deploy EdgeLake via Command Line 

The following provides an example for deploying EdgeLake via CLI. Users can [specify configurations](docker-makefiles/edgelake_generic.env), 
or run with defaults, in which case, a node with only TCP and REST connectivity will be deployed.

```shell 
docker run -it --network host --name edgelake-generic --rm anylogco/edgelake:latest
```
Note, unless specified the default ports are 32548 (TCP) and 32549 (REST) 
