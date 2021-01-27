#!/usr/bin/env bash
# encoding: utf-8

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install Redis

echo_error() { echo -e "\033[031;1m$*\033[0m"; }
echo_warn() { echo -e "\033[033;1m$*\033[0m"; }
echo_info() { echo -e "\033[032;1m$*\033[0m"; }

# show_banner
function show_banner() {
  echo_info "
 -------------------------------------------------
 | Install for Linux                             |
 | http://github.com/godcheese/shell_bag         |
 | author: godcheese [godcheese@outlook.com]     |
 -------------------------------------------------"
}
show_banner

# check_system
release_id=$(awk '/^NAME="/' /etc/os-release | awk -F '"' '{print $2}' | awk -F ' ' '{print $1}' | tr 'A-Z' 'a-z' 2>&1)
release_name=
release_version=$(awk '/^VERSION="/' /etc/os-release | awk -F '"' '{print $2}' | awk -F ' ' '{print $1}' 2>&1)
release_full_version=
linux_kernel=$(uname -srm | awk -F ' ' '{print $2}' | awk -F '-' '{print $1}' 2>&1)

function check_system() {
  case "${release_id}" in
  "centos")
    release_name="CentOS"
    release_full_version=$(awk '/\W/' /etc/centos-release | awk '{print $4}' 2>&1)
    ;;
  "ubuntu")
    release_name="Ubuntu"
    release_full_version="${release_version}"
    release_version=$(echo "${release_version}" | awk -F '.' '{print $1}')
    ;;
  "debian")
    release_name="Debian"
    release_full_version=$(cat /etc/debian_version 2>&1)
    ;;
  *)
    echo_error "\nUnsupported system.\n"
    exit 0
    ;;
  esac
}
check_system

