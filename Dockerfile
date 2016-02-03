FROM debian:jessie
MAINTAINER SneakyScampi

ENV VERSION 1.5.7
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/local/src/
ADD assets/sha256checksum sha256checksum

RUN apt-get update && apt-get install -y apt-utils && apt-get upgrade -y
RUN apt-get install -y\
	build-essential \
	tar \
	wget \
	sudo \
	libssl-dev \
	libevent-dev \
	libevent-2.0-5 \
	libexpat1-dev \
	dnsutils \
	&& wget http://www.unbound.net/downloads/unbound-${VERSION}.tar.gz -P /usr/local/src/ \
	&& sha256sum -c sha256checksum \
	&& tar -xvf unbound-${VERSION}.tar.gz \
	&& rm unbound-${VERSION}.tar.gz \
	&& cd unbound-${VERSION} \
	&& ./configure --prefix=/usr/local --with-libevent \
	&& make \
	&& make install \
	&& cd ../ \
	#&& rm -R unbound-${VERSION} \
	&& apt-get purge -y \
	build-essential \
	gcc \
	gcc-4.8 \
	cpp \
	cpp-4.8 \
	libssl-dev \
	libevent-dev \
	libexpat1-dev \
	&& apt-get autoremove --purge -y \
	&& apt-get install -y libexpat1 \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

RUN useradd --system unbound
ENV PATH $PATH:/usr/local/lib
RUN ldconfig
COPY assets/unbound.conf /usr/local/etc/unbound/unbound.conf
COPY assets/usr/local/bin /usr/local/bin/
RUN chown -R unbound:unbound /usr/local/etc/unbound/
RUN sudo -u unbound unbound-anchor -a /usr/local/etc/unbound/root.key ; true
RUN sudo -u unbound unbound-control-setup
RUN sudo -u unbound wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /usr/local/etc/unbound/root.hints

ADD start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 53/udp
EXPOSE 53

CMD ["/start.sh"]
