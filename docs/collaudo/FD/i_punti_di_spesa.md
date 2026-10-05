# I punti di spesa, ordine FD voce 01.2

Enumerati, non campionati (R3), sul codice del commit `d46348c4`: ogni punto
di `lib` che consuma minuti, Eos o denaro, il file e la riga del gesto, se
prima dell'ordine c'era una conferma e cosa c'e' adesso. Le righe si
ricavano con `grep -rn "LaConfermaDellaSpesa\." lib` e
`grep -rn "consenso: consenso" lib`.

**La premessa dell'ordine, abbattuta (R2).** *"La conferma del costo esiste
gia' da qualche parte e il LIVE la salta"*: falso. Prima dell'ordine **nessun
punto** mostrava il costo e il saldo con due pulsanti. Due punti avevano due
pulsanti col costo ma senza il saldo (il dono e il regalo di Eos), gli altri
spendevano al primo tocco su una riga col prezzo, e il LIVE apriva una
sessione a pagamento al primo tocco, senza nessuna riga.

## Minuti

| # | Punto | Gesto (file:riga) | Prima | Adesso |
|---|---|---|---|---|
| 1 | Il LIVE dalla pastiglia d'oro | `lib/features/maestri/chat/maestro_chat_screen.dart:719` | nessuna conferma, sessione a pagamento al tocco | `entraNelVivo`, `lib/features/maestri/live/l_entrata_nel_vivo.dart:37`, conferma dei minuti |
| 2 | Il LIVE dal menu' della chat | `lib/features/maestri/chat/maestro_chat_screen.dart:1564` | nessuna conferma | la stessa `entraNelVivo` |

I minuti si leggono prima del tocco con la funzione nuova `iMinutiDelLive`
(`functions/src/live.ts`), che usa lo stesso conto dell'apertura
(`iSecondiCheRestano`). **Va pubblicata dal fondatore**.

## Eos

| # | Punto | Gesto (file:riga) | Prima | Adesso |
|---|---|---|---|---|
| 3 | L'oroscopo dell'anno, 300 Eos | `lib/features/horoscope/oroscopo_screen.dart:1008` (`PortaDellaSpesa`) | riga col prezzo, un pulsante, spesa al tocco | conferma, `lib/design_system/components/porta_della_spesa.dart:90` |
| 4 | L'oroscopo completo di oggi, 50 Eos | `lib/features/horoscope/oroscopo_screen.dart:2207` (`PortaDellaSpesa`) | come sopra | come sopra |
| 5 | Un posto in piu' fra gli amici, 100 Eos | `lib/features/amici/amici_screen.dart:311` (`PortaDellaSpesa`) | come sopra | come sopra |
| 6 | Riscatto di una stesa | `lib/features/tarot/stesa_tre_carte_screen.dart:955` (`corredoDelRiscatto`) | "Riscatta" spendeva al tocco | conferma, `lib/features/pricing/upgrade_invite.dart:193` |
| 7 | Riscatto di una sinastria | `lib/features/synastry/sinastria_vip_screen.dart:433` | come sopra | come sopra |
| 8 | Riscatto di un confronto fra i Maestri | `lib/features/maestri/chat/maestro_chat_screen.dart:391` | come sopra | come sopra |
| 9 | Riscatto di un approfondimento | `lib/features/maestri/chat/maestro_chat_screen.dart:480` | come sopra | come sopra |
| 10 | Riscatto di una gettata di rune | `lib/features/maestri/caligo/rune/rune_draw_screen.dart:250` | come sopra | come sopra |
| 11 | Riscatto di una domanda nella Consulta | `lib/features/maestri/ask/ask_maestri_screen.dart:233` | come sopra | come sopra |
| 12 | Un confronto del cielo in piu', 30 Eos | `lib/features/cerchio/confronto_del_cielo_screen.dart:94` | un pulsante, spesa al tocco | conferma |
| 13 | Il dono, scintilla 30 e sigillo 80 | `lib/features/cerchio/scheda_dell_amico_screen.dart:65` | `AlertDialog` proprio, due pulsanti, senza saldo | conferma unica; il dialogo proprio e' stato tolto |
| 14 | Regala Eos, da 100 a 500 | `lib/features/cerchio/scheda_dell_amico_screen.dart:140` | foglio col cursore, due pulsanti, senza saldo | il foglio sceglie quanto, la conferma unica dice costo e saldo |
| 15 | Un posto in piu' nel Cerchio, 100 Eos | `lib/core/cerchio/il_cerchio_sociale.dart:888` (`compraUnPosto`) | nessun chiamante | nessun chiamante; la porta pretende il consenso |

Il cenno e' gratuito (`PREZZI_DEI_DONI.cenno: 0` sul server) e non chiede la
conferma: ha la sua porta, `mandaUnCenno`
(`lib/core/cerchio/il_cerchio_sociale.dart`), chiamata da
`lib/features/cerchio/la_tendina_del_cerchio.dart:369` e dalla tessera del
dono.

## Denaro

Nessun acquisto vero in `lib`: `in_app_purchase` e `purchases_flutter` non
sono nel `pubspec.yaml`. "Attiva in Demo" (`lib/features/pricing/pricing_screen.dart`)
non incassa niente e lo dice.

## Fuori dalla voce, e perche'

Gli **usi del giorno compresi nel piano** (una domanda in chat,
l'approfondimento, il confronto fra i Maestri, la stesa, la gettata, la
sinastria, il confronto del cielo) non consumano minuti, Eos o denaro: si
contano sul piano, e il loro residuo lo dice gia' `RigaDelResiduo` (ordine
CE voce 04, decisione del fondatore del 30 agosto 2026: *"serve pulsante
consenso esplicito solo se l'utente spende EOS"*). Quando sono finiti, la
strada degli Eos e' il riscatto, punti 6-11, che passa dalla conferma.

`CostoInChiaro` (`lib/design_system/components/costo_in_chiaro.dart`) non e'
una conferma: e' una riga di testo col costo e il saldo, senza pulsanti, e
non ha chiamanti in `lib`. Resta com'e', con le sue prove.

## La porta unica

- La conferma: `lib/design_system/components/la_conferma_della_spesa.dart`.
- Il consenso, che solo la conferma crea:
  `lib/core/entitlement/il_consenso_della_spesa.dart`.
- Le sei porte che lo pretendono: `SpesaDegliEos.perLaVoce`,
  `QuestionAllowance.riscatta`, `IlCerchioSociale.compraUnPosto`,
  `mandaUnDono`, `regalaGliEos`, `SchermataLive.route`.
- La guardia: `test/la_spesa_passa_dalla_conferma_test.dart`.
