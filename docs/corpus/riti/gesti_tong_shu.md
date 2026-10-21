# I gesti propiziatori del Tong Shu

Ordine GA, voce GA.04, 20 ottobre 2026. Il quarto paragrafo del responso Lungo dell'Oroscopo cinese, nel riquadro "Il gesto propiziatorio": un'attività che l'almanacco tradizionale cinese (Tong Shu, 通勝/通書; nella forma popolare 黄历) lega al giorno attraverso i dodici ufficiali del giorno (建除十二神, detti anche 十二值星). Per Settimana, Mese e Anno vale l'ufficiale del primo giorno del periodo, e ciascuno ha la sua variante (ordine GA voce GA.06, 21 ottobre 2026): "settimana" e "mese" cominciano oggi, nel giorno dell'ufficiale, e il testo dice i sette o i trenta giorni da oggi; "anno" dice che l'anno cinese è nato a Capodanno sotto l'ufficiale e dà un gesto da fare adesso, che vale in qualunque punto dell'anno, senza parlare di inizio. La vecchia variante unica "periodo" non esiste più: dava lo stesso testo alla Settimana e all'Anno e faceva "inaugurare il tratto" a un anno cominciato da mesi.

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

- Jian: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Jian, il giorno che stabilisce.
- Chu: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Chu, il giorno che toglie.
- Man: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Man, il giorno del pieno.
- Ping: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Ping, il giorno che livella.
- Ding: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Ding, il giorno che fissa.
- Zhi: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Zhi, il giorno che tiene.
- Po: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Po, il giorno che rompe.
- Wei: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Wei, il giorno della vigilanza.
- Cheng: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Cheng, il giorno che compie.
- Shou: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Shou, il giorno che raccoglie.
- Kai: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Kai, il giorno che apre.
- Bi: Il gesto viene dal Tong Shu, l'almanacco cinese che lega ogni giorno a un ufficiale: questo è Bi, il giorno che chiude.

## I riti

### Jian, Generale, giorno
- Rito: Oggi è il giorno di Jian, l'ufficiale che stabilisce. Scegli una cosa rimandata da tempo e compi adesso il primo passo concreto: scrivi la prima riga, apri il quaderno nuovo, metti la data in cima alla pagina. Il resto può aspettare: conta che la cosa sia avviata.

### Jian, Generale, settimana
- Rito: La settimana che nasce oggi appartiene a Jian, che pone le fondamenta. Metti sul tavolo un oggetto che rappresenti ciò che vuoi far crescere nei sette giorni (una chiave, un sasso, una matita) e lascialo in vista. Ogni volta che lo incontri, fai un passo in quella direzione.

### Jian, Generale, mese
- Rito: Jian, primo dei dodici ufficiali, governa il giorno da cui partono questi trenta giorni. Scegli un progetto che vuoi vedere in piedi entro il mese e segna nell'agenda quattro date, una per settimana, ciascuna col passo da compiere. Compi il primo subito, prima di sera.

### Jian, Generale, anno
- Rito: Sotto Jian, che dà forma stabile alle cose, il tuo anno cinese è venuto al mondo a Capodanno. Il suo gesto vale in qualunque giorno: prendi una decisione sospesa da tempo e rendila concreta con un atto preciso, una prenotazione, una domanda inviata, un sì detto a voce.

### Jian, Amore, giorno
- Rito: Oggi l'almanacco segna Jian, il giorno che dà fondamento agli affetti. Tocca a te il primo passo: manda il messaggio che aspetti di ricevere, a chi ami o, se sei senza legame, a una persona che desideri conoscere meglio. Bastano poche parole, semplici e vere.

### Jian, Amore, settimana
- Rito: Con Jian, che mette le basi, si apre oggi una settimana adatta a fondare un'abitudine degli affetti. Se hai un legame, proponi a chi ami dieci minuti di dialogo ogni sera, senza telefoni; se sei senza legame, scegli una sera fissa per uscire con gli amici e rispettala.

### Jian, Amore, mese
- Rito: Per trenta giorni, da oggi, gli affetti seguono Jian, l'ufficiale che edifica. Costruisci un piccolo rito di tavola: una cena preparata insieme ogni settimana con chi ami oppure, se sei senza legame, un pranzo fisso con persone care e qualcuno di nuovo. Fissa adesso la prima data.

### Jian, Amore, anno
- Rito: Negli affetti conta il segno di Jian, l'ufficiale che dà stabilità: sotto di lui è nato a Capodanno il tuo anno cinese. Scegli adesso un luogo dove tornare con costanza, insieme a chi ami o, se sei senza legame, per conoscere persone nuove: un circolo, un coro, un'associazione di quartiere.

### Jian, Carriera, giorno
- Rito: Oggi governa Jian, che istituisce: la tradizione lo dà buono anche a chi assume un incarico. Al lavoro apri il compito che continui a spostare e completa soltanto il primo passaggio. Prima di chiudere annota il punto preciso da cui riprendere.

### Jian, Carriera, settimana
- Rito: Sotto Jian, che fonda, comincia oggi la tua settimana di lavoro e di studio. Proponi a chi coordina il tuo lavoro un compito nuovo da prendere in carico e parlane di persona entro questi sette giorni. Prepara adesso la frase con cui chiederlo, breve e chiara.

### Jian, Carriera, mese
- Rito: Al lavoro e nello studio questi trenta giorni partono da Jian, che avvia le cose ed è propizio, dice l'almanacco, anche a chi entra in una scuola. Iscriviti adesso al corso che rimandi, oppure scegli un manuale della tua materia e fissa un'ora alla settimana per studiarlo.

### Jian, Carriera, anno
- Rito: Il lavoro di quest'anno cinese segue Jian, che guida la serie dei dodici: l'anno è nato sotto di lui a Capodanno. Prepara adesso il terreno a un compito che nessuno ha ancora avviato: raccogli in una cartella ciò che serve, dalle un nome e mettila in cima alla scrivania.

### Jian, Fortuna, giorno
- Rito: Oggi è Jian, il giorno che rende solido ciò che nasce e che l'almanacco dà buono anche per mettersi in cammino. Per le occasioni prendi una strada mai percorsa per andare dove devi: guarda le vetrine, le insegne, i volti. Un percorso nuovo mostra ciò che l'abitudine nasconde.

### Jian, Fortuna, settimana
- Rito: Nei sette giorni che Jian, l'ufficiale che costruisce, governa da oggi, le occasioni chiedono un primo contatto. Telefona a una persona che fa già ciò che vorresti fare tu e chiedile come ha mosso i primi passi. Ascolta con attenzione, prendi nota, ringrazia.

### Jian, Fortuna, mese
- Rito: Per le occasioni dei trenta giorni che partono oggi con Jian, che mette in piedi le cose ed è buono anche per chi parte, scegli una meta vicina mai visitata: un borgo, un museo, un sentiero. Decidi adesso con chi andarci e come arrivarci.

### Jian, Fortuna, anno
- Rito: Le occasioni del tuo anno cinese, nato a Capodanno sotto Jian, passano anche dal mettersi in cammino, che l'almanacco affianca allo stabilire. Rendi adesso pronti gli strumenti dell'uscita: riordina la borsa, sistema le scarpe, gonfia le ruote della bicicletta. Ciò che è pronto invita a partire.

### Chu, Generale, giorno
- Rito: Oggi è il giorno di Chu, l'ufficiale che toglie il vecchio per fare spazio al nuovo. Apri la dispensa o il frigorifero e porta via adesso ciò che è scaduto o dimenticato da tempo. Lascia sul ripiano soltanto quello che usi davvero.

### Chu, Generale, settimana
- Rito: Chu, che sgombra, regge la settimana che nasce oggi. Passa un panno umido sulla soglia di casa e sul pavimento dell'ingresso, poi togli le scarpe e le borse accumulate lì vicino. Nei sette giorni che seguono tieni libero quel passaggio: è la porta da cui entra il nuovo.

### Chu, Generale, mese
- Rito: Trenta giorni sotto il segno di Chu, che libera, partono oggi. Ogni settimana scegli un'abitudine che consuma tempo senza restituire nulla, come scorrere notizie a vuoto: sospendila per sette giorni. Comincia adesso dalla più ingombrante e osserva che cosa entra nello spazio liberato.

