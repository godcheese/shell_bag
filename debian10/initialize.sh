

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