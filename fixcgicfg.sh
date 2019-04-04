#!/bin/bash -e
sed -e "s/nagiosadmin/${ADAGIOS_USER:-nagiosadmin}/" /etc/nagios/cgi.cfg > /tmp.cfg
mv -f /tmp.cfg /etc/nagios/cgi.cfg
