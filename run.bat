@setlocal DisableDelayedExpansion
@echo off




::========================================================================================================================================

:: Re-launch the script with x64 process if it was initiated by x86 process on x64 bit Windows
:: or with ARM64 process if it was initiated by x86/ARM32 process on ARM64 Windows

if exist %SystemRoot%\Sysnative\cmd.exe (
set "_cmdf=%~f0"
setlocal EnableDelayedExpansion
start %SystemRoot%\Sysnative\cmd.exe /c ""!_cmdf!" %*"
exit /b
)

:: Re-launch the script with ARM32 process if it was initiated by x64 process on ARM64 Windows

if exist %SystemRoot%\SysArm32\cmd.exe if %PROCESSOR_ARCHITECTURE%==AMD64 (
set "_cmdf=%~f0"
setlocal EnableDelayedExpansion
start %SystemRoot%\SysArm32\cmd.exe /c ""!_cmdf!" %*"
exit /b
)

::  Set Path variable, it helps if it is misconfigured in the system

set "SysPath=%SystemRoot%\System32"
if exist "%SystemRoot%\Sysnative\reg.exe" (set "SysPath=%SystemRoot%\Sysnative")
set "Path=%SysPath%;%SystemRoot%;%SysPath%\Wbem;%SysPath%\WindowsPowerShell\v1.0\"

::========================================================================================================================================

cls
color 07
title  Exitlag Trial Reset v3.1

set _elev=
if /i "%~1"=="-el" set _elev=1

set winbuild=1
set "nul=>nul 2>&1"
set "_psc=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
for /f "tokens=6 delims=[]. " %%G in ('ver') do set winbuild=%%G

set _NCS=1
if %winbuild% LSS 10586 set _NCS=0
if %winbuild% GEQ 10586 reg query "HKCU\Console" /v ForceV2 2>nul | find /i "0x0" 1>nul && (set _NCS=0)


::========================================================================================================================================

if %winbuild% LSS 7600 (
%nceline%
echo Unsupported OS version detected.
echo This program is supported only for Windows 10/11 and their Server equivalent.
goto shitSend
)

if not exist %_psc% (
%nceline%
echo Powershell is not installed in the system.
echo Aborting...
goto shitSend
)

::========================================================================================================================================

::  Fix for the special characters limitation in path name

set "_batf=%~f0"
set "_batp=%_batf:'=''%"

