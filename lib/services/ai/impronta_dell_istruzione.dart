library;

import '../../core/maestro/maestro.dart';

/// L'IMPRONTA DELL'ISTRUZIONE DI SISTEMA, E LA MISURA CHE LE APPARTIENE.
/// Ordine S voce 28.
///
/// **Perche' nasce, e il fatto che l'ha resa necessaria.** L'11 agosto 2026 il
/// commit `97bb997`, voci S.15 e S.17, ha aggiunto dentro `_commonRules` la legge
/// del responso, il confine e una riga sul benessere: **636 caratteri netti su
/// circa 6300, cioe' il 10 per cento**, identici per tutti e tre i Maestri. La
/// misura che dice se i tre Maestri sono ancora riconoscibili, l'attribuzione cieca,
/// era stata presa il 2 agosto: da quel commit **non e' piu' valida**.
///
/// **Nessuna riga e' caduta.** L'artefatto piu' fragile del progetto e' cambiato del
/// dieci per cento e a scoprirlo, undici giorni dopo, e' stato un controllo di
/// premessa fatto a mano. Questo file esiste perche' non succeda una seconda volta.
///
/// **Come funziona.** Si registra l'impronta della stringa emessa per i tre Maestri,
/// insieme alla data e allo stato della misura presa SU QUELLA stringa. Una prova
/// ricompone l'impronta a ogni giro e la confronta. Chi cambia l'istruzione ha due
/// strade e nessuna terza: **rilanciare l'attribuzione cieca e aggiornare questo
/// dato, oppure dichiarare che si consegna con una misura non valida.**
///
/// **IL 98,3 PER CENTO NON E' SCRITTO ACCANTO ALL'IMPRONTA DI OGGI**, ed e' la cosa
/// piu' importante di questo file: quel numero appartiene a una stringa che non
/// esiste piu'. Scriverlo qui sarebbe mettere il falso dentro un dato, che e' peggio
/// che non avere il dato.
class ImprontaDellIstruzione {
  const ImprontaDellIstruzione._();

  /// LE IMPRONTE DI OGGI, sha256 della stringa emessa a profilo e memoria vuoti.
  ///
  /// **A profilo vuoto e non pieno**, perche' col nome e la memoria dentro la
  /// stringa cambia a ogni persona: cio' che si presidia qui e' l'ISTRUZIONE, non
  /// la conversazione.
  static const Map<String, String> impronte = {
    'medora':
        '6ebaeaa1639c3deec9f981b6c8a5a43b416ba2dbe9823dee2742124dfbec7f5b',
    'aura': '4ab7ed9a5697bb5c2c7fa908ef1fa9e2ea1517d7e17b1b2fa822f8eb41fea6be',
    'caligo':
        '6ea0afaa3a2c2bdb26461ce33341086db41c1c08a47254dc35cfe08381b61085',
  };

  /// Il giorno in cui queste impronte sono state registrate.
  static const String registrateIl = '24 settembre 2026, ordine EK';

