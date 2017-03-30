####################################################
# 1. Get all dependencies from github
# 2. Pull dependencies down and build binary
#     and copy into image
# 3. Copy NGINX specific conf files into image
# 4. Make sure permissions are correct
####################################################

NGINX_USER=nginx

NGINX_BIN_DIR=/usr/bin
NGINX_CONF_DIR=/etc/nginx
NGINX_LOG_DIR=/var/log/nginx
NGINX_TMP_DIR=/var/spool/nginx/tmp

useradd -s /bin/false $NGINX_USER

mkdir -p -m 775 $NGINX_CONF_DIR/conf.d
mkdir -p -m 775 $NGINX_LOG_DIR
mkdir -p -m 775 $NGINX_TMP_DIR

chmod -R 775 $NGINX_CONF_DIR
chmod -R 775 $NGINX_TMP_DIR

# Get necessary binaries from apt
apt-get update
apt-get install -y build-essential git libpcre3 libpcre3-dev

# Build binary from nginx and additional modules
cd deps/nginx-1.10.3

# Run configure with options and additional modules
./configure \
   --user=nginx \
   --group=nginx \
   --prefix=$NGINX_CONF_DIR \
   --sbin-path=$NGINX_BIN_DIR/nginx \
   --conf-path=$NGINX_CONF_DIR/nginx.conf \
   --error-log-path=$NGINX_LOG_DIR/error.log \
   --http-log-path=$NGINX_LOG_DIR/access.log \
   --http-client-body-temp-path=/tmp/client_body \
   --http-proxy-temp-path=/tmp/proxy \
   --http-fastcgi-temp-path=/tmp/fastcgi \
   --pid-path=/var/run/nginx.pid \
   --with-pcre \
   --with-http_ssl_module \
   --with-http_gzip_static_module \
   --with-http_stub_status_module \
   --with-openssl=../openssl-1.1.0e \
   --with-zlib=../zlib-1.2.11 \
   --with-ipv6 \
   --without-mail_imap_module         \
   --without-mail_smtp_module         \
   --without-mail_pop3_module      \
   --add-module=../naxsi/naxsi_src \
   --add-module=../ngx_http_substitutions_filter_module \
   --add-module=../headers-more-nginx-module

# Run make and make install
make && make install

# Check nginx build
nginx -V

# Copy binary and configuration files
cp $NGINX_BIN_DIR/nginx /usr/sbin/
cp -R ../../conf/ $NGINX_CONF_DIR
