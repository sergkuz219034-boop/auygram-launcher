@echo off
chcp 65001 >nul
title AyuGram Launcher
:: Запускаем в режиме STA (нужен для GUI) и не закрываем окно, если будет ошибка
powershell -NoProfile -ExecutionPolicy Bypass -Sta -File "%~dp0auygram.ps1"
if %errorlevel% neq 0 pause
