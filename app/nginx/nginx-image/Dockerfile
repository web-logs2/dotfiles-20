ARG NGINX_VERSION

FROM nginx:${NGINX_VERSION} as build
WORKDIR /usr/src/nginx-${NGINX_VERSION}
RUN export NGINX_ARGS=$(nginx -V 2>&1 | sed -n -e 's/^.*arguments: //p') \
  && apt-get update && \
  apt-get install -y \
  git \
  wget \
  libxml2 \
  libxslt1-dev \
  libpcre3 \
  libpcre3-dev \
  zlib1g \
  zlib1g-dev \
  openssl \
  libssl-dev \
  libtool \
  automake \
  gcc \
  make \
  && rm -rf /var/cache/apt \
  && wget -q "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
  && tar -C /usr/src -xzvf "nginx-${NGINX_VERSION}.tar.gz" \
  && git clone https://github.com/arut/nginx-dav-ext-module.git /srv/nginx-dav-ext-module \
  && bash -c "./configure --add-dynamic-module=/srv/nginx-dav-ext-module ${NGINX_ARGS}" && \
  make modules

FROM nginx:${NGINX_VERSION}
COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build /usr/src/nginx-${NGINX_VERSION}/objs/ngx_http_dav_ext_module.so /usr/lib/nginx/modules/
RUN usermod -u 1000 -o nginx && groupmod -g 1000 -o nginx