### Chu, Generale, anno
- Rito: Quest'anno cinese ha visto la luce a Capodanno sotto Chu, che spazza via il superfluo. Il suo gesto vale in ogni momento: rileggi adesso i propositi che ti porti dietro da tempo e depenna con un tratto deciso quello che non ti appartiene più. Non sostituirlo subito.

### Chu, Amore, giorno
- Rito: Oggi l'almanacco indica Chu, il giorno che fa pulizia. Negli affetti lascia andare un piccolo rancore che porti da tempo, verso chi ami o chi hai amato, oppure in famiglia: scrivilo su un foglio, rileggilo una volta e poi strappalo. Resta più spazio per ciò che conta.

### Chu, Amore, settimana
- Rito: La settimana degli affetti che oggi Chu inaugura, l'ufficiale che sfronda, chiede di abbandonare le abitudini che allontanano. Se hai un legame, lascia fuori dalla tavola i telefoni per sette giorni; se sei senza legame, smetti di controllare il profilo di chi ti ha ferito. Comincia stasera.

### Chu, Amore, mese
- Rito: Con Chu, che fa largo, cominciano oggi trenta giorni per alleggerire il cuore. Ogni settimana rileggi una conversazione che ancora pesa, di un amore finito o di una lite recente: cancella i messaggi che non vuoi più portare con te. Comincia adesso dalla più vecchia.

### Chu, Amore, anno
- Rito: Il cuore, in quest'anno cinese nato a Capodanno sotto Chu, chiede spazio libero più che cose nuove: Chu è l'ufficiale che svuota per preparare. Scegli adesso una pretesa che pesa sugli affetti, verso chi ami o verso chi cerchi: dilla ad alta voce un'ultima volta per lasciarla andare.

### Chu, Carriera, giorno
- Rito: Oggi governa Chu, il giorno che rimuove. Al lavoro libera il piano della scrivania: butta le carte inutili, i fogli doppi, le penne che non scrivono più. Tieni a portata di mano soltanto ciò che serve al compito di oggi. Uno spazio vuoto aiuta a vedere le priorità.

### Chu, Carriera, settimana
- Rito: Con Chu, l'ufficiale che leva ciò che è superato, la settimana di lavoro comincia togliendo invece di aggiungere. Scegli un impegno che non ha più senso portare avanti e chiudilo adesso con garbo, per iscritto, a chi di dovere. Così i sette giorni respirano.

### Chu, Carriera, mese
- Rito: Il mese di lavoro e di studio che si apre oggi porta il segno di Chu, che sfoltisce. Ogni settimana togli dal tuo metodo un passaggio inutile: una copia di troppo, un controllo doppio, una riunione che non decide nulla. Adesso scegli il primo e annota come farne a meno.

### Chu, Carriera, anno
- Rito: Sotto Chu, che elimina l'inutile, è nato a Capodanno il tuo anno cinese. Nel lavoro e nello studio il suo gesto vale in qualsiasi giorno: apri adesso la memoria del computer, cancella le cartelle doppie e i file superati, poi svuota il cestino digitale.

### Chu, Fortuna, giorno
- Rito: Oggi è Chu, il giorno del ricambio. Per le occasioni spalanca le finestre di tutte le stanze per qualche minuto e lascia uscire l'aria ferma. Intanto togli dal davanzale e dal tavolo ciò che si è accumulato senza motivo. Un luogo arioso accoglie meglio.

### Chu, Fortuna, settimana
- Rito: In questa settimana di Chu, che scarta ciò che non serve, le occasioni chiedono tempo libero prima ancora di cose nuove. Togli dall'agenda dei sette giorni un impegno che non ti somiglia più e lascia vuota quell'ora: usala per una passeggiata senza meta.

### Chu, Fortuna, mese
- Rito: Le occasioni dei trenta giorni che partono oggi con Chu, l'ufficiale che porta via, chiedono posto. Metti accanto alla porta una borsa vuota e ogni sera aggiungi un oggetto che non usi, da regalare. Quando è piena, consegnala a chi ne ha bisogno. Comincia adesso con il primo.

### Chu, Fortuna, anno
- Rito: A Capodanno l'anno cinese è nato sotto Chu, l'ufficiale che fa posto. Per le occasioni il gesto vale in qualunque giorno: libera adesso un angolo della casa da ciò che non usi, puliscilo e lascialo vuoto. Quel posto libero lascia spazio a ciò che deve venire.

### Man, Generale, giorno
- Rito: Oggi è il giorno di Man, l'ufficiale del pieno, che l'almanacco dedica anche alle offerte e ai desideri espressi. Accendi una candela sul tavolo e pronuncia a voce bassa un augurio per chi ti è caro. Poi ringrazia per una cosa che oggi c'è già.

### Man, Generale, settimana
- Rito: Man, il giorno colmo, governa oggi il primo dei sette giorni: la tradizione lo lega ai voti e ai ringraziamenti. Scrivi su un foglio tre doni ricevuti di recente e un desiderio solo. Piegalo, tienilo in tasca e rileggilo quando la settimana si chiude.

### Man, Generale, mese
- Rito: Il mese che comincia oggi appartiene a Man: l'almanacco antico avverte che il troppo pieno trabocca. Per i trenta giorni scegli una misura semplice: una sera libera alla settimana, senza impegni né schermi. Fissala adesso sul calendario e difendila da ogni richiesta.

### Man, Generale, anno
- Rito: Man, l'ufficiale della pienezza, ha accolto a Capodanno la nascita del tuo anno cinese. Il gesto vale adesso come in ogni altro giorno: riempi un bicchiere d'acqua fino all'orlo, guardalo un istante e bevine un sorso. Ciò che è pieno chiede misura, dice la tradizione.

### Man, Amore, giorno
- Rito: Oggi l'almanacco segna Man, il giorno pieno, buono anche per stringere i legami di famiglia. Telefona a un parente che non senti da tempo e ascolta le sue notizie senza fretta. Se hai un legame, fallo insieme a chi ami; se sei senza legame, chiama anche un'amicizia cara.

### Man, Amore, settimana
- Rito: Sotto Man, che la tradizione lega alle famiglie unite, la settimana degli affetti chiede una tavola condivisa. Nei sette giorni invita a casa le persone care, la famiglia o gli amici più stretti, per un caffè e qualcosa di dolce. Manda adesso il primo invito.

### Man, Amore, mese
- Rito: Gli affetti seguono Man, l'ufficiale che riempie, per trenta giorni da oggi. Scegli una persona cara, chi ami o chi ti piacerebbe conoscere meglio: dedicale ogni settimana un gesto di cura, cominciando adesso con un messaggio affettuoso. La cura ripetuta riempie un legame più di un grande gesto.

### Man, Amore, anno
- Rito: Nato a Capodanno sotto Man, il pieno, propizio ai voti per tradizione, il tuo anno cinese affida gli affetti alla famiglia. Prepara adesso un piccolo dono fatto a mano per un parente o per chi ami, o per un'amicizia se sei senza legame: consegnalo con un augurio.

### Man, Carriera, giorno
- Rito: Oggi governa Man, il giorno che chiede misura a ciò che è carico. Al lavoro ringrazia di persona chi ti ha dato una mano in questi giorni, con parole precise su ciò che ha fatto. Un grazie detto bene riempie la giornata di chi lo riceve.

### Man, Carriera, settimana
- Rito: Con Man, che trabocca se lo si carica troppo, si apre una settimana in cui al lavoro conviene non aggiungere impegni. Per sette giorni, a ogni nuova richiesta, rispondi che ci pensi e decidi soltanto a mente fredda, dopo aver guardato quanto porti già.

### Man, Carriera, mese
- Rito: I tuoi trenta giorni di lavoro e di studio partono da Man, il giorno che porta le cose al colmo. Raccogli in una cartella i lavori riusciti dell'ultimo tratto e mostrali a una persona di fiducia: chiedile che cosa vede di buono. Fallo adesso, prima di aggiungere altro.

### Man, Carriera, anno
- Rito: Nel lavoro di quest'anno cinese, venuto al mondo sotto Man a Capodanno, vale l'avvertenza dell'almanacco: quel che si colma oltre misura si versa. Prima di accettare un nuovo incarico, lascia adesso un impegno a chi può prenderlo con più respiro, spiegando con chiarezza come si svolge.

