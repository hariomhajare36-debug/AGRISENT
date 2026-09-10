@echo off
setlocal
cd /d "%~dp0"

echo [AgriRent] Building backend package if needed...
if not exist "target\agrirent-backend-1.0.0.jar" (
    call mvnw.cmd package -DskipTests
)

echo [AgriRent] Starting AgriRent Spring Boot Backend (MSSQL Production/Local Mode)...
java -jar target\agrirent-backend-1.0.0.jar %*