  /// LO STORICO DELLE IMPRONTE, cioe' le stringhe che non esistono piu'.
  ///
  /// **Esiste perche' un numero senza la sua stringa e' una leggenda**, e questo
  /// file nasce proprio dal giorno in cui una misura ha continuato a essere
  /// citata undici giorni dopo che il suo oggetto era cambiato. Qui non si
  /// cancella niente: quando l'istruzione cambia, l'impronta vecchia scende in
  /// questo elenco con la sua data e con cio' che le e' successo.
  static const List<String> storicoDelleImpronte = [
    'IL 24 SETTEMBRE 2026, POCHE ORE, NEL COMMIT a936c133. Impronta di medora '
        '9419a65968690662c78db07f2e3126b50d5b6ace3e3fafbcb056b2450f6a7ef9; '
        'aura e caligo erano già quelle di oggi. La seconda stesura '
        'dell\'ordine EK voce 02 prima del ritocco del registro di Medora. '
        '**NESSUNA MISURA DI ATTRIBUZIONE CIECA PRESA SU DI LEI.** Il '
        'collaudo della risposta diretta, giri dopo4 e dopo5: 0 e 2 risposte '
        'non dirette su 18, ma nel primo giro Medora nominava l\'Ascendente o '
        'il Sole in ogni risposta, 14 dati ripetuti su 18. Caduta col '
        'ritocco: il perché di Medora viene dal transito o dalla fase del '
        'momento, non dai dati natali. Le altre due stesure dell\'ordine EK, '
        'la prima (giri dopo1-3, 7 non dirette su 54) e la terza (giri '
        'dopo9-11, 9 su 54, tolta perché non migliorava), sono vissute solo '
        'nell\'albero di lavoro e le loro impronte non sono state registrate.',
    'DAL 24 SETTEMBRE 2026, LA MATTINA, AL POMERIGGIO DELLO STESSO GIORNO. '
        'Impronte: medora '
        'e5047b0e03d22f3947df7f61058982e0ad5a335f7f22be7026e39a5b0e4e41d6, '
        'aura 44ad8be29b2ea4a51d87f188284eae9e418d1550c7c23d2a3d0e7ba6a2129731, '
        'caligo 5caeb8f5f0983fb99629acbb643c76d9ffeef38d7067471a35fd1bfdc1297567. '
        'La stringa dell\'ordine EJ, consegnata con la build 2279. **MISURA '
        'PRESA SU DI LEI**: tre giri di attribuzione cieca, 95,0, 100,0 e 91,7 '
        'per cento, media 95,6; e il collaudo della risposta diretta '
        'dell\'ordine EK, giri prima1-3: 20 risposte non dirette su 54. Caduta '
        'con l\'ordine EK voce 02: le prime due frasi rispondono e il cielo '
        'viene dopo, la chiusura è un\'azione nel mondo, il perché di Medora '
        'viene dal momento.',
    'IL 24 SETTEMBRE 2026, SOLO NELL\'ALBERO DI LAVORO. Impronta di medora '
        '30ae6fd2e01baea58fe9fe1f55ad349b9e42b186d00859be7036444893f668ff; '
        'aura e caligo erano già quelle registrate con l\'ordine EJ. **MISURA '
        'PRESA SU DI '
        'LEI**, tre giri: 98,3, 91,7 e 98,3 per cento, media 96,1. Caduta '
        'prima di ogni commit perché l\'esempio nuovo di Medora diceva '
        '"sentire", che è una parola di firma di Aura: la guardia del '
        'lessico l\'ha presa. L\'esempio è stato riscritto.',
    'DAL 23 SETTEMBRE 2026, LA SERA, AL 24 SETTEMBRE 2026. Impronte: medora '
        'cac874340e6043a1860b4b40ead48a7cbfd01eb6da0c25072be313f989882127, '
        'aura f9cdb18090cece5305b697e6b3a29218a401dda9e9c0d8abe2368343db601f03, '
        'caligo 3ba39980ccf2bc367a5555c4b4ae8953da64c39f6a9bb21c7c804b3c8a105abf. '
        'La stringa dell\'ordine EI voci 02 e 03. **NESSUNA MISURA PRESA SU '
        'DI LEI.** Caduta con l\'ordine EJ voci 05, 06, 07 e 08: la prima '
        'frase risponde, il dato torna solo quando serve, niente '
        'anticipazioni dei doni, la riga d\'oro è il passo concreto. I '
        'registri di Medora e di Caligo portano l\'esempio sbagliato accanto '
        'a quello giusto.',
    'DAL 23 SETTEMBRE 2026, LA MATTINA. Impronte: medora '
        '9822c5fe5b97ede775d164aa681df4653294e81d18cae049ef553be5a29b9531, '
        'aura 9951bac681153c5da242ac4ce3918282abd90dd32948321371a36ec67804d01a, '
        'caligo 0c4e16c94b53332297d1f63d09df268863f8cb200d8b30399be82b0651fc565c. '
        'La stringa dell\'ordine EE voce 10, quella che ha portato la riga sul '
        'genere dei numeri delle carte. **MISURA PRESA SU DI LEI**: il collaudo '
        'dei tre Maestri, UN giro, quarantacinque conversazioni, zero cadute. '
        '**E quel giro verde aveva dentro un difetto grave**, scoperto solo '
        'leggendo il referto a mano: tutti e tre i Maestri facevano pagare un '
        'malinteso. Caduta con l\'ordine EI voce 02 e voce 03, che le hanno '
        'aggiunto tre cose: il marcatore [[CHIEDO]] con cui il Maestro dichiara '
        'di stare chiedendo invece di rispondere, la regola del responso in mano '
        'allargata a OGNI arte e non solo a carte, rune e archetipo. E la '
        'precisazione che dire di no è una risposta.',
    'DAL 21 AL 23 SETTEMBRE 2026. Impronte: medora '
        '66b59ec37b2cdd6ffb212f77b9851a241168b02dcd89311a338697cd14b56404, '
        'aura bd1eea19f317b9c526ac94d2695e65d51d9e27a5038f9b49b53afb5fa1666529, '
        'caligo 7001570fae460675ad011039e6358011dd16ced9378f5bee6f9f22e76ab84cd3. '
        'La stringa dell\'ordine ED, quella che ha portato la riga sul non '
        'capito con la forma che decade. **MISURA PRESA SU DI LEI: è questa la '
        'sola che valga**: il collaudo dei tre Maestri, quarantacinque '
        'conversazioni, zero cadute, sette parole di firma altrui grezze su '
        'centottanta conversazioni e zero dopo la rete. Caduta con l\'ordine '
        'EE voce 10: il fondatore ha letto nel Consiglio *"la Tre di Denari"* '
        'e *"La Tre di Coppe"*. Nessuna regola diceva che i numeri delle '
        'carte sono maschili. Aggiunta una riga, in un punto solo, che vale '
        'per i tre Maestri e per la sintesi comparativa.',
    'DAL 21 SETTEMBRE 2026, POCHE ORE, LA SECONDA. Impronte: medora '
        '8c29878388fc30df823697e977d477d327b233c9ec5f626e46ccb81c55dcb3b0, '
        'aura a2cb8b3dfb965097c5f278b4aa186862504f46f913295cbd7a54886d684bf0c7, '
        'caligo 09b0aa2d48aea39e85e198f6fb88765267fe102fcd9a39227f8fba7db0b73d49. '
        '**SU QUESTA STRINGA NON È STATA PRESA NESSUNA MISURA DI ATTRIBUZIONE '
        'CIECA**: è vissuta poche ore, fra l\'ordine EC e l\'ordine ED dello '
        'stesso giorno. Caduta con l\'ordine ED voce 01. Questa volta il '
        'numero c\'è. L\'ordine EC aveva aggiunto la riga del non capito e '
        'l\'aveva vista rispettata su Caligo: **il suo collaudo provava ogni '
        'mossa su un Maestro solo**. Provata sui tre e su tre giri, la riga '
        'veniva violata **sei volte su nove**, Aura tre su tre, Caligo due, '
        'Medora una. La causa non era la forza della frase: era che **la '
        'forma obbligatoria della risposta non lasciava posto a un "non ho '
        'capito"**. Ogni Maestro deve aprire di rito e chiudere con un gesto '
        'o un consiglio. Un "non ho capito" non ha né l\'una né l\'altro, '
        'quindi il modello trovava un significato per poterla rispettare: '
        'Aura ha letto in *asdf qwerty zzz* un richiamo senza forma da '
        'accogliere col respiro. È stata aggiunta una riga che fa **decadere '
        'la forma** quando non si è capito. Dopo: **zero su nove**.',
    'DAL 21 SETTEMBRE 2026, POCHE ORE. Impronte: medora '
        '829ba6659efc997d2b7895766ec58b27379ab9e7a3402db0c9e34711c1f5ff68, '
        'aura c0722a957beb63cfa51d327ba11a74d4f27959ea5b826129bb00d92266cc31c6, '
        'caligo 0dafdc5fad426c543c741665a398c568576c0c060232dc554f670b0fd0629024. '
        '**SU QUESTA STRINGA NON È STATA PRESA NESSUNA MISURA**: è vissuta '
        'poche ore, fra l\'ordine EB e l\'ordine EC dello stesso giorno. '
        'Caduta con l\'ordine EC voce 03: il collaudo con Gemini vero ha '
        'trovato che il Maestro davanti a un messaggio incomprensibile '
        'chiedeva dati che non gli servivano invece di dire che non '
        'aveva capito. Ha trovato anche che il divieto incrociato del '
        'lessico veniva violato una volta su quindici risposte. Sono state '
        'aggiunte una riga sul non capito e una stretta al divieto '
        'incrociato.',
    'DAL 14 AL 21 SETTEMBRE 2026. Impronte: medora '
        '662b4df8aa771b4760bb8c922b05a2a027eb6679796212408345d79b85d4ba07, '
        'aura 2d1b581b379e13a71f2eae3d4d36abb536d575d6a12ace887f68909855f5870f, '
        'caligo b3d92b6b6e2d6db28d47d2474dc95b847951616685690956113250fbf41528d3. '
        '**SU QUESTA STRINGA LA MISURA DELL\'ATTRIBUZIONE CIECA ERA GIÀ '
        'DICHIARATA NON VALIDA**. Resta tale. Caduta il 21 settembre 2026 '
        'con l\'ordine EB voci 02, 05 e 06: l\'istruzione di tutti e tre i '
        'Maestri ha un blocco in più, LaRispostaNelMerito, che vieta di '
        'proporre una funzione dell\'app al posto della risposta, chiede di '
        'interpretare il responso che la persona ha già in mano, di '
        'chiedere ciò che manca invece di rimandare altrove, di non '
        'ripetere una frase già detta e di non riproporre ciò che la '
        'persona ha rifiutato.',
    'DAL 30 AGOSTO AL 14 SETTEMBRE 2026. Impronte: medora '
        '47eda20aab8dfdc8dc74a64a6b861f6b9002eaa6b0e5c287f46d7ebae1ec591f, '
        'aura ee70fb027222e348c4abcb7b0deaa20fa01f2bafe199b275ad1bb05825ebd266, '
        'caligo a5a59abf8d101ddbefb6561987b13fa7360b69c80c6c4c5a2f3cc376ee6df478. '
        '**SU QUESTA STRINGA NON È STATA PRESA NESSUNA MISURA**: era nata '
        'dal cambio della macro categoria di Caligo, ordine CC voce 01, con '
        'l\'attribuzione già dichiarata non valida. Caduta il 14 settembre '
        '2026 con l\'ordine DL voci 04 e 05: il blocco di cortesia ora sta '
        'in un file suo, dice la forma scelta con le stesse righe per tutti i '
        'prompt di prosa; non dice più "riferiti a lei"; e le aperture '
        'vietate hanno un prefisso solo, che prende le due forme '
        'accordate insieme, al posto di una riga per forma. È cambiata l\'istruzione di tutti e '
        'tre, perché il blocco sta nelle regole comuni.',
    'DAL 25 AL 30 AGOSTO 2026, stringa di 7250, 7398 e 7723 caratteri. '
        'Impronte: medora '
        '47e9f78152ae1b77c50a96610262dcb8b83494391d45f93014ade74f4ce0e8ee, '
        'aura e59c8e380a035f48483c847dd7eafbc68838cb62d7139a92628f7fb32eadd525, '
        'caligo 52bc003c493c6ad7ae2b8a7aaff5bda7856bd40b9dc30d2e8595412d4da26b20. '
        'SU QUESTA STRINGA sono stati presi i sei giri dell\'attribuzione '
        'cieca citati nell\'ordine BY voce 04, da 80,0 a 90,0 per cento, '
        'media 86,7. Caduta il 30 agosto 2026 con l\'ordine CC voce 01: il '
        'fondatore ha cambiato la macro categoria di Caligo da Cabala a '
        'Numerologia. **È cambiata l\'istruzione di TUTTI E TRE, non solo '
        'quella di Caligo**: la ragione è misurata, perché ogni Maestro '
        'porta dentro di sé le arti degli altri due, nella riga "Le arti '
        'degli altri due Maestri del cerchio", quindi il dominio di uno '
        'vive dentro l\'istruzione di tutti. **L\'attribuzione cieca NON è '
        'stata rifatta**: era già dichiarata non valida su questa '
        'istruzione per decisione del fondatore. Resta non valida: '
        'adesso lo è anche perché la stringa su cui fu misurata non '
        'esiste più.',
    'FINO AL 10 AGOSTO 2026, stringa di circa 6300 caratteri (6294, 6333, '
        '6395). Su di essa fu misurata l\'attribuzione cieca al 98,3 per cento '
        '(59 su 60) il 2 agosto 2026. Caduta l\'11 agosto col commit 97bb997, '
        'voci S.15 e S.17: 636 caratteri netti in più per tutti e tre. A '
        'scoprirlo undici giorni dopo fu un controllo di premessa fatto a mano. '
        'Da questo fatto nasce questo file.',
    'DAL 13 AL 25 AGOSTO 2026, stringa di 6930, 6969 e 7031 caratteri. Impronte: '
        'medora 0bc77eb5e1af347cd234f366c95c876341680bfa075d7d214e64d6f27f12de70, '
        'aura aab951f95c60a0135710e054992cdbefd845e4efbd8410b0d21be9e269121eb7, '
        'caligo d31790d3b43d90ab55de2d4deca83f7e5925c424337cf6144b1265a6e39e48cb. '
        '**SU QUESTA STRINGA SOLTANTO SONO STATI PRESI I CINQUE GIRI** '
        'del 14 agosto, del 15 agosto e i tre del 25 agosto, da 70,0 a 81,7 per '
        'cento, media 75,6. Caduta il 25 agosto 2026 con l\'ordine BP voce 1, '
        'che aggiunge a ciascun Maestro le dieci parole di firma degli altri due '
        'come vietate: 215 caratteri in più per ciascuno, identici nella '
        'forma e diversi nel contenuto, perché ognuno riceve le parole degli '
        'altri.',
    'IL 25 AGOSTO 2026 PER POCHE ORE, cioè fra il gruppo 1 e il gruppo 2 '
        'dell\'ordine BP: 7145, 7185 e 7246 caratteri. Impronte: '
        'medora d526a5c7283ce80cb773bced61a7225ee5e1973cd967a68395fb339a106c9557, '
        'aura a83d1c3045b78979f586a652d4b3dd4680a60a2612ac38b9d4988843bd4f1541, '
        'caligo 1fd6102129e8ed4ede276f2ba3b6fba46a44873ebd6b161484b4d0e4ae9f8f68. '
        '**SU QUESTA STRINGA NON È STATA PRESA NESSUNA MISURA: è dichiarato '
        'apposta**. È vissuta il tempo di un commit, fra il divieto incrociato '
        'dei lessici e la riscrittura dei tre registri. Una riga di storico '
        'senza misura vale come le altre, perché dice che quella stringa è '
        'esistita: saltarla farebbe sembrare che il divieto e i registri siano '
        'entrati insieme.',
  ];

