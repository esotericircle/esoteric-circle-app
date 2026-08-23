# ORDINE BC, il manifesto

**SEI COSE.** Sette voci, dalla BC.00 alla BC.06, sul ramo
`claude/esoteric-circle-master-order-e798aj`. Nasce dal collaudo della build
2196, che il fondatore ha giudicato "finalmente un ottimo lavoro".

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_bc_guard_test.dart`
conta sulle righe.

## Le premesse, verificate prima di lavorare

**Cinque premesse su sei sono esatte. Una e' superata, e si dichiara qui invece
di correggerla in silenzio.**

### BC.01: esatta, e il fatto nuovo ha una causa che nasce da ieri

Il blocco del cielo porta, in colonna: il titolo, la Luna con l'occhiello
della fase in oro, e la riga personale in bianco corsivo. **Fra le due righe
che il fondatore nomina ci sono quattro punti di aria** piu' l'interlinea a
1,3. Le due righe sono `moon.italianName` in oro e `personalLine` in bianco:
la coppia e' quella giusta.

**E il fatto della testa e dei piedi che spariscono col movimento nasce dal
lavoro di ieri.** L'ordine BA voce 02 ha chiuso i Maestri dentro un ritaglio,
perche' non uscissero piu' dal loro riquadro a coprire il testo. **La
parallasse del giroscopio muove le figure dentro quel ritaglio**, e cio' che
prima sbordava adesso viene tagliato: la testa salendo, i piedi scendendo. Non
e' un difetto nuovo comparso da solo, e' il prezzo della cura di ieri, e va
pagato diversamente.

### BC.02: il fatto e' del fondatore, ma la causa scritta nell'ordine e' SUPERATA

**L'ordine dice**: "il testo promette carta natale, memoria dei Maestri,
Sigilli ed Eos, qui e sul server, mentre esegue solo `memory.deleteAllData()`".

**Non e' piu' vero, e non lo e' dalla build 2195.** L'ordine AZ voce 08 ha gia'
curato quella meta': oggi `_chiediLOblio` esegue **tre** cose, non una. Chiama
`memory.deleteAllData()`, poi `DimenticanzaDelTelefono.dimentica()`, che
cancella le chiavi della persona dal telefono, poi `esci()`. Quella premessa
descrive il codice di due build fa.

**Il fatto del fondatore resta intero e va spiegato**, perche' l'ha misurato
sul telefono con la 2196: "il borsellino, i traguardi e altri dati attualmente
restano anche dopo la conferma della cancellazione". Censite le chiavi vere di
`lib/` una per una, **sono 53**: 39 coperte dai prefissi, 4 tenute apposta, e
**dieci scoperte**, di cui due sono falsi positivi (un'interpolazione e un nome
di dominio). Le otto vere che sopravvivono alla cancellazione:

| chiave | dove vive |
|---|---|
| `natal.chart.v1` | **la carta natale**, cioe' la prima cosa che il testo promette |
| `viso.storico` | lo storico del viso |
| `filo.parola_del_giorno` | il filo del giorno |
| `filo.domanda_di_medora` | il filo del giorno |
| `luogo.attuale` | il luogo |
| `avvisi.alba.giaChiesto` | il permesso gia' chiesto |
| `maestro.welcome.rotation.` | la rotazione dei benvenuti |
| `esoteric.voce` | il registro dei guasti |

**Le chiavi del borsellino e del cammino NON sono fra queste**: `borsellino.` e
`cammino.` hanno il prefisso giusto e vengono cancellate dal disco. Quindi per
loro la causa e' un'altra, e va trovata guardando invece che indovinando.

### BC.03: esatta, e la regola violata e' scritta nel codice stesso

La tessera Archetipo vuota apre il Test al tocco e **non porta la freccia**. La
regola esiste gia', dichiarata in `_PassportCard`: *"Se la tessera apre
qualcosa al tocco, la freccia lo dice"*, con `if (onTap != null)` che disegna
il chevron. **Ma la tessera Archetipo non usa quella card**: usa
`_PassportEntryCard`, nata per le voci dietro il velo, che per costruzione
mostra il badge e mai una freccia. L'ordine BB voce 05 le ha aggiunto un tocco
dall'esterno, con un `GestureDetector` che avvolge la card, e la card non lo
sa.

### BC.04: esatta, e la causa e' una riga

I nomi si sovrappongono perche' il testo e' scritto cosi':

```dart
Text(widget.maestro.displayName,
     maxLines: 1, softWrap: false, overflow: TextOverflow.visible)
