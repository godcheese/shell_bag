#!/usr/bin/env bash
# encoding: utf-8.0

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install Nginx

# install nginx
function install_nginx() {
  echo "Installing Nginx..."
  if [[ "${release_id}"x == "centos"x ]]; then
    yum update
    yum install -y gcc zlib* pcre-devel make
  fi
  if [[ "${release_id}"x == "ubuntu"x ]]; then
    apt-get update
    apt-get -y gcc zlib* pcre-devel make
  fi
  if test -r /etc/init.d/nginx; then
    service nginx stop
  else
    if test -r /usr/local/bin/nginx; then
      nginx -s stop >/dev/null
    fi
  fi
  current_path=$(pwd)
  install_path=$1
  download_url=$2
  file_name=$3
  base_file_name=$(basename ${download_url})
  if [[ ${download_url} =~ ^http.* ]]; then
    curl -o ${base_file_name} ${download_url}
  fi
  rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
  tar -zxvf ${base_file_name} -C ${install_path}
  cd ${install_path}/${file_name}
  ./configure --prefix=${install_path}/${file_name}/bin --sbin-path=nginx --conf-path=${install_path}/${file_name}/bin/conf/nginx.conf --pid-path=${install_path}/${file_name}/bin/logs/nginx.pid
  cd src
  make distclean
  make && make install
  cd ${current_path}
  if test -r /usr/local/bin/nginx; then
    result=$(ps -ef | grep nginx | grep -v grep)
    if [[ ${result} =~ "00:00:00 nginx" ]]; then
      nginx -s stop
    fi
  fi
  rm -rf /usr/local/bin/nginx
  ln -fs ${install_path}/${file_name}/bin/nginx /usr/local/bin/nginx
  rm -rf ${install_path}/${file_name}/bin/nginx.service && touch ${install_path}/${file_name}/bin/nginx.service
  cat >${install_path}/${file_name}/bin/nginx.service <<EOF
#!/bin/sh
# chkconfig: - 85 15
# description: Nginx is a World Wide Web server. It is used to serve.
# author: godcheese [godcheese@outlook.com]
bin_path=
if test -z "\${bin_path}" ; then
    bin_path="/usr/local/bin/nginx"
fi
if ! test -r "\${bin_path}" ; then
    echo "Nginx not found:\${bin_path}"
    exit 0
fi
case "\$1" in
    "status")
        result=\$(ps -ef | grep nginx | grep -v grep)
        if [[ \${result} =~ "00:00:00 nginx" ]]; then
            echo "Nginx is running."
        else
            echo "Nginx is not running."
        fi
        ;;
    "start")
        result=\$(ps -ef | grep nginx | grep -v grep)
        if [[ \${result} =~ "00:00:00 nginx" ]]; then
            echo "Nginx is running."
        else
            echo "Starting nginx..."
            "\${bin_path}"
            echo "Nginx start successful."
        fi
        ;;
    "stop")
        result=\$(ps -ef | grep nginx | grep -v grep)
        if [[ \${result} =~ "00:00:00 nginx" ]]; then
            echo "Stopping nginx..."
            "\${bin_path}" -s stop
            echo "Nginx stop successful."
        else
            echo "Nginx is not running."
        fi
        ;;
    "restart")
        result=\$(ps -ef | grep nginx | grep -v grep)
        echo "Restarting nginx..."
        if [[ \${result} =~ "00:00:00 nginx" ]]; then
            "\${bin_path}" -s reload
        else
            "\${bin_path}"
            "\${bin_path}" -s reload
        fi
        echo "Nginx restart successful."
        ;;
    "test")
        echo "Testing nginx conf..."
        "\${bin_path}" -t
        echo "Nginx conf test successful."
        ;;
