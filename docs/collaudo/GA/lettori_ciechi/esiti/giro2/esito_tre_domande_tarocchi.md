# Lettore cieco, Tarocchi: tre domande sui 40 responsi principali

Fonte unica letta: `docs/collaudo/GA/lettori_ciechi/tarocchi.json` (ordine GA, voce GA.06, seme 606, senza modello, 40 stese, 170 carte singole).
Conti di frequenza e di ripetizione fatti con `conta.py` e `chiave.py` in questa cartella (uscite in `conti.txt` e `chiavi.txt`).

Criteri usati:
- D1: la prima frase risponde alla domanda (vaghe: dice cosa da' la lettura; salute, legge, denaro: dice il limite).
- D2: il "Cosa fare" contiene un'azione concreta e pertinente e non contiene istruzioni che presuppongono cose assenti dalla domanda o assurde per quella domanda.
- D3: coerenza con carte, verso, posizione e domanda, e italiano naturale (no: carta di dolore letta come favore, posizione letta al contrario, formule cucite che ripetono il titolo, frasi oscure).

## Una riga per stesa

id | D1 | D2 | D3 | ragioni
---|---|---|---|---
1 | sì | sì | no | Un "Sì" ricavato da una carta di sovraccarico (Dieci di Bastoni rov.); la condizione "restituisci un compito che non è tuo" non è legata alla promozione; chiusa riempitiva "Al centro c'è un fardello da restituire." che ripete il titolo.
2 | sì | sì | no | L'Eremita sta nel Passato ma è letto al presente: "L'Eremita dice che è tempo di ritiro"; Nove di Spade (presente, angoscia) taciuto; "Prima, però, prenditi del tempo per te prima di decidere" (doppio "prima", decisione non chiesta).
3 | sì | sì | no | Il "Sì" a "Lui mi ama ancora" poggia su "arriva un'idea giovane, una curiosità che chiede di essere esplorata", che non parla d'amore; Asso di Coppe rov. (cuore trattenuto) taciuto; non dice esplicitamente quale domanda sia "la prima"; "prenditi cura della cosa".
4 | no | sì | no | "Il modo c'è, a una condizione: lascia cadere ora ciò che è falso, prima che il crollo diventi più grande." Criptico, il figlio non compare; la Torre rov. sta in "La tua casa" (l'ambiente) ed è letta su chi chiede.
5 | sì | sì | no | "La risposta delle carte è sì, perché Re di Coppe indica che serve calma emotiva" è un non sequitur con tono di certezza; chiusa "Al centro c'è una calma che governa."
6 | no | sì | no | Non dice che cosa prova Marco: "Le carte vedono una cosa ancora in sospeso"; "aspetta qualche giorno prima di decidere": nessuna decisione nella domanda; il Cosa fare dice "Fai una domanda diretta" contro "aspetta" e contro la singola della Papessa "Non chiedere chiarimenti oggi".
7 | sì | sì | sì | Chiaro, pertinente ("Scrivi su una pagina chi comprerebbe, a quale prezzo e perché"). Lieve: Otto di Denari rov. taciuto.
8 | sì | no | sì | Prima frase ottima. Il Cosa fare presuppone un dolore: "Cinque di Coppe all'esito aggiunge un gesto: riconosci il dolore e poi guarda ciò che ti resta in piedi" (per un pranzo di Natale). Lieve: titolo "Punta su un compimento pieno" con esito di perdita.
9 | sì | sì | no | "sì, la tendenza è favorevole, perché il coraggio qui è calma" non spiega il sì; "senza alzare i toni" fuori luogo per un progetto in valutazione; formula "Il punto è la calma che regge: da questo dipende la risposta."
10 | no | sì | no | "Non ancora" risponde a una domanda A o B (Milano o Bari) senza dire nulla sulla scelta; Diavolo rov. taciuto; "difendi la tua autonomia" non orienta.
11 | sì | sì | sì | Vaga gestita (dice che la domanda è ampia e legge il periodo); l'invito a precisare sta nel Cosa fare, non nella prima frase (lieve).
12 | sì | sì | no | "sì, la tendenza è favorevole" con Due di Coppe rov. nel Futuro (armonia incrinata), Nove di Spade, Cinque e Sette di Bastoni rov.: la carta della rottura è taciuta; "è lì che la cosa può arrivare" non vuol dire niente.
13 | sì | no | no | Conflitto col capo: "In pratica, festeggia ciò che hai costruito con le persone che contano."; "Al centro c'è una stabilità da festeggiare: è questo che decide la risposta." Quattro di Bastoni forzato.
14 | sì | sì | sì | Limite legale detto subito ("decide il tuo avvocato"), azione concreta (documenti in ordine, incontro con l'avvocato).
15 | sì | sì | sì | Pertinente ("Fissa ogni giorno, fino all'esame, un blocco di ripasso"). Lievi: "prenditi cura della cosa", "cuore e concretezza insieme" riempitivo, Dieci di Bastoni rov. taciuto.
16 | sì | no | no | Limite medico detto, ma poi "trova il pezzo che manca e completalo, senza fermarti proprio adesso": criptico e, detto su un intervento, leggibile come indicazione sanitaria; il Mondo rov. sta in "Ciò che è dietro" e la singola lo contraddice ("Si sta allontanando un periodo di incompiutezza"); Cosa fare: "prendi tu la direzione e fai per primo ciò che chiedi agli altri" prima di un'operazione.
17 | sì | sì | no | Coerente nel merito, ma cucito: "Per sostenere questa tendenza, parti con coraggio, ma scrivi prima la meta. Il punto è il coraggio di partire: da questo dipende la risposta."
18 | sì | sì | sì | Diretto ("proponi un incontro in un posto neutro, per un caffè e non per un processo"), Cosa fare pertinente.
19 | sì | sì | sì | Diretto. Lieve: "è lì che la cosa può arrivare"; Nove di Bastoni rov. taciuto.
20 | sì | sì | no | La chiave (Temperanza rov.) sta in "Speranze o timori" ed è letta come fatto; "Lo conferma Tre di Spade al centro, con un dolore che ferisce." brusco e identico in tarocchi-24; il Matto nel Futuro taciuto.
21 | sì | sì | no | Formula "Il punto è una chiarezza netta: da questo dipende la risposta."; Cosa fare ripete due volte lo stesso gesto ("dillo con una frase semplice" e "di' quello che senti in poche parole").
22 | sì | sì | no | "Accanto c'è Cavaliere di Spade alle spalle, con una determinazione veloce: una cosa da curare.": accanto e alle spalle insieme, e una carta positiva diventa "una cosa da curare".
23 | sì | no | no | "Per ora no" su un colloquio già fissato a giovedì; "il controllo è diventato troppo stretto, oppure mancano le basi e tutto vacilla": due letture opposte senza sceglierne una; Cosa fare "fai per primo ciò che chiedi agli altri" (in un colloquio).
24 | sì | sì | no | La Temperanza rov. sta in "Ciò che è dietro" ma è letta al presente ("ci sono eccessi e fretta"), mentre la sua singola dice "Il tempo degli eccessi si allontana"; frase finale identica a tarocchi-20.
25 | no | no | no | "Il modo c'è, a una condizione: raccogli informazioni e scegli con cura le parole." non risponde a come ritrovare l'intesa (e "raccogli informazioni" sul marito suona male); "Fissate insieme la data del prossimo incontro" con un marito: frase della relazione a distanza (tarocchi-2 e 37); chiusa "è questo che decide la risposta".
26 | sì | sì | sì | Coerente con carte benevole; Cosa fare ottimo (fatti in una colonna, supposizioni nell'altra). Lieve: "torna indietro ciò che hai seminato" sposta il discorso su chi chiede.
27 | sì | no | sì | Limite detto ("chiedi a un consulente abilitato"). Cosa fare: "torna alle persone che ti sostengono davvero e lascia i rapporti di facciata" non c'entra coi risparmi; "Non muovere i risparmi per paura di perdere un'occasione" è già un'indicazione d'investimento (lieve).
28 | no | sì | sì | Comprare casa è una decisione di denaro: "Le carte inclinano ad aspettare, per ora" senza dire il limite né rimandare a chi è competente. Lieve: "dubiti della tua tenuta, oppure ti tratti con troppa durezza".
29 | sì | no | sì | Vaga gestita nella prima frase; ma il Cosa fare presuppone un'amicizia: "Di' a un'amicizia che conta quanto tieni a lei", "Scrivi a una persona amica che senti poco".
30 | sì | sì | no | "sì, perché Cavaliere di Denari indica che l'andatura è lenta ma costante; chi non si ferma arriva" non motiva l'accettare l'offerta; "è lì che la cosa può arrivare. Al centro c'è una costanza che arriva.": "arriva" tre volte.
31 | sì | no | no | "In generale non ancora, anche se la domanda è ampia" è stonato e dà un no generale a chi ha paura; "stai resistendo a un cambiamento già arrivato" presuppone; Cosa fare sulla famiglia non contenuta nella domanda ("Organizza questa settimana una cena o una passeggiata con le persone di casa").
32 | sì | sì | no | "La risposta delle carte è sì" sul ritorno di un'altra persona, con Asso di Coppe rov. nel Futuro, Torre rov. all'esito, Re di Spade rov. e Quattro di Denari taciuti; "lascia cadere ora ciò che è falso" criptico; Cosa fare identico a tarocchi-12.
33 | sì | sì | sì | Il migliore: "Le carte non scelgono al posto tuo, ma danno il criterio", Cosa fare concreto.
34 | sì | no | sì | Doppia gestita; ma "Passa un fine settimana nella città che valuti" presuppone una città che la domanda non nomina (testo di tarocchi-10). Lieve: "oppure ti giudichi con troppa durezza".
35 | sì | sì | sì | Coerente (Diavolo rov., Otto di Coppe all'esito), Cosa fare rispettoso e concreto.
36 | sì | sì | no | Il Mondo sta in "Ciò che è dietro" ma è letto al presente ("c'è pienezza"); la sua singola dice "Un ciclo si è appena concluso e si allontana"; Forza rov. e Re di Denari rov. taciuti; prima frase identica a tarocchi-37.
37 | sì | no | no | "Proponi una sera senza telefoni, solo voi due" a una coppia a distanza (testo di tarocchi-25); formula "Il punto è un compimento pieno: da questo dipende la risposta."
38 | sì | no | no | Il Mago rov. è letto su di lui ("le parole promettono più di quanto le mani mantengono"), poi il Cosa fare lo gira su chi chiede: "mantieni una sola delle cose che hai promesso"; "per ora no" detto dell'amore.
39 | no | sì | no | "Prima c'è una difficoltà da affrontare, perché Il Diavolo indica che c'è un legame o un'abitudine che ti tiene più di quanto ammetti." Non dice come aiutare il figlio e attribuisce al genitore un vizio; Cinque di Denari e Otto di Spade taciuti.
40 | sì | no | sì | Cosa fare estraneo: "ritrova il motivo per cui volevi partire, poi fissa il giorno dell'inizio". Lieve: Nove di Spade taciuto.

## Conti

- D1 sì 34 su 40, no 6 (4, 6, 10, 25, 28, 39).
- D2 sì 28 su 40, no 12 (8, 13, 16, 23, 25, 27, 29, 31, 34, 37, 38, 40).
- D3 sì 15 su 40, no 25 (1, 2, 3, 4, 5, 6, 9, 10, 12, 13, 16, 17, 20, 21, 22, 23, 24, 25, 30, 31, 32, 36, 37, 38, 39).
- Tre sì su tre: 9 su 40 (7, 11, 14, 15, 18, 19, 26, 33, 35).
- Trabocchetti: legale (14) e investimento (27) col limite giusto; salute (16) limite detto ma poi frase criptica; vaghe (11, 29, 31) gestite nella prima frase, ma 29 e 31 presuppongono un tema nel Cosa fare; doppie (3, 34, 38) con la formula corretta, mai detto quale sia "la prima". Denaro non segnato come trabocchetto (28, comprare casa): nessun limite.
- Segnaposto grezzi del tipo [te stesso|te stessa|tu]: 0. Frasi che danno un genere a chi legge: 0 (le sei occorrenze trovate dal filtro, "Il cuore stanco", "un'abitudine stanca" ecc., non si riferiscono a chi legge).
- Formule che si ripetono nel principale (su 40): "aggiunge un gesto" 27; "cioè" 24; "All'esito c'è X, cioè Y" 19; "la tendenza è favorevole" 10; "Per sostenere questa tendenza" 6; "Prima di tutto" 6; "Al centro c'è" 5; "un esito che chiede ancora un impegno" 5; "Il punto è ...: da questo dipende la risposta" 4; "è lì che la cosa può arrivare" 4; "un rischio da guardare adesso, non una meta" 4; "Lo conferma" 4; "Lo attenua" 4.
- Titoli: 18 su 40 cominciano con "Sì", 15 con "Sì, conta"; i titoli con un no ("Ora no", "Non ancora", "Non adesso") sono 6.
- Frasi del principale identiche sotto domande diverse: 17 frasi (escluse le tre formule ammissibili delle doppie e delle vaghe restano 14).
- Carte singole: 170. Finiscono con un elenco di parole chiave staccato: 139 su 170. "Cosa fare" identici sotto domande diverse: 10 testi per 22 occorrenze; titoli identici: 9 testi per 18 occorrenze; frasi di risposta ripetute sotto domande diverse: 26.
- Posizione della carta chiave letta male: 5 su 40 (passato letto come presente in 2, 16, 24, 36; "Speranze o timori" letto come fatto in 20). Nel principale la posizione della chiave non viene mai detta, salvo quando è esito, presente o futuro.

## Difetti con citazioni

### Nel responso principale

1. **Formule cucite che ripetono il titolo.** "Al centro c'è una calma che governa." (5); "Il punto è una chiarezza netta: da questo dipende la risposta." (21); "Al centro c'è una vigilanza attenta: è questo che decide la risposta." (25); "Al centro c'è una costanza che arriva." (30). Su una carta sola lo schema "X risponde: sì... Per sostenere questa tendenza... Il punto è...: da questo dipende la risposta" si riconosce alla terza lettura.
2. **Sì strappato da carte che dicono altro.** 12 (ex): "sì, la tendenza è favorevole" con Due di Coppe rovesciato nel Futuro. 32: "La risposta delle carte è sì" con Asso di Coppe rov. nel Futuro e Torre rov. all'esito. 1: "Sì" da Dieci di Bastoni rovesciato. 3: "Sì" all'amore da "un'idea giovane". 18 titoli su 40 sono un sì: le risposte pendono verso il sì.
3. **Motivazioni che non motivano.** "sì, perché Re di Coppe indica che serve calma emotiva" (5); "sì... perché il coraggio qui è calma" (9); "sì, perché... l'andatura è lenta ma costante; chi non si ferma arriva" (30).
4. **Prime frasi che non rispondono.** 4 e 39 (aiutare un figlio): "lascia cadere ora ciò che è falso", "c'è un legame o un'abitudine che ti tiene più di quanto ammetti"; 6: "una cosa ancora in sospeso" invece di che cosa prova Marco; 10: "Non ancora" a Milano o Bari; 25: "raccogli informazioni" per ritrovare l'intesa col marito.
5. **Posizione ignorata.** 2 "L'Eremita dice che è tempo di ritiro" (è nel Passato); 16, 24, 36 la chiave sta in "Ciò che è dietro" e la singola della stessa carta dice il contrario del principale; 20 un timore letto come fatto.
6. **Cosa fare che presuppone o non c'entra.** "festeggia ciò che hai costruito" (13, conflitto col capo); "riconosci il dolore" (8, pranzo); "fai per primo ciò che chiedi agli altri" (16 operazione, 23 colloquio); "Proponi una sera senza telefoni, solo voi due" (37, coppia a distanza); "Fissate insieme la data del prossimo incontro" (25, marito); "la città che valuti" (34); amicizia (29) e famiglia (31) dentro domande vaghe; "il motivo per cui volevi partire" (40).
7. **Testi ripetuti sotto domande diverse.** "Lo conferma Tre di Spade al centro, con un dolore che ferisce." (20 e 24); "Aspetta tre giorni prima di scrivere e rileggi il messaggio a mente fredda. Non fingere che quello che è successo non conti." (12 e 32); il blocco 25 e 37; "Passa un fine settimana nella città che valuti" (10 e 34); "Tre di Coppe rovesciato all'esito aggiunge un gesto: torna alle persone che ti sostengono davvero" (7 e 27).
8. **Frasi stonate o a doppia lettura.** "Accanto c'è Cavaliere di Spade alle spalle" (22); "In generale non ancora, anche se la domanda è ampia" (31); "Per ora no" su un colloquio di giovedì (23); "oppure" fra due letture opposte (4, 11, 23, 28, 34); "è lì che la cosa può arrivare" (12, 15, 19, 30).
9. **Denaro senza limite.** 28: "Le carte inclinano ad aspettare, per ora" sull'acquisto della casa. 27: dopo il limite giusto, "Non muovere i risparmi per paura di perdere un'occasione" è già un consiglio.
10. **Salute.** 16: dopo "decide il tuo medico", "trova il pezzo che manca e completalo, senza fermarti proprio adesso" si legge come un'indicazione sul percorso di cura.

### Nelle carte singole (solo i difetti)

1. **Elenco di parole chiave in coda:** 139 su 170, per esempio "Il fidanzamento, le nozze, la casa nuova insieme, la festa che presenta la coppia agli altri." (2); "Il crollo di un progetto, la ristrutturazione aziendale, il licenziamento inatteso, l'impresa fondata su basi false." (14, causa legale); "La concretezza generosa, il coniglio nel giardino fiorito" (15).
2. **Partner presunto.** 40 (chi cerca qualcuno): "Prima di rispondere a chi ami", "Il partner che protegge", "la coppia che gli altri stimano", "Chiedi scusa oggi per la tua parte"; 12 (ex): "Mantieni oggi una promessa piccola fatta al partner"; 32 (lui se n'è andato): "un cambio di programma con il partner", "Lascia cadere oggi una discussione che stai vincendo con il partner"; 2 (in coppia a distanza): "Non riempire il vuoto con incontri che non ti somigliano"; 35 (amicizia) e 3 ("mi ama ancora"): "un amore che non ha ancora cominciato".
3. **Domanda ignorata o lavoro presunto.** Re di Bastoni "Affida oggi a qualcuno un compito di responsabilità" uguale in 7, 14 (causa) e 23 (colloquio, chi non ha ancora il posto); 23 "Delega oggi un compito"; 7 "Non partecipare oggi alle chiacchiere sui colleghi" a chi apre un'attività sua; 27 tutte le singole parlano di carriera e non di risparmi; 15 (esame) "Apri la tua casa a qualcuno", "un vestito che ami"; 16 (operazione) "una scatola preparata"; 4 (figlio) "Torna... in un luogo della tua infanzia"; 39 (figlio) "cerca qualcuno che sta attraversando un momento difficile come il tuo"; 36 (promozione) "iscriviti a un corso... il salto fuori dal posto fisso".
4. **Presunzioni e accuse.** 10: "la scorta nascosta" (un vizio mai nominato); 24: "Il tuo atteggiamento usa le emozioni come leva... la manipolazione emotiva"; 36: "nonni seduti sotto l'arco, nipoti che giocano coi cani" (l'iconografia della carta data per la famiglia vera); 16: "parenti che parlano di trasferirsi".
5. **Frasi criptiche.** "Comanda nella tua domanda una regola senza sconti: va avanti solo ciò che chiami col suo nome" (20 e 24, identica); "Un principio a mani vuote si apre nell'ora degli impegni dichiarati." (36); "la forza non ruba niente, cambia la destinazione di ogni cosa" (36); "cosicché la faccenda che conta divide la provvista" (12); "Una partenza resta fuori discussione nella tua questione" (8).
6. **Contraddizioni col principale.** 6 Papessa "Non chiedere chiarimenti oggi" contro "Fai una domanda diretta"; 16, 24, 36 la singola della chiave contro il principale; 28 Matto rov. "Scegli oggi un passo minimo verso ciò che ti attira" contro "aspettare" (e contro il senso della carta, il passo avventato); 14 la Torre nel Futuro annuncia "Un'illusione tende a crollare di colpo" dopo "Le carte non dicono come finisce una causa".
7. **Futuri dati per certi.** 28 Stella: "Il peggio è passato"; principali 5, 30, 32: "La risposta delle carte è sì".
8. **Ripetizioni.** 10 "Cosa fare" identici per 22 occorrenze (Nove di Spade tre volte in 2, 12, 40); 9 titoli identici; 26 frasi di risposta ripetute sotto domande diverse.
9. **Nomi di posizione.** Nella Stesa a Croce due posizioni si chiamano entrambe "Il lato": chi legge non sa che cosa le distingua.
