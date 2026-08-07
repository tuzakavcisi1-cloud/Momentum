#!/usr/bin/env bash
# API'yi CORS allowlist'inde PROBE KOKENI ile baslatir. $1 = IZOLASYON | IZOLASYONSUZ
# Ayri dosyadir: kabuk komut satirinda dll yolu gecmesin (pkill -f self-kill kusuru, o62'de iki kez).
set -u
DLL=/home/claude/o62/src/backend/Momentum.Api/bin/Debug/net10.0/Momentum.Api.dll
DESEN='Momentum[.]Api[.]dll'
MOD="${1:-IZOLASYON}"
pkill -f "$DESEN" 2>/dev/null
for _ in $(seq 1 30); do pgrep -f "$DESEN" >/dev/null || break; sleep 0.5; done
k=$(curl -s -o /dev/null -w '%{http_code}' --max-time 2 http://127.0.0.1:5298/health/live 2>/dev/null || echo 000)
[ "$k" = "200" ] && { echo "DUR: port hala dolu, olcum KOR olurdu"; exit 3; }
if [ "$MOD" = "IZOLASYONSUZ" ]; then EK="Izolasyon__Etkin=false"; else EK="Izolasyon__Etkin=true"; fi
setsid env ASPNETCORE_ENVIRONMENT=Development ASPNETCORE_URLS=http://127.0.0.1:5298 \
  Cors__AllowedOrigins__0=http://127.0.0.1:5111 $EK \
  /opt/dotnet/dotnet "$DLL" > /tmp/api-$MOD.log 2>&1 < /dev/null &
for _ in $(seq 1 40); do
  k=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:5298/health/live 2>/dev/null || true)
  [ "$k" = "200" ] && break; sleep 0.5
done
echo "MOD=$MOD · /health/live -> $k · surec: $(pgrep -f "$DESEN" | head -1)"
echo -n "  izolasyon basliklari: "
curl -sI http://127.0.0.1:5298/health/live | grep -ci '^cross-origin' | tr -d '\n'; echo " adet"