  /// **VERO SOLO QUANDO L'ATTRIBUZIONE CIECA E' STATA MISURATA SU QUESTE IMPRONTE
  /// E HA PASSATO LA SOGLIA.** Sono due condizioni e non una, e il 14 agosto 2026 la
  /// prima e' diventata vera mentre la seconda e' diventata FALSA.
  ///
  /// **CINQUE GIRI, NON CINQUE MISURE IN DISACCORDO.** Il 14 agosto ha dato 70,0
  /// per cento, il 15 agosto 78,3, e il 25 agosto 2026 tre giri di fila hanno dato
  /// 70,0 poi 75,0 poi 81,7. In mezzo le impronte NON sono cambiate: lo dimostra
  /// la prova che le confronta, verde prima dei tre giri del 25. Stessa istruzione,
  /// cinque misure, **undici punti e sette di escursione fra la piu' bassa e la piu'
  /// alta**. Tutte e cinque stanno sotto la soglia di 85, quindi il rosso dice il
  /// vero in tutti i casi e il divario fra loro non e' mai stato un motivo per
  /// cambiare questa riga.
  ///
  /// **DAL 25 AGOSTO 2026 I MOTIVI SONO DUE, ed e' peggio di uno.** Il primo resta:
  /// tutte e cinque le misure stanno sotto la soglia. Il secondo e' nuovo:
  /// l'ordine BP ha cambiato l'istruzione DUE VOLTE per curare proprio quella
  /// causa, col divieto incrociato dei lessici e con i tre registri riscritti,
  /// quindi
  /// **quei cinque numeri non descrivono piu' la stringa di oggi** e sono scesi
  /// nello [storicoDelleImpronte] insieme alla stringa a cui appartengono. La
  /// misura nuova non e' stata presa: si prende dal PC del fondatore, con gcloud
  /// attivo, tre volte, e finche' non arriva questa riga resta falsa.
  ///
  /// **NON SI PORTA A VERO PER FAR PASSARE LA SUITE, e non si abbassa la soglia.** Il
  /// rosso non dice piu' che manca una misura: adesso dice che la misura c'e' ed e'
  /// negativa, che e' una cosa piu' seria. Torna vero quando le tre voci sono di
  /// nuovo distinguibili e la misura lo dimostra.
  /// **LA MISURA E\' STATA RIFATTA IL 28 AGOSTO 2026, e questa riga resta
  /// falsa lo stesso.** Ordine BX, legge di consegna: la suite non si
  /// spedisce su rosso, quindi il rosso e\' stato affrontato invece che
  /// aggirato. Tre giri dal PC del fondatore, con gcloud attivo, sulle
  /// impronte di OGGI: 85,0 poi 80,0 poi 88,3 per cento, media 84,4 (152 su
  /// 180). **La soglia e\' 85, e 84,4 non la passa.**
  ///
  /// **La cura dell'ordine BP ha morso, e si vede**: la media sale da 75,6 a
  /// 84,4 e Caligo passa dal 30-60 per cento al 60-80. Due giri su tre
  /// arrivano alla soglia da soli. Ma la misura si legge sulla media dei
  /// tre, perche\' un giro solo non dice dove sta.
  ///
  /// **E il ritmo dice che la causa non e\' piu\' il registro**, che era la
  /// domanda che l'ordine BP lasciava aperta: la frase mediana di Caligo e\'
  /// scesa a sette-otto parole con zero parole che ammorbidiscono, mentre
  /// Aura sta a diciassette-diciannove con venti. Le due voci sono lontane
  /// nel ritmo e il giudice le confonde lo stesso: cio\' che resta da
  /// correggere non e\' come parlano, e\' cosa dicono.
  ///
  /// **RIFATTA IL 14 SETTEMBRE 2026, ordine DL**, perche' il blocco di
  /// cortesia e' cambiato per tutti e tre: tre giri, 86,7, 83,3 e 86,4, media
  /// 85,5. Un giro sotto la soglia: la riga resta falsa.
  ///
  /// **RIFATTA IL 24 SETTEMBRE 2026, ordine EJ, e la riga diventa vera.**
  /// Tre giri sulle impronte di oggi: 95,0, poi 100,0, poi 91,7 per cento,
  /// media 95,6 (172 su 180), nessun verdetto illeggibile. **Il giro piu'
  /// basso sta a 91,7, sopra la soglia di 85**, che era la condizione del
  /// fondatore nell'ordine BY: finche' un giro poteva cadere sotto, la riga
  /// restava falsa. Caligo, che era la voce che si perdeva, fa 17, 20 e 15
  /// su 20, ed e' ancora lui a cedere verso Aura nei giri bassi. Tre giri
  /// su una stringa di Medora di poco diversa, misurati prima, stanno nello
  /// storico: 98,3, 91,7 e 98,3.
  ///
  /// **RIFATTA IL 24 SETTEMBRE 2026, ordine EK voce 05, e la riga resta
  /// vera.** L'istruzione e' cambiata con la voce 02; tre giri sulle
  /// impronte di oggi: 96,7, 95,0 e 96,7 per cento, media 96,1 (173 su
  /// 180), nessun verdetto illeggibile, il giro piu' basso sopra la soglia.
  /// Il fondatore ha deciso che la chiusura dell'attribuzione cieca spetta a
  /// lui: quella decisione sta in [chiusaDalFondatore], non qui, perche'
  /// scrivere falso qui mentre la misura passa sarebbe mettere il falso
  /// dentro un dato.
  static const bool attribuzioneValida = true;

