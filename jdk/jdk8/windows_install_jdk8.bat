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
echo ׼����װ JDK...
echo.
echo ��װ�밴��������˳�ֱ�ӹرմ���
echo.
echo **********************************************
 
pause
 
set /p "JDK_INSTALL_PATH=������ Java �� JDK ��װ·������س�Ĭ��·��Ϊ %JDK_INSTALL_PATH%��:"

if defined JDK_INSTALL_PATH (echo JDK ��װ·���������) else (set JDK_INSTALL_PATH=C:\Program Files\Java\jdk1.8.0_192)
echo JDK ·��Ϊ %JDK_INSTALL_PATH%

echo.
echo ���ڰ�װ JDK���벻Ҫִ����������
echo.
echo ���Ե�...
echo.
start /WAIT jdk-8u192-windows-x64.exe /qn INSTALLDIR="%JDK_INSTALL_PATH%"
echo JDK ��װ���
 
set JAVA_HOME=%JDK_INSTALL_PATH%
set PATH=%PATH%;%%JAVA_HOME%%\bin;%%JAVA_HOME%%\jre\bin
set CLASSPATH=.;%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar
 
set RegV="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
 
reg add %RegV% /v "JAVA_HOME" /d "%JAVA_HOME%" /f
reg add %RegV% /v "Path" /t REG_EXPAND_SZ /d "%PATH%" /f
reg add %RegV% /v "CLASSPATH" /d "%CLASSPATH%" /f
call java -version
mshta vbscript:msgbox("JDK ����������ɡ�",64,"��Ϣ")(window.close)
exit