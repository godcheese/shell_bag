#!/usr/bin/env bash
# encoding: utf-8

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install Nginx

echo_error() { echo -e "\n\033[031;1mERROR $(date +"%F %T")\t$*\033[0m"; }
echo_warn() { echo -e "\n\033[033;1mWARN $(date +"%F %T")\t$*\033[0m"; }
echo_info() { echo -e "\n\033[032;1mINFO $(date +"%F %T")\t$*\033[0m"; }

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
  "debian")
    release_name="Debian"
    release_full_version=$(cat /etc/debian_version 2>&1)
    ;;
  "ubuntu")
    release_name="Ubuntu"
    release_full_version="${release_version}"
    release_version=$(echo "${release_version}" | awk -F '.' '{print $1}')
    ;;
  *)
    echo_error "\nUnsupported system."
    exit 0
    ;;
  esac
}
check_system

# install_nginx
function install_nginx() {
  nginx_conf_file=
  nginx_pid_file=
  nginx_log_error_file=

  echo_info "\nInstalling Nginx..."
  if [ "${release_id}"x == "centos"x ]; then
    yum update -y
    yum install -y gcc zlib* pcre-devel make
  fi
  if [ "${release_id}"x == "ubuntu"x ]; then
    apt-get update -y
    apt-get install -y gcc build-essential libpcre3 libpcre3-dev
  fi
  if test -r /etc/init.d/nginx; then
    chkconfig --add nginx && chkconfig nginx off
    service nginx stop >/dev/null
  else
    if test -r /usr/local/bin/nginx; then
      /usr/local/bin/nginx -s stop >/dev/null
    fi
  fi
  kill_process nginx
  current_path=$(pwd)
  install_path="$1"
  download_url="$2"
  file_name="$3"
  base_file_name=$(basename "${download_url}")
  if [[ "${download_url}" =~ ^http.* ]]; then
    curl -o "${base_file_name}" "${download_url}"
  fi
  rm -rf "${install_path}/${file_name}" && mkdir -p "${install_path}"
  tar -zxvf "${base_file_name}" -C "${install_path}"

  if test -z "${nginx_conf_file}"; then
    nginx_conf_file="${install_path}/${file_name}/bin/conf/nginx.conf"
  fi
  if test -z "${nginx_pid_file}"; then
    nginx_pid_file="${install_path}/${file_name}/bin/nginx.pid"
  fi
  if [ ! -r "${nginx_conf_file}" ]; then
    mkdir -p "${nginx_conf_file%/*}"
#    touch "${nginx_conf_file}"
  fi
  if [ ! -r "${nginx_pid_file}" ]; then
    mkdir -p "${nginx_pid_file%/*}"
#    touch "${nginx_pid_file}"
  fi

  cd "${install_path}/${file_name}"
  if [ "${release_id}"x == "ubuntu"x ]; then
    curl -o zlib-1.2.11.tar.gz http://www.zlib.net/zlib-1.2.11.tar.gz
    tar -zxvf zlib-1.2.11.tar.gz
    cd zlib-1.2.11
    ./configure
    make && make install
  fi
  cd "${install_path}/${file_name}"
  ./configure --prefix="${install_path}/${file_name}/bin" --sbin-path=nginx --conf-path="${nginx_conf_file}" --pid-path="${nginx_pid_file}"
  make && make install
  cd "${current_path}"
  rm -rf /usr/local/bin/nginx
  ln -fs "${install_path}/${file_name}/bin/nginx" /usr/local/bin/nginx
  rm -rf "${install_path}/${file_name}/bin/nginx.service" && touch "${install_path}/${file_name}/bin/nginx.service"
  cat >"${install_path}/${file_name}/bin/nginx.service" <<EOF
#!/bin/sh
# chkconfig: - 85 15
# description: It is used to serve.
# author: godcheese [godcheese@outlook.com]

exec_file="${install_path}/${file_name}/bin/nginx"
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
esac
EOF

  rm -rf /etc/init.d/nginx
  \cp -rf "${install_path}/${file_name}/bin/nginx.service" /etc/init.d/nginx
  chmod 755 /etc/init.d/nginx
  sed -i "/^# Made for Nginx/d" /etc/profile
  sed -i "/NGINX_HOME/d" /etc/profile
  echo "# Made for Nginx env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export NGINX_HOME=\"${install_path}/${file_name}\"" >>/etc/profile
  echo "export PATH=\"\${NGINX_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -3 /etc/profile)
  echo_warn "\n写入 /etc/profile 的环境变量内容：\n${profile}"
  chkconfig --add nginx && chkconfig nginx on
  service nginx start
  version=$(nginx -v 2>&1)
  if [ "$?" != 0 ]; then
    show_banner
    echo_error "\nNginx 安装失败！"
    exit 1
  else
    firewall-cmd --zone=public --add-service=http --permanent >/dev/null 2>&1
    firewall-cmd --zone=public --add-service=https --permanent >/dev/null 2>&1
    firewall-cmd --zone=public --add-port=80/tcp --permanent >/dev/null 2>&1
    firewall-cmd --zone=public --add-port=443/tcp --permanent >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
    show_banner
    echo_info "\nNginx 安装成功！
- Nginx 版本：${version}
- Nginx 安装路径：${install_path}/${file_name}/bin
- Nginx 配置文件路径：${nginx_conf_file}
- Nginx 日志文件路径：${install_path}/${file_name}/bin/logs
- Nginx 常用命令：
  状态：service nginx status
  启动：service nginx start
  停止：service nginx stop
  重启：service nginx restart
  测试配置：service nginx test"
    exit 0
  fi
}

# show_banner
function show_banner() {
  echo_info "
 -------------------------------------------------
 | Install for Linux                             |
 | http://github.com/godcheese/shell_bag         |
 | author: godcheese [godcheese@outlook.com]     |
 -------------------------------------------------"
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

show_banner
case "$1" in
"install")
  install_nginx "$2" "$3" "$4"
  ;;
"uninstall")
  uninstall_nginx "$2" "$3" "$4"
  ;;
*)
  echo_error "\n请输入正确的命令"
  exit 1
  ;;
esac
