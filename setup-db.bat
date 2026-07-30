@echo off
set MYSQL="C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
set USER=root
set PASS=your_mysql_password
set DB=musicnest
set DIR=%~dp0server\src\main\resources

echo ============================================
echo  MusicNest Database Setup
echo ============================================
echo.
echo [1/4] Dropping old database...
%MYSQL% -u%USER% -p%PASS% -e "DROP DATABASE IF EXISTS %DB%;" 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to drop database. Check password or MySQL service.
    pause
    exit /b 1
)
echo         Done.

echo [2/4] Creating database...
%MYSQL% -u%USER% -p%PASS% -e "CREATE DATABASE %DB% DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to create database.
    pause
    exit /b 1
)
echo         Done.

echo [3/4] Importing schema.sql (tables)...
%MYSQL% -u%USER% -p%PASS% --default-character-set=utf8mb4 %DB% < "%DIR%\schema.sql" 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to import schema.sql.
    pause
    exit /b 1
)
echo         Done.

echo [4/4] Importing data.sql (seed data)...
%MYSQL% -u%USER% -p%PASS% --default-character-set=utf8mb4 %DB% < "%DIR%\data.sql" 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Failed to import data.sql.
    pause
    exit /b 1
)
echo         Done.

echo.
echo ============================================
echo  Setup Complete!
echo  Database: %DB%
echo  Accounts:
echo    admin     (ROLE_ADMIN)
echo    staff01   (ROLE_STAFF)
echo ============================================
pause
