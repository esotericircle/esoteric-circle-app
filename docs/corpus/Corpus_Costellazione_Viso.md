# Corpus della Costellazione del Viso

Fonte di verita' dei testi della Costellazione del Viso, l'esperienza distintiva
di Aura. La geometria del volto si MISURA in modo deterministico dai contorni
rilevati sul dispositivo; i significati sono la tradizione con la nostra
curatela. Nessuna AI a runtime, nessun testo generato: tutto viene da qui.

## Fondazione

Fisiognomica reale: la Personologia di Edward Vincent Jones, giudice e studioso,
resa popolare da Naomi Tickle. E' un metodo che lega proporzioni e forme del
volto a tendenze del carattere. Non e' una diagnosi ne' una previsione: e' una
lettura simbolica, uno specchio. Il disclaimer globale unico si mostra
all'onboarding, non ripetuto qui. Il pannello "Fonti e metodo" nella schermata
lo dichiara (`FaceCorpus.fontiEMetodo`).

## Come si misura

La classificazione sta in `lib/core/face/face_classifier.dart`, funzione pura e
deterministica: stessi contorni, stesso responso. Per ogni categoria si misura
una proporzione (una distanza, un rapporto, un angolo), la si confronta con una
soglia dichiarata e se ne ricava la variante e la MARCATEZZA, cioe' quanto la
proporzione si stacca dal neutro. Il tratto DOMINANTE, quello con la marcatezza
piu' alta, da' il titolo evocativo del responso. I pareggi di marcatezza si
sciolgono con l'ordine canonico delle categorie.

Alcune proporzioni (la fronte sfuggente o verticale, gli zigomi pronunciati) su
un volto frontale si approssimano dalla geometria disponibile: e' curatela
dichiarata, non misura di profilo. Il ripiego tattile
(`FaceClassifier.daSelezioni`) alimenta lo stesso motore dalle selezioni
guidate, con una salienza curata per far emergere un dominante.

## Le categorie e le varianti

Undici categorie, con le letture fedeli alla Personologia. Il nome della
variante e il titolo evocativo stanno in `lib/core/face/face_trait.dart`, le
frasi di lettura in `lib/core/face/face_corpus.dart`.

- Forma del volto: tondo (socievole e caloroso, attento agli altri); quadrato
  (forza interiore e determinazione, pratico); ovale o lungo (mente analitica e
  riflessiva, diplomatico); triangolare, fronte larga e mento stretto (idee e
  immaginazione, creativo).
- Fronte: sfuggente (pensa in fretta, va al risultato); verticale (metodico,
  analizza prima di decidere).
- Sopracciglia: dritte (pensiero logico sui fatti); curve (orientato alle
  persone); ad angolo (mente organizzatrice).
- Distanza degli occhi: ravvicinati (grande messa a fuoco, sensibile ai tempi,
  poco tollerante degli errori); distanziati (visione ampia e tollerante).
- Grandezza degli occhi: grandi (espressivo, aperto alle emozioni); raccolti,
  piccoli o profondi (concentrato e intuitivo).
- Naso: lungo (pianifica e valuta); corto (vive il presente, agisce).
- Labbra: piene (generoso nel dare e nel parlare); sottili (essenziale e
  misurato).
- Bocca: larga (generoso e aperto); piccola (raccolto).
- Mento: ampio (costante e fermo); a punta (rapido e adattabile).
- Mascella: larga (volonta' salda e tenace); stretta (flessibile).
- Zigomi: alti e pronunciati (ama la sfida e l'avventura); morbidi (cerca calore
  piu' che conquista).

## La sintesi e i transiti

La sintesi calda del responso si costruisce in modo deterministico
(`FaceCorpus.sintesi`) intrecciando le frasi dei tratti piu' marcati. Con
l'interruttore dei transiti acceso si aggiunge una riga di sincronicita' dal
cielo del giorno (`FaceTransits`), deterministica dal Sole e dalla Luna come nel
Test Archetipo: nessun motore di effemeridi nuovo, il cielo si accosta e non
causa.

## Privacy

Il rilevamento del volto e' on-device (`google_mlkit_face_detection`, contorni).
Nessuna immagine lascia il dispositivo, nessuna foto viene salvata oltre l'uso
del momento. Chi non ha fotocamera o nega il permesso passa dal ripiego tattile.
