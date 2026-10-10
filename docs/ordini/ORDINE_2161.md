# ORDINE 2161, Esoteric Circle

CODE PORTA A TERMINE TUTTO L'ORDINE, OGNI VOCE, FINO ALLA CONSEGNA. Non si ferma a meta', non rimanda voci, non lascia lavoro da ordinare di nuovo. Se il contesto si stringe, comprime i rapporti e non il lavoro. L'unica fermata ammessa e' una premessa falsa.

Ramo canonico `claude/esoteric-circle-master-order-e798aj`. Undici voci, tutte di Mauro, in priorita' assoluta e nel suo ordine. Niente altro entra. La consegna e' ordinata dentro questo ordine, col numero di build **2161**, perche' il contatore e' gia' a 2160 per i due ordini iOS.

Le quindici premesse dell'ordine precedente sono gia' state abbattute in sola lettura, e i loro accertamenti sono scritti dentro le voci come FATTI. Non rifare quel lavoro.

## Premesse da abbattere, solo tre

- **A.** La testa del canonico e' ancora `b6bc55bba92117fd7e67cc10706797b8df4dfe1f`, col contatore di versione a 2160. Se il ramo si e' mosso, dichiara la testa nuova e verifica che i fatti scritti qui sotto reggano ancora.
- **B.** `kDiagnosiAttiva` e' ancora acceso e porterebbe sul telefono del tester l'ingresso a tappe nel Risveglio, le etichette a schermo e il racconto all'avvio.
- **C.** Ne' `CLAUDE.md` ne' gli agenti in `.claude/agents/` vietano quanto ordinato qui.

## Decisione sulla diagnosi

`kDiagnosiAttiva` va SPENTO prima di costruire la 2161. L'interruttore resta nel codice e non si toglie, perche' la diagnosi iOS puo' servire ancora. Una prova cade se una build di consegna parte con la diagnosi accesa.

---

## VOCE 1. L'emblema e le frasi di attesa non si vedono piu' in nessuna chat

Parole di Mauro: l'emblema che compare dall'alto al basso e le frasi di riflessione nelle chat SONO SPARITE DA TUTTE LE CHAT DEI MAESTRI.

**Fatto gia' accertato, e cambia la natura della voce:** il codice NON e' stato tolto. `ConsultoDelCieloView`, `FrasiDellAttesa` e `TempiDellAttesa` esistono, e la scena e' montata in `maestro_chat_screen.dart:536` dietro `mostraLaScenaDiAttesa = _sending && !_seguitoInVolo`. Non e' una cancellazione: e' una scena viva che la persona non vede.

Tre ipotesi, in ordine di forza. Si verificano PRIMA di correggere, dichiarando l'esito anche quando cadono.

1. L'attesa minima garantita non c'e' piu' oppure non e' rispettata, quindi la scena lampeggia e sparisce prima di essere leggibile. I numeri approvati il 4 agosto 2026 sono: emblema che si compone dall'alto verso il basso in **3 secondi**, frasi da **2 secondi** l'una, **minimo garantito due frasi complete**, tempo alla prima parola intorno ai **4,2 secondi**, che e' un aumento voluto. Verifica che quel minimo esista ancora e che governi davvero l'uscita dalla scena.
2. `_seguitoInVolo` e' vero quando non dovrebbe, quindi la condizione spegne la scena.
3. La scena e' costruita ma coperta da qualcosa che le sta sopra, per esempio la barra oppure un foglio.

Correggi la causa che trovi, non le tre insieme. Vale ancora la regola sul contenuto: una frase mostrata durante un'attesa deve dire il vero, e se il dato che nomina manca la frase non compare. Con Riduci Movimento l'emblema appare senza comporsi e le frasi restano.

**Prova a guardia, obbligatoria.** Una prova che ENUMERA le tre chat, monta l'app dall'avvio vero e non il widget in isolamento, e misura per QUANTO TEMPO la scena resta a video, non solo che esista nell'albero. Cade col nome del Maestro se in una delle tre la scena dura meno del minimo garantito. Una prova che conta widget non prende questo difetto, perche' il widget c'e'.

