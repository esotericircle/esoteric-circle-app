# IL CENSIMENTO DEL GENERE, PRIMA E DOPO L'ORDINE DL

**Voce DL.12, appendice del rapporto.** 14 settembre 2026. Lo stesso metodo
prima e dopo: ogni stringa letterale di `lib`, commenti esclusi e letterali
adiacenti uniti, in cui una forma della persona che legge porta il genere.
Il criterio e' quello della guardia della voce DL.06, `formeDelGenere` in
`lib/core/chat/le_forme_del_genere.dart`: un verbo alla seconda persona
seguito da una parola del dizionario o da un participio, l'infinito col
genere in apertura di frase o dopo *di*, i riflessivi, *te stesso* e *te
stessa*, i vocativi. **Concordata** vuol dire che la stringa passa dalla
porta del genere: e' dentro una marca a tre campi, o sta in una porta
dichiarata, o e' un ramo di una scelta maschile e femminile.

**Perche' 110 e non 83.** L'ordine ne misurava ottantatre' con un criterio
piu' stretto, il participio e l'aggettivo attaccati al verbo essere, e lo
dichiarava *"un pavimento e non un totale"*. Il criterio del dizionario ne
trova centodieci: le ventisette in piu' sono soprattutto le frasi lunghe dei
corpora, gli infiniti col genere (*"essere sicuro"*) e i riflessivi. Sotto,
l'elenco intero, non solo le ventisette: il censimento dell'ordine non
e' nel repository, e separarle a mano vorrebbe dire indovinare.

**Perche' dopo sono 123.** Dopo si conta ogni stringa che porta almeno
una marca, anche quando il criterio senza la marca non avrebbe trovato
niente: la conversione ha marcato frasi intere, e una frase riscritta puo'
dividersi in due letterali. Il numero che conta e' l'altro: nessuna
stringa non concordata.

| area | prima | concordate prima | *te stesso/a* prima | dopo | concordate dopo | *te stesso/a* dopo |
|---|---:|---:|---:|---:|---:|---:|
| `core/angels` | 5 | 0 | 4 | 6 | 6 | 0 |
| `core/archetypes` | 14 | 0 | 9 | 27 | 27 | 0 |
| `core/astro` | 1 | 0 | 0 | 1 | 1 | 0 |
| `core/chat` | 0 | 0 | 0 | 1 | 1 | 0 |
| `core/domande` | 1 | 0 | 1 | 1 | 1 | 0 |
| `core/face` | 5 | 0 | 0 | 13 | 13 | 0 |
| `core/horoscope` | 4 | 2 | 0 | 2 | 2 | 0 |
| `core/identity` | 3 | 2 | 1 | 2 | 2 | 0 |
| `core/maestro` | 9 | 2 | 0 | 4 | 4 | 0 |
| `core/responsi` | 1 | 0 | 1 | 0 | 0 | 0 |
| `core/ricordi` | 1 | 0 | 0 | 1 | 1 | 0 |
| `core/rituals` | 17 | 0 | 9 | 17 | 17 | 0 |
| `core/sigilli` | 2 | 0 | 0 | 2 | 2 | 0 |
| `core/tarot` | 28 | 0 | 11 | 35 | 35 | 0 |
| `core/viaggio` | 1 | 0 | 1 | 1 | 1 | 0 |
| `features/account` | 4 | 0 | 0 | 3 | 3 | 0 |
| `features/angels` | 4 | 0 | 0 | 1 | 1 | 0 |
| `features/maestri` | 1 | 0 | 0 | 1 | 1 | 0 |
| `features/onboarding` | 9 | 4 | 0 | 5 | 5 | 0 |
| **totale** | **110** | **10** | **37** | **123** | **123** | **0** |

---

## Le 110 stringhe di prima

File, riga, le forme trovate e l'inizio della stringa, fino a duecentoventi
caratteri. La barra verticale dentro il testo e' resa con la barra obliqua,
perche' in una tavola la verticale e' il bordo della cella.

