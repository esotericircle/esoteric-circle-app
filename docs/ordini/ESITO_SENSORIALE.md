# ESITO dell'ORDINE: LE QUATTRO VOCI E IL LIVELLO SENSORIALE

## I file audio che Mauro deve fornire

Vengono per primi, come chiede l'ordine, cosi' si possono cercare su Envato
mentre il resto procede. Gli slot sono **predisposti nel codice**: appena i file
arrivano in `assets/audio/`, suonano senza toccare una riga.

| Slot | Nome del file atteso | Quando suona | Durata | Peso massimo |
|---|---|---|---|---|
| Firma | `firma.mp3` | All'apertura dell'app, una volta per sessione | 2,0 s | 120 KB |
| Rivelazione | `rivelazione.mp3` | Risonanza, animale, angeli, sigillo | 1,5 s | 100 KB |
| Rito compiuto | `rito_compiuto.mp3` | Chiusura di un rito o di una lettura | 1,5 s | 100 KB |
| Soglia | `soglia.mp3` | Entrando nel dominio di un Maestro | 0,5 s | 60 KB |
| Rifiuto | `rifiuto.mp3` | Quando un limite si chiude | 0,3 s | 40 KB |

**Formato**: MP3, 128 kbps, 44,1 kHz, mono. Mono e non stereo: questi sono
segnali, non musica, e il mono dimezza il peso senza togliere nulla.

**Peso totale**: sotto i 420 KB, quindi entro il mezzo mega richiesto.

**Finche' i file non ci sono l'app non emette nulla e non si rompe**: il ripiego
e' il silenzio, dichiarato nel codice e verificato da un test.

Nota su cosa NON serve: i tre Maestri non hanno tre suoni diversi. Sarebbe
rumore, non identita'.

## Una cosa che non ho potuto leggere

La specifica `Specifica_Livello_Sensoriale_Esoteric_Circle` sta nel Project di
Claude e **non e' raggiungibile dal filesystem**: l'ho cercata nei documenti del
repo e nella cartella dei briefing, non c'e'. Lavoro sul perimetro dell'ordine,
che e' dettagliato, e lo dichiaro qui invece di far finta di aver letto un
documento che non ho visto. Se la specifica contiene scelte diverse da quelle
che faccio, vanno riviste.

## La stima, scritta prima di toccare il codice

### Le quattro voci

- **V1 piena.** La misura si fa sull'AREA DIPINTA, e questo e' il punto: la
  correzione precedente era verde perche' guardava il riquadro del widget mentre
  l'avatar sborda con `Clip.none`. Se il test non riesce a leggere l'area
  dipinta uso il confronto per immagine, e dichiaro quale dei due ho usato.
- **V2 piena, col rischio piu' alto.** Quattro bocciature. Stavolta ho un
  riferimento preciso, e so gia' che il colore e' un difetto a se': nel painter
  avevo scritto `Colors.white` e a schermo esce oro, quindi la mano che si vede
  potrebbe non essere quella che ho corretto. E' la prima cosa che verifico.
- **V3 piena.** Un componente solo, portato in ogni punto, col test che conta
  chi lo usa e denuncia chi adatta un'immagine al riempimento fuori da esso.
- **V4 piena nel codice, col giudizio finale a Mauro.** Non ho dispositivo:
  sfaso, allungo e abbasso l'opacita' di partenza, ma se sul telefono resta
  impercettibile lo puo' dire solo lui.

### Il livello sensoriale

- **S1 piena.** Una dipendenza sola. Il confine `TonePlayer` esiste gia', quindi
  il lettore vero entra dietro la stessa interfaccia. Il rischio non e' il
  codice, e' `flutter pub get`: se la rete non risponde lo dichiaro.
- **S2 piena, e viene prima del suono** come l'ordine prescrive. Sono 17
  chiamate dirette in 7 file da ricondurre ai quattro schemi.
- **S3 piena come struttura, muta come contenuto.** I cinque slot, il catalogo
  come dato, il ripiego silenzioso e il test che vieta i suoni fuori catalogo.
  I file li sceglie Mauro.
- **S4 in VERSIONE SEMPLICE dichiarata: una transizione sola**, quella della
  carta del Maestro che si apre nel suo dominio, che e' il percorso piu'
  frequente. Le altre due restano standard. L'ordine ammette espressamente
  questa riduzione, e la scelgo adesso invece di scoprirla alla fine.
- **S5 piena.** E' il governo di tutto il resto, quindi non e' rinunciabile.

**Se il tempo finisce**, finiscono per ultime V4 e le transizioni di S4. Mai
S1, S2, S5.

## Stato voce per voce

Si compila mentre il lavoro procede.