### Man, Fortuna, giorno
- Rito: Oggi è Man, il giorno della misura colma, legato dalla tradizione ai desideri espressi. Per le occasioni dai forma a ciò che speri: dillo in una frase chiara, a voce alta, davanti alla finestra aperta. Un desiderio detto con precisione è più facile da riconoscere quando passa.

### Man, Fortuna, settimana
- Rito: Una settimana sotto Man, il recipiente colmo, comincia oggi: le occasioni amano chi sa ricevere. Prepara un angolo della casa con un oggetto che per te significa gioia, una conchiglia, un disegno, un ricordo di viaggio. Guardalo ogni mattina come un augurio.

### Man, Fortuna, mese
- Rito: Nel mese che parte oggi con Man, ufficiale del colmo e dei voti, le occasioni chiedono gratitudine. Metti in casa un fiore fresco e rinnovalo ogni settimana dei trenta giorni: ogni volta che lo sostituisci, ringrazia per un'occasione ricevuta. Comincia adesso con il primo fiore.

### Man, Fortuna, anno
- Rito: Le occasioni di quest'anno cinese, sorto a Capodanno sotto Man, passano dalle offerte che l'almanacco lega al pieno. Riempi adesso una ciotola di frutta e mettila al centro della tavola come augurio: offrine a chiunque passi da casa, finché dura.

### Ping, Generale, giorno
- Rito: Oggi è il giorno di Ping, l'ufficiale che livella: l'almanacco lo trova adatto anche ad aggiustare. Ripara adesso una piccola cosa rimasta guasta, un bottone che pende, una maniglia che cigola, una lampadina spenta. Rimettere in pari le piccole cose dà ordine all'intera giornata.

### Ping, Generale, settimana
- Rito: La settimana che oggi apre Ping, che porta le cose al pari, chiede occhi attenti alle linee storte. Raddrizza i quadri, allinea i libri sullo scaffale, metti in squadra il tappeto. Ogni giorno dei sette sistema una linea che pende: è il gesto dell'ufficiale.

### Ping, Generale, mese
- Rito: Ping, che spiana ogni dislivello, segna l'avvio del tuo mese. Per i trenta giorni cerca un ritmo pari: dopo ogni ora di impegno intenso concediti qualche minuto di pausa, in piedi, lontano dagli schermi. Comincia adesso con la prima pausa e respira a fondo.

### Ping, Generale, anno
- Rito: Ping, che rende pari ciò che pende, ha dato a Capodanno il suo segno al tuo anno cinese. Il gesto vale in qualunque momento: restituisci adesso una cosa ricevuta in prestito, un libro, oppure ricambia un favore rimasto senza risposta. I conti di cortesia tornano in pari.

### Ping, Amore, giorno
- Rito: Oggi governa Ping, il giorno piano. In amore appiana un piccolo attrito: se hai un legame, ascolta fino in fondo la versione di chi ami prima di rispondere; se sei senza legame, chiarisci con garbo un malinteso nato in una conoscenza recente.

### Ping, Amore, settimana
- Rito: Ping, che rimette in equilibrio, dà oggi il tono a sette giorni di parità negli affetti. Se hai un legame, lascia ogni sera a chi ami la scelta di qualcosa, il film, la cena, la passeggiata; se sei senza legame, lascia scegliere a un'amicizia il programma della serata.

### Ping, Amore, mese
- Rito: I trenta giorni che cominciano oggi con Ping, l'ufficiale delle cose messe in pari, chiedono agli affetti riconoscimento reciproco. Ogni settimana riconosci a voce, a chi ami o a un'amicizia se sei senza legame, un gesto che compie per te e che di solito dai per scontato. Comincia adesso.

### Ping, Amore, anno
- Rito: Ping, che pareggia, segna gli affetti del tuo anno cinese, nato sotto di lui a Capodanno. Correggi adesso una piccola disparità: se hai un legame, prendi tu un compito che di solito spetta a chi ami; se sei senza legame, ricambia un'amicizia che dà più di quanto riceve.

### Ping, Carriera, giorno
- Rito: Oggi l'almanacco indica Ping, il giorno che rende uniforme, adatto ai lavori di rifinitura. Al lavoro correggi un documento pieno di imprecisioni: rileggilo ad alta voce, sistema le cifre e i nomi, uniforma i caratteri. Rifinire vale quanto creare, a volte di più.

### Ping, Carriera, settimana
- Rito: Nel lavoro, la settimana che nasce oggi sotto Ping, che smussa i picchi, chiede un carico distribuito. Apri l'agenda dei sette giorni e sposta gli impegni dai giorni troppo fitti a quelli più leggeri. Fallo adesso, prima di ogni altra cosa.

### Ping, Carriera, mese
- Rito: Trenta giorni di lavoro e di studio partono oggi da Ping, che aggiusta ciò che zoppica. Scegli lo strumento che usi di più, un programma, un modello di documento, un'abitudine di metodo: miglioralo un poco ogni settimana. Adesso correggi il primo difetto che noti.

### Ping, Carriera, anno
- Rito: Ping, sotto cui è nato a Capodanno il tuo anno cinese, chiede al lavoro un piano ben in bolla. Regola adesso la tua postazione: lo schermo all'altezza degli occhi, la sedia alla giusta misura, il piano sgombro e dritto. Un luogo in pari aiuta il lavoro di ogni giorno.

### Ping, Fortuna, giorno
- Rito: Oggi è Ping, il giorno che leviga, legato dalla tradizione ai lavori di abbellimento. Per le occasioni abbellisci il luogo dove passi più tempo: un fiore in un bicchiere, un panno sulla superficie opaca, una luce meglio orientata. Un ambiente curato prepara l'accoglienza.

### Ping, Fortuna, settimana
- Rito: Le occasioni dei sette giorni che oggi apre Ping, che rende piana la strada, passano più volentieri dove non si inciampa. Individua un ostacolo pratico che ti frena, una pratica in sospeso, un documento da rinnovare: toglilo di mezzo adesso, senza rimandare.

### Ping, Fortuna, mese
- Rito: Il mese di Ping, ufficiale delle superfici lisce, comincia oggi: per le occasioni prepara l'accoglienza. Nei trenta giorni rinnova l'ingresso di casa, il luogo dove si arriva: una soglia pulita, uno zerbino nuovo, una luce calda accanto alla porta. Comincia adesso con un solo dettaglio.

### Ping, Fortuna, anno
- Rito: Quest'anno cinese è nato a Capodanno sotto Ping, che rende scorrevole il passaggio: per le occasioni il gesto è togliere un intralcio. Fallo adesso in casa: sposta il mobile in cui urti sempre, fissa il tappeto che si arriccia, libera il corridoio. Dove si passa bene, si passa più spesso.

### Ding, Generale, giorno
- Rito: Oggi è il giorno di Ding, l'ufficiale che fissa: l'almanacco antico lo indica per i piani e per i calcoli. Siediti dieci minuti con un foglio e disegna il piano della giornata, ora per ora. Scegli una priorità sola e scrivila in alto, ben chiara.

### Ding, Generale, settimana
- Rito: Ding, che rende stabili le cose, governa oggi l'avvio della settimana. Fissa un orario per svegliarti e uno per coricarti, uguali per tutti i sette giorni: regola adesso la sveglia. Un ritmo fermo dà forza a ogni altro proposito. Rimanda le partenze che non servono.

### Ding, Generale, mese
- Rito: Sotto Ding, che consolida, comincia oggi il tuo mese. Appendi al muro un calendario dei trenta giorni e segna in ciascuna settimana una sola cosa da rendere salda, con un colore diverso. Fallo adesso, poi guardalo ogni mattina prima di uscire.

### Ding, Generale, anno
- Rito: A Capodanno Ding, l'ufficiale che ferma ciò che oscilla, ha dato il suo segno al tuo anno cinese. Il gesto vale in qualsiasi momento: fissa adesso ciò che traballa in casa, una mensola, una sedia, un'anta; stringi le viti. Ciò che è saldo regge meglio ogni giorno.

