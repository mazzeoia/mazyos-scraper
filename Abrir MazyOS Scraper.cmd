@echo off
rem Sobe o MazyOS Scraper (janela minimizada) e abre no navegador.
rem Pra desligar, feche a janela "MazyOS Scraper" na barra de tarefas.
cd /d "%~dp0"
set DISABLE_TELEMETRY=1
start "MazyOS Scraper" /min mazyos-scraper.exe -web -addr :8080 -c 4 -data-folder webdata
timeout /t 3 /nobreak >nul
start "" http://localhost:8080