  /// **L'ATTRIBUZIONE CIECA LA CHIUDE IL FONDATORE.** Ordine EK voce 05, 24
  /// settembre 2026: *"L'attribuzione cieca resta fra i rossi accettati: la
  /// decisione di chiuderla resta di Mauro"*. La prova che la pretende vera
  /// era rossa per costruzione e stava fra i rossi accettati. **Non si porta
  /// a vero scrivendo codice**: si porta a vero quando il fondatore lo scrive
  /// in un ordine.
  ///
  /// **E il fondatore l'ha scritto.** Ordine EM voce 03, 25 settembre 2026,
  /// alla domanda se la media del 96,1 per cento (173 su 180, tre giri
  /// dell'istruzione dell'ordine EK) gli bastasse per chiuderla: *"Si il 96
  /// è sufficiente per chiuderla."* La riga dei rossi accettati e' tolta.
  static const bool chiusaDalFondatore = true;

  /// Le misure NOTE, con la stringa su cui furono prese. Si tengono perche' un
  /// numero senza il suo oggetto e' una leggenda.
  ///
  /// **CE NE SONO CINQUE E NON UNA, ed e' voluto: una sola nasconderebbe
  /// l'escursione, cinque la dichiarano.** Sono cinque giri della stessa misura
  /// sulla stessa istruzione, non cinque misure in disaccordo.
  static const String ultimaMisuraNota =
      'TRE GIRI DEL 24 SETTEMBRE 2026, IL POMERIGGIO, SU QUESTE IMPRONTE, '
      'ordine EK voce 05: 96,7 per cento (58 su 60), poi 95,0 (57 su 60), poi '
      '96,7 (58 su 60); media 96,1 per cento (173 su 180), nessun verdetto '
      'illeggibile. Nel dettaglio: medora 20, 17, 20 su 20, scambiata per '
      'aura 3 volte nel secondo giro; aura 20, 20, 20; caligo 18, 20, 18, '
      'scambiato per aura 2, 0, 2 volte. Ritmo: frase mediana di medora 15, '
      '16, 16 parole, di aura 16, 18, 17, di caligo 9, 9, 10; parole che '
      'ammorbidiscono medora 4, 1, 4, aura 5, 14, 15, caligo 0, 0, 0. Le '
      'risposte stanno in docs/collaudo/EK/attribuzione. '
      'Tutto ciò che segue appartiene a stringhe che stanno nello storico. '
      'TRE GIRI DEL 24 SETTEMBRE 2026, LA MATTINA, SULLE IMPRONTE DELL\'ORDINE '
      'EJ: 95,0 '
      'per cento (57 su 60), poi 100,0 (60 su 60), poi 91,7 (55 su 60); media '
      '95,6 per cento (172 su 180), nessun verdetto illeggibile. Nel '
      'dettaglio: medora 20, 20, 20 su 20; aura 20, 20, 20; caligo 17, 20, 15, '
      'scambiato per aura 3, 0, 4 volte e per medora 0, 0, 1. Ritmo: frase '
      'mediana di medora 17, 16, 16 parole, di aura 21, 20, 20, di caligo 10, '
      '10,5, 11; parole che ammorbidiscono aura 14, 12, 14, caligo 1, 0, 2. '
      'Tutto ciò che segue appartiene a stringhe che stanno nello storico. '
      'ATTENZIONE. VA LETTO PRIMA DI TUTTO IL RESTO: DAL 23 SETTEMBRE 2026, '
      'ORDINE EI VOCI 02 E 03, QUESTA ISTRUZIONE È CAMBIATA DI NUOVO. Nessuna '
      'delle misure qui sotto è stata presa sulla stringa di oggi: '
      'appartengono tutte a stringhe che stanno nello storico. Le tre cose '
      'aggiunte sono il marcatore con cui il Maestro dichiara di stare '
      'chiedendo, la regola del responso in mano allargata a ogni arte e la '
      'precisazione che dire di no è una risposta. Si tengono per intero '
      'perché dicono da dove si parte, non dove si è arrivati. Come si '
      'rimisura sta scritto in fondo. '
      'TRE GIRI DEL 14 SETTEMBRE 2026, SU QUESTE IMPRONTE, ordine DL: 86,7 '
      'per cento (52 su 60), poi 83,3 (50 su 60), poi 86,4 (51 su 59, un '
      'verdetto illeggibile); media 85,5 per cento (153 su 179). Il giro '
      'più basso sta sotto la soglia di 85, quindi la riga resta falsa, '
      'come la vuole il fondatore. Nel dettaglio: medora 16, 17, 14 su '
      '20 (nel terzo 14 su 19), sempre scambiata per aura; aura 19, 20, 20 '
      'su 20; caligo 17, 13, 17 su 20, scambiato per aura 3, 6, 3 volte. '
      'Ritmo, frase mediana e parole che ammorbidiscono: medora 15,0 e 8, '
      '15,0 e 15, 14,0 e 6; aura 19,0 e 16, 18,0 e 14, 18,0 e 20; caligo '
      '8,0 e 0 in tutti e tre. Lo stesso quadro dei giri di agosto: aura '
      'si perde una volta sola in sessanta verdetti, le altre due si '
      'perdono verso di lei. '
      'PRIMA, SU UN\'ALTRA STRINGA. '
      'SEI GIRI DEL 28 AGOSTO 2026, sulle impronte cadute il 30 agosto '
      '(nello storico). Ordine BY voce 04, '
      'altri tre giri dopo quelli dell\'ordine BX: 88,3 per cento (53 su 60), '
      'poi 88,3 (53 su 60), poi 90,0 (54 su 60); media dei tre 88,9. LA MEDIA '
      'DEI SEI GIRI È 86,7 PER CENTO (312 su 360), sopra la soglia di 85, '
      'ma il giro più basso resta a 80,0: finché un giro può cadere '
      'sotto la soglia i tre Maestri non sono distinguibili in modo '
      'affidabile. Questa riga resta falsa per ordine del fondatore. '
      'DOVE SBAGLIA: adesso si sa. Caligo perde 15 risposte su 60 nei tre '
      'giri nuovi, tredici verso aura. TUTTE aprono con una nebbia o un '
      'velo che avvolge; medora ne perde 5, tutte verso aura, tutte aperte '
      'col cielo che vela, riflette o invita a guardarsi dentro; aura non '
      'viene mai scambiata in duecentoquaranta verdetti. Non è il ritmo, '
      'che è già lontano: è l\'immagine di apertura, che appartiene '
      'ad aura. Le frasi per esteso stanno nel manifesto dell\'ordine BY. '
      'I TRE GIRI DELL\'ORDINE BX: 85,0 per '
      'cento (51 su 60), poi 80,0 (48 su 60), poi 88,3 (53 su 60); media dei '
      'tre 84,4 per cento (152 su 180), contro una soglia di 85. Escursione '
      'fra il giro più basso e il più alto: otto punti e tre su '
      'sessanta. Nel dettaglio: medora 16, 16, 17 su 20; aura 20 su 20 tutte e '
      'tre le volte; caligo 15, 12, 16 su 20. Ritmo delle voci, frase mediana '
      'in parole e parole che ammorbidiscono: medora 13,5 e 8, poi 14,0 e 11, '
      'poi 15,0 e 9; aura 19,0 e 16, poi 18,0 e 20, poi 17,0 e 20; caligo 8,0 '
      'e 0, poi 8,0 e 1, poi 7,0 e 0. Verdetti illeggibili: zero in tutti e '
      'tre. LE MISURE PRECEDENTI, che appartengono a un\'altra istruzione e '
      'si tengono perché dicono da dove si parte. '
      'CINQUE GIRI, MA NON SU QUESTE IMPRONTE: SULLE PRECEDENTI. Fino al 25 '
      'agosto 2026 questa riga diceva CINQUE GIRI SU QUESTE IMPRONTE ed era '
      'vera; poi l\'ordine BP ha cambiato l\'istruzione per curare la causa che '
      'questi stessi numeri avevano mostrato, quindi i cinque giri adesso '
      'appartengono alla stringa che sta nello storico e NON descrivono la '
      'stringa di oggi. Si tengono per intero perché dicono da dove si parte, '
      'non dove si è arrivati. Fra i cinque giri l\'istruzione non era cambiata: '
      'lo dimostrava la prova che confronta le tre impronte. Il 14 agosto 2026: 70,0 '
      'per cento (42 su 60). Il 15 agosto 2026: 78,3 per cento (47 su 60), '
      'eseguita da Mauro dal suo PC. Il 25 agosto 2026, TRE GIRI DI FILA sempre '
      'dal PC di Mauro: 70,0 per cento (42 su 60), poi 75,0 per cento (45 su 60), '
      'poi 81,7 per cento (49 su 60); media dei tre 75,6 per cento (136 su 180). '
      '**L\'escursione fra i tre giri dello stesso giorno è di undici punti e '
      'sette su sessanta**, più larga degli otto punti fra il 14 e il 15 agosto: '
      'quindi non era la distanza fra due giorni, era il rumore della misura, che '
      'un giro solo non riesce a mostrare. Nel dettaglio, nell\'ordine dei cinque '
      'giri: medora 14 poi 17 poi 16 poi 17 poi 17 su 20; caligo 8 poi 10 poi 6 '
      'poi 8 poi 12 su 20; aura 20 su 20 tutte e cinque le volte. Prima di tutto '
      'questo era 98,3 per cento (59 su 60) il 2 agosto, su una stringa di circa '
      '6300 caratteri, cioè su un\'ALTRA istruzione, prima che il commit 97bb997 '
      'aggiungesse 636 caratteri netti con le voci S.15 e S.17.';