| # | file | riga | forme | concordata | testo |
|---:|---|---:|---|---|---|
| 1 | `core/angels/angel_lore.dart` | 96 | sei disposto | no | Qui si lavora la parola mantenuta. Una promessa vale quanto il tempo che sei disposto a dedicarle quando smette di convenirti. |
| 2 | `core/angels/angel_lore.dart` | 206 | te stesso | no | Dici le cose come stanno senza usare la verità come un'arma. La tua misura è la giustizia applicata prima di tutto a te stesso. |
| 3 | `core/angels/angel_lore.dart` | 245 | te stesso | no | Verità nelle controversie, contratti, ambito legale, ogni situazione dove qualcuno deve pronunciarsi. Riguarda anche il giudizio che applichi a te stesso. |
| 4 | `core/angels/angel_lore.dart` | 556 | te stesso | no | Hai un metro di misura alto, prima di tutto verso te stesso. Usalo per riconoscere il valore in chi ti sta davanti, non per pesarti addosso ogni giorno. |
| 5 | `core/angels/angel_lore.dart` | 676 | te stesso | no | L'affinità, cioè la capacità di sentire l'altro senza confonderti con lui. Ti insegna a stare vicino restando te stesso. |
| 6 | `core/archetypes/archetype_corpus.dart` | 90 | te stesso | no | In amore ti batti per chi ami e lo proteggi con tutto te stesso, pronto a metterti in gioco. La tua dedizione è totale e non ti tiri indietro davanti alle difficoltà del legame. Vuoi essere all'altezza e a volte trasform |
| 7 | `core/archetypes/archetype_corpus.dart` | 105 | Sei prezioso | no | Sul lavoro innovi e sfidi le regole che hanno smesso di avere senso, perché vedi ciò che va cambiato. La tua voglia di rompere lo status quo porta idee che gli altri non osano. Sei prezioso dove serve scuotere un sistema |
| 8 | `core/archetypes/archetype_corpus.dart` | 107 | te stesso | no | Nella quotidianità mal sopporti le imposizioni e fai le cose a modo tuo, contro le abitudini di tutti. Dici quello che pensi anche quando è scomodo e non ti pieghi al conformismo. La routine imposta ti fa sentire ingabbi |
| 9 | `core/archetypes/archetype_corpus.dart` | 113 | tu stesso | no | Dove gli altri vedono muri, tu vedi possibilità. Sai che le cose, tu stesso compreso, possono trasformarsi, mentre unisci la visione alla volontà per far accadere ciò che immagini. Leggi in profondità persone e situazion |
| 10 | `core/archetypes/archetype_corpus.dart` | 126 | sei uscito | no | Hai conosciuto la vita per quello che è. Ne sei uscito concreto e vero senza smettere di essere umano. Non ti servono maschere né piedistalli, stai tra gli altri da pari con empatia e buon senso. Sei quello su cui si può |
| 11 | `core/archetypes/archetype_corpus.dart` | 129 | resti deluso | no | In amore cerchi appartenenza vera, un legame concreto fatto di presenza e di fiducia reciproca. Non ami le grandi scene, preferisci i gesti quotidiani che dicono ci sono. Stai bene con chi ti accetta senza pretese e rest |
| 12 | `core/archetypes/archetype_corpus.dart` | 131 | ti senti poco riconosciuto | no | Sul lavoro sei affidabile e tieni unito il gruppo, quello su cui tutti sanno di poter contare. Porti buon senso, empatia e concretezza dove servono i piedi per terra. Non cerchi il palco, cerchi che le cose funzionino da |
| 13 | `core/archetypes/archetype_corpus.dart` | 133 | te stesso | no | Nella quotidianità stai tra gli altri da pari, senza maschere né piedistalli, con empatia e semplicità. Tieni i piedi per terra quando tutti perdono la testa e riporti al concreto. Ti bastano cose vere e rapporti sinceri |
| 14 | `core/archetypes/archetype_corpus.dart` | 142 | te stesso | no | In amore sei nel tuo territorio: vivi il legame con una passione totale che riempie la vita. Sai creare intimità e bellezza. Fai sentire l'altro visto, desiderato e importante. Ti doni per intero e cerchi una connessione |
| 15 | `core/archetypes/archetype_corpus.dart` | 146 | te stesso | no | Nella quotidianità cerchi bellezza, intimità e momenti profondi con le persone a cui tieni. Vivi di sensazioni, di piaceri veri e di connessioni che scaldano la giornata. La freddezza e la distanza ti fanno appassire. Il |
| 16 | `core/archetypes/archetype_corpus.dart` | 172 | sei riconosciuto, te stesso | no | Nella quotidianità pensi agli altri prima che a te stesso e ti prendi cura di chi ti circonda. La casa, gli affetti e la vicinanza sono il tuo centro, il posto dove dai il meglio. Ti riempie il gesto di esserci per qualc |
| 17 | `core/archetypes/archetype_corpus.dart` | 191 | te stesso | no | Hai bisogno di dare forma a ciò che non esiste ancora. Le idee in te diventano opere. Trasformi l'immaginazione in qualcosa di reale che prima non c'era. Vivi per creare bellezza e senso. Nel fare trovi te stesso. La tua |
| 18 | `core/archetypes/archetype_corpus.dart` | 198 | te stesso | no | Nella quotidianità hai sempre qualcosa da creare: trasformi le idee in gesti concreti. Cerchi bellezza in ciò che fai e mal sopporti il vuoto e la ripetizione senza senso. Nel dare forma alle cose trovi te stesso e il tu |
| 19 | `core/archetypes/archetype_quiz.dart` | 122 | Restare solo | no | Restare solo |
| 20 | `core/astro/lingua_degli_eventi.dart` | 75 | sei nato | no | Il Sole torna esattamente dove era quando sei nato. È il compleanno astronomico, che non sempre cade nel giorno civile. |
| 21 | `core/domande/cornici_del_presagio.dart` | 150 | te stesso | no | Oggi di’ a voce alta, anche solo a te stesso, la cosa di te che stai evitando di guardare. Una volta sola basta. |
| 22 | `core/face/face_corpus.dart` | 39 | Sei espressivo | no | Sei espressivo e aperto alle emozioni, che leggi e lasci passare. |
| 23 | `core/face/face_corpus.dart` | 41 | Sei concentrato | no | Sei concentrato e intuitivo, con uno sguardo che va in profondità. |
| 24 | `core/face/face_corpus.dart` | 47 | Sei generoso | no | Sei generoso nel dare e nel parlare, caldo nel condividere. |
| 25 | `core/face/face_corpus.dart` | 65 | Sei generoso | no | Sei generoso e aperto, comunichi con slancio e allarghi il cerchio. |
| 26 | `core/face/face_corpus.dart` | 67 | Sei raccolto | no | Sei raccolto, tieni per te quello che conta finché non è il momento. |
| 27 | `core/horoscope/horoscope.dart` | 154 | Caro | si | Caro $name |
| 28 | `core/horoscope/horoscope.dart` | 155 | Cara | si | Cara $name |
| 29 | `core/horoscope/horoscope_data.dart` | 269 | sei da solo | no | Se sei da solo, un incontro leggero merita attenzione. |
| 30 | `core/horoscope/horoscope_data.dart` | 290 | fatti trovare pronto | no | La fortuna gira dalla tua parte nel pomeriggio, fatti trovare pronto. |
| 31 | `core/identity/identity_controller.dart` | 62 | Benvenuto | si | Benvenuto nel cerchio$n |
| 32 | `core/identity/identity_controller.dart` | 63 | Benvenuta | si | Benvenuta nel cerchio$n |
| 33 | `core/identity/natal_identity.dart` | 163 | te stesso | no | dono, compimento e universalità: doni te stesso. |
| 34 | `core/maestro/cio_che_aura_ricorda.dart` | 76 | sei rimasto | no | Oggi sei rimasto più a lungo della settimana scorsa. |
| 35 | `core/maestro/frasi_dell_attesa.dart` | 90 | sei nato | no | Sto risalendo alla Luna sotto cui sei nato |
| 36 | `core/maestro/il_respiro_di_oggi.dart` | 44 | ti sei fermato | no | Oggi ti sei fermato a respirare $nome. Anche quello è passato per la tua giornata. |
| 37 | `core/maestro/lente_del_cielo.dart` | 53 | sei nato | no | la ${ancoraggio.valore} sotto cui sei nato |
| 38 | `core/maestro/maestro_welcome.dart` | 96 | Caro | si | Caro $name |
| 39 | `core/maestro/maestro_welcome.dart` | 97 | Cara | si | Cara $name |
| 40 | `core/maestro/seguito_della_lettura.dart` | 34 | ti sei fermato | no | - Continua da dove ti sei fermato. Non riassumere, non riformulare, non ripetere con altre parole ciò che hai già detto: chi rilegge due volte la stessa cosa si sente preso in giro. |
| 41 | `core/maestro/voce_del_maestro.dart` | 160 | sei solo | no | Non sei solo |
| 42 | `core/maestro/voce_del_maestro.dart` | 161 | sei sola | no | Non sei sola |
| 43 | `core/responsi/anatomia_del_responso.dart` | 41 | te stesso | no | Un'indicazione concreta, compibile oggi o nei prossimi giorni. Non "ascolta te stesso": una cosa che si può davvero fare. |
| 44 | `core/ricordi/lettura_del_mese.dart` | 179 | sei stato | no | Con l'Iniziato, ogni mese il tuo Maestro dominante ti racconta dove sei stato e cosa è cambiato. |
| 45 | `core/rituals/animal_catalog.dart` | 135 | te stesso | no | Fedeltà, libertà, fiducia nell'istinto: il Lupo ti insegna a stare nel gruppo senza perdere te stesso. |
| 46 | `core/rituals/dream_rite_corpus.dart` | 82 | ti sei speso | no | hai dato luce, ti sei speso |
| 47 | `core/rituals/guide_animal_corpus.dart` | 130 | te stesso | no | Si presenta come guida quando devi difendere i tuoi o ritrovare la tua tribù senza perdere te stesso. |
| 48 | `core/rituals/guide_animal_corpus.dart` | 144 | te stesso | no | cammina in gruppo senza sciogliere te stesso. |
| 49 | `core/rituals/guide_animal_corpus.dart` | 155 | sei chiamato, te stesso | no | Si presenta come guida quando sei chiamato a una visione più grande e a governare te stesso con nobiltà. |
| 50 | `core/rituals/guide_animal_corpus.dart` | 164 | te stesso | no | governa te stesso prima di guidare gli altri. |
| 51 | `core/rituals/guide_animal_corpus.dart` | 207 | te stesso | no | Oggi tratta te stesso e gli altri con una gentilezza nuova. |
| 52 | `core/rituals/guide_animal_corpus.dart` | 287 | sei protetto | no | porta con te la tua casa, sei protetto. |
| 53 | `core/rituals/relazione_lunare.dart` | 27 | sei nato | no | Stanotte la Luna torna dov'era quando sei nato: è il tuo ritorno lunare, il momento in cui il sentire ricomincia da capo. |
| 54 | `core/rituals/rito_alba_corpus.dart` | 854 | Sei arrivato | no | Sei arrivato prima che il rumore cominciasse. Il respiro che hai contato adesso lo hai contato nel silenzio. |
| 55 | `core/rituals/rito_alba_corpus.dart` | 866 | Sei arrivato | no | Sei arrivato quando il giorno era ancora chiuso. Quello che hai portato con te lo hai scelto al buio. |
| 56 | `core/rituals/runes.dart` | 181 | sei difeso | no | L'alce, lo scudo alzato: sei difeso, resta connesso al sacro. |
| 57 | `core/rituals/runes.dart` | 183 | Sei più difeso | no | Sei più difeso di quanto credi: alza lo sguardo. |
| 58 | `core/rituals/runes.dart` | 222 | te stesso | no | L'uomo, l'umanità: ritrova te stesso dentro la comunità. |
| 59 | `core/rituals/runes.dart` | 224 | te stesso | no | Conosci te stesso attraverso gli altri. |
| 60 | `core/rituals/sunset_rune_corpus.dart` | 124 | sei più difeso | no | Lascia fuori la guardia: qui sei più difeso di quanto credi. |
| 61 | `core/rituals/sunset_rune_corpus.dart` | 144 | te stesso | no | Lascia fuori gli altri e i loro sguardi: stanotte torni solo a te stesso. |
| 62 | `core/sigilli/sentiero_costellazione.dart` | 934 | sei nato | no | Il Sole torna dov’era quando sei nato: tu eri qui con l’Oroscopo. |
| 63 | `core/sigilli/sentiero_loto.dart` | 931 | sei nato | no | Il Sole torna dov’era quando sei nato: tu eri qui con il Rito dell’Alba. |
| 64 | `core/tarot/tarot_card.dart` | 180 | ti sei scordata, te stessa | no | La creatività sembra bloccata, oppure ti sei scordata di rivolgere a te stessa l'attenzione che dai a tutto il resto. Prima di far fiorire fuori, torna a nutrire la tua radice. Rifiorisce dentro ciò che curi con gentilez |
| 65 | `core/tarot/tarot_card.dart` | 204 | te stesso | no | Tradizione, insegnamento e senso condiviso ti sono vicini e vale la pena cercare un maestro, un consiglio, una sapienza più grande di te. C'è forza nell'appartenere a qualcosa che viene da lontano. Ma la guida vera non t |
| 66 | `core/tarot/tarot_card.dart` | 217 | te stesso | no | C'è amore e c'è un bivio: una decisione che tocca i tuoi valori più veri, non solo il desiderio del momento. Il cielo ti chiede di scegliere con tutto te stesso, testa e cuore insieme. Quando l'amore è allineato a ciò ch |
| 67 | `core/tarot/tarot_card.dart` | 247 | sei onesto, te stesso | no | C'è una verità che eviti, oppure una responsabilità che continui a rimandare. Finché resta in ombra, pesa. Guardala in faccia con calma, l'equilibrio torna nel momento in cui sei onesto con te stesso. |
| 68 | `core/tarot/tarot_card.dart` | 288 | sei diventata, te stessa | no | Forse dubiti della tua tenuta, o forse sei diventata dura con te stessa. La vera forza non è la stretta, è la mano gentile. Torna a trattarti con mitezza e ritrovi il controllo che credevi perso. |
| 69 | `core/tarot/tarot_card.dart` | 302 | ti sei imposta | no | L'attesa ha smesso di insegnare e sa di stallo, o ti sei imposta un sacrificio che non serve a nessuno. Cambia lo sguardo, oppure scendi dall'albero e torna ad agire. Non ogni rinuncia è nobile, alcune sono solo paura tr |
| 70 | `core/tarot/tarot_card.dart` | 367 | sei stanco | no | Dopo la tempesta arriva una luce dolce e con lei fiducia, ispirazione, la promessa che guarirai. La Stella non urla, rassicura: sei sulla strada giusta anche se sei stanco. Lasciati guidare da questa quiete luminosa, il  |
| 71 | `core/tarot/tarot_card.dart` | 411 | te stesso | no | Rimandi un bilancio che senti necessario, oppure ti giudichi con una durezza che non ti aiuta. La rinascita non nasce dalla condanna, ma dall'ascolto e dal perdono. Sii con te stesso il giudice giusto, quello che compren |
| 72 | `core/tarot/tarot_card.dart` | 421 | sei arrivato | no | Pienezza, traguardo, integrazione: un ciclo si chiude in armonia e tu sei arrivato dove dovevi. È un momento di compimento, goditelo prima di aprire il prossimo cerchio. Ciò che hai attraversato ora è parte di te, intero |
| 73 | `core/tarot/tarot_card.dart` | 450 | te stesso | no | C'è paura di osare, o una direzione ancora confusa che ti tiene sulla soglia. Prima di muoverti, chiarisci a te stesso cosa vuoi davvero. Un passo deciso vale più di dieci fatti nel dubbio. |
| 74 | `core/tarot/tarot_card.dart` | 512 | ti senti assediato | no | È tempo di tenere il punto, di avere coraggio sotto pressione e difendere ciò in cui credi. Sei in vantaggio, anche se ti senti assediato. Hai la forza per reggere, non cedere proprio adesso. |
| 75 | `core/tarot/tarot_card.dart` | 515 | Ti senti sopraffatto | no | Ti senti sopraffatto, o troppo sulla difensiva anche quando non serve. Scegli con lucidità dove vale la pena resistere e dove invece puoi lasciare. Non devi difendere ogni collina. |
| 76 | `core/tarot/tarot_card.dart` | 538 | Sei stanco | no | Sei stanco ma vicino al traguardo e la tenacia ora è tutto. Hai già fatto il più, non mollare proprio l'ultimo tratto. Un'ultima prova, poi potrai posare lo scudo. |
| 77 | `core/tarot/tarot_card.dart` | 554 | ti sei caricato | no | Porti un fardello che forse non ti appartiene, per abitudine o per senso del dovere. Lascia andare ciò che ti sei caricato senza necessità. Alleggerirti non è tradire nessuno, è respirare. |
| 78 | `core/tarot/tarot_card.dart` | 590 | te stessa | no | Sicurezza, calore, magnetismo: brilli con generosità e la tua fiamma scalda chi ti sta intorno. Sii pienamente te stessa, è proprio questo che attrae. La tua luce non toglie spazio a nessuno. |
| 79 | `core/tarot/tarot_card.dart` | 776 | te stessa | no | Ti perdi negli altri, assorbi ogni loro stato d'animo fino a smarrire il tuo. Riporta un poco di cura anche a te stessa. Puoi amare senza annegare. |
| 80 | `core/tarot/tarot_card.dart` | 904 | Ti sei guadagnata | no | Autonomia, agiatezza, frutti meritati con le tue mani: goditi ciò che hai costruito da te. È la carta dell'indipendenza serena. Ti sei guadagnata il tuo spazio, abitalo con piacere. |
| 81 | `core/tarot/tarot_card.dart` | 1061 | te stesso | no | Astuzia, prudenza, agire con tatto invece che di forza. Usa l'ingegno, ma resta onesto con te stesso su cosa stai facendo. La furbizia è un'arte, l'inganno una trappola anche per chi lo tende. |
| 82 | `core/tarot/tarot_card.dart` | 1074 | Ti senti bloccato | no | Ti senti bloccato, ma i limiti sono soprattutto nella tua mente. Le corde sono più larghe di quanto credi e la benda te la puoi togliere. Il primo passo verso l'uscita è capire che c'è. |
| 83 | `core/tarot/tarot_card.dart` | 1077 | Eri più libero | no | Una liberazione, una via che si apre dopo il senso di trappola. Riconosci la tua forza e fai il primo passo fuori. Eri più libero di quanto la paura ti diceva. |
| 84 | `core/tarot/tarot_card.dart` | 1142 | te stessa | no | Una durezza, o una solitudine scelta come corazza. Ammorbidisci il giudizio, a partire da quello verso te stessa. La lama più affilata non deve rivolgersi contro chi la porta. |
| 85 | `core/tarot/tarot_reading.dart` | 282 | sei disposto | no | Cosa sei disposto a lasciare andare per fare spazio a questo? |
| 86 | `core/tarot/voce_della_stesa.dart` | 148 | Sei scesa | no | Sei scesa con questa domanda: «{domanda}» |
| 87 | `core/tarot/voce_della_stesa.dart` | 194 | essere arrivata | no | Porta un compimento. Il rischio, qui, non è fallire: è non accorgersi di essere arrivata. |
| 88 | `core/tarot/voce_della_stesa.dart` | 230 | sei disposta | no | Dice che c'è un prezzo. E che il prezzo è noto. Quello che non è ancora chiaro è se sei disposta a pagarlo. |
| 89 | `core/tarot/voce_della_stesa.dart` | 273 | sentirti più pronta | no | Usa adesso quello che hai costruito, invece di aspettare di sentirti più pronta. |
| 90 | `core/tarot/voce_della_stesa.dart` | 278 | saresti stata | no | Chiedi adesso quello che rimandavi a quando saresti stata più forte. |
| 91 | `core/tarot/voce_della_stesa.dart` | 398 | sei arrivata | no | {passato} racconta come ci sei arrivata. Non è un rimprovero, è il filo. |
| 92 | `core/viaggio/la_voce_del_mondo_di_sotto.dart` | 286 | te stesso | no | Chiedi a te stesso quale racconterai meglio fra dieci anni. |
| 93 | `features/account/account_screen.dart` | 781 | Sei uscito | no | Sei uscito. Il tuo cammino ti aspetta al rientro. |
| 94 | `features/account/account_screen.dart` | 925 | sei davvero sicuro | no | Ne sei davvero sicuro? |
| 95 | `features/account/custodia_del_cielo.dart` | 454 | ti sei mai registrato | no | ${_guaio!} Se non ti sei mai registrato, potrai farlo tra poco, alla fine del rito, oppure dal menu utente. |
| 96 | `features/account/dati_di_nascita_screen.dart` | 199 | sei nato | no | Il giorno in cui sei nato |
| 97 | `features/angels/angels_screen.dart` | 139 | sei nato | no | I tuoi tre si ricavano da tre cose diverse: la posizione del Sole alla tua nascita, in archi di cinque gradi, il giorno in cui sei nato, l'ora esatta. |
| 98 | `features/angels/angels_screen.dart` | 244 | sei nato | no | Nasce dal giorno in cui sei nato, il ${triade.dayOfYear}esimo dell'anno. Veglia su ciò che senti e su come ami. |
| 99 | `features/angels/angels_screen.dart` | 259 | sei venuto | no | Nasce dall'ora della tua nascita. Veglia sul tuo pensiero e su ciò che sei venuto a fare. |
| 100 | `features/angels/angels_screen.dart` | 568 | sei nato | no | Il cerchio dello zodiaco ha trecentosessanta gradi e gli angeli sono settantadue: cinque gradi per ciascuno. Si guarda dove stava il Sole nel momento in cui sei nato, non il giorno sul calendario, poi si legge a chi tocc |
| 101 | `features/maestri/aura/face/face_constellation_screen.dart` | 1229 | sei pronto | no | Scansione completa. Quando sei pronto, cattura. |
| 102 | `features/onboarding/anteprima_tono.dart` | 45 | Sei arrivato | no | Bentornato. Sei arrivato fin qui: il tuo cielo ti aspettava. |
| 103 | `features/onboarding/anteprima_tono.dart` | 47 | Sei arrivata | no | Bentornata. Sei arrivata fin qui: il tuo cielo ti aspettava. |
| 104 | `features/onboarding/domanda_dell_invito.dart` | 168 | sei arrivato | no | Se sei arrivato qui da un invito, chi te lo ha mandato riceve il suo premio. Tocca Incolla: dal link che hai ricevuto prendiamo soltanto il codice. Si fa una volta sola. |
| 105 | `features/onboarding/natal_chart_reveal.dart` | 544 | sei nato | no | Senza il giorno in cui sei nato non posso tracciare niente. Preferisco dirtelo invece di farti aspettare. |
| 106 | `features/onboarding/risveglio_journey.dart` | 379 | sei nato | no | Guarda il cielo in cui sei nato |
| 107 | `features/onboarding/scena_del_ritrovamento.dart` | 222 | Bentornato | si | Bentornato nel Cerchio |
| 108 | `features/onboarding/scena_del_ritrovamento.dart` | 222 | Bentornato | si | Bentornato, $nome |
| 109 | `features/onboarding/scena_del_ritrovamento.dart` | 224 | Bentornata | si | Bentornata nel Cerchio |
| 110 | `features/onboarding/scena_del_ritrovamento.dart` | 224 | Bentornata | si | Bentornata, $nome |

