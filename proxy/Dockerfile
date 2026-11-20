FROM nginx:1.28-alpine

ARG REVISION=local

LABEL org.opencontainers.image.revision="${REVISION}"

COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
