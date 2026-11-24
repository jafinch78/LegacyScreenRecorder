@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
set "LOG=%~dp0BUILD_LAST.log"
set "RC=1"
echo ========================================
echo STAGE 1: BUILD ENVIRONMENT
echo ========================================
if not exist "settings.gradle" goto :fail
if not exist "app\build.gradle" goto :fail
rem Select only a verified JDK 17; never silently use Studio's newer JBR.
set "JDK17="
if defined LEGACY_JDK17 call :tryjdk "%LEGACY_JDK17%"
if defined JAVA_HOME call :tryjdk "%JAVA_HOME%"
for /d %%J in ("%USERPROFILE%\.jdks\*") do call :tryjdk "%%~fJ"
for /d %%J in ("%ProgramFiles%\Microsoft\jdk-17*" "%ProgramFiles%\Eclipse Adoptium\jdk-17*" "%ProgramFiles%\Java\jdk-17*" "%ProgramFiles%\Amazon Corretto\jdk17*") do call :tryjdk "%%~fJ"
call :tryjdk "%ProgramFiles%\Android\Android Studio\jbr"
if not defined JDK17 goto :jdkfail
set "JAVA_HOME=%JDK17%"
set "PATH=%JAVA_HOME%\bin;%PATH%"
echo PASS: Verified JDK 17 at "%JAVA_HOME%"
if not defined ANDROID_HOME if exist "%LOCALAPPDATA%\Android\Sdk\platforms\android-35\android.jar" set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"
if not defined ANDROID_HOME if defined ANDROID_SDK_ROOT set "ANDROID_HOME=%ANDROID_SDK_ROOT%"
if not defined ANDROID_HOME goto :sdkfail
if not exist "%ANDROID_HOME%\platforms\android-35\android.jar" goto :sdkfail
set "GRADLE="
if defined GRADLE_HOME if exist "%GRADLE_HOME%\bin\gradle.bat" set "GRADLE=%GRADLE_HOME%\bin\gradle.bat"
if not defined GRADLE if exist "C:\Gradle\gradle-8.9\bin\gradle.bat" set "GRADLE=C:\Gradle\gradle-8.9\bin\gradle.bat"
if not defined GRADLE for /f "delims=" %%G in ('where gradle.bat 2^>nul') do if not defined GRADLE set "GRADLE=%%G"
if not defined GRADLE goto :gradlefail
echo Project: %CD%
echo SDK: %ANDROID_HOME%
echo Gradle: %GRADLE%
> "%LOG%" echo JAVA_HOME=%JAVA_HOME%
"%JAVA_HOME%\bin\java.exe" -version >> "%LOG%" 2>&1
call "%GRADLE%" --version >> "%LOG%" 2>&1
set "RC=%ERRORLEVEL%"
type "%LOG%"
if not "%RC%"=="0" goto :fail
findstr /b /c:"Gradle 8.9" "%LOG%" >nul
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" goto :gradlefail
echo PASS: JDK 17, Gradle 8.9 and SDK 35 detected.
echo ========================================
echo STAGE 2: BUILD AND LINT
echo ========================================
call "%GRADLE%" "-Dorg.gradle.java.home=%JAVA_HOME%" --no-daemon --console=plain :app:assembleDebug :app:lintDebug >> "%LOG%" 2>&1
set "RC=%ERRORLEVEL%"
type "%LOG%"
if not "%RC%"=="0" goto :fail
echo ========================================
echo STAGE 3: VERIFY BUILD OUTPUT
echo ========================================
if not exist "app\build\outputs\apk\debug\app-debug.apk" goto :missingapk
for %%A in ("app\build\outputs\apk\debug\app-debug.apk") do if %%~zA LEQ 0 goto :missingapk
echo PASS: APK built and lint completed.
echo APK: %CD%\app\build\outputs\apk\debug\app-debug.apk
echo Log: %LOG%
set "RC=0"
goto :end
:jdkfail
> "%LOG%" echo FAIL: No verified JDK 17 found.
echo FAIL: No verified JDK 17 found. Install a JDK 17 or set LEGACY_JDK17 to its folder.
echo Example: winget install --id Microsoft.OpenJDK.17 --exact
set "RC=1"
goto :fail
:sdkfail
echo FAIL: Android SDK Platform 35 not found. Set ANDROID_HOME.
set "RC=1"
goto :fail
:gradlefail
echo FAIL: Gradle 8.9 required. Set GRADLE_HOME or use C:\Gradle\gradle-8.9.
set "RC=1"
goto :fail
:missingapk
echo FAIL: APK missing or empty.
set "RC=1"
:fail
if "%RC%"=="0" set "RC=1"
echo FAIL: Build not verified. See %LOG% if present.
:end
echo Final ERRORLEVEL = %RC%
pause
exit /b %RC%

:tryjdk
if defined JDK17 exit /b 0
if not exist "%~1\bin\java.exe" exit /b 0
if not exist "%~1\bin\javac.exe" exit /b 0
"%~1\bin\java.exe" -XshowSettings:properties -version 2>&1 | findstr /r /c:"java.specification.version = 17$" >nul
if errorlevel 1 exit /b 0
set "JDK17=%~1"
exit /b 0
