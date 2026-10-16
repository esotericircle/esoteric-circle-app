#!/usr/bin/env bash
# Rigenera le anteprime committate in docs/preview.
#
# I widget test di cattura scrivono di default in build/preview, cartella
# ignorata dal versionamento, cosi' un normale `flutter test` lascia l'albero
# pulito. Questo script e' la richiesta esplicita: valorizza AGGIORNA_ANTEPRIME
# e riesegue le sole catture, che sovrascrivono i PNG di docs/preview.
#
# Uso, dalla radice del repository:
#   ./tool/aggiorna_anteprime.sh
# Poi si rivedono le differenze con `git diff --stat docs/preview` e si committa
# quello che si vuole tenere.
set -euo pipefail

echo 'Rigenero le anteprime in docs/preview...'
AGGIORNA_ANTEPRIME=1 flutter test test/screenshot_capture_test.dart

echo
echo 'Fatto. Anteprime aggiornate in docs/preview.'
echo 'Rivedi le differenze con: git diff --stat docs/preview'
