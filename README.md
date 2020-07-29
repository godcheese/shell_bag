# shell_bag
> Linux/Unix Shell、Windows Bat 工具包


Linux CentOS Usage Example：
```
sudo curl -o install_dev_software.sh https://github.com/godcheese/shell_bag/raw/master/centos/install_dev_software.sh && sudo bash install_dev_software.sh jdk /webwork/software/jdk https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202 && sudo bash install_dev_software.sh maven /webwork/software/maven https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz apache-maven-3.6.3 && sudo bash install_dev_software.sh maven /webwork/software/maven https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.31-el7-x86_64.tar.gz apache-maven-3.6.3
```

|     | Script | System | Software | Usage |
| :-- | :----- | :----- | :------- | :---- |
| centos | install_dev_software.sh | >= CentOS 7.0 | JDK、Python、Maven、Nginx、MySQL、Oracle | ```jdk /webwork/software/jdk https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202``` ```python /webwork/software/python https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tgz jdk1.8.0_202``` ```maven /webwork/software/maven https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz apache-maven-3.6.3``` ```nginx /webwork/software/nginx http://nginx.org/download/nginx-1.18.0.tar.gz nginx-1.18.0``` ```mysql /webwork/software/mysql https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.31-el7-x86_64.tar.gz mysql-5.7.31-el7-x86_64``` ```oracle /webwork/software/oracle https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202``` |
| macos | install_dev_software.sh | >= macOS 10.14 | JDK、Python、Maven、Nginx、MySQL、Oracle | ```jdk /webwork/software/jdk https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202``` ```python /webwork/software/python https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202``` ```maven /webwork/software/maven https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202``` ```nginx /webwork/software/nginx http://nginx.org/download/nginx-1.18.0.tar.gz nginx-1.18.0``` ```mysql /webwork/software/mysql https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.31-macos10.14-x86_64.tar.gz jdk1.8.0_202``` ```oracle /webwork/software/oracle https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202```|
| windows | install_dev_software.sh | >= Windows XP | JDK、Python、Maven、Nginx、MySQL、Oracle | ```jdk /webwork/software/jdk https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-windows-x64.exe jdk1.8.0_202``` ```python /webwork/software/python https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202``` ```maven /webwork/software/maven https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202``` ```nginx /webwork/software/nginx http://nginx.org/download/nginx-1.18.0.zip nginx-1.18.0``` ```mysql /webwork/software/mysql https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202``` ```oracle /webwork/software/oracle https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-x64.tar.gz jdk1.8.0_202```|





| nginx | centos7_install_1180.sh | >= CentOS 7.0 | Nginx | 1.18.0 | http://nginx.org/download/nginx-1.18.0.tar.gz |
| macos1014_install_1180.sh | >= macOS 10.14 | Nginx | 1.18.0 | http://nginx.org/download/nginx-1.18.0.tar.gz | macOS 安装 JDK |
| windowsxp_install_1180.bat | >= Windows XP | Nginx | 1.18.0 | http://nginx.org/download/nginx-1.18.0.zip | Windows 安装 Nginx |