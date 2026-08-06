#!/usr/bin/env bash
# M-W3-1 mutant kosucusu. AYRI DOSYADIR: kabuk komut satirinda dll yolu gecmesin diye --
# `pkill -f <yol>` kendi kabugunu de oldurup olcumu SESSIZCE sahte yapiyordu (bu oturumda iki kez oldu).
set -u
DLL=/home/claude/o62/src/backend/Momentum.Api/bin/Debug/net10.0/Momentum.Api.dll
DESEN='Momentum[.]Api[.]dll'

durdur() {
  pkill -f "$DESEN" 2>/dev/null
  for _ in $(seq 1 30); do pgrep -f "$DESEN" >/dev/null || return 0; sleep 0.5; done
  return 1
}

yokla() {   # yokla <tavan>  -> 200 gorunce doner (SABIT SLEEP YOK, ORTAM.md)
  for _ in $(seq 1 "$1"); do
    k=$(curl -s -o /dev/null -w '%{http_code}' --max-time 2 http://127.0.0.1:5298/health/live 2>/dev/null || true)
    [ "$k" = "200" ] && { echo "$k"; return 0; }
    sleep 0.5
  done
  echo "${k:-000}"; return 1
}

echo "--- once calisanlari durdur ---"
pgrep -af "$DESEN" || echo "  (surec yok)"
durdur && echo "  durduruldu" || echo "  DURDURULAMADI"
kod=$(curl -s -o /dev/null -w '%{http_code}' --max-time 2 http://127.0.0.1:5298/health/live 2>/dev/null || echo 000)
echo "  port bos mu -> $kod (000 beklenir)"
[ "$kod" = "200" ] && { echo "DUR: port hala dolu, mutant KOR olurdu"; exit 3; }

echo
echo "=== $1 ==="
if [ "$1" = "MUTANT" ]; then
  setsid env ASPNETCORE_ENVIRONMENT=Development ASPNETCORE_URLS=http://127.0.0.1:5298 Izolasyon__Etkin=false \
    /opt/dotnet/dotnet "$DLL" > /tmp/api-mutant.log 2>&1 < /dev/null &
else
  setsid env ASPNETCORE_ENVIRONMENT=Development ASPNETCORE_URLS=http://127.0.0.1:5298 \
    /opt/dotnet/dotnet "$DLL" > /tmp/api-taban.log 2>&1 < /dev/null &
fi
kod=$(yokla 40); echo "  /health/live -> $kod"
echo "  KOSAN SUREC: $(pgrep -af "$DESEN" | head -1)"
echo "--- basliklar ---"
curl -sS -i http://127.0.0.1:5298/health/live | grep -i '^cross-origin' || echo "  COOP/COEP YOK"
echo "--- tarayici (headless Chromium) ---"
python3 /tmp/tarayici_olc.py http://127.0.0.1:5298/health/live 2>&1 | tail -2
