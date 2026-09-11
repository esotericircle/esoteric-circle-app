# RAPPORTO DELL'ORDINE DE, IL VIAGGIO DELLO SCIAMANO

**Per Mauro, al risveglio dell'11 settembre 2026.**

Il manifesto completo, con le sedici voci una per una e tutti i numeri, sta in
`docs/ordini/ORDINE_DE_MANIFESTO.md`. Questo foglio dice solo tre cose: che
cosa hai adesso sul telefono, che cosa ho trovato guardandolo, e che cosa
aspetta te.

---

## 1. LA COSA PIU' IMPORTANTE, e non e' una voce chiusa

**Le sedici voci erano chiuse con i numeri, e l'app a video era sbagliata lo
stesso.**

Ieri notte avevo scritto che DE.16, la prova visiva sul telefono, non si poteva
fare mentre dormivi, e che *"le voci che quelle fotografie dovrebbero provare
sono pero' tutte provate al banco, con i numeri"*. Era vero e non bastava.
Stamattina il viaggio l'ho percorso davvero, dalla soglia alla card, e ho
trovato **sei difetti**. Nessuno di loro era visibile da nessuna prova.

Il piu' grave: **alla seconda e alla terza discesa l'animale si vedeva intero,
testa compresa**, mentre lo schermo prometteva *"la lente scopre solo dove
puo', oggi"*. Cioe' esattamente la cosa che l'ordine DE voce 03 esiste per
impedire.

Lo sorvegliavano due guardie. Tutte e due verdi, tutte e due a ragione: una
misurava la **geometria** (il cerchio della lente non tocca il rettangolo della
testa, e non lo toccava); l'altra misurava **l'albero dei widget** (il velo
c'e' ed e' opaco, e c'era ed era opaco, anche con le animazioni spente come sul
tuo telefono). **Il velo era costruito, era opaco, e non dipingeva niente.**

Fra l'albero e i pixel c'era uno `ShaderMask` con `BlendMode.dstIn`: il buco
della lente si ritagliava dal velo con una maschera di fusione, e sul telefono
quella maschera cancellava **il velo intero** invece del suo cerchio. Al banco
funzionava.

**Adesso il velo non usa nessuna maschera**: coltre e fantasma interi, e sopra
un ritaglio circolare dell'animale nitido con dentro il gradiente che torna
alla coltre esattamente sul raggio. Stesso disegno, nessuna fusione chiesta a
nessuno.

E la guardia che lo sorveglia adesso **rasterizza la scena e misura quanto e'
nitido il rettangolo della testa**: centootto fotogrammi, dodici animali per
tre discese per tre posizioni della lente. Il rapporto peggiore fra testa
velata e testa scoperta e' **0,209**. Col velo tolto a mano lo stesso numero va
a **1,000**, ed e' cosi' che l'ho vista rossa prima di crederle.

---

## 2. I SEI DIFETTI, e chi li ha fatti

| # | che cosa si vedeva | padre | stato |
|---|---|---|---|
| 1 | l'animale intero, testa compresa, alla seconda e alla terza discesa | **ordine DE voce 03** | riparato, con guardia nuova vista rossa |
| 2 | *"Non e nuovo"*, *"Questa non e la prima volta"*, *"di la"* | **ordine DE voce 11** | tre accenti rimessi |
| 3 | *"un altra volta"* | **ordine DE voce 11** | apostrofo rimesso |
| 4 | *"mi ha trovato il 11 settembre 2026"*, **sulla card che si condivide** | **ordine DE voce 08** | l'articolo si elide davanti a 8 e a 11 |
| 5 | *"E' il Lince. Adesso lo conosci."* | **ordine DE voce 08** | il genere dei dodici entra nel catalogo |
| 6 | quattro discese, la stessa terna di ombre nelle stesse tre posizioni | **ordine DE voce 03** | la terna resta, cambia l'ordine |

Sui quattro errori di lingua c'e' una cosa da dire che vale piu' della
riparazione. **La guardia che sorveglia gli accenti cercava sei parole**:
*piu*, *gia*, *cosi*, *perche*, *cioe*, *meta*. Sono le sei che qualcuno aveva
gia' sbagliato. **Il verbo essere non ci era mai finito perche' nessuno lo
aveva ancora sbagliato**: un elenco chiuso dice sempre la verita' su ieri.

Adesso c'e' una guardia nuova, `il_verbo_essere_ha_l_accento_test`, che non
cerca parole ma **sette sequenze in cui la lettera `e` non puo' essere una
congiunzione**: *non e*, *che e*, *e la prima volta*, *un altra*, *di la*,
*il 8*, *il 11*. Gira su **20.866 stringhe** di `lib`. L'ho vista rossa
rimettendo *"Non e nuovo"* al suo posto, e verde dopo averlo tolto.

Nel farla ha trovato **due errori miei di un'altra famiglia**, che ho riparato
insieme agli altri: un apostrofo al posto dell'accento nel corpus delle rune
del tramonto, e un messaggio di diagnostica del verso dell'animale.

---

## 3. CHE COSA ASPETTA TE, e sono due cose

**DE.04, l'ingrandimento dei dodici animali.** L'ordine diceva di usare
l'upscaling di Imagen su Vertex AI *"che il progetto ha gia' configurato"*. Ho
verificato: **il progetto `esoteric-circle` raggiunge ventisette modelli e
nessuno e' Imagen**. I quattro che toccano le immagini sono tutti Gemini, e
Gemini **rigenera**, non ingrandisce: userebbe la tua illustrazione come
ispirazione e ti restituirebbe un altro animale. L'ordine dice *"MAI
rigenerare"*, e quindi mi sono fermato. Lo strumento e' scritto e aspetta:
serve che tu accenda Imagen sul progetto.

**DE.05, i tre asset.** Aspettano tre file tuoi. La scala di ripetizione della
texture del tunnel e' gia' dichiarata: **sei giri su tutta la discesa**.

---

## 4. CHE COSA HAI SUL TELEFONO

La build **2247**, con i sei difetti riparati. Le catture di come stava prima
le ho tenute apposta dentro `docs/catture/de_df/`: tre di loro mostrano il
difetto e non la prova, e le tengo perche' un manifesto che mostri solo le
schermate riuscite racconta una giornata che non c'e' stata.

Il viaggio che ho fatto io stamattina e' finito con la Lince. La card diceva
*"MI HA TROVATO LINCE"*, e sotto *"mi ha trovato il 11 settembre 2026"*.
Adesso direbbe *"l'11 settembre"*.
