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
- Rito: Oggi è il giorno di Jian, l'ufficiale che stabilisce: l'almanacco lo lega agli inizi. Scegli una cosa che rimandi da tempo e dalle adesso il primo passo concreto. Scrivi la prima riga, apri il primo quaderno, segna la data in cima alla pagina. Il resto può aspettare.

### Jian, Generale, settimana
- Rito: La settimana nasce oggi sotto Jian, l'ufficiale che stabilisce le fondamenta. Il suo gesto vale per i sette giorni: decidi adesso che cosa vuoi avviare e mettilo per iscritto in una frase sola. Poi compi il primo passo, anche piccolo, perché l'almanacco affida a Jian gli inizi.

### Jian, Generale, mese
- Rito: Jian, l'ufficiale che stabilisce, governa il giorno da cui partono questi trenta giorni. Scegli un progetto che vuoi vedere in piedi entro il mese e scrivi su un foglio i passi che servono. Compi adesso il primo, anche minimo: poi tieni il foglio in vista ogni mattina.

### Jian, Generale, anno
- Rito: Il tuo anno cinese è nato a Capodanno sotto Jian, l'ufficiale che stabilisce le fondamenta. Il suo gesto vale adesso come allora: scegli una cosa ferma da troppo tempo e mettila in cammino con un atto concreto. Scrivi una riga, fai una telefonata, sposta la prima pietra.

### Jian, Amore, giorno
- Rito: Oggi l'almanacco segna Jian, il giorno che stabilisce e dà inizio. Negli affetti vuol dire fare il primo passo: manda tu il messaggio che aspetti di ricevere, a chi ami o a chi desideri conoscere meglio. Proponi una cosa nuova da fare insieme e comincia con poche parole semplici.

### Jian, Amore, settimana
- Rito: Con Jian, che stabilisce, si apre oggi una settimana adatta a fondare un'abitudine degli affetti. Se hai un legame, scegli con chi ami un piccolo rito comune, una passeggiata o una cena senza telefoni; se sei senza legame, scegline uno per incontrare persone nuove. Fissalo adesso.

### Jian, Amore, mese
- Rito: Jian apre la serie degli ufficiali e governa il primo dei trenta giorni che hai davanti. Negli affetti è il tempo di fondare: scegli un gesto da ripetere ogni settimana: un tempo dedicato a chi ami oppure, se sei senza legame, un luogo dove incontrare persone nuove. Scrivilo subito nell'agenda.

### Jian, Amore, anno
- Rito: Negli affetti il tuo anno cinese porta il segno di Jian, l'ufficiale che stabilisce, sotto cui è nato a Capodanno. Fonda adesso qualcosa che duri: un'abitudine condivisa con chi ami o, se sei senza legame, un luogo da frequentare con costanza dove conoscere persone. Scegli oggi quale.

### Jian, Carriera, giorno
- Rito: Oggi governa Jian, l'ufficiale che stabilisce: la tradizione gli affida chi assume un incarico o comincia uno studio. Al lavoro apri adesso il compito che continui a spostare e completa soltanto il primo passaggio. Annota dove ti fermi così sai da dove riprendere.

### Jian, Carriera, settimana
- Rito: Sotto Jian, il giorno degli inizi, comincia oggi la tua settimana di lavoro e di studio. Scrivi su un foglio il progetto che vuoi avviare, dividilo in tre passi e compi adesso il primo. Tieni il foglio dove lo vedi ogni mattina di questi sette giorni.

### Jian, Carriera, mese
- Rito: Al lavoro e nello studio questi trenta giorni partono da Jian, che l'almanacco affida a chi assume un incarico o entra in una scuola. Iscriviti adesso al corso che rimandi, oppure prendi in carico un compito nuovo e fissa nell'agenda la prima ora da dedicargli.

### Jian, Carriera, anno
- Rito: Il lavoro di quest'anno cinese, nato a Capodanno sotto Jian, porta il segno dell'ufficiale che assegna gli incarichi. Prendi adesso in mano un compito che nessuno ha ancora avviato, o una materia che vuoi studiare: scrivi il primo passo e fallo oggi stesso.

### Jian, Fortuna, giorno
- Rito: Oggi è Jian, il giorno che stabilisce: l'almanacco lo consiglia a chi si mette in cammino o entra in una scuola. Per le occasioni cerca un inizio: iscriviti a un corso, prendi una strada mai fatta, chiedi a qualcuno di insegnarti una cosa che non sai.

### Jian, Fortuna, settimana
- Rito: Questa settimana di Jian, l'ufficiale che apre la serie dei dodici, offre alle occasioni un punto di partenza. Scegli un luogo nuovo da frequentare nei sette giorni o una competenza da imparare. Fai adesso la prima mossa concreta per avvicinarti: una telefonata, un'iscrizione, una strada diversa.

### Jian, Fortuna, mese
- Rito: Per le occasioni dei trenta giorni che cominciano oggi con Jian, mettiti in cammino. Scegli una meta raggiungibile che non hai mai visitato (un quartiere, un museo, un sentiero) e segna nell'agenda il giorno in cui andarci. La tradizione affida a Jian chi parte.

### Jian, Fortuna, anno
- Rito: Le occasioni del tuo anno cinese seguono Jian, sotto cui l'anno è nato a Capodanno: l'almanacco lo dà a chi si mette in cammino o entra in una scuola. Adesso scegli una cosa da imparare che ti avvicini a ciò che speri e cerca chi può insegnartela.

### Chu, Generale, giorno
- Rito: Oggi è il giorno di Chu, l'ufficiale che toglie: l'almanacco antico lo spiega come il giorno che leva il vecchio per far posto al nuovo. Scegli un cassetto, una mensola o il piano della scrivania e sgombralo adesso. Tieni solo ciò che usi davvero.

### Chu, Generale, settimana
- Rito: Oggi Chu, che toglie il vecchio e prepara il nuovo, apre una settimana di sgombero. Fai una lista di tre cose che occupano spazio senza servire più e liberatene una oggi stesso. Le altre due possono aspettare con calma i sette giorni che seguono.

### Chu, Generale, mese
- Rito: Chu, l'ufficiale che leva il vecchio per far posto al nuovo, segna il giorno da cui parte il tuo mese. Scegli una stanza della casa e dedica i trenta giorni a sgombrarla un poco alla volta. Comincia adesso da un solo ripiano e porta via ciò che non serve.

### Chu, Generale, anno
- Rito: Quest'anno cinese ha visto la luce a Capodanno sotto Chu, che toglie il vecchio e dispone il nuovo. Il suo gesto vale in ogni momento: scegli adesso un oggetto, un impegno o un'abitudine che tieni per inerzia e lascialo andare con un atto preciso, senza rimpianti.

### Chu, Amore, giorno
- Rito: Oggi l'almanacco indica Chu, il giorno che toglie. Negli affetti lascia andare un piccolo rancore che porti da tempo verso chi ami o chi hai amato, oppure verso un familiare. Diglielo con parole semplici oppure scrivilo su un foglio e poi strappalo. Fai spazio a ciò che conta.

### Chu, Amore, settimana
- Rito: La settimana che parte oggi con Chu, l'ufficiale che toglie, chiede di sgombrare negli affetti le abitudini che allontanano. Se vivi una relazione, scegli con l'altra persona una cosa sola da lasciare indietro; se sei senza legame, lascia andare un'attesa che ti blocca. Comincia adesso.

### Chu, Amore, mese
- Rito: Con Chu, che leva il vecchio, cominciano oggi trenta giorni per fare pulizia nel cuore. Rileggi i messaggi che ancora ti pesano, di un amore finito o di una lite recente: cancella quelli che non vuoi più portare con te. Tieni soltanto le parole che fanno bene.

