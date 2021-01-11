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
    echo_error "\n${release_name} ${release_version}\nUnsupported system."
    exit 0
    ;;
  "ubuntu")
    release_name="Ubuntu"
    release_full_version="${release_version}"
    release_version=$(echo "${release_version}" | awk -F '.' '{print $1}')
    echo_error "\n${release_name} ${release_version}\nUnsupported system."
    exit 0
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
  # 系统 oracle 用户的密码
  oracle_user_password=123456
  # sid
  oracle_sid=orcl
  # 服务名
  oracle_service_name=orcl.lan
  oracle_port=1521
  # oracle 数据库全局密码，sys、system、sysdba 都用此密码
  oracle_password=123456
  # oracle 实例数据存储目录
  oracle_data=/u01/app/oracle/oradata
  oracle_base=/u01/app/oracle
  oracle_home=/u01/app/oracle/product/11.2.0/dbhome_1
  oracle_install_response_dir=/home/oracle/response
  ora_inst_path=/etc/oraInst.loc
  ora_inventory_path=/home/oracle/ora11g/oraInventory
  app_dir=/u01/app
  tmp_dir=/u01/tmp
  bash_profile=/home/oracle/.bash_profile
  # 安装文件解压到目录
  unzip_dir=/home/oracle
  # 单位：MB，最小 256MB，8G及以下系统建议 256MB
  oracle_memory_limit=256
  override_install=$2

  echo_info "\nInstalling Oracle 11g R2..."
  if [ "${release_id}"x == "centos"x ]; then
    yum update -y
    yum install -y wget unzip net-tools
    # 使用 oracle 提供的环境配置工具，这个工具会调整内核参数，自动创建一些必要的 linux 用户和组，比如用户组 oinstall 和用户 oracle
    wget http://public-yum.oracle.com/public-yum-ol7.repo -O /etc/yum.repos.d/public-yum-ol7.repo
    wget http://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol7 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
    yum install -y oracle-rdbms-server-11gR2-preinstall
    # 完成后备份一下这个目录（/var/log/oracle-rdbms-server-11gR2-preinstall）的文件到其它目录，这个目录是修改系统后日志和原本的内核配置备份
    # 加载内核参数和 sysctl -p 效果一样
    sysctl -f
  fi

  # 创建一些必要的目录和配置，配置 oracle 系统配置文件和授权
  rm -rf "${ora_inst_path}"
  cat >>"${ora_inst_path}" <<EOF
inventory_loc=${ora_inventory_path}
inst_group=oinstall
EOF
  chmod 664 "${ora_inst_path}"

  # 创建 oracle 安装的目录和授权
  rm -rf "${app_dir}"
  rm -rf "${tmp_dir}"
  mkdir -p "${app_dir}"
  mkdir "${tmp_dir}"
  chown -R oracle:oinstall "${app_dir}"
  chmod -R 775 "${app_dir}"
  chmod a+wr "${tmp_dir}"

  # 设置系统 oracle 用户密码，oracle 是安装工具自己创建的用户
  echo "${oracle_user_password}" | passwd --stdin "oracle"

  sed -i "/^TMP=\/u01\/tmp/d" "${bash_profile}"
  sed -i "/^TMPDIR=\/u01\/tmp/d" "${bash_profile}"
  sed -i "/^export TMP TMPDIR/d" "${bash_profile}"
  sed -i "/^ORACLE_BASE=\/u01\/app\/oracle/d" "${bash_profile}"
  sed -i "/^ORACLE_HOME=\/u01\/app\/oracle\/product\/11.2.0\/dbhome_1/d" "${bash_profile}"
  sed -i "/^ORACLE_SID=orcl/d" "${bash_profile}"
  sed -i "/^ORACLE_HOME_LISTNER=\$ORACLE_HOME/d" "${bash_profile}"
  sed -i "/^PATH\=\$ORACLE_HOME\/bin:\$PATH/d" "${bash_profile}"
  sed -i "/^PATH=export ORACLE_BASE ORACLE_SID ORACLE_HOME ORACLE_HOME_LISTNER PATH/d" "${bash_profile}"

  # 为oracle用户添加一些必要的环境
  cat >>"${bash_profile}" <<EOF