# install_redis
function install_redis() {
  redis_port=6379
  redis_password=123456
  redis_data=
  redis_conf_file=
  redis_pid_file=
  redis_log_file=

  echo_info "\nInstalling Redis..."
  input="$1"
  extract="$2"
  output="$3"
  replace="$4"
  which=$(which mysql 2>&1)
  echo "${which}" | grep "/usr/bin/which: no" "${which}" &>/dev/null
  if [ "$?" == 1 ]; then
    if [ ! -z "${which}" ]; then
      echo_warn "You have installed: ${which}"
      if [ -z "${replace}" ]; then
        read -p "Do you want to overwrite the installation ?(no)": replace
      fi
      if [ -z "${replace}" ]; then
        replace="no"
      fi
      replace=$(echo "${replace}" | tr [A-Z] [a-z])
      if [[ "${replace}" =~ ^y|yes$ ]]; then
        echo_warn "Overwrite installation..."
        rm -rf "${which}"
      else
        echo_warn "Do not overwrite installation and exit."
        exit 0
      fi
    fi
  fi

  if [ "${release_id}"x == "centos"x ]; then
    yum update -y
    yum install -y gcc
    yum install -y epel-release
    yum install -y centos-release-scl
    yum install -y devtoolset-9-gcc devtoolset-9-gcc-c++ devtoolset-9-binutils
    echo "source /opt/rh/devtoolset-9/enable" >>/etc/profile
    source /etc/profile
  fi
  if test -r /etc/init.d/redis; then
    if [ "${release_id}"x == "centos"x ]; then
      service redis stop >/dev/null
      chkconfig --del redis && chkconfig redis off
    fi
    if [ "${release_id}"x == "ubuntu"x ]; then
      /etc/init.d/redis stop >/dev/null
      update-rc.d -f redis remove
    fi
  fi
  kill_process redis
  kill_process redis-server
  current_path=$(pwd)
  base_filename=$(basename "${input}")
  rm -rf "${output}" && mkdir -p "${output}"
  if [[ "${input}" =~ ^http.* ]]; then
    curl -o "${base_filename}" "${input}"
    tar -zxvf "${base_filename}"
  else
    tar -zxvf "${input}"
  fi
  if [ "$(pwd)/${extract}" != "${output}" ]; then
    mv "${extract}/"* "${output}"
    rm -rf "${extract}"
  fi
  if test -z "${redis_data}"; then
    redis_data="${output}/data"
  fi
  if test -z "${redis_conf_file}"; then
    redis_conf_file="${output}/redis.conf"
  fi
  if test -z "${redis_pid_file}"; then
    redis_pid_file="${output}/redis.pid"
  fi
  if test -z "${redis_log_file}"; then
    redis_log_file="${output}/redis.log"
  fi
  if [ ! -d "${redis_data}" ]; then
    mkdir -p "${redis_data}"
  fi
  if [ ! -r "${redis_conf_file}" ]; then
    mkdir -p "${redis_conf_file%/*}"
    \cp -rf "${output}/redis.conf" "${redis_conf_file}"
  fi
  if [ ! -r "${redis_pid_file}" ]; then
    mkdir -p "${redis_pid_file%/*}"
    touch "${redis_pid_file}"
  fi
  if [ ! -r "${redis_log_file}" ]; then
    mkdir -p "${redis_log_file%/*}"
    touch "${redis_log_file}"
  fi
  cd "${output}"
  make && make install PREFIX="${output}"
  cd "${current_path}"
  rm -rf /usr/local/bin/redis-server
  rm -rf /usr/local/bin/redis-cli
  ln -fs "${output}/bin/redis-server" /usr/local/bin/redis-server
  ln -fs "${output}/bin/redis-cli" /usr/local/bin/redis-cli
  rm -rf "${output}/bin/redis.service" && touch "${output}/bin/redis.service"
  cat >"${output}/bin/redis.service" <<EOF
#!/usr/bin/env bash
# encoding: utf-8
# chkconfig: - 84 16
# description: It is used to serve.
# author: godcheese [godcheese@outlook.com]
### BEGIN INIT INFO
# Provides: redis
# Required-Start: $local_fs $remote_fs
# Should-Start:
# Required-Stop: $local_fs $remote_fs
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop Redis
# Description: Redis
### END INIT INFO

# kill_process
function kill_process() {
  if [ \$# -lt 1 ]; then
    echo "Argument is missing: procedure_name"
    exit 1
  fi
  # grep -v grep 排除 grep 本身，grep -v install 排除正在运行的本身
  # ps -ef | grep procedure_name | grep -v grep | grep -v install | awk '{print $2}' | xargs kill -9
  process=\$(ps -ef | grep \$1 | grep -v grep | grep -v PPID | awk '{ print \$2}')
  for i in \$process; do
    kill -9 \$i
  done
}

exec_file="${output}/bin/redis-server"
conf_file="${redis_conf_file}"
log_file="${redis_log_file}"
if [ ! -r "\${exec_file}" ]; then
  exec_file=/usr/local/bin/redis-server
fi
if [ ! -r "\${exec_file}" ]; then
  echo "Redis not found:\${exec_file}"
  exit 1
fi
if [ ! -r "\${conf_file}" ]; then
  conf_file=/etc/redis/redis.conf
fi
if [ ! -r "\${log_file}" ]; then
  log_file=/var/log/redis.log
fi
case "\$1" in
  "status")
  result=\$(ps -ef | grep redis-server | grep -v grep)
  if [[ "\${result}" =~ "redis-server" ]] ; then
    echo "Redis is running."
  else
    echo "Redis is not running."
  fi
  ;;
  "start")
    result=\$(ps -ef | grep redis-server | grep -v grep)
    if [[ "\${result}" =~ "redis-server" ]] ; then
      echo "Redis is running."
    else
      echo "Starting redis..."
      nohup "\${exec_file}" "\${conf_file}" >"\${log_file}" 2>&1 &
    echo "Redis start successful."
    fi
    ;;
  "stop")
    result=\$(ps -ef | grep redis-server | grep -v grep)
    if [[ "\${result}" =~ "redis-server" ]] ; then
      echo "Stopping redis..."
      kill_process redis-server
      echo "Redis stop successful."
    else
      echo "Redis is not running."
    fi
    ;;
  "restart")
    result=\$(ps -ef | grep redis-server | grep -v grep)
    echo "Restarting redis..."
    if [[ "\${result}" =~ "redis-server" ]] ; then
      kill_process redis-server
      nohup "\${exec_file}" "\${conf_file}" >"\${log_file}" 2>&1 &
    else
      nohup "\${exec_file}" "\${conf_file}" >"\${log_file}" 2>&1 &
    fi
    echo "Redis restart successful."
    ;;
  *)
    echo "Usage: {status|stop|restart}"
    exit 1
    ;;