### Chu, Amore, anno
- Rito: Il cuore, in quest'anno cinese nato sotto Chu a Capodanno, chiede spazio libero più che cose nuove. Togli adesso un peso dagli affetti: un oggetto legato a un amore finito, una gelosia, una pretesa verso chi ami o chi cerchi. Lascia andare quel peso con un gesto.

### Chu, Carriera, giorno
- Rito: Oggi è Chu, il giorno che leva il vecchio. Al lavoro libera la scrivania e la casella di posta: archivia ciò che è chiuso, cancella i promemoria superati, butta le carte inutili. Uno spazio sgombro aiuta a vedere quale compito viene davvero prima degli altri.

### Chu, Carriera, settimana
- Rito: Con Chu, l'ufficiale che toglie, la settimana di lavoro comincia togliendo invece di aggiungere. Rileggi gli impegni presi e scegli quello che non ha più senso portare avanti. Chiudilo adesso con garbo così i sette giorni che seguono trovano spazio per ciò che conta.

### Chu, Carriera, mese
- Rito: Il mese di lavoro e di studio che si apre oggi porta il segno di Chu, che toglie il vecchio. Dedica i trenta giorni a sfoltire: cartelle doppie, procedure superate, abbonamenti a notiziari mai letti. Adesso comincia dalla casella di posta e svuota una sola cartella.

### Chu, Carriera, anno
- Rito: Sotto Chu è nato a Capodanno il tuo anno cinese: nel lavoro e nello studio chiede di levare ciò che ingombra. Scegli adesso un compito che porti avanti per abitudine, senza frutto: restituiscilo o chiudilo con una comunicazione chiara a chi di dovere.

### Chu, Fortuna, giorno
- Rito: Oggi governa Chu, il giorno che toglie per fare posto. Le occasioni arrivano dove c'è spazio: riordina l'ingresso di casa, apri le finestre, porta via una cosa che non usi più da mesi. Lascia libero un angolo della stanza per ciò che deve ancora venire.

### Chu, Fortuna, settimana
- Rito: In questa settimana segnata da Chu, che leva il vecchio, le occasioni chiedono tempo libero prima ancora delle cose nuove. Togli dall'agenda dei sette giorni un impegno che non ti somiglia più. In quello spazio vuoto lascia entrare una possibilità diversa, anche solo una passeggiata senza meta.

### Chu, Fortuna, mese
- Rito: Trenta giorni sotto il segno di Chu partono oggi: per le occasioni, fai posto. Ogni sera di questo mese porta via di casa un oggetto che non usi, da regalare o da riciclare. Comincia adesso con il primo e lascia libero l'angolo dove stava.

### Chu, Fortuna, anno
- Rito: A Capodanno l'anno cinese è nato sotto Chu, l'ufficiale che fa posto al nuovo togliendo il vecchio. Per le occasioni il gesto vale in qualunque giorno: libera adesso un angolo della casa da ciò che non usi e lascialo vuoto, pronto ad accogliere.

### Man, Generale, giorno
- Rito: Oggi è il giorno di Man, l'ufficiale del pieno: l'almanacco lo dedica alle offerte e ai desideri espressi. Accendi una candela oppure metti un fiore sul tavolo e pronuncia a voce bassa un desiderio per chi ami. Poi ringrazia per una cosa che oggi c'è già.

### Man, Generale, settimana
- Rito: Man, l'ufficiale del pieno che la tradizione lega ai voti e ai ringraziamenti, governa oggi il primo dei sette giorni. Scrivi su un foglio tre cose di cui senti gratitudine e un desiderio solo. Conserva il foglio e rileggilo quando la settimana si chiude.

### Man, Generale, mese
- Rito: Il mese che comincia oggi è di Man, il pieno: l'almanacco antico avverte che ciò che è colmo trabocca. Per i trenta giorni scegli una misura semplice, un impegno in meno o una sera libera alla settimana. Fissala adesso e ringrazia per ciò che hai già.

### Man, Generale, anno
- Rito: Man, il pieno, ha accolto a Capodanno la nascita del tuo anno cinese: l'almanacco lo lega ai voti e alla gratitudine. Il gesto vale in qualunque punto dell'anno: accendi adesso una candela, nomina a voce bassa tre doni ricevuti e un desiderio per chi ti è caro.

### Man, Amore, giorno
- Rito: Oggi l'almanacco segna Man, il giorno pieno, adatto a stringere i legami di famiglia. Chiama un parente che non senti da tempo oppure invita chi ami, o un'amicizia cara se sei senza legame, a condividere un pasto preparato con cura. Riempi la tavola con poche cose buone.

### Man, Amore, settimana
- Rito: Sotto Man, che la tradizione affida ai legami familiari, la settimana degli affetti chiede una tavola piena. Organizza nei sette giorni un incontro che riunisca le persone care, la famiglia o gli amici più stretti, anche solo un caffè a casa tua. Manda adesso il primo invito.

### Man, Amore, mese
- Rito: Per trenta giorni, da oggi, Man porta negli affetti il segno del pieno e dei legami stretti. Scegli una persona cara, chi ami o chi ti piacerebbe conoscere meglio: dedicale un gesto di cura ogni settimana. Comincia adesso con un messaggio affettuoso.

### Man, Amore, anno
- Rito: Nato a Capodanno sotto Man, l'ufficiale del pieno, il tuo anno cinese lega gli affetti ai voti e alla famiglia. Esprimi adesso un voto per la tua vita sentimentale, per l'amore che hai o per quello che desideri: scrivilo su un biglietto e conservalo.

### Man, Carriera, giorno
- Rito: Oggi governa Man, il giorno del pieno: ciò che è colmo chiede misura. Al lavoro guarda quello che hai già raccolto, una pratica finita o un risultato ottenuto: riconoscilo con una riga di bilancio. Ringrazia un collega che ti ha dato una mano in questi giorni.

### Man, Carriera, settimana
- Rito: Con Man, il pieno, si apre una settimana in cui al lavoro conviene non caricarsi di impegni nuovi. Fai adesso l'elenco di ciò che già porti e scegli dove mettere la tua cura migliore nei sette giorni. Ciò che è colmo trabocca, avverte l'almanacco antico.

### Man, Carriera, mese
- Rito: Il pieno di Man governa il giorno da cui partono i tuoi trenta giorni di lavoro e di studio. Guarda i risultati già raccolti e scrivine il bilancio in una pagina. Poi ringrazia adesso, con un messaggio, chi ti ha aiutato a ottenerli.

### Man, Carriera, anno
- Rito: Nel lavoro di quest'anno cinese, nato sotto Man a Capodanno, vale l'avvertenza dell'almanacco: ciò che è pieno trabocca. Prima di accettare un nuovo incarico, guarda adesso ciò che già porti e lascia un impegno a chi può prenderlo con più respiro.

### Man, Fortuna, giorno
- Rito: Oggi è Man, il giorno del pieno, che la tradizione lega ai desideri espressi. Per le occasioni dai forma a ciò che speri: scrivilo in una frase chiara e leggila ad alta voce davanti alla finestra. Un desiderio detto con precisione diventa più facile da riconoscere.

### Man, Fortuna, settimana
- Rito: Man, il giorno del pieno, regge oggi una settimana in cui le occasioni amano chi sa accogliere. Prepara adesso un piccolo spazio in casa con un oggetto che per te significa gioia. Guardalo ogni mattina dei sette giorni come un augurio.

### Man, Fortuna, mese
- Rito: Nel mese che parte oggi con Man, l'ufficiale dei voti, le occasioni chiedono un desiderio detto con chiarezza. Scrivilo adesso in una frase sola, appendila dove passi ogni giorno e leggila a voce alta ogni volta che la vedi nei trenta giorni.

### Man, Fortuna, anno
- Rito: Le occasioni di quest'anno cinese, nato a Capodanno sotto Man, passano dai voti espressi con misura. Esprimi adesso un desiderio solo e preciso, scrivilo su un foglio e conservalo fra le pagine di un libro caro. Ringrazia poi per un'occasione che hai già ricevuto.

