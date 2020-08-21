# The macchina.io Remote Manager Docker Compose Configuration

## About macchina.io Remote Manager

[macchina.io Remote Manager](https://macchina.io) provides secure remote access to connected devices
via HTTP or other TCP-based protocols and applications such as secure shell (SSH) or
Virtual Network Computing (VNC). With macchina.io Remote Manager, any network-connected device
running the Remote Manager Agent software (*WebTunnelAgent*, contained in this SDK)
can be securely accessed remotely over the internet from browsers, mobile apps, desktop,
server or cloud applications.

This even works if the device is behind a NAT router, firewall or proxy server.
The device becomes just another host on the internet, addressable via its own URL and
protected by the Remote Manager server against unauthorized or malicious access.
macchina.io Remote Manager is a great solution for secure remote support and maintenance,
as well as for providing secure remote access to devices for end-users via web or
mobile apps.

Visit [macchina.io](https://macchina.io/remote.html) to learn more and to register for a free account.
Specifically, see the [Getting Started](https://macchina.io/remote_signup.html) page and the
[Frequently Asked Questions](https://macchina.io/remote_faq.html) for
information on how to use the macchina.io Remote Manager device agent.

There is also a [blog post](https://macchina.io/blog/?p=257) showing step-by-step instructions to connect a Raspberry Pi.


## About This Repository

This repository contains a [docker-compose.yml](docker-compose.yml) file (and supporting
files) for setting up all necessary containers for running the macchina.io Remote Manager
server. This includes:

  - the macchina.io Remote Manager Server (also known as *reflector*, from the
    [macchina/reflector](https://hub.docker.com/repository/docker/macchina/reflector)
    repository on [Docker Hub](https://hub.docker.com)
  - a MariaDB server
  - a HAProxy server as frontend to the Remote Manager server, providing
    TLS termination and request throttling


### Prerequisites

To run the macchina.io Remote Manager server, you will need the following:

  - A host system (Linux, macOS, Windows) with Docker and Docker Compose installed.
  - The MySQL or MariaDB client (`mysql`) for setting up the database schema.
  - A wildcard domain with a properly set-up wildcard DNS entry. For example,
    if your Remote Manager instance will use the domain *devices.company.com*,
    you'll need corresponding DNS entries for `*.devices.company.com` and
    `devices.company.com` pointing to the public IP address of your server.
    The included example files use the domain `demo.my-devices.net`.
  - A wildcard certificate (and corresponding private key) for your domain. A wildcard
    certificate for `*.demo.my-devices.net` is included in
    [haproxy/reflector.pem](haproxy/reflector.pem). For HAProxy, private key and
    certificate must be combined in one file in PEM format.
  - A Remote Manager server license file (`reflector.license`) for your domain.
    A sample license file for the domain `demo.my-devices.net` is included
    (limited to 10 connected devices) and can be found in
    [reflector/reflector.license](reflector/reflector.license).

You may also want to have the *macchina.io Remote Manager Set-Up and Administration Guide*
document ready at hand.

Furthermore, you should be familiar with Docker and Docker Compose.

### Setting Up

Setting up the system consists of two steps:

  1. Build the Docker images.
  2. Set up the database schema.

#### Build the Docker Images

Two Docker images need to be built. First, the macchina.io Remote Manager Server
(macchina/reflector) image needs to be extended to include the license file.
The necessary [`Dockerfile`](reflector/Dockerfile) is in the `reflector` directory.

Second, the HAProxy image must be extended with a proper configuration.
The [`Dockerfile`](haproxy/Dockerfile) for that is in the `haproxy` directory.

To build the images, run:

```
$ docker-compose build
```

#### Set Up the Database schema

To set-up the MySQL/MariaDB database schema for the Remote Manager server,
first bring up the stack with Docker Compose:

```
$ docker-compose up
```

Then, in a separate shell, create the database schema.

```
$ mysql -h 127.0.0.1 reflector -u reflector -p <createtables.sql
```

The default password for the `reflector` user is `reflector` (set in the
`docker-compose.yml` file).

After creating the database schema, you can stop the stack by simply
typing `CTRL-C` in the shell running `docker-compose up`.

### Running

To run the macchina.io Remote Manager stack, run:

```
$ docker-compose up -d
```

Use the `-d` argument to run the containers in the background.

The first step after starting the stack is to log-in to the
web user interface and change the default password for the `admin`
account.

