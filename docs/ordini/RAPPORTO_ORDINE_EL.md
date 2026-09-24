# RAPPORTO DELL'ORDINE EL

L'Alba si apre alzando il sole. Ordine del 25 settembre 2026; lavoro del 24
settembre 2026 sera sull'orologio della macchina, in coda all'ordine EK come
hai chiesto. Ramo `claude/esoteric-circle-master-order-e798aj`. Manifesto
`docs/ordini/ORDINE_EL_MANIFESTO.md`, prove in `docs/collaudo/EL/`.

## LE VOCI CHIUSE, CON LA LORO PROVA

- **EL.01, l'ingresso del sole**: `docs/collaudo/EL/registrazione_del_sole.mp4`,
  col foglio `prova_del_sole.txt` e la tavola `tavola_del_sole.png`. Sul Realme,
  dal tocco sul dono dell'Alba: a 0,54 secondi la notte col sole
  sull'orizzonte e l'invito, il dito alza il sole e il cielo si illumina fino
  a 5,71 secondi, a 6,14 secondi le carte. Prima dell'ordine EL il dono si
  apriva direttamente sulle carte.
- **EL.02, il Taglia che ricompone il mazzo**, la voce che hai aggiunto in
  chat: `docs/collaudo/EL/registrazione_del_taglio.mp4`, col foglio
  `prova_del_taglio.txt` e la tavola `tavola_del_taglio.png`. Sul Realme, dal
  tocco su Taglia: il tavolo largo 849 pixel diventa un mazzo largo
  121 pixel a 0,60 secondi, due pacchetti affiancati fra
  1,08 e 1,52 secondi, e il tavolo e' di nuovo steso a
  2,21 secondi. Prima il Taglia non mostrava niente sul Realme, e una
  volta ha lasciato il tavolo vuoto per un secondo.

**Il giudizio a video resta tuo.**

---

## DOVE VIVEVA IL VECCHIO INGRESSO

Nel commit `8a19e6b8`, file `lib/features/rituals/dawn_rite_screen.dart`, il
Rito dell'Alba: il trascinamento alle righe 252-269, il tocco che compie
l'alba alle 271-293, la scena col suo gesto alle 571-621, l'invito *"Trascina
in alto, oppure tocca"* alle 727-789, il motore del sole alle 804-946. Il gesto
era nato col commit `bf5661e9` del 15 luglio 2026. Le tre immagini della scena
(`assets/ritual_backgrounds/dawn_sky_night.png`, `dawn_sky_day.png`,
`dawn_sun.png`) erano ancora nel pacchetto, senza piu' nessuno che le usasse.

**Ora vive in `lib/features/rituals/il_sole_dell_alba.dart`**, rimesso com'era:
lo stesso trascinamento di 220 punti, la stessa soglia, lo stesso tocco di
ripiego, lo stesso motore del sole. L'unica aggiunta: a sole salito la scena
resta illuminata 450 millesimi prima che arrivino le carte; poi si dissolve in
700 millesimi mentre il tavolo dei ventidue entra a spirale. Dalla stesa delle
carte in avanti **niente e' cambiato**. Riaprendo il dono nello stesso giorno si
torna al responso e il sole non si ripete, come avevi deciso il 17 settembre.

## L'ORDINE CHE LO CHIEDEVA, E IL PADRE DELLA REGRESSIONE

**Sul ramo la tua richiesta di tenere l'ingresso non c'e'.** L'ho cercata in
tutti i manifesti e i rapporti dal DS all'EK, in `docs/`, nei messaggi dei
commit e nelle trascrizioni delle sessioni presenti su questa macchina, con
*"ingresso"*, *"col dito"*, *"verso il cielo"*, *"alza il sole"*, *"solleva"*,
*"stesso ingresso"* e *"gesto del sole"*. Le trascrizioni del 17 settembre,
il giorno degli ordini DT e DU, su questa macchina non ci sono: se l'avevi
scritto li', o in chat con l'Architetto, non e' arrivato in nessun testo sul
ramo.

**Il padre e' l'ordine DT, voci DT.01 e DT.02, commit `47b3c2be` del 17
settembre 2026.** Le voci scritte dicevano *"via il Rito dell'Alba"* e
*"l'Arcano dell'Alba: Medora, le sette, un gesto solo, scegliere una carta
coperta e girarla"* (`docs/ordini/ORDINE_DT_MANIFESTO.md`, righe 44-52): il
gesto solo e' diventato la carta da girare, e la schermata col sole e' stata
cancellata intera. **Nessuna prova se n'e' accorta**, perche' le prove del Rito
sono state tolte con lui e quelle dell'Arcano misuravano il tavolo.

## SCARTI FRA L'ORDINE E IL RAMO

