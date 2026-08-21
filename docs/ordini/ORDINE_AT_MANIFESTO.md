# ORDINE AT, il manifesto

**LE TRE TRANSIZIONI DI STELLE.** Undici voci, dalla AT.00 alla AT.10, sul ramo
`claude/esoteric-circle-master-order-e798aj`.

**SOSTITUISCE INTEGRALMENTE la voce AS.02**, che resta FERMATA SU DECISIONE DEL
FONDATORE: tutto il lavoro fatto o previsto sulle feste dei traguardi va
demolito, non adattato.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_at_guard_test.dart`
conta sulle righe.

## L'avvertenza di metodo, riportata come l'ordine chiede

Il ramo non e' sul remoto perche' il push non passa, quindi l'Architetto NON ha
potuto leggere il codice dell'ordine AS. Cio' che riguarda file toccati da AS
e' dichiarato IPOTESI e va misurato. Cio' che viene dalle misure del fondatore
e' fatto.

## I fatti, rifatti qui

- **F1 CONFERMATO.** In `transition/` ci sono `Star-Transition-8.mov`, `9` e
  `10`, piu' i due archivi zip sorgente.
- **F3 CONFERMATO al byte.** 132.336.243, 136.640.302 e 142.754.571.
- **I2 ABBATTUTA, ed e' la scoperta piu' importante di questa apertura.**
  L'ipotesi era che i `.mov` non fossero tracciati da git. **Lo sono, e non
  solo: sono gia' DENTRO TRE COMMIT**, `64eef3c3` (AS.08), `f24e7a10` (AS.09)
  e `9c50242d` (AS.10). Sono 411 MB di video entrati nella storia, e sono la
  causa del push che non passa: vedi la voce AT.01.

## Le premesse dell'ordine, e una che cade

- **P1 ABBATTUTA da F2**, come l'ordine stesso dichiara: `pix_fmt=argb`, il
  canale alpha esiste.
- **P2 DA VERIFICARE con una prova reale**, non con la documentazione: si
  carica il file convertito con `ui.instantiateImageCodec` e si pretende
  `frameCount` uguale a 50 e alpha minore di 255 nel primo fotogramma.
- **UNA PREMESSA DELLE REGOLE DI CASA E' FALSA, e si dichiara invece di
  aggirarla.** L'ordine dice che il corpus di riferimento e'
  `Traguardi_165_Revisione_D2.json`. **Quel file non esiste sul disco**:
  `docs/corpus/` contiene B, C e D. Il corpus vivo resta la revisione D finche'
  la D2 non arriva, e le sette condizioni impossibili che la D2 doveva
  correggere restano dichiarate dormienti come nell'ordine AS voce 12.

## Le voci

- **AT.00** Il manifesto prima di tutto. Stato: CHIUSA
  (questo file, nato prima di ogni altra modifica, con la guardia che pretende
  zero voci APERTE alla consegna)
- **AT.01** Igiene del repository. Stato: APERTA
- **AT.02** Conversione dei tre video in WebP animati. Stato: APERTA
- **AT.03** Demolizione dell'apparato precedente. Stato: APERTA
- **AT.04** Il lettore di transizione. Stato: APERTA
- **AT.05** La regia e il frame 21. Stato: APERTA
- **AT.06** Una festa, un traguardo. Stato: APERTA
- **AT.07** Cosa compare al frame 21. Stato: APERTA
- **AT.08** Assegnazione per Maestro. Stato: APERTA
- **AT.09** Misure di accettazione. Stato: APERTA
- **AT.10** Fallback, solo se misurato. Stato: APERTA

## I marcatori, contati sulle righe

VOCI_TOTALI: 11
VOCI_APERTE: 10
VOCI_CHIUSE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
