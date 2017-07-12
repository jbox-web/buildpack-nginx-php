NGINX_CACHE_DIR=$CACHE_DIR/nginx
PHP_CACHE_DIR=$CACHE_DIR/php5

source $BP_DIR/bin/packages/install_nginx.sh
source $BP_DIR/bin/packages/install_php.sh


function get_apt_updates() {
  apt-get update > /dev/null 2>&1
}


function package_is_installed() {
  package=$1
  $(dpkg -s $package > /dev/null 2>&1)
  echo $?
}


function install_package() {
  local package=$1
  local package_name=${package^^}
  if [[ $(package_is_installed $package) -eq 0 ]] ; then
    version=$(dpkg -l | grep $package | head -n 1 | awk '{print $3}')
    echo "$package_name already installed : $version" | indent
    "install_"$package"_configuration"
  else
    echo "* Bundling $package_name" | indent
    "fetch_"$package"_packages"
    "install_"$package"_configuration"
  fi
}


function install_configuration() {
  # Install JBoxPatchDatabase
  cp -r "$BP_DIR/conf/jbox-patch-database/"* /usr/local/bin/
  ln -s /usr/local/bin/jbox_database.rb /usr/local/bin/jbox_database
  chmod 755 /usr/local/bin/jbox_*

  # Create dir for MySQL socket
  mkdir -p /var/run/mysqld

  ln -sf /dev/stdout /var/log/cron.log

  # Add start script
  mkdir -p /etc/service/00-rsyslog
  cp "$BP_DIR/conf/runit/start-rsyslog.sh" /etc/service/00-rsyslog/run

  # Chmod 755 init scripts
  chmod 755 /etc/service/*/run
}


function package_logs_files() {
  jq --raw-output '.extra.heroku["log-files"] // [] | .[]' < "$BUILD_DIR/composer.json"
}


function package_framework() {
  jq --raw-output '.extra.heroku.framework // ""' < "$BUILD_DIR/composer.json"
}


function package_php_config() {
  jq --raw-output '.extra.heroku["php-config"] // [] | .[]' < "$BUILD_DIR/composer.json"
}


function package_php_includes() {
  jq --raw-output '.extra.heroku["php-includes"] // [] | .[]' < "$BUILD_DIR/composer.json"
}


function package_nginx_includes() {
  jq --raw-output '.extra.heroku["nginx-includes"] // [] | .[]' < "$BUILD_DIR/composer.json"
}


function init_logger_fifo() {
  for log_file in $*; do
    echo "mkdir -p `dirname ${log_file}`"
    echo "rm -f ${log_file}"
    echo "mkfifo ${log_file}"
    echo ''
  done
}