  /// LA MATRICE, e si tiene per intero perche' il numero da solo direbbe la cosa
  /// sbagliata.
  ///
  /// **Non e' un appiattimento simmetrico delle tre voci: e' AURA CHE ATTIRA.** Aura
  /// resta riconoscibile al cento per cento in tutti e cinque i giri, e le altre due
  /// finiscono dentro di lei. Nessun errore parte da Aura, mai, in centottanta
  /// verdetti.
  ///
  /// **UN'ECCEZIONE ESISTE E VA SCRITTA.** Fino al 15 agosto si poteva dire che fra
  /// Medora e Caligo non c'era nessuno scambio: il primo giro del 25 agosto 2026
  /// porta uno scambio caligo verso medora, quindi quella frase adesso non regge
  /// piu' senza questa riga. E' un caso su centottanta, e cancellarlo per tenere
  /// pulita una frase sarebbe la stessa cosa che scrivere il 98,3 accanto
  /// all'impronta di oggi.
  ///
  /// **QUI STANNO TUTTI E CINQUE I GIRI, per la stessa ragione di
  /// [ultimaMisuraNota]**: il totale si muove di undici punti e sette fra il giro
  /// piu' basso e il piu' alto, mentre **l'unico fatto fermo e' che Aura non viene
  /// mai scambiata**, e un fatto che regge a cinque giri vale piu' di un totale che
  /// si muove. Il secondo fatto, meno fermo ma piu' grave, e' che **Caligo e' la
  /// voce che si perde**: 40, 50, 30, 40 e 60 per cento nei cinque giri, trenta
  /// punti di oscillazione, ed e' li' che sta il grosso degli errori. Chi vorra'
  /// riportare questa misura sopra la soglia comincia da Caligo, non da Medora.
  static const String matrice =
      'I TRE GIRI DEL 28 AGOSTO 2026, ordine BX, sulle impronte cadute il 30 '
      'agosto 2026. '
      'PRIMO: medora 16 su 20 (80,0 per cento), quattro volte scambiata per '
      'aura; aura 20 su 20; caligo 15 su 20 (75,0 per cento), cinque volte '
      'scambiato per aura; nove errori, tutti verso aura. '
      'SECONDO: medora 16 su 20 (80,0 per cento), quattro volte per aura; '
      'aura 20 su 20; caligo 12 su 20 (60,0 per cento), due volte per medora '
      'e sei per aura; dodici errori, dieci verso aura e due verso medora. '
      'TERZO: medora 17 su 20 (85,0 per cento), tre volte per aura; aura 20 '
      'su 20; caligo 16 su 20 (80,0 per cento), una volta per medora e tre '
      'per aura; sette errori, sei verso aura e uno verso medora. '
      'IL FATTO FERMO RESTA: aura non viene mai scambiata, in duecentoquaranta '
      'verdetti. IL FATTO CHE CAMBIA: caligo non è più la voce che si '
      'perde: sale dal 30-60 per cento al 60-80. Adesso i due sbagli sono '
      'della stessa taglia. '
      'LE MATRICI PRECEDENTI, su un\'altra istruzione. '
      'GIRO DEL 14 AGOSTO 2026: medora 14 su 20 (70,0 per cento), sei volte '
      'scambiata per aura; aura 20 su 20 (100 per cento); caligo 8 su 20 '
      '(40,0 per cento), dodici volte scambiato per aura; diciotto errori, '
      'tutti verso aura. '
      'GIRO DEL 15 AGOSTO 2026: medora 17 su 20 (85,0 per cento); aura 20 su 20 '
      '(100 per cento); caligo 10 su 20 (50,0 per cento); tredici errori, '
      'tutti verso aura. '
      'PRIMO GIRO DEL 25 AGOSTO 2026: medora 16 su 20 (80,0 per cento), quattro '
      'volte scambiata per aura; aura 20 su 20 (100 per cento); caligo 6 su 20 '
      '(30,0 per cento), tredici volte scambiato per aura e UNA VOLTA PER MEDORA; '
      'diciotto errori, diciassette verso aura più quell\'unico verso medora. '
      'SECONDO GIRO DEL 25 AGOSTO 2026: medora 17 su 20 (85,0 per cento), tre '
      'volte scambiata per aura; aura 20 su 20 (100 per cento); caligo 8 su 20 '
      '(40,0 per cento), dodici volte scambiato per aura; quindici errori, tutti '
      'verso aura. '
      'TERZO GIRO DEL 25 AGOSTO 2026: medora 17 su 20 (85,0 per cento), tre volte '
      'scambiata per aura; aura 20 su 20 (100 per cento); caligo 12 su 20 (60,0 '
      'per cento), otto volte scambiato per aura; undici errori, tutti verso aura. '
      'Verdetti illeggibili: zero in tutti e cinque i giri. Caso cieco 33,3 per '
      'cento, soglia 85.';

