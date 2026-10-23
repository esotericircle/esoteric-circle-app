#!/bin/bash
# Tocca l'elemento cliccabile il cui content-desc CONTIENE il testo dato.
# Uso: tap_by_desc.sh "Continua"
set -e
export MSYS_NO_PATHCONV=1
DEV=767f596c
CATTURE="C:\Users\user\Desktop\esoteric-circle-app\.claude\worktrees\aspetta-testo-riallineamento-5a7bfd\docs\collaudo\FZ\simulazioni\catture"
adb -s "$DEV" shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1
adb -s "$DEV" pull /sdcard/ui.xml "$CATTURE/_ui.xml" >/dev/null 2>&1
LINE=$(grep -o 'content-desc="[^"]*"[^>]*clickable="true"[^>]*bounds="\[[0-9]*,[0-9]*\]\[[0-9]*,[0-9]*\]"' "$CATTURE/_ui.xml" | grep -F "$1" | head -1)
if [ -z "$LINE" ]; then
  echo "NON TROVATO: $1"
  exit 1
fi
BOUNDS=$(echo "$LINE" | grep -o '\[[0-9]*,[0-9]*\]\[[0-9]*,[0-9]*\]')
X1=$(echo "$BOUNDS" | sed -E 's/\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]/\1/')
Y1=$(echo "$BOUNDS" | sed -E 's/\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]/\2/')
X2=$(echo "$BOUNDS" | sed -E 's/\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]/\3/')
Y2=$(echo "$BOUNDS" | sed -E 's/\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]/\4/')
CX=$(( (X1 + X2) / 2 ))
CY=$(( (Y1 + Y2) / 2 ))
echo "Tocco '$1' a ($CX, $CY), da $LINE"
adb -s "$DEV" shell input tap "$CX" "$CY"