TMP=${tmp_dir}
TMPDIR=${tmp_dir}
export TMP TMPDIR
ORACLE_BASE=${oracle_base}
ORACLE_HOME=${oracle_home}
ORACLE_SID=${oracle_sid}
ORACLE_HOME_LISTNER=${oracle_home}
PATH=\${ORACLE_HOME}/bin:$PATH
export ORACLE_BASE ORACLE_SID ORACLE_HOME ORACLE_HOME_LISTNER PATH
EOF
  # 生效
  source "${bash_profile}"

  # linux.x64_11gR2_database_2of2.zip
  # linux.x64_11gR2_database_1of2.zip
  # 解压 解压后文件会在 ${unzip_dir}/database
  rm -rf "${unzip_dir}/database"
  unzip linux.x64_11gR2_database_1of2.zip -d "${unzip_dir}"
  unzip linux.x64_11gR2_database_2of2.zip -d "${unzip_dir}"

  # 由于某些原因文件权限问题 运行这个命令(选)
  chown -R oracle:oinstall "${unzip_dir}/database"

  # 拷贝到 /home/oracle/response，用于安装使用
  rm -rf "${oracle_install_response_dir}"
  \cp -rf "${unzip_dir}/database/response" "${oracle_install_response_dir}"

  # oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v11_2_0
  # 此处设置 INSTALL_DB_AND_CONFIG 安装并自动配置数据库实例和监听，建议首次安装用这个，不然配置另外两个文件，新建实例和监听
  sed -i 's@^oracle.install.option=@oracle.install.option=INSTALL_DB_AND_CONFIG@' "${oracle_install_response_dir}/db_install.rsp"
  sed -i 's@^ORACLE_HOSTNAME=@ORACLE_HOSTNAME=localhost@' "${oracle_install_response_dir}/db_install.rsp"
  sed -i 's@^UNIX_GROUP_NAME=@UNIX_GROUP_NAME=oinstall@' "${oracle_install_response_dir}/db_install.rsp"
  sed -i 's@^INVENTORY_LOCATION=@INVENTORY_LOCATION='"${ora_inventory_path}"'@' "${oracle_install_response_dir}/db_install.rsp"
  # zh_CN,en
  sed -i 's@^SELECTED_LANGUAGES=@SELECTED_LANGUAGES=zh_CN,en@' "${oracle_install_response_dir}/db_install.rsp"
  sed -i 's@^ORACLE_HOME=@ORACLE_HOME='"${oracle_home}"'@' "${oracle_install_response_dir}/db_install.rsp"
  sed -i 's@^ORACLE_BASE=@ORACLE_BASE='"${oracle_base}"'@' "${oracle_install_response_dir}/db_install.rsp"
  # EE 企业版
  sed -i 's@^oracle.install.db.InstallEdition=@oracle.install.db.InstallEdition=EE@' "${oracle_install_response_dir}/db_install.rsp"
  sed -i 's@^oracle.install.db.isCustomInstall=false@oracle.install.db.isCustomInstall=true@' "${oracle_install_response_dir}/db_install.rsp"
  #   oracle.install.db.customComponents=oracle.server:11.2.0.1.0,oracle.sysman.ccr:10.2.7.0.0,oracle.xdk:11.2.0.1.0,oracle.rdbms.oci:11.2.0.1.0,oracle.network:11.2.0.1.0,oracle.network.listener:11.2.0.1.0,oracle.rdbms:11.2.0.1.0,oracle.options:11.2.0.1.0,oracle.rdbms.partitioning:11.2.0.1.0,oracle.oraolap:11.2.0.1.0,oracle.rdbms.dm:11.2.0.1.0,oracle.rdbms.dv:11.2.0.1.0,orcle.rdbms.lbac:11.2.0.1.0,oracle.rdbms.rat:11.2.0.1.0
  sed -i 's@^oracle.install.db.DBA_GROUP=@oracle.install.db.DBA_GROUP=dba@' "${oracle_install_response_dir}/db_install.rsp"
  sed -i 's@^oracle.install.db.OPER_GROUP=@oracle.install.db.OPER_GROUP=oinstall@' "${oracle_install_response_dir}/db_install.rsp"
  sed -i 's@^oracle.install.db.config.starterdb.type=@oracle.install.db.config.starterdb.type=GENERAL_PURPOSE@' "${oracle_install_response_dir}/db_install.rsp"
  # 服务名 service name
  sed -i 's@^oracle.install.db.config.starterdb.globalDBName=@oracle.install.db.config.starterdb.globalDBName='"${oracle_service_name}"'@' "${oracle_install_response_dir}/db_install.rsp"
  # 实例 sid
  sed -i 's@^oracle.install.db.config.starterdb.SID=@oracle.install.db.config.starterdb.SID='"${oracle_sid}"'@' "${oracle_install_response_dir}/db_install.rsp"
  # oracle.install.db.config.starterdb.characterSet=AL32UTF8
  # oracle.install.db.config.starterdb.memoryOption=true
  # 单位：MB，最小 256MB，8G及以下系统建议 256MB
  sed -i 's@^oracle.install.db.config.starterdb.memoryLimit=@oracle.install.db.config.starterdb.memoryLimit='"${oracle_memory_limit}"'@' "${oracle_install_response_dir}/db_install.rsp"
  # 是否安装示例配置（ExampleSchemas），包含了 scott 和 hr 两个用户，生产环境不建议安装
  # oracle.install.db.config.starterdb.installExampleSchemas=false
  # oracle.install.db.config.starterdb.enableSecuritySettings=true
  # oracle 数据库全局密码，sys、system、sysdba 都用此密码
  sed -i 's@^oracle.install.db.config.starterdb.password.ALL=@oracle.install.db.config.starterdb.password.ALL='"${oracle_password}"'@' "${oracle_install_response_dir}/db_install.rsp"
  # oracle.install.db.config.starterdb.control=DB_CONTROL
  # oracle.install.db.config.starterdb.dbcontrol.enableEmailNotification=false
  # oracle.install.db.config.starterdb.dbcontrol.emailAddress=
  # oracle.install.db.config.starterdb.dbcontrol.SMTPServer=
  # oracle.install.db.config.starterdb.automatedBackup.enable=false
  # oracle.install.db.config.starterdb.automatedBackup.osuid=oracle
  # oracle.install.db.config.starterdb.automatedBackup.ospwd=123456
  sed -i 's@^oracle.install.db.config.starterdb.storageType=@oracle.install.db.config.starterdb.storageType=FILE_SYSTEM_STORAGE@' "${oracle_install_response_dir}/db_install.rsp"
  sed -i 's@^oracle.install.db.config.starterdb.fileSystemStorage.dataLocation=@oracle.install.db.config.starterdb.fileSystemStorage.dataLocation='"${oracle_data}"'@' "${oracle_install_response_dir}/db_install.rsp"
  # 忽略安全更新，建议 true
  sed -i 's@^DECLINE_SECURITY_UPDATES=@DECLINE_SECURITY_UPDATES=true@' "${oracle_install_response_dir}/db_install.rsp"

  oracle_install_log_path=/tmp/oracle_install.log
  #  su - oracle -c "/home/oracle/database/runInstaller -force -silent -noconfig -responseFile /home/oracle/response/db_install.rsp -ignorePrereq" 1>${oracle_out}
  su - oracle -c "/home/oracle/database/runInstaller -force -silent -responseFile /home/oracle/response/db_install.rsp -ignorePrereq" 1>"${oracle_install_log_path}"
  echo_info "\nOracle installer is running...Please wait a few minutes and do not do anything."
  i=0
  while true; do
    echo -en "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"$(echo "Processing progress: $i")
    ((i++))
    grep -E "\[FATAL\]" ${oracle_install_log_path} &>/dev/null
    if [ "$?" == 0 ]; then
      echo_error "\nOracle start install has error:\n $(cat "${oracle_install_log_path}" | grep -E "\[FATAL\]")"
      exit 1
    fi
    cat "${oracle_install_log_path}" | grep "Successfully Setup Software." &>/dev/null
    if [ "$?" == 0 ]; then
      echo_info "\nOracle installer run completed.And something else to do ..."
      break
    fi
  done
  # 运行 oracle 安装目录下的 root.sh 文件，生成 /etc/oratab 文件
  sh "${oracle_home}/root.sh" 1>"${oracle_install_log_path}"
  while true; do
    cat "${oracle_install_log_path}" | grep "for the output of root script" &>/dev/null
    if [ "$?" == 0 ]; then
      break
    fi
  done
  rm -rf "${oracle_install_log_path}"

  # 修改了/etc/oratab 改 N 为 Y ，启动服务时也会同时启动实例
  sed -i 's@^'"${oracle_sid}"':'"${oracle_home}"':N@'"${oracle_sid}"':'"${oracle_home}"':Y@' /etc/oratab
  rm -rf /usr/bin/dbstart
  rm -rf /usr/bin/dbshut
  rm -rf /usr/bin/lsnrctl
  rm -rf /usr/bin/sqlplus

  # 启动 oracle 数据库及实例 dbstart $ORACLE_HOME
  ln -s "${oracle_home}/bin/dbstart" /usr/bin/dbstart
  # 关闭 oracle 数据库及实例 dbshut $ORACLE_HOME
  ln -s "${oracle_home}/bin/dbshut" /usr/bin/dbshut
  # 启动监听器 lsnrctl start / lsnrctl stop / lsnrctl status
  ln -s "${oracle_home}/bin/lsnrctl" /usr/bin/lsnrctl
  # oracle 自带数据库命令行工具
  ln -s "${oracle_home}/bin/sqlplus" /usr/bin/sqlplus
  su - oracle -c "dbstart ${oracle_home}"
  cat "${oracle_home}/startup.log" | awk 'END {print}' | grep "warm started." &>/dev/null
  if [ "$?" != 0 ]; then
    echo_error "/nThere is something wrong with Oracle startup."
    exit 0
  fi
  su - oracle -c "dbstart ${oracle_home}"
  version=$(su - oracle -c "sqlplus -S '/ as sysdba' <<EOF
  set pagesize 0 feedback off verify off heading off echo off;
  select * from v\\\$version;
  exit;
  EOF"
  )
  echo $version
  if [ "$?" != 0 ]; then
    show_banner
    echo_error "\nOracle 11g R2 安装失败！"
    exit 0
  else
    # 防火墙 放行 1521 端口（防火墙很可能开着的）
    # ORA-12541: TNS:no listener 报错请先检查防火墙是否开启或放行端口
    firewall-cmd --zone=public --add-port="${oracle_port}"/tcp --permanent >/dev/null 2>&1
    # 重新加载防火墙规则
    firewall-cmd --reload >/dev/null 2>&1
    #  firewall-cmd --list-all-zones
    show_banner
    echo_info "\nOracle 11g R2 安装成功！
