# ORDINE DW, LA CONDIVISIONE E L'INVITO, FUNZIONE PER FUNZIONE

**Sigla:** DW. **Data:** 18 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Parte dal commit `45fa4572`
(build 2269).

**Il fatto, dal fondatore**, dopo la prova sul telefono: *"ti sei dimenticato
di aggiungere i pulsanti per la condivisione che inserisci sempre e quindi non
crea nemmeno la card di condivisione. devi sistemare. fai un censimento per
tutte le funzionalità, verifica tutto ciò che riguarda la condivisione e
invita un amico e anche come e la facilità nell'invito."* E con uno screenshot
dall'iPhone di un altro fondatore: *"c'è qualcosa che non va, devi anche
controllare per iPhone"*.

VOCI_TOTALI: 8
VOCI_CHIUSE: 8
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

Il rapporto sta in `docs/ordini/RAPPORTO_ORDINE_DW.md`.

---

## I FATTI, RISCONTRATI SUL CODICE E SUL TELEFONO PRIMA DI USARLI

| cosa dice il fondatore | il riscontro | esito |
|---|---|---|
| l'Arcano dell'Alba non ha i pulsanti di condivisione | **vero**: `ArtiConResponso.senzaAzioni['alba']` lo esenta, per l'ordine DT voce 02 che vietava ogni comando sulla schermata; il rapporto DT lasciava la decisione aperta. Visto sul Realme con la 2269: in fondo al responso non c'è niente | **VERO** |
| quindi non crea nemmeno la card | **vero**: non esiste una card dell'Arcano da condividere; le altre nove arti con card ne hanno una (`*_share_card.dart`) | **VERO** |
| sull'iPhone c'è qualcosa che non va | **vero**, e non solo sull'iPhone: *Manda a qualcuno* della festa di un traguardo manda **un testo solo**, senza link all'app e senza immagine; la frase del traguardo e' scritta per chi l'ha acceso (*"tu eri qui"*) e la legge l'amico; le virgolette sono dritte (`BonusDellaCondivisione.perIlTraguardo`, `condivisionePrivata`) | **VERO** |
| (non detto) il Soffio del Destino | condivide **solo testo** (`breath_destiny_screen.dart`, `_shareWord`), nessuna card | **TROVATO** |

---

## LE VOCI

- **DW.01**, il censimento: ogni punto dell'app da cui parte una condivisione o
  un invito, cosa parte davvero (testo, immagine, link, codice), il premio, e
  ogni funzione con un responso che non condivide o condivide solo testo. Sta
  in `docs/condivisione/CENSIMENTO.md`.
  **Fatto**: `docs/condivisione/CENSIMENTO.md`, prima e dopo, funzione
  per funzione, e cio' che resta con il nome di chi lo deve fare.
  **CHIUSA.**
- **DW.02**, l'Arcano dell'Alba ha Custodisci, Parlane e Condividi, dalle
  azioni comuni, e **Condividi manda una card immagine**: la carta, la parola,
  il gesto col suo perche', la chiusura di Medora, il marchio. L'esenzione
  `senzaAzioni['alba']` si toglie.
  **Fatto**: le tre azioni comuni sotto la carta rivelata, solo a carta
  girata; la card `ArcanoDellAlbaShareCard`; il Parlane con un'apertura
  che non nomina l'Arcano, perche' il riconoscitore degli intenti la
  rimanderebbe alla schermata. Vista rossa togliendo le azioni.
  **CHIUSA.**
- **DW.03**, il Soffio del Destino condivide una card immagine, non un testo
  solo.
  **Fatto**: `SoffioShareCard`, col soffione del rito e il loto di Aura.
  La guardia DW.08 era rossa sul Soffio, e sul Soffio soltanto.
  **CHIUSA.**
- **DW.04**, la festa di un traguardo: il messaggio che parte e' scritto **per
  chi lo riceve**, porta il link all'app con l'invito, e ha la sua immagine.
  E' lo screenshot dell'iPhone.
  **Fatto**: i tre testi riscritti per chi li riceve, con il link
  dell'invito in tutti e tre e le virgolette basse; la card del Sigillo
  disegnata fuori campo. Vista rossa rimettendo la frase del traguardo:
  cadono tutti i 165 Sigilli.
  **CHIUSA.**
- **DW.05**, invitare un amico e' facile: da dove si invita, quanti tocchi
  servono dalla home, cosa riceve l'amico, se il premio si attribuisce.
  Gli attriti trovati dal censimento si tolgono o si dichiarano.
  **Fatto, con le decisioni del fondatore**: *Invita un amico* nel menu'
  Account; la domanda *Ti ha invitato qualcuno?* torna una volta, solo
  dopo la prima registrazione e mai nel Santuario; 60 Eos a tutti e due
  (`EOS_A_CHI_ARRIVA_CON_UN_INVITO`, da distribuire dal PC). Il link che
  apre l'app e l'attribuzione automatica restano, dichiarati nel
  censimento.
  **CHIUSA.**
- **DW.06**, un dominio solo: le card stampano indirizzi presi da un punto
  solo (`Brand`), e quell'indirizzo esiste.
  **Fatto**: Oroscopo e Stesa stampavano *esotericircle.com*,
  l'Archetipo un percorso che nessuno gestisce; ora tutto legge `Brand`.
  Vista rossa rimettendo il dominio a mano nella Stesa. **Il dominio
  `esotericircle.app` non risponde in HTTPS**: lo attiva il fondatore.
  **CHIUSA.**
- **DW.07**, l'iPhone: i percorsi di condivisione hanno cio' che iOS pretende
  (l'origine del foglio di condivisione, i file temporanei), verificati sul
  codice e sulla build di Codemagic.
  **Fatto**: `PortaDellaCondivisione.origineDelFoglio`, passata da tutte
  e quattro le chiamate. Vista rossa prima: quattro su quattro senza.
  La prova su iPhone vera viene con la build di Codemagic.
  **CHIUSA.**
- **DW.08**, la guardia: ogni arte con un responso monta le azioni comuni con
  una card immagine, e un'esenzione vale solo se dichiarata a frase.
  **Fatto**: in `custodisci_e_parlane_test.dart`, sulle undici arti che
  condividono. Rossa sul Soffio prima della sua card.
  **CHIUSA.**

---

## COME SI MISURA, VOCE PER VOCE

| voce | la grandezza misurata |
|---|---|
| 01 | il censimento enumera i punti dal codice, non a memoria, e ogni riga ha file e riga |
| 02 | sulla schermata rivelata ci sono le tre azioni; la card si disegna e ha carta, parola, gesto e perche' |
| 03 | il Soffio passa da una card immagine alla porta della condivisione |
| 04 | il testo privato della festa non contiene *tu eri* rivolto a chi riceve, contiene il link, e parte con un'immagine |
| 05 | i tocchi dalla home fino all'invito, contati sul telefono |
| 06 | nessuna card scrive a mano un dominio diverso da `Brand.domain` |
| 07 | ogni chiamata di condivisione passa l'origine del foglio che iOS chiede |
| 08 | la guardia vista rossa sul Soffio, che mandava un testo solo |