### Ding, Amore, giorno
- Rito: Oggi governa Ding, il giorno che rende saldo ciò che è incerto. Negli affetti trasforma un'intenzione in un orario: fissa per stasera una telefonata a chi ami o, se sei senza legame, a una persona che vorresti conoscere meglio. Poi mantienila, qualunque cosa accada.

### Ding, Amore, settimana
- Rito: Con Ding, l'ufficiale che stabilizza, oggi parte una settimana di promesse piccole e mantenibili. Concorda con chi ami un saluto fisso alla stessa ora ogni sera dei sette giorni oppure, se sei senza legame, promettiti un'uscita in cui incontrare persone nuove. Decidilo adesso.

### Ding, Amore, mese
- Rito: Ding, che assesta, segna l'avvio di trenta giorni in cui l'almanacco sconsiglia le liti. Negli affetti fissa una regola semplice, con chi ami o con chi frequenti: quando il tono sale, una pausa di dieci minuti prima di rispondere. Stabiliscila adesso e rispettala ogni volta.

### Ding, Amore, anno
- Rito: Il segno di Ding, che dà radici, accompagna gli affetti del tuo anno cinese, nato sotto di lui a Capodanno. Metti adesso accanto al letto un oggetto che ricordi un impegno preso, verso chi ami o, se sei senza legame, verso la tua vita affettiva. Guardalo ogni sera.

### Ding, Carriera, giorno
- Rito: Oggi l'almanacco segna Ding, il giorno fermo, adatto a chi deve pianificare. Al lavoro prendi un progetto confuso e scrivine la scaletta: le fasi, chi fa cosa, quando finisce ciascun passaggio. Un piano nero su bianco libera la mente per il resto della giornata.

### Ding, Carriera, settimana
- Rito: In questa settimana di lavoro, aperta oggi da Ding, l'ufficiale che mette paletti, stabilisci subito le regole: orari, priorità, momenti senza interruzioni. Scrivile in un posto visibile e condividile con chi lavora accanto a te, così i sette giorni partono con chiarezza.

### Ding, Carriera, mese
- Rito: Ding, ufficiale del calcolo e della fermezza, governa il primo dei tuoi trenta giorni di lavoro e di studio. Misura per una settimana quanto tempo ti chiede davvero ogni compito ricorrente e annotalo: poi fissa le stime per il resto del mese. Comincia adesso dal primo compito.

### Ding, Carriera, anno
- Rito: Per il lavoro e lo studio, l'anno cinese nato sotto Ding a Capodanno chiede scelte ferme. Prendi adesso la decisione che lasci in sospeso da troppo, fra due strade, due metodi, due offerte: scegline una e comunicala a chi deve saperlo. Ciò che è deciso smette di pesare.

### Ding, Fortuna, giorno
- Rito: Oggi è Ding, il giorno che dà contorni netti. Per le occasioni prepara ciò che serve a coglierle: un curriculum aggiornato, i recapiti giusti, una presentazione di poche righe. Raccogli tutto adesso in un'unica cartella, così niente resta incerto o disperso.

### Ding, Fortuna, settimana
- Rito: Ding, l'ufficiale dei progetti ben fondati, regge oggi una settimana in cui le occasioni si riconoscono meglio con una mappa. Apri sul telefono una nota con ciò che speri e, sotto, i nomi di tre persone che potrebbero aiutarti. Rileggila ogni mattina dei sette giorni.

### Ding, Fortuna, mese
- Rito: Le occasioni del mese che comincia oggi con Ding, che dà ancoraggio, chiedono appuntamenti fissati, non attese. Scegli tre persone che possono aprirti una porta e fissa con ciascuna un incontro nei trenta giorni. Scrivi adesso la prima data, con l'ora e il luogo.

### Ding, Fortuna, anno
- Rito: Ding, che mette ogni cosa al suo posto, ha fissato a Capodanno il segno del tuo anno cinese. Per le occasioni scegli adesso un luogo del quartiere dove tornare con regolarità, un mercato, un caffè, finché le persone imparano a riconoscerti. Le occasioni passano da chi si trova sempre lì.

### Zhi, Generale, giorno
- Rito: Oggi è il giorno di Zhi, l'ufficiale che tiene: l'almanacco antico dice che conserva ciò che è stato compiuto. Scegli una buona abitudine che hai già e ripetila adesso con più attenzione del solito. Mantenere vale quanto cominciare, ricorda questo giorno.

### Zhi, Generale, settimana
- Rito: Zhi, che tiene saldo il raggiunto, governa la settimana che nasce oggi: la tradizione lo dà buono anche per costruire e piantare. Metti a dimora un seme in un vaso e annaffialo ogni giorno dei sette. Mentre lo fai, pensa a ciò che vuoi far durare.

### Zhi, Generale, mese
- Rito: Il mese che parte oggi porta il segno di Zhi, che protegge il compiuto ed è propizio a edificare. Costruisci qualcosa di piccolo un poco ogni settimana: una mensola, un modellino, un orto sul balcone. Comincia adesso con il primo pezzo e lascialo dove si vede.

### Zhi, Generale, anno
- Rito: Sotto Zhi, che mantiene ciò che c'è, il tuo anno cinese è nato a Capodanno. Il suo gesto è la manutenzione, buona in qualunque giorno: prendi adesso una cosa che usi da tempo e rimettila in forma, come lucidare le scarpe, cucire una fodera, oliare la catena della bicicletta.

### Zhi, Amore, giorno
- Rito: Oggi governa Zhi, il giorno della fedeltà. In amore mantieni oggi stesso una piccola promessa: a chi ami, se hai un legame; a te, se sei senza legame, come accettare un invito per incontrare persone nuove. Una parola tenuta vale più di dieci dette.

### Zhi, Amore, settimana
- Rito: Affidata a Zhi, che difende ciò che esiste già, la settimana degli affetti non chiede novità. Se hai un legame, scegli con chi ami un'abitudine che vi fa bene e proteggetela da ogni impegno; se sei senza legame, tieni ferma un'ora per ciò che ti appassiona. Decidila adesso.

### Zhi, Amore, mese
- Rito: Zhi, l'ufficiale che non lascia cadere, apre oggi trenta giorni in cui gli affetti si rafforzano con la costanza. Scegli un legame che conta, un amore, un'amicizia, un familiare: chiama quella persona ogni settimana nello stesso momento, anche solo per pochi minuti. Fai adesso la prima chiamata.

### Zhi, Amore, anno
- Rito: Gli affetti del tuo anno cinese, nato a Capodanno sotto Zhi, chiedono di tenere caro ciò che c'è. Rinnova adesso un gesto che avevate perso, con chi ami o con chi ti vuole bene da sempre: un caffè insieme al mattino, una canzone, un luogo dove tornare.

### Zhi, Carriera, giorno
- Rito: Oggi l'almanacco indica Zhi, il giorno che trattiene. Al lavoro metti al sicuro un risultato già ottenuto: salva le versioni definitive, fai una copia dei file importanti, conserva in un luogo protetto ciò che ti è costato fatica. Ciò che è al sicuro resta a disposizione.

### Zhi, Carriera, settimana
- Rito: Sotto Zhi, che regge ciò che è avviato, la settimana di lavoro chiede costanza più che novità. Scegli il progetto principale dei sette giorni e dedicagli adesso la prima ora, senza aprire altri fronti. Ripeti quell'ora ogni mattina fino al settimo giorno.

### Zhi, Carriera, mese
- Rito: Trenta giorni di cura cominciano oggi con Zhi, che non disperde il lavoro fatto. Nel lavoro e nello studio scrivi una guida di come svolgi il compito più importante, una pagina alla settimana. Comincia adesso dalla prima, con parole semplici che altri possano seguire.

### Zhi, Carriera, anno
- Rito: L'anno cinese, che Zhi ha accolto a Capodanno, chiede al lavoro di non lasciar sfumare ciò che hai costruito. Scegli adesso un risultato ottenuto e insegnalo a chi lavora con te: mostra il percorso che lo ha reso possibile. Ciò che si trasmette non va perduto.

### Zhi, Fortuna, giorno
- Rito: Oggi è Zhi, il giorno della presa salda. Per le occasioni non lasciar cadere un contatto prezioso: rispondi adesso a un messaggio rimasto aperto oppure ringrazia chi ti ha dato una mano. Le occasioni restano volentieri vicine a chi sa tenerle.