- 系统 oracle 用户密码：${oracle_user_password}
- Oracle 版本：${version}
- Oracle 安装路径：${oracle_home}
- Oracle 数据保存路径：${oracle_data}
- Oracle 启动日志：${oracle_home}/startup.log
- Oracle 端口：${oracle_port}
- 全局密码：${oracle_password}
- Oracle 常用命令（需切换成系统 oracle 用户执行）：
  启动：dbstart \${ORACLE_HOME}
  停止：dbshut \${ORACLE_HOME}
  监听器状态：lsnrctl status
  启动监听器：lsnrctl start
  停止监听器：lsnrctl stop
- 其它：
  远程连接方式：
  sqlplus sys/password@ip:port/orcl.lan as sysdba
  conn sys/password@ip:port/orcl.lan as sysdba
  查看实例状态：
  sqlplus 中执行 select status from v\$instance;
  sqlplus 中启动实例执行 startup
  sqlplus 中关闭实例执行 shutdown immediate
  查看 1521 端口：
  netstat -an|grep 1521
  查看 oracle 进程
  ps -ef|grep ora_|grep -v grep
  查看 oracle 的监听进程
  ps -ef|grep tnslsnr|grep -v grep
  dbstart dbshut 运行时报 ORACLE_HOME_LISTNER is not SET, unable to auto-start Oracle Net Listener 错误解决方法（也可忽略，手动运行 lsnrctl start 启动监听器）：
  sed -i 's@^ORACLE_HOME_LISTNER=\$1=@ORACLE_HOME_LISTNER=\$ORACLE_HOME@' \"\$ORACLE_HOME/bin/dbstart\"
  sed -i 's@^ORACLE_HOME_LISTNER=\$1=@ORACLE_HOME_LISTNER=\$ORACLE_HOME@' \"\$ORACLE_HOME/bin/dbshut\"
  "
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
  install_oracle11g_r2 "$2" "$3" "$4" "$5"
  ;;
"uninstall")
  install_oracle11g_r2 "$2" "$3" "$4" "$5"
  ;;
*)
  echo_error "\n请输入正确的命令"
  exit 1
  ;;
esac