```

**`softWrap: false` con `overflow: TextOverflow.visible` vuol dire: esci dalla
tua colonna invece di adattarti.** Ogni Maestro sta in un `Expanded`, cioe' in
un terzo della larghezza; il vincitore ha la tipografia cerimoniale, piu'
grande delle altre due, e "MEDORA" a quella misura e' piu' largo di un terzo
dello schermo. Sborda, e finisce sopra "CALIGO".

### BC.05: esatta

Le chiamate programmate oggi sono **tre**, non cinque, e nessuna e' legata a un
Dono: la sera per la Runa del Tramonto, il mattino per le gettate o per il
cielo, e il traguardo a un passo dieci ore dopo. Nessuna si accende o si spegne
per conto suo.

**E il testo del permesso e' quello che il fondatore ha letto**, parola per
parola: *"Posso avvisarti una volta al giorno, quando il sole sorge da te, che
il Rito dell'Alba e' pronto. Un avviso solo, nessun altro."* Con cinque avvisi
quella frase diventa una bugia.

**Gli orari dei cinque Doni esistono gia' nel codice** e sono quelli
concordati: Alba 7:00, Soffio 10:30, Arcano 13:00, Tramonto 18:30, Notte
22:30.

### BC.06: esatta su tutti e tre i punti, e il terzo ha una causa dichiarata

La bolla mostra `$accesi perle accese su $tutti, nella fascia X` **senza il
titolo "I traguardi raggiunti"**, e sotto `prossimo.frase` **senza il titolo
"Il tuo prossimo traguardo"**.

**E il terzo punto e' il piu' grave, perche' il campo sbagliato ha il nome
giusto scritto sopra.** `frase` e' dichiarata nel codice come **"LA FRASE
WOW"**, cioe' quella della festa: si legge una volta sola, nell'istante in cui
il Sigillo si accende, ed e' scritta al passato per definizione. "Il primo Test
Archetipo completato." La bolla la usa per dire **cosa manca**, quindi annuncia
al passato una cosa mai fatta.

**Il campo giusto esiste gia' e lo dice di se' stesso**: `percheConta`, la cui
documentazione recita *"Non e' la frase della festa: quella si legge una volta
sola... Questa si legge PRIMA, sul sentiero, e deve far venire voglia di
raggiungerlo."* C'e' anche `nome`, *"il nome proprio del traguardo, quello che
si legge sul sentiero"*, che per quel traguardo vale "Sai quale archetipo ti
somiglia".

## Le voci

- **BC.00** Manifesto e verifica delle premesse. Stato: CHIUSA
- **BC.01** I Maestri in home, e le due righe sopra di loro. Stato: CHIUSA
- **BC.02** La gestione dell'account e dei dati. Stato: APERTA
- **BC.03** La bolla Archetipo nel Passaporto. Stato: CHIUSA
- **BC.04** I nomi si sovrappongono nella Risonanza. Stato: CHIUSA
- **BC.05** Le notifiche, davvero. Stato: CHIUSA
- **BC.06** La bolla dei traguardi nei Sentieri. Stato: CHIUSA, con dodici nomi lasciati al fondatore

## L'ordine di lavoro, deciso qui

Si comincia da cio' che si ripara in una riga e si vede subito, e si tiene per
ultimo cio' che tocca il server e la vita dei dati di una persona.

1. **BC.04**, che e' una riga sola e un difetto che si vede ogni volta che
   qualcuno si registra.
2. **BC.03**, che e' una freccia e una regola gia' scritta da applicare.
3. **BC.06**, che e' lingua e scelta del campo giusto, senza rischi.
4. **BC.01**, che tocca il lavoro di ieri e va MISURATO su tutte e tre le
   misure di schermo prima e dopo, perche' la copertura del testo non deve
   tornare.
5. **BC.05**, che e' lavoro nuovo: cinque chiamate al posto di tre, ognuna con
   il suo interruttore, piu' la schermata che le governa.
6. **BC.02** per ultima, perche' e' la piu' pesante e la sola che cancella per
   sempre: tocca telefono e server insieme, e va scritta in modo che ogni voce
   faccia esattamente cio' che dichiara.

## I marcatori

VOCI_TOTALI: 7
VOCI_APERTE: 1
VOCI_CHIUSE: 6
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0

## Cosa BC.06 lascia al fondatore, e perche' non l'ho deciso io

**Il caso che il fondatore ha citato e' risolto.** La bolla mostrava
`frase`, che nel modello si chiama *"LA FRASE WOW"* ed e' quella della festa:
al passato per costruzione, perche' festeggia una cosa appena avvenuta. Adesso
mostra `nome`, e per quel traguardo la riga passa da **"Il primo Test
Archetipo completato."** a **"Sai quale archetipo ti somiglia"**.

**Ma il fondatore ha enunciato un principio, non solo un caso**: non si scrive
come fatto cio' che non e' fatto. Contati sui 165 traguardi, **dodici nomi
sono scritti come una cosa gia' avvenuta**, e il primo dei Fiori di Loto e' uno
di quelli: chi apre quel sentiero il primo giorno legge "Hai ricevuto il primo
Soffio" sotto il titolo "IL TUO PROSSIMO TRAGUARDO".

I dodici: *La tua carta e' nata*, *La prima stesa*, *Una domanda ripresa*, *LA
COSTELLAZIONE COMPIUTA*, *Hai gettato le prime rune*, *Il tuo Animale ti ha
trovato*, *La notte compiuta*, *Hai ricevuto il primo Soffio*, *Il mattino
aperto*, *Il primo respiro guidato*, *Il respiro compiuto*, *IL LOTO APERTO*.

**Non li ho riscritti, ed e' una scelta dichiarata.** I nomi dei traguardi sono
contenuto del mondo del Cerchio, scritti nella voce dei Maestri: sono materia
del fondatore, non di chi sviluppa, e riscriverli sarebbe mettergli in bocca
parole sue. La prova
`test/la_bolla_dei_traguardi_dice_quale_e_quale_test.dart` li conta, li stampa
a ogni giro e tiene fermo il numero a dodici, cosi' la decisione resta
possibile invece di dimenticarsi.