esac
EOF

  rm -rf /etc/init.d/redis
  \cp -rf "${output}/bin/redis.service" /etc/init.d/redis
  chmod 755 /etc/init.d/redis
  sed -i 's@^protected-mode yes@protected-mode no@' "${redis_conf_file}"
  sed -i 's@^bind 127.0.0.1@# bind 127.0.0.1@' "${redis_conf_file}"
  sed -i 's@^# port 0@port '"${redis_port}"'@' "${redis_conf_file}"
  sed -i 's@^# requirepass foobared@requirepass '"${redis_password}"'@' "${redis_conf_file}"
  sed -i 's@pidfile /var/run/redis_6379.pid@pidfile '"${redis_pid_file}"'@' "${redis_conf_file}"
  sed -i 's@logfile ""@logfile '"${redis_log_file}"'@' "${redis_conf_file}"
  sed -i 's@dir ./@dir '"${redis_data}"'@' "${redis_conf_file}"
  if [ "${release_id}"x == "centos"x ]; then
    service redis start
    chkconfig --add redis && chkconfig redis on
  fi
  if [ "${release_id}"x == "ubuntu"x ]; then
    /etc/init.d/redis start
    update-rc.d -f redis defaults
  fi
  sed -i "/^source \/opt\/rh\/devtoolset-9\/enable/d" /etc/profile
  source /etc/profile
  sed -i "/^# Made for Redis/d" /etc/profile
  sed -i "/REDIS_HOME/d" /etc/profile
  echo "# Made for Redis env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export REDIS_HOME=\"${output}\"" >>/etc/profile
  echo "export PATH=\"\${REDIS_HOME}:\${REDIS_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -3 /etc/profile)
  echo_warn "\n写入 /etc/profile 的环境变量内容：\n${profile}"
  version=$(redis-server --version 2>&1)
  if [ "$?" != 0 ]; then
    show_banner
    echo_error "\nRedis 安装失败！\n"
    exit 1
  else
    if [ "${release_id}"x == "centos"x ]; then
      firewall-cmd --zone=public --add-port="${redis_port}"/tcp --permanent >/dev/null 2>&1
      firewall-cmd --reload >/dev/null 2>&1
    fi
    if [ "${release_id}"x == "ubuntu"x ]; then
      ufw allow "${redis_port}"/tcp >/dev/null 2>&1
    fi
    show_banner
    echo_info "\nRedis 安装成功！已关闭 protected mode。
- Redis 版本：${version}
- Redis 安装路径：${output}/bin
- Redis 配置文件路径：${redis_conf_file}
- Redis 端口：${redis_port}
- Redis 密码：${redis_password}
- Redis 常用命令："
    if [ "${release_id}"x == "centos"x ]; then
      echo_info "  状态：service redis status
  启动：service redis start
  停止：service redis stop
  重启：service redis restart\n"
    fi
    if [ "${release_id}"x == "ubuntu"x ]; then
      echo_info "  状态：/etc/init.d/redis status
  启动：/etc/init.d/redis start
  停止：/etc/init.d/redis stop
  重启：/etc/init.d/redis restart\n"
    fi
    exit 0
  fi
}

# kill_process
function kill_process() {
  if [ $# -lt 1 ]; then
    echo "Argument is missing: procedure_name"
    exit 1
  fi
  # grep -v grep 排除 grep 本身，grep -v install 排除正在运行的本身
  # ps -ef | grep procedure_name | grep -v grep | grep -v install | awk '{print $2}' | xargs kill -9
  process=$(ps -ef | grep "$1" | grep -v grep | grep -v install | grep -v PPID | awk '{ print $2}')
  for i in $process; do
    echo "Kill the $1 process [ $i ]"
    kill -9 "$i"
  done
}

case "$1" in
"install")
  shift 1
  usage="Usage:
-h show usage.
-i test.tar.gz/https.example.com/test.tar.gz
-e subDirectory
-o /test
-r yes/y"
  while getopts "hi:e:o:r:" arg; do
    case $arg in
    i)
      input="$OPTARG"
      ;;
    e)
      extract="$OPTARG"
      ;;
    o)
      output="$OPTARG"
      ;;
    r)
      replace="$OPTARG"
      ;;
    h)
      echo "${usage}"
      exit 0
      ;;
    ?)
      echo "${usage}"
      exit 1
      ;;
    esac
  done
  shift $((OPTIND - 1))
  if [ -z "${input}" ] || [ -z "${extract}" ] || [ -z "${output}" ]; then
    echo_error "\nInvalid argument."
    echo "${usage}"
    exit 1
  fi
  install_redis "${input}" "${extract}" "${output}" "${replace}"
  ;;
"uninstall")
  shift 1
  echo "Not yet developed."
  ;;
*)
  echo_error "\n请输入正确的命令：\n install/uninstall"
  exit 1
  ;;
esac