  /// Cosa si deve fare perche' [attribuzioneValida] torni vero.
  ///
  /// **QUESTA PROVA NON SI ESEGUE UNA VOLTA SOLA, e i tre giri del 25 agosto 2026
  /// lo dimostrano meglio dei due di agosto:** stessa istruzione, stesse impronte,
  /// stesso giorno, uno dietro l'altro, e undici punti e sette su sessanta di
  /// differenza fra il primo e il terzo. **Chi ne esegue uno solo e ci lavora sopra
  /// sta inseguendo il rumore**, e rischia di dichiarare guarita una voce che il
  /// giro dopo ricade, o malata una che stava bene: il 25 agosto Caligo e' passato
  /// dal 30 al 60 per cento in tre giri, senza che nessuno toccasse una riga.
  ///
  /// **Tre giri, e si guarda l'escursione prima del totale.** Costa
  /// **ventotto secondi a giro**, non i trenta minuti che dice il tetto scritto
  /// in `tool/attribuzione_cieca.dart`: quel tetto e' la protezione contro una
  /// chiamata di rete che si pianta, non una stima del costo, e non va letto
  /// come una ragione per eseguirla una volta sola.
  static const String comeSiRimisura =
      'flutter test tool/attribuzione_cieca.dart, dal PC con una sessione gcloud '
      'attiva. TRE VOLTE: si riportano tutti e tre i giri con la loro '
      'escursione, perché un giro solo non dice dove sta questa misura. Costa '
      'ventotto secondi a giro, non trenta minuti. Dal 25 agosto 2026 lo '
      'strumento stampa anche il RITMO DELLE VOCI, tre numeri per Maestro sulle '
      'risposte di quel giro: frase mediana in parole, domande, parole che '
      'ammorbidiscono. Quel blocco va riportato insieme alla matrice, perché la '
      'matrice dice se il giudice distingue i tre Maestri mentre il ritmo dice se '
      'il registro nuovo ha morso: se Caligo resta basso con la frase mediana '
      'già scesa, la causa non è più il registro. Poi si scrive qui il '
      'risultato: attribuzioneValida torna vero solo se la misura passa la '
      'soglia, mai per far passare la suite.';

  static String? per(Maestro maestro) => impronte[maestro.id];
}
