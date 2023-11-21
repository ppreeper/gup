APP="loki"
REPO="https://github.com/grafana/loki"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "helm" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

if [ $(id -u) == 0 ]; then
  BDIR="/usr/local/bin"
else
  BDIR="${HOME}/.local/bin"
fi

download() {
    echo "download $1 version"
    echo "installing ${vers}"
    FN=${APP}-linux-amd64.zip
    rm -rf /tmp/${APP}_${vers} /tmp/${FN}
    wget -qc ${REPO}/releases/download/${vers}/${FN} -O /tmp/${FN}
    mkdir -p /tmp/${APP}_${vers}
    unzip /tmp/${FN} -d /tmp/${APP}_${vers}
    rm -f ${BDIR}/${APP}
    install /tmp/${APP}_${vers}/${APP}-linux-amd64 ${BDIR}/${APP}
    rm -rf /tmp/${APP}_${vers} /tmp/${FN}
}

config() {
  sudo mkdir /etc/loki
cat <<-_EOF_ | sudo tee /etc/loki/loki-config.yml > /dev/null
auth_enabled: false
server:
  http_listen_port: 3100
ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 5m
  chunk_retain_period: 30s
schema_config:
  configs:
  - from: 2020-05-15
    store: boltdb
    object_store: filesystem
    schema: v11
    index:
      prefix: index_
      period: 168h
storage_config:
  boltdb:
    directory: /tmp/loki/index
  filesystem:
    directory: /tmp/loki/chunks
limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  max_entries_limit_per_query: 500000
# By default, Loki will send anonymous, but uniquely-identifiable usage and configuration
# analytics to Grafana Labs. These statistics are sent to https://stats.grafana.org/
#
# Statistics help us better understand how Loki is used, and they show us performance
# levels for most users. This helps us prioritize features and documentation.
# For more information on what's sent, look at
# https://github.com/grafana/loki/blob/main/pkg/usagestats/stats.go
# Refer to the buildReport method to see what goes into a report.
#
# If you would like to disable reporting, uncomment the following lines:
#analytics:
#  reporting_enabled: false
_EOF_
}

# download new
if [ -z $(which ${APP}) ]; then
  download new
  config
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} --version | grep -i ^${APP} | awk '{print $3}')
  [ "${APPVER}" = "$(echo $vers | sed 's/^v//')" ] && echo "${APP} version is current" || download ${vers}
  config
fi
