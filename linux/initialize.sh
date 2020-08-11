

# centos 7
mv /etc/yum.repos.d/Centos-Base.repo /etc/yum.repos.d/Centos-Base.repo.bak
wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum update
yum install -y wget
yum install -y net-tools
yum install -y lsof
yum install -y gcc
yum install -y gcc-c++
yum install -y make
yum install -y perl*
perl -v
yum install -y "kernel-devel-$(uname -r)"
yum install -y epel-release
yum install -y dkms


# debian 10
# 安装 SSH 服务
sudo apt-get update
sudo apt-get install -y vim
sudo apt-get install -y ssh
sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/^PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
service ssh start
service ssh status


# ubuntu 16.04
# 安装 SSH 服务
sudo apt-get update
sudo apt-get install -y ssh
sed -i "s/^#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
sed -i "s/^PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config
service ssh start
service ssh status

# 安装 SFTP 服务
#sudo apt-get install -y open-sshserver




# 获取系统信息
function system_info() {
  release_name=$(awk '/^NAME="/' /etc/os-release | awk -F '"' '{print $2}' | awk -F ' ' '{print $1}' | tr 'A-Z' 'a-z' 2>&1)
  release_version=$(awk '/^VERSION="/' /etc/os-release | awk -F '"' '{print $2}' | awk -F ' ' '{print $1}' 2>&1)
  release_full_version=
  linux_kernel=$(uname -srm | awk -F ' ' '{print $2}' | awk -F '-' '{print $1}' 2>&1)
  case "${release_name}" in
  "centos")
    release_full_version=$(awk '/\W/' /etc/centos-release | awk '{print $4}' 2>&1)
    ;;
  "debian")
    release_full_version=$(cat /etc/debian_version 2>&1)
    ;;
  "ubuntu")
    release_full_version=${release_version}
    release_version=$(echo ${release_version} | awk -F '.' '{print $1}')
    ;;
  *)
    echo "Unknown system."
    exit 0
    ;;
  esac
}
system_info