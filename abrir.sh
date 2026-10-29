#!/usr/bin/env bash
# Sobe o MazyOS Scraper em segundo plano e abre no navegador.
# Pra desligar: kill $(cat webdata/mazyos.pid)
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p webdata

export DISABLE_TELEMETRY=1
nohup ./mazyos-scraper -web -addr :8080 -data-folder webdata > webdata/mazyos.log 2>&1 &
echo $! > webdata/mazyos.pid

sleep 3
url=http://localhost:8080
if command -v open >/dev/null 2>&1; then open "$url"; else xdg-open "$url" >/dev/null 2>&1 || echo "Abra $url no navegador"; fi
