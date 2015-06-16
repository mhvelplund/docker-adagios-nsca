# Adagios server
FROM pschmitt/adagios
MAINTAINER Mads Hvelplund "mhv@tmnet.dk"
ENV ADAGIOS_PASS admin0936
ENV GIT_REPO true

# Download
RUN yum -y install tar make automake gcc-c++ syslog
COPY nsca-2.9.1.tar.gz /download/nsca-2.9.1.tar.gz
WORKDIR /download
RUN tar xvzf nsca-2.9.1.tar.gz

# Compile
WORKDIR /download/nsca-2.9.1
RUN ./configure
RUN make all
RUN cp -v "/download/nsca-2.9.1/src/nsca" "/usr/sbin/nsca"
WORKDIR /

# Debug
ADD test.message /test/test.message
RUN cp -v "/download/nsca-2.9.1/src/send_nsca" "/test/send_nsca"
RUN cp -v "/download/nsca-2.9.1/sample-config/send_nsca.cfg" "/test/send_nsca.cfg"

# Configure
ADD nsca.cfg /etc/nagios/nsca.cfg
RUN chown nagios.nagios /etc/nagios/nsca.cfg
RUN chmod 664 /etc/nagios/nsca.cfg
ADD check_dummy.cfg /etc/nagios/okconfig/commands/check_dummy.cfg

ADD supervisord.conf /etc/supervisord.conf

#Cleanup
RUN rm -rf download

EXPOSE 80 5667