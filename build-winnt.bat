@echo off
set VSINSTALLDIR=C:\Program Files\Microsoft Visual Studio\2022\Community

set PATH=%VSINSTALLDIR%\Common7\IDE;%PATH%
set PATH=%VSINSTALLDIR%\VC\Tools\MSVC\14.44.32507\bin\HostX64\x64;%PATH%

if not exist "target\classes\natives\windows_64\" (
  md target\classes\natives\windows_64
)

nmake ARCH=x86_64 /f Makefile.nmake
