# Quick Start

## Requirements
* Make 
* Docker & Docker Compose 

## Port Configurations
| Node Type | TCP | REST | 
| :---: | :---: | :---: | 
| Master | 32048 | 32049 | 
| Operator 1 | 32148 | 32149 | 
| Operator 2 | 32158 | 32159 | 
| Query | 32348 | 32349 | 

## Deployment
**Master**: 
1. In [docker-makefiles/edgelake_master.env](docker-makefiles/edgelake_master.env), update the IP address of the 
LEDGER_CONN to the IP of the machine. 
```shell
# before
LEDGER_CONN=127.0.0.1:32048

# after
LEDGER_CONN=192.168.86.20:32048
``` 

2. Start Master Node 
```shell
make up EDGELAKE_TYPE=master
```

**Operator 1**:
1. In [docker-makefiles/edgelake_operator.env](docker-makefiles/edgelake_operator.env), update the IP address of the 
LEDGER_CONN to the TCP IP:Port for Master node 
```shell
# before
LEDGER_CONN=127.0.0.1:32048

# after
LEDGER_CONN=192.168.86.20:32048
```

You may also update other configurations in the dotenv file, such as: Logical database name and Enable MQTT client, to get random data

2. Start Operator Node 
```shell
make up EDGELAKE_TYPE=operator
```

**Operator 2**:
1. In [docker-makefiles/edgelake_operator2.env](docker-makefiles/edgelake_operator2.env), update the IP address of the 
LEDGER_CONN to the TCP IP:Port for Master node 
```shell
# before
LEDGER_CONN=127.0.0.1:32048

# after
LEDGER_CONN=192.168.86.20:32048
```

You may also update other configurations in the dotenv file, such as: Logical database name and Enable MQTT client, to get random data

2. Start Operator Node 
```shell
make up EDGELAKE_TYPE=operator2
```

**Query**: 
1. In [docker-makefiles/edgelake_query.env](docker-makefiles/edgelake_query.env), update the IP address of the 
LEDGER_CONN to the IP of the machine. 
```shell
# before
LEDGER_CONN=127.0.0.1:32048

# after
LEDGER_CONN=192.168.86.20:32048
``` 

2. Start Query Node 
```shell
make up EDGELAKE_TYPE=master
```


## Insert + Query Data 
* Simple Insert Data of 10 rows into EdgeLake
```shell
#!/bin/bash

# Parameters
CONN="127.0.0.1:32149"            # REST connection (IP:Port)
DBMS="new_company"                # Logical DB name
TABLE="my_table"                  # Table name

# Function to generate 10 JSON rows with timestamp and value
generate_data() {
  for i in {1..10}
  do
    TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    VALUE=$((RANDOM % 100))
    echo "{\"timestamp\":\"$TIMESTAMP\",\"value\":$VALUE}"
    sleep 1
  done
}

# Send each row using curl
generate_data | while read -r row
do
  curl -X PUT "http://${CONN}" \
    -H "type: json" \
    -H "dbms: ${DBMS}" \
    -H "table: ${TABLE}" \
    -H "mode: streaming" \
    -H "Content-Type: text/plain" \
    -H "User-Agent: AnyLog/1.23" \
    --data "$row"

  echo ""  # Just for spacing
done
```

* Query Data 
```shell
CONN="127.0.0.1:32349"            # REST connection (IP:Port) for Query node 
DBMS="new_company"                # Logical DB name
TABLE="my_table"                  # Table name

curl -X GET http://${CONN} \
  -H "sql ${DBMS} format=table SELECT * FROM ${table}" \
  -H "User-Agent: AnyLog/1.23" \
  -H "destination: network"
```


## Support
To find the IP address
```shell
# Mac / Linux
docker-compose $ ifconfig en0
en0: flags=8863<UP,BROADCAST,SMART,RUNNING,SIMPLEX,MULTICAST> mtu 1500
        options=6460<TSO4,TSO6,CHANNEL_IO,PARTIAL_CSUM,ZEROINVERT_CSUM>
        ether f0:18:98:13:19:67
        inet6 fe80::1092:7409:c6ec:3823%en0 prefixlen 64 secured scopeid 0x6 
        inet 192.168.86.20 netmask 0xffffff00 broadcast 192.168.86.255
        nd6 options=201<PERFORMNUD,DAD>
        media: autoselect
        status: active

# Windows
docker-compose $ Get-NetIPConfiguration | Where-Object {$_.InterfaceAlias -eq "Wi-Fi"}
InterfaceAlias       : Wi-Fi
InterfaceIndex       : 12
InterfaceDescription : Intel(R) Dual Band Wireless-AC 8265
NetProfile.Name      : HomeNetwork
IPv4Address          : 192.168.1.101
IPv6Address          : fe80::1c2d:xxxx:xxxx:xxxx%12
IPv4DefaultGateway   : 192.168.1.1
DNSServer            : 8.8.8.8
                       8.8.4.4
```