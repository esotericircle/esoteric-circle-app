# Corpus dell'Animale Guida

Fonte di verita' dei testi dell'Animale Guida, il wow personale di Caligo. La
derivazione e' deterministica e fissa per persona; i significati sono la
tradizione sciamanica con la nostra curatela. Nessuna AI a runtime, nessun testo
generato: tutto viene da qui, da `lib/core/rituals/guide_animal_corpus.dart`.

## Fondazione

Sciamanesimo, in particolare il core shamanism di Michael Harner, e la
letteratura degli animali di potere: Ted Andrews (Animal Speak), Steven Farmer
(Animal Spirit Guides), Jamie Sams e David Carson (Medicine Cards). Un'onesta' e'
dovuta e dichiarata nel pannello "Fonti e metodo": nella tradizione l'animale di
potere si TROVA col viaggio sciamanico, non si calcola dall'astrologia. La nostra
derivazione dal segno solare e' un ponte di curatela, un modo per offrire un
totem coerente col cielo della persona, non un responso della tradizione. Non e'
una diagnosi ne' una previsione: e' intrattenimento e crescita, uno specchio. Il
disclaimer globale unico si mostra all'onboarding.

## Derivazione

Deterministica e fissa per persona, dal segno solare del profilo (la stessa
sorgente di Oroscopo e Sinastria), con una tabella di curatela biiettiva sui
dodici animali che hanno l'arte gia' a bundle
(`lib/core/rituals/animal_catalog.dart`). Funzione pura in
`lib/core/rituals/guide_animal_derivation.dart`, coperta da test.

- Ariete, Falco
- Toro, Orso
- Gemelli, Volpe
- Cancro, Lupo
- Leone, Aquila
- Vergine, Gufo
- Bilancia, Cervo
- Scorpione, Serpente
- Sagittario, Cavallo
- Capricorno, Tartaruga
- Acquario, Corvo
- Pesci, Lince

L'animale e' un fatto identitario dalla sola data di nascita, come la fase
lunare, quindi compare vivo nel Cosmic Passport.

## Due ingressi: identita' e viaggio

L'Animale Guida ha due porte distinte, servite dalla stessa schermata con un
parametro `GuideAnimalMode`.

- Identita', dal Cosmic Passport (`GuideAnimalMode.identita`): la lettura fissa
  di chi e' il tuo animale, natura dono lezione, quando ti guida, l'invito, e se
  c'e' il Test l'intreccio con l'archetipo. Non cambia mai, e' la carta
  d'identita' del totem.
- Viaggio, dal dominio di Caligo (`GuideAnimalMode.viaggio`, il default): il
  viaggio col tamburo, poi il Messaggio del Giorno, uno solo al giorno, dal
  transito reale che tocca la carta. Sotto il messaggio c'e' il blocco di
  trasparenza che dichiara come nasce, il rimando alla lettura di identita', poi
  Condividi e Parlane con Caligo. Le bolle di identita' NON stanno nel viaggio,
  per non ripetere.

## Le letture

Ogni animale ha una lettura piena, fedele alla simbologia delle opere citate,
senza inventare tratti fuori tradizione. I campi in
`lib/core/rituals/guide_animal_corpus.dart`:

- natura: chi e' l'animale nel simbolo.
- dono: il dono che porta.
- lezione: la lezione che insegna.
- quando: quando si presenta come guida.
- invito: un invito concreto, per oggi.
- messaggi: il repertorio del Messaggio del Giorno, almeno dodici righe per
  animale, nella voce grave dell'animale e di Caligo. Dal repertorio si sceglie
  la riga del giorno in base al tema del transito.

## Arricchimento con l'archetipo

Se esiste un risultato del Test Archetipo, alla lettura si aggiunge una sezione
che intreccia la medicina dell'animale con l'archetipo dominante
(`intreccioArchetipo`): l'archetipo indica la strada, il totem porta la forza.
Senza il Test la sezione non compare e l'animale resta pieno lo stesso.
L'animale NON cambia col Test, per fedelta' e per evitare accoppiamenti forzati.

## Messaggio del Giorno, dal transito reale

Uno solo al giorno, nella voce dell'animale, dal transito che tocca la carta
dell'utente. Il motore e' `lib/core/rituals/guide_animal_day.dart`
(`GuideAnimalDay.per`), che riusa `NightSky`, lo stesso cielo su cui poggiano
l'Oroscopo e i Doni del Giorno, senza un secondo motore di effemeridi.

Composizione, tutta deterministica, zero AI, zero costo a runtime:

- Transito primario: la Luna di transito di oggi (`NightSky.moonSign`, l'unico
  pianeta veloce calcolabile offline con il Sole) e il suo aspetto PER SEGNO al
  Sole natale (il segno solare dell'utente, l'unico punto natale garantito
  offline). L'aspetto si ricava dalla distanza fra i due segni: congiunzione,
  sestile, quadrato, trigono, opposizione o nessun aspetto maggiore. Niente orbo
  fine, per onesta' con cio' che il dispositivo sa davvero.
- Tema: la natura dell'aspetto diventa un tema (armonia, sfida, intensita',
  quiete). Dal tema piu' il totem si sceglie in modo deterministico la riga dal
  repertorio dell'animale, con la stessa hash FNV-1a a 32 bit dell'Oroscopo.
- Stabilita': ancorato al mezzogiorno del giorno locale, resta fisso fino alla
  mezzanotte e si ricalcola dopo, come l'Oroscopo e i Doni. Nessuna casualita'.

## Trasparenza, come nasce il messaggio di oggi

Sotto il messaggio, un blocco dichiarato in chiaro (`_Trasparenza`) mostra due
cose, generate dagli stessi dati del calcolo, non scritte a mano caso per caso:

- Il transito di oggi in parole, es. "Oggi la Luna in Sagittario passa lontana
  dal tuo Sole in Cancro".
- I dati della carta natale usati: il Sole natale (sempre, dal segno) e la Luna
  natale quando la data di nascita e' nota (`NightSky.moonSign` sul momento di
  nascita). L'Ascendente NON compare: senza il motore a effemeridi completo non
  e' calcolabile offline, e non si inventa, per il Protocollo Verita'.
