# RAPPORTO DELL'ORDINE EO

La nuova home a schede, i domini riordinati e il LIVE piu' pronto. Ordine e
lavoro del 26 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`.
Manifesto `docs/ordini/ORDINE_EO_MANIFESTO.md`, prove in `docs/collaudo/EO/`,
quelle del telefono in `docs/collaudo/EO/realme/`. Le tue consegne: *"Procedi
Senza fermarti, se hai domande, usa le risposte consigliate. Fai tutti i test
su Cell e controlla che tutto funzioni anche su iPhone. Alla fine, quando sei
sicuro che è tutto ok, consegna nuova build"* e *"Non consegnare la versione
iPhone,.prima devo controllare io"*. Build Android 0.1.0+2283; iPhone non
consegnato.

## LE VOCI CHIUSE, CON LA LORO PROVA

- **EO.01, gli sfondi delle schede**: `docs/collaudo/EO/realme/eo10_eo13_dominio_medora.png`. **99 WebP su 99** nel repository e registrati; sul Realme le 30 arti col loro sfondo.
- **EO.02, com'e' fatta una scheda**: `docs/collaudo/EO/eo02_09_guardia_verde.txt`. Titolo sotto, a sinistra, **rimpiccioliti 0 su 56** schede della home (anche a testo 1,3); prima uno, l'Oroscopo Personalizzato nella bolla.
- **EO.03, il tocco**: `docs/collaudo/EO/realme/eo03_tocco_oroscopo_registro_e_fotogrammi.txt`. Sul Realme **317 ms dal tocco alla fine dell'uscita, 0 fotogrammi persi**.
- **EO.04, la "i" gira la scheda**: `docs/collaudo/EO/realme/eo04_la_i_gira_rigira_e_dal_retro_entra.png`. Gira, rigira dallo stesso angolo, dal retro entra: **3 su 3** sul Realme; area della "i" 48 punti.
- **EO.05, le arti in arrivo**: `docs/collaudo/EO/realme/eo05_in_arrivo_si_gira_e_si_rigira.png`. Si gira da sola e dice **"In arrivo, Fase 2"**; pagine aperte **0**.
- **EO.09, le righe della home**: `docs/collaudo/EO/realme/eo17_home_scorsa_in_giu_nessun_doppione.png`. **10 righe su 10** e **56 schede su 56** contro il tuo elenco, coi formati tuoi.
- **EO.10, l'ordine dei domini**: `docs/collaudo/EO/realme/eo10_eo13_dominio_aura.png`. Domini nell'ordine tuo **da 1 su 3 a 3 su 3**, 30 schede su 30.
- **EO.11, i due nomi nuovi**: `docs/collaudo/EO/eo11_dopo.txt`. Righe a video coi nomi vecchi **da 9 a 0**.
- **EO.12, il Test Archetipo solo nel Passaporto**: `docs/collaudo/EO/eo10_13_prove_verdi.txt`. Nel dominio di Aura **da 1 a 0**; il Passaporto lo apre.
- **EO.13, la riga "In arrivo"**: `docs/collaudo/EO/realme/eo10_eo13_dominio_caligo.png`. **24 arti** in fondo ai domini (7, 8, 9), sfondo del Maestro, icona in oro, clessidra.
- **EO.14, i tempi del LIVE**: `docs/collaudo/EO/live/logcat_eo14_dopo_medora.txt`. Dalla fine della domanda al Maestro che parla, stesse domande: **mediana da 6,3 a 4,8 secondi**; la risposta scritta compare **da 4,1 a 2,3 secondi**.
- **EO.15, le voci predefinite**: `docs/collaudo/EO/eo15_voci_dei_live_dal_server.txt`. Erinome, Sulafat, Algenib: **40 sintesi su 40** nei LIVE di oggi.
- **EO.16, "Dal vivo" accanto ai contatori**: `docs/collaudo/EO/realme/eo08_eo16_consulta_apre_la_chat_dal_vivo_accanto_ai_contatori.png`.
- **EO.17, nessun doppione in vista**: `docs/collaudo/EO/eo17_doppioni_in_vista_dopo.txt`. Schede doppie in vista **da 5 a 0** su 20; sul Realme 20 schede in vista tutte diverse.

## LE TRE VOCI APERTE, E LA DOMANDA A TE PER CIASCUNA

1. **EO.08, "Consulta" sotto "Entra".** Sul formato del tuo telefono lo spazio
   sotto non c'e' senza rimpicciolire i Maestri: col pulsante sotto il busto
   centrale scende da oltre 260 a 245 punti e i tre Maestri dal 30 al 28 per
   cento della schermata, cioe' sotto le misure che avevi chiesto tu. Adesso
   "Consulta" sta **accanto a "Entra", in tondo** con l'icona della chat, e
   sta sotto solo sugli schermi molto alti. **Domanda: va bene accanto, o lo
   vuoi sotto anche coi Maestri piu' piccoli di 15 punti?** Consiglio:
   accanto.
2. **EO.06 ed EO.07, il riflesso dell'oro e la scheda al centro.** Sul tuo
   Realme le animazioni del telefono sono a zero, e il telefono lo dichiara
   come riduzione del movimento: per l'ordine, riflesso e sollevamento li'
   sono spenti. Li vedi sull'iPhone. Fotogrammi misurati: 59,7 al secondo col
   riflesso e senza. **Domanda: sul tuo telefono li vuoi accesi lo stesso?**
   Consiglio: si', perche' chi mette le animazioni a zero di solito vuole un
   telefono piu' rapido, non un'app senza luce; il tocco e il giro della
   scheda li ho gia' tenuti accesi per questo.

## COSA HO TROVATO E RIPARATO STRADA FACENDO, CON IL SUO PADRE

- **La scheda che svaniva restava sopra l'arte aperta** (EO.03), visto sul
  Realme alla prima build di prova: l'uscita si fermava a meta' perche' la
  home coperta ammutolisce i suoi ticchettii. Riparato, e la prova che lo
  prende e' caduta sul codice di prima.
- **Un rettangolo scuro sotto i titoli delle schede laterali** (EO.07), visto
  sul Realme con la build di misura: l'ombra copriva tutto il riquadro.
  Riparato.
- **Il pulsante sotto "Entra" rimpiccioliva i Maestri** (EO.08), preso dalla
  suite intera: vedi la domanda qui sopra.
- **Una seconda iscrizione all'accelerometro** (EO.06): la regola della casa
  ne vuole una. Il riflesso legge adesso l'inclinazione della parallasse.
- **La risposta a flusso del LIVE non passava dal controllo della
  troncatura** come la guardia pretende (EO.14, gia' spinta ieri). Riparato.
- **La cartella degli sfondi mancava nel manifesto degli asset, e la sua
  guardia non dichiarava il cardinale** (EO.01, gia' spinta). Riparato.
- **L'istruzione dei Maestri e' cambiata coi nomi delle sezioni** (EO.11):
  rifatta l'attribuzione cieca, tre giri, **90,0, 87,7 e 89,5 per cento**,
  media 89,1, sopra la soglia di 85 ma **tre punti e sette sotto il 92,8
  dell'ordine EN**: Calìgo si confonde di nuovo con Aura e con Medora. La
  causa non l'ho misurata.
- **Una domanda di Aura si perdeva nel LIVE** tre volte su tre: tutte le
  trascrizioni tornavano vuote mentre il controllo della frase l'aveva
  capita. Adesso vale l'ultimo controllo. PROVENIENZA IGNOTA per la
  trascrizione vuota.
- **Un commit spinto con una guardia rossa** (`dc75e426`, EO.11, lo storico
  delle impronte che nominava due sezioni sulla stessa riga): la catena di
  comandi non leggeva l'esito della prova. Riparato nel commit dopo, dieci
  minuti piu' tardi. Il difetto e' mio, del modo di lavorare.
- **Le etichette brevi "Tarocchi" e "Oroscopo" sono uscite** con lo scaffale
  di prima (EO.02): la scheda porta il titolo del catalogo, come l'ordine
  chiede, e non lo rimpicciolisce.

## IL LIVE, NEL DETTAGLIO

Dalla fine della domanda al Maestro che parla, sul Realme, le stesse domande
di stamattina: Medora 4,4, 4,7, 4,8 secondi (prima 6,9, 5,9, 7,7); Aura 4,8,
4,8, 4,2, 5,0 (prima 6,2, 5,7, 7,5); Calìgo 4,8, 4,9, 5,1 (prima 6,8, 6,3,
6,3). Il guadagno viene da Flash-Lite e dalla risposta che e' gia' pronta
quando la frase si chiude. **La chiusura a 1,3 secondi scatta di rado**: la
trascrizione anticipata impiega da 1,1 a 1,8 secondi e arriva quando la
chiusura normale dei due secondi e' vicina. Per guadagnare ancora mezzo
secondo si puo' cominciare la trascrizione prima; costa piu' trascrizioni per
frase, e la decisione e' tua.

## L'IPHONE

Da Windows un iPhone non si accende, e la build iOS la lanci tu su Codemagic,
che la carica su TestFlight: non l'ho lanciata. Ho fatto la parte che si puo'
fare da qui: l'app intera montata con la piattaforma iOS, alla misura di un
iPhone 13, con la fisica di scorrimento e i gesti di iOS
(`docs/collaudo/EO/su_iphone_piattaforma_ios.txt`): le dieci righe, una riga
che scorre di lato, il giro della scheda, "Consulta" che apre la chat, il
dominio a sezioni con "In arrivo". Tutto verde. Nessun permesso nuovo:
riflesso e schede non aggiungono sensori.

## LE PROVE

La suite intera e lo sbarramento: vedi la sezione della consegna qui sotto.
Guardie nuove: otto, tutte viste rosse con l'innesto verificato (registro
`docs/guardie.md`, da 525 a 533).