esac
EOF

  rm -rf /etc/init.d/nginx
  \cp -rf ${install_path}/${file_name}/bin/nginx.service /etc/init.d/nginx
  chmod 755 /etc/init.d/nginx
  if [[ "${release_id}"x != "ubuntu"x ]]; then
    chkconfig --add nginx && chkconfig nginx on
  fi
  sed -i "/# Made for Nginx/d" /etc/profile
  sed -i "/NGINX_HOME/d" /etc/profile
  echo "# Made for Nginx env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export NGINX_HOME=\"${install_path}/${file_name}\"" >>/etc/profile
  echo "export PATH=\"\${NGINX_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -4 /etc/profile)
  echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
  service nginx restart
  version=$(nginx -v 2>&1)
  if [[ ! $? == 0 ]]; then
    echo -e "\033[31m
        Nginx 安装失败！
        \033[0m"
    exit 0
  else
    firewall-cmd --zone=public --add-service=http --permanent >/dev/null 2>&1
    firewall-cmd --zone=public --add-service=https --permanent >/dev/null 2>&1
    firewall-cmd --zone=public --add-port=80/tcp --permanent >/dev/null 2>&1
    firewall-cmd --zone=public --add-port=443/tcp --permanent >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
    echo -e "\033[32m
        Nginx 安装成功！
        \033[0m"
    echo -e "\033[32m
        - Nginx 版本：${version}
        - Nginx 安装路径：${install_path}/${file_name}/bin
        - Nginx 配置文件路径：${install_path}/${file_name}/bin/conf/nginx.conf
        - Nginx 日志文件路径：${install_path}/${file_name}/bin/conf/nginx.conf
        - Nginx 常用命令：
          状态：service nginx status
          启动：service nginx start
          停止：service nginx stop
          重启：service nginx restart
          测试配置：service nginx test
        \033[0m"
    exit 0
  fi
}

# install maven
function install_maven() {
  install_path=$1
  download_url=$2
  file_name=$3
  base_file_name=$(basename ${download_url})
  if [[ ${download_url} =~ ^http.* ]]; then
    curl -o ${base_file_name} ${download_url}
  fi
  rm -rf ${install_path}/${file_name} && mkdir -p ${install_path}
  tar -zxvf ${base_file_name} -C ${install_path}
  rm -rf /usr/local/bin/mvn
  ln -fs ${install_path}/${file_name}/bin/mvn /usr/local/bin/mvn
  sed -i "/# Made for Maven/d" /etc/profile
  sed -i "/MAVEN_HOME/d" /etc/profile
  echo "# Made for Maven env by godcheese [godcheese@outlook.com] on $(date +%F)" >>/etc/profile
  echo "export MAVEN_HOME=\"${install_path}/${file_name}\"" >>/etc/profile
  echo "export PATH=\"\${MAVEN_HOME}/bin:\${PATH}\"" >>/etc/profile
  source /etc/profile
  profile=$(tail -4 /etc/profile)
  echo -e "\033[32m
    写入 /etc/profile 的环境变量内容：
    ${profile}
    \033[0m"
  version=$(mvn --version 2>&1)
  if [[ ! $? == 0 ]]; then
    echo -e "\033[31m
        Maven 安装失败！
        \033[0m"
    exit 0
  else
    echo -e "\033[32m
        Maven 安装成功！
        \033[0m"
    echo -e "\033[32m
        - Maven 版本：${version}
        - Maven 安装路径：${install_path}/${file_name}
        \033[0m"
    exit 0
  fi
}

# show banner
function show_banner() {
  echo -e "\033[32m
    -------------------------------------------------
    | Install for CentOS                            |
    | http://github.com/godcheese/shell_bag         |
    | author: godcheese [godcheese@outlook.com]     |
    -------------------------------------------------
    \033[0m"
}

show_banner
case "$1" in
"install")
  install_nginx $2 $3 $4
  ;;
"uninstall")
  uninstall_nginx $2 $3 $4
  ;;
*)
  echo "请输入正确的命令"
  exit 0
  ;;
esac
