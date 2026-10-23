# Lettore cieco, Oroscopo: le tre domande su 48 responsi

Fonte letta: `docs/collaudo/GA/lettori_ciechi/oroscopo.json` (ordine GA, voce GA.06, seme 606, senzaModello true, 48 responsi su 48 dichiarati). Nessun altro file aperto. Giorni della settimana di tutte le date citate verificati con un calcolo (tutti giusti). Ripetizioni contate con uno script di sette parole consecutive (`ripetizioni_oroscopo.py`, nella stessa cartella).

Criteri usati:
- D1 sì se la prima frase dice con una parola di giudizio com'e' il periodo nel dominio (favorevole, in salita, stabile, calma, faticosa, propizia...) e quel giudizio va d'accordo con la fascia.
- D2 sì se il Cosa fare dice un gesto preciso che chiunque, nel periodo, puo' fare; no se il gesto vale solo per una situazione che il testo da' per scontata senza offrire un'alternativa.
- D3 sì se nessuna indicazione di tempo esce dal periodo o e' gia' passata, e se dominio, fascia, reggente del rito e simboli citati nel Da dove viene vanno d'accordo con il testo.

## Una riga per responso

oroscopo-1 | D1 sì | D2 sì | D3 sì | Capricorno, giorno, Generale, salita: "Oggi la giornata è in salita". Luna in Ariete in quarta casa solare e in quadratura al Capricorno, Sole in Scorpione in undicesima: case giuste. Difetto non contato: oggi e' domenica 25 ottobre e il testo da' per certi "mezzi in ritardo, code lunghe" e un appuntamento ("Se capisci che non arrivi in orario").
oroscopo-2 | D1 no | D2 sì | D3 sì | D1: la prima frase, "Oggi in amore le parole dette a voce sono calorose e arrivano più dirette di quelle scritte", dice come arrivano le parole, non com'e' la giornata; il favore si capisce solo per deduzione. Rito di Marte di martedi', inno orfico 65 ad Ares: giusto. Luna in Acquario in quinta per la Bilancia: giusto.
oroscopo-3 | D1 sì | D2 sì | D3 sì | "Oggi è una giornata adatta a ragionare sulla tua direzione nel lavoro" (favorevole 4). Luna in Ariete prima casa, Marte in Leone quinta: giusto.
oroscopo-4 | D1 sì | D2 sì | D3 sì | "Oggi la fortuna è serena" (equilibrio). Rito di Marte di martedi' coerente. Difetto non contato: "il Sole in quadratura al tuo Ascendente", ma la scheda porta solo la data di nascita, senza ora: l'Ascendente non si ricava dai dati mostrati.
oroscopo-5 | D1 sì | D2 sì | D3 sì | "Settimana piena ma gestibile" (equilibrio 2,86). Luna piena in Toro lunedi' 26 ottobre 05:11, decima casa del Leone: giusto e dentro la settimana 25-31 ottobre. Rito del Sole di domenica, inno orfico 8: giusto.
oroscopo-6 | D1 sì | D2 sì | D3 sì | "Settimana favorevole agli incontri". Momento chiave sabato 24 ottobre, dentro 20-26. Difetto lieve: "riscrivi la presentazione" rimanda a un profilo sulle app nominato solo come ipotesi nella risposta.
oroscopo-7 | D1 sì | D2 sì | D3 sì | "Settimana lucida nel lavoro". Momento chiave sabato 24, dentro. Rito di Marte di martedi'. Verso dell'inno ripetuto (vedi difetti).
oroscopo-8 | D1 sì | D2 sì | D3 sì | "Settimana fortunata negli incontri casuali". Momento chiave venerdi' 30 ottobre, dentro 25-31.
oroscopo-9 | D1 sì | D2 sì | D3 sì | "Mese favorevole alla compagnia". Momento chiave sabato 31 ottobre, dentro.
oroscopo-10 | D1 sì | D2 sì | D3 sì | "Mese propizio all'amore che nasce o si rinnova facendo qualcosa insieme". Momento chiave mercoledi' 28, dentro. Rito quasi uguale a quello del responso 2 (vedi difetti). Lieve: "iscrivetevi insieme e restate fino alla fine" non dice fine di che cosa.
oroscopo-11 | D1 sì | D2 sì | D3 sì | "Nel lavoro il mese è stabile, non spinge e non frena". Luna nuova in Scorpione lunedi' 9 novembre, seconda casa della Bilancia: giusto e dentro il mese.
oroscopo-12 | D1 sì | D2 sì | D3 sì | "Per la buona sorte il mese è propizio vicino a casa". Ultimo quarto in Leone domenica 1 novembre, undicesima della Bilancia: giusto. Rito dei semi "in questi trenta giorni": dentro.
oroscopo-13 | D1 sì | D2 sì | D3 sì | "l'anno è favorevole all'ospitalità e ai rapporti vicini". Anno dal compleanno martedi' 18 agosto 2026, rito di Marte: giusto. Difetto non contato: "L'Ascendente della tua Rivoluzione Solare è in Cancro" chiede ora e luogo, che la scheda non porta.
oroscopo-14 | D1 sì | D2 sì | D3 sì | "In amore l'anno è favorevole a dire ciò che desideri". Venere in casa 4: intimita', coerente.
oroscopo-15 | D1 sì | D2 sì | D3 sì | "L'anno è in equilibrio sul lavoro ma chiede ordine". Compleanno martedi' 12 maggio, rito di Marte: giusto.
oroscopo-16 | D1 sì | D2 sì | D3 no | D3: l'unico simbolo citato e' "Giove ... nella casa 9, quella dei viaggi, degli studi e dei paesi stranieri", e la risposta dice il contrario: "Qui la sorte sta meno nelle novità e più in ciò che hai già". In piu' l'anno cominciato il 24 novembre 2025 finisce fra cinque settimane, e il testo parla di "L'anno" come se cominciasse.
oroscopo-17 | D1 sì | D2 sì | D3 sì | "Oggi la giornata è stancante" (salita). Luna in Pesci terza dalla Luna in Makara piu' tara Naidhana sfavorevole: il livello 2 si spiega. Rito di Surya di domenica: giusto. Difetto: frase sul Rahu Kalam che dice soltanto che manca un dato.
oroscopo-18 | D1 sì | D2 sì | D3 sì | "Oggi in amore la giornata è adatta a fare spazio". Luna in Pesci undicesima dal Toro: giusto. Difetto lieve: il simbolo dice "gioia" e "la casa del cuore", il testo porta in una giornata favorevole a riaprire "ferite" e "rancore".
oroscopo-19 | D1 sì | D2 no | D3 sì | D2: il gesto presuppone che qualcuno taccia, "scrivi in privato ... a ciascuna delle persone che tacciono", e anche il ramo per chi lavora in proprio presuppone "un fornitore o un cliente che non risponde"; per chi ha colleghi che rispondono, o non lavora (la persona e' nata nel 1962), non c'e' niente da fare. Luna in Capricorno dodicesima dall'Acquario, Mangala di martedi': giusto.
oroscopo-20 | D1 sì | D2 sì | D3 sì | "Oggi la sorte è in equilibrio". Luna in nona dal Toro, "di attenzione": coerente con 3.
oroscopo-21 | D1 sì | D2 sì | D3 sì | "Settimana favorevole e concreta". Giorno migliore mercoledi' 21, dentro. Lieve: il Cosa fare da' per certa la cosa rotta ("le viti, la colla, la lampadina") che la risposta aveva posto con un "Se".
oroscopo-22 | D1 sì | D2 no | D3 sì | D2: "Se hai un legame, passate due giorni come se la scelta fosse già fatta": la scelta esiste solo per chi "parlate di un passo importante"; chi ha un legame senza decisioni in sospeso resta senza gesto. Rito di Mangala di martedi'; "entro il fine settimana" dentro 20-26.
oroscopo-23 | D1 sì | D2 sì | D3 sì | "Settimana di equilibrio nel lavoro". Giorno migliore lunedi' 26, dentro.
oroscopo-24 | D1 sì | D2 sì | D3 sì | "Settimana tranquilla per la fortuna". Rito di Shukra di venerdi' 23: giusto.
oroscopo-25 | D1 sì | D2 sì | D3 sì | "È un buon mese per cambiare un'abitudine". Rito di Shukra di venerdi'.
oroscopo-26 | D1 sì | D2 sì | D3 sì | "In amore il mese è stabile". Giorno migliore domenica 1 novembre, dentro.
oroscopo-27 | D1 sì | D2 sì | D3 sì | "Nel lavoro il mese è favorevole a chi si fa avanti". Rito di Mangala. Lieve: "tre traguardi entro la fine del mese" e' ambiguo (fine di ottobre o del periodo 20 ottobre-18 novembre?).
oroscopo-28 | D1 sì | D2 sì | D3 sì | "Il mese porta buona sorte alle occasioni che hai già". Giorno migliore sabato 24. Sgrammaticato: "la Luna attraversa la undicesima".
oroscopo-29 | D1 sì | D2 sì | D3 sì | "È un anno stabile". Giove favorevole e Sade Sati: equilibrio coerente; il compleanno di venerdi' 6 febbraio regge Shukra: giusto.
oroscopo-30 | D1 sì | D2 sì | D3 sì | "In amore l'anno è favorevole alla seduzione". Giove in Karka undicesima dalla Vergine: giusto. Rito di Surya di domenica 20 settembre: giusto.
oroscopo-31 | D1 sì | D2 sì | D3 sì | "Nel lavoro l'anno procede lento, ma lento non vuol dire fermo" (salita). Difetto: "Saturno era in Mina" senza dire quando; il "era" rimanda al compleanno, che in questo responso non c'e'.
oroscopo-32 | D1 sì | D2 sì | D3 sì | "Quest'anno la sorte è quieta". Giove in decima, "non una delle sue case favorevoli": equilibrio coerente. Sgrammaticato: "Al tuo compleanno del 8 marzo 2026".
oroscopo-33 | D1 sì | D2 sì | D3 sì | "Oggi la giornata è favorevole alle conversazioni tranquille". Coniglio e Cane, una delle sei armonie: giusto. Ufficiale Zhi ("Tenere") del 20 ottobre coerente con il responso 36.
oroscopo-34 | D1 sì | D2 sì | D3 no | D3: la risposta dice "Oggi la vita sentimentale è calma", il Da dove viene dice due volte il contrario: "le Sette Uccisioni ... sono pressione e sfida" e "la prima oggi è di scena nella sua forma dura, pressione e sfida; la seconda oggi se ne va in obblighi e pressioni". Rito Kai del 25 ottobre: giusto.
oroscopo-35 | D1 sì | D2 sì | D3 sì | "Giornata piana nel lavoro". Criptico: "oggi è tenuta a bada dal tuo talento, con più libertà e meno riconoscimenti".
oroscopo-36 | D1 sì | D2 sì | D3 sì | "Giornata faticosa per la fortuna con gli oggetti" (salita). Rito Zhi, "il giorno che trattiene": coerente con il tenere le cose. Inutile: "Il Dio della Ricchezza ... oggi sta a sud-ovest", mai usato.
oroscopo-37 | D1 sì | D2 sì | D3 sì | "La settimana è equilibrata se i pesi si dividono" (giudizio messo sotto condizione, ma nominato). Giorno migliore mercoledi' 28, dentro 23-29. Rito Cheng di venerdi' 23.
oroscopo-38 | D1 sì | D2 sì | D3 sì | "In amore la settimana è dolce". Fine settimana 24-25 dentro. Criptico per l'amore: "nutrita dall'impegno concreto ... ciò che arriva dal lavoro fatto".
oroscopo-39 | D1 sì | D2 sì | D3 sì | "Settimana tranquilla nel lavoro e nello studio". Rito Cheng "entro i sette giorni": dentro.
oroscopo-40 | D1 sì | D2 sì | D3 sì | "Settimana tranquilla per la fortuna". Giorno migliore oggi, venerdi' 23.
oroscopo-41 | D1 sì | D2 sì | D3 sì | "Il mese è equilibrato". Maiale e Tigre, sei armonie: giusto. Il Cosa fare ha l'alternativa per chi non ha passioni: bene.
oroscopo-42 | D1 sì | D2 sì | D3 sì | "Il mese è luminoso per il fascino". Rito Kai di domenica 25. Futuro dato per certo: "ti piaci di più e questa sicurezza si vede". Doppione del 30 (vedi difetti).
oroscopo-43 | D1 sì | D2 sì | D3 sì | "Il mese è sereno e adatto al lavoro di riordino". Giorno migliore mercoledi' 28.
oroscopo-44 | D1 sì | D2 sì | D3 sì | "Per la fortuna il mese è regolare". Lieve: nello stesso responso Cheng e' "che l'almanacco dedica a partire e a trasferirsi" (rito) e "il giorno che compie" (Da dove viene); negli altri responsi e' sempre il compimento.
oroscopo-45 | D1 sì | D2 sì | D3 sì | "l'anno è favorevole ai legami vicini". Anno del Cavallo 17 febbraio 2026-6 febbraio 2027; Tigre, Cavallo e Cane in tripla armonia: giusto.
oroscopo-46 | D1 sì | D2 sì | D3 sì | "In amore l'anno è leggero e favorevole".
oroscopo-47 | D1 sì | D2 sì | D3 sì | "Sul lavoro quest'anno è favorevole ai passi importanti". "da qui al prossimo Capodanno lunare" dentro l'anno. Sgrammaticato: "Il lavoro dell'anno cinese che stai vivendo porta il segno di Cheng, sotto cui è nato a Capodanno" (soggetto di "è nato" diventa "il lavoro").
oroscopo-48 | D1 sì | D2 sì | D3 sì | "Quest'anno la fortuna è generosa con chi dice ad alta voce che cosa cerca".

## Conti per domanda

| Domanda | sì | no | quali no |
|---|---|---|---|
| D1, la prima frase dice com'e' il periodo, coerente con la fascia | 47 | 1 | oroscopo-2 |
| D2, il Cosa fare e' un gesto concreto per chiunque | 46 | 2 | oroscopo-19, oroscopo-22 |
| D3, tutto coerente con periodo, dominio, fascia, reggente, simboli | 46 | 2 | oroscopo-16, oroscopo-34 |

Responsi con tre sì: 43 su 48. Nessun responso ha piu' di un no.

Controlli che hanno dato tutti esito pulito: giorno della settimana di ogni data citata (24 date, tutte giuste); reggente del rito e giorno del primo giorno del periodo (domenica Sole o Surya, martedi' Marte o Mangala, venerdi' Shukra, giovedi' Giove, lunedi' Luna: tutti giusti); momenti chiave e giorni migliori sempre dentro il periodo e mai prima di "oggi" quando il periodo comincia oggi; segni lunari fra responsi diversi coerenti fra loro (Luna tropicale Acquario il 20, Ariete il 25, Toro il 26; siderale Capricorno il 20, Acquario il 21, Pesci il 24 e 25, Ariete il 26, Cancro il 1 novembre); rami cinesi dei giorni coerenti (Coniglio il 20, Maiale il 28) e ufficiali del Tong Shu coerenti (Zhi il 20, Cheng il 23, Kai il 25); animali cinesi giusti per tutte le date di nascita.

## Difetti non contati, con citazioni

### Dati che la scheda non contiene
- oroscopo-4: "il Sole in quadratura al tuo Ascendente". oroscopo-13: "L'Ascendente della tua Rivoluzione Solare è in Cancro". L'Ascendente chiede ora e luogo di nascita; la scheda porta solo la data. Chi legge non sa da dove venga. PROVENIENZA IGNOTA (da chi legge alla cieca non si risale alla voce).

### Vite inventate e situazioni date per certe
- oroscopo-1: di domenica, "mezzi in ritardo, code lunghe e piccoli contrattempi" e "Se capisci che non arrivi in orario" (presuppone un tragitto e un appuntamento).
- oroscopo-19: "a ciascuna delle persone che tacciono" (presuppone colleghi muti).
- oroscopo-22: "passate due giorni come se la scelta fosse già fatta" (presuppone una decisione in sospeso).
- oroscopo-28: "Inviti lasciati senza risposta, proposte messe da parte, messaggi letti di fretta" detto come fatto.
- oroscopo-21: il Cosa fare da' per certa la cosa rotta: "procurati quello che serve: le viti, la colla, la lampadina".

### Futuri dati per certi
- oroscopo-42: "in amore ti piaci di più e questa sicurezza si vede".
- oroscopo-36: "chiavi, occhiali, documenti e caricatori cambiano posto con facilità e si perdono proprio quando servono".
- oroscopo-2 (approfondimento): "un piccolo imbarazzo che oggi passa in fretta e lascia una vicinanza nuova".
- oroscopo-5: "impegni regolari, qualche richiesta in più, nessuna corsa".

### Salute, denaro, legge
- Nessun consiglio vero. Il piu' vicino: oroscopo-30, "regalati un dettaglio ... un profumo, un capo che ami, un taglio nuovo" (spesa suggerita, lieve). oroscopo-15 nomina "diritto" e "contratti equi" solo come lettura della tradizione.

### Frasi criptiche, gergo, rimandi a parti che non ci sono
- oroscopo-34: "La scheda dell'amore le legge come la figura dell'altro" e "la seconda oggi se ne va in obblighi e pressioni"; in piu' il nome "Sette Uccisioni" in una giornata d'amore detta calma.
- oroscopo-35: "oggi è tenuta a bada dal tuo talento, con più libertà e meno riconoscimenti".
- oroscopo-38: "la prima quel giorno è nutrita dall'impegno concreto; la seconda quel giorno è di scena nella sua forma regolare, ciò che arriva dal lavoro fatto" (per l'amore).
- oroscopo-17: "senza la tua città non si può dire quando cade oggi" (una frase per dire che manca un dato).
- oroscopo-36: "Il Dio della Ricchezza, dicono gli almanacchi cinesi, oggi sta a sud-ovest" (indicazione mai usata).
- oroscopo-31: "Saturno era in Mina" senza il quando.
- Otto responsi (22, 24, 25, 27, 37, 39, 42, 44): "Il livello del periodo è la media dei livelli dei suoi giorni, ciascuno letto col metodo del Giorno" (gergo di prodotto, rimanda a un "metodo del Giorno" che chi legge non vede).
- Gergo tecnico non spiegato: "angolare" (13, 14, 15), "cadente" (16).

### Incoerenze lievi coi simboli
- oroscopo-18: simbolo "gioia ... la casa del cuore", testo su "foto che riaprono ferite" e "rancore".
- oroscopo-44: Cheng detto "che l'almanacco dedica a partire e a trasferirsi" nel rito e "il giorno che compie" nel Da dove viene.

### Sgrammaticature
- oroscopo-28: "la Luna attraversa la undicesima" (l'undicesima).
- oroscopo-32: "Al tuo compleanno del 8 marzo 2026" (dell'8).
- oroscopo-47: "porta il segno di Cheng, sotto cui è nato a Capodanno" (il soggetto grammaticale e' "il lavoro").
- oroscopo-36: "Giornata faticosa per la fortuna con gli oggetti" (costrutto goffo).
- oroscopo-10: "iscrivetevi insieme e restate fino alla fine" (fine di che cosa).

### Genere attribuito a chi legge
- Nessuno. Ricerca su aggettivi e participi in seconda persona: zero casi; "single" e "senza legame" sono neutri.

### Testi e riti ripetuti fra responsi
- Verso "mutando la forza delle armi nelle opere di Demetra" in quattro riti: 4, 7, 12, 15.
- Verso "Volgiti al desiderio di Cipride e alle feste di Lieo" in 2 e 10, con lo stesso gesto (un frutto e un brindisi, un frutto e una bevanda da condividere).
- Rito di Cheng quasi uguale in 37 ("Chiudi adesso una faccenda in sospeso"), 45 ("scegli adesso una cosa lasciata a metà e portala a termine"), 47 ("scegli adesso il compito che resta aperto da più tempo e consegnalo"), simile in 39.
- Glossa di Kai identica in 34 e 42: "che l'almanacco antico dedica alle unioni e ai conviti".
- Offerta d'acqua a Surya in 17 ("Versa un filo d'acqua da un bicchiere guardando la luce") e 32 ("Versa un filo d'acqua in un vaso di fiori rivolto al sole").
- Responsi 30 e 42 quasi doppioni: fascino curato, "un profumo, un capo che ami, un taglio nuovo" contro "un abito ..., un profumo, un taglio nuovo", poi coppia a cena o corteggiamento e chi e' senza legame fra gente nuova.
- Attacchi a formula: "Nella vita di ogni giorno l'anno è favorevole" (13, 45); "Settimana tranquilla per la fortuna, che passa" (24, 40).
- Tema del quartiere e delle botteghe in 12, 32, 45 (e 13, 4); tema dell'agenda da svuotare in 5 e 40.
- Chiuse degli approfondimenti a formula: "Il segno buono è" (12, 45), "Il segno che funziona è" (13, 44), "Il segno giusto è" (42); "Il pericolo è" / "Il rischio è" (4, 13, 30, 34, 45).
