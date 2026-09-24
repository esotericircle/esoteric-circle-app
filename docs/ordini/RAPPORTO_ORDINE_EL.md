# RAPPORTO DELL'ORDINE EL

L'Alba si apre alzando il sole. Ordine del 25 settembre 2026; lavoro del 24
settembre 2026 sera sull'orologio della macchina, in coda all'ordine EK come
hai chiesto. Ramo `claude/esoteric-circle-master-order-e798aj`. Manifesto
`docs/ordini/ORDINE_EL_MANIFESTO.md`, prove in `docs/collaudo/EL/`.

## LA VOCE CHIUSA, CON LA SUA PROVA

- **EL.01, l'ingresso del sole**: `docs/collaudo/EL/registrazione_del_sole.mp4`,
  col foglio `prova_del_sole.txt` e la tavola `tavola_del_sole.png`. Sul Realme,
  dal tocco sul dono dell'Alba: a 0,54 secondi la notte col sole
  sull'orizzonte e l'invito, il dito alza il sole e il cielo si illumina fino
  a 5,71 secondi, a 6,14 secondi le carte. Prima dell'ordine EL il dono si
  apriva direttamente sulle carte.

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
lo misura 12,23 contro il 4,5 preteso. Registro delle guardie a 511.

## I DIFETTI E I LORO PADRI

- L'ingresso del sole perso: **ordine DT**, voci DT.01 e DT.02, commit
  `47b3c2be`.
- Nessun altro difetto nuovo in quest'ordine.

## LA BUILD

L'ordine chiede, finito tutto, una build nuova su App Tester: e' la 2280, con
gli ordini EK ed EL insieme. I dati della consegna sono nel rapporto EK.
