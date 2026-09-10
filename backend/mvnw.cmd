@REM ----------------------------------------------------------------------------
@REM Maven Start Up Batch script
@REM ----------------------------------------------------------------------------

@IF "%DEBUG%" == "" @ECHO OFF
@SETLOCAL

SET ERROR_CODE=0

@REM Set local scope for the variables with windows NT shell
IF "%OS%"=="Windows_NT" @SETLOCAL

@REM Auto-detect real JDK 17 if JAVA_HOME is unset or pointing to javapath
IF EXIST "C:\Program Files\Java\jdk-17\bin\java.exe" (
  SET "JAVA_HOME=C:\Program Files\Java\jdk-17"
  GOTO OkJHome
)

@REM ==== START VALIDATION ====
IF NOT "%JAVA_HOME%" == "" GOTO OkJHome

FOR %%i IN (javac.exe) DO SET JAVA_EXE=%%~$PATH:i
IF NOT "%JAVA_EXE%" == "" (
  FOR %%i IN ("%JAVA_EXE%\..") DO SET JAVA_HOME=%%~fsi
  GOTO OkJHome
)

ECHO Error: JAVA_HOME not found in your environment. >&2
ECHO Please set the JAVA_HOME variable in your environment to match the >&2
ECHO location of your Java installation. >&2
GOTO error

:OkJHome
IF EXIST "%JAVA_HOME%\bin\java.exe" GOTO init

ECHO Error: JAVA_HOME is set to an invalid directory. >&2
ECHO JAVA_HOME = "%JAVA_HOME%" >&2
ECHO Please set the JAVA_HOME variable in your environment to match the >&2
ECHO location of your Java installation. >&2
GOTO error

:init
SET MAVEN_PROJECTBASEDIR=%~dp0
SET MAVEN_DIR=%USERPROFILE%\.m2\wrapper\dists\apache-maven-3.9.9\bin

IF EXIST "%MAVEN_DIR%\mvn.cmd" (
  SET "MAVEN_CMD=%MAVEN_DIR%\mvn.cmd"
  GOTO runMaven
)

ECHO Downloading Maven 3.9.9 distribution...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $zip = Join-Path $env:TEMP 'apache-maven-3.9.9-bin.zip'; Invoke-WebRequest -Uri 'https://repo.maven.apache.org/maven2/org/apache/maven/apache-maven/3.9.9/apache-maven-3.9.9-bin.zip' -OutFile $zip; $dest = Join-Path $env:USERPROFILE '.m2\wrapper\dists'; New-Item -ItemType Directory -Force -Path $dest | Out-Null; Expand-Archive -Path $zip -DestinationPath $dest -Force; Remove-Item $zip; }"

IF EXIST "%MAVEN_DIR%\mvn.cmd" (
  SET "MAVEN_CMD=%MAVEN_DIR%\mvn.cmd"
  GOTO runMaven
)

ECHO Error: Failed to setup Maven wrapper. Please install Maven or check your network.
GOTO error

:runMaven
CALL "%MAVEN_CMD%" %*
IF ERRORLEVEL 1 GOTO error
GOTO end

:error
SET ERROR_CODE=1

:end
@ENDLOCAL & SET ERROR_CODE=%ERROR_CODE%
exit /B %ERROR_CODE%
