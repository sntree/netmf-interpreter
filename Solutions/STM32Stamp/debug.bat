@echo off
:: 设置一些参数
set x_flavor=debug
set x_memory=flash
set x_root=..\..\
rem set msbuild=C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild
set msbuild=msbuild
set MDK_VER=5.05
set MDKPORT=MDK%MDK_VER%
set MDK_TOOL_PATH=D:\Keil_v5\ARM

:: 先尝试取得当前目录名，作为方案名

for %%i in ("%cd%") do set x_name=%%~ni

title 编译MF方案[%x_name%][%x_flavor%][%x_memory%]

rem pushd %x_root%
rem call setenv_MDK.cmd %MDK_VER% %MDK_TOOL_PATH%
rem popd

:: 准备Feedback，避免编译警告
set feedback=%CLRROOT%\tools\make\Feedback\%x_name%_%COMPILER_TOOL_VERSION%.feedback
if Not Exist %feedback% echo feedback > %feedback%
set feedback=%CLRROOT%\tools\make\Feedback\%x_name%_%COMPILER_TOOL_VERSION%_loader.feedback
if Not Exist %feedback% echo feedback > %feedback%

if exist msbuild.log del msbuild.log /f/q

echo 开始编译......
call %msbuild% dotnetmf.proj /t:build /p:flavor=%x_flavor%;memory=%x_memory% /maxcpucount /noLogo /v:minimal /fileLogger /flp:Verbosity=normal

IF %errorlevel% == 0 (
	:: 绿色显示成功
	echo *******************************
	echo 编译成功
	echo *******************************
) ELSE (
	echo *******************************
	echo 编译出错，请到msbuild.log中通过搜索error关键字检查详细错误信息！
	echo 有可能重新编译后错误会消失，也有可能删除输出目录后可以解决错误！
	echo 
	pause
	GOTO :EOF
)

:copybin
:: 把生成的文件复制出来
set x_buildout=%x_root%BuildOutput\THUMB2\%MDKPORT%\le\%x_memory%\%x_flavor%\%x_name%\bin
if not exist %x_buildout% set x_buildout=%x_root%BuildOutput\THUMB2FP\%MDKPORT%\le\%x_memory%\%x_flavor%\%x_name%\bin
set x_bindir=%x_root%..\MFBin\%x_name%

if not exist %x_bindir% md %x_bindir%
:: 复制TinyBooter.bin
copy %x_buildout%\*.bin %x_bindir%\ /y
copy %x_buildout%\*.axf %x_bindir%\ /y

del %x_buildout%\*.bin /f/q
del %x_buildout%\*.axf /f/q

:: 复制ER_FLASH和ER_CONFIG
set x_buildout=%x_buildout%\tinyclr.bin
copy %x_buildout%\*.* %x_bindir%\ /y
copy %x_bindir%\ER_FLASH %x_bindir%\TinyCLR.bin /y

del %x_bindir%\ER_FLASH /f/q

echo 输出已复制到 %x_bindir%\

echo 
pause

del %x_bindir%\ER_FLASH /f/q