### Zhi, Fortuna, settimana
- Rito: Zhi, l'ufficiale che tiene vicino ciò che vale, segna oggi una settimana in cui le occasioni vengono da ciò che hai già. Scorri la rubrica e scegli tre persone con cui riallacciare un filo nei sette giorni. Comincia adesso con la prima: un saluto semplice, senza richieste.

### Zhi, Fortuna, mese
- Rito: Per le occasioni, il mese che si apre oggi sotto Zhi, che serba ciò che è buono, chiede di ricambiare. Ogni settimana dei trenta giorni ricambia un favore ricevuto: un aiuto, un'indicazione, un passaggio. Fallo adesso per la prima volta, scegliendo il favore più vecchio.

### Zhi, Fortuna, anno
- Rito: Le buone occasioni dell'anno cinese, nato sotto Zhi a Capodanno, si fermano dove trovano cura. Proponi adesso di rivedere di persona un contatto prezioso che rischi di perdere: fissa un caffè, una passeggiata, una visita. Mantenere i legami è il gesto di Zhi.

### Po, Generale, giorno
- Rito: Oggi è il giorno di Po, l'ufficiale che rompe: l'almanacco lo sconsiglia per quasi ogni impresa e lo lascia soltanto al demolire. Non cominciare nulla di importante. Butta via invece un oggetto rotto che conservi senza motivo e lascia quel vuoto com'è.

### Po, Generale, settimana
- Rito: Po, il giorno della rottura, regge oggi l'avvio della tua settimana: la tradizione lo trova adatto solo a smontare. Non avviare nulla oggi: individua una cattiva abitudine e spezzala con un gesto preciso, come togliere il telefono dal comodino la sera. Rimanda le partenze ai giorni seguenti.

### Po, Generale, mese
- Rito: Il primo dei trenta giorni appartiene a Po, che sta all'opposto di Jian e rompe. Usa il mese per smontare: scegli un mobile o un oggetto ingombrante che non usi più e smontalo pezzo per pezzo nelle settimane, portando via le parti. Comincia oggi dalla prima vite.

### Po, Generale, anno
- Rito: L'anno cinese ha ricevuto a Capodanno il segno di Po, l'ufficiale che spezza. Il suo gesto è rompere la consuetudine: cambia adesso un gesto quotidiano, la strada abituale, il posto a tavola, la tazza del mattino. Ciò che si rompe con leggerezza lascia passare aria nuova.

### Po, Amore, giorno
- Rito: Oggi governa Po, il giorno della frattura, poco adatto agli affetti nuovi secondo l'almanacco. Non forzare dichiarazioni né decisioni importanti. Rompi piuttosto un'abitudine che riapre ferite: archivia la conversazione che continui a rileggere e non tornarci per tutta la giornata.

### Po, Amore, settimana
- Rito: Con Po, che infrange, comincia oggi una settimana degli affetti che non è fatta per le grandi svolte. Rompi invece un copione che si ripete, la stessa discussione con chi ami o la stessa scelta sbagliata se sei senza legame: cambia adesso la prima battuta.

### Po, Amore, mese
- Rito: Po, che manda in frantumi il vecchio, governa il giorno da cui partono trenta giorni di pulizia negli affetti. Non progettare dichiarazioni: prendi una lettera mai spedita, un biglietto di un amore finito o di una lite: strappalo a pezzi piccoli e gettalo. Ogni settimana lascia andare un peso così.

### Po, Amore, anno
- Rito: Sotto Po, nemico delle forme irrigidite, il tuo anno cinese è nato a Capodanno. Negli affetti scegli adesso una pretesa rigida, verso chi ami o verso chi cerchi: rompila con un gesto contrario, cedi il passo, cambia programma, lascia scegliere all'altra persona.

### Po, Carriera, giorno
- Rito: Oggi l'almanacco segna Po, il giorno della demolizione, sfavorevole agli inizi e alle intese. Al lavoro non lanciare progetti nuovi: apri piuttosto il cassetto delle bozze e getta le carte che non servono più, appunti superati, stampe doppie. Togliere il guasto è il compito di questo giorno.

### Po, Carriera, settimana
- Rito: Sotto Po, che abbatte, la settimana di lavoro comincia togliendo. Spezza le interruzioni: per sette giorni spegni le notifiche per un'ora ogni mattina e lavora a una cosa sola. Comincia adesso, con la prima ora. I progetti nuovi possono attendere i giorni seguenti.

### Po, Carriera, mese
- Rito: Nel lavoro e nello studio, il mese che oggi apre Po è adatto a smantellare, non a lanciare. Scegli una riunione che non decide nulla o un passaggio doppio: scrivi adesso a chi ne decide una proposta chiara per toglierlo di mezzo nei trenta giorni.

### Po, Carriera, anno
- Rito: Po, che fa crollare ciò che non regge, ha segnato a Capodanno la nascita del tuo anno cinese. Nel lavoro il suo gesto è lasciare un metodo che ti rallenta: abbandonalo adesso e scrivi con che cosa lo sostituisci. Un metodo caduto fa posto a uno migliore.

### Po, Fortuna, giorno
- Rito: Oggi è Po, il giorno che recide, in cui l'almanacco consiglia di non intraprendere nulla di propizio. Per le occasioni il gesto è tagliare un vincolo inutile: cancella un'iscrizione automatica che ti riempie la casella di posta o il telefono. Così la strada resta più libera.

### Po, Fortuna, settimana
- Rito: Po, l'ufficiale che separa, apre oggi una settimana in cui le occasioni non si inseguono: la tradizione lo lascia al disfare. Elimina adesso un impegno che ti pesa senza portarti nulla e rimanda ai giorni seguenti ogni passo nuovo. Prima si libera la strada.

### Po, Fortuna, mese
- Rito: Strada sgombra: è ciò che chiedono le occasioni dei trenta giorni che partono oggi con Po, che scioglie i nodi stretti. Individua l'abitudine che ti blocca più spesso, come dire di sì a tutto: spezzala adesso con un no gentile, poi ripeti quel no una volta a settimana.

### Po, Fortuna, anno
- Rito: Per le occasioni, l'anno cinese nato sotto Po a Capodanno chiede di demolire una scusa prima di cercare. Smetti adesso di ripetere la frase con cui rifiuti in partenza ciò che non conosci: ogni volta che ti sale alle labbra, sostituiscila con una domanda.

### Wei, Generale, giorno
- Rito: Oggi è il giorno di Wei, l'ufficiale del pericolo: l'almanacco lo consiglia per il raccoglimento e sconsiglia di salire in alto o di cambiare casa. Prenditi cinque minuti di silenzio in un luogo tranquillo e dedica un pensiero a chi vuoi proteggere.

### Wei, Generale, settimana
- Rito: Wei, il giorno della vigilanza, governa oggi la tua settimana: la tradizione lo affida ai voti, non agli spostamenti. Rileggi adesso con calma i piani dei sette giorni e accanto a ogni uscita segna un margine di tempo in più. Chi ha tempo non corre rischi.

### Wei, Generale, mese
- Rito: Trenta giorni sotto Wei, che chiede passi misurati, cominciano oggi. Ogni sera accendi una candela per qualche minuto e, guardando la fiamma, ripensa alla giornata: dove hai corso troppo, dove è servita attenzione. Comincia stasera. Rimanda i traslochi e le salite rischiose.

### Wei, Generale, anno
- Rito: Wei, l'ufficiale che veglia dopo la rottura, ha visto nascere a Capodanno il tuo anno cinese. Il suo gesto è la prudenza, buona in ogni giorno: fai adesso il giro della casa e controlla serrature, rubinetti, prese e fornelli. Ciò che è in ordine lascia riposare la mente.

### Wei, Amore, giorno
- Rito: Oggi governa Wei, il giorno che chiede attenzione. Negli affetti non affrontare di fretta le questioni delicate: se una parola difficile preme, rimandala a un momento calmo. Intanto ascolta, con chi ami o con chi stai conoscendo, più di quanto parli.

