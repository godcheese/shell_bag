@echo off

rem http://github.com/godcheese/shell_bag
rem author: godcheese [godcheese@outlook.com]

echo -------------------------------------------------
echo | Windows Auto Install Jdk 8                    |
echo | http://github.com/godcheese/shell_bag         |
echo | author: godcheese [godcheese@outlook.com]     |
echo -------------------------------------------------

%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
 
echo **********************************************
echo.
echo 准备安装 JDK...
echo.
echo 安装请按任意键，退出直接关闭窗口
echo.
echo **********************************************
 
pause
 
set /p "JDK_INSTALL_PATH=请输入 Java 的 JDK 安装路径（或回车默认路径为 %JDK_INSTALL_PATH%）:"

if defined JDK_INSTALL_PATH (echo JDK 安装路径设置完成) else (set JDK_INSTALL_PATH=C:\Program Files\Java\jdk1.8.0_192)
echo JDK 路径为 %JDK_INSTALL_PATH%

echo.
echo 正在安装 JDK，请不要执行其它操作
echo.
echo 请稍等...
echo.
start /WAIT jdk-8u192-windows-x64.exe /qn INSTALLDIR="%JDK_INSTALL_PATH%"
echo JDK 安装完成
 
set JAVA_HOME=%JDK_INSTALL_PATH%
set PATH=%PATH%;%%JAVA_HOME%%\bin;%%JAVA_HOME%%\jre\bin
set CLASSPATH=.;%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar
 
set RegV="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
 
reg add %RegV% /v "JAVA_HOME" /d "%JAVA_HOME%" /f
reg add %RegV% /v "Path" /t REG_EXPAND_SZ /d "%PATH%" /f
reg add %RegV% /v "CLASSPATH" /d "%CLASSPATH%" /f
call java -version
mshta vbscript:msgbox("JDK 环境配置完成。",64,"信息")(window.close)
exit