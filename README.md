# labbsr0x/docker-dns-bind9

- [labbsr0x/docker-dns-bind9](#labbsr0xdocker-dns-bind9)
- [Introduction](#introduction)
  - [Contributing](#contributing)
  - [Issues](#issues)
- [Getting started](#getting-started)
  - [Installation](#installation)
  - [Quickstart](#quickstart)
  - [Persistence](#persistence)
- [Maintenance](#maintenance)
  - [Upgrading](#upgrading)
  - [Shell Access](#shell-access)
- [Example](#example)
  - [Prerequisites](#prerequisites)
    - [Primary DNS](#primary-dns)
    - [Secondary DNS](#secondary-dns)
    - [Testing new DNS Server](#testing-new-dns-server)
  - [Others](#others)
- [References](#references)

# Introduction

`Dockerfile` to create a [Docker](https://www.docker.com/) container image for [BIND](https://www.isc.org/downloads/bind/) DNS server.

BIND is open source software that implements the Domain Name System (DNS) protocols for the Internet. It is a reference implementation of those protocols, but it is also production-grade software, suitable for use in high-volume and high-reliability applications.

## Contributing

If you find this image useful here's how you can help:

- Send a pull request with your awesome features and bug fixes
- Help users resolve their [issues](../../issues?q=is%3Aopen+is%3Aissue).

## Issues

Before reporting your issue please try updating Docker to the latest version and check if it resolves the issue. Refer to the Docker [installation guide](https://docs.docker.com/installation) for instructions.

SELinux users should try disabling SELinux using the command `setenforce 0` to see if it resolves the issue.

If the above recommendations do not help then [report your issue](../../issues/new) along with the following information:

- Output of the `docker version` and `docker info` commands
- The `docker run` command or `docker-compose.yml` used to start the image. Mask out the sensitive bits.

# Getting started

## Installation

Automated builds of the image are available on [Dockerhub](https://hub.docker.com/r/labbsr0x/dns-bind9) and is the recommended method of installation.

```bash
docker pull labbsr0x/dns-bind9
```

Alternatively you can build the image yourself.

```bash
docker build -t labbsr0x/dns-bind9 github.com/labbsr0x/docker-dns-bind9
```

or 

```bash
make build
```

## Quickstart

Start BIND using:

```bash
docker run --rm --name bind -d --publish 53:53/tcp --publish 53:53/udp --volume ${PWD}/.bind9:/data labbsr0x/dns-bind9
```

or

```bash
make docker-run
```

*Alternatively, you can use the sample [docker-compose.yml](docker-compose.yml) file to start the container using [Docker Compose](https://docs.docker.com/compose/)*

## Persistence

For the BIND to preserve its state across container shutdown and startup you should mount a volume at `/data`.

> *The [Quickstart](#quickstart) command already mounts a volume for persistence.*

```bash
mkdir -p .bind9
```

# Maintenance

## Upgrading

To upgrade to newer releases:

  1. Download the updated Docker image:

  ```bash
  docker pull labbsr0x/dns-bind9
  ```

  2. Stop the currently running image:

  ```bash
  docker stop bind
  ```

  or 

  ```bash
  make docker-stop
  ```

  3. Remove the stopped container

  ```bash
  docker rm -v bind
  ```

  and

  ```bash
  rm -rf .bind9
  ```

  4. Start the updated image

  ```bash
  docker run -name bind -d \
    [OPTIONS] \
    labbsr0x/dns-bind9
  ```

## Shell Access

For debugging and maintenance purposes you may want access the containers shell. If you are using Docker version `1.3.0` or higher you can access a running containers shell by starting `bash` using `docker exec`:

```bash
docker exec -it bind bash
```

# Example 

## Prerequisites
- Two servers that will be our DNS name servers with the following features installed. Referred as **ns1** and **ns2**.
  - docker
  - docker-compose
  - git
- **newdomain.com** domain as an example.
  
|Servers  |Description           |	Example FQDN       | Example IP    |
|:-------:|:---------------------|:--------------------|:-------------:|
|ns1      |Primary DNS server    |ns1.newdomain.com    |10.0.10.1      |
|ns2      |Secondary DNS server  |ns2.newdomain.com    |10.0.10.2      |

### Primary DNS

Clone github project on ns1 server

```bash
git clone https://github.com/labbsr0x/docker-dns-bind9.git
```

Create a directory that will be used as DNS volume

```bash
mkdir /opt/bind9
```

Copy **primary DNS directory** and **docker-compose file**

```bash
cp -r /opt/docker-dns-bind9/example/primary /opt/bind9/.

cp /opt/docker-dns-bind9/docker-compose.yml /opt/bind9/.
```

Set volume path in **docker-compose.yml**

```yml
...
    volumes:
    - /opt/bind9/primary:/data # Change volume path
```

Rename zone file **db.example.com** to name of desired zone.

In this example we will rename **db.example.com** to **db.newdomain.com**

```bash
mv /opt/bind9/primary/bind/etc/db.example.com /opt/bind9/primary/bind/etc/db.novodominio.com
```

In zone file change everywhere that are **example.com** to new zone and setup IP.

In this example we will change **example.com** to **newdomain.com**

```yml
;
; BIND data file for local loopback interface
;
$TTL    604800
@       IN      SOA     newdomain.com. root.newdomain.com. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.newdomain.com.
@       IN      NS      ns2.newdomain.com.
@       IN      A       127.0.0.1
@       IN      AAAA    ::1

ns1             A       10.0.10.1   ; Change to the desired NS1 IP
ns2             A       10.0.10.2   ; Change to the desired NS2 IP
```

Config the new db file and new zone in  **named.conf.default-zones**.

In this example we will change **example.com** to **newdomain.com** and the file path **db.example.com** to **db.newdomain.com** and set Secondary DNS IP in allow-transfer.

```yml
...
zone "newdomain.com" { // Change to desired zone
        type master;
        file "/etc/bind/db.newdomain.com"; // Change to zone file path
        allow-transfer {10.0.10.2; };        // Change to Secondary DNS IP
//      allow-update {
//          key "example.com";
//  };
};
...
```

Start the new DNS with docker-compose.

```bash
docker-compose up -d
```

### Secondary DNS

Clone github project on ns2 server

```bash
git clone https://github.com/labbsr0x/docker-dns-bind9.git
```

Create a directory that will be used as DNS volume

```bash
mkdir /opt/bind9
```

Copy **secondary DNS directory** and **docker-compose file**

```bash
cp -r /opt/docker-dns-bind9/example/secondary /opt/bind9/.

cp /opt/docker-dns-bind9/docker-compose.yml /opt/bind9/.
```

Set volume path in **docker-compose.yml**

```yml
...
    volumes:
    - /opt/bind9/secondary:/data # Change volume path
```

Config the new db file and new zone in  **named.conf.default-zones**.

In this example we will change **example.com** to **newdomain.com** and the file path **db.example.com** to **db.newdomain.com** and set Primary DNS IP in master field.

```yml
...
zone "newdomain.com" { // Change to desired zone
        type slave;
        file "/etc/bind/db.newdomain.com";  // Change to zone file path
        masters {10.0.10.1;};               // Change to Primary DNS IP
};
...
```

Start the secondary DNS with docker-compose.

```bash
docker-compose up -d
```

### Testing new DNS Server

```bash
dig -t ns newdomain.com @localhost +short
```

Result

```bash
ns1.newdomain.com.
ns2.newdomain.com.
```

## Others

`
Example in Portuguese (pt_BR) on fabiotavarespr.dev's blog
`
- [Como configurar um DNS Bind9 com docker](https://fabiotavarespr.dev/posts/configurar-dns-bind9-com-docker/)

# References

References used in these projects

[github.com/sameersbn/docker-bind](https://github.com/sameersbn/docker-bind)

[Deploying a DNS Server using Docker](http://www.damagehead.com/blog/2015/04/28/deploying-a-dns-server-using-docker/)