### Wei, Amore, settimana
- Rito: La prudenza di Wei accompagna la settimana degli affetti che comincia oggi: ciò che è fragile va protetto, non messo alla prova. Se hai un legame, prepara a chi ami qualcosa di caldo dopo una giornata pesante; se sei senza legame, fai lo stesso per un'amicizia.

### Wei, Amore, mese
- Rito: Il mese degli affetti che nasce oggi sotto Wei, che vuole cautela e voti sinceri, chiede delicatezza più che slancio. Ogni settimana scrivi a mano un augurio breve, per chi ami o per chi speri di incontrare: raccoglilo in un quaderno dedicato. Scrivi il primo adesso.

### Wei, Amore, anno
- Rito: Nella vita sentimentale, l'anno cinese nato a Capodanno sotto Wei chiede di procedere con tatto. Prima di ogni parola difficile, con chi ami, in famiglia o con chi frequenti, fai adesso tre respiri lenti: lascia che la fretta passi prima di parlare.

### Wei, Carriera, giorno
- Rito: Oggi l'almanacco indica Wei, il giorno del rischio, poco adatto ai salti nel vuoto. Al lavoro controlla due volte prima di inviare: rileggi una comunicazione importante, verifica i dati, i nomi e gli allegati. La cautela di oggi risparmia correzioni in seguito.

### Wei, Carriera, settimana
- Rito: Sotto Wei, che invita a guardarsi intorno, la settimana di lavoro comincia senza cambi bruschi. Annota i punti deboli dei progetti in corso e scegli quale mettere in sicurezza per primo: fallo adesso, con calma, prima di aggiungere altro nei sette giorni.

### Wei, Carriera, mese
- Rito: Wei, che chiede occhi aperti, governa il primo dei tuoi trenta giorni di lavoro e di studio. Prima di ogni decisione importante del mese chiedi il parere di una persona esperta e ascoltalo fino in fondo. Scegli adesso a chi rivolgerti e fissa il primo colloquio.

### Wei, Carriera, anno
- Rito: Il tuo anno cinese porta da Capodanno il segno di Wei e chiede al lavoro passi controllati. Metti adesso al sicuro i dati del progetto più fragile: una copia su un secondo supporto, una password cambiata, una scadenza resa più realistica. Prevedere il guasto è il gesto dell'ufficiale della cautela.

### Wei, Fortuna, giorno
- Rito: Oggi è Wei, il giorno in cui la tradizione sconsiglia viaggi rischiosi e salite in alto. Per le occasioni resta con i piedi per terra: davanti a una proposta appena arrivata, chiedi tempo prima di rispondere e valutala con lucidità. Una pausa ponderata è un gesto saggio.

### Wei, Fortuna, settimana
- Rito: Wei, l'ufficiale del discernimento, segna oggi una settimana in cui le occasioni vanno pesate. Scrivi adesso, accanto a ogni possibilità che vedi, un rischio e una precauzione. Dedica poi qualche minuto di raccoglimento a ciò che speri nei sette giorni.

### Wei, Fortuna, mese
- Rito: Per trenta giorni, a partire da oggi, Wei invita le occasioni alla prudenza. Metti in tasca un piccolo sasso liscio e tienilo con te per tutto il mese: prima di ogni sì importante, stringilo e conta fino a dieci. Comincia adesso a portarlo.

### Wei, Fortuna, anno
- Rito: Wei ha dato a Capodanno il suo segno all'anno cinese che stai vivendo, ufficiale vigile che diffida delle partenze. Per le occasioni rinuncia adesso a uno spostamento che non serve, un viaggio fatto per abitudine, una salita rischiosa: le buone occasioni si trovano anche vicino.

### Cheng, Generale, giorno
- Rito: Oggi è il giorno di Cheng, l'ufficiale del compimento: l'almanacco lo considera fra i più propizi. Prendi il libro lasciato a metà e leggilo fino all'ultima pagina, oppure fino al capitolo che chiude una parte. Rimetterlo sullo scaffale, finito, è il gesto di questo giorno.

### Cheng, Generale, settimana
- Rito: Cheng, che fa giungere al termine, regge oggi il primo dei sette giorni. Scegli un lavoro manuale da finire entro il settimo giorno: uno rimasto a metà, se ne hai, oppure uno nuovo e piccolo, un disegno, una cornice, un vaso da dipingere. Comincia adesso con il primo tratto.

### Cheng, Generale, mese
- Rito: Sotto Cheng, che conclude, si apre oggi il tuo mese. Ogni settimana dei trenta giorni chiudi una piccola pratica di casa rimasta in sospeso: un documento da rinnovare, una lampadina da cambiare, un orlo da cucire. Comincia adesso dalla più semplice, prima di sera.

### Cheng, Generale, anno
- Rito: Cheng, l'ufficiale che porta a compimento, ha dato a Capodanno il suo segno al tuo anno cinese. Il gesto vale in qualunque punto dell'anno: scrivi adesso una lettera a mano a una persona cara, oppure finisci quella rimasta a metà se ne hai una, poi firmala e spediscila.

### Cheng, Amore, giorno
- Rito: Oggi governa Cheng, il giorno del traguardo, che la tradizione lega anche alle unioni. Negli affetti realizza adesso la sorpresa progettata e mai fatta, piccola o grande, per chi ami o per chi desideri avvicinare. Non aspettare un'occasione speciale: l'occasione è oggi.

### Cheng, Amore, settimana
- Rito: Cheng, che chiude il cerchio, segna oggi la settimana degli affetti. Se vivi una relazione, realizzate nei sette giorni un progetto di cui parlate da tempo, anche minimo: una gita, una cena in un posto nuovo; se sei senza legame, porta a termine un passo che rimandi.

### Cheng, Amore, mese
- Rito: Gli affetti dei trenta giorni che cominciano oggi seguono Cheng, che porta a frutto ed è propizio alle unioni. Scegli un chiarimento rimasto a metà con chi ami o, se sei senza legame, un incontro che rimandi da tempo: fissane adesso la data e preparane le prime parole.

### Cheng, Amore, anno
- Rito: Cheng, l'ufficiale che corona le cose ed è amico delle unioni, ha segnato a Capodanno il tuo anno cinese. Celebra adesso un legame che dura: una ricorrenza lasciata passare con chi ami o, se sei senza legame, un'amicizia di lunga data, con un brindisi o un biglietto.

### Cheng, Carriera, giorno
- Rito: Oggi l'almanacco segna Cheng, il giorno buono per le consegne. Al lavoro porta a termine il compito più vicino alla fine e consegnalo prima di sera, anche se non è perfetto. Vedere una cosa completata dà slancio a quelle che seguono.

### Cheng, Carriera, settimana
- Rito: Sotto Cheng, che perfeziona, la settimana di lavoro e di studio chiede arrivi più che partenze. Scegli la cosa più vicina alla fine, che sia un compito, una pratica o un capitolo: fissa adesso il passo che la chiude entro i sette giorni. Se serve un sì, chiedilo subito.

### Cheng, Carriera, mese
- Rito: Cheng, che dopo la vigilanza porta a compimento, governa il primo dei tuoi trenta giorni di lavoro. Fai l'elenco dei compiti vicini alla fine e assegna a ciascuno una data di consegna dentro il mese. Chiudi adesso il primo e cancellalo con un tratto.

### Cheng, Carriera, anno
- Rito: Nel lavoro e nello studio conta il segno di Cheng, l'ufficiale delle opere finite: sotto di lui, a Capodanno, ha preso vita il tuo anno cinese. Scegli adesso un impegno di lavoro, di studio o personale che puoi chiudere in pochi giorni e portalo fino in fondo.

### Cheng, Fortuna, giorno
- Rito: Oggi è Cheng, il giorno che compie e che l'almanacco dà buono anche per mettersi in viaggio. Per le occasioni muoviti: vai di persona dove finora hai solo scritto, a un incontro, da qualcuno che stimi. Le cose si compiono spesso quando ci si mette in strada.

### Cheng, Fortuna, settimana
- Rito: Cheng, che fa arrivare in fondo, regge oggi una settimana in cui le occasioni chiedono di essere completate. Riprendi una possibilità lasciata cadere a metà strada e fai adesso il passaggio che mancava: una risposta, una richiesta, un documento allegato. Ciò che manca è spesso poco.

