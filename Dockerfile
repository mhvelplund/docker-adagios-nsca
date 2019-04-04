# Adagios server
FROM pschmitt/adagios
MAINTAINER Mads Hvelplund "mads@swissarmyronin.dk"

# Enable git repository
ENV GIT_REPO true

COPY nsca-2.9.1.tar.gz /download/nsca-2.9.1.tar.gz
COPY etc /etc/nagios
COPY supervisord.conf /etc/supervisord.conf
COPY fixcgicfg.sh /opt/fixcgicfg.sh

RUN rpm --rebuilddb && \
	yum install -y tar automake gcc-c++ syslog libmcrypt-devel.x86_64 && \
	tar -C /download/ -xvzf /download/nsca-2.9.1.tar.gz && \
	cd /download/nsca-2.9.1 && \
	./configure && \
	make all && \
	cp -v "/download/nsca-2.9.1/src/nsca" "/usr/sbin/nsca" && \
	chown -R nagios.nagios /etc/nagios && \
	chmod +x /opt/fixcgicfg.sh && \
	yum remove -y tar automake gcc-c++ && \
	rm -rf /download /var/cache/yum

## Debug
#COPY test.message /test/test.message # DEBUG
#RUN cp -v "/download/nsca-2.9.1/src/send_nsca" "/test/send_nsca" && \
#	cp -v "/download/nsca-2.9.1/sample-config/send_nsca.cfg" "/test/send_nsca.cfg"

WORKDIR /etc/nagios

EXPOSE 80 5667