### Ping, Generale, giorno
- Rito: Oggi è il giorno di Ping, l'ufficiale che livella: l'almanacco lo trova adatto ad aggiustare e abbellire. Ripara una piccola cosa rimasta guasta in casa, un bottone o una maniglia che cigola. Poi sistema un angolo perché sia più bello da guardare.

### Ping, Generale, settimana
- Rito: La settimana che oggi apre Ping, l'ufficiale che porta le cose al pari, chiede le riparazioni rimandate. Scrivi l'elenco delle piccole cose da aggiustare in casa e risolvine una adesso. Le altre trovano con calma il loro giorno nei sette che seguono.

### Ping, Generale, mese
- Rito: Ping, che livella e abbellisce, segna l'avvio del tuo mese. Scegli una stanza o un angolo trascurato e rendilo più bello nei trenta giorni, un poco alla volta: un quadro raddrizzato, una luce nuova, una superficie pulita. Comincia adesso dal dettaglio più piccolo.

### Ping, Generale, anno
- Rito: Il tuo anno cinese è venuto al mondo a Capodanno sotto Ping, l'ufficiale che mette in pari. Il suo gesto è aggiustare: ripara adesso una cosa guasta da tempo, in casa o in un'abitudine, poi rendila un poco più bella da guardare.

### Ping, Amore, giorno
- Rito: Oggi governa Ping, il giorno che spiana e mette in pari. In amore appiana un piccolo attrito: se hai un legame, ascolta la versione di chi ami fino in fondo prima di rispondere; se sei senza legame, chiarisci con garbo un malinteso nato in una conoscenza recente.

### Ping, Amore, settimana
- Rito: Ping, che livella, dà oggi il tono a una settimana di equilibrio negli affetti. Se vivi una relazione, guarda se uno dei due dà più dell'altro e proponi un piccolo scambio di compiti; se sei senza legame, chiediti se dai agli altri più di quanto ricevi.

### Ping, Amore, mese
- Rito: I trenta giorni che cominciano oggi con Ping chiedono agli affetti di spianare il terreno. Ripensa a un attrito rimasto aperto, con chi ami o con chi hai lasciato andare, oppure in famiglia: scegli adesso la frase con cui appianarlo e trova il momento giusto per dirla.

### Ping, Amore, anno
- Rito: Per gli affetti, il tuo anno cinese porta il segno di Ping, l'ufficiale che mette in pari, sotto cui è nato a Capodanno. Rendi più pari ciò che dai e ciò che ricevi, con chi ami o con chi ti sta vicino: fai adesso un passo concreto.

### Ping, Carriera, giorno
- Rito: Oggi l'almanacco indica Ping, il giorno piano, adatto ad aggiustare. Al lavoro rimetti in sesto ciò che zoppica: correggi un documento pieno di errori, aggiorna una cartella disordinata, sistema uno strumento che usi ogni giorno. Rifinire vale quanto creare, a volte anche di più.

### Ping, Carriera, settimana
- Rito: Nel lavoro, la settimana che nasce sotto Ping chiede di distribuire il carico in modo più uniforme, come fa l'ufficiale che livella. Guarda i sette giorni che hai davanti e sposta gli impegni dove sono troppo fitti. Comincia adesso riordinando con calma l'agenda di domani.

### Ping, Carriera, mese
- Rito: Trenta giorni di lavoro e di studio partono oggi da Ping, l'ufficiale che livella e aggiusta. Scegli il documento, il metodo o lo strumento che usi di più e miglioralo un poco ogni settimana. Adesso correggi la prima cosa che zoppica.

### Ping, Carriera, anno
- Rito: Ping, sotto cui il tuo anno cinese è nato a Capodanno, chiede al lavoro rifinitura più che slancio. Prendi adesso il compito che fai ogni giorno e trova il passaggio che zoppica: correggilo, semplificalo, rendilo più pulito. Rifinire è il gesto dell'ufficiale che livella.

### Ping, Fortuna, giorno
- Rito: Oggi è Ping, il giorno che rende piano il terreno. Per le occasioni abbellisci il luogo dove passi più tempo: un fiore, una luce migliore, una superficie lucidata. La tradizione lega questo giorno ai lavori di rifinitura che preparano l'accoglienza.

### Ping, Fortuna, settimana
- Rito: Le occasioni dei sette giorni che oggi apre Ping, l'ufficiale che mette in pari, passano più volentieri su una strada liscia. Individua un ostacolo pratico che ti frena, come una pratica in sospeso o una risposta da dare: rimuovilo adesso.

### Ping, Fortuna, mese
- Rito: Il mese di Ping, che rende piano il terreno, comincia oggi: per le occasioni prepara l'accoglienza. Nei trenta giorni abbellisci l'ingresso di casa, il luogo dove si arriva: una pianta, una luce calda, una soglia pulita. Comincia adesso con un solo dettaglio.

### Ping, Fortuna, anno
- Rito: Quest'anno cinese è nato a Capodanno sotto Ping, che spiana la strada: per le occasioni il gesto è togliere un intralcio. Scegli adesso una pratica ferma o una risposta che rimandi da tempo e portala a termine, così la via resta piana.

### Ding, Generale, giorno
- Rito: Oggi è il giorno di Ding, l'ufficiale che fissa: l'almanacco antico lo indica per i piani e per i calcoli. Siediti per dieci minuti con un foglio e disegna il piano della giornata. Decidi una priorità sola e scrivila in alto.

### Ding, Generale, settimana
- Rito: Ding, che rende stabili le cose, governa oggi l'avvio della settimana. È il momento di fare il piano dei sette giorni: fissa tre obiettivi chiari e per ciascuno un giorno. Evita di disperdere le forze in imprese improvvise e rimanda le partenze non necessarie.

### Ding, Generale, mese
- Rito: Sotto Ding, l'ufficiale dei piani e dei calcoli, comincia oggi il tuo mese. Prendi un foglio grande e disegna i trenta giorni in quattro colonne, una per settimana: scrivi in ciascuna una cosa sola da fissare. Fallo adesso e appendi il foglio dove lo vedi.

### Ding, Generale, anno
- Rito: A Capodanno Ding, l'ufficiale che fissa, ha dato il suo segno al tuo anno cinese. Il gesto dell'almanacco è fare piani: siediti adesso con un foglio, scrivi le tre cose che vuoi rendere stabili e accanto a ciascuna il passo che le avvicina.

### Ding, Amore, giorno
- Rito: Oggi governa Ding, il giorno che fissa e consolida. Negli affetti trasforma un'intenzione in un appuntamento: con chi ami, un giorno e un'ora senza distrazioni; o con chi desideri conoscere, un invito preciso. La tradizione sconsiglia le discussioni accese: rimanda ogni polemica a un momento più calmo.

### Ding, Amore, settimana
- Rito: Con Ding, l'ufficiale che stabilizza, oggi parte una settimana di promesse piccole e mantenibili. Concorda con chi ami un gesto da ripetere ogni sera dei sette giorni, oppure, se sei senza legame, promettiti un'uscita in cui incontrare persone nuove. Fissalo adesso.

### Ding, Amore, mese
- Rito: Ding, che rende saldo ciò che è incerto, segna l'avvio di un mese adatto alle promesse che si mantengono. Negli affetti scegli adesso un impegno chiaro verso chi ami o verso chi vorresti incontrare: scrivilo nell'agenda con una data precisa e tienilo fermo.

### Ding, Amore, anno
- Rito: Il segno di Ding, l'ufficiale che fissa, accompagna gli affetti del tuo anno cinese, nato sotto di lui a Capodanno. Trasforma adesso un'intenzione in un impegno: un tempo fisso per chi ami o, se sei senza legame, un appuntamento fisso con ciò che ti fa incontrare gli altri.

