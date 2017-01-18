@echo off
:: ����һЩ����
set x_flavor=debug
set x_memory=flash
set x_root=..\..\
rem set msbuild=C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild
set msbuild=msbuild
set MDK_VER=5.05
set MDKPORT=MDK%MDK_VER%
set MDK_TOOL_PATH=D:\Keil_v5\ARM

:: �ȳ���ȡ�õ�ǰĿ¼������Ϊ������

for %%i in ("%cd%") do set x_name=%%~ni

title ����MF����[%x_name%][%x_flavor%][%x_memory%]

rem pushd %x_root%
rem call setenv_MDK.cmd %MDK_VER% %MDK_TOOL_PATH%
rem popd

:: ׼��Feedback��������뾯��
set feedback=%CLRROOT%\tools\make\Feedback\%x_name%_%COMPILER_TOOL_VERSION%.feedback
if Not Exist %feedback% echo feedback > %feedback%
set feedback=%CLRROOT%\tools\make\Feedback\%x_name%_%COMPILER_TOOL_VERSION%_loader.feedback
if Not Exist %feedback% echo feedback > %feedback%

if exist msbuild.log del msbuild.log /f/q

echo ��ʼ����......
call %msbuild% dotnetmf.proj /t:build /p:flavor=%x_flavor%;memory=%x_memory% /maxcpucount /noLogo /v:minimal /fileLogger /flp:Verbosity=normal

IF %errorlevel% == 0 (
	:: ��ɫ��ʾ�ɹ�
	echo *******************************
	echo ����ɹ�
	echo *******************************
) ELSE (
	echo *******************************
	echo ����������뵽msbuild.log��ͨ������error�ؼ��ּ����ϸ������Ϣ��
	echo �п������±����������ʧ��Ҳ�п���ɾ�����Ŀ¼����Խ������
	echo 
	pause
	GOTO :EOF
)

:copybin
:: �����ɵ��ļ����Ƴ���
set x_buildout=%x_root%BuildOutput\THUMB2\%MDKPORT%\le\%x_memory%\%x_flavor%\%x_name%\bin
if not exist %x_buildout% set x_buildout=%x_root%BuildOutput\THUMB2FP\%MDKPORT%\le\%x_memory%\%x_flavor%\%x_name%\bin
set x_bindir=%x_root%..\MFBin\%x_name%

if not exist %x_bindir% md %x_bindir%
:: ����TinyBooter.bin
copy %x_buildout%\*.bin %x_bindir%\ /y
copy %x_buildout%\*.axf %x_bindir%\ /y

del %x_buildout%\*.bin /f/q
del %x_buildout%\*.axf /f/q

:: ����ER_FLASH��ER_CONFIG
set x_buildout=%x_buildout%\tinyclr.bin
copy %x_buildout%\*.* %x_bindir%\ /y
copy %x_bindir%\ER_FLASH %x_bindir%\TinyCLR.bin /y

del %x_bindir%\ER_FLASH /f/q

echo ����Ѹ��Ƶ� %x_bindir%\

echo 
pause

del %x_bindir%\ER_FLASH /f/q