1. L'ordine da' per scritta una tua richiesta di tenere l'ingresso: sul ramo
   non si trova (sopra, con dove l'ho cercata).
2. L'ordine chiede la registrazione dello schermo del Realme: il Realme non ha
   `screenrecord`, e il registratore di sistema non si usa perche' salva
   nella tua galleria e riprende le notifiche. La registrazione e' fatta di
   83 fotogrammi di `screencap`, montati nel video con le loro durate vere.
3. Sul Realme la dissolvenza e la spirale non si vedono: il telefono ha le tre
   scale delle animazioni di sistema a 0,0, e l'app rispetta Riduci
   Movimento. Con le animazioni accese ci sono, e le mostrano le anteprime
   `docs/preview/arcano-alba-sole-prima.png`, `-meta.png` e
   `-illuminata.png`.
4. La prima registrazione ha un buco di tre secondi, `screencap` fermo dopo la
   scena illuminata: la prova e' la seconda, senza buchi.

## LE GUARDIE

**Regola B**, prima di mettere il sole davanti al tavolo, otto guardie della
zona viste rosse con tre innesti verificati col conteggio letterale (la chiave
delle carte cambiata, un'interpolazione riscritta, il corpus del Rito
dell'Alba dato al Maestro sbagliato): `l_arcano_dell_alba_si_gira`,
`il_tavolo_dei_ventidue`, `il_mischia_ricompone_il_mazzo`, `l_alba_si_legge`,
`il_responso_si_legge_ovunque`, `il_censimento_dei_caratteri`, `rito_alba` e
la cattura dell'Arcano delle anteprime.

**Regola A**: la guardia nuova `l_arcano_dell_alba_si_apre_col_sole`, cinque
prove, cade se l'Arcano si apre senza il sole, se le carte arrivano prima che
il sole sia salito, se il dito non lo alza, se un gesto corto lo alza lo
stesso, se manca il tocco di ripiego, o se il sole si ripete a chi riapre.
Vista rossa in cinque giri d'innesto; una volta la prova non cadeva perche'
guardava troppo presto, e ho spostato il momento della misura, non la soglia.
La guardia dell'ordine, `ordine_el_guard`, vista rossa con due innesti nel
manifesto. Le prove che aprono l'Arcano passano tutte dal gesto vero con
`test/alzare_il_sole.dart`, che pretende il sole prima delle carte.
**L'invito sul cielo notturno si legge**: la tabella del contrasto dell'Alba
lo misura 12,23 contro il 4,5 preteso. **Per il Taglia**: `il_tavolo_dei_ventidue` e `il_mischia_ricompone_il_mazzo` viste rosse prima di toccare il tavolo, e la prima era cieca sul Taglia (lo toccava col Mischia ancora in corsa); la guardia nuova `il_taglia_ricompone_il_mazzo`, quattro prove, nata rossa sul Taglia di prima e vista rossa con quattro innesti. Registro delle guardie a 512.

## IL TAGLIA, VOCE EL.02

**Prima**: le due meta' del ventaglio si scostavano e tornavano al loro posto,
nessun mazzo; col movimento ridotto, cioe' sul Realme, a video non cambiava
niente. **Adesso**, in due secondi: le carte si raccolgono nel mazzo, il
pacchetto di sopra si alza e va a destra, i due pacchetti restano affiancati,
quello che era sotto si posa sopra l'altro, e le carte si ristendono dal
mazzo. **Si vede anche con le animazioni di sistema spente**, perche' e' il
contenuto del pulsante. Il Mischia resta com'era, come hai detto: col
movimento ridotto cambia i posti senza animazione. Se vuoi che anche lui si
veda sul telefono con le animazioni spente, e' una riga.

**Il tavolo vuoto.** Registrando il Taglia di prima sul Realme, le carte sono
sparite per circa un secondo dopo il tocco. Con la build nuova non si e'
ripetuto, e la causa esatta non l'ho riprodotta; ma il meccanismo che poteva
farlo c'era: a ogni scambio di posti le ventidue immagini venivano distrutte
e ricreate. Ora le carte si spostano e le immagini restano le loro, 0
ricreate su 22 contro 22 su 22, e c'e' una prova che lo pretende.

## I DIFETTI E I LORO PADRI

- L'ingresso del sole perso: **ordine DT**, voci DT.01 e DT.02, commit
  `47b3c2be`.
- Il Taglia senza mazzo e senza niente da vedere col movimento ridotto:
  **ordine DU**, commit `5e1064f2`.
- Le ventidue immagini ricreate a ogni scambio di posti, e il dorso che
  cambiava forma quando il tocco si spegneva: **ordine DU**, commit
  `5e1064f2`. **E una volta l'ho allargato io**, ordine EL voce 02: per non
  far scegliere un dorso durante i gesti spegnevo il tocco cambiando la forma
  del dorso, e le immagini si ricreavano anche all'inizio e alla fine di ogni
  gesto. L'ha presa la prova nuova prima di ogni consegna, era nella build di
  prova installata sul Realme e non in quella consegnata.
- La prova del tavolo cieca sul Taglia: **ordine EE voce 01**, commit
  `14088e9f`, che ha portato il Mischia da 1.100 a 1.800 millesimi senza
  aggiornare l'attesa della prova, scritta nell'ordine DU.
- L'invito del sole caduto su `etichette_e_lettura`: **ordine EL voce 01**,
  l'invito nel file nuovo; e il file del Rito dell'Alba rimasto fra gli
  ammessi dopo che l'ordine DT l'aveva cancellato: **ordine DT**, commit
  `47b3c2be`.

## LA BUILD

L'ordine chiede, finito tutto, una build nuova su App Tester: e' la 2280, con
gli ordini EK ed EL insieme. I dati della consegna sono nel rapporto EK.