**Rosso:** porta il minimo garantito a zero e la prova deve cadere col tempo misurato.

**Anteprima:** la scena di attesa a meta' composizione, 1080x2391, montata dentro l'app.

## VOCE 2. Nelle chat la barra mostra un fondo pieno

Parole di Mauro: la barra ESPLORA va bene per home e dominio, ma nelle chat torna a farsi vedere lo sfondo slot fisso senza trasparenza e dissolvenza.

**Fatto gia' accertato, e assolve il fondo:** il gradiente vetro di `SantuarioBottomBar` alle righe 60-68 e' UN RAMO SOLO ed e' identico ovunque. Nella chat si legge come rettangolo pieno perche' l'eccezione presa con la 2158, cioe' il `SafeArea` che consuma il fondo, lascia sotto la barra una FASCIA SENZA CONTENUTO: il gradiente scende sul vuoto invece che su cio' che scorre.

Non si tocca il colore della barra: si toglie l'eccezione. **L'eccezione sulla chat e' revocata da Mauro.** Nella chat il contenuto arriva sotto la barra come in home e nel dominio, e il vetro si legge perche' sotto c'e' qualcosa. Il campo di scrittura puo' restare ancorato, perche' e' uno strumento e non contenuto, ma non deve produrre nessuna fascia vuota sotto la barra.

**Prova a guardia.** Una prova enumera le cinque schermate che portano la barra e cade se sotto la barra, in una di esse, esiste una fascia priva di contenuto scorrevole. Non una prova sul colore, che sarebbe verde in tutte e cinque anche adesso: la grandezza da misurare e' cosa c'e' sotto.

**Rosso:** rimetti il `SafeArea` che consuma il fondo nella sola chat e la prova cade nominando la chat.

**Anteprima:** la barra in chat con contenuto vero sotto il vetro, 1080x2391.

## VOCE 3. I suggerimenti sono tre e non sono piu' divisi

Parole di Mauro: nella prima schermata di ogni dominio il Maestro propone solo 3 suggerimenti di domande, prima ce n'erano molte e divise anche in generiche e personali.

**Fatto gia' accertato, ed e' un generatore orfano e non una cancellazione:** le due famiglie esistono in `chat_suggestions.dart`, `SuggestionGroup.frequent` e `SuggestionGroup.personal`, con le etichette "Domande frequenti" e "Domande personali", e per Medora sono otto piu' dodici. Il pannello che le mostra NON e' montato da nessuna parte: la chat monta soltanto `SuggestionSets.starters()`, che sono tre.

1. Trova con `git log -S` il commit che ha staccato il pannello e dichiara sha, data e messaggio. Serve a sapere se e' stato staccato apposta oppure per distrazione.
2. Rimonta il pannello nella prima schermata di OGNI dominio, con le due famiglie e le loro etichette a video. Non riscrivere gli elenchi: usa quelli che esistono, perche' due elenchi che descrivono la stessa cosa divergono sempre.
3. Le domande personali nascono da un dato vero della persona: si compongono in modo deterministico da persona e giorno, passando dalle porte che esistono, e se il dato manca la domanda che lo userebbe NON compare invece di uscire con un segnaposto.
4. Se serve un limite a quante se ne mostrano insieme, e' un numero dichiarato con accanto la ragione, mai un tre scritto a mano.

**Prova a guardia.** Una prova enumera i tre domini, conta i suggerimenti e verifica che tutte e due le famiglie siano presenti in ognuno; cade col nome del Maestro quando una famiglia manca oppure quando il conto scende sotto il minimo ripristinato. Una seconda prova cade se qualcuno monta di nuovo i soli starters.

**Rosso:** rimetti i soli starters in un dominio e la prova cade nominandolo.

**Anteprima:** la prima schermata di un dominio con le due famiglie visibili, 1080x2391.

## VOCE 4. In home manca la striscia delle altre arti del Cerchio