set "_PSarg="""%~f0""" -el %_args%"

set "_ttemp=%temp%"

setlocal EnableDelayedExpansion

::========================================================================================================================================

echo "!_batf!" | find /i "!_ttemp!" 1>nul && (
%nceline%
echo Script is launched from the temp folder,
echo Most likely you are running the script directly from the archive file.
echo:
echo Extract the archive file and launch the script from the extracted folder.
goto shitSend
)

::========================================================================================================================================

::  Elevate script as admin and pass arguments and preventing loop

%nul% reg query HKU\S-1-5-19 || (
if not defined _elev %nul% %_psc% "start cmd.exe -arg '/c \"!_PSarg:'=''!\"' -verb runas" && exit /b
%nceline%
echo This script require administrator privileges.
echo To do so, right click on this script and select 'Run as administrator'.
goto shitSend
)

::========================================================================================================================================

setlocal DisableDelayedExpansion

::  Check desktop location

set _desktop_=
for /f "skip=2 tokens=2*" %%a in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop') do call set "_desktop_=%%b"
if not defined _desktop_ for /f "delims=" %%a in ('%_psc% "& {write-host $([Environment]::GetFolderPath('Desktop'))}"') do call set "_desktop_=%%a"

set "_pdesk=%_desktop_:'=''%"
setlocal EnableDelayedExpansion
set "mastemp=%SystemRoot%\Temp\__shit"

::========================================================================================================================================


:MainMenu
cls
color 07
title Exitlag Trial Reset v3.1
mode 76, 30
if exist "%mastemp%\.*" rmdir /s /q "%mastemp%\" %nul%
echo:
echo:
echo:
echo:
echo:       ______________________________________________________________
echo:
echo:                 Activation Methods:
echo:
echo:             [1] Spoof HWID and activate Exitlag                                                                  
echo:             [2] Activate test mode (restart required)
echo:             [3] Unactivate test mode
echo:             [4] Extras                                               
echo:             __________________________________________________      
echo:                                                                     
echo:             [5] Join our Discord group!
echo:             [6] Exit                                
echo:       ______________________________________________________________
echo:
Echo: "Enter a menu option in the Keyboard [1,2,3,4,5,6]: "
choice /C:123456 /N
set _erl=%errorlevel%

if %_erl%==6 exit /b
if %_erl%==5 start https://discord.gg/PUEqfrHsHe & goto :MainMenu
if %_erl%==4 goto:Extras
if %_erl%==3 setlocal & call :Unactivate     & cls & endlocal & goto :MainMenu
if %_erl%==2 setlocal & call :Testmode   & cls & endlocal & goto :MainMenu
if %_erl%==1 setlocal & call :Spoofer    & cls & endlocal & goto :MainMenu
goto :MainMenu        
::========================================================================================================================================

:Extras

cls
title  Extras
mode 76, 30
echo:
echo:
echo:
echo:
echo:
echo:       ______________________________________________________________
echo:
echo:             [1] MAC Changer
echo:
echo:             [2] Check Disk Serial
echo:
echo:             [3] Create a new user (Generate new id)
echo:
echo:             [4] Delete new user (delete user from "3")
echo:
echo:             [5] Go to Main Menu
echo:       ______________________________________________________________
echo:
echo:   "Enter a menu option in the Keyboard [1,2,3,4,5] :"
choice /C:12345 /N
set _erl=%errorlevel%

if %_erl%==4 goto :DeleteUser
if %_erl%==5 goto :MainMenu
if %_erl%==3 goto :CreateUser
if %_erl%==2 goto :CheckDS
if %_erl%==1 goto :macchanger & cls & endlocal & goto :Extras
goto :Extras

::========================================================================================================================================

:+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

::  Extract the text from batch script without character issue

:_Export

%nul% %_psc% "$f=[io.file]::ReadAllText('!_batp!') -split \":%~1\:.*`r`n\"; [io.file]::WriteAllText('%~2',$f[1].Trim(),[System.Text.Encoding]::%~3);"
exit /b

:oemexport

%nul% %_psc% "$f=[io.file]::ReadAllText('!_batp!') -split \":%~1\:.*`r`n\"; [io.file]::WriteAllText('!_pdesk!\$OEM$\$$\Setup\Scripts\%~2',$f[1].Trim(),[System.Text.Encoding]::ASCII);"
exit /b

::========================================================================================================================================

:_prep

cls
if exist "%mastemp%\.*" rmdir /s /q "%mastemp%\" %nul%
md "%mastemp%\" %nul%
echo:
echo Extracting Files to %mastemp%\
pushd "%mastemp%\"
exit /b

:_clean

cd \
if exist "%mastemp%\.*" rmdir /s /q "%mastemp%\" %nul%
echo:
echo Cleaning Extracted Files...
timeout /t 1 > nul
exit /b

::========================================================================================================================================

:+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

:shitSend
echo:
echo Press any key to exit...
pause >nul
exit /b

:======================================================================================================================================================

:CheckDS
cls
echo Disk Serial: %nul%
wmic diskdrive get serialnumber
echo %nul%
echo: Press any key to continue...
pause >nul
goto :MainMenu

:======================================================================================================================================================

:macchanger
cls
echo Changing MAC Address...
call "%~dp0\data\macchanger.bat"
echo: MAC Address changed!
echo: Press any key to continue!
pause >nul
goto :MainMenu

:======================================================================================================================================================

:Testmode
cls
echo Activating Test mode now...
bcdedit.exe -set TESTSIGNING ON 
echo: Done! %nul%
pause >nul 
goto :MainMenu

:======================================================================================================================================================

:Unactivate
cls
echo Unactivate Test mode now...
bcdedit.exe -set TESTSIGNING OFF
echo: Done! %nul%
pause >nul
goto :MainMenu

:======================================================================================================================================================

:Spoofer
cls
%~dp0\data\spoofer.exe "%~dp0\data\driver.sys
echo: Spoofed! %nul%
pause >nul
goto :MainMenu

:======================================================================================================================================================

:CreateUser
cls
call "%~dp0\data\createuser.bat"
cls
echo Created, please press any key to continue...
pause >nul
goto :MainMenu

:======================================================================================================================================================

:DeleteUser
cls
call "%~dp0\data\deleteuser.bat"
echo Deleted!
echo Press any key to continue...
pause >nul
goto :MainMenu

:======================================================================================================================================================

                             