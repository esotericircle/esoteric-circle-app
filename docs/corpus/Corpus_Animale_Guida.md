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
  viaggio col tamburo, poi il messaggio del momento, sempre nuovo. E'
  l'esperienza ripetibile, il motivo per tornare. Sotto il messaggio ci sono
  Chiedi ancora, il rimando alla lettura di identita', poi Condividi e Parlane
  con Caligo. Le bolle di identita' NON stanno nel viaggio, per non ripetere.

## Le letture

Ogni animale ha una lettura piena, fedele alla simbologia delle opere citate,
senza inventare tratti fuori tradizione. I campi in
`lib/core/rituals/guide_animal_corpus.dart`:

- natura: chi e' l'animale nel simbolo.
- dono: il dono che porta.
- lezione: la lezione che insegna.
- quando: quando si presenta come guida.
- invito: un invito concreto, per oggi.
- messaggi: il repertorio del Messaggio dall'Animale, almeno dodici righe per
  animale, nella voce grave dell'animale e di Caligo, che ruotano coi giorni e
  col Chiedi ancora.

## Arricchimento con l'archetipo

Se esiste un risultato del Test Archetipo, alla lettura si aggiunge una sezione
che intreccia la medicina dell'animale con l'archetipo dominante
(`intreccioArchetipo`): l'archetipo indica la strada, il totem porta la forza.
Senza il Test la sezione non compare e l'animale resta pieno lo stesso.
L'animale NON cambia col Test, per fedelta' e per evitare accoppiamenti forzati.

## Messaggio dall'Animale

Il segno del momento nella voce dell'animale, che cambia sui transiti
(`messaggioDelGiorno`): deterministico dal giorno e dai pianeti che il
dispositivo sa calcolare, il Sole sempre e la Luna quando e' abbastanza piena,
come i Doni del Giorno. Non una promessa, un'intenzione o un segno. Nessun motore
di effemeridi nuovo: i pianeti arrivano da `ArchetypeSky`.

La riga si sceglie deterministica dal repertorio: `_indiceBase` piega l'ordinale
del giorno con la presenza della Luna, modulo la lunghezza del repertorio, cosi'
cambia ogni giorno ma resta stabile nello stesso giorno. Chiedi ancora aggiunge
un offset `tiro`, per scorrere il repertorio, entro un piccolo limite
(`maxTiri`), oltre il quale l'invito diventa tornare domani. Tutto deterministico,
zero AI, zero costo a runtime.