### Cheng, Fortuna, mese
- Rito: Il mese che parte oggi segue Cheng, che dà compimento e accompagna, secondo la tradizione, anche chi parte. Per le occasioni organizza nei trenta giorni una gita di un giorno verso un luogo che ti chiama da tempo: scegli adesso la meta e il mezzo.

### Cheng, Fortuna, anno
- Rito: Nato a Capodanno sotto Cheng, che non lascia le cose a metà, il tuo anno cinese chiede di portare fino in fondo le occasioni: la candidatura rimasta in bozza, la domanda mai inviata, la richiesta tenuta nel cassetto. Inviala adesso, così com'è.

### Shou, Generale, giorno
- Rito: Oggi è il giorno di Shou, l'ufficiale che raccoglie: l'almanacco antico dice che dopo il compimento viene il raccolto. Fermati a mettere in fila ciò che hai ottenuto in questo tempo e scrivilo in un elenco. Leggilo con calma e riconosci il cammino fatto.

### Shou, Generale, settimana
- Rito: Shou, che riunisce i frutti, governa oggi la settimana che hai davanti. Raduna ciò che è sparso, foto, appunti, idee annotate in tanti posti diversi, in un unico luogo. Fallo adesso e scegli quale idea coltivare nei sette giorni: il raccolto precede ogni semina.

### Shou, Generale, mese
- Rito: Il mese che comincia oggi prende il segno da Shou, l'ufficiale che mette al riparo. Prepara nei trenta giorni una piccola conserva fatta in casa: una marmellata, un barattolo di erbe essiccate, un vasetto di frutta sciroppata. Comincia adesso scegliendo che cosa mettere da parte.

### Shou, Generale, anno
- Rito: L'anno cinese che stai vivendo è nato a Capodanno sotto Shou, che ritira ciò che è maturo. Il gesto vale in ogni momento dell'anno: fai adesso il giro della casa con un cesto e raccogli ciò che è fuori posto, poi rimetti ogni cosa dove deve stare.

### Shou, Amore, giorno
- Rito: Oggi governa Shou, il giorno della mietitura. Negli affetti raccogli i momenti belli: racconta a voce a chi ami, o a chi ti vuole bene se sei senza legame, un ricordo felice vissuto insieme, con tutti i dettagli che ricordi.

### Shou, Amore, settimana
- Rito: Shou, l'ufficiale che fa il bilancio dei frutti, invita oggi gli affetti a riconoscere ciò che hanno già dato. Ogni sera dei sette giorni, prima di dormire, richiama alla mente una cosa bella ricevuta da chi ami o, se sei senza legame, da un'amicizia cara. Comincia stasera, senza fretta.

### Shou, Amore, mese
- Rito: Trenta giorni per gli affetti partono oggi con Shou, che accoglie il frutto maturo. Ogni settimana scegli una foto di un momento bello, con chi ami o con chi ti è caro: stampala e mettila in un album dedicato. Comincia adesso dalla più recente.

### Shou, Amore, anno
- Rito: Dal Capodanno lunare il tuo anno cinese porta il segno di Shou, che serba i frutti. Negli affetti raccogli ciò che c'è già: prepara adesso una cena con quello che hai in casa, senza comprare nulla, per chi ami o, se sei senza legame, per un'amicizia cara.

### Shou, Carriera, giorno
- Rito: Oggi l'almanacco indica Shou, il giorno che tira le somme, propizio anche a chi studia. Al lavoro annota in una pagina le lezioni dell'ultimo progetto: che cosa ha funzionato, gli errori, le soluzioni trovate. Tienila a portata di mano per il prossimo lavoro.

### Shou, Carriera, settimana
- Rito: Shou, che la tradizione lega anche allo studio oltre che al raccolto, segna oggi la tua settimana di lavoro e di studio. Scegli una competenza da coltivare nei sette giorni e dedica adesso mezz'ora alla prima lezione. Studiare è raccogliere per il tempo che viene.

### Shou, Carriera, mese
- Rito: Lo studio e il lavoro dei trenta giorni che cominciano oggi seguono Shou, l'ufficiale delle messi. Raccogli i riscontri: chiedi a due persone con cui lavori che cosa funziona nel tuo modo di fare e che cosa cambierebbero. Fai adesso la prima domanda e ascolta senza difenderti.

### Shou, Carriera, anno
- Rito: Il tuo anno cinese, venuto al mondo a Capodanno sotto Shou, lega il lavoro ai frutti raccolti. Metti adesso in ordine i lavori riusciti in una raccolta da mostrare: progetti, testi, immagini, risultati, ciascuno con una riga di spiegazione. Ciò che hai raccolto parla per te.

### Shou, Fortuna, giorno
- Rito: Oggi è Shou, il giorno che porta dentro il raccolto, sconsigliato dall'almanacco per i viaggi lunghi. Per le occasioni resta nei paraggi: rispondi adesso alle proposte arrivate, rileggi gli inviti ricevuti, segna quali meritano un sì. Spesso l'occasione è già sulla soglia.

### Shou, Fortuna, settimana
- Rito: In questa settimana aperta oggi da Shou, che vede maturare il seminato, le occasioni nascono dagli incontri recenti. Ripercorri le persone conosciute di recente e scegli l'incontro da far crescere: riprendilo adesso con un invito vicino a casa, perché la tradizione sconsiglia i viaggi lunghi.

### Shou, Fortuna, mese
- Rito: Il mese che oggi apre Shou, l'ufficiale che riempie il granaio, invita a cercare le occasioni vicine, senza lunghi viaggi. Ogni settimana esplora a piedi una via vicina a casa che non conosci, entra in una bottega, saluta chi incontri. Comincia adesso con la prima.

### Shou, Fortuna, anno
- Rito: Nel tuo anno cinese, nato sotto Shou a Capodanno, le occasioni passano spesso per mani già vicine. Accetta adesso un'offerta di aiuto che di solito rifiuti: un passaggio, un consiglio, una mano in un lavoro. Ricevere con un sì pieno è il gesto di Shou.

### Kai, Generale, giorno
- Rito: Oggi è il giorno di Kai, l'ufficiale che apre: l'almanacco antico lo chiama il soffio vitale che comincia. Spalanca porte e finestre per qualche minuto e lascia entrare luce e aria in ogni stanza. Respira a fondo davanti alla finestra più ampia.

### Kai, Generale, settimana
- Rito: Kai, l'ufficiale delle porte aperte, buono anche per i conviti secondo la tradizione, regge oggi la tua settimana. Invita a pranzo i vicini o gli amici nei sette giorni, con un piatto semplice. Scegli adesso la data e bussa alla prima porta.

### Kai, Generale, mese
- Rito: Kai, che mette in moto, segna il mese che parte oggi. Nei trenta giorni prova ogni settimana una cosa mai fatta: un piatto nuovo, un genere di musica sconosciuto, uno sport, un museo. Scegli adesso la prima e falla oggi stesso, anche se è piccola.

### Kai, Generale, anno
- Rito: Kai, l'ufficiale dell'apertura, ha visto nascere a Capodanno il tuo anno cinese. Il gesto vale oggi come in ogni altro giorno: riprendi adesso un'amicizia interrotta senza motivo, con una telefonata o una visita. Ciò che era chiuso torna a respirare.

### Kai, Amore, giorno
- Rito: Oggi governa Kai, il giorno che schiude, buono anche per le unioni secondo l'almanacco antico. Negli affetti pronuncia una frase sincera che di solito tieni per te: dilla a chi ami o a chi desideri conoscere, guardando la persona negli occhi.

### Kai, Amore, settimana
- Rito: Allargare il cerchio degli affetti è il gesto della settimana che Kai governa da oggi. Se hai un legame, proponi a chi ami un'attività nuova da provare insieme nei sette giorni, un ballo, un laboratorio; se sei senza legame, iscriviti a un'attività di gruppo dove conoscere persone.

### Kai, Amore, mese
- Rito: Sotto Kai, l'ufficiale dei varchi, cominciano oggi trenta giorni aperti agli incontri del cuore. Ogni settimana rivolgi una domanda nuova a chi ami oppure, se sei senza legame, a chi frequenti: un sogno, un ricordo, una paura. Ascolta la risposta. Ponila adesso per la prima volta.

