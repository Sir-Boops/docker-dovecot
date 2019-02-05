FROM alpine:3.8

ENV DOVE_VER="2.3.4.1"

RUN addgroup -S dovenull && \
    adduser -S -u 991 -G dovenull dovenull && \
    addgroup -S dovecot && \
    adduser -S -u 992 -G dovecot dovecot && \
    addgroup vmail && \
    adduser -S -u 993 -G vmail vmail

RUN apk add -U --virtual deps curl \
        gcc g++ openssl-dev make && \
    apk add libssl1.0 && \
    cd ~ && \
    curl --remote-name https://www.dovecot.org/releases/$(echo $DOVE_VER | cut -c1-3)/dovecot-$DOVE_VER.tar.gz && \
    tar xf dovecot-$DOVE_VER.tar.gz && \
    cd ~/dovecot-$DOVE_VER && \
    ./configure --bindir=/opt/dovecot/bin \
        --sbindir=/opt/dovecot/sbin --sysconfdir=/opt/dovecot/etc && \
    make -j$(nproc) > /dev/null && \
    make install && \
    apk del --purge deps && \
    rm -rf ~/*

CMD /opt/dovecot/sbin/dovecot -F
