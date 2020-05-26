FROM alpine:3.7
RUN apk update && apk upgrade
RUN apk add nginx g++ gcc socat nmap netcat-openbsd perl bash zsh curl wget make perl-dev openssl openssl-dev zlib zlib-dev

RUN curl -L https://cpanmin.us | perl - App::cpanminus
RUN cpanm   Net::SSLeay POE POE::Filter::SSL POE::Wheel::ReadWrite          \
            POE::Filter::Stackable POE::Filter::Reference                   \
            POE::Wheel::SocketFactory POE::Component::Client::Keepalive     \
            POE::Component::Client::SOCKS POE::Component::Client::DNS       \
            POE::Component::Client::HTTP POE::Component::EasyDBI            \
            POE::Wheel::FollowTail

RUN mkdir /build
ADD asset/redir-3.3.tar.xz /build
RUN cd /build/redi* && ./configure && make && make install 

RUN mkdir -p /var/log/nginx /run/nginx/               \
    && rm -Rf /var/log/nginx/*                        \
    && chown nginx:nginx /var/log/nginx /run/nginx/

COPY asset/nginx.conf /etc/nginx/nginx.conf
COPY asset/mime.types /etc/nginx/mime.types
COPY asset/default.conf /etc/nginx/conf.d/default.conf

COPY asset/rc.sh /sbin/rc.sh
RUN chmod +x /sbin/rc.sh
COPY asset/dumb-init_1.2.2_amd64 /bin/dumbinit
RUN chmod +x /bin/dumbinit
COPY asset/attach.pl /sbin/attach.pl
RUN chmod +x /sbin/attach.pl

COPY asset/vhost.template /etc/nginx/conf.d/vhost.template
COPY asset/write_vhosts.pl /sbin/write_vhosts.pl
RUN chmod +x /sbin/write_vhosts.pl

ENTRYPOINT ["/bin/dumbinit","/sbin/rc.sh"]