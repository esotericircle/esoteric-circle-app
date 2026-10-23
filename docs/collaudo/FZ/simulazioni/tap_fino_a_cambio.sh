#!/bin/bash
# Tocca ripetutamente (x,y) finche' lo screenshot cambia dimensione in byte
# rispetto a prima del primo tocco, o finche' non si esauriscono i tentativi.
# Uso: tap_fino_a_cambio.sh X Y [tentativi] [attesa_secondi]
set -e
export MSYS_NO_PATHCONV=1
DEV=767f596c
CATTURE="C:\Users\user\Desktop\esoteric-circle-app\.claude\worktrees\aspetta-testo-riallineamento-5a7bfd\docs\collaudo\FZ\simulazioni\catture"
X="$1"
Y="$2"
TENTATIVI="${3:-10}"
ATTESA="${4:-4}"

adb -s "$DEV" shell screencap -p /sdcard/prima.png >/dev/null 2>&1
adb -s "$DEV" pull /sdcard/prima.png "$CATTURE/_prima.png" >/dev/null 2>&1
PRIMA=$(stat -c%s "$CATTURE/_prima.png" 2>/dev/null || wc -c < "$CATTURE/_prima.png")

for i in $(seq 1 "$TENTATIVI"); do
  adb -s "$DEV" shell input tap "$X" "$Y"
  sleep "$ATTESA"
  adb -s "$DEV" shell screencap -p /sdcard/dopo.png >/dev/null 2>&1
  adb -s "$DEV" pull /sdcard/dopo.png "$CATTURE/_dopo.png" >/dev/null 2>&1
  DOPO=$(stat -c%s "$CATTURE/_dopo.png" 2>/dev/null || wc -c < "$CATTURE/_dopo.png")
  echo "tentativo $i: prima=$PRIMA dopo=$DOPO"
  if [ "$DOPO" != "$PRIMA" ]; then
    echo "CAMBIATA al tentativo $i"
    cp "$CATTURE/_dopo.png" "$CATTURE/_cambiata.png"
    exit 0
  fi
done
echo "NESSUN CAMBIAMENTO dopo $TENTATIVI tentativi"
exit 1