Parole di Mauro: nella home ancora mancano in basso la slide con "le altre arti del cerchio".

**Fatto gia' accertato:** la striscia esiste, si chiama "Scopri altre arti del Cerchio", e vive nel DOMINIO, in `maestro_screen.dart:488`. In home non e' montata. E' il caso "esiste e non e' montato", quindi non si costruisce niente di nuovo.

Monta la stessa striscia in fondo alla home. **Non copiarla:** portala fuori in un punto condiviso e falla usare da tutti e due i posti, altrimenti nasce la ventesima occorrenza della famiglia delle due porte. Legge dal catalogo delle arti, che resta l'unico elenco. In home mostra le arti che non stanno gia' nello scaffale delle tue, e se la regola di selezione deve essere diversa da quella del dominio si dichiara nel codice con la sua ragione.

**Prova a guardia.** Una prova monta la home, scorre fino in fondo e trova la striscia coi suoi elementi; una seconda prova enumera i punti che la mostrano e cade se esistono due costruzioni diverse della stessa striscia.

**Attenzione al precedente:** con la 2156 una fascia in fondo alla home fu dichiarata sparita mentre c'era e si raggiungeva scorrendo. Misura montando l'app e scorrendo, poi dichiara.

**Anteprima:** la home scorsa fino in fondo, 1080x2391.

## VOCE 5. Uruz e' ancora quadrata con i bordi neri

**Fatto gia' accertato:** 94,3 per cento di pixel opachi, sul FRONTE e sul RETRO, immagine 789x869.

Scontorno a chiave di tinta, MAI per distanza RGB. Riempi solo i pinhole piccoli, lascia trasparenti i vuoti veri, togli il residuo di sfondo con despill sui bordi senza mangiare la venatura. Verifica su fondo chiaro E su scacchiera, mai solo sul nero. Poi rigenera il retro DALLA pietra pulita, perche' il retro nasce dalla runa incisa e ne eredita i difetti. L'asset e' sotto lucchetto di CI: dichiara come lo hai sbloccato e rimetti il lucchetto.

**Misura:** percentuale di pixel opachi prima e dopo, per fronte e per retro, col confronto contro la mediana delle altre ventitre. Se Uruz resta lontana dalla mediana, non e' chiusa.

**Anteprima:** le ventiquattro rune affiancate, dove Uruz non si distingue piu' a occhio.

## VOCE 6. Via il rettangolo rosso sotto la gettata

Parole di Mauro: la gettata delle rune mostra uno sfondo quadrato rosso sopra il quale si sistemano le rune, fa cagare e bisogna rimuovere quel cazzo di sfondo quadrato.

**Fatto gia' accertato, e non e' cio' che l'Architetto sospettava:** lo dipinge `_PozzoPainter`. Il rosso e' `_acqua`, un `drawRect` alla riga 1431, cioe' l'acqua del Pozzo nel rosso di Caligo, usata nelle gettate fisse. Il beige e' `_telo` alla riga 1470, il panno di Tacito, usato nel getto libero. Non c'entra la fisica della 2158, che non disegna nulla.

**Decisione dell'Architetto, con la ragione scritta perche' chi legge dopo capisca.**

- **L'acqua rossa del Pozzo sparisce.** Un rettangolo pieno nel rosso di Caligo sotto le pietre e' un fondale bespoke squadrato, ed e' contro la regola del cosmo condiviso. Le pietre cadono sul cosmo.
- **Il panno di Tacito resta**, perche' non e' decorazione: e' la fonte, cioe' il candido panno su cui si gettano le sorti nella Germania di Tacito, ed e' cio' che rende il rito vero invece che inventato. Ma smette di essere un rettangolo: bordi morbidi e irregolari, nessun angolo retto, nessun riempimento piatto, e la sua fonte nominata nel pannello Fonti e metodo.

Vincolo che non si perde correggendo: le pietre continuano a non uscire dal campo e a non sovrapporsi, e la disposizione resta deterministica a parita' di persona, giorno e domanda.

