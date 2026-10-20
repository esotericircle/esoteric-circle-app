# I gesti propiziatori del Tong Shu

Ordine GA, voce GA.04, 20 ottobre 2026. Il quarto paragrafo del responso Lungo dell'Oroscopo cinese, nel riquadro "Il gesto propiziatorio": un'attività che l'almanacco tradizionale cinese (Tong Shu, 通勝/通書; nella forma popolare 黄历) lega al giorno attraverso i dodici ufficiali del giorno (建除十二神, detti anche 十二值星). Per Settimana, Mese e Anno vale l'ufficiale del primo giorno del periodo: la variante "periodo" lo dice nel testo.

## Le fonti

1. **欽定協紀辨方書 (Qinding Xieji Bianfang Shu)**, compilato sotto la direzione di 允祿 (Yunlu) per l'imperatore Qianlong, 1739, nel 四庫全書 (Siku Quanshu), sezione 術數. Juan 4, 義例二, "建除十二神". Testo in linea: https://zh.wikisource.org/wiki/欽定協紀辨方書_(四庫全書本)/卷04 (consultato il 20 ottobre 2026). Da qui vengono:
   - la regola del calcolo: "其法從月建上起建……如正月建寅則寅日起建順行十二辰是也" (si comincia Jian dal ramo del mese: nel mese Yin, il giorno Yin è Jian, poi si procede in ordine) e "每月交節則疊兩值日" (a ogni ingresso di un termine solare jie l'ufficiale si ripete per due giorni);
   - il senso di ciascun ufficiale, nella spiegazione della loro successione: Chu "除舊布新" (toglie il vecchio e dispone il nuovo); Man "滿則必溢" (ciò che è pieno trabocca); Ping "繼滿故必以平" (segue il pieno, quindi livella); Zhi "執者守其成也" (Zhi custodisce ciò che è compiuto); Po "對七為衝衝則破也" (il settimo è opposto, l'opposizione rompe); Wei "救破以危" (dopo la rottura viene la vigilanza); Cheng "繼危者成"; Shou "既成必收" (compiuto, si raccoglie); Kai è il soffio vitale che comincia e Bi lo racchiude, "唯其能閉故復能建" (solo perché sa chiudere la serie torna a Jian);
   - alcuni 宜 legati agli spiriti che accompagnano gli ufficiali: per Jian "宜封建視事" (assumere un incarico e attendere agli affari), per Man "宜祀神祗求福願" (onorare gli spiriti ed esprimere voti), per Ding "宜運謀算畫計策" (fare piani e calcoli), per Zhi "宜修造築垣" (costruire, alzare muri), per Kai "宜叙婚姻行宴樂" (unioni e conviti).
2. **淮南子 (Huainanzi), "天文訓" (Tianwen xun)**, II secolo a.C., la successione legata ai rami: "寅爲建，卯爲除，辰爲滿，巳爲平……子爲開……丑爲閉". Testo in linea: https://zh.wikisource.org/wiki/淮南子/天文訓 (consultato il 20 ottobre 2026).
3. **La sintesi corrente degli almanacchi** sui 宜 e 忌 dei dodici, "择日必读：建除十二神", sohu.com, 12 ottobre 2023: https://www.sohu.com/a/727671351_121819358 (consultato il 20 ottobre 2026). Riporta per esempio: 建 宜 入学、出行、赴任; 除 宜 祭祀、祈福; 满 宜 祭祀、祈福、结亲; 平 宜 动土、修饰; 定 宜 祭祀、祈福、制定计划; 执 宜 祭祀、祈福、捕捉; 破 宜 破屋, 忌 各类吉事; 危 宜 祭祀、祈福, 忌 迁移、登高; 成 宜 开市、嫁娶、移徙、出行; 收 宜 祭祀、祈福、入学; 开 宜 开市、嫁娶、祭祀、祈福; 闭 宜 祭祀、塞穴、筑堤, 忌 开市、出行.
4. **建除十二神**, Wikipedia in cinese: https://zh.wikipedia.org/wiki/建除十二神 (consultato il 20 ottobre 2026), per il rimando al juan 4 dello Xieji Bianfang Shu, per i 忌 del calendario di Dunhuang del 924 (後唐同光二年曆書) e per l'elenco dei 宜 di Jian nel calendario dei contadini (農民曆).
5. **Il riscontro già fatto nel repository**, `docs/collaudo/ES/cinese.txt`, paragrafo 2 (ordine ES voce 08): la stessa tabella dei 宜 e 忌, controllata sugli almanacchi in linea huangli999.com e huangli888.com per Bi (1 ottobre 2026), Zhi (8 ottobre), Po (9 ottobre, "诸事不宜", 宜 "破屋 坏垣") e Man (17 ottobre).

**Avvertenza di metodo**, già scritta nell'ordine ES: nell'almanacco completo il consiglio del giorno nasce dall'ufficiale insieme a molti altri spiriti (神煞). Questi gesti leggono **il solo ufficiale del giorno**, non l'almanacco intero.

## Il giudizio sul calcolo del repository

`lib/core/horoscope/l_almanacco_cinese.dart`, `LAlmanaccoCinese.guardiano`: guardiano = (ramo del giorno - ramo del mese solare) mod 12, con 0 = Jian ... 11 = Bi; il ramo del mese è quello aperto dall'ultimo jie (data all'ora di Pechino) che non supera il giorno (`ramoDelMese`, `indiceDelJie`, tabella `ITerminiSolari` 1900-2100, il primo jie della tabella apre il mese Chou). **Il calcolo è giusto** e segue alla lettera la regola dello Xieji Bianfang Shu, juan 4:
- il giorno il cui ramo coincide col ramo del mese è Jian ("從月建上起建", con l'esempio del mese Yin e del giorno Yin): la differenza vale zero proprio in quel giorno;
- la sequenza procede in ordine coi rami ("順行十二辰"), come nella successione del Huainanzi;
- nel giorno del jie il ramo del giorno avanza di uno e anche il ramo del mese avanza di uno, quindi la differenza resta quella del giorno prima: l'ufficiale si ripete ("每月交節則疊兩值日") senza una regola in più. In Dart l'operatore `%` dà sempre un resto non negativo, quindi la differenza negativa non è un difetto.
La verifica sui numeri è già nel repository (`docs/collaudo/ES/cinese.txt` e `cinese_verifica.csv`): trenta giorni su trenta uguali a `lunar_python` e a `cnlunar`, cinque su cinque uguali agli almanacchi in linea, compreso il giorno di Han Lu dell'8 ottobre 2026 che ripete Zhi.

## Le scelte dei gesti

Per ogni ufficiale si è preso un 宜 della tradizione che una persona può compiere subito, lasciando fuori ciò che tocca salute (求医), denaro (纳财, 求财, 开市 come commercio) e questioni legali (立约, 词讼):
- Jian, Stabilire: cominciare, mettersi in cammino, entrare in uno studio (入学、出行、赴任; 封建視事).
- Chu, Togliere: sgombrare, togliere il vecchio per fare posto (除舊布新).
- Man, Pieno: esprimere voti e ringraziare, stringere i legami di famiglia (祭祀、祈福、结亲; 求福願); e la misura, perché il pieno trabocca.
- Ping, Livellare: aggiustare e abbellire, mettere in pari (修饰; 繼滿以平).
- Ding, Fissare: fare piani, fissare (制定计划; 運謀算畫計策); niente liti né partenze (忌 词讼、出行).
- Zhi, Tenere: custodire ciò che c'è, costruire e piantare (守其成; 修造築垣).
- Po, Rompere: la tradizione lo dà sfavorevole a ogni cosa propizia (诸事不宜) e adatto solo a demolire (破屋 坏垣): il gesto è buttare il rotto, spezzare un'abitudine, non cominciare.
- Wei, Pericolo: raccoglimento e voti (祭祀、祈福), prudenza; niente spostamenti né salite (忌 迁移、登高). Le fonti non sono unanimi sul suo peso: il testo non lo dice infausto, dice che chiede vigilanza.
- Cheng, Compiere: portare a termine, partire, unire (成; 出行、移徙、嫁娶 come unione degli affetti).
- Shou, Raccogliere: raccogliere i frutti, studiare (既成必收; 入学); niente viaggi lunghi (忌 出行).
- Kai, Aprire: aprire, incontrare persone, conviti (开为生气; 叙婚姻行宴樂).
- Bi, Chiudere: anch'esso poco propizio (闭破不相当), adatto a chiudere falle e alzare argini (塞穴、筑堤): il gesto è chiudere, sigillare, completare, custodire.

## Da dove viene

- Jian: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Jian, il giorno che stabilisce.
- Chu: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Chu, il giorno che toglie.
- Man: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Man, il giorno del pieno.
- Ping: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Ping, il giorno che livella.
- Ding: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Ding, il giorno che fissa.
- Zhi: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Zhi, il giorno che tiene.
- Po: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Po, il giorno che rompe.
- Wei: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Wei, il giorno della vigilanza.
- Cheng: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Cheng, il giorno che compie.
- Shou: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Shou, il giorno che raccoglie.
- Kai: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Kai, il giorno che apre.
- Bi: Il gesto viene dall'almanacco tradizionale cinese, il Tong Shu, che lega a ogni giorno uno dei dodici ufficiali: questo è Bi, il giorno che chiude.

## I riti

### Jian, Generale, giorno
- Rito: Oggi è il giorno di Jian, l'ufficiale che stabilisce: l'almanacco lo lega agli inizi. Scegli una cosa che rimandi da tempo e dalle adesso il primo passo concreto. Scrivi la prima riga, apri il primo quaderno, segna la data in cima alla pagina. Il resto può aspettare domani.

### Jian, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Jian, l'ufficiale che stabilisce le fondamenta. Il suo gesto vale per tutto il tratto: decidi adesso che cosa vuoi avviare e mettilo per iscritto in una frase sola. Poi compi il primo passo, anche piccolo, perché l'almanacco affida a Jian gli inizi.

### Jian, Amore, giorno
- Rito: Oggi l'almanacco segna Jian, il giorno che stabilisce e dà inizio. Negli affetti vuol dire fare il primo passo: manda tu il messaggio che aspetti di ricevere, oppure proponi alla persona amata una cosa nuova da fare insieme nei prossimi giorni. Comincia con poche parole semplici.

### Jian, Amore, periodo
- Rito: Il primo giorno di questo periodo appartiene a Jian, che stabilisce. Per gli affetti è il tempo di fondare un'abitudine condivisa: scegli con la persona amata un piccolo rito comune, una passeggiata o una cena senza telefoni. Fissa adesso il primo appuntamento in calendario.

### Jian, Carriera, giorno
- Rito: Oggi governa Jian, l'ufficiale che stabilisce: la tradizione gli affida chi assume un incarico o comincia uno studio. Al lavoro apri adesso il compito che continui a spostare e completa soltanto il primo passaggio. Annota dove ti fermi così domani riprendi da lì.

### Jian, Carriera, periodo
- Rito: Il primo giorno di questo periodo è sotto Jian, il giorno degli inizi. Nel lavoro vale per tutto il tratto: scrivi su un foglio il progetto che vuoi avviare, dividilo in tre passi e comincia oggi il primo. Tieni il foglio dove lo vedi ogni mattina.

### Jian, Fortuna, giorno
- Rito: Oggi è Jian, il giorno che stabilisce: l'almanacco lo consiglia a chi si mette in cammino o entra in una scuola. Per le occasioni cerca un inizio: iscriviti a un corso, prendi una strada mai fatta, chiedi a qualcuno di insegnarti una cosa che non sai.

### Jian, Fortuna, periodo
- Rito: Il primo giorno del periodo è di Jian, l'ufficiale che apre la serie dei dodici. Le occasioni chiedono un punto di partenza: scegli un luogo nuovo da frequentare o una competenza da imparare in questo tratto di tempo. Fai adesso la prima mossa concreta per avvicinarti.

### Chu, Generale, giorno
- Rito: Oggi è il giorno di Chu, l'ufficiale che toglie: l'almanacco antico lo spiega come il giorno che leva il vecchio per far posto al nuovo. Scegli un cassetto, una mensola o il piano della scrivania e sgombralo adesso. Tieni solo ciò che usi davvero.

### Chu, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Chu, che toglie il vecchio e prepara il nuovo. Comincia il tratto con uno sgombero: fai una lista di tre cose che occupano spazio senza servire più e liberatene una oggi stesso. Le altre due seguono con calma.

### Chu, Amore, giorno
- Rito: Oggi l'almanacco indica Chu, il giorno che toglie. Negli affetti lascia andare un piccolo rancore che porti da tempo verso la persona amata o verso un familiare. Diglielo con parole semplici oppure scrivilo su un foglio e poi strappalo. Fai spazio a ciò che conta.

### Chu, Amore, periodo
- Rito: Il periodo si apre con Chu, l'ufficiale che toglie: il primo giorno porta il suo segno. Per gli affetti è tempo di sgombrare le abitudini che vi allontanano. Parla con la persona amata di una cosa sola da lasciare indietro insieme e cominciate subito a farlo.

### Chu, Carriera, giorno
- Rito: Oggi è Chu, il giorno che leva il vecchio. Al lavoro libera la scrivania e la casella di posta: archivia ciò che è chiuso, cancella i promemoria superati, butta le carte inutili. Uno spazio sgombro aiuta a vedere quale compito viene davvero prima degli altri.

### Chu, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Chu, l'ufficiale che toglie. Nel lavoro comincia togliendo invece di aggiungere: rileggi gli impegni presi e scegli quello che non ha più senso portare avanti. Chiudilo con garbo adesso così il resto del tratto trova spazio.

### Chu, Fortuna, giorno
- Rito: Oggi governa Chu, il giorno che toglie per fare posto. Le occasioni arrivano dove c'è spazio: riordina l'ingresso di casa, apri le finestre, porta via una cosa che non usi più da mesi. Lascia libero un angolo della stanza per ciò che deve ancora venire.

### Chu, Fortuna, periodo
- Rito: Il primo giorno di questo periodo è segnato da Chu, che leva il vecchio e prepara il nuovo. Per le occasioni sgombra il tempo prima delle cose: togli dall'agenda un impegno che non ti somiglia più. In quello spazio vuoto lascia entrare una possibilità diversa.

### Man, Generale, giorno
- Rito: Oggi è il giorno di Man, l'ufficiale del pieno: l'almanacco lo dedica alle offerte e ai desideri espressi. Accendi una candela oppure metti un fiore sul tavolo e pronuncia a voce bassa un desiderio per chi ami. Poi ringrazia per una cosa che oggi c'è già.

### Man, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Man, il pieno, che la tradizione lega ai voti e ai ringraziamenti. Apri il tratto scrivendo su un foglio tre cose di cui senti gratitudine e un desiderio solo. Conserva il foglio e rileggilo alla fine del periodo.

### Man, Amore, giorno
- Rito: Oggi l'almanacco segna Man, il giorno pieno, adatto a stringere i legami di famiglia. Chiama un parente che non senti da tempo oppure invita la persona amata a condividere un pasto preparato con cura. Riempi la tavola con poche cose buone e tempo senza fretta.

### Man, Amore, periodo
- Rito: Il primo giorno del periodo porta Man, l'ufficiale del pieno che la tradizione affida ai legami familiari. Per gli affetti organizza un incontro che riunisca le persone care, anche solo un caffè a casa tua. Scegli adesso la data e manda il primo invito.

### Man, Carriera, giorno
- Rito: Oggi governa Man, il giorno del pieno: ciò che è colmo chiede misura. Al lavoro guarda quello che hai già raccolto, una pratica finita o un risultato ottenuto: riconoscilo con una riga di bilancio. Ringrazia un collega che ti ha aiutato in questi giorni.

### Man, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Man, il pieno. L'almanacco antico avverte che ciò che è colmo trabocca: nel lavoro comincia il tratto senza caricarti di impegni nuovi. Fai l'elenco di ciò che già porti e scegli dove mettere la tua cura migliore.

### Man, Fortuna, giorno
- Rito: Oggi è Man, il giorno del pieno, che la tradizione lega ai desideri espressi. Per le occasioni dai forma a ciò che speri: scrivilo in una frase chiara e leggila ad alta voce davanti alla finestra. Un desiderio detto con precisione diventa più facile da riconoscere.

### Man, Fortuna, periodo
- Rito: Il primo giorno di questo periodo appartiene a Man, l'ufficiale del pieno. Le occasioni amano chi sa accogliere: prepara adesso un piccolo spazio in casa con un oggetto che per te significa gioia. Guardalo ogni mattina come un augurio per il tratto.

### Ping, Generale, giorno
- Rito: Oggi è il giorno di Ping, l'ufficiale che livella: l'almanacco lo trova adatto ad aggiustare e abbellire. Ripara una piccola cosa rimasta guasta in casa, un bottone o una maniglia che cigola. Poi sistema un angolo perché sia più bello da guardare.

### Ping, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Ping, che porta le cose al pari. Comincia il tratto con le riparazioni rimandate: scrivi l'elenco delle piccole cose da aggiustare e risolvine una oggi. Un ordine semplice rende il cammino più piano per tutto il periodo.

### Ping, Amore, giorno
- Rito: Oggi governa Ping, il giorno che spiana e mette in pari. Negli affetti appiana un piccolo attrito rimasto in sospeso con la persona amata: ascolta la sua versione fino in fondo prima di rispondere. Poi cerca insieme un punto d'incontro, anche minimo.

### Ping, Amore, periodo
- Rito: Il periodo si apre col primo giorno di Ping, l'ufficiale che livella. Per gli affetti è un tempo di equilibrio: guarda se nella relazione uno dei due dà più dell'altro e proponi adesso un piccolo cambio di compiti. Rendere le cose pari è già un modo di volersi bene.

### Ping, Carriera, giorno
- Rito: Oggi l'almanacco indica Ping, il giorno piano, adatto ad aggiustare. Al lavoro rimetti in sesto ciò che zoppica: correggi un documento pieno di errori, aggiorna una cartella disordinata, sistema uno strumento che usi ogni giorno. Rifinire vale quanto creare, a volte anche di più.

### Ping, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Ping, che livella. Nel lavoro distribuisci il carico in modo più uniforme: guarda le prossime giornate e sposta gli impegni dove sono troppo fitti. Comincia oggi riordinando l'agenda di domani con calma.

### Ping, Fortuna, giorno
- Rito: Oggi è Ping, il giorno che rende piano il terreno. Per le occasioni abbellisci il luogo dove passi più tempo: un fiore, una luce migliore, una superficie lucidata. La tradizione lega questo giorno ai lavori di rifinitura che preparano l'accoglienza.

### Ping, Fortuna, periodo
- Rito: Il primo giorno di questo periodo è segnato da Ping, l'ufficiale che mette in pari. Le occasioni passano più volentieri su una strada liscia: individua un ostacolo pratico che ti frena e rimuovilo adesso. Una pratica rimasta in sospeso, una risposta da dare.

### Ding, Generale, giorno
- Rito: Oggi è il giorno di Ding, l'ufficiale che fissa: l'almanacco antico lo indica per i piani e per i calcoli. Siediti per dieci minuti con un foglio e disegna il piano dei prossimi giorni. Decidi una priorità e scrivila in alto.

### Ding, Generale, periodo
- Rito: Il primo giorno di questo periodo appartiene a Ding, che rende stabili le cose. È il momento di fare il piano dell'intero tratto: fissa tre obiettivi chiari e per ciascuno una data. Evita di disperdere le forze in imprese improvvise.

### Ding, Amore, giorno
- Rito: Oggi governa Ding, il giorno che fissa e consolida. Negli affetti trasforma un'intenzione in un appuntamento: scegli con la persona amata un giorno e un'ora per stare insieme senza distrazioni. La tradizione sconsiglia le discussioni accese, quindi rimanda ogni polemica a un momento più calmo.

### Ding, Amore, periodo
- Rito: Il periodo si apre con un primo giorno di Ding, l'ufficiale che stabilizza. Per gli affetti è tempo di promesse piccole e mantenibili: concorda con la persona amata un gesto che vi impegnate a ripetere con regolarità. Fissalo adesso, con un giorno preciso della settimana.

### Ding, Carriera, giorno
- Rito: Oggi l'almanacco segna Ding, adatto a chi deve pianificare. Al lavoro prendi un progetto confuso e scrivine la scaletta: le fasi, chi fa cosa, quando finisce ciascun passaggio. Un piano messo nero su bianco libera la mente per il resto della giornata.

### Ding, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Ding, l'ufficiale che fissa. Nel lavoro stabilisci adesso le regole del tratto: orari, priorità, momenti senza interruzioni. Scrivile in un posto visibile e condividile con chi lavora accanto a te, così il tratto parte con chiarezza.

### Ding, Fortuna, giorno
- Rito: Oggi è Ding, il giorno che rende saldo ciò che è incerto. Per le occasioni fissa un appuntamento con qualcuno che può aprirti una porta: un incontro, una telefonata, una lettera. Metti data e ora nero su bianco così l'occasione prende forma.

### Ding, Fortuna, periodo
- Rito: Il primo giorno di questo periodo è di Ding, che la tradizione dedica ai progetti ben pensati. Le occasioni si riconoscono meglio con una mappa: scrivi dove vuoi arrivare entro la fine del periodo e quali persone potrebbero aiutarti. Tieni la mappa a portata di mano.

### Zhi, Generale, giorno
- Rito: Oggi è il giorno di Zhi, l'ufficiale che tiene: l'almanacco antico dice che custodisce ciò che è stato compiuto. Scegli una buona abitudine che hai già e rinforzala adesso, ripetendola con più attenzione del solito. Mantenere conta quanto cominciare, dice questo giorno.

### Zhi, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Zhi, che tiene saldo il raggiunto. La tradizione lo lega al costruire e al piantare: metti a dimora una piantina o un seme in un vaso e curalo per tutto il tratto. Ogni volta che lo annaffi ricorda ciò che vuoi custodire.

### Zhi, Amore, giorno
- Rito: Oggi governa Zhi, il giorno che tiene e protegge. Negli affetti mantieni una promessa fatta alla persona amata, anche piccola, oggi stesso. Se non ne hai in sospeso fai un gesto che dica la tua presenza costante: un messaggio a metà giornata, una mano sulla spalla.

### Zhi, Amore, periodo
- Rito: Il primo giorno del periodo è affidato a Zhi, l'ufficiale che custodisce ciò che esiste già. Per gli affetti non cercare novità: rafforza quello che c'è. Scegli con la persona amata una consuetudine che vi fa bene e proteggetela dagli impegni per tutto il tratto.

### Zhi, Carriera, giorno
- Rito: Oggi l'almanacco indica Zhi, il giorno che tiene fermo. Al lavoro consolida un risultato già ottenuto: salva le versioni definitive, documenta come hai risolto un problema, metti al sicuro i file importanti. Ciò che è custodito con cura resta disponibile domani.

### Zhi, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Zhi, che tiene. La tradizione sconsiglia in questo giorno di aprire attività nuove: nel lavoro porta avanti con costanza ciò che hai già avviato. Scegli il progetto principale del tratto e dedica oggi la prima ora a quello.

### Zhi, Fortuna, giorno
- Rito: Oggi è Zhi, il giorno che trattiene e conserva. Per le occasioni non lasciar cadere un contatto prezioso: rispondi a quel messaggio rimasto aperto, ringrazia chi ti ha dato un'indicazione utile. Le occasioni restano vicine a chi sa tenerle con garbo.

### Zhi, Fortuna, periodo
- Rito: Il primo giorno di questo periodo appartiene a Zhi, l'ufficiale che custodisce. Le occasioni del tratto vengono spesso da ciò che hai già: scorri i tuoi contatti e scegli tre persone con cui riallacciare un filo. Comincia adesso con la prima.

### Po, Generale, giorno
- Rito: Oggi è il giorno di Po, l'ufficiale che rompe: l'almanacco lo sconsiglia per quasi ogni impresa e lo lascia soltanto al demolire. Non cominciare nulla di importante. Butta via invece un oggetto rotto che conservi senza motivo e lascia quel vuoto com'è.

### Po, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Po, il giorno della rottura, che la tradizione trova adatto solo a smontare. Apri il tratto senza avviare nulla: individua una cattiva abitudine e spezzala oggi con un gesto preciso. Rimanda le partenze ai giorni successivi.

### Po, Amore, giorno
- Rito: Oggi governa Po, il giorno che rompe, poco adatto agli affetti nuovi secondo l'almanacco. Non forzare dichiarazioni né decisioni importanti. Fai piuttosto ordine nei ricordi: elimina una vecchia foto o un messaggio che ti ferisce ancora quando lo rileggi. Il vuoto che resta è spazio.

### Po, Amore, periodo
- Rito: Il periodo comincia con Po, l'ufficiale della rottura: la tradizione gli lascia soltanto il demolire. Per gli affetti non progettare grandi svolte nel primo giorno. Rompi invece uno schema che si ripete tra voi, per esempio la stessa discussione: cambiane adesso il copione.

### Po, Carriera, giorno
- Rito: Oggi l'almanacco segna Po, il giorno che rompe, sfavorevole agli inizi e alle intese. Al lavoro non lanciare progetti nuovi. Smantella piuttosto una procedura inutile: una riunione che nessuno vuole, un passaggio doppio, un modulo superato. Togliere ciò che è guasto è il suo compito.

### Po, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Po, che la tradizione dedica soltanto al demolire. Nel lavoro usa questo inizio per smontare ciò che non regge: guarda un metodo che ti rallenta da tempo e decidi di abbandonarlo. Il nuovo può partire domani.

### Po, Fortuna, giorno
- Rito: Oggi è Po, il giorno della rottura, in cui l'almanacco consiglia di non intraprendere nulla di propizio. Per le occasioni il gesto è sgomberare la strada: rompi un'abitudine che ti blocca, come rimandare sempre la stessa risposta. Domani la via è più libera.

### Po, Fortuna, periodo
- Rito: Il primo giorno di questo periodo appartiene a Po, l'ufficiale che spezza. Le occasioni non si inseguono in questo inizio: la tradizione lo lascia al demolire. Elimina adesso un impegno che ti pesa senza portarti nulla e rimanda a domani ogni passo nuovo.

### Wei, Generale, giorno
- Rito: Oggi è il giorno di Wei, l'ufficiale del pericolo: l'almanacco lo consiglia per il raccoglimento e sconsiglia di salire in alto o di cambiare casa. Prenditi cinque minuti di silenzio in un luogo tranquillo. Pensa a chi vuoi proteggere e dedicagli un pensiero.

### Wei, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Wei, il giorno della vigilanza. La tradizione lo affida alle preghiere e ai voti, non agli spostamenti. Apri il tratto con calma: ricontrolla i piani prima di muoverti e dedica un momento di silenzio a ciò che desideri custodire.

### Wei, Amore, giorno
- Rito: Oggi governa Wei, il giorno che chiede attenzione. Negli affetti non affrontare le questioni delicate di fretta. Raccogliti un momento e pensa con affetto alla persona amata, poi diglielo con un messaggio semplice. La tradizione lega questo giorno ai voti più che alle imprese.

### Wei, Amore, periodo
- Rito: Il primo giorno del periodo è di Wei, l'ufficiale della prudenza. Per gli affetti è un inizio da vivere con delicatezza: osserva ciò che nella relazione è fragile e proteggilo invece di metterlo alla prova. Esprimi adesso un augurio sincero per la persona amata.

### Wei, Carriera, giorno
- Rito: Oggi l'almanacco indica Wei, il giorno del pericolo, poco adatto ai salti nel vuoto. Al lavoro controlla due volte prima di inviare: rileggi una comunicazione importante, verifica i dati, chiedi un parere. La cautela di oggi può evitare correzioni nei giorni seguenti.

### Wei, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Wei, che invita alla vigilanza. Nel lavoro comincia il tratto senza cambi bruschi: annota i punti deboli dei progetti in corso e scegli quale mettere in sicurezza per primo. Fallo adesso con calma.

### Wei, Fortuna, giorno
- Rito: Oggi è Wei, il giorno in cui la tradizione sconsiglia viaggi per mare e salite in alto. Per le occasioni resta con i piedi per terra: valuta con lucidità una proposta che ti è arrivata e chiedi tempo prima di rispondere. Una pausa ponderata è un gesto saggio.

### Wei, Fortuna, periodo
- Rito: Il primo giorno di questo periodo è segnato da Wei, l'ufficiale del pericolo. Le occasioni del tratto chiedono discernimento: scrivi accanto a ogni possibilità che vedi un rischio e una precauzione. Dedica poi un momento di raccoglimento a ciò che speri.

### Cheng, Generale, giorno
- Rito: Oggi è il giorno di Cheng, l'ufficiale che compie: l'almanacco lo considera fra i più adatti a portare a termine. Scegli una cosa lasciata a metà e finiscila adesso, anche se è piccola. Un libro da chiudere, una lettera da spedire, un armadio da completare.

### Cheng, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Cheng, che porta le cose a compimento. Inaugura il tratto chiudendo una faccenda in sospeso da troppo tempo. Poi scegli l'impresa che vuoi vedere compiuta entro la fine del periodo e scrivila.

### Cheng, Amore, giorno
- Rito: Oggi governa Cheng, il giorno del compimento, che la tradizione lega anche alle unioni. Negli affetti completa un gesto rimasto a metà: la sorpresa progettata e mai fatta, la parola gentile trattenuta. Dedicalo adesso alla persona amata, senza aspettare un'occasione speciale.

### Cheng, Amore, periodo
- Rito: Il primo giorno del periodo è di Cheng, l'ufficiale che compie e unisce. Per gli affetti è un buon segno d'inizio: realizza con la persona amata un progetto di cui parlate da tempo, un viaggio breve o una stanza da sistemare. Stabilite oggi il primo passo concreto.

### Cheng, Carriera, giorno
- Rito: Oggi l'almanacco segna Cheng, il giorno adatto ad aprire e a concludere. Al lavoro porta a termine il compito più vicino alla fine e consegnalo prima di sera. Poi segnalo come chiuso: vedere una cosa completata può dare slancio a quelle che seguono.

### Cheng, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Cheng, che compie. Nel lavoro fai di questo inizio un traguardo: scegli il progetto più maturo e fissa adesso il passo che lo chiude. Coinvolgi chi deve approvarlo così il compimento non resta in sospeso.

### Cheng, Fortuna, giorno
- Rito: Oggi è Cheng, il giorno che l'almanacco dedica a partire e a trasferirsi. Per le occasioni muoviti: vai di persona dove finora hai solo scritto, partecipa a un incontro, visita un luogo che ti incuriosisce. Spesso le cose si compiono quando ci si mette in strada.

### Cheng, Fortuna, periodo
- Rito: Il primo giorno di questo periodo appartiene a Cheng, l'ufficiale del compimento. Le occasioni del tratto chiedono di arrivare in fondo: riprendi una possibilità lasciata cadere a metà strada e completa adesso il passaggio che mancava. Una risposta, una richiesta, una visita.

### Shou, Generale, giorno
- Rito: Oggi è il giorno di Shou, l'ufficiale che raccoglie: l'almanacco antico dice che dopo il compimento viene il raccolto. Fermati a mettere insieme ciò che hai ottenuto in questo tempo e scrivilo in un elenco. Leggilo con calma e riconosci il cammino fatto.

### Shou, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Shou, che raccoglie i frutti. Apri il tratto riordinando quello che hai già: foto, appunti, idee sparse in tanti posti. Riuniscile in un unico luogo oggi e scegli quale coltivare nelle prossime giornate.

### Shou, Amore, giorno
- Rito: Oggi governa Shou, il giorno del raccolto. Negli affetti raccogli i momenti belli: ripensa con la persona amata a un ricordo felice vissuto insieme e raccontatevelo a vicenda. Poi mettilo per iscritto oppure stampa una foto di quel giorno e appendila.

### Shou, Amore, periodo
- Rito: Il primo giorno del periodo è di Shou, l'ufficiale che raccoglie. Per gli affetti è tempo di riconoscere ciò che la relazione ha già dato: scrivi su un biglietto tre cose belle che la persona amata ti ha donato in questo ultimo tratto. Consegna il biglietto adesso.

### Shou, Carriera, giorno
- Rito: Oggi l'almanacco indica Shou, adatto a chi entra in una scuola e a chi raccoglie. Al lavoro raccogli ciò che hai imparato: annota in una pagina le lezioni dell'ultimo progetto, gli errori e le soluzioni. Tienila a portata di mano per il prossimo inizio.

### Shou, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Shou, che la tradizione lega allo studio. Nel lavoro scegli una competenza da coltivare per tutto il tratto e dedica oggi mezz'ora alla prima lezione. Raccogli materiali, appunti e domande in una cartella dedicata.

### Shou, Fortuna, giorno
- Rito: Oggi è Shou, il giorno del raccolto, che l'almanacco sconsiglia per i viaggi lunghi. Per le occasioni resta nei paraggi e raccogli: rispondi alle proposte arrivate, rileggi gli inviti ricevuti, segna quali meritano un sì. Spesso l'occasione è già sulla soglia.

### Shou, Fortuna, periodo
- Rito: Il primo giorno di questo periodo appartiene a Shou, l'ufficiale che raccoglie. Le occasioni del tratto possono nascere da ciò che hai seminato prima: ripercorri gli incontri degli ultimi mesi e scegli quello da far maturare. Fai adesso un passo per riprenderlo.

### Kai, Generale, giorno
- Rito: Oggi è il giorno di Kai, l'ufficiale che apre: l'almanacco antico lo chiama il soffio vitale che comincia. Spalanca porte e finestre per qualche minuto, lascia entrare luce e aria. Poi apri anche l'agenda e fai spazio a un incontro che desideri.

### Kai, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Kai, che la tradizione lega ai banchetti e alle feste. Inaugura il tratto con una tavola aperta: invita a casa amici o vicini per un pasto semplice. Scegli adesso la data e manda gli inviti.

### Kai, Amore, giorno
- Rito: Oggi governa Kai, il giorno che apre, che l'almanacco antico dedica alle unioni e ai conviti. Negli affetti apri il cuore con una frase sincera alla persona amata, di quelle che di solito tieni per te. Dilla guardandola negli occhi oppure scrivila a mano.

### Kai, Amore, periodo
- Rito: Il primo giorno del periodo è di Kai, l'ufficiale dell'apertura. Per gli affetti è tempo di allargare il cerchio: presenta la persona amata a un amico caro, oppure fatevi presentare insieme qualcuno di nuovo. Organizza adesso il primo incontro, anche una semplice cena a casa.

### Kai, Carriera, giorno
- Rito: Oggi l'almanacco segna Kai, il giorno propizio ad aprire un'attività. Al lavoro apri un canale nuovo: scrivi a una persona che stimi e che non conosci ancora, proponi un'idea in riunione, inaugura un fascicolo per un progetto. Un'apertura piccola basta.

### Kai, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Kai, che apre. Nel lavoro dai inizio al tratto con una presentazione: racconta a chi lavora con te il progetto che vuoi aprire e chiedi chi vuole partecipare. Fallo adesso, finché il soffio dell'inizio è fresco.

### Kai, Fortuna, giorno
- Rito: Oggi è Kai, il giorno dell'apertura, fra i più graditi alla tradizione. Per le occasioni esci e incontra persone: accetta un invito, parla con qualcuno che vedi spesso senza mai salutare, entra in un luogo nuovo del quartiere. Un saluto può aprire una porta.

### Kai, Fortuna, periodo
- Rito: Il primo giorno di questo periodo appartiene a Kai, l'ufficiale che apre le porte. Le occasioni del tratto passano dagli incontri: scegli un gruppo, un corso o un'associazione da frequentare e fai adesso la prima telefonata. Aprire la porta è il gesto.

### Bi, Generale, giorno
- Rito: Oggi è il giorno di Bi, l'ufficiale che chiude: l'almanacco lo sconsiglia per aprire o partire e lo lascia al sigillare. Chiudi una cosa rimasta aperta: un barattolo, una porta che sbatte, una faccenda sospesa. Poi riponi quello che hai usato.

### Bi, Generale, periodo
- Rito: Il primo giorno di questo periodo è di Bi, che chiude e custodisce. La tradizione spiega che senza chiusura il nuovo non può nascere. Comincia il tratto completando ciò che è incompiuto: fai la lista delle questioni aperte e chiudine una oggi, con un gesto definitivo.

### Bi, Amore, giorno
- Rito: Oggi governa Bi, il giorno che chiude, poco adatto alle promesse nuove secondo l'almanacco. Negli affetti custodisci invece di cercare: passa la sera in casa con la persona amata, telefoni spenti, porta chiusa. Proteggere l'intimità è il gesto di oggi.

### Bi, Amore, periodo
- Rito: Il primo giorno del periodo è di Bi, l'ufficiale che sigilla. Per gli affetti chiudi con dolcezza una questione rimasta in sospeso, un chiarimento promesso o una scusa mai detta. Fallo adesso, così il periodo può ripartire libero da pesi vecchi.

### Bi, Carriera, giorno
- Rito: Oggi l'almanacco indica Bi, il giorno che chiude, sfavorevole all'avvio di attività. Al lavoro completa invece di aprire: chiudi le pratiche finite, archivia le cartelle, rispondi agli ultimi messaggi rimasti sospesi. Lascia la scrivania sgombra prima di andare via, pronta per il prossimo inizio.

### Bi, Carriera, periodo
- Rito: Il primo giorno di questo periodo cade sotto Bi, che la tradizione lega a chiudere le falle e alzare argini. Nel lavoro individua il punto dove si disperde più tempo e mettici un argine adesso: una regola, un orario, un limite. Proteggi così le energie del tratto.

### Bi, Fortuna, giorno
- Rito: Oggi è Bi, il giorno che sigilla, in cui l'almanacco sconsiglia di inseguire novità. Per le occasioni conserva ciò che hai: rileggi una proposta già accettata e porta a termine l'ultimo passaggio. Una porta chiusa bene aiuta a preparare la prossima apertura.

### Bi, Fortuna, periodo
- Rito: Il primo giorno di questo periodo appartiene a Bi, l'ultimo dei dodici ufficiali. Dopo di lui la serie torna a Jian, che stabilisce. Per le occasioni chiudi adesso un capitolo: saluta un progetto finito, ringrazia chi ti ha accompagnato. Così prepari spazio per ciò che ricomincia.
