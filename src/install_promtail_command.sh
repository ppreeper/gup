APP="promtail"
REPO="https://github.com/grafana/promtail"
vers=$(git ls-remote --tags ${REPO} | grep "refs/tags.*[0-9]$" | grep -v -e "helm" | awk '{print $2}' | sed 's/refs\/tags\///' | sort -V | uniq | tail -1)

USERIDNUMBER=$(grep $(whoami) /etc/passwd | awk -F":" '{print $3}')
if [ ${USERIDNUMBER} == 0 ]; then
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
  sudo mkdir /etc/promtail
cat <<-_EOF_ | sudo tee /etc/promtail/promtail-config.yml > /dev/null
server:
  http_listen_port: 9080
  grpc_listen_port: 0
positions:
  filename: /tmp/positions.yaml
clients:
  - url: http://localhost:3100/loki/api/v1/push
scrape_configs:
  - job_name: syslog
    syslog:
      listen_address: 0.0.0.0:1514
      labels:
        job: syslog
    relabel_configs:
      - source_labels: [__syslog_message_hostname]
        target_label: host
      - source_labels: [__syslog_message_hostname]
        target_label: hostname
      - source_labels: [__syslog_message_severity]
        target_label: level
      - source_labels: [__syslog_message_app_name]
        target_label: application
      - source_labels: [__syslog_message_facility]
        target_label: facility
      - source_labels: [__syslog_connection_hostname]
        target_label: connection_hostname
_EOF_
}

# download new
if [ -z $(which ${APP}) ]; then
  download new
else
  APPBIN=$(which ${APP})
  APPVER=$(${APPBIN} --version | grep -i ^${APP} | awk '{print $3}')
  [ "${APPVER}" = "$(echo $vers | sed 's/^v//')" ] && echo "${APP} version is current" || download ${vers}
fi
