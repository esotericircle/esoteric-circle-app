# ORDINE AK. IL PASSAPORTO SI PULISCE, LE ARTI PREFERITE ARRIVANO, E LA BUILD VA SU APP TESTER

Cinque voci, da AK.01 ad AK.05. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse riverificate sulla testa `307653b` (quella che l'ordine AJ chiuso
lascia) il 17 agosto 2026.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: APERTA, CHIUSA,
FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE. Finche' una riga
e' APERTA la guardia `test/ordine_ak_guard_test.dart` resta rossa. Le voci
non si rinumerano e non si accorpano; un commit per voce; la suite intera
gira UNA volta alla AK.05, prima del push.

## Le premesse, riverificate una per una il 17 agosto 2026

1. **P1 VERA.** La rotellina esiste: `cosmic_passport_screen.dart` righe
   141-148, IconButton `passport_settings` che apre SettingsScreen.
2. **P2 VERA.** La PortaDellAccount vive nella testata del Passport (riga
   129) e ovunque dall'ordine AI; AccountScreen elenca Impostazioni (righe
   52-58) che apre SettingsScreen.
3. **P3 VERA.** `_SentieriDelCammino` (righe 921-970) e' una colonna nuda di
   tre ListTile su Material trasparente, primo elemento del corpo (riga 181).
4. **P4 VERA.** Righe 159-164: la pagina promette i fatti fissi e mostra per
   prima cosa il cammino, che cambia ogni giorno.
5. **P5 VERA.** "Le tue arti" in due punti della vista (righe 52 e 189);
   seme `semePer` da due arti per Maestro; tetto nove (riga 37).
6. **P6 VERA.** Nove arti attive col nome giusto; `tarot_spread_three` e'
   "Stesa di Tarocchi" e NON si rinomina: la decisione di Mauro e'
   l'etichetta breve "Tarocchi" nello scaffale della home.
7. **P7 VERA.** Comando storico di consegna con l'app
   `1:425821975933:android:1b1ca4db8d4df69b940814`; versione attuale
   `0.1.0+2178` (pubspec.yaml riga 12); attestazione col fornitore non
   installato su build da App Distribution, compromesso noto.

## Le cinque voci

- **AK.01** Lo scaffale diventa "Le arti preferite" — CHIUSA
- **AK.02** La fila "Le altre arti del Cerchio" — CHIUSA
- **AK.03** La rotellina lascia il Passport — CHIUSA
- **AK.04** I sentieri nella bolla "I tuoi traguardi" — APERTA
- **AK.05** Il manifesto, la suite, la build su App Tester — APERTA

## I marcatori, contati sulle righe

VOCI_TOTALI: 5
VOCI_APERTE: 2
VOCI_CHIUSE: 3
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
