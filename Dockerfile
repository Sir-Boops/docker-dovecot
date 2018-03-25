FROM alpine:3.7

ENV DOVE_VER="2.3.0.1"

RUN apk add -U --virtual deps curl \
		gcc g++ openssl-dev make && \
	cd ~ && \
	curl --remote-name https://www.dovecot.org/releases/${DOVE_VER%.*.*}/dovecot-$DOVE_VER.tar.gz && \
	tar xf dovecot-$DOVE_VER.tar.gz && cd ~/dovecot-$DOVE_VER && \
	./configure --bindir=/opt/dovecot/bin \
		--sbindir=/opt/dovecot/sbin --sysconfdir=/opt/dovecot/etc && \
	make -j$(nproc) && \
	make install && \
	apk del --purge deps && \
	rm -rf ~/*

CMD /opt/dovecot/sbin/dovecot -F
