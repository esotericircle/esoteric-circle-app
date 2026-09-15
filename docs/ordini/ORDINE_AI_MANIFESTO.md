# ORDINE AI. LA PILLOLA DEGLI EOS SEMPRE VISIBILE, E IL MENU' UTENTE OVUNQUE

Quattro voci, da AI.01 a AI.04. Ramo `claude/esoteric-circle-master-order-e798aj`,
premesse verificate sulla testa `0656512` il 17 agosto 2026.

## Perche' quest'ordine esiste

Difetti di Mauro del 17 agosto, dalle foto del telefono: il borsellino deve
essere SEMPRE visibile e oggi anche dove si vede e' brutto, un "0 Eos" di
testo nudo in alto a destra; il menu' utente si vede solo nella home.
DECISIONE REGISTRATA: la scritta ESPLORA e il suo menu' a scomparsa NON si
toccano, la sovrapposizione occasionale e' voluta da Mauro.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. Stati ammessi: CHIUSA, FERMATA SU
PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE, APERTA. Finche' una riga e'
APERTA la guardia `test/ordine_ai_guard_test.dart` resta rossa. Le voci non
si rinumerano e non si accorpano.

## Le premesse, verificate una per una il 17 agosto 2026

1. **P1 VERA, enumerata.** Il borsellino vive in
   `lib/design_system/components/borsellino.dart` (`SegnoDelBorsellino`), il
   volo in `volo_degli_eos.dart`, `IconaDegliEos` ha sei punti di montaggio.
   Delle CINQUE schermate principali (la legge vive in
   `dove_si_vede_la_barra.dart`): mostrano il saldo i tre domini dei Maestri
   (`AngoloDellaBarra` nello Stack della testata) e il Consiglio
   (`AskMaestriScreen`, riga 517); NON lo mostrano la home (`SantuarioScreen`),
   il `CosmicPassport` e la chat (`MaestroChatScreen`). Fuori dalle
   principali lo mostrano le rotte d'arte e i sentieri (barra di
   `rotta_arte.dart`).
2. **P2 VERA.** Il saldo e' `IconaDegliEos` piu' `Text` in una `Row` a misura
   minima, senza contenitore: la larghezza cresce col numero.
3. **P3 VERA, enumerata.** L'unica porta al menu' utente e' l'avatar della
   home (`_UserAvatarButton`, privato di `santuario_screen.dart`, apre
   `AccountScreen`). Il Passport ha un `UserAvatar` DECORATIVO (non e' una
   porta) e un ingranaggio che apre le Impostazioni, non l'account. Domini,
   chat e Consiglio non hanno nessuna porta.
4. **P4 VERA, riprodotta.** A 360 punti il titolo "Notifiche" della card
   dell'account si spezza in "Notific|he": il titolo ha 83 punti di
   larghezza perche' il distintivo "In arrivo" ruba la riga.

## Le quattro voci

- **AI.01** La pillola degli Eos — CHIUSA
  (decisione di Mauro del 17 agosto 2026, portata dalla coda all'ordine: la
  VESTE MISTA. La pillola vive col velo di riposo; quando il volo degli Eos
  le atterra dentro si accende d'oro per 2,6 secondi, poi torna velo. Sotto
  Riduci Movimento il cambio e' secco. Il guadagno si celebra da solo.
  Anteprima dei tre momenti: `docs/preview/pillola_tre_momenti.png`.)
- **AI.02** Il menu' utente ovunque — CHIUSA
- **AI.03** I titoli delle card non si spezzano dentro le parole — CHIUSA
- **AI.04** Il manifesto e il rapporto — CHIUSA

## I marcatori, contati sulle righe

VOCI_TOTALI: 4
VOCI_APERTE: 0
VOCI_CHIUSE: 4
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
