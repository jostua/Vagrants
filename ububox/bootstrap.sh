#!/usr/bin/env bash

HOSTSET ()
{
cat << EOF | sudo tee /etc/hosts
127.0.0.1 localhost
127.0.1.1 $1.vagrants.lan $1

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF
}

BINDSET ()
{
cat << EOF | sudo tee /etc/bind/named.conf.options
options {
        directory "/var/cache/bind";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0s placeholder.

        forwarders {
                8.8.8.8;
                4.4.4.4;
        };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };

};

EOF
cat << EOF | sudo tee /etc/bind/named.conf.local
//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include "/etc/bind/zones.rfc1918";

zone "vagrants.lan" IN {
        type master;
        file "/etc/bind/zones/vagrants.lan.db";
};

zone "0.168.192.in-addr.arpa" {
        type master;
        file "/etc/bind/zones/rev.0.168.192.in-addr.arpa";
};
EOF
}

DNSSET ()
{
cat << EOF | sudo tee /etc/dhcp/dhclient.conf
option rfc3442-classless-static-routes code 121 = array of unsigned integer 8;

send host-name = gethostname();
supersede domain-name "vagrants.lan";
prepend domain-name-servers 127.0.0.1;
request subnet-mask, broadcast-address, time-offset, routers,
        domain-name, domain-name-servers, domain-search, host-name,
        dhcp6.name-servers, dhcp6.domain-search,
        netbios-name-servers, netbios-scope, interface-mtu,
        rfc3442-classless-static-routes, ntp-servers,
        dhcp6.fqdn, dhcp6.sntp-servers;
EOF
}

ZONESET ()
{
cat << EOF | sudo tee /etc/bind/zones/vagrants.lan.db
$ORIGIN .
$TTL 86400      ; 1 day
vagrants.lan. IN SOA ubuntu.vagrants.lan. hostmaster.vagrants.lan. (
    2008080901 ; serial
    8H ; refresh
    4H ; retry
    4W ; expire
    1D ; minimum
)

vagrants.lan. IN NS ubuntu.vagrants.lan.
vagrants.lan. IN MX 10 ubuntu.vagrants.lan.

$ORIGIN vagrants.lan.

localhost    IN A 127.0.0.1

email           IN A 192.168.33.103
ububox          IN A 192.168.33.101
web             IN A 192.168.33.102
EOF
cat << EOF | sudo tee /etc/bind/zones/rev.0.168.192.in-addr.arpa
; IP Address-to-Host DNS Pointers for the 192.168.0 subnet
@ IN SOA ubuntu.vagrants.lan. hostmaster.vagrants.lan. (
    2008080901 ; serial
    8H ; refresh
    4H ; retry
    4W ; expire
    1D ; minimum
)
; define the authoritative name server
           IN NS ububox.vagrants.lan.
; our hosts, in numeric order
101		IN PTR ubuntu.vagrants.lan.
102		IN PTR web.vagrants.lan.
103		IN PTR email.vagrants.lan.
EOF
}

case $1 in
	ububox)
		HOSTSET $1

		#setup DNS and DHCP
		apt-get update
		apt-get -y install bind9
		apt-get -y install isc-dhcp-server

		#set bind9 configuration
		BINDSET
		mkdir /etc/bind/zones
		ZONESET

		#set DNS to self
		DNSSET

		;;
	web)
		HOSTSET $1
		;;
	email)
		HOSTSET $1
		;;
esac