### Ding, Carriera, giorno
- Rito: Oggi l'almanacco segna Ding, adatto a chi deve pianificare. Al lavoro prendi un progetto confuso e scrivine la scaletta: le fasi, chi fa cosa, quando finisce ciascun passaggio. Un piano messo nero su bianco libera la mente per il resto della giornata.

### Ding, Carriera, settimana
- Rito: In questa settimana di lavoro, aperta oggi da Ding, l'ufficiale che fissa, stabilisci subito le regole: orari, priorità, momenti senza interruzioni. Scrivile in un posto visibile e condividile con chi lavora accanto a te, così i sette giorni partono con chiarezza.

### Ding, Carriera, mese
- Rito: Ding, che l'almanacco antico indica per i piani e i calcoli, governa il primo giorno del tuo mese di lavoro. Scrivi adesso la scaletta dei trenta giorni: le tappe, i nomi di chi se ne occupa, le date di consegna. Rileggila all'inizio di ogni settimana.

### Ding, Carriera, anno
- Rito: Per il lavoro e lo studio, l'anno cinese nato sotto Ding a Capodanno chiede piani chiari. Siediti adesso con il progetto che ti sta più a cuore e fissane le tappe, con un nome e una data per ciascuna. Evita le liti: la tradizione le sconsiglia sotto Ding.

### Ding, Fortuna, giorno
- Rito: Oggi è Ding, il giorno che rende saldo ciò che è incerto. Per le occasioni fissa un appuntamento con qualcuno che può aprirti una porta: un incontro, una telefonata, una lettera. Metti data e ora nero su bianco così l'occasione prende forma.

### Ding, Fortuna, settimana
- Rito: Ding, che la tradizione dedica ai progetti ben pensati, regge oggi una settimana in cui le occasioni si riconoscono meglio con una mappa. Scrivi dove vuoi arrivare nei sette giorni e quali persone potrebbero aiutarti. Tieni la mappa a portata di mano e fissa adesso il primo contatto.

### Ding, Fortuna, mese
- Rito: Le occasioni del mese che comincia oggi con Ding chiedono appuntamenti fissati, non attese. Scegli tre persone che possono aprirti una porta e fissa con ciascuna un incontro o una telefonata nei trenta giorni. Scrivi adesso la prima data nell'agenda, con l'ora.

### Ding, Fortuna, anno
- Rito: Ding ha fissato a Capodanno il segno del tuo anno cinese: per le occasioni vale la sua arte dei piani. Disegna adesso una mappa di ciò che speri: dove vuoi arrivare, chi può aiutarti, quale passo è alla tua portata. Tienila dove la vedi e aggiornala quando cambia.

### Zhi, Generale, giorno
- Rito: Oggi è il giorno di Zhi, l'ufficiale che tiene: l'almanacco antico dice che custodisce ciò che è stato compiuto. Scegli una buona abitudine che hai già e rinforzala adesso, ripetendola con più attenzione del solito. Mantenere conta quanto cominciare, dice questo giorno.

### Zhi, Generale, settimana
- Rito: Zhi, che tiene saldo il raggiunto, governa oggi la tua settimana. La tradizione lo lega al costruire e al piantare: metti a dimora una piantina o un seme in un vaso e curalo per tutti i sette giorni. Ogni volta che lo annaffi ricorda ciò che vuoi custodire.

### Zhi, Generale, mese
- Rito: Il mese che parte oggi porta il segno di Zhi, che custodisce ciò che è compiuto. Scegli una buona abitudine che hai già e tienila viva per tutti i trenta giorni, segnando su un calendario ogni volta che la ripeti. Fai adesso il primo segno.

### Zhi, Generale, anno
- Rito: Sotto Zhi, che custodisce ciò che è stato compiuto, il tuo anno cinese è nato a Capodanno. Il gesto della tradizione è costruire e piantare: metti a dimora adesso una pianta che possa crescere a lungo e affidale ciò che vuoi tenere saldo.

### Zhi, Amore, giorno
- Rito: Oggi governa Zhi, il giorno che tiene e protegge. In amore mantieni oggi stesso una piccola promessa: a chi ami, se hai un legame; a te, se sei senza legame, come l'impegno di accettare un invito e incontrare persone nuove. Una parola tenuta vale più di dieci dette.

### Zhi, Amore, settimana
- Rito: Affidata a Zhi, che custodisce ciò che esiste già, la settimana in amore non chiede novità. Se hai un legame, scegli con chi ami una consuetudine che vi fa bene e proteggetela dagli impegni; se sei senza legame, tieni ferma ogni settimana un'ora per ciò che ti accende. Fissala adesso.

### Zhi, Amore, mese
- Rito: Zhi, l'ufficiale che tiene, apre oggi trenta giorni in cui gli affetti si rafforzano custodendo. Scegli un legame che conta per te (un amore, un'amicizia, un familiare) e dagli ogni settimana un tempo fisso, protetto con cura. Segna adesso nell'agenda il primo appuntamento.

### Zhi, Amore, anno
- Rito: Gli affetti del tuo anno cinese, nato a Capodanno sotto Zhi, chiedono di custodire ciò che c'è. Proteggi adesso un legame prezioso, con chi ami o con chi ti vuole bene da sempre: mantieni una promessa rimasta in sospeso o rinnova un gesto che avevate perso.

### Zhi, Carriera, giorno
- Rito: Oggi l'almanacco indica Zhi, il giorno che tiene fermo. Al lavoro consolida un risultato già ottenuto: salva le versioni definitive, documenta come hai risolto un problema, metti al sicuro i file importanti. Ciò che è custodito con cura resta a disposizione quando serve.

### Zhi, Carriera, settimana
- Rito: Sotto Zhi, che tiene, la settimana di lavoro chiede costanza più che novità. La tradizione sconsiglia di aprire attività nuove in questo giorno: porta avanti ciò che hai già avviato. Scegli il progetto principale dei sette giorni e dedicagli adesso la prima ora.

### Zhi, Carriera, mese
- Rito: Trenta giorni di costanza cominciano oggi con Zhi, che custodisce il compiuto. Nel lavoro e nello studio metti al sicuro ciò che hai costruito: scrivi una guida di come svolgi il compito più importante, una pagina a settimana. Comincia adesso dalla prima.

### Zhi, Carriera, anno
- Rito: L'anno cinese, nato a Capodanno sotto Zhi, chiede al lavoro e allo studio di tenere saldo ciò che è stato costruito. Scegli adesso un risultato già ottenuto e proteggilo: documentalo, salvane una copia, insegnalo a chi lavora con te. Mantenere conta quanto costruire.

### Zhi, Fortuna, giorno
- Rito: Oggi è Zhi, il giorno che trattiene e conserva. Per le occasioni non lasciar cadere un contatto prezioso: rispondi a quel messaggio rimasto aperto, ringrazia chi ti ha dato un'indicazione utile. Le occasioni restano vicine a chi sa tenerle con garbo.

### Zhi, Fortuna, settimana
- Rito: Zhi, l'ufficiale che custodisce, segna oggi una settimana in cui le occasioni vengono spesso da ciò che hai già. Scorri i tuoi contatti e scegli tre persone con cui riallacciare un filo nei sette giorni. Comincia adesso con la prima, con un messaggio semplice.

### Zhi, Fortuna, mese
- Rito: Per le occasioni, il mese che si apre oggi sotto Zhi chiede di tenere vicino ciò che è prezioso. Ogni settimana dei trenta giorni rispondi a un messaggio rimasto aperto o ringrazia chi ti ha dato un'indicazione utile. Fallo adesso per la prima volta.

### Zhi, Fortuna, anno
- Rito: Le buone occasioni dell'anno cinese, nato sotto Zhi a Capodanno, restano vicine a chi sa tenerle. Proteggi adesso un contatto prezioso che rischi di perdere: scrivigli due righe, ricorda un favore ricevuto, proponi di rivedervi. Tenere è il gesto dell'ufficiale che custodisce.

### Po, Generale, giorno
- Rito: Oggi è il giorno di Po, l'ufficiale che rompe: l'almanacco lo sconsiglia per quasi ogni impresa e lo lascia soltanto al demolire. Non cominciare nulla di importante. Butta via invece un oggetto rotto che conservi senza motivo e lascia quel vuoto com'è.

### Po, Generale, settimana
- Rito: Po, il giorno della rottura, regge oggi l'avvio della tua settimana: la tradizione lo trova adatto solo a smontare. Non avviare nulla oggi: individua una cattiva abitudine e spezzala con un gesto preciso. Rimanda le partenze ai giorni successivi della settimana.

### Po, Generale, mese
- Rito: Il primo dei trenta giorni appartiene a Po, che la tradizione lascia soltanto al demolire. Usa il mese per smontare ciò che non regge più: ogni settimana togli un'abitudine, un oggetto o un impegno che pesa senza servire. Oggi comincia buttando via una cosa rotta.

### Po, Generale, anno
- Rito: L'anno cinese ha ricevuto a Capodanno il segno di Po, l'ufficiale che rompe. Il suo gesto è demolire: spezza adesso un'abitudine che ti trattiene, con un atto netto. Poi getta un oggetto guasto tenuto per inerzia e non riempire subito quel vuoto.

### Po, Amore, giorno
- Rito: Oggi governa Po, il giorno che rompe, poco adatto agli affetti nuovi secondo l'almanacco. Non forzare dichiarazioni né decisioni importanti. Fai piuttosto ordine nei ricordi: elimina una vecchia foto o un messaggio che ti ferisce ancora quando lo rileggi. Il vuoto che resta è spazio.

### Po, Amore, settimana
- Rito: La settimana degli affetti che oggi comincia con Po, l'ufficiale della rottura, non è fatta per le grandi svolte. Rompi invece uno schema che si ripete, la stessa discussione con chi ami o la stessa scelta sbagliata se sei senza legame: cambiane adesso il copione.

### Po, Amore, mese
- Rito: Po, l'ufficiale che spezza, regge il giorno da cui partono trenta giorni di pulizia negli affetti. Non progettare dichiarazioni: scegli un rancore vecchio o una speranza che ti fa solo male e lascia andare quel peso con un gesto preciso. Fallo adesso, senza clamore.

### Po, Amore, anno
- Rito: Sotto Po, l'ufficiale che rompe, il tuo anno cinese è nato a Capodanno: negli affetti chiede di spezzare ciò che ferisce. Elimina adesso un ricordo che ti fa ancora male, una foto o un messaggio: il vuoto che resta fa spazio agli affetti di oggi.

### Po, Carriera, giorno
- Rito: Oggi l'almanacco segna Po, il giorno che rompe, sfavorevole agli inizi e alle intese. Al lavoro non lanciare progetti nuovi. Smantella piuttosto una procedura inutile: una riunione che nessuno vuole, un passaggio doppio, un modulo superato. Togliere ciò che è guasto è il suo compito.

### Po, Carriera, settimana
- Rito: Sotto Po, che la tradizione dedica soltanto al demolire, la settimana di lavoro comincia smontando. Guarda un metodo che ti rallenta da tempo e decidi adesso di abbandonarlo. I progetti nuovi possono partire nei giorni che seguono, quando la strada è sgombra.

### Po, Carriera, mese
- Rito: Nel lavoro e nello studio, il mese che oggi apre Po è adatto a smantellare, non a lanciare. Scegli una procedura inutile o un passaggio doppio: nei trenta giorni toglilo di mezzo. Scrivi adesso a chi ne decide una proposta chiara per eliminarlo.

### Po, Carriera, anno
- Rito: Po, l'ufficiale che rompe, ha segnato a Capodanno la nascita del tuo anno cinese. Nel lavoro e nello studio il suo gesto è smontare ciò che non regge: abbandona adesso un metodo che ti rallenta, scrivi perché e con che cosa lo sostituisci.

### Po, Fortuna, giorno
- Rito: Oggi è Po, il giorno della rottura, in cui l'almanacco consiglia di non intraprendere nulla di propizio. Per le occasioni il gesto è sgomberare la strada: rompi un'abitudine che ti blocca, come rimandare sempre la stessa risposta. Così la via resta più libera.

### Po, Fortuna, settimana
- Rito: Po, l'ufficiale che spezza, apre oggi una settimana in cui le occasioni non si inseguono: la tradizione lo lascia al demolire. Elimina adesso un impegno che ti pesa senza portarti nulla e rimanda ai giorni seguenti della settimana ogni passo nuovo.

### Po, Fortuna, mese
- Rito: Le occasioni dei trenta giorni che partono oggi con Po, l'ufficiale che rompe, chiedono strada sgombra. Individua l'abitudine che ti blocca più spesso, come dire di sì a tutto: spezzala adesso con un no gentile, poi ripeti quel gesto ogni settimana.

### Po, Fortuna, anno
- Rito: Per le occasioni, l'anno cinese nato sotto Po a Capodanno chiede di sgombrare prima di cercare. Rompi adesso un'abitudine che ti chiude le porte: la scusa che ripeti, il rifiuto automatico. Togli di mezzo anche un impegno che ti svuota.

### Wei, Generale, giorno
- Rito: Oggi è il giorno di Wei, l'ufficiale del pericolo: l'almanacco lo consiglia per il raccoglimento e sconsiglia di salire in alto o di cambiare casa. Prenditi cinque minuti di silenzio in un luogo tranquillo. Pensa a chi vuoi proteggere e dedicagli un pensiero.

### Wei, Generale, settimana
- Rito: Wei, il giorno della vigilanza, governa oggi la tua settimana: la tradizione lo affida alle preghiere e ai voti, non agli spostamenti. Ricontrolla con calma i piani dei sette giorni prima di muoverti e dedica adesso un momento di silenzio a ciò che desideri custodire.

### Wei, Generale, mese
- Rito: Trenta giorni sotto Wei, l'ufficiale della vigilanza, cominciano oggi: chiedono passi misurati e raccoglimento. Scegli un momento fisso della sera per qualche minuto di silenzio e dedicalo a chi vuoi proteggere. Comincia adesso, in un luogo tranquillo. Rimanda i traslochi e le salite rischiose.

### Wei, Generale, anno
- Rito: Wei, l'ufficiale della vigilanza, ha visto nascere a Capodanno il tuo anno cinese. Il suo gesto è il raccoglimento: fermati adesso cinque minuti in silenzio, pensa a chi vuoi proteggere e prima di ogni passo rischioso concediti una pausa per ricontrollare.

### Wei, Amore, giorno
- Rito: Oggi governa Wei, il giorno che chiede attenzione. Negli affetti non affrontare le questioni delicate di fretta. Raccogliti un momento e pensa con affetto a chi ami o a chi desideri incontrare, poi esprimi un augurio sincero. La tradizione lega questo giorno ai voti più che alle imprese.

### Wei, Amore, settimana
- Rito: La prudenza di Wei accompagna la settimana degli affetti che comincia oggi. Osserva ciò che è fragile nella tua vita sentimentale, con o senza legame: proteggilo invece di metterlo alla prova. Esprimi adesso un voto sincero per chi ami o per chi speri di incontrare.

### Wei, Amore, mese
- Rito: Il mese degli affetti che nasce oggi sotto Wei chiede delicatezza più che slancio. Ogni settimana dedica un momento di raccoglimento a chi ami o a chi desideri, con un pensiero gentile o un augurio scritto, senza pretese. Comincia adesso con il primo.

### Wei, Amore, anno
- Rito: Nella vita sentimentale, l'anno cinese nato a Capodanno sotto Wei chiede vigilanza e cura. Prima di una parola difficile, con chi ami, in famiglia o con chi stai conoscendo, concediti adesso un momento di silenzio e un voto sincero per quella persona.

### Wei, Carriera, giorno
- Rito: Oggi l'almanacco indica Wei, il giorno del pericolo, poco adatto ai salti nel vuoto. Al lavoro controlla due volte prima di inviare: rileggi una comunicazione importante, verifica i dati, chiedi un parere. La cautela di oggi può evitare correzioni nei giorni seguenti.

### Wei, Carriera, settimana
- Rito: Sotto Wei, che invita alla vigilanza, la settimana di lavoro comincia senza cambi bruschi. Annota i punti deboli dei progetti in corso e scegli quale mettere in sicurezza per primo. Fallo adesso con calma e ricontrolla due volte ogni comunicazione importante dei sette giorni.

### Wei, Carriera, mese
- Rito: Wei, poco adatto ai salti nel vuoto, governa il primo dei tuoi trenta giorni di lavoro. Prima di ogni decisione importante del mese chiedi un parere e rileggi i dati. Comincia adesso: scegli il progetto più esposto e scrivi tre precauzioni per metterlo al sicuro.

### Wei, Carriera, anno
- Rito: Il tuo anno cinese, nato a Capodanno sotto Wei, chiede al lavoro passi controllati. Scegli adesso il progetto più fragile e mettilo in sicurezza: una copia dei dati, un parere chiesto, una scadenza resa più realistica. La vigilanza è il gesto dell'ufficiale.

### Wei, Fortuna, giorno
- Rito: Oggi è Wei, il giorno in cui la tradizione sconsiglia viaggi per mare e salite in alto. Per le occasioni resta con i piedi per terra: valuta con lucidità una proposta che ti è arrivata e chiedi tempo prima di rispondere. Una pausa ponderata è un gesto saggio.

### Wei, Fortuna, settimana
- Rito: Wei, l'ufficiale del pericolo, segna oggi una settimana in cui le occasioni chiedono discernimento. Scrivi adesso accanto a ogni possibilità che vedi un rischio e una precauzione. Dedica poi con calma un momento di raccoglimento a ciò che speri nei sette giorni.

### Wei, Fortuna, mese
- Rito: Per trenta giorni, a partire da oggi, Wei invita le occasioni alla prudenza. Quando arriva una proposta, chiedi tempo prima di rispondere e valutala con lucidità. Comincia adesso con quella che hai sul tavolo e rimanda viaggi e salite che non servono.

### Wei, Fortuna, anno
- Rito: Wei ha dato a Capodanno il suo segno all'anno cinese che stai vivendo. Per le occasioni vale la sua prudenza: davanti a una proposta, fermati adesso e scrivi un rischio e una precauzione, poi dedica un momento di raccoglimento a ciò che speri.

### Cheng, Generale, giorno
- Rito: Oggi è il giorno di Cheng, l'ufficiale che compie: l'almanacco lo considera fra i più adatti a portare a termine. Scegli una cosa lasciata a metà e finiscila adesso, anche se è piccola. Un libro da chiudere, una lettera da spedire, un armadio da completare.

### Cheng, Generale, settimana
- Rito: Cheng, che porta le cose a compimento, regge oggi il primo dei sette giorni. Chiudi adesso una faccenda in sospeso da troppo tempo. Poi scegli l'impresa che vuoi vedere compiuta prima che la settimana si chiuda e scrivila su un foglio.

### Cheng, Generale, mese
- Rito: Sotto Cheng, fra i giorni più adatti a portare a termine, si apre oggi il tuo mese. Scegli tre cose lasciate a metà e assegna a ciascuna una settimana per finirla. Completa adesso la più piccola: una lettera, un armadio, un libro da chiudere.

### Cheng, Generale, anno
- Rito: Il segno che Cheng ha posto a Capodanno sul tuo anno cinese è il compimento. Il gesto vale in qualunque giorno dell'anno: scegli adesso una cosa lasciata a metà e portala a termine, anche se è piccola, poi cancellala dall'elenco delle cose sospese.

### Cheng, Amore, giorno
- Rito: Oggi governa Cheng, il giorno del compimento, che la tradizione lega anche alle unioni. Negli affetti completa un gesto rimasto a metà: la sorpresa progettata e mai fatta, la parola gentile trattenuta. Dedicalo adesso a chi ami o a chi desideri avvicinare, senza aspettare un'occasione speciale.

### Cheng, Amore, settimana
- Rito: Cheng, che compie e unisce, dà oggi il suo segno alla settimana degli affetti. Se vivi una relazione, realizzate un progetto di cui parlate da tempo, anche piccolo; se sei senza legame, porta a termine un passo che rimandi, come accettare un invito. Stabilisci adesso il primo gesto concreto.

### Cheng, Amore, mese
- Rito: Gli affetti dei trenta giorni che cominciano oggi seguono Cheng, che la tradizione lega alle unioni. Scegli una cosa da portare a compimento, un chiarimento con chi ami o un incontro che rimandi da tempo se sei senza legame: fissane adesso la data.

### Cheng, Amore, anno
- Rito: Cheng, l'ufficiale che compie e unisce, ha segnato a Capodanno il tuo anno cinese. Negli affetti il gesto è completare: pronuncia adesso la parola che trattieni da tempo a chi ami o, se sei senza legame, accetta l'invito che continui a rimandare.

### Cheng, Carriera, giorno
- Rito: Oggi l'almanacco segna Cheng, il giorno adatto ad aprire e a concludere. Al lavoro porta a termine il compito più vicino alla fine e consegnalo prima di sera. Poi segnalo come chiuso: vedere una cosa completata può dare slancio a quelle che seguono.

### Cheng, Carriera, settimana
- Rito: Sotto Cheng, che compie, la settimana di lavoro chiede traguardi più che partenze. Scegli il progetto più maturo e fissa adesso il passo che lo chiude entro i sette giorni. Coinvolgi chi deve approvarlo così il compimento non resta in sospeso.

### Cheng, Carriera, mese
- Rito: Cheng, l'ufficiale che compie, governa il primo dei trenta giorni di lavoro e di studio che hai davanti. Fai l'elenco dei compiti vicini alla fine e assegna a ciascuno una data di consegna dentro il mese. Chiudi adesso il primo e spuntalo dall'elenco.

### Cheng, Carriera, anno
- Rito: Il lavoro dell'anno cinese che stai vivendo porta il segno di Cheng, sotto cui è nato a Capodanno. Il suo gesto è portare a termine: scegli adesso il compito che resta aperto da più tempo e consegnalo, anche imperfetto, con una nota su ciò che manca.

### Cheng, Fortuna, giorno
- Rito: Oggi è Cheng, il giorno che l'almanacco dedica a partire e a trasferirsi. Per le occasioni muoviti: vai di persona dove finora hai solo scritto, partecipa a un incontro, visita un luogo che ti incuriosisce. Spesso le cose si compiono quando ci si mette in strada.

### Cheng, Fortuna, settimana
- Rito: Cheng, l'ufficiale del compimento e delle partenze, regge oggi una settimana in cui le occasioni chiedono di arrivare in fondo. Riprendi una possibilità lasciata cadere a metà strada e completa adesso il passaggio che mancava: una risposta, una richiesta, una visita.

### Cheng, Fortuna, mese
- Rito: Mettiti in strada: il mese che comincia oggi è di Cheng, che l'almanacco dedica a partire e a trasferirsi. Per le occasioni scegli un luogo dove finora hai solo scritto o telefonato e vacci di persona nei trenta giorni. Fissa adesso la data.

### Cheng, Fortuna, anno
- Rito: A Capodanno il tuo anno cinese è nato sotto Cheng, che compie le cose e accompagna chi parte. Per le occasioni il gesto è arrivare in fondo: riprendi adesso una possibilità lasciata a metà e fai il passo che mancava, di persona se puoi.

