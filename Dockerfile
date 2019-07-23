FROM alpine:3.10

# Set versions
ENV DOVE_VER="2.3.7.1"
ENV SEIVE_VER="0.5.7.1"

# Create Groups
RUN addgroup -S dovenull && \
	adduser -S -u 991 -G dovenull dovenull && \
	addgroup -S dovecot && \
	adduser -S -u 992 -G dovecot dovecot && \
	addgroup vmail && \
	adduser -S -u 993 -G vmail vmail

# Build and install dovecot
RUN apk add -U --virtual deps build-base \
		openssl-dev && \
	apk add openssl && \
	cd ~ && \
	wget https://dovecot.org/releases/$(echo $DOVE_VER | cut -c1-3)/dovecot-$DOVE_VER.tar.gz && \
	wget https://pigeonhole.dovecot.org/releases/$(echo $DOVE_VER | cut -c1-3)/dovecot-$(echo $DOVE_VER | cut -c1-3)-pigeonhole-${SEIVE_VER}.tar.gz && \
	tar xf dovecot-$DOVE_VER.tar.gz && \
	tar xf dovecot-$(echo $DOVE_VER | cut -c1-3)-pigeonhole-${SEIVE_VER}.tar.gz && \
	cd ~/dovecot-$DOVE_VER && \
	./configure --bindir=/opt/dovecot/bin \
		--sbindir=/opt/dovecot/sbin --sysconfdir=/opt/dovecot/etc && \
	make -j$(nproc) && \
	make install && \
	cd ~/dovecot-$(echo $DOVE_VER | cut -c1-3)-pigeonhole-${SEIVE_VER} && \
	./configure --with-dovecot=/usr/local/lib/dovecot && \
	make -j$(nproc) && \
	make install && \
	rm -rf ~/* && \
	apk del --purge deps

# Add dovecot to system path
ENV PATH=${PATH}:/opt/dovecot/sbin:/opt/dovecot/bin

# Run dovecot
CMD dovecot -F