**Prova a guardia.** Una prova a pixel sulla scena della gettata cade se esistono pixel del rosso dell'acqua; una seconda prova cade se il panno ha un bordo rettilineo lungo piu' di una soglia dichiarata; una terza verifica che nessuna pietra esca dal campo e che non ci siano sovrapposizioni.

**Rosso:** rimetti il `drawRect` dell'acqua e la prima prova cade col conto dei pixel rossi.

**Anteprima obbligatoria**, e prima di nominarla nel rapporto VERIFICA CHE IL FILE ESISTA NEL REPOSITORY: la gettata a scena ferma, 1080x2391, montata dentro l'app. Nel rapporto della 2158 e' stata nominata `rune-telo.png`, che non esiste: la cattura vera scrive `rune-getto.png`.

## VOCE 7. Via ogni residuo di tracciamento, anche nei testi

Parole di Mauro: elimina il tracciamento delle rune e lascia solo "tieni premuto", ma bisogna cambiare anche nei testi che c'e' solo tieni premuto.

**Fatto gia' accertato:** `sunset_rune_screen.dart:985` mostra ancora "Traccia con il dito sulla pietra e scopri il simbolo."

**Decisione di Mauro, da non ribaltare mai piu':** il gesto e' TENERE PREMUTO sulla pietra. Il tracciamento col dito che scorre non esiste, non si costruisce, e chi in futuro trovera' `onLongPress` non lo consideri un difetto. Scrivi questa riga accanto a quel codice.

Correggi il testo e ogni altro che dica la stessa cosa. Il testo vive in un punto solo, mai scritto a mano in due schermate. Se resta codice di tracciamento, toglilo.

**Prova a guardia.** Una prova enumera tutte le stringhe vive di `lib` e cade se una parla di tracciare, seguire il tratto oppure scorrere il dito nel contesto delle rune. La prova RICOMPONE la stringa come la legge la persona, quindi unisce i frammenti concatenati e le righe adiacenti, e guarda le due forme di virgolette. Una ricerca riga per riga non le vede: e' gia' costato tre volte in questo progetto.

**Rosso:** rimetti una frase che dice di tracciare, spezzata su due righe del sorgente, e la prova deve cadere lo stesso.

## VOCE 8. Il doppio tocco per girare la runa funziona sul riquadro e non sulla pietra

Parole di Mauro: dove c'e' scritto "premi 2 volte sulla pietra per girare la runa" non funziona, funziona solo se fai 2 click sul riquadro dove c'e' scritto di premere 2 volte e non sulla pietra.

**Fatto gia' accertato:** `onDoubleTap` sta solo su `_invitoGira`, alla riga 1124, cioe' sul riquadro. Sulla pietra non c'e' niente. E' la regola della promessa mantenuta: l'invito nomina la pietra e l'area di tocco sta altrove.

Il doppio tocco SULLA PIETRA gira la runa, con area di tocco piena sulla pietra intera e non sul suo riquadro di testo. Il riquadro puo' restare toccabile come cortesia, ma la pietra deve funzionare.

**Prova a guardia.** Una prova simula il doppio tocco al CENTRO DELLA PIETRA e verifica che la runa si giri; una seconda prova enumera i punti dell'app dove un invito nomina un oggetto toccabile e cade se in uno di essi l'area di tocco non copre quell'oggetto.

**Rosso:** togli il gesto dalla pietra lasciandolo sul riquadro e la prima prova cade.

## VOCE 9. Nel Tramonto il tratto va sulla pietra vergine, non su un vettoriale

Parole di Mauro: la traccia della runa tenendo premuto appare sopra un'immagine vettoriale standard e non sulla Runa Vergine.

**Fatto gia' accertato:** durante l'incisione l'unico strato dipinto e' `_IncisionePainter`, cioe' un glifo vettoriale. L'asset compare soltanto a incisione completata.

La pietra vergine sta sotto FIN DAL PRIMO ISTANTE, e il solco si scava sopra di lei mentre il dito preme. Al termine non c'e' nessuna sostituzione di immagine, perche' la pietra era gia' quella: cambia solo il solco.