### Shou, Generale, giorno
- Rito: Oggi è il giorno di Shou, l'ufficiale che raccoglie: l'almanacco antico dice che dopo il compimento viene il raccolto. Fermati a mettere insieme ciò che hai ottenuto in questo tempo e scrivilo in un elenco. Leggilo con calma e riconosci il cammino fatto.

### Shou, Generale, settimana
- Rito: Shou, che raccoglie i frutti, governa oggi la settimana che hai davanti. Riordina quello che hai già: foto, appunti, idee sparse in tanti posti. Riuniscile adesso in un unico luogo e scegli quale coltivare nei sette giorni. Il raccolto viene prima di ogni nuova semina.

### Shou, Generale, mese
- Rito: Il raccolto di Shou dà il segno al mese che comincia oggi. Ogni settimana dei trenta giorni metti per iscritto ciò che hai ottenuto, anche le piccole cose. Comincia adesso con un elenco di ciò che hai raccolto finora e leggilo con calma.

### Shou, Generale, anno
- Rito: L'anno cinese che stai vivendo è nato a Capodanno sotto Shou, l'ufficiale che raccoglie. Dopo il compimento viene il raccolto, dice l'almanacco antico: raccogli adesso in una pagina i frutti già colti e rileggili ad alta voce. Riconoscere ciò che c'è è il gesto di Shou.

### Shou, Amore, giorno
- Rito: Oggi governa Shou, il giorno del raccolto. Negli affetti raccogli i momenti belli: ripensa a un ricordo felice vissuto con chi ami o con chi ti vuole bene: raccontalo a quella persona oppure mettilo per iscritto. Stampa una foto di quel giorno e appendila.

### Shou, Amore, settimana
- Rito: Shou, l'ufficiale che raccoglie, invita oggi gli affetti a riconoscere ciò che hanno già dato. Scrivi su un biglietto tre cose belle ricevute in questo ultimo tratto da chi ami o, se sei senza legame, da un'amicizia cara. Consegnalo adesso, oppure rileggilo ogni sera della settimana.

### Shou, Amore, mese
- Rito: Trenta giorni di raccolto per gli affetti partono oggi con Shou, l'ufficiale che raccoglie. Ogni settimana scegli un ricordo bello vissuto con chi ami o con chi ti è caro: scrivilo in un quaderno dedicato. Comincia adesso dal più recente e rileggilo con calma.

### Shou, Amore, anno
- Rito: Dal Capodanno lunare il tuo anno cinese porta il segno di Shou, che raccoglie. Negli affetti il gesto è custodire i frutti: metti adesso in una scatola un ricordo felice di un amore o di un'amicizia, un biglietto o una foto. Riaprila quando ne senti il bisogno.

### Shou, Carriera, giorno
- Rito: Oggi l'almanacco indica Shou, adatto a chi entra in una scuola e a chi raccoglie. Al lavoro raccogli ciò che hai imparato: annota in una pagina le lezioni dell'ultimo progetto, gli errori e le soluzioni. Tienila a portata di mano per il prossimo inizio.

### Shou, Carriera, settimana
- Rito: Shou, che la tradizione lega allo studio, segna oggi la tua settimana di lavoro e di studio. Scegli una competenza da coltivare nei sette giorni e dedica adesso mezz'ora alla prima lezione. Raccogli materiali, appunti e domande in una cartella dedicata.

### Shou, Carriera, mese
- Rito: Lo studio e il lavoro dei trenta giorni che cominciano oggi seguono Shou, l'ufficiale del raccolto. Ogni settimana raccogli in una pagina ciò che hai imparato: errori, soluzioni, idee. Adesso apri la pagina e scrivi con calma la prima lezione dell'ultimo progetto.

### Shou, Carriera, anno
- Rito: Il tuo anno cinese, venuto al mondo a Capodanno sotto Shou, lega il lavoro al raccolto e allo studio. Raccogli adesso ciò che hai imparato nel lavoro: scrivi in una pagina tre lezioni, un errore che non ripeti e una competenza da coltivare ancora.

### Shou, Fortuna, giorno
- Rito: Oggi è Shou, il giorno del raccolto, che l'almanacco sconsiglia per i viaggi lunghi. Per le occasioni resta nei paraggi e raccogli: rispondi alle proposte arrivate, rileggi gli inviti ricevuti, segna quali meritano un sì. Spesso l'occasione è già sulla soglia.

### Shou, Fortuna, settimana
- Rito: In questa settimana di raccolto, aperta oggi da Shou, le occasioni possono nascere da ciò che hai seminato prima. Ripercorri gli incontri recenti e scegli quello da far maturare. Fai adesso un passo per riprenderlo, restando nei paraggi: la tradizione sconsiglia i viaggi lunghi.

### Shou, Fortuna, mese
- Rito: Il mese che oggi apre Shou, l'ufficiale del raccolto, invita a raccogliere le occasioni già vicine. Ogni settimana rileggi gli inviti e le proposte arrivate e scegli quale merita un sì. Comincia adesso dalla più vecchia, senza allontanarti per viaggi lunghi.

### Shou, Fortuna, anno
- Rito: Nel tuo anno cinese, nato sotto Shou a Capodanno, le occasioni sono spesso già sulla soglia. Raccogli adesso ciò che hai seminato: rispondi a una proposta rimasta in attesa, riprendi un contatto promettente, accetta ciò che merita. Restare nei paraggi è il gesto di Shou.

### Kai, Generale, giorno
- Rito: Oggi è il giorno di Kai, l'ufficiale che apre: l'almanacco antico lo chiama il soffio vitale che comincia. Spalanca porte e finestre per qualche minuto, lascia entrare luce e aria. Poi apri anche l'agenda e fai spazio a un incontro che desideri.

### Kai, Generale, settimana
- Rito: Kai, che la tradizione lega ai banchetti e alle feste, regge oggi la tua settimana. Apri la casa nei sette giorni: invita amici o vicini per un pasto semplice. Scegli adesso la data e manda gli inviti. Una tavola aperta è il gesto di Kai.

### Kai, Generale, mese
- Rito: Kai, il soffio vitale che comincia, dà il segno al mese che parte oggi. Nei trenta giorni apri una porta nuova ogni settimana: un luogo, una persona, un'attività mai provata. Scegli adesso la prima e scrivila nell'agenda. Poi spalanca le finestre e lascia entrare aria.

### Kai, Generale, anno
- Rito: Kai, l'ufficiale dell'apertura, ha visto nascere a Capodanno il tuo anno cinese. Il gesto vale oggi come in ogni altro giorno: apri adesso una porta rimasta chiusa: riprendi un'amicizia interrotta, torna in un luogo amato, rispondi a un invito lasciato cadere.

### Kai, Amore, giorno
- Rito: Oggi governa Kai, il giorno che apre, che l'almanacco antico dedica alle unioni e ai conviti. Negli affetti apri il cuore con una frase sincera, di quelle che di solito tieni per te: dilla a chi ami o a chi desideri conoscere, guardando negli occhi oppure scrivendo a mano.

### Kai, Amore, settimana
- Rito: Allargare il cerchio degli affetti è il gesto della settimana che Kai, l'ufficiale dell'apertura, governa da oggi. Accetta un invito o fanne uno: una cena a casa con persone care e qualcuno di nuovo, insieme a chi ami se hai un legame. Organizza adesso il primo incontro.

### Kai, Amore, mese
- Rito: Sotto Kai, che l'almanacco antico dedica alle unioni e ai conviti, cominciano oggi trenta giorni aperti agli incontri. Ogni settimana fai un invito: una cena con chi ami, un'uscita con amici dove conoscere persone nuove se sei senza legame. Manda adesso il primo.

### Kai, Amore, anno
- Rito: Aperto da Kai a Capodanno, il tuo anno cinese invita gli affetti all'incontro. Il gesto è aprire il cuore: rivolgi adesso una parola sincera a chi ami o, se sei senza legame, accetta di conoscere qualcuno di nuovo, anche solo per un caffè.

