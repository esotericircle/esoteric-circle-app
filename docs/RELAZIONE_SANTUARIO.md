# Relazione, Santuario e navigazione viva

Lavoro notturno autonomo. Questa relazione racconta cosa è stato fatto sulle
tre parti richieste, le scelte di messa in scena e i dubbi aperti che restano
per Mauro. Nessun intervento ha toccato console, telefono o asset definitivi di
Mauro: niente voce, niente lip sync, niente avatar finali. I busti e i volti
usano i master versionati già in repo come segnaposto.

## Paletti rispettati

- Nessuna operazione che richieda la console Google, il telefono o asset nuovi
  di Mauro.
- Nessuna voce, nessun lip sync, nessun avatar definitivo.
- Consegna a screenshot headless più questa relazione.
- Regole Firestore, App Check, APK e test Vertex reali non toccati.

## Parte 0, correzioni

### Freccia Indietro al posto della X

Verifica sul campo: l'header della chat non conteneva una X, usava già
`Icons.arrow_back_rounded`, cioè una vera freccia Indietro. La chat è una route
spinta con `MaterialPageRoute`, non un modale, quindi la freccia riavvolge
correttamente la pila. Se sul simulatore era comparsa una X, era cache vecchia
della build. Ho comunque blindato il comportamento:

- header con `automaticallyImplyLeading: false` e `leading` esplicito a freccia
  Indietro, tooltip "Indietro", azione `Navigator.maybePop`;
- nessuna barra di navigazione dentro la chat, esperienza immersiva;
- nessuna freccia Avanti;
- `android:enableOnBackInvokedCallback="true"` nel manifest, così il tasto di
  sistema Android e lo scorrimento dal bordo popano la stessa pila.

### D eufonica

Aggiunto `lib/core/lang/euphonic.dart` con `aEuphonic(String next)`, che
restituisce "ad" davanti a vocale e "a" altrimenti. Applicato al placeholder
della chat, che ora scrive "Scrivi ad Aura" e "Scrivi a Medora", "Scrivi a
Caligo". Un test copre la forma per tutti e tre.

## Parte 1, il Santuario

Non esiste in repo una "Specifica del Santuario" formale: i briefing la citano
solo come Home immersiva con bottom bar dei Maestri e transizione globale del
tema al cambio Maestro. Ho quindi costruito sui punti dati nel compito,
segnalando qui gli scostamenti.

Schermata unica, palcoscenico architettonico antico e neutro:

- Luna in alto che illumina la parte alta della scena, buio e vuoto attorno
  alla figura centrale.
- Tre mezzibusti in primo piano: il centrale è il più grande ed è l'ultimo
  Maestro usato, i due dietro sono più piccoli, arretrati e smorzati.
- Marcatore discreto per il Maestro preferito, una piccola stella, distinto
  dall'ultimo usato.
- Profondità 2.5D: ogni Maestro emerge dalla sua cornice a card colorata, la
  testa sfonda il bordo superiore, la cornice resta dietro in parallasse.

Cambio Maestro in due modi:

- carosello dei busti, quello scelto avanza al centro e si ingrandisce;
- barra in basso.

Al cambio, in contemporanea: i busti ruotano, l'aura di quel Maestro diventa
predominante, il cosmo vira verso il suo accento con dissolvenza cromatica, la
luce lunare scorre sui busti. Saluto breve, circa un secondo, non bloccante,
con varianti a rotazione, quando un Maestro raggiunge il centro (placeholder).

Ingresso al dominio: il tocco sul Maestro centrale entra nel dominio in modo
rapido. Lo spell a schermo pieno resta riservato alla prima volta, non ancora
cablato.

Bottom bar a cinque voci: Santuario, Medora, Caligo, Aura, Cosmic Passport. Il
Passport è distinto dagli altri con icona a tessera. L'ordine dei tre Maestri
in fila è quello fisso, Medora, Caligo, Aura.

Accessibilità, Reduce Motion: parallasse minima, busti fermi, niente stella
cadente. Il cosmo interrompe l'animazione quando il sistema chiede meno
movimento o quando il Quality Tier è basso.