Vincoli: la pietra vergine si prende dalla porta unica costruita con la 2158, `RetroDellaRuna`, non da un percorso scritto a mano; la geometria del tratto resta quella che esiste e non si duplica; il precache si fa prima, altrimenti in prova la pietra non si decodifica e la misura accusa la scena di essere vuota mentre e' la misura a non vedere.

**Prova a guardia.** Una prova a pixel a META' incisione verifica che sotto il solco ci sia la venatura dell'asset e non un riempimento piatto; una prova enumerante cade se il Tramonto prende la pietra da un percorso diverso dalla porta unica.

**Rosso:** rimetti il glifo vettoriale come unico strato e la prova a pixel cade.

**Anteprima:** il tratto a meta' incisione sulla pietra vergine, 1080x2391.

## VOCE 10. Nel Tramonto "attiva posizione" non chiede il permesso

Parole di Mauro: il tasto "attiva posizione" non funziona, non viene richiesta l'autorizzazione del dispositivo per l'uso della posizione GPS.

**Fatto gia' accertato, ed e' un ramo mancante e non un pulsante morto:** il pulsante chiama davvero, `resolve` poi `checkPermission` poi `requestPermission` in `sky_location.dart:140`, e i permessi sono dichiarati in tutti e due i manifest. Il difetto e' che `chiedi()` APPIATTISCE `denied` e `deniedForever` in un solo esito, `negata`. Quindi a chi ha negato una volta per sempre il dialogo di sistema non comparira' mai piu', la schermata mostra sempre lo stesso avviso, e non porta mai alle impostazioni.

I tre esiti restano DISTINTI fino a schermo.

- **concesso**: la posizione si usa.
- **negato una volta**: la schermata lo dice, resta usabile col ripiego dichiarato, e il pulsante puo' chiedere di nuovo.
- **negato per sempre**: il pulsante PORTA ALLE IMPOSTAZIONI DEL SISTEMA invece di ripetere una richiesta che non comparira', e il testo spiega perche'.

Il ripiego resta dichiarato come ripiego, mai un numero inventato al posto della posizione vera.

Nota che vale oltre questa voce: appiattire due esiti diversi in uno solo e' la stessa forma di difetto della regola messa in una porta sola, cioe' un'informazione che esisteva e viene buttata a monte. Cerca se `chiedi()` e' l'unico punto che lo fa.

**Prova a guardia.** Tre prove, una per esito, che verificano cosa vede la persona in ciascuno dei tre casi; una quarta prova cade se in qualche punto `denied` e `deniedForever` tornano a essere lo stesso valore.

**Rosso:** riappiattisci i due esiti e la quarta prova cade.

## VOCE 11. Nel Tramonto il riquadro "gira la pietra" va subito sotto la pietra

Parole di Mauro: il riquadro "gira la pietra per rovesciarla" dovrebbe essere posizionato subito sotto la pietra.

**Fatto gia' accertato:** fra la pietra e l'invito stanno la riga del verso, la Voce A intera e la riga di trasparenza.

L'invito sale immediatamente sotto la pietra, con una distanza dichiarata come costante e non come numero sparso. Il verso, la Voce A e la riga di trasparenza scendono sotto l'invito, nell'ordine attuale fra loro. Vale la regola sugli inviti: un pulsante vero con area di tocco piena, una sola riga di guida, la riga di stato smorzata come nota di servizio.

**Misura:** distanza in punti fra il bordo basso della pietra e il bordo alto dell'invito, prima e dopo, con la soglia dichiarata.

**Anteprima:** il Tramonto con la pietra e l'invito sotto, 1080x2391.

---

## Come si lavora