## Le 123 stringhe di dopo

Tutte concordate. Si vede la marca a tre campi, con la barra verticale resa
come sopra.

| # | file | riga | testo |
|---:|---|---:|---|
| 1 | `core/angels/angel_lore.dart` | 102 | Qui si lavora la parola mantenuta. Una promessa vale quanto il tempo che [sei disposto/sei disposta/vuoi] dedicarle quando smette di convenirti. |
| 2 | `core/angels/angel_lore.dart` | 212 | Dici le cose come stanno senza usare la verità come un'arma. La tua misura è la giustizia applicata prima di tutto a [te stesso/te stessa/te]. |
| 3 | `core/angels/angel_lore.dart` | 251 | Verità nelle controversie, contratti, ambito legale, ogni situazione dove qualcuno deve pronunciarsi. Riguarda anche il giudizio che applichi a [te stesso/te stessa/te]. |
| 4 | `core/angels/angel_lore.dart` | 252 | Giustizia. Distingui il fatto dall'opinione, poi decidi. La tua forza sta nel non aver bisogno di alzare la voce per [essere creduto/essere creduta/farti credere]. |
| 5 | `core/angels/angel_lore.dart` | 562 | Hai un metro di misura alto, prima di tutto verso [te stesso/te stessa/te]. Usalo per riconoscere il valore in chi ti sta davanti, non per pesarti addosso ogni giorno. |
| 6 | `core/angels/angel_lore.dart` | 682 | L'affinità, cioè la capacità di sentire l'altro senza confonderti con lui. Ti insegna a stare vicino [restando te stesso/restando te stessa/senza perderti]. |
| 7 | `core/archetypes/archetype_corpus.dart` | 85 | Sul lavoro dai il meglio dove puoi muoverti, cambiare e inventare, lontano dagli schemi rigidi. Ami i progetti nuovi, i territori inesplorati e le sfide che nessuno ha ancora affrontato. La tua curiosità apre strade che  |
| 8 | `core/archetypes/archetype_corpus.dart` | 87 | Nella quotidianità mal sopporti le abitudini fisse e cerchi sempre una variazione, un percorso diverso, un'esperienza da provare. Ti muovi molto, dentro e fuori di casa, con un bisogno costante di aria e di orizzonte. La |
| 9 | `core/archetypes/archetype_corpus.dart` | 96 | In amore vai in profondità e cerchi una mente con cui capirti oltre le parole. Ti innamori di chi ti fa pensare e con cui puoi condividere il senso delle cose. La tua lealtà è solida, ma tieni le emozioni a distanza per  |
| 10 | `core/archetypes/archetype_corpus.dart` | 98 | Sul lavoro [sei il consigliere e lo stratega, quello/sei la consigliera e la stratega, quella/porti consiglio e strategia: sei chi] vede lontano e mette ordine nella confusione. Le persone vengono da te per capire, perch |
| 11 | `core/archetypes/archetype_corpus.dart` | 109 | In amore ti batti per chi ami e lo proteggi con [tutto te stesso, pronto/tutta te stessa, pronta/tutto ciò che hai, con la voglia di] metterti in gioco. La tua dedizione è totale e non ti tiri indietro davanti alle diffi |
| 12 | `core/archetypes/archetype_corpus.dart` | 113 | Nella quotidianità affronti la giornata di petto e trasformi ogni ostacolo in una sfida da vincere. Non rimandi, agisci, [ti senti vivo/ti senti viva/senti la vita] quando c'è qualcosa per cui lottare. La calma e l'attes |
| 13 | `core/archetypes/archetype_corpus.dart` | 122 | In amore rifiuti gli schemi e cerchi un legame autentico, senza finzioni né regole imposte da fuori. Ti dai a chi ti accetta [com'è, libero/com'è, libera/per come sei, in libertà] e senza maschere. La convenzione ti soff |
| 14 | `core/archetypes/archetype_corpus.dart` | 124 | Sul lavoro innovi e sfidi le regole che hanno smesso di avere senso, perché vedi ciò che va cambiato. La tua voglia di rompere lo status quo porta idee che gli altri non osano. [Sei prezioso/Sei preziosa/Il tuo contribut |
| 15 | `core/archetypes/archetype_corpus.dart` | 126 | Nella quotidianità mal sopporti le imposizioni e fai le cose a modo tuo, contro le abitudini di tutti. Dici quello che pensi anche quando è scomodo e non ti pieghi al conformismo. La routine imposta ti fa sentire [ingabb |
| 16 | `core/archetypes/archetype_corpus.dart` | 132 | Dove gli altri vedono muri, tu vedi possibilità. Sai che le cose, [tu stesso compreso/tu stessa compresa/e tu con loro], possono trasformarsi, mentre unisci la visione alla volontà per far accadere ciò che immagini. Legg |
| 17 | `core/archetypes/archetype_corpus.dart` | 137 | Sul lavoro [sei il visionario/sei la visionaria/porti la visione] che apre strade e vede possibilità dove gli altri vedono muri. Trasformi le situazioni e trovi soluzioni che sembravano impossibili. La tua intuizione cam |
| 18 | `core/archetypes/archetype_corpus.dart` | 145 | Hai conosciuto la vita per quello che è. [Ne sei uscito concreto e vero/Ne sei uscita concreta e vera/Ne hai tratto concretezza e verità] senza smettere di [essere umano/essere umana/avere umanità]. Non ti servono masche |
| 19 | `core/archetypes/archetype_corpus.dart` | 148 | In amore cerchi appartenenza vera, un legame concreto fatto di presenza e di fiducia reciproca. Non ami le grandi scene, preferisci i gesti quotidiani che dicono ci sono. Stai bene con chi ti accetta senza pretese e rest |
| 20 | `core/archetypes/archetype_corpus.dart` | 150 | Sul lavoro sei affidabile e tieni unito il gruppo: [quello/quella/la persona] su cui tutti sanno di poter contare. Porti buon senso, empatia e concretezza dove servono i piedi per terra. Non cerchi il palco, cerchi che l |
| 21 | `core/archetypes/archetype_corpus.dart` | 152 | Nella quotidianità stai tra gli altri da pari, senza maschere né piedistalli, con empatia e semplicità. Tieni i piedi per terra quando tutti perdono la testa e riporti al concreto. Ti bastano cose vere e rapporti sinceri |
| 22 | `core/archetypes/archetype_corpus.dart` | 158 | Vivi le cose con intensità: il legame con gli altri è dove [ti senti davvero vivo/ti senti davvero viva/senti davvero la vita]. Sai creare bellezza e intimità, ti doni con passione e fai sentire l'altro visto e important |
| 23 | `core/archetypes/archetype_corpus.dart` | 161 | In amore sei nel tuo territorio: vivi il legame con una passione totale che riempie la vita. Sai creare intimità e bellezza. Fai sentire l'altro visto, desiderato e importante. Ti doni per intero e cerchi una connessione |
| 24 | `core/archetypes/archetype_corpus.dart` | 165 | Nella quotidianità cerchi bellezza, intimità e momenti profondi con le persone a cui tieni. Vivi di sensazioni, di piaceri veri e di connessioni che scaldano la giornata. La freddezza e la distanza ti fanno appassire. Il |
| 25 | `core/archetypes/archetype_corpus.dart` | 189 | Sul lavoro sei il collante della squadra: [quello/quella/la persona] che tiene insieme le persone e le sostiene. Ti accorgi di chi è in difficoltà e ci sei, con generosità e senza clamore. Crei un ambiente sicuro dove gl |
| 26 | `core/archetypes/archetype_corpus.dart` | 191 | Nella quotidianità pensi agli altri prima che a [te stesso/te stessa/te] e ti prendi cura di chi ti circonda. La casa, gli affetti e la vicinanza sono il tuo centro, il posto dove dai il meglio. Ti riempie il gesto di es |
| 27 | `core/archetypes/archetype_corpus.dart` | 202 | Sul lavoro [sei il leader che fa crescere, quello/sei la leader che fa crescere, quella/guidi e fai crescere: sei chi] mette ordine e crea stabilità intorno a sé. Ti prendi sulle spalle il peso delle decisioni e dai una  |
| 28 | `core/archetypes/archetype_corpus.dart` | 210 | Hai bisogno di dare forma a ciò che non esiste ancora. Le idee in te diventano opere. Trasformi l'immaginazione in qualcosa di reale che prima non c'era. Vivi per creare bellezza e senso. Nel fare trovi [te stesso/te ste |
| 29 | `core/archetypes/archetype_corpus.dart` | 213 | In amore porti immaginazione e profondità: vedi nell'altro possibilità che nessuno aveva colto. Costruisci una relazione come un'opera, con cura, bellezza e senso. Ti doni con intensità e cerchi un legame che abbia anima |
| 30 | `core/archetypes/archetype_corpus.dart` | 215 | Sul lavoro [sei l'innovatore e l'artigiano, quello/sei l'innovatrice e l'artigiana, quella/porti innovazione e mestiere: sei chi] trasforma le idee in qualcosa di reale. Immagini ciò che non esiste ancora e gli dai forma |
| 31 | `core/archetypes/archetype_corpus.dart` | 217 | Nella quotidianità hai sempre qualcosa da creare: trasformi le idee in gesti concreti. Cerchi bellezza in ciò che fai e mal sopporti il vuoto e la ripetizione senza senso. Nel dare forma alle cose trovi [te stesso/te ste |
| 32 | `core/archetypes/archetype_quiz.dart` | 127 | [Restare solo/Restare sola/Restare senza nessuno] |
| 33 | `core/archetypes/archetype_quiz.dart` | 130 | [Essere ingabbiato/Essere ingabbiata/Stare in gabbia] |
| 34 | `core/astro/lingua_degli_eventi.dart` | 76 | Il Sole torna esattamente dove era [quando sei nato/quando sei nata/alla tua nascita]. È il compleanno astronomico, che non sempre cade nel giorno civile. |
| 35 | `core/chat/la_marca_del_genere.dart` | 221 | [$maschile/$femminile/$neutro] |
| 36 | `core/domande/cornici_del_presagio.dart` | 157 | Oggi di’ a voce alta, anche solo a [te stesso/te stessa/te], la cosa di te che stai evitando di guardare. Una volta sola basta. |
| 37 | `core/face/face_corpus.dart` | 18 | [Sei socievole e caloroso, attento/Sei socievole e calorosa, attenta/Hai un carattere socievole e caloroso, attento] agli altri e a metterli a proprio agio. |
| 38 | `core/face/face_corpus.dart` | 30 | [Sei metodico/Sei metodica/Hai metodo]: analizzi prima di decidere e costruisci un passo alla volta. |
| 39 | `core/face/face_corpus.dart` | 43 | [Sei espressivo e aperto/Sei espressiva e aperta/Hai un modo espressivo e aperto] alle emozioni, che leggi e lasci passare. |
| 40 | `core/face/face_corpus.dart` | 46 | [Sei concentrato e intuitivo/Sei concentrata e intuitiva/Hai uno spirito concentrato e intuitivo], con uno sguardo che va in profondità. |
| 41 | `core/face/face_corpus.dart` | 54 | [Sei generoso nel dare e nel parlare, caldo/Sei generosa nel dare e nel parlare, calda/Hai generosità nel dare e nel parlare, calore] nel condividere. |
| 42 | `core/face/face_corpus.dart` | 58 | [Sei essenziale e misurato/Sei essenziale e misurata/Hai un modo essenziale e misurato], scegli poche parole e le scegli bene. |
| 43 | `core/face/face_corpus.dart` | 65 | Sai quando muoverti e quando aspettare. La differenza la riconosci [da solo/da sola/senza aiuto]. |
| 44 | `core/face/face_corpus.dart` | 72 | [Resti fermo/Resti ferma/Tieni il punto] su quello che conta e lasci andare il resto senza farne una battaglia. |
| 45 | `core/face/face_corpus.dart` | 77 | [Sei generoso e aperto/Sei generosa e aperta/Hai un modo generoso e aperto], comunichi con slancio e allarghi il cerchio. |
| 46 | `core/face/face_corpus.dart` | 80 | [Sei raccolto/Sei raccolta/Hai un modo raccolto], tieni per te quello che conta finché non è il momento. |
| 47 | `core/face/face_corpus.dart` | 83 | [Sei costante e fermo/Sei costante e ferma/Hai costanza e fermezza], tieni la rotta anche quando intorno cambia tutto. |
| 48 | `core/face/face_corpus.dart` | 86 | [Sei rapido e adattabile/Sei rapida e adattabile/Hai prontezza e adattabilità], cambi passo appena serve senza irrigidirti. |
| 49 | `core/face/face_corpus.dart` | 93 | Ami la sfida e l'avventura, cerchi il rischio che ti fa sentire [vivo/viva/la vita addosso]. |
| 50 | `core/horoscope/horoscope_data.dart` | 269 | Se [sei da solo/sei da sola/non hai qualcuno accanto], un incontro leggero merita attenzione. |
| 51 | `core/horoscope/horoscope_data.dart` | 290 | La fortuna gira dalla tua parte nel pomeriggio, [fatti trovare pronto/fatti trovare pronta/tieniti a disposizione]. |
| 52 | `core/identity/natal_identity.dart` | 162 | movimento, cambiamento e sensi: [vivi libero/vivi libera/vivi in libertà]. |
| 53 | `core/identity/natal_identity.dart` | 167 | dono, compimento e universalità: [doni te stesso/doni te stessa/ti doni]. |
| 54 | `core/maestro/cio_che_aura_ricorda.dart` | 78 | Oggi [sei rimasto più a lungo/sei rimasta più a lungo/hai passato più tempo qui] della settimana scorsa. |
| 55 | `core/maestro/frasi_dell_attesa.dart` | 92 | Sto risalendo alla Luna [sotto cui sei nato/sotto cui sei nata/della tua nascita] |
| 56 | `core/maestro/il_respiro_di_oggi.dart` | 45 | [Oggi ti sei fermato a respirare/Oggi ti sei fermata a respirare/Oggi hai respirato] $nome. Anche quello è passato per la tua giornata. |
| 57 | `core/maestro/lente_del_cielo.dart` | 54 | la ${ancoraggio.valore} [sotto cui sei nato/sotto cui sei nata/della tua nascita] |
| 58 | `core/ricordi/lettura_del_mese.dart` | 179 | Con l'Iniziato, ogni mese il tuo Maestro dominante ti racconta dove [sei stato/sei stata/ti ha portato il cammino] e cosa è cambiato. |
| 59 | `core/rituals/animal_catalog.dart` | 142 | Fedeltà, libertà, fiducia nell'istinto: il Lupo ti insegna a stare nel gruppo senza perdere [te stesso/te stessa/chi sei]. |
| 60 | `core/rituals/dream_rite_corpus.dart` | 98 | hai dato luce, [ti sei speso/ti sei spesa/hai dato tanto] |
| 61 | `core/rituals/guide_animal_corpus.dart` | 150 | Si presenta come guida quando devi difendere i tuoi o ritrovare la tua tribù senza perdere [te stesso/te stessa/chi sei]. |
| 62 | `core/rituals/guide_animal_corpus.dart` | 164 | cammina in gruppo senza sciogliere [te stesso/te stessa/chi sei]. |
| 63 | `core/rituals/guide_animal_corpus.dart` | 175 | Si presenta come guida quando [sei chiamato/sei chiamata/la vita ti chiama] a una visione più grande e a governare [te stesso/te stessa/te] con nobiltà. |
| 64 | `core/rituals/guide_animal_corpus.dart` | 184 | governa [te stesso/te stessa/te] prima di guidare gli altri. |
| 65 | `core/rituals/guide_animal_corpus.dart` | 227 | Oggi tratta [te stesso/te stessa/te] e gli altri con una gentilezza nuova. |
| 66 | `core/rituals/guide_animal_corpus.dart` | 307 | porta con te la tua casa, [sei protetto/sei protetta/la protezione è con te]. |
| 67 | `core/rituals/relazione_lunare.dart` | 28 | Stanotte la Luna torna dov'era [quando sei nato/quando sei nata/alla tua nascita]: è il tuo ritorno lunare, il momento in cui il sentire ricomincia da capo. |
| 68 | `core/rituals/rito_alba_corpus.dart` | 854 | [Sei arrivato/Sei arrivata/Sei qui] prima che il rumore cominciasse. Il respiro che hai contato adesso lo hai contato nel silenzio. |
| 69 | `core/rituals/rito_alba_corpus.dart` | 867 | [Sei arrivato quando/Sei arrivata quando/Sei qui da quando] il giorno era ancora chiuso. Quello che hai portato con te lo hai scelto al buio. |
| 70 | `core/rituals/runes.dart` | 194 | L'alce, lo scudo alzato: [sei difeso, resta connesso/sei difesa, resta connessa/la difesa c'è, resta in contatto] al sacro. |
| 71 | `core/rituals/runes.dart` | 198 | [Sei più difeso/Sei più difesa/La tua difesa è più forte] di quanto credi: alza lo sguardo. |
| 72 | `core/rituals/runes.dart` | 238 | L'uomo, l'umanità: ritrova [te stesso/te stessa/chi sei] dentro la comunità. |
| 73 | `core/rituals/runes.dart` | 241 | [Conosci te stesso/Conosci te stessa/Conosci chi sei] attraverso gli altri. |
| 74 | `core/rituals/sunset_rune_corpus.dart` | 131 | Lascia fuori la guardia: qui [sei più difeso/sei più difesa/la tua difesa è più forte] di quanto credi. |
| 75 | `core/rituals/sunset_rune_corpus.dart` | 151 | Lascia fuori gli altri e i loro sguardi: stanotte torni [solo a te stesso/sola a te stessa/soltanto a te]. |
| 76 | `core/sigilli/sentiero_costellazione.dart` | 935 | Il Sole torna dov’era [quando sei nato/quando sei nata/alla tua nascita]: tu eri qui con l’Oroscopo. |
| 77 | `core/sigilli/sentiero_loto.dart` | 931 | Il Sole torna dov’era [quando sei nato/quando sei nata/alla tua nascita]: tu eri qui con il Rito dell’Alba. |
| 78 | `core/tarot/tarot_card.dart` | 150 | Un nuovo inizio ti chiama e il cielo ti chiede di [partire leggero/partire leggera/partire senza pesi], con fiducia e cuore aperto, anche senza vedere tutta la strada. Il Matto non è ingenuo, è libero e la sua leggerezza |
| 79 | `core/tarot/tarot_card.dart` | 193 | La creatività sembra bloccata, oppure [ti sei scordato di rivolgere a te stesso/ti sei scordata di rivolgere a te stessa/hai smesso di rivolgere a te] l'attenzione che dai a tutto il resto. Prima di far fiorire fuori, to |
| 80 | `core/tarot/tarot_card.dart` | 217 | Tradizione, insegnamento e senso condiviso ti sono vicini e vale la pena cercare un maestro, un consiglio, una sapienza più grande di te. C'è forza nell'appartenere a qualcosa che viene da lontano. Ma la guida vera non t |
| 81 | `core/tarot/tarot_card.dart` | 230 | C'è amore e c'è un bivio: una decisione che tocca i tuoi valori più veri, non solo il desiderio del momento. Il cielo ti chiede di scegliere con [tutto te stesso/tutta te stessa/tutto ciò che sei], testa e cuore insieme. |
| 82 | `core/tarot/tarot_card.dart` | 260 | C'è una verità che eviti, oppure una responsabilità che continui a rimandare. Finché resta in ombra, pesa. Guardala in faccia con calma, l'equilibrio torna nel momento in cui [sei onesto con te stesso/sei onesta con te s |
| 83 | `core/tarot/tarot_card.dart` | 301 | Forse dubiti della tua tenuta, o forse [sei diventato duro con te stesso/sei diventata dura con te stessa/ti tratti con durezza]. La vera forza non è la stretta, è la mano gentile. Torna a trattarti con mitezza e ritrovi |
| 84 | `core/tarot/tarot_card.dart` | 315 | L'attesa ha smesso di insegnare e sa di stallo, o [ti sei imposto/ti sei imposta/hai scelto] un sacrificio che non serve a nessuno. Cambia lo sguardo, oppure scendi dall'albero e torna ad agire. Non ogni rinuncia è nobil |
| 85 | `core/tarot/tarot_card.dart` | 380 | Dopo la tempesta arriva una luce dolce e con lei fiducia, ispirazione, la promessa che guarirai. La Stella non urla, rassicura: sei sulla strada giusta anche se [sei stanco/sei stanca/senti la stanchezza]. Lasciati guida |
| 86 | `core/tarot/tarot_card.dart` | 424 | Rimandi un bilancio che senti necessario, oppure ti giudichi con una durezza che non ti aiuta. La rinascita non nasce dalla condanna, ma dall'ascolto e dal perdono. [Sii con te stesso il giudice giusto, quello/Sii con te |
| 87 | `core/tarot/tarot_card.dart` | 434 | Pienezza, traguardo, integrazione: un ciclo si chiude in armonia e [tu sei arrivato/tu sei arrivata/sei] dove dovevi. È un momento di compimento, goditelo prima di aprire il prossimo cerchio. Ciò che hai attraversato ora |
| 88 | `core/tarot/tarot_card.dart` | 463 | C'è paura di osare, o una direzione ancora confusa che ti tiene sulla soglia. Prima di muoverti, chiarisci a [te stesso/te stessa/te] cosa vuoi davvero. Un passo deciso vale più di dieci fatti nel dubbio. |
| 89 | `core/tarot/tarot_card.dart` | 473 | Hai seminato e messo in moto qualcosa e ora comincia l'attesa dei frutti, l'espansione avviata. Guarda arrivare ciò che hai lanciato, con fiducia. I risultati sono in viaggio verso di te, [tienti pronto/tienti pronta/pre |
| 90 | `core/tarot/tarot_card.dart` | 515 | Un riconoscimento tarda ad arrivare, o un dubbio su di te ti fa sentire [poco valido/poco valida/di valere poco]. Ma il tuo valore resta anche quando l'applauso non c'è. Non legare ciò che vali solo a chi te lo conferma. |
| 91 | `core/tarot/tarot_card.dart` | 525 | È tempo di tenere il punto, di avere coraggio sotto pressione e difendere ciò in cui credi. Sei in vantaggio, anche se [ti senti assediato/ti senti assediata/senti l'assedio]. Hai la forza per reggere, non cedere proprio |
| 92 | `core/tarot/tarot_card.dart` | 528 | [Ti senti sopraffatto/Ti senti sopraffatta/Ti senti travolgere], o troppo sulla difensiva anche quando non serve. Scegli con lucidità dove vale la pena resistere e dove invece puoi lasciare. Non devi difendere ogni colli |
| 93 | `core/tarot/tarot_card.dart` | 551 | [Sei stanco ma vicino/Sei stanca ma vicina/La stanchezza c'è, ma sei vicino] al traguardo e la tenacia ora è tutto. Hai già fatto il più, non mollare proprio l'ultimo tratto. Un'ultima prova, poi potrai posare lo scudo. |
| 94 | `core/tarot/tarot_card.dart` | 567 | Porti un fardello che forse non ti appartiene, per abitudine o per senso del dovere. Lascia andare ciò che [ti sei caricato/ti sei caricata/porti] senza necessità. Alleggerirti non è tradire nessuno, è respirare. |
| 95 | `core/tarot/tarot_card.dart` | 603 | Sicurezza, calore, magnetismo: brilli con generosità e la tua fiamma scalda chi ti sta intorno. Sii pienamente [te stesso/te stessa/chi sei], è proprio questo che attrae. La tua luce non toglie spazio a nessuno. |
| 96 | `core/tarot/tarot_card.dart` | 656 | Amicizia, festa, comunità: è il tempo di celebrare insieme. La gioia condivisa raddoppia, quindi circondati di chi ti vuole bene. C'è qualcosa da festeggiare, [non farlo da solo/non farlo da sola/fallo in compagnia]. |
| 97 | `core/tarot/tarot_card.dart` | 698 | Il rischio è vivere di ricordi, [restare aggrappato/restare aggrappata/aggrapparti] a un tempo che non c'è più. Onora ciò che è stato, poi torna con dolcezza al presente. La vita ti aspetta adesso, non solo nella memoria |
| 98 | `core/tarot/tarot_card.dart` | 711 | Dopo la confusione arriva la chiarezza, metti a fuoco un desiderio vero tra i tanti. Ora sai quale strada vuoi. Scegliere una cosa è rinunciare alle altre ed è proprio questo che [ti rende libero/ti rende libera/ti dà li |
| 99 | `core/tarot/tarot_card.dart` | 789 | Ti perdi negli altri, assorbi ogni loro stato d'animo fino a smarrire il tuo. Riporta un poco di cura anche a [te stesso/te stessa/te]. Puoi amare senza annegare. |
| 100 | `core/tarot/tarot_card.dart` | 917 | Autonomia, agiatezza, frutti meritati con le tue mani: goditi ciò che hai costruito da te. È la carta dell'indipendenza serena. [Ti sei guadagnato/Ti sei guadagnata/Hai guadagnato] il tuo spazio, abitalo con piacere. |
| 101 | `core/tarot/tarot_card.dart` | 1074 | Astuzia, prudenza, agire con tatto invece che di forza. Usa l'ingegno, ma [resta onesto con te stesso/resta onesta con te stessa/non mentirti] su cosa stai facendo. La furbizia è un'arte, l'inganno una trappola anche per |
| 102 | `core/tarot/tarot_card.dart` | 1087 | [Ti senti bloccato/Ti senti bloccata/Ti sembra di non poterti muovere], ma i limiti sono soprattutto nella tua mente. Le corde sono più larghe di quanto credi e la benda te la puoi togliere. Il primo passo verso l'uscita |
| 103 | `core/tarot/tarot_card.dart` | 1090 | Una liberazione, una via che si apre dopo il senso di trappola. Riconosci la tua forza e fai il primo passo fuori. [Eri più libero/Eri più libera/Avevi più libertà] di quanto la paura ti diceva. |
| 104 | `core/tarot/tarot_card.dart` | 1155 | Una durezza, o una solitudine scelta come corazza. Ammorbidisci il giudizio, a partire da quello verso [te stesso/te stessa/te]. La lama più affilata non deve rivolgersi contro chi la porta. |
| 105 | `core/tarot/tarot_reading.dart` | 283 | Cosa [sei disposto/sei disposta/puoi] lasciare andare per fare spazio a questo? |
| 106 | `core/tarot/voce_della_stesa.dart` | 149 | [Sei sceso/Sei scesa/Sei qui] con questa domanda: «{domanda}» |
| 107 | `core/tarot/voce_della_stesa.dart` | 183 | È una carta che chiude un giro: qualcosa che portavi avanti ha trovato la sua forma, anche se [non te ne sei ancora accorto/non te ne sei ancora accorta/non l'hai ancora notato]. |
| 108 | `core/tarot/voce_della_stesa.dart` | 196 | Porta un compimento. Il rischio, qui, non è fallire: è non accorgersi di [essere arrivato/essere arrivata/essere al traguardo]. |
| 109 | `core/tarot/voce_della_stesa.dart` | 232 | Dice che c'è un prezzo. E che il prezzo è noto. Quello che non è ancora chiaro è se [sei disposto/sei disposta/vuoi] pagarlo. |
| 110 | `core/tarot/voce_della_stesa.dart` | 275 | Usa adesso quello che hai costruito, invece di aspettare di [sentirti più pronto/sentirti più pronta/avere più certezze]. |
| 111 | `core/tarot/voce_della_stesa.dart` | 281 | Chiedi adesso quello che rimandavi a quando [saresti stato più forte/saresti stata più forte/avresti avuto più forza]. |
| 112 | `core/tarot/voce_della_stesa.dart` | 402 | {passato} racconta [come ci sei arrivato/come ci sei arrivata/la strada fatta fin qui]. Non è un rimprovero, è il filo. |
| 113 | `core/viaggio/la_voce_del_mondo_di_sotto.dart` | 297 | [Sei sceso/Sei scesa/Sei qui] con la domanda {su}. |
| 114 | `features/account/account_screen.dart` | 783 | [Sei uscito/Sei uscita/Hai chiuso la sessione]. Il tuo cammino ti aspetta al rientro. |
| 115 | `features/account/account_screen.dart` | 928 | [Ne sei davvero sicuro/Ne sei davvero sicura/Vuoi davvero farlo]? |
| 116 | `features/account/custodia_del_cielo.dart` | 455 | Se [non ti sei mai registrato/non ti sei mai registrata/non hai ancora un account], potrai farlo tra poco, alla fine del rito, oppure dal menu utente. |
| 117 | `features/angels/angels_screen.dart` | 259 | Nasce dall'ora della tua nascita. Veglia sul tuo pensiero e su ciò che [sei venuto/sei venuta/sei qui] a fare. |
| 118 | `features/maestri/aura/face/face_constellation_screen.dart` | 1231 | Scansione completa. [Quando sei pronto/Quando sei pronta/Quando vuoi], cattura. |
| 119 | `features/onboarding/anteprima_tono.dart` | 53 | [Bentornato. Sei arrivato fin qui/Bentornata. Sei arrivata fin qui/Che bello vederti qui]: il tuo cielo ti aspettava. |
| 120 | `features/onboarding/domanda_dell_invito.dart` | 169 | Se [sei arrivato/sei arrivata/sei qui] da un invito, chi te lo ha mandato riceve il suo premio. Tocca Incolla: dal link che hai ricevuto prendiamo soltanto il codice. Si fa una volta sola. |
| 121 | `features/onboarding/maestro_reveal_screen.dart` | 747 | [Benvenuto/Benvenuta/Ti do il benvenuto] nel cerchio |
| 122 | `features/onboarding/risveglio_journey.dart` | 381 | Guarda il cielo [in cui sei nato/in cui sei nata/della tua nascita] |
| 123 | `features/onboarding/scena_del_ritrovamento.dart` | 223 | [Bentornato/Bentornata/Di nuovo] nel Cerchio |