### Kai, Amore, anno
- Rito: Sotto Kai, che accoglie e festeggia, il tuo anno cinese è venuto al mondo a Capodanno. Organizza adesso un piccolo brindisi per chi ami o, se sei senza legame, per gli amici più cari: invita anche una persona nuova al tavolo. Una tavola allargata scalda gli affetti.

### Kai, Carriera, giorno
- Rito: Oggi l'almanacco segna Kai, il giorno propizio ad aprire un'attività. Al lavoro apri un canale nuovo: scrivi a una persona che stimi e che non conosci ancora, con due righe sincere su ciò che apprezzi del suo lavoro. Un'apertura piccola basta.

### Kai, Carriera, settimana
- Rito: Sotto Kai, che inaugura, la settimana di lavoro e di studio comincia con una presentazione. Racconta a chi lavora con te il progetto che vuoi far nascere e chiedi chi vuole partecipare nei sette giorni. Fallo adesso, finché lo slancio è fresco.

### Kai, Carriera, mese
- Rito: Kai, che spalanca le porte alle attività nuove, segna l'avvio del tuo mese di lavoro e di studio. Ogni settimana partecipa a un incontro del tuo settore, una conferenza, un gruppo di studio, una serata aperta: presentati ad almeno una persona. Scegli adesso il primo appuntamento.

### Kai, Carriera, anno
- Rito: Nel lavoro conta il soffio di Kai, l'ufficiale che dischiude: il tuo anno cinese è nato sotto di lui a Capodanno. Proponi adesso in riunione, o per iscritto a chi decide, l'idea che tieni nel cassetto da troppo tempo. Un'idea detta circola.

### Kai, Fortuna, giorno
- Rito: Oggi è Kai, fra i giorni più graditi alla tradizione, quello che apre. Per le occasioni saluta per primo qualcuno che vedi spesso senza mai salutarlo: il vicino, il negoziante, chi fa la tua stessa strada. Un saluto può aprire una porta.

### Kai, Fortuna, settimana
- Rito: Kai, che fa circolare l'aria nuova, segna oggi una settimana in cui le occasioni passano dagli incontri. Scegli un gruppo, un coro o un'associazione da frequentare nei sette giorni e fai adesso la prima telefonata per entrarci. Entrare in un cerchio nuovo è il gesto.

### Kai, Fortuna, mese
- Rito: Esci e incontra persone: il mese che comincia oggi è di Kai, che l'almanacco conta fra i più fausti. Per le occasioni accetta ogni settimana almeno un invito che di solito declini. Comincia adesso rispondendo sì al primo che hai davanti.

### Kai, Fortuna, anno
- Rito: Kai, sotto cui l'anno cinese è nato a Capodanno, porta il segno dell'uscio spalancato. Per le occasioni il gesto è uscire incontro agli altri: entra adesso in un luogo del quartiere dove non hai mai messo piede, una bottega, una sala, un cortile: presentati a chi trovi.

### Bi, Generale, giorno
- Rito: Oggi è il giorno di Bi, l'ufficiale che chiude: l'almanacco lo sconsiglia per aprire o partire e lo lascia al sigillare. Chiudi bene ciò che è rimasto aperto in casa, barattoli, cassetti, ante, la finestra che sbatte. Poi riponi ogni oggetto che hai usato.

### Bi, Generale, settimana
- Rito: Bi, che racchiude, regge oggi la tua settimana: la tradizione dice che solo chi sa chiudere torna a stabilire. Fai la lista delle questioni aperte e chiudine una adesso, con un gesto definitivo. Le altre trovano posto nei sette giorni, una alla volta.

### Bi, Generale, mese
- Rito: Bi, che conclude la serie dei dodici ed è buono per tappare le falle, governa il mese che parte oggi. Ogni settimana ripara una piccola perdita di casa: il rubinetto che gocciola, lo spiffero sotto la porta, la guarnizione consumata. Comincia adesso da quella che senti di più.

### Bi, Generale, anno
- Rito: Sotto Bi, che serra, il tuo anno cinese ha preso vita a Capodanno. Il suo gesto è chiudere bene: manda adesso il messaggio che conclude una faccenda trascinata da tempo, con parole chiare e senza rancore. Ciò che è chiuso con garbo smette di chiedere attenzione.

### Bi, Amore, giorno
- Rito: Oggi governa Bi, il giorno raccolto, poco adatto alle promesse nuove secondo l'almanacco. In amore proteggi invece di cercare: se hai un legame, passa la sera con chi ami, telefoni spenti e porta chiusa; se sei senza legame, concediti una sera quieta, senza rincorrere nessuno.

### Bi, Amore, settimana
- Rito: Bi, che chiude con dolcezza, dà oggi agli affetti sette giorni per sanare una questione in sospeso. Una scusa mai detta, un chiarimento promesso, con chi ami, in famiglia o con chi frequenti: dillo adesso a voce, con calma, così la settimana riparte leggera.

### Bi, Amore, mese
- Rito: Con Bi, che pone confini, partono oggi trenta giorni per difendere la quiete degli affetti. Fissa un confine: dopo una certa ora non rispondi ai messaggi che ti agitano. Rispettalo ogni sera e dedica quel tempo a chi ami o, se sei senza legame, a te.

### Bi, Amore, anno
- Rito: Chiudere con cura è il gesto che Bi, sotto cui è nato a Capodanno il tuo anno cinese, chiede agli affetti. Raccogli adesso in una busta le lettere e i biglietti di un legame finito, chiudila bene e riponila in alto, lontano dagli occhi. Il cuore ritrova spazio.

### Bi, Carriera, giorno
- Rito: Oggi l'almanacco indica Bi, il giorno della chiusura, sfavorevole all'avvio di attività. Al lavoro completa invece di aprire: chiudi le pratiche finite, archivia le cartelle, lascia la scrivania sgombra prima di andare via. Ciò che è riposto bene prepara il prossimo lavoro.

### Bi, Carriera, settimana
- Rito: Bi, che tiene chiuso e che la tradizione lega anche agli argini, segna oggi la tua settimana di lavoro. Individua l'ora del giorno in cui si disperde più tempo e mettici un argine: spegni la posta per due ore ogni mattina dei sette giorni. Comincia adesso.

### Bi, Carriera, mese
- Rito: Il lavoro e lo studio dei trenta giorni che cominciano oggi seguono Bi, che chiude i varchi. Metti in sicurezza ciò che hai: ogni settimana cambia una password debole, chiudi un accesso che non usi, fai una copia protetta dei file importanti. Comincia adesso dalla password più vecchia.

### Bi, Carriera, anno
- Rito: Sotto Bi, che raccoglie le forze dentro un recinto, il tuo anno cinese è nato a Capodanno. Nel lavoro chiudi adesso un fronte secondario che disperde le energie: comunica con chiarezza che lo lasci e a chi passa ciò che resta. Le forze tornano così al compito principale.

### Bi, Fortuna, giorno
- Rito: Oggi è Bi, il giorno che mette il suggello, in cui l'almanacco sconsiglia di inseguire novità. Per le occasioni conserva ciò che hai: rileggi una proposta già accettata e porta a termine l'ultimo passaggio che manca. Un affare concluso lascia libere le mani.

### Bi, Fortuna, settimana
- Rito: Bi, che mette il punto finale, regge oggi una settimana per chiudere un capitolo. Per le occasioni saluta un progetto finito e ringrazia, di persona o per iscritto, chi ha fatto la strada con te. Così prepari spazio a ciò che viene dopo.

### Bi, Fortuna, mese
- Rito: Le occasioni del mese che si apre oggi con Bi, che chiude a chiave, chiedono di tenere stretto ciò che hai. Ogni sera dei trenta giorni chiudi con calma la porta di casa e, girando la chiave, pensa a una cosa buona da conservare. Comincia stasera.

### Bi, Fortuna, anno
- Rito: Il segno di Bi, sotto cui l'anno cinese è nato a Capodanno, è quello delle cose messe al riparo. Per le occasioni sigilla adesso ciò che hai ottenuto: metti al sicuro un documento importante, conferma per iscritto un impegno preso, salva il recapito di una persona preziosa.