### Kai, Carriera, giorno
- Rito: Oggi l'almanacco segna Kai, il giorno propizio ad aprire un'attività. Al lavoro apri un canale nuovo: scrivi a una persona che stimi e che non conosci ancora, proponi un'idea in riunione, inaugura un fascicolo per un progetto. Un'apertura piccola basta.

### Kai, Carriera, settimana
- Rito: Sotto Kai, che apre, la settimana di lavoro e di studio comincia con una presentazione. Racconta a chi lavora con te il progetto che vuoi aprire e chiedi chi vuole partecipare nei sette giorni. Fallo adesso, finché il soffio dell'inizio è fresco.

### Kai, Carriera, mese
- Rito: Kai, propizio ad aprire un'attività, segna l'avvio del tuo mese di lavoro e di studio. Ogni settimana apri un canale nuovo: scrivi a una persona che stimi e non conosci ancora, proponi un'idea, frequenta un incontro di settore. Comincia adesso col primo messaggio.

### Kai, Carriera, anno
- Rito: Nel lavoro, il tuo anno cinese porta il soffio di Kai, sotto cui è nato a Capodanno. Il gesto è aprire un canale: scrivi adesso a una persona che stimi e non conosci ancora, o proponi in riunione l'idea che tieni nel cassetto.

### Kai, Fortuna, giorno
- Rito: Oggi è Kai, il giorno dell'apertura, fra i più graditi alla tradizione. Per le occasioni esci e incontra persone: accetta un invito, parla con qualcuno che vedi spesso senza mai salutare, entra in un luogo nuovo del quartiere. Un saluto può aprire una porta.

### Kai, Fortuna, settimana
- Rito: Kai, l'ufficiale che apre le porte, segna oggi una settimana in cui le occasioni passano dagli incontri. Scegli un gruppo, un corso o un'associazione da frequentare nei sette giorni e fai adesso la prima telefonata. Aprire la porta è il gesto.

### Kai, Fortuna, mese
- Rito: Esci e incontra persone: il mese che comincia oggi è di Kai, fra i giorni più graditi alla tradizione. Per le occasioni accetta ogni settimana almeno un invito e saluta qualcuno che vedi spesso senza conoscerlo. Comincia adesso con il primo saluto.

### Kai, Fortuna, anno
- Rito: Kai, fra gli ufficiali più graditi alla tradizione, ha segnato a Capodanno il tuo anno cinese. Per le occasioni il gesto è uscire incontro agli altri: entra adesso in un luogo nuovo del quartiere, accetta un invito, saluta chi incroci ogni giorno.

### Bi, Generale, giorno
- Rito: Oggi è il giorno di Bi, l'ufficiale che chiude: l'almanacco lo sconsiglia per aprire o partire e lo lascia al sigillare. Chiudi una cosa rimasta aperta: un barattolo, una porta che sbatte, una faccenda sospesa. Poi riponi quello che hai usato.

### Bi, Generale, settimana
- Rito: Bi, che chiude e custodisce, regge oggi la tua settimana. La tradizione spiega che senza chiusura il nuovo non può nascere: fai la lista delle questioni aperte e chiudine una adesso, con un gesto definitivo. Le altre trovano posto nei sette giorni.

### Bi, Generale, mese
- Rito: Chiudere e sigillare: è il compito del mese che parte oggi con Bi, ultimo dei dodici ufficiali. Ogni settimana porta a compimento una questione rimasta aperta e riponi ciò che hai usato. Comincia adesso chiudendo la più piccola, senza aprirne di nuove.

### Bi, Generale, anno
- Rito: Sotto Bi, che chiude e sigilla, il tuo anno cinese ha preso vita a Capodanno. Solo chi sa chiudere torna a stabilire, dice l'almanacco antico: porta adesso a compimento una faccenda trascinata da tempo e sigillala con un gesto definitivo: un ultimo passaggio, un messaggio di chiusura.

### Bi, Amore, giorno
- Rito: Oggi governa Bi, il giorno che chiude, poco adatto alle promesse nuove secondo l'almanacco. In amore custodisci invece di cercare: se hai un legame, passa la sera con chi ami, telefoni spenti e porta chiusa; se sei senza legame, concediti una sera quieta, senza rincorrere nessuno.

### Bi, Amore, settimana
- Rito: Bi, l'ufficiale che sigilla, dà oggi agli affetti una settimana per chiudere con dolcezza una questione in sospeso. Un chiarimento promesso, una scusa mai detta, con chi ami, in famiglia o con chi frequenti: fallo adesso, così i sette giorni ripartono leggeri.

### Bi, Amore, mese
- Rito: Con Bi, che chiude, partono oggi trenta giorni per proteggere ciò che conta negli affetti. Ogni settimana riserva una sera senza telefoni né impegni a chi ami o, se sei senza legame, a te e alle amicizie più fedeli. Fissa adesso la prima.

### Bi, Amore, anno
- Rito: Chiudere con dolcezza è il gesto che Bi, sotto cui è nato a Capodanno il tuo anno cinese, chiede agli affetti. Porta adesso a compimento una questione sospesa, una scusa o un chiarimento, con chi ami o con chi ha contato per te, senza riaprire ferite.

### Bi, Carriera, giorno
- Rito: Oggi l'almanacco indica Bi, il giorno che chiude, sfavorevole all'avvio di attività. Al lavoro completa invece di aprire: chiudi le pratiche finite, archivia le cartelle, rispondi agli ultimi messaggi rimasti sospesi. Lascia la scrivania sgombra prima di andare via, pronta per il prossimo inizio.

### Bi, Carriera, settimana
- Rito: Bi, che la tradizione lega a chiudere le falle e alzare argini, segna oggi la tua settimana di lavoro. Individua il punto dove si disperde più tempo e mettici un argine adesso: una regola, un orario, un limite. Proteggi così le energie dei sette giorni.

### Bi, Carriera, mese
- Rito: Il lavoro e lo studio dei trenta giorni che cominciano oggi seguono Bi, sfavorevole all'avvio di attività. Usa il mese per completare invece di aprire: ogni settimana chiudi una pratica finita e archivia le cartelle. Comincia adesso rispondendo ai messaggi rimasti sospesi.

### Bi, Carriera, anno
- Rito: Arginare è il gesto di Bi, sotto cui il tuo anno cinese è nato a Capodanno. Nel lavoro chiudi adesso la falla da cui fugge più tempo, come un'interruzione continua: alza un argine con una regola chiara e comunicala a chi lavora con te.

### Bi, Fortuna, giorno
- Rito: Oggi è Bi, il giorno che sigilla, in cui l'almanacco sconsiglia di inseguire novità. Per le occasioni conserva ciò che hai: rileggi una proposta già accettata e porta a termine l'ultimo passaggio. Una porta chiusa bene aiuta a preparare la prossima apertura.

### Bi, Fortuna, settimana
- Rito: Bi, l'ultimo dei dodici ufficiali, regge oggi una settimana per chiudere un capitolo: dopo di lui la serie torna a Jian, che stabilisce. Per le occasioni saluta un progetto finito e ringrazia chi ha fatto la strada con te. Così prepari spazio.

### Bi, Fortuna, mese
- Rito: Conservare ciò che hai è il gesto del mese che si apre oggi con Bi, il giorno che sigilla. Per le occasioni completa ogni settimana un impegno già preso, invece di cercarne di nuovi. Comincia adesso da quello più vicino alla fine.

### Bi, Fortuna, anno
- Rito: Una porta chiusa bene prepara la prossima: è il segno di Bi, sotto cui l'anno cinese è nato a Capodanno. Per le occasioni sigilla adesso ciò che hai ottenuto: metti al sicuro un documento importante, conferma un impegno preso, custodisci un contatto prezioso.
