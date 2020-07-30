
mv /etc/yum.repos.d/Centos-Base.repo /etc/yum.repos.d/Centos-Base.repo.bak
wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum -y install wget
yum -y install net-tools
yum -y install gcc
yum -y install gcc-c++
yum -y install make
yum -y install perl*
perl -v
yum -y install "kernel-devel-$(uname -r)"
yum -y install epel-release
yum -y install dkms