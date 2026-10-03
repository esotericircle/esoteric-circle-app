# ORDINE AH. LA VERSIONE DI FLUTTER SI FISSA NELLA CI

Due voci, AH.01 e AH.02. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `7810cf0` il 17 agosto 2026.

## Perche' quest'ordine esiste

GitHub Actions e Codemagic dichiarano il solo canale stable senza numero: due
build a settimane di distanza possono usare due Flutter diversi, e un archivio
che nessuno sa rifare identico non e' verificabile. La versione vera e' stata
MISURATA sul PC di Mauro il 16 agosto 2026 con `flutter --version`: Flutter
3.44.5 stable, Dart 3.12.2.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: CHIUSA, FERMATA SU
PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE, APERTA. Finche' una riga e'
APERTA la guardia `test/ordine_ah_guard_test.dart` resta rossa. Le voci non si
rinumerano e non si accorpano.

## Le premesse, verificate una per una il 17 agosto 2026

1. **P1 VERA.** `.github/workflows/android-build.yml` alla riga 35 dice
   `channel: stable` dentro `subosito/flutter-action@v2`, senza numero.
2. **P2 VERA.** `codemagic.yaml` alla riga 91 dice `flutter: stable`, unica
   occorrenza, senza numero.
3. **P3 VERA.** Nessun file dichiara la versione di Flutter come dato
   leggibile da una prova. Esiste `docs/versione_distribuita.json`, ma
   registra l'ultimo build CONSEGNATO e si aggiorna dopo ogni distribuzione:
   mescolarci la versione dell'attrezzo, che si muove solo a mano e con
   giudizio, farebbe muovere insieme due cose che hanno padroni diversi. Il
   posto sovrano nuovo e' `docs/versione_flutter.json`.

## Le due voci

- **AH.01** Il numero entra nei due file, e vive in un posto solo — CHIUSA
- **AH.02** Il manifesto e il rapporto — CHIUSA

## I marcatori, contati sulle righe

VOCI_TOTALI: 2
VOCI_APERTE: 0
VOCI_CHIUSE: 2
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
