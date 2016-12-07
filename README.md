Bluetooth Network Access Point for Raspberry Pi
===============================================

Introduction
------------

Bluetooth allows classical networking (TCP/IP). Although the throughput
is limited, it has a number of advantages, like low power consumption.
One drawback is that it does not work out of the box, it needs some
additional packages and the configuration is not simple.

This project mainly collects and combines files and code-snippets I found
in the internet to provide an easy to install version of a bluetooth
network access point. It is targeted at Raspberry Pis running Raspbian
Jessie, but it should also run on other flavors of Linux, as long as
they provide a Bluez5 stack.


Architecture
------------

Depending on your needs, you can choose to setup the system as a **server**,
a **client** or a **nap** (network access point).

A **server** provides access to the system. This setup is the right choice
if you are running a standalone system and want to query settings or
control it e.g. from a browser. This is an ideal setup to use with
smartphones and tablets (at least under Android), because once paired
the smartphone/tablet will automatically use the bluetooth-connection
for networking.

A **client** needs a second bluetooth-device to establish a connection.
The second device must be a server or a nap. With this setup, you can
provide an internet connection to a Pi (e.g. a Pi-Zero) using a
second pi as a nap.

A **nap** is a special version of the server. It bridges incoming
connections to an existing network interface (typically ethernet) and
allows clients to transparently access the network. Depending on your
network configuration, the nap itself can be invisible for the clients.

All the functionality is wrapped in a Systemd-service named `btnap.service`.
For servers and naps, this service automatically configures a network
bridge. For every incoming connection it creates a new bluetooth-based
network interface `bnepX` and adds it to the bridge. The difference between
the server and the nap is that the latter also adds an existing
network interface to the bridge, so all connected clients will use
that interface for access to the network. Depending on your needs,
you could also configure routing from the bridge-device to an
existing network device, but this setup is not directly supported by
this project.

For clients, the `btnap.service` will just establish a connection
to the provided remote bluetooth device.


Installation
------------

To install, just run the following commands (on Raspbian Jessie-Lite you
have to install git first):

    git clone https://github.com/bablokb/pi-btnap
    sudo pi-btnap/tools/install-btnap  server [ifname] | client

The argument to `install-btnap` selects the role of the system. If you
select the `server` role and provide an interface name, the system
will act as a network-access-point (it adds the interface to the bridge).
You can change the role afterwards by editing `/etc/btnap.conf`
(see the section *Configuration* below).

The scripts installs some additional packages needed by the python-script.
It adds a template configuration file (`/etc/btnap.conf`) and it enables
(but doesn't start) the `btnap.service`. You could edit the install
script before installation and provide your own defaults for a number
of variables, but it is better to change the generated configuration file.

There are some install-time only configuration options (e.g. additional
installation of dnsmasq). Please check the install-script and change
as needed.


Configuration
-------------

All configuration is done in the file `/etc/btnap.conf`:

    MODE="server"             # values: server|client

    # server configuration
    BR_DEV="br0"                # bridge-device
    BR_IP="192.168.20.99/24"    # IP of bridge/network-size
    BR_GW="192.168.20.1"        # GW-IP for bridge
    ADD_IF=""                   # add eth0 to convert the server to a nap

    # client configuration
    REMOTE_DEV=""           # MAC of remote BT nap server

    DEBUG=""                # set to anything to enable debug-messages

If the bridge IP (variable `BR_IP`) is in the range of your home-network,
btnap-clients can access your server even if in nap-mode.

