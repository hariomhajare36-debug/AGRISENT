@echo off
setlocal
cd /d "%~dp0"

echo [AgriRent] Building backend package if needed...
if not exist "target\agrirent-backend-1.0.0.jar" (
    call mvnw.cmd package -DskipTests
)

echo [AgriRent] Starting AgriRent Spring Boot Backend in Development Mode (H2 in-memory)...
java -jar target\agrirent-backend-1.0.0.jar --spring.profiles.active=dev %*
