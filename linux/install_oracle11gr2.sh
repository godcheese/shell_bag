#!/usr/bin/env bash
# encoding: utf-8

# http://github.com/godcheese/shell_bag
# author: godcheese [godcheese@outlook.com]
# description: Install Oracle 11g R2 (Oracle Database 11g Enterprise Edition Release 11.2.0.1.0 - 64bit Production)

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
    echo_error "\nUnsupported system."
    ;;
  "ubuntu")
    release_name="Ubuntu"
    release_full_version="${release_version}"
    release_version=$(echo "${release_version}" | awk -F '.' '{print $1}')
    echo_error "\nUnsupported system."
    ;;
  *)
    echo_error "\nUnsupported system."
    exit 0
    ;;
  esac
}
check_system

# install_oracle11g_r2
function install_oracle11g_r2() {

  yum update -y
  yum install -y wget unzip net-tools expect

  # 使用 oracle 提供的环境配置工具
  # 这个工具会调整内核参数，建立一些必要的 linux 用户和组
  # 可能网络不好会安装不成功，多 install 一下
  wget http://public-yum.oracle.com/public-yum-ol7.repo -O /etc/yum.repos.d/public-yum-ol7.repo
  wget http://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol7 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle

  yum install -y oracle-rdbms-server-11gR2-preinstall

  # 完成后备份一下这个目录的文件到其他目录
  # 这个文件夹是修改系统后日志和原本的内核配置备份
  # /var/log/oracle-rdbms-server-11gR2-preinstall

  # 加载内核参数 和 sysctl -p 一样
  sysctl -f

  # 创建一些目录和配置
  # 配置 oracle 系统配置文件和授权
  rm -rf /etc/oraInst.loc
  cat >>/etc/oraInst.loc <<EOF
inventory_loc=/home/oracle/ora11g/oraInventory
inst_group=oinstall
EOF
  chmod 664 /etc/oraInst.loc

  # 创建oracle安装的目录&授权
  rm -rf /u01/app/
  rm -rf /u01/tmp
  mkdir -p /u01/app/
  mkdir /u01/tmp
  chown -R oracle:oinstall /u01/app/
  chmod -R 775 /u01/app/
  chmod a+wr /u01/tmp

  # 设置oracle用户密码 oracle是安装工具自己创建的,参考我之前讲的，比如：123456
  #  passwd oracle
  echo "123456" | passwd --stdin "oracle"

  sed -i "/^TMP=/u01/tmp/d" /home/oracle/.bash_profile
  sed -i "/^TMPDIR=/u01/tmp/d" /home/oracle/.bash_profile
  sed -i "/^export TMP TMPDIR/d" /home/oracle/.bash_profile
  sed -i "/^ORACLE_BASE=/u01/app/oracle/d" /home/oracle/.bash_profile
  sed -i "/^ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1/d" /home/oracle/.bash_profile
  sed -i "/^ORACLE_SID=orcl/d" /home/oracle/.bash_profile
  sed -i "/^ORACLE_HOME_LISTNER=\$ORACLE_HOME/d" /home/oracle/.bash_profile
  sed -i "/^PATH=\$ORACLE_HOME/bin:\$PATH/d" /home/oracle/.bash_profile
  sed -i "/^PATH=export ORACLE_BASE ORACLE_SID ORACLE_HOME ORACLE_HOME_LISTNER PATH/d" /home/oracle/.bash_profile

  # 为oracle用户添加一些必要的环境
  cat >>/home/oracle/.bash_profile <<EOF
TMP=/u01/tmp
TMPDIR=/u01/tmp
export TMP TMPDIR

ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
ORACLE_SID=orcl
ORACLE_HOME_LISTNER=$ORACLE_HOME
PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_BASE ORACLE_SID ORACLE_HOME ORACLE_HOME_LISTNER PATH
EOF
  # 生效
  source /oracle/home/.bash_profile

  # linux.x64_11gR2_database_2of2.zip
  # linux.x64_11gR2_database_1of2.zip 上传至/home/oracle/
  # 解压 解压后文件会在 /home/oracle/database/
  rm -rf /home/oracle/database
  unzip linux.x64_11gR2_database_1of2.zip -d /home/oracle
  unzip linux.x64_11gR2_database_2of2.zip -d /home/oracle

  # 由于某些原因文件权限问题 运行这个命令(选)
  chown -R oracle:oinstall /home/oracle/database

  # 备份到/home/oracle/rsp/
  rm -rf /home/oracle/rsp
  \cp -rf /home/oracle/database/response /home/oracle/rsp

  # 配置安装响应文件db_install.rsp文件 这里配置参数先下载到本地 用记事本根据自己情况修改 在上传过去
  # 我的/home/oracle/rsp/db_install.rsp
  # oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
  # sed -i 's@^oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0@oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0@' "/home/oracle/rsp/db_install.rsp"
  # INSTALL_DB_AND_CONFIG 安装并自动配置数据库实例和监听 建议首次安装用这个
  # 不然配置另外两个文件，新建实例和监听
  # oracle.install.option=INSTALL_DB_AND_CONFIG
  sed -i 's@^oracle.install.option=@oracle.install.option=INSTALL_DB_AND_CONFIG@' "/home/oracle/rsp/db_install.rsp"
  # ORACLE_HOSTNAME=localhost
  sed -i 's@^ORACLE_HOSTNAME=@ORACLE_HOSTNAME=localhost@' "/home/oracle/rsp/db_install.rsp"
  # UNIX_GROUP_NAME=oinstall
  sed -i 's@^UNIX_GROUP_NAME=@UNIX_GROUP_NAME=oinstall@' "/home/oracle/rsp/db_install.rsp"
  # INVENTORY_LOCATION=/home/oracle/ora11g/oraInventory
  sed -i 's@^INVENTORY_LOCATION=@INVENTORY_LOCATION=/home/oracle/ora11g/oraInventory@' "/home/oracle/rsp/db_install.rsp"
  # SELECTED_LANGUAGES=zh_CN,en
  sed -i 's@^SELECTED_LANGUAGES=@SELECTED_LANGUAGES=zh_CN,en@' "/home/oracle/rsp/db_install.rsp"
  # ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
  sed -i 's@^ORACLE_HOME=@ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1@' "/home/oracle/rsp/db_install.rsp"
  # ORACLE_BASE=/u01/app/oracle
  sed -i 's@^ORACLE_BASE=@ORACLE_BASE=/u01/app/oracle@' "/home/oracle/rsp/db_install.rsp"
  # oracle.install.db.InstallEdition=EE
  sed -i 's@^oracle.install.db.InstallEdition=@oracle.install.db.InstallEdition=EE@' "/home/oracle/rsp/db_install.rsp"
  # oracle.install.db.isCustomInstall=true
  sed -i 's@^oracle.install.db.isCustomInstall=false@oracle.install.db.isCustomInstall=true@' "/home/oracle/rsp/db_install.rsp"
  # oracle.install.db.customComponents=oracle.server:11.2.0.1.0,oracle.sysman.ccr:10.2.7.0.0,oracle.xdk:11.2.0.1.0,oracle.rdbms.oci:11.2.0.1.0,oracle.network:11.2.0.1.0,oracle.network.listener:11.2.0.1.0,oracle.rdbms:11.2.0.1.0,oracle.options:11.2.0.1.0,oracle.rdbms.partitioning:11.2.0.1.0,oracle.oraolap:11.2.0.1.0,oracle.rdbms.dm:11.2.0.1.0,oracle.rdbms.dv:11.2.0.1.0,orcle.rdbms.lbac:11.2.0.1.0,oracle.rdbms.rat:11.2.0.1.0
  #  sed -i 's@^ORACLE_HOSTNAME=@ORACLE_HOSTNAME=localhost@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.DBA_GROUP=dba
  sed -i 's@^oracle.install.db.DBA_GROUP=@oracle.install.db.DBA_GROUP=dba@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.OPER_GROUP=oinstall
  sed -i 's@^oracle.install.db.OPER_GROUP=@oracle.install.db.OPER_GROUP=oinstall@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.config.starterdb.type=GENERAL_PURPOSE
  sed -i 's@^oracle.install.db.config.starterdb.type=@oracle.install.db.config.starterdb.type=GENERAL_PURPOSE@' "/home/oracle/rsp/db_install.rsp"
  # 这个是服务名
  #  oracle.install.db.config.starterdb.globalDBName=orcl.lan
  sed -i 's@^oracle.install.db.config.starterdb.globalDBName=@oracle.install.db.config.starterdb.globalDBName=orcl.lan@' "/home/oracle/rsp/db_install.rsp"
  # 实例sid
  #  oracle.install.db.config.starterdb.SID=orcl
  sed -i 's@^oracle.install.db.config.starterdb.SID=@oracle.install.db.config.starterdb.SID=orcl@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.config.starterdb.characterSet=AL32UTF8
  #  sed -i 's@^oracle.install.db.config.starterdb.characterSet=AL32UTF8@oracle.install.db.config.starterdb.characterSet=AL32UTF8@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.config.starterdb.memoryOption=true
  sed -i 's@^oracle.install.db.config.starterdb.memoryOption=true@oracle.install.db.config.starterdb.memoryOption=true@' "/home/oracle/rsp/db_install.rsp"
  # 最小256M 我是学习就选择最小了
  #  oracle.install.db.config.starterdb.memoryLimit=256
  sed -i 's@^oracle.install.db.config.starterdb.memoryLimit=@oracle.install.db.config.starterdb.memoryLimit=256@' "/home/oracle/rsp/db_install.rsp"
  # 是否安装学习的scott和hr(我就知道这两个)
  #  oracle.install.db.config.starterdb.installExampleSchemas=false
  #  sed -i 's@^oracle.install.db.config.starterdb.installExampleSchemas=false@oracle.install.db.config.starterdb.installExampleSchemas=false@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.config.starterdb.enableSecuritySettings=true
  #  sed -i 's@^oracle.install.db.config.starterdb.enableSecuritySettings=true@oracle.install.db.config.starterdb.enableSecuritySettings=true@' "/home/oracle/rsp/db_install.rsp"
  # 密码全设置成123456 (安装时会提示，个人学习忽略)
  #  oracle.install.db.config.starterdb.password.ALL=123456
  sed -i 's@^oracle.install.db.config.starterdb.password.ALL=@oracle.install.db.config.starterdb.password.ALL=123456@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.config.starterdb.control=DB_CONTROL
  #  sed -i 's@^oracle.install.db.config.starterdb.control=DB_CONTROL@oracle.install.db.config.starterdb.control=DB_CONTROL@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=false
  #  sed -i 's@^oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=false@oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=false@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.config.starterdb.automatedBackup.enable=false
  sed -i 's@^oracle.install.db.config.starterdb.automatedBackup.enable=false@oracle.install.db.config.starterdb.automatedBackup.enable=false@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE
  sed -i 's@^oracle.install.db.config.starterdb.storageType=@oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE@' "/home/oracle/rsp/db_install.rsp"
  #  oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=/u01/app/oracle/oradata
  sed -i 's@^oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=@oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=/u01/app/oracle/oradata@' "/home/oracle/rsp/db_install.rsp"
  # true
  #  DECLINE_SECURITY_UPDATES=true
  sed -i 's@^DECLINE_SECURITY_UPDATES=@DECLINE_SECURITY_UPDATES=true@' "/home/oracle/rsp/db_install.rsp"
  # 修改完成保存上传到 /home/oracle/rsp

  # 防火墙 放行 1521 端口（防火墙很可能开着的）
  # ORA-12541: TNS:no listener 报错请先检查防火墙是否开启或放行端口
  firewall-cmd --zone=public --add-port=1521/tcp --permanent
  # 重新加载防火墙规则
  firewall-cmd --reload

  # 切换成 oracle 用户
  #  su oracle

  su - oracle <<EOF
pwd
echo "123456"
EOF


  su - oracle -c "/home/oracle/database/runInstaller -silent -ignorePrereq -responseFile /home/oracle/rsp/db_install.rsp;pwd"

# 判断是否安装完毕的最好方法是去循环定时读取安装日志里，是否有安装完毕的信息，安装完毕则继续执行以下脚本

  # 安装
  # 会出现密码不规范的警告，忽略
  #  /home/oracle/database/runInstaller -silent -ignorePrereq -responseFile /home/oracle/rsp/db_install.rsp

  # 查看安装过程 另开一个shell 稍等
  #tail -f /home/oracle/ora11g/oraInventory/logs/installActions2017-09-24_12-26-49PM.log

  # 运行 oracle 安装目录下的 root.sh 文件，生成 /etc/oratab 文件
  bash $ORACLE_HOME/root.sh

  # 修改oracle服务启动配置
  #  vi /etc/oratab
  # 修改了/etc/oratab N->Y 所以启动服务也会同时启动实例
  # N的情况不会同时启动实例 sqlplus登录会提示 an idle instance
  # 用sqlplus 然后---> startup启动实例
  # 重启系统后用这个命令启动
  #  将
  #  orcl:/u01/app/oracle/product/11.2.0/dbhome_1:N
  #  改成
  #  orcl:/u01/app/oracle/product/11.2.0/dbhome_1:Y
  #  :wq!保存
  sed -i 's@^orcl:/u01/app/oracle/product/11.2.0/dbhome_1:N@orcl:/u01/app/oracle/product/11.2.0/dbhome_1:Y@' /etc/oratab

  # oracle 自带数据库命令行工具
  rm -rf /usr/bin/sqlplus
  ln -s $ORACLE_HOME/bin/sqlplus /usr/bin/sqlplus

  rm -rf /usr/bin/dbstart
  # 启动 oracle 数据库及实例 dbstart $ORACLE_HOME
  ln -s $ORACLE_HOME/bin/dbstart /usr/bin/dbstart

  rm -rf /usr/bin/dbshut
  # 关闭 oracle 数据库及实例 dbshut $ORACLE_HOME
  ln -s $ORACLE_HOME/bin/dbshut /usr/bin/dbshut

  rm -rf /usr/bin/lsnrctl
  # 启动监听器 lsnrctl start / lsnrctl stop / lsnrctl status
  ln -s $ORACLE_HOME/bin/lsnrctl /usr/bin/lsnrctl

  #  # 切换为 root 用户
  #  expect -c "
  #  spawn su root
  #  expect \"Password:\"
  #  send \""${root_password}"\r\"
  #  interact"
  #
  #  yum uninstall -y expect

  # 启动 oracle # 关闭实例：dbshut $ORACLE_HOME
  # dbstart dbshut 运行时报 ORACLE_HOME_LISTNER is not SET, unable to auto-start Oracle Net Listener 错误解决方法（也可忽略，手动运行 lsnrctl start 启动监听器）：
  # vi $ORACLE_HOME/bin/dbstart
  # 将 ORACLE_HOME_LISTNER=$1 替换成 ORACLE_HOME_LISTNER=$ORACLE_HOME
  # vi $ORACLE_HOME/bin/dbshut
  # 将 ORACLE_HOME_LISTNER=$1 替换成 ORACLE_HOME_LISTNER=$ORACLE_HOME
  dbstart $ORACLE_HOME

  # 启动监听器 关闭监听器：lsnrctl stop 查看监听器状态：lsnrctl status
  lsnrctl start

}

