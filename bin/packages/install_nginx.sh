function fetch_nginx_packages() {
  if [ -n "$BUILDPACK_CLEAN_CACHE" ] ; then
    rm -rf $NGINX_CACHE_DIR
  fi

  if [ -z "$GET_PACKAGE_LIST" ] ; then
    get_apt_updates
    GET_PACKAGE_LIST=1
  fi

  if [ ! -d $NGINX_CACHE_DIR ] ; then
    mkdir -p $NGINX_CACHE_DIR
    apt-get --print-uris --yes install nginx | grep ^\' | cut -d\' -f2 > $NGINX_CACHE_DIR/downloads.list
    wget --input-file $NGINX_CACHE_DIR/downloads.list -P $NGINX_CACHE_DIR > /dev/null 2>&1
  else
    echo '(from cache)' | indent
  fi

  dpkg -i $NGINX_CACHE_DIR/*.deb > /dev/null 2>&1

  version=$(dpkg -l | grep nginx | head -n 1 | awk '{print $3}')
  echo "NGINX installed : $version" | indent
}


function install_nginx_configuration() {
  cp "$BP_DIR/conf/nginx/nginx.conf" /etc/nginx/nginx.conf

  # Add start script
  mkdir -p /etc/service/nginx
  cp "$BP_DIR/conf/runit/start-nginx.sh" /etc/service/nginx/run

  mkdir -p /etc/service/nginx-access-logger
  cp "$BP_DIR/conf/runit/start-nginx-access-logger.sh" /etc/service/nginx-access-logger/run

  mkdir -p /etc/service/nginx-error-logger
  cp "$BP_DIR/conf/runit/start-nginx-error-logger.sh" /etc/service/nginx-error-logger/run
}
