#----------------------------------------------------------
# Docker Image for Nginx webserver
# - configurations on optional folder for easyer overrides
# - adapted for reverse proxy use
# - additional configs for simplesamlphp
# - nginx runs as application user
#----------------------------------------------------------
FROM nginx:mainline-alpine
LABEL maintainer="Paulo Costa <paulo.costa@fccn.pt>"

#---- Read build args
ARG WEB_DOCUMENT_ROOT=/var/www
ARG NGINX_ROOT=/etc/nginx
ARG NGINX_OPTS=/opt/nginx

ENV TZ=Europe/Lisbon
ENV WEB_ROOT=$WEB_DOCUMENT_ROOT

#add testing and community repositories
RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && echo '@community http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
  && echo '@edge http://nl.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
  && apk update && apk upgrade --no-cache --available && apk add --upgrade apk-tools@edge \
#------ set timezone
  ; apk --no-cache add ca-certificates && update-ca-certificates \
  ; apk add --update tzdata && cp /usr/share/zoneinfo/Europe/Lisbon /etc/localtime \
#--- additional packages
  ; rm -rf /var/cache/apk/*

#-Add configurations
COPY ./config/h5bp $NGINX_ROOT/h5bp
COPY ./config/sites-available $NGINX_ROOT/sites-available
COPY ./config/mime.types $NGINX_ROOT/mime.types

#---- place additional configurations on opts folder and create pointers for configs
WORKDIR $NGINX_OPTS
COPY ./config/nginx.conf $NGINX_OPTS/nginx.conf
COPY ./config/conf.d $NGINX_ROOT/conf.d
COPY ./config/commons $NGINX_OPTS/commons
#- Add startup script
COPY ./build/entrypoint.sh /tmp/entrypoint.sh
#--- make arrangements for opts folder
RUN rm $NGINX_ROOT/nginx.conf && ln -s $NGINX_OPTS/nginx.conf $NGINX_ROOT/nginx.conf \
  && mkdir -p $NGINX_OPTS/sites-enabled && rm -rf $NGINX_ROOT/sites-enabled && ln -s $NGINX_OPTS/sites-enabled $NGINX_ROOT/sites-enabled \
  && mkdir ssl && ln -s $NGINX_OPTS/ssl $NGINX_ROOT/ssl \
  && rm -f $NGINX_ROOT/conf.d/default.conf && mkdir $NGINX_OPTS/conf.d \
  && envsubst < $NGINX_ROOT/conf.d/99-opt-configs.unset > $NGINX_ROOT/conf.d/99-opt-configs.conf \
  && rm -f $NGINX_ROOT/conf.d/99-opt-configs.unset \
  && ln -s $NGINX_OPTS/commons $NGINX_ROOT/commons \
#---- prepare startup script
  && chmod +x /tmp/entrypoint.sh

WORKDIR $NGINX_ROOT

# display version numbers
RUN echo "Using: "; echo $(nginx -v); echo "Webroot dir: $WEB_ROOT";
CMD ["/tmp/entrypoint.sh"]
