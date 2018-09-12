FROM     ubuntu:14.04.1

# ---------------- #
#   Installation   #
# ---------------- #

ENV DEBIAN_FRONTEND noninteractive

# Install all prerequisites
RUN     apt-get -y install --no-install-recommends software-properties-common                                                   &&\
        add-apt-repository -y ppa:chris-lea/node.js                                                                             &&\
        apt-get -y update                                                                                                       &&\
        apt-get -y --force-yes install  --no-install-recommends python-django-tagging python-simplejson \
        python-memcache python-ldap python-cairo python-pysqlite2 python-support \
        python-pip gunicorn supervisor nginx-light nodejs git wget curl openjdk-7-jre build-essential python-dev

RUN     pip install Twisted==11.1.0; pip install Django==1.5; pip install pytz; npm install ini chokidar

RUN     mkdir /src                                                                                                                &&\
# Install Grafana
        mkdir /src/grafana                                                                                                        &&\
        mkdir /opt/grafana                                                                                                        &&\
        wget https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.2.3.linux-amd64.tar.gz -O /src/grafana.tar.gz  &&\
        tar -xzf /src/grafana.tar.gz -C /opt/grafana --strip-components=1                                                         &&\
        rm /src/grafana.tar.gz                                                                                                    &&\
# Fix some container permissions
        chown -R www-data /var/lib/nginx                                                                                          &&\
        chmod 755 /

# ----------------- #
#   Configuration   #
# ----------------- #

# Configure Grafana
ADD     ./grafana/custom.ini /opt/grafana/conf/custom.ini

# Add the default dashboards
RUN     mkdir -p /src/dashboards; mkdir /src/dashboard-loader
ADD     ./grafana/dashboards/* /src/dashboards/
ADD     ./grafana/dashboard-loader/dashboard-loader.js /src/dashboard-loader/

# Configure nginx and supervisord
ADD     ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD     ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# ---------------- #
#   Expose Ports   #
# ---------------- #

# Grafana
EXPOSE  80

# -------- #
#   Run!   #
# -------- #

CMD     ["/usr/bin/supervisord"]
