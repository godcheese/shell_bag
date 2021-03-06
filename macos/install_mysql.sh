#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install MySQL

# get_system_info
release_id=$(awk '/^NAME="/' /etc/os-release | awk -F '"' '{print $2}' | awk -F ' ' '{print $1}' | tr 'A-Z' 'a-z' 2>&1)
release_name=
release_version=$(awk '/^VERSION="/' /etc/os-release | awk -F '"' '{print $2}' | awk -F ' ' '{print $1}' 2>&1)
release_full_version=
linux_kernel=$(uname -srm | awk -F ' ' '{print $2}' | awk -F '-' '{print $1}' 2>&1)
function get_system_info() {
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
    release_full_version=${release_version}
    release_version=$(echo ${release_version} | awk -F '.' '{print $1}')
    ;;
  *)
    echo "Unknown system."
    exit 0
    ;;
  esac
}
get_system_info

# install_mysql
function install_mysql() {
  echo "Installing MySQL..."
  if [[ "${release_id}"x == "ubuntu"x ]]; then
    apt-get install update
    apt-get install -y libaio-dev
  fi
  if test -r /etc/init.d/mysql; then
    systemctl disable mysql >/dev/null
    service mysql stop >/dev/null
    rm -rf /var/lock/subsys/mysql
  fi
  install_path=$1
  download_url=$2
  file_name=$3
  base_file_name=$(basename ${download_url})
  if [[ ${download_url} =~ ^http.* ]]; then
    curl -o ${base_file_name} ${download_url}
  fi
  rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
  tar -zxvf ${base_file_name} -C ${install_path}
  mkdir -p ${install_path}/${file_name}/data
  mkdir -p ${install_path}/${file_name}/log
  rm -rf /etc/init.d/mysql
  \cp -rf ${install_path}/${file_name}/support-files/mysql.server /etc/init.d/mysql
  if [[ "${release_id}"x != "ubuntu"x ]]; then
    chkconfig --add mysql && chkconfig mysql on
  fi
  rm -rf /usr/local/bin/mysql
  rm -rf /usr/local/bin/mysqldump
  rm -rf /usr/local/bin/myisamchk
  rm -rf /usr/local/bin/mysqld_safe
  ln -fs ${install_path}/${file_name}/bin/mysql /usr/local/bin/mysql
  ln -fs ${install_path}/${file_name}/bin/mysqldump /usr/local/bin/mysqldump
  ln -fs ${install_path}/${file_name}/bin/myisamchk /usr/local/bin/myisamchk
  ln -fs ${install_path}/${file_name}/bin/mysqld_safe /usr/local/bin/mysqld_safe

  touch ${install_path}/${file_name}/mysql.sock
  touch ${install_path}/${file_name}/mysql.pid
  touch ${install_path}/${file_name}/log/mysql-error.log

  rm -rf /etc/my.cnf.d && mkdir -p /etc/my.cnf.d
  rm -rf /etc/my.cnf && touch /etc/my.cnf
  cat >/etc/my.cnf <<EOF
[client]
socket=${install_path}/${file_name}/mysql.sock
[mysqld]
basedir=${install_path}/${file_name}
datadir=${install_path}/${file_name}/data
socket=${install_path}/${file_name}/mysql.sock
pid-file=${install_path}/${file_name}/mysql.pid
port=3306
symbolic-links=0
[mysqld_safe]
log-error=${install_path}/${file_name}/log/mysql-error.log
pid-file=${install_path}/${file_name}/mysql.pid
!includedir /etc/my.cnf.d
EOF

  sed -i "/# Made for MySQL/d" /etc/profile
  sed -i "/MYSQL_HOME/d" /etc/profile
  echo "# Made for MySQL env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export MYSQL_HOME=\"${install_path}/${file_name}\"" >>/etc/profile
  echo "export PATH=\"\${MYSQL_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -4 /etc/profile)
  echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
  groupadd -f mysql && useradd -r -g mysql mysql -s /bin/false
  chown -R mysql ${install_path}/${file_name}
  ${install_path}/${file_name}/bin/mysqld --initialize-insecure --user=mysql
  systemctl enable mysql
  service mysql restart
  ${install_path}/${file_name}/bin/mysqladmin -u root password "123456"
  version=$(mysql --version 2>&1)
  if [[ ! $? == 0 ]]; then
    echo -e "\033[31m
        MySQL 安装失败！
        \033[0m"
    exit 0
  else
    firewall-cmd --zone=public --add-port=3306/tcp --permanent >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
    echo -e "\033[32m
        MySQL 安装成功！
        \033[0m"
    echo -e "\033[32m
        - MySQL 版本：${version}
        - MySQL 安装路径：${install_path}/${file_name}
        - MySQL数据保存路径：${install_path}/${file_name}/data
        - MySQL日志文件路径：${install_path}/${file_name}/log
        - MySQL 端口：3306
        - root 密码：123456
        - MySQL 常用命令：
          状态：service mysql status
          启动：service mysql start
          停止：service mysql stop
          重启：service mysql restart
        \033[0m"
    exit 0
  fi
}

# show banner
function show_banner() {
  echo -e "\033[32m
    -------------------------------------------------
    | Install for Linux                             |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"
}

show_banner
case "$1" in
"install")
  install_mysql $2 $3 $4
  ;;
"uninstall")
  uninstall_mysql $2 $3 $4
  ;;
*)
  echo "请输入正确的命令"
  exit 0
  ;;
esac