Wow 1, cielo reale: il cielo del Santuario mostra la Luna nella sua fase reale
corrente. Non esisteva in repo un motore astronomico, quindi ho aggiunto
`lib/core/astro/moon_phase.dart`, un calcolo autosufficiente della fase lunare
dalla data (mese sinodico e frazione illuminata), con nome italiano della fase.
Negli screenshot compare "Luna calante", coerente con la data di cattura. Se un
domani arriva un motore astronomico ufficiale, questo si sostituisce dietro la
stessa interfaccia.

Wow 2, il cerchio visibile: un filo d'oro sottile di luce collega i tre
Maestri, discreto, dietro i busti.

Performance, vincolo primario rispettato:

- solo il centrale è vivo, con respiro e animazione idle segnaposto;
- i laterali sono più scuri, arretrati e quasi fermi;
- non ci sono mai tre busti animati insieme;
- il Quality Tier degrada su device deboli, il cosmo si ferma in tier basso.

## Parte 2, navigazione viva

Mai un vicolo cieco. La pila è: Santuario, poi dominio, poi chat, e ogni passo
si riavvolge con la freccia e col tasto di sistema.

- Dal Santuario, il tocco sul Maestro centrale apre il suo dominio.
- Il dominio è un hub minimale con l'ingresso "Parla con il Maestro" verso la
  chat esistente, più le funzioni del dominio mostrate come tessere Coming soon
  in grigio, con badge dorato. Per ottenere questo senza toccare gli stati del
  catalogo, che servono al checkpoint Demo, ho aggiunto un `forceComingSoon` a
  `FeatureGrid` e `FeatureTile`, usato solo dall'hub.
- La freccia Indietro del dominio torna al Santuario, quella della chat torna
  al dominio.
- Il Cosmic Passport è la quinta destinazione distinta, per ora una schermata
  segnaposto pulita con le voci future già elencate e marcate "In arrivo".

## Parte 3, prove e consegna

- `flutter analyze` pulito, nessun problema.
- Tutti i test verdi.
- Test di navigazione nuovi in `test/navigation_test.dart`: Santuario, dominio,
  chat e ritorno con la pila che si riavvolge; la bottom bar che cambia il
  Maestro centrale; l'ordine fisso Medora, Caligo, Aura.
- Screenshot headless in `docs/preview/`:
  - `santuario-medora.png`, `santuario-caligo.png`, `santuario-aura.png`, con
    aura e cosmo virati sul Maestro centrale;
  - `dominio-medora.png`, l'hub con le funzioni Coming soon;
  - `passport.png`, il Cosmic Passport segnaposto.

## Dubbi aperti per Mauro

1. Nessuna "Specifica del Santuario" formale in repo. Ho costruito sui punti
   del compito. I briefing citano anche card quotidiane in Home, Oracolo del
   Giorno, Soffio del Destino, Rito dell'Alba, Runa del Tramonto, oroscopo e
   mood tracker: non fanno parte di questa scena eroe e restano da collocare in
   un passo successivo. Da confermare se vanno nel Santuario o in un livello
   sotto.
2. Il Maestro preferito è fissato a Medora come segnaposto. Va collegato alla
   vera preferenza dell'utente quando esisterà la sua persistenza.
3. Palcoscenico architettonico: è un fondale segnaposto neutro. L'asset ricco
   arriverà da Mauro e si innesta al posto del fondale attuale.
4. I busti usano i master versionati dei Maestri come segnaposto. Servono i
   veri mezzibusti quando pronti.
5. I saluti al centro e l'animazione idle sono placeholder, con varianti a
   rotazione. Lo spell d'ingresso a schermo pieno alla prima volta non è ancora
   cablato.
6. Il calcolo della fase lunare è autosufficiente. Se arriva il motore
   astronomico ufficiale (effemeridi svizzere via FreeAstroAPI), va sostituito
   dietro la stessa interfaccia, per il cielo del Santuario e per il resto.

Fermato qui, come richiesto.
