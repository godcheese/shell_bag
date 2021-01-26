#!/usr/bin/env bash
# encoding: utf-8

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install MySQL

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

# install_mysql
function install_mysql() {
  mysql_port=3306
  mysql_password=123456
  mysql_data=
  mysql_sock_file=
  mysql_pid_file=
  mysql_log_error_file=

  echo_info "\nInstalling MySQL..."
  input="$1"
  extract="$2"
  output="$3"
  replace="$4"
  which=$(which mysql 2>&1)
  echo "${which}" | grep "/usr/bin/which: no" "${which}" &>/dev/null
  if [ "$?" == 1 ]; then
    if [ ! -z "${which}" ]; then
      echo "You have installed: ${which}"
      if [ -z "${replace}" ]; then
        read -p "Do you want to overwrite the installation ?(no)": replace
      fi
      if [ -z "${replace}" ]; then
        replace="no"
      fi
      replace=$(echo "${replace}" | tr [A-Z] [a-z])
      if [[ "${replace}" =~ ^y|yes$ ]]; then
        echo "Overwrite installation..."
        rm -rf "${which}"
      else
        echo "Do not overwrite installation and exit."
        exit 0
      fi
    fi
  fi

  if [ "${release_id}"x == "ubuntu"x ]; then
    apt-get update -y
    apt-get install -y libaio-dev
  fi
  if test -r /etc/init.d/mysql; then
    chkconfig --del mysql && chkconfig mysql off
    service mysql stop >/dev/null
    rm -rf /var/lock/subsys/mysql
  fi
  kill_process mysql
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
  if test -z "${mysql_data}"; then
    mysql_data="${output}/data"
  fi
  if test -z "${mysql_log_error_file}"; then
    mysql_log_error_file="${output}/log/mysql-error.log"
  fi
  if test -z "${mysql_sock_file}"; then
    mysql_sock_file="${output}/mysql.sock"
  fi
  if test -z "${mysql_pid_file}"; then
    mysql_pid_file="${output}/mysql.pid"
  fi
  if [ ! -d "${mysql_data}" ]; then
    mkdir -p "${mysql_data}"
  fi
  if [ ! -r "${mysql_sock_file}" ]; then
    mkdir -p "${mysql_sock_file%/*}"
    touch "${mysql_sock_file}"
  fi
  if [ ! -r "${mysql_pid_file}" ]; then
    mkdir -p "${mysql_pid_file%/*}"
    touch "${mysql_pid_file}"
  fi
  if [ ! -r "${mysql_log_error_file}" ]; then
    mkdir -p "${mysql_log_error_file%/*}"
    touch "${mysql_log_error_file}"
  fi

  rm -rf /etc/init.d/mysql
  \cp -rf "${output}/support-files/mysql.server" /etc/init.d/mysql
  rm -rf /usr/local/bin/mysql
  rm -rf /usr/local/bin/mysqldump
  rm -rf /usr/local/bin/myisamchk
  rm -rf /usr/local/bin/mysqld_safe
  ln -fs "${output}/bin/mysql" /usr/local/bin/mysql
  ln -fs "${output}/bin/mysqldump" /usr/local/bin/mysqldump
  ln -fs "${output}/bin/myisamchk" /usr/local/bin/myisamchk
  ln -fs "${output}/bin/mysqld_safe" /usr/local/bin/mysqld_safe
  ln -fs "${output}/bin/mysqladmin" /usr/local/bin/mysqladmin

  rm -rf /etc/my.cnf.d && mkdir -p /etc/my.cnf.d
  rm -rf /etc/my.cnf && touch /etc/my.cnf
  cat >/etc/my.cnf <<EOF
[client]
socket=${mysql_sock_file}
[mysqld]
basedir=${output}
datadir=${mysql_data}
socket=${mysql_sock_file}
pid-file=${mysql_pid_file}
port=3306
symbolic-links=0
[mysqld_safe]
log-error=${mysql_log_error_file}
pid-file=${mysql_pid_file}
!includedir /etc/my.cnf.d
EOF

  sed -i "/^# Made for MySQL/d" /etc/profile
  sed -i "/MYSQL_HOME/d" /etc/profile
  echo "# Made for MySQL env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export MYSQL_HOME=\"${output}\"" >>/etc/profile
  echo "export PATH=\"\${MYSQL_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -3 /etc/profile)
  echo_warn "\n写入 /etc/profile 的环境变量内容：\n${profile}"
  groupadd -f mysql && useradd -r -g mysql mysql -s /bin/false
  chown -R mysql:mysql "${output}"
  "${output}/bin/mysqld" --initialize-insecure --user=mysql
  chkconfig --add mysql && chkconfig mysql on
  service mysql start
  "${output}/bin/mysqladmin" -u root password "${mysql_password}"
  "${output}/bin/mysql" -uroot -p123456 -e "use mysql;update user set host ='%' where user ='root';"
  service mysql restart
  version=$(mysql --version 2>&1)
  if [ "$?" != 0 ]; then
    show_banner
    echo_error "\nMySQL 安装失败！"
    exit 0
  else
    firewall-cmd --zone=public --add-port=${mysql_port}/tcp --permanent >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
    show_banner
    echo_info "\nMySQL 安装成功！
- MySQL 版本：${version}
- MySQL 安装路径：${output}
- MySQL 数据保存路径：${mysql_data}
- MySQL 日志文件路径：${mysql_log_error_file%/*}
- MySQL 端口：${mysql_port}
- root 密码：${mysql_password}
- MySQL 常用命令：
  状态：service mysql status
  启动：service mysql start
  停止：service mysql stop
  重启：service mysql restart"
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
  install_mysql "${input}" "${extract}" "${output}" "${replace}"
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
