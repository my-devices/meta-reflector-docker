# The macchina.io REMOTE Server Docker Compose Configuration

## About macchina.io REMOTE

[macchina.io REMOTE](https://macchina.io/remote) provides secure remote access to connected devices
via HTTP or other TCP-based protocols and applications such as secure shell (SSH) or
Virtual Network Computing (VNC). With macchina.io REMOTE, any network-connected device
running the macchina.io REMOTE Agent software (*WebTunnelAgent*)
can be securely accessed remotely over the internet from browsers, mobile apps, desktop,
server or cloud applications.

This even works if the device is behind a NAT router, firewall or proxy server.
The device becomes just another host on the internet, addressable via its own URL and
protected by the macchina.io REMOTE server against unauthorized or malicious access.
macchina.io REMOTE is a great solution for secure remote support and maintenance,
as well as for providing secure remote access to devices for end-users via web or
mobile apps.

Visit [macchina.io/remote](https://macchina.io/remote) to learn more and to register for a free account.
Specifically, see the [Getting Started](https://macchina.io/remote_signup.html) page and the
[Frequently Asked Questions](https://macchina.io/remote_faq.html) for
information on how to use the macchina.io REMOTE device agent.

There is also a [blog post](https://macchina.io/blog/?p=257) showing step-by-step instructions to connect a Raspberry Pi.


## About This Repository

This repository contains a [docker-compose.yml](docker-compose.yml) file (and supporting
files) for setting up all necessary containers for running the macchina.io REMOTE
server with Docker. This includes:

  - the macchina.io REMOTE Server (also known as *reflector*, from the
    [macchina/reflector](https://hub.docker.com/repository/docker/macchina/reflector)
    repository on [Docker Hub](https://hub.docker.com)
  - a [MariaDB](https://hub.docker.com/_/mariadb) server
  - a [HAProxy](https://hub.docker.com/_/haproxy) server as frontend to the
    macchina.io REMOTE server, providing TLS termination and load balancing
  - a [Redis](https://hub.docker.com/_/redis) server, used for storing
    session information in a setup with multiple reflector instances


### Prerequisites

To run the macchina.io REMOTE server, you will need the following:

  - A host system (Linux, macOS, Windows) with Docker and Docker Compose installed.
  - The MySQL or MariaDB client (`mysql`) for setting up the database schema.
  - A wildcard domain with a properly set-up wildcard DNS entry. For example,
    if your macchina.io REMOTE instance will use the domain `devices.company.com`,
    you'll need corresponding DNS entries for `*.devices.company.com` and
    `devices.company.com` pointing to the public IP address of your server.
    The included example files use the domain `demo.my-devices.net`.
  - A proper wildcard certificate (and corresponding private key) for your domain. A
    wildcard certificate for `*.demo.my-devices.net` is included in
    [haproxy/reflector.pem](haproxy/reflector.pem). For HAProxy, private key and
    certificate must be combined in one file in PEM format. See the [`cert`](cert) directory
    for a [script](cert/gencert.sh) to generate a private key and self-signed certificate.
  - A macchina.io REMOTE server license file (`reflector.license`) for your domain.
    A sample license file for the domain `demo.my-devices.net` is included
    (limited to 10 connected devices) and can be found in
    [reflector/reflector.license](reflector/reflector.license).
    You will need to replace the included license file with one for your own
    domain.

You may also want to have the *macchina.io REMOTE Server Set-Up and Administration Guide*
document ready at hand.

Furthermore, you should already be familiar with [Docker](https://docs.docker.com) and
[Docker Compose](https://docs.docker.com/compose/).


### Setting Up

Setting up the system consists of two steps:

  1. Build the Docker images.
  2. Set up the database schema.

#### Build the Docker Images

Two Docker images need to be built. First, the macchina.io REMOTE Server
(macchina/reflector) image needs to be extended to include the license file
and the custom [reflector.properties](reflector/reflector.properties) configuration
file (with Redis support enabled).
The necessary [`Dockerfile`](reflector/Dockerfile) is in the `reflector` directory.

Second, the HAProxy image must be extended with a proper configuration.
This includes the TLS certificate and private key. Both must be in a single file
named `reflector.pem`.
The [`Dockerfile`](haproxy/Dockerfile) for that is in the `haproxy` directory.

To build the images, run:

```
$ docker-compose build
```

#### Set Up the Database schema

To set-up the MySQL/MariaDB database schema for the macchina.io REMOTE server,
first bring up the stack with Docker Compose:

```
$ docker-compose up
```

Then, in a separate shell, create the database schema.

```
$ mysql -h 127.0.0.1 reflector -u reflector -p <mysql/createtables.sql
```

The default password for the `reflector` MySQL/MariaDB user is `reflector`
(set in the `docker-compose.yml` file). You may want to change it, along
with the root password as well.

After creating the database schema, you can stop the stack by simply
typing `CTRL-C` in the shell running `docker-compose up`.

### Running

To run the macchina.io REMOTE stack, run:

```
$ docker-compose up -d
```

Use the `-d` argument to run the containers in the background.

The first step after starting the stack is to log-in to the
web user interface and change the default password for the `admin`
account.

The DNS entries for `demo.my-devices.net` and `*.demo.my-devices.net`
have been set up to point to `127.0.0.1`. So if you have a browser
running on the same machine your containers are running on, and
you're using the default domain `demo.my-devices.net`, you
can go to https://demo.my-devices.net to sign in to your new
macchina.io REMOTE server.

Note: you will not be able to sign-in if the domain name in the
URL does not match the one the server is configured for.
