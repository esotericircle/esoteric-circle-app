# Specifica della Stesa a Tre Carte, Medora, Esoteric Circle

Nota di precedenza: la fonte sovrana dello stato realizzato resta docs/STATO_VIVO.md. In caso di conflitto tra questa specifica e STATO_VIVO, vince STATO_VIVO. Questo file serve come riferimento della regia e dell'intento, non come stato.

Funzione bandiera dell'app, dominio Medora, nella Demo. Regole dai briefing sovrani piu' la regia confermata con Mauro il 19 luglio.

## Cartigli delle carte

Gli artwork delle 78 carte hanno DUE cartigli vuoti, superiore e inferiore. A runtime Flutter sovrappone in font dorato il numerale nel superiore, romano per i Maggiori, arabo o figura di corte per i Minori, e il nome della carta nell'inferiore. Un solo set per tutte le lingue. Si riusa CartiglioText di vip_frame.dart.

Placche misurate sull'arte reale (853 per 1280, cornice madre identica su tutte): superiore x 0,395..0,603 y 0,017..0,069; inferiore x 0,352..0,678 y 0,924..0,965, con rientro dalle volute d'oro. Fatto e verificato al commit a6b3ba6.

## Correzioni ai cartigli, decise il 19 luglio sera

- Il nome nel cartiglio inferiore, sui nomi lunghi, non si comprime su una riga sola, che sembra un errore. Va su DOPPIA RIGA quando serve, spezzando sul "di", per esempio CAVALIERE / DI BASTONI, con lettere non condensate e centrate. Su una riga solo i nomi corti.
- Il numerale nel cartiglio superiore va centrato con precisione, ora non lo e'.
- CAMBIO rispetto a prima: sulla carta rovesciata ruota tutta la carta, cartigli inclusi, quindi anche numero e nome vanno a testa in giu', come una carta vera. Questo perche' il nome leggibile viene comunque ripetuto in grande sotto la carta.
- Il nome della carta va ripetuto in grande e leggibile sotto la carta, accanto alla posizione, perche' nel cartiglio resta piccolo e decorativo. Sotto ogni carta: posizione, nome grande, eventuale rovesciato, riga di significato.

## Regia confermata per la Demo

- Apertura cinematografica. Medora a mezzo busto al centro, le carte emergono dal cosmo, la orbitano in spirale, scendono a ventaglio o doppio ventaglio se lo spazio e' poco, mostrando il dorso identico dritto e capovolto. Intro prodotta da Mauro, handoff sotto. Protagonista una Medora 2.5D a mezzo busto.
- Medora viva. Il mezzo busto respira, sguardo sulla carta attiva, espressioni che cambiano secondo la lettura, serena, sorriso caldo sulle carte luminose, sguardo grave e tenero sulle carte d'ombra o rovesciate. Realizzazione senza Rive obbligatorio: prima strada tre ritratti d'espressione piu' respiro fatto da Flutter, seconda strada ritratto a livelli di Photoshop animato da Flutter, terza Rive con la guida passo passo. Innesto MedoraStage pronto a ricevere l'asset finale.
- Mescolamento. Scuoti per mischiare, vortice a spirale, vibrazione, poi riposo nel ventaglio, fallback tap.
- Taglio del mazzo. Un tocco per tagliare prima di mescolare.
- Respiro del mazzo. Prima della scelta il ventaglio respira piano.
- Scelta. Si sfiora una carta, si alza e si illumina, si tira fuori e vola nello slot con scia di stelle, poi flip. Le tre carte scelte fluttuano e si inclinano col giroscopio, fallback statico.
- Reveal a tema, elementale per seme, fioritura piu' solenne sui Maggiori.
- Suono e vibrazione dietro l'interruttore di silenzio.
- Firma della stesa. Sigillo unico deterministico dalle tre carte, sulla card di condivisione e in piccolo a fine schermata.
- Selettori prima della stesa: chiave con Predittiva attiva e Jodorowsky e Caligo Coming soon; profondita' Breve Media Lunga bloccata Premium; mazzo Rider-Waite attivo con Marsiglia e Thoth Coming soon; interruttore Includi carte rovesciate default attivo.
- Disclaimer una sola volta. Stringere il vuoto in fondo alla schermata.

## Costruzione a tre blocchi

Blocco 1 struttura e stato: correzioni cartigli, nome grande sotto, MedoraStage col respiro e stati, selettori, firma della stesa, card aggiornata, layout stretto. Blocco 2 coreografia: apertura, orbita, ventaglio che respira, taglio, mescolamento a vortice, volo con scia e flip. Blocco 3 sensi: reveal elementale, suono e vibrazione, giroscopio.

## Rimandati all'MVP

Il cielo che ascolta. Il filo del destino. L'eco del passato.

## Handoff dell'intro

L'intro finisce in bianco pieno, Flutter parte dal bianco e dissolve sulla scena viva, Medora in alto al centro e ventaglio in basso nella stessa composizione. Il bianco copre il taglio.
