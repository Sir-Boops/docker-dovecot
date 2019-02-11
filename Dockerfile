FROM alpine:3.8

# Set versions
ENV DOVE_VER="2.3.4.1"
ENV SIEV_VER="0.5.4"

# Create Groups
RUN addgroup -S dovenull && \
    adduser -S -u 991 -G dovenull dovenull && \
    addgroup -S dovecot && \
    adduser -S -u 992 -G dovecot dovecot && \
    addgroup vmail && \
    adduser -S -u 993 -G vmail vmail

# Build and install dovecot
RUN apk add -U --virtual deps curl \
        gcc g++ openssl-dev make && \
    apk add libssl1.0 && \
    cd ~ && \
    curl --remote-name https://www.dovecot.org/releases/$(echo $DOVE_VER | cut -c1-3)/dovecot-$DOVE_VER.tar.gz && \
	curl --remote-name https://pigeonhole.dovecot.org/releases/$(echo $DOVE_VER | cut -c1-3)/dovecot-$(echo $DOVE_VER | cut -c1-3)-pigeonhole-${SIEV_VER}.tar.gz && \
    tar xf dovecot-$DOVE_VER.tar.gz && \
	tar xf dovecot-$(echo $DOVE_VER | cut -c1-3)-pigeonhole-${SIEV_VER}.tar.gz && \
    cd ~/dovecot-$DOVE_VER && \
    ./configure --bindir=/opt/dovecot/bin \
        --sbindir=/opt/dovecot/sbin --sysconfdir=/opt/dovecot/etc && \
    make -j$(nproc) > /dev/null && \
    make install

# Add dovecot to system path
ENV PATH=${PATH}:/opt/dovecot/sbin:/opt/dovecot/bin

# Build ans install Pigeonhole
RUN cd ~ && \
	cd dovecot-$(echo $DOVE_VER | cut -c1-3)-pigeonhole-${SIEV_VER} && \
	./configure --prefix=/opt/pigeonhole --with-dovecot=/root/dovecot-${DOVE_VER} && \
	make -j$(nproc) > /dev/null && \
	make install && \
	rm -rf ~/* && \
	apk del --purge deps

# Add Pigeonhole to PATH
ENV PATH=${PATH}:/opt/pigeonhole/bin

# Run dovecot
CMD dovecot -F