# sqlplus sysdba 登录
#sqlplus / as sysdba

# 查看状态
#select status from v$instance;

# 启动实例 立即关闭实例：shutdown immediate
#startup

# 退出 sqlplus
#exit

# 切换 root 用户
#su root

# 查看 1521 端口
#netstat -an|grep 1521

# 查看 oracle 进程
#ps -ef|grep ora_|grep -v grep

# 查看 oracle 的监听进程
#ps -ef|grep tnslsnr|grep -v grep

# 防火墙 放行 1521 端口（防火墙很可能开着的）
# ORA-12541: TNS:no listener 报错请先检查防火墙是否开启或放行端口
#firewall-cmd --zone=public --add-port=1521/tcp --permanent
# 重新加载防火墙规则
#firewall-cmd --reload

# 远程连接oracle
#sqlplus sys/oracle@192.168.100.131:1521/ORCL.LAN as sysdba
#conn sys/oracle@192.168.100.131:1521/ORCL.LAN as sysdba

# 用户 oracle/123456
# sid：orcl
# 服务名（Service Name）：orcl.lan

# service name: orcl.lan
# or sid: orcl
# port: 1521
# as sysdba
# username: sys
# password: 123456

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
  install_oracle11g_r2 "$2" "$3" "$4"
  ;;
"uninstall")
  install_oracle11g_r2 "$2" "$3" "$4"
  ;;
*)
  echo_error "\n请输入正确的命令"
  exit 1
  ;;
esac
