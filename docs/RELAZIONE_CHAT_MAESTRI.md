# Relazione, chat dei tre Maestri (lavoro notturno)

Sintesi di cosa ho cambiato e dei dubbi da valutare al risveglio. Ambito
rispettato: nulla che richieda console o telefono, nessuna voce, nessun avatar
definitivo, nessun passo nuovo di C3.

## Parte 1, rifinitura di Medora

- Navigazione. L'header ora ha una freccia Indietro esplicita in alto a
  sinistra (icona `arrow_back_rounded`) che riavvolge la pila con
  `Navigator.maybePop`. Niente X, niente freccia Avanti, nessuna barra di
  navigazione dentro la chat: resta superficie immersiva. Il tasto di sistema
  Android e lo scorrimento dal bordo popano comunque la route; ho aggiunto nel
  manifest `enableOnBackInvokedCallback` per il gesto di ritorno predittivo su
  Android 13 e oltre.
- Coerenza avatar. Il volto del Maestro compare ora nell'header e nelle bolle
  in tutti gli stati, conversazione inclusa. Ho eliminato i cerchi blu vuoti:
  l'avatar tiene l'icona dorata dietro l'immagine, cosi' non resta mai un
  cerchio vuoto mentre il volto carica o dove il master e' trasparente. Negli
  screenshot headless precarico il volto prima della cattura, cosi' si vede
  gia' decodificato.

## Parte 2, chat completa su Aura e Caligo

Stessa struttura di Medora, con la voce e il dominio di ciascuno. La chat era
gia' generica sul Maestro, quindi ho abilitato l'ingresso per tutti e tre
(prima solo Medora) e riempito i contenuti mancanti.

- Persona. Ho redatto le persone piene di Aura (chakra, energia, respiro, suono
  e frequenze, benessere) e Caligo (rune del Futhark, Albero della Vita,
  archetipi, animali guida, simbologia), fedeli al dominio e con personalita'
  distinta, Aura quieta e avvolgente, Caligo profondo ed essenziale. Restano i
  disclaimer, tradizioni reali, benessere e non cura, nessuna promessa.
  DUBBIO: nel repo non ho trovato il testo definitivo delle loro persone, solo
  le versioni brevi che avevo scritto io. Le ho ampliate in buona fede, da
  rivedere contro il documento Personas quando lo consolidiamo.
- Palette. Aura verde smeraldo e oro, Caligo rosso e oro. Cosmo e aura virano
  sull'accento del Maestro al cambio, come per Medora (gia' gestito dal tema).
- Sottotitolo di dominio sotto il nome: Astrologia e Destino, Energia e
  Benessere, Rune e Simboli.
- Avatar. Uso i master gia' versionati, `Aura-1.png` e `Caligo-1.png`, come
  avatar dell'header, delle bolle e mezzo busto dello stato vuoto, segnaposto
  in attesa del crop dedicato. Il master di Caligo e' lasciato com'e',
  l'armonizzazione la fai tu dopo.
- Suggerimenti. Due categorie, Domande frequenti e Domande personali, curate e
  coerenti al dominio, fino a dodici frequenti. Le personali pescano dai
  luminari, Sole, Luna e Ascendente, letti attraverso il dominio del Maestro
  (per Aura energia e chakra, per Caligo rune, simboli e archetipi).
  DUBBIO: la regola dice che le personali pescano dai luminari, che sono un
  concetto astrologico. Per Aura e Caligo ho legato i luminari della carta
  dell'utente al loro dominio, cosi' restano davvero personali. Se preferisci
  altro criterio per loro, si cambia in un punto solo.
- Stato vuoto. Saluto in voce del Maestro piu' quattro chip d'avvio.
- Accenti corretti, nessuna proposizione dopo la virgola che inizia con e,
  nessun trattino lungo.

## Parte 3, prove e consegna

- `flutter analyze` pulito, tutti i test verdi (installo Flutter in ambiente per
  girarli, qui non compila da solo).
- Test estesi ai tre Maestri: accenti (persona, suggerimenti e testi visibili),
  header senza pulsante di debug, nessuna costellazione quadrata che trapela.
- Nove screenshot headless in `docs/preview`, per ciascun Maestro conversazione,
  pannello suggerimenti e stato vuoto:
  `medora-chat.png`, `medora-chat-suggerimenti.png`, `medora-chat-vuoto.png`,
  e gli analoghi `aura-*` e `caligo-*`. Il workflow committa tutta la cartella.

## Cosa resta fuori, come da tue istruzioni

Regole Firestore, enforcement App Check, APK e prova reale di Vertex non toccati.
Voce Gemini-TTS, avatar animati definitivi e altri passi nuovi di C3 non avviati.

## Nota

Le risposte dei Maestri negli screenshot sono testo di esempio seminato per la
cattura, non output reale di Gemini: la prova della voce vera resta l'APK sul
telefono col backend configurato.
