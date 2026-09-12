# ORDINE DI, IL VIAGGIO DELLO SCIAMANO DIVENTA UN PERCORSO

**Sigla:** DI. **Data:** 12 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`.

**Vincolo permanente:** tutta l'intelligenza a runtime gira su Gemini e
Vertex AI, mai su API Anthropic. **Nessuna build senza ordine del fondatore.**

VOCI_TOTALI: 17
VOCI_CHIUSE: 1
VOCI_SBLOCCATE_E_APERTE: 1

---

## DI.09, prima cosa: IL VIDEO. VERIFICATO E NEL RAMO

L'ordine chiede di verificare il file **prima di qualunque altra cosa**, e di
fermarsi se non c'e'. **Alla prima verifica non c'era**: la testa remota era
`e0e8b825`, e il file non stava su nessuno dei tredici rami remoti, ne' nella
cartella del progetto, ne' fra Desktop, Download, Documenti, Video e il disco
D:. La voce e' rimasta ferma, senza video sostitutivi e senza segnaposto.

**Il fondatore l'ha poi caricato**, e prima di copiarlo:

| misura | attesa | trovata |
|---|---|---|
| dimensione | 2.262.337 byte | 2.262.337 byte |
| SHA-256 | `0db19531...c12c77d` | identica, sul file caricato e sulla copia |
| misura | 720 x 1280 | 720 x 1280 |
| cadenza | 24 fps | 24/1 |
| durata | 8,000 s | 8,000000 s |
| fotogrammi | 192 | 192 dichiarati e **192 contati** uno per uno |
| codifica | H.264 high | h264, profilo High |
| audio | muto | un solo flusso |
| indice in testa | si' | `ftyp moov free mdat` |

Copiato senza ricodifica ne' rinomina in
`brand_assets/mondo_di_sotto/discesa_v1.mp4`, commit `2928464c`, e **il blob sul
remoto ha la stessa impronta**. La cartella e' dichiarata nel pubspec accanto a
`brand_assets/sentieri/` e `docs/stato_asset.json` la conosce.

---

## DI.01, IL TEMA DELLA DOMANDA ARRIVA DAVVERO. CHIUSA

**La premessa dell'ordine e' vera, riletta sul codice.** Lo schermo assegnava
`_temaScelto = d.tema`, l'etichetta *"Una scelta da fare"*; la voce del Mondo di
Sotto cercava `d.id == idDomanda`, l'identificatore `scelta`. E c'era una
seconda riga col confronto sbagliato, quella che decideva quale domanda
apparisse accesa.

**Il campo faceva tre mestieri**: portava l'etichetta, portava `'incontro'` per
la terza via, e faceva da semaforo per saltare il controllo del testo. E'
questo che ha permesso a un'etichetta di entrarci senza che niente se ne
accorgesse.

**LA CURA E' IL TIPO.** `TemaDellaDomanda` e' un enum dei sei temi,
`_temaScelto` e' un `TemaDellaDomanda?`, e l'id delle sei domande **non si
scrive piu' a mano**: si legge dall'enum. **Scrivere l'etichetta dove va il
tema non compila**, provato: il compilatore dice *"A value of type 'String'
can't be assigned to a variable of type 'TemaDellaDomanda?'"*. La terza via e il
semaforo si leggono dalla via scelta. Il diario salva l'id e lo ritraduce in
parole per il riassunto dei Maestri, capendo anche i diari vecchi, che
contengono le etichette.

**LA PROVA FA LA STRADA INTERA**, perche' la guardia dell'ordine DG voce 07 era
verde proprio chiamando il compositore direttamente, con l'id giusto in mano:
**misurava il contenuto, non la strada**. `il_tema_della_domanda_arriva_alla_risposta`
tocca la domanda sullo schermo, scende col dito, apre la nebbia, segue
l'ombra, risale, e legge la risposta **come arriva a schermo**. **Sei domande,
sei riprese.** Vista rossa: col tema nullo nella chiamata, sei cadute su sei.

**Cosa si legge a schermo adesso**, e va detto perche' **non e' ancora
eccellente**: *"Con te e' scesa un tempo che non arriva"* sbaglia il genere;
*"Sei sceso"* da' per scontato un lettore uomo; *"era qualcosa che e' finito.
E' finito."* ripete. Rientrano nella rilettura integrale della voce DI.05.

### Il censimento della stessa famiglia

L'ordine chiede di censire ogni punto dove un'etichetta per persone viene
confrontata con un identificatore stabile. **Tre passate**: i confronti diretti
fra un campo id e un campo etichetta (nessuno); le undici funzioni che cercano
per id una stringa venuta da fuori, coi loro chiamanti (tutte con id scritti
dal codice, e due verificate a fondo: il segno del ricordo dell'oroscopo, che
chi lo rilegge accetta di proposito in tre forme, e i pianeti degli eventi del
cielo, `sun` da tutte e due le parti); le etichette usate come chiave di mappa
o di confronto. **Due parenti veri**:

1. **La matrice dei piani cercava le righe per etichetta**, e ogni ricerca a
   etichetta non trovata ripiegava in silenzio: `haMemoria` su **vero**, cioe'
   la memoria dei Maestri gratis per tutti; `limiteGiornaliero` su **nullo**,
   cioe' illimitato, l'abuso chiuso dall'ordine CE voce 08; `haProfondita` su
   **falso**, cioe' la Profonda tolta a chi l'ha pagata. Bastava ritoccare una
   parola della tabella. E le etichette erano scritte **due volte**, nella
   matrice e nelle costanti `rigaDomande` e sorelle. **Curata col tipo**:
   `RigaDelPiano`, dieci chiavi, ricerche per chiave, l'etichetta resta per la
   tabella. I nomi delle costanti sono gli stessi, e' cambiato il loro tipo.
2. **Il registro lunare delle rune del tramonto era indicizzato col nome
   italiano della fase.** Qui il nome e' l'identita' stessa della fase nel
   modulo lunare, e passarlo a un tipo vorrebbe dire rifare il motore
   astronomico: **curato con una guardia**, che pretende che le chiavi del
   registro siano esattamente i nomi che la fase sa produrre.

**E la cura della matrice ha reso piu' forte una prova vecchia**, che ha
subito trovato due righe con un numero che non sono tetti d'uso: *Eos in dono
alla sottoscrizione*, una quantita' regalata una volta, e *Domanda al Maestro
reale*, **una quota mensile di un servizio umano che nel codice non impone
nessuno**. Dichiarate per nome e ragione. **La seconda va al fondatore**:
l'Illuminato si vede promettere *"una domanda al mese al Maestro reale,
risposta entro 48 ore"*, e niente la implementa.

**LE GUARDIE:** `il_tema_della_domanda_arriva_alla_risposta` e
`le_etichette_non_fanno_da_chiave`, registro a **397**.
