#!/usr/bin/env bash
# encoding: utf-8

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install Nginx

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
  *)
    echo_error "\nUnsupported system.\n"
    exit 0
    ;;
  esac
}
check_system

# install_nginx
function install_nginx() {
  nginx_conf_file=
  nginx_pid_file=

  echo_info "\nInstalling Nginx..."
  input="$1"
  extract="$2"
  output="$3"
  replace="$4"
  which=$(which nginx 2>&1)
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
    yum install -y gcc zlib* pcre-devel make
  fi
  if [ "${release_id}"x == "ubuntu"x ]; then
    apt-get update -y
    apt-get install -y gcc build-essential libpcre3 libpcre3-dev
  fi
  if test -r /etc/init.d/nginx; then
    if [ "${release_id}"x == "centos"x ]; then
      service nginx stop >/dev/null
      chkconfig --del nginx && chkconfig nginx off
    fi
    if [ "${release_id}"x == "ubuntu"x ]; then
      /etc/init.d/nginx stop >/dev/null
      update-rc.d -f nginx remove
    fi
  else
    if test -r /usr/local/bin/nginx; then
      /usr/local/bin/nginx -s stop >/dev/null
    fi
  fi
  kill_process nginx
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
  if test -z "${nginx_conf_file}"; then
    nginx_conf_file="${output}/bin/conf/nginx.conf"
  fi
  if test -z "${nginx_pid_file}"; then
    nginx_pid_file="${output}/bin/nginx.pid"
  fi
  if [ ! -r "${nginx_conf_file}" ]; then
    mkdir -p "${nginx_conf_file%/*}"
  fi
  if [ ! -r "${nginx_pid_file}" ]; then
    mkdir -p "${nginx_pid_file%/*}"
  fi
  cd "${output}"
  if [ "${release_id}"x == "ubuntu"x ]; then
    curl -o zlib-1.2.11.tar.gz http://www.zlib.net/zlib-1.2.11.tar.gz
    tar -zxvf zlib-1.2.11.tar.gz
    cd zlib-1.2.11
    ./configure
    make && make install
  fi
  cd "${output}"
  ./configure --prefix="${output}/bin" --sbin-path=nginx --conf-path="${nginx_conf_file}" --pid-path="${nginx_pid_file}"
  make && make install
  sed -i 's@^#user  nobody;@user  root;@' "${nginx_conf_file}"
  cd "${current_path}"
  rm -rf /usr/local/bin/nginx
  ln -fs "${output}/bin/nginx" /usr/local/bin/nginx
  rm -rf "${output}/bin/nginx.service" && touch "${output}/bin/nginx.service"
  cat >"${output}/bin/nginx.service" <<EOF
#!/usr/bin/env bash
# encoding: utf-8
# chkconfig: - 85 15
# description: It is used to serve.
# author: godcheese [godcheese@outlook.com]
### BEGIN INIT INFO
# Provides: nginx
# Required-Start: $local_fs $remote_fs
# Should-Start:
# Required-Stop: $local_fs $remote_fs
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop Nginx
# Description: Nginx
### END INIT INFO

exec_file="${output}/bin/nginx"
if [ ! -r "\${exec_file}" ]; then
  exec_file=/usr/local/bin/nginx
fi
if [ ! -r "\${exec_file}" ] ; then
  echo "Nginx not found:\${exec_file}"
  exit 0
fi
case "\$1" in
  "status")
  result=\$(ps -ef | grep nginx | grep -v grep)
  if [[ "\${result}" =~ "00:00:00 nginx" ]] ; then
    echo "Nginx is running."
  else
    echo "Nginx is not running."
  fi
  ;;
  "start")
    result=\$(ps -ef | grep nginx | grep -v grep)
    if [[ "\${result}" =~ "00:00:00 nginx" ]] ; then
      echo "Nginx is running."
    else
      echo "Starting nginx..."
      "\${exec_file}"
      echo "Nginx start successful."
    fi
    ;;
  "stop")
    result=\$(ps -ef | grep nginx | grep -v grep)
    if [[ "\${result}" =~ "00:00:00 nginx" ]] ; then
      echo "Stopping nginx..."
      "\${exec_file}" -s stop
      echo "Nginx stop successful."
    else
      echo "Nginx is not running."
    fi
    ;;
  "restart")
    result=\$(ps -ef | grep nginx | grep -v grep)
    echo "Restarting nginx..."
    if [[ "\${result}" =~ "00:00:00 nginx" ]] ; then
    "\${exec_file}" -s reload
    else
      "\${exec_file}" -s reload
    fi
      echo "Nginx restart successful."
    ;;
  "test")
    echo "Testing nginx conf..."
    "\${exec_file}" -t
    echo "Nginx conf test successful."
    ;;
  *)
    echo "Usage: {status|stop|restart|test}"
    exit 1
    ;;
esac
EOF

  rm -rf /etc/init.d/nginx
  \cp -rf "${output}/bin/nginx.service" /etc/init.d/nginx
  chmod 755 /etc/init.d/nginx
  sed -i "/^# Made for Nginx/d" /etc/profile
  sed -i "/NGINX_HOME/d" /etc/profile
  echo "# Made for Nginx env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export NGINX_HOME=\"${output}\"" >>/etc/profile
  echo "export PATH=\"\${NGINX_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -3 /etc/profile)
  echo_warn "\n写入 /etc/profile 的环境变量内容：\n${profile}\n"
  if [ "${release_id}"x == "centos"x ]; then
    service nginx start
    chkconfig --add nginx && chkconfig nginx on
  fi
  if [ "${release_id}"x == "ubuntu"x ]; then
    /etc/init.d/nginx start
    update-rc.d -f nginx defaults
  fi
  version=$(nginx -v 2>&1)
  if [ "$?" != 0 ]; then
    show_banner
    echo_error "\nNginx 安装失败！\n"
    exit 1
  else
    if [ "${release_id}"x == "centos"x ]; then
      firewall-cmd --zone=public --add-service=http --permanent >/dev/null 2>&1
      firewall-cmd --zone=public --add-service=https --permanent >/dev/null 2>&1
      firewall-cmd --zone=public --add-port=80/tcp --permanent >/dev/null 2>&1
      firewall-cmd --zone=public --add-port=443/tcp --permanent >/dev/null 2>&1
      firewall-cmd --reload >/dev/null 2>&1
    fi
    if [ "${release_id}"x == "ubuntu"x ]; then
      ufw allow 80/tcp >/dev/null 2>&1
      ufw allow 443/tcp >/dev/null 2>&1
    fi
    show_banner
    echo_info "\nNginx 安装成功！
- Nginx 版本：${version}
- Nginx 安装路径：${output}/bin
- Nginx 配置文件路径：${nginx_conf_file}
- Nginx 日志文件路径：${output}/bin/logs
- Nginx 常用命令："
    if [ "${release_id}"x == "centos"x ]; then
      echo_info "  状态：service nginx status
  启动：service nginx start
  停止：service nginx stop
  重启：service nginx restart
  测试配置：service nginx test\n"
    fi
    if [ "${release_id}"x == "ubuntu"x ]; then
      echo_info "  状态：service nginx status
  启动：/etc/init.d/nginx start
  停止：/etc/init.d/nginx stop
  重启：/etc/init.d/nginx restart
  测试配置：/etc/init.d/nginx test\n"
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
  install_nginx "${input}" "${extract}" "${output}" "${replace}"
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