1. Ogni ipotesi scritta qui si verifica PRIMA di correggere, e l'esito si dichiara anche quando l'ipotesi cade.
2. Ogni prova nuova ha il suo ROSSO ESEGUITO DAVVERO. Se il rosso non scatta, NON allentare la prova: cambia la grandezza misurata e scrivi nel test perche' l'hai cambiata.
3. Su ogni voce, prima di dichiararla chiusa, rispondi nel messaggio di commit: questa regola dove vive, e quante porte ci arrivano.
4. Un test che monta un widget in isolamento non coglie un difetto di cablaggio ne' un difetto di durata. Dove il sospetto e' un collegamento oppure un tempo, si monta l'app dall'avvio vero.
5. Si commette a ogni voce chiusa, con un messaggio suo. Mai tutto alla fine.
6. Durante il lavoro esegui solo le prove dell'area toccata. La suite intera una volta sola alla fine di ogni voce.
7. `git add -A` NON si usa. Il commit si compone per percorsi espliciti.
8. Le anteprime si giudicano a 360 punti logici, cioe' 1080 pixel, e si montano come e' montato cio' che provano. In cattura si usa `pump` e non `step`, e si scrivono in `docs/preview` solo con `AGGIORNA_ANTEPRIME=1` nell'ambiente. Dopo ogni modifica al punto comune del corredo rigenera tutto e LEGGI IL GUARDIANO riportandone il numero.
9. NESSUN RAPPORTO NOMINA UN FILE GENERATO SENZA AVERNE VERIFICATO L'ESISTENZA NEL REPOSITORY DOPO IL PUSH. Nella 2158 e' stata citata `rune-telo.png`, che non esiste.
10. Ogni voce visiva porta la sua coppia prima e dopo in `docs/preview/prima_dopo/`. Nella 2158 non ne e' entrata nessuna. Se una coppia non prova niente, consegnala dicendo che non prova niente e porta accanto la misura che invece prova.
11. Lingua: italiano, mai il trattino lungo, mai la virgola prima della "e" o della "ed" congiunzione, accenti veri nei testi a video. Riesegui la prova della lingua sul testo che scrivi tu.
12. Ogni ripiego dichiara di essere un ripiego, nel codice e a schermo.
13. UNO SHA SI CITA SOLO DOPO AVERLO LETTO DAL REMOTO A PUSH AVVENUTO.
14. UN ESITO RIPORTATO DA UN CANALE CHE NON HA ESEGUITO IL COMANDO NON E' L'ESITO DEL COMANDO.
15. Non condensare, non tagliare, non riassumere nessun documento.
16. Aggiorna `docs/STATO_VIVO.md` alla fine, nelle sezioni corrette e mai come addendum.

## La consegna

Spegni `kDiagnosiAttiva`. Analyze col conto dichiarato e quanti sono nuovi rispetto alla build precedente, sapendo che 66 esistenti sono un debito e non "pulito". Suite verde. Anteprime rigenerate col numero del guardiano e quante ne sono cambiate. Commit per percorsi espliciti. Push col credential helper effimero senza `--force`, e verifica che locale e remoto coincidano.

Poi `flutter build apk --release --target-platform android-arm64`, un solo APK arm64, NUMERO DI BUILD 2161, e consegna con App Distribution al destinatario unico `cloud@esotericircle.app`.

Dichiara: il numero letto dall'archivio con aapt2, la release, il comando esatto, il peso nelle DUE unita' base 1000 e base 1024, e la differenza rispetto alla 2158 che pesava 152.372.767 byte, dicendo da dove viene. Aggiorna `docs/versione_distribuita.json` dentro la procedura di consegna, non a mano.

## Il rapporto finale

In testa: l'esito delle tre premesse, e per la Voce 1 e la Voce 3 anche la causa vera trovata, con lo sha del commit dove serve.

Poi, per ogni voce: la misura prima e dopo col metodo usato, il rosso eseguito e cosa ha stampato, la coppia prima e dopo, e la FRASE DI ACCETTAZIONE, cioe' una riga che dice a Mauro cosa deve vedere sul telefono.

Riporta il numero dei catch muti dopo il lavoro, che il Registro tiene a 76. Ogni file che nomini deve esistere nel repository dopo il push, e devi averlo verificato. Dichiara ogni immagine che non prova niente invece di lasciarla interpretare.
