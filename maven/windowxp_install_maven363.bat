@echo off

rem http://github.com/godcheese/shell_bag
rem author: godcheese [godcheese@outlook.com]

echo *************************************************
echo  Install the JDK
echo  http://github.com/godcheese/shell_bag
echo  author: godcheese [godcheese@outlook.com]
echo *************************************************
echo.
echo Prepare to install the JDK...
echo.
set /p KEY=Press any key to continue or close the window to exit...
echo.
set TEMP_INSTALLATION_PATH=%ProgramFiles%\Java\jdk1.8.0_192
set /p "JDK_INSTALLATION_PATH=Please enter the JDK installation path(Otherwise %TEMP_INSTALLATION_PATH%):"
if not defined JDK_INSTALLATION_PATH (set JDK_INSTALLATION_PATH=%TEMP_INSTALLATION_PATH%)
echo JDK installation path: %JDK_INSTALLATION_PATH%
echo.
echo Installing the JDK,please do not do something else...
echo.
start /WAIT jdk-8u192-windows-x64.exe /qn
echo.
echo JDK install completed.
echo.
echo Prepare to configure the JDK...
echo.
echo Configuring JDK,please do not do something else...
set JAVA_HOME=%JDK_INSTALLATION_PATH%
set PATH=%PATH%;%%JAVA_HOME%%\bin;%%JAVA_HOME%%\jre\bin
set CLASSPATH=.;%%JAVA_HOME%%\lib\dt.jar;%%JAVA_HOME%%\lib\tools.jar
set RegV=HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment
reg add "%RegV%" /v "JAVA_HOME" /d "%JAVA_HOME%" /f
reg add "%RegV%" /v "Path" /t REG_EXPAND_SZ /d "%PATH%" /f
reg add "%RegV%" /v "CLASSPATH" /d "%CLASSPATH%" /f
echo.
echo JDK configuration completed.
echo.
echo JDK installation path: %JDK_INSTALLATION_PATH%
echo.
set /p KEY=Press any key to exit...
exit