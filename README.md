# NGINX - Distroless

![Version](https://img.shields.io/github/v/release/jbeverid/nginx-distroless)
![Docker Pulls](https://img.shields.io/docker/pulls/jbeveridge/nginx-distroless)
![Docker Image Size](https://img.shields.io/docker/image-size/jbeveridge/nginx-distroless/latest)

This repository contains a Dockerfile that builds a lightweight distroless NGINX 1.27.2 image from source, based on the article [Smallest Distroless NGINX Container](https://medium.com/@rockmetoo/smallest-distroless-nginx-container-alpine-c08c3a9cac93). The NGINX build is customized with various modules and optimizations for security and performance.

## Table of Contents

- [Why Distroless](#why-distroless)
- [Features](#features)
- [Building the Docker Image](#building-the-docker-image)
- [Exposed Port](#exposed-port)
- [Base Image](#base-image)
- [Usage as a Base Image](#usage-as-a-base-image)
- [Production Ready with Minimal Attack Vectors](#production-ready-with-minimal-attack-vectors)
- [Licenses](#licenses)

## Why Distroless

This Docker image was created with several goals in mind:

1. **Lightweight and Efficient**: By building NGINX from source and using a distroless base image, this project results in a smaller and more efficient Docker image. This reduces both storage and memory consumption, making it ideal for production environments where resource efficiency is critical.

2. **Security-Focused**: The use of a distroless base image (`gcr.io/distroless/static`) eliminates unnecessary components such as shells, package managers, and utilities that are often found in traditional base images. This significantly reduces the attack surface, improving the security posture of the container.

3. **Customizable NGINX Build**: This image allows users to have complete control over the NGINX build, including selecting only the modules needed for their specific application. This results in a leaner server without the bloat of unnecessary modules, while still maintaining important features like SSL, HTTP/2, and advanced logging.

4. **Production-Ready**: With NGINX being a widely-used, high-performance web server, this image is tailored for production use. It provides the necessary performance optimizations and security features while allowing users to configure it for their specific needs.

5. **Easily Extensible**: This image is designed to be used as a base for other applications, where users can add their own configuration (`nginx.conf`), static files, or custom application logic on top of an already optimized NGINX instance.

6. **Minimal Attack Vectors**: By stripping out unnecessary tools and utilities, this image minimizes the potential for vulnerabilities, making it a safer choice for running web servers in cloud-native or containerized environments.

7. **Compliance and Auditability**: This image is ideal for environments that require strict security compliance and auditability, as it reduces the components to the bare minimum needed for running NGINX, helping teams meet security standards more easily.

This project is meant to provide a highly efficient, secure, and customizable foundation for anyone looking to deploy NGINX in a containerized environment with confidence in its production-readiness.

## Features

The NGINX build includes the following features based on the `./configure` command used during the build process:

- **Installation Paths**:
    - Prefix: `/etc/nginx`
    - NGINX binary: `/usr/sbin/nginx`
    - Configuration file: `/etc/nginx/nginx.conf`
    - Error log: `/dev/stderr`
    - Access log: `/dev/stdout`
    - PID file: `/var/run/nginx.pid`
    - Lock file: `/var/run/nginx.lock`

- **Temporary File Paths**:
    - Client body temp path: `/var/cache/nginx/client_temp`
    - Proxy temp path: `/var/cache/nginx/proxy_temp`
    - FastCGI temp path: `/var/cache/nginx/fastcgi_temp`
    - uWSGI temp path: `/var/cache/nginx/uwsgi_temp`
    - SCGI temp path: `/var/cache/nginx/scgi_temp`

- **Security and Performance Flags**:
    - Compiler options: `-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC`
    - Linker options: `-Wl,-z,relro -Wl,-z,now -pie`
    - Built to run under user `nonroot` and group `nonroot`

- **Included Modules**:
    - Compatibility (`--with-compat`)
    - File AIO support (`--with-file-aio`)
    - Threads support (`--with-threads`)
    - HTTP Addition module (`--with-http_addition_module`)
    - HTTP Authentication Request module (`--with-http_auth_request_module`)
    - HTTP WebDAV support (`--with-http_dav_module`)
    - HTTP FLV streaming support (`--with-http_flv_module`)
    - HTTP Gzip module (`--with-http_gunzip_module`)
    - HTTP Gzip Static module (`--with-http_gzip_static_module`)
    - HTTP MP4 streaming module (`--with-http_mp4_module`)
    - HTTP Random Index module (`--with-http_random_index_module`)
    - HTTP Real IP module (`--with-http_realip_module`)
    - HTTP Secure Link module (`--with-http_secure_link_module`)
    - HTTP Slice module (`--with-http_slice_module`)
    - HTTP Stub Status module (`--with-http_stub_status_module`)
    - HTTP Substitution module (`--with-http_sub_module`)
    - HTTP/2 support (`--with-http_v2_module`)
    - HTTP Degradation module (`--with-http_degradation_module`)
    - PCRE support for regular expressions (`--with-pcre`)
    - JIT compilation support for PCRE (`--with-pcre-jit`)
    - SSL/TLS support (`--with-http_ssl_module`)

## Building the Docker Image

To build the Docker image, run the following command in the project directory:

```bash
docker build --platform="linux/amd64" -t nginx-distroless .
```

## Exposed Port

By default, this image exposes port `8080` for the NGINX server.

## Base Image

This NGINX build is copied over to a distroless image based on `gcr.io/distroless/static`, ensuring a minimal and secure runtime environment. The distroless base image does not include a package manager or shell, reducing the potential attack surface.

## Usage as a Base Image

To use this distroless NGINX image as a base for your own Docker projects, you can reference the image hosted on DockerHub under the tag `jbeverid/nginx-distroless`.

Here is an example `Dockerfile`:

```Dockerfile
FROM jbeveridge/nginx-distroless:latest

# Copy your own NGINX configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Copy your application files
COPY ./your-app/ /usr/share/nginx/html/
```

## Production Ready with Minimal Attack Vectors

This image is built with security and performance in mind, including essential NGINX modules and utilizing a distroless base image to minimize the attack surface. However, please note the following:

- **Disclaimer**: While this image minimizes potential attack vectors, it is provided "as-is" without warranty, and the author assumes no liability for any issues that may arise. Use at your own risk.

- **Custom Configuration**: You will likely need to provide your own `nginx.conf` for your specific use case. Be sure to review and configure NGINX securely for your environment.

- **Security Scanning**: It is recommended to run security scans on the final image, especially if additional dependencies or configurations are added.

## Licenses

This project includes NGINX, which is licensed under the 2-clause BSD-like license. You can find the full text of the NGINX license [here](licenses/NGINX_LICENSE).


