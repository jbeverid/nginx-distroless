# Build stage
FROM debian:bookworm-slim AS build

ARG NGINX_VERSION=1.27.2
WORKDIR /var/www/nginx-distroless
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install necessary libraries and dependencies to compile nginx
RUN apt-get update && apt-get install -y \
    gcc g++ make unzip \
    libaio-dev libc-dev libxslt1-dev libxml2-dev zlib1g-dev \
    libpcre3-dev libbz2-dev libssl-dev autoconf wget \
    lsb-release apt-transport-https ca-certificates

# Define non-root user environment variables
ENV USER=nonroot
ENV UID=10001

# Create the nonroot user
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

# Download and extract Nginx
RUN wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
    tar xf "nginx-${NGINX_VERSION}.tar.gz"

# Configure and compile Nginx
WORKDIR /var/www/nginx-distroless/nginx-${NGINX_VERSION}
RUN ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/dev/stderr \
    --http-log-path=/dev/stdout \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nonroot \
    --group=nonroot \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_degradation_module \
    --with-pcre \
    --with-pcre-jit \
    --with-cc-opt="-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -fPIC" \
    --with-ld-opt="-Wl,-z,relro -Wl,-z,now -pie" \
    && make -j$(nproc) \
    && make install

# Create necessary directories
RUN mkdir -p /var/cache/nginx/ /var/lib/nginx /etc/nginx/conf.d/ /usr/share/nginx/html

# Final stage
FROM gcr.io/distroless/static:latest
ENV TZ="UTC"

# Copy necessary files from the build stage
COPY --from=build /etc/passwd /etc/group /etc/
COPY --from=build /etc/nginx /etc/nginx
COPY --from=build /usr/sbin/nginx /usr/sbin/
COPY --from=build /var/log /var/log
COPY --from=build /var/cache/nginx /var/cache/nginx
COPY --from=build /var/run /var/run
COPY --from=build /usr/share/nginx /usr/share/nginx

# Copy required libraries
COPY --from=build \
    /lib/*-linux-gnu/libdl.so.2 \
    /lib/*-linux-gnu/libcrypt.so.1 \
    /lib/*-linux-gnu/libpcre.so.3 \
    /lib/*-linux-gnu/libssl.so.3 \
    /usr/lib/*-linux-gnu/libcrypto.so.3 \
    /lib/*-linux-gnu/libz.so.1 \
    /lib/*-linux-gnu/libc.so.6 \
    /lib/*-linux-gnu/libnss_compat.so.2 \
    /lib/*-linux-gnu/libnss_files.so.2 \
    /lib/

# Copy dynamic linker
COPY --from=build /lib/*-linux-gnu/ld-linux*.so.* /lib/
COPY --from=build /lib64/ld-linux-x86-64.so.2 /lib64/

COPY licenses/NGINX_LICENSE /usr/share/licenses/NGINX_LICENSE
COPY configs/nginx.conf /etc/nginx/nginx.conf
COPY configs/default.conf /etc/nginx/conf.d/default.conf
COPY html/index.html /usr/share/nginx/html/index.html
COPY html/50x.html /usr/share/nginx/html/50x.html

# Switch to non-root user
USER nonroot
EXPOSE 8080
STOPSIGNAL SIGTERM
ENTRYPOINT ["nginx", "-g", "daemon off;"]
