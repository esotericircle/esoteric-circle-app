import '../astro/zodiac.dart';

/// I TESTI DELLA SINASTRIA VIP, revisione B. Ordine CA voce 04.
///
/// **Questo file NON e' scritto a mano: nasce da**
/// `docs/corpus/sinastria_testi.md`, che e' la fonte, e
/// `test/il_corpus_della_sinastria_test.dart` rilegge quel documento e
/// pretende che ogni riga di qui sia la sua. Un corpus e una copia che
/// divergono sono due corpus, e il giorno che divergono nessuno se ne
/// accorge leggendo il codice.
///
/// **La regola che governa ogni riga**, dal documento: nessun testo dell'app
/// afferma qualcosa sulla vita privata di una persona reale. Niente
/// sentimenti, relazioni, salute, denaro, guai. L'esagerazione vive su due
/// cose che non si possono querelare: la relazione fra i due segni, e cio'
/// che il personaggio fa in pubblico come professionista.
class TestiDellaSinastria {
  const TestiDellaSinastria._();

  /// Le sette relazioni fra i segni, come il documento le nomina.
  static RelazioneFraSegni relazione(Zodiac a, Zodiac b) {
    if (a == b) return RelazioneFraSegni.stesso;
    final ea = _elemento(a);
    final eb = _elemento(b);
    if (ea == eb) return RelazioneFraSegni.elemento;
    final distanza = ((a.index - b.index).abs()) % 12;
    if (distanza == 6) return RelazioneFraSegni.opposti;
    const fuoco = _Elemento.fuoco;
    const aria = _Elemento.aria;
    const terra = _Elemento.terra;
    const acqua = _Elemento.acqua;
    if ((ea == fuoco && eb == aria) || (ea == aria && eb == fuoco)) {
      return RelazioneFraSegni.fuocoaria;
    }
    if ((ea == terra && eb == acqua) || (ea == acqua && eb == terra)) {
      return RelazioneFraSegni.terracqua;
    }
    // Fuoco con acqua e terra con aria: elementi che si sfidano.
    if ((ea == fuoco && eb == acqua) ||
        (ea == acqua && eb == fuoco) ||
        (ea == terra && eb == aria) ||
        (ea == aria && eb == terra)) {
      return RelazioneFraSegni.tensione;
    }
    return RelazioneFraSegni.estranei;
  }

  static _Elemento _elemento(Zodiac z) {
    switch (z) {
      case Zodiac.aries:
      case Zodiac.leo:
      case Zodiac.sagittarius:
        return _Elemento.fuoco;
      case Zodiac.taurus:
      case Zodiac.virgo:
      case Zodiac.capricorn:
        return _Elemento.terra;
      case Zodiac.gemini:
      case Zodiac.libra:
      case Zodiac.aquarius:
        return _Elemento.aria;
      case Zodiac.cancer:
      case Zodiac.scorpio:
      case Zodiac.pisces:
        return _Elemento.acqua;
    }
  }

  /// Le cinque fasce di affinita', dal documento: 90, 75, 60, 45.
  static FasciaDiAffinita fascia(int percento) {
    if (percento >= 90) return FasciaDiAffinita.leggendaria;
    if (percento >= 75) return FasciaDiAffinita.alta;
    if (percento >= 60) return FasciaDiAffinita.buona;
    if (percento >= 45) return FasciaDiAffinita.curiosa;
    return FasciaDiAffinita.attrito;
  }

  /// Le trentacinque frasi SOPRA il cerchio: una riga sola, la prima che si
  /// legge. Sostituisce l'etichetta fissa che stava dentro il cerchio e che si
  /// ripeteva perche' dipendeva dalla sola fascia.
  static const Map<RelazioneFraSegni, Map<FasciaDiAffinita, String>> sopraIlCerchio =
      <RelazioneFraSegni, Map<FasciaDiAffinita, String>>{
    RelazioneFraSegni.stesso: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Siete la stessa persona in due corpi. Che paura.',
      FasciaDiAffinita.alta: 'Stesso segno, stessi difetti, stessa faccia tosta.',
      FasciaDiAffinita.buona: 'Vi capireste anche al buio, e infatti spesso lo fate.',
      FasciaDiAffinita.curiosa: 'Uguali sì, ma non è detto che sia un complimento.',
      FasciaDiAffinita.attrito: 'Due copie dello stesso originale non fanno una coppia.',
    },
    RelazioneFraSegni.elemento: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Stessa materia, stessa fiamma, stessa follia.',
      FasciaDiAffinita.alta: 'Parlate la stessa lingua senza aver mai preso lezioni.',
      FasciaDiAffinita.buona: 'Vi riconoscete a distanza, come fa la gente della stessa razza.',
      FasciaDiAffinita.curiosa: 'Stessa sostanza, forme diverse: vi somigliate a giorni alterni.',
      FasciaDiAffinita.attrito: 'Anche l\'acqua e il ghiaccio sono la stessa cosa, e non vanno d\'accordo.',
    },
    RelazioneFraSegni.fuocoaria: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Uno accende, l\'altra soffia. È così che nascono gli incendi.',
      FasciaDiAffinita.alta: 'Insieme fareste saltare la corrente a mezzo quartiere.',
      FasciaDiAffinita.buona: 'Vi date fuoco a vicenda, ma nel senso bello.',
      FasciaDiAffinita.curiosa: 'C\'è aria per bruciare, manca solo qualcuno che accenda.',
      FasciaDiAffinita.attrito: 'Troppo vento spegne anche il fuoco più deciso.',
    },
    RelazioneFraSegni.terracqua: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Una terra così e un\'acqua così fanno nascere qualsiasi cosa.',
      FasciaDiAffinita.alta: 'Uno tiene, l\'altra nutre: si chiama fortuna.',
      FasciaDiAffinita.buona: 'Un\'intesa che non fa rumore e regge il peso.',
      FasciaDiAffinita.curiosa: 'Terreno buono, pioggia incerta: vediamo che raccolto viene.',
      FasciaDiAffinita.attrito: 'Troppa acqua su troppa terra fa solo fango.',
    },
    RelazioneFraSegni.opposti: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Agli antipodi dello zodiaco e non riuscite a smettere di guardarvi.',
      FasciaDiAffinita.alta: 'Il contrario esatto di te ti sta guardando. Buona fortuna.',
      FasciaDiAffinita.buona: 'L\'attrazione dei contrari, quella che nessuno sa spiegare.',
      FasciaDiAffinita.curiosa: 'Opposti abbastanza da incuriosirvi, non abbastanza da capirvi.',
      FasciaDiAffinita.attrito: 'Vi guardate dai due capi del tavolo, e il tavolo è lungo.',
    },
    RelazioneFraSegni.tensione: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Una tensione così alta di solito finisce sui giornali.',
      FasciaDiAffinita.alta: 'Chimica pura e nessuna via d\'uscita: complimenti.',
      FasciaDiAffinita.buona: 'Vi sfidate, e la cosa vi diverte più di quanto ammettiate.',
      FasciaDiAffinita.curiosa: 'Scintille sì, incendio non pervenuto.',
      FasciaDiAffinita.attrito: 'Due elementi che si annullano a vicenda, con garbo.',
    },
    RelazioneFraSegni.estranei: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Non avete niente in comune e vi trovate benissimo. Spiegatelo voi.',
      FasciaDiAffinita.alta: 'Due mondi diversi che hanno deciso di piacersi lo stesso.',
      FasciaDiAffinita.buona: 'Curiosi l\'uno dell\'altro, che è già più di quanto capiti di solito.',
      FasciaDiAffinita.curiosa: 'Vi guardate come si guarda una lingua straniera.',
      FasciaDiAffinita.attrito: 'Due mondi diversi, e i visti non si sono trovati.',
    },
  };

  /// I trentacinque titoli della bolla: poche parole, da titolo di giornale.
  static const Map<RelazioneFraSegni, Map<FasciaDiAffinita, String>> titoliDellaBolla =
      <RelazioneFraSegni, Map<FasciaDiAffinita, String>>{
    RelazioneFraSegni.stesso: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Lo specchio perfetto',
      FasciaDiAffinita.alta: 'Due gocce d\'acqua, e una tempesta',
      FasciaDiAffinita.buona: 'Conosco già tutti i tuoi trucchi',
      FasciaDiAffinita.curiosa: 'Troppo simili per stupirsi',
      FasciaDiAffinita.attrito: 'Il difetto in doppia copia',
    },
    RelazioneFraSegni.elemento: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Stessa materia, stesso destino',
      FasciaDiAffinita.alta: 'Nati dalla stessa scintilla',
      FasciaDiAffinita.buona: 'Ci si riconosce tra simili',
      FasciaDiAffinita.curiosa: 'Parenti alla lontana',
      FasciaDiAffinita.attrito: 'Stessa origine, strade opposte',
    },
    RelazioneFraSegni.fuocoaria: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'L\'incendio annunciato',
      FasciaDiAffinita.alta: 'Benzina e fiammiferi',
      FasciaDiAffinita.buona: 'Chi accende e chi soffia',
      FasciaDiAffinita.curiosa: 'Manca solo la scintilla',
      FasciaDiAffinita.attrito: 'Troppo vento per una fiamma sola',
    },
    RelazioneFraSegni.terracqua: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Tutto quello che tocca fiorisce',
      FasciaDiAffinita.alta: 'Radici e pioggia',
      FasciaDiAffinita.buona: 'L\'intesa che non fa rumore',
      FasciaDiAffinita.curiosa: 'Un raccolto da vedere',
      FasciaDiAffinita.attrito: 'Fango, per ora',
    },
    RelazioneFraSegni.opposti: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Il disastro perfetto',
      FasciaDiAffinita.alta: 'Il tuo contrario esatto',
      FasciaDiAffinita.buona: 'L\'attrazione che nessuno spiega',
      FasciaDiAffinita.curiosa: 'Vicini di zodiaco, lontani di testa',
      FasciaDiAffinita.attrito: 'Ai due capi del tavolo',
    },
    RelazioneFraSegni.tensione: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Roba da prima pagina',
      FasciaDiAffinita.alta: 'Chimica pericolosa',
      FasciaDiAffinita.buona: 'La sfida che vi diverte',
      FasciaDiAffinita.curiosa: 'Scintille senza incendio',
      FasciaDiAffinita.attrito: 'Si annullano con eleganza',
    },
    RelazioneFraSegni.estranei: <FasciaDiAffinita, String>{
      FasciaDiAffinita.leggendaria: 'Nessuno lo capisce, funziona',
      FasciaDiAffinita.alta: 'Due mondi che hanno deciso',
      FasciaDiAffinita.buona: 'Curiosità reciproca',
      FasciaDiAffinita.curiosa: 'Una lingua straniera',
      FasciaDiAffinita.attrito: 'Visti non concessi',
    },
  };

  /// Le tre aperture per relazione. SEGNO_A e SEGNO_B sono i due segni.
  static const Map<RelazioneFraSegni, List<String>> aperture =
      <RelazioneFraSegni, List<String>>{
    RelazioneFraSegni.stesso: <String>[
      'Due SEGNO_A nella stessa stanza sono uno spettacolo o un disastro, e non c\'è mai una terza possibilità.',
      'Sei un SEGNO_A e hai davanti un altro SEGNO_A: sai già come va a finire, ed è questo il problema.',
      'Stesso segno vuol dire stesse virtù, ma soprattutto stessi vizi, e i vizi in doppia copia si notano.',
    ],
    RelazioneFraSegni.elemento: <String>[
      'SEGNO_A e SEGNO_B sono fatti della stessa materia, e la materia si riconosce da lontano.',
      'Stesso elemento, forme diverse: vi capite prima di parlare, il che vi risparmia parecchie discussioni.',
      'Fra un SEGNO_A e un SEGNO_B non serve spiegarsi: serve semmai decidere chi comanda.',
    ],
    RelazioneFraSegni.fuocoaria: <String>[
      'Il fuoco di SEGNO_A e l\'aria di SEGNO_B: uno accende, l\'altra alimenta, e nessuno dei due sa dove finisce.',
      'Mettere insieme SEGNO_A e SEGNO_B è come lasciare una finestra aperta accanto a un camino acceso.',
      'SEGNO_A brucia, SEGNO_B soffia: la fisica è dalla vostra parte, la prudenza molto meno.',
    ],
    RelazioneFraSegni.terracqua: <String>[
      'La terra di SEGNO_A e l\'acqua di SEGNO_B fanno la cosa più rara dello zodiaco: qualcosa che dura.',
      'SEGNO_A tiene, SEGNO_B nutre: non è romantico da raccontare, ma è quello che regge quando il resto crolla.',
      'Fra SEGNO_A e SEGNO_B non ci sono fuochi d\'artificio, c\'è un raccolto.',
    ],
    RelazioneFraSegni.opposti: <String>[
      'SEGNO_A e SEGNO_B stanno ai due capi opposti del cerchio, il che significa che avete lo stesso identico problema visto da due lati.',
      'Un SEGNO_A e un SEGNO_B sono la stessa medaglia girata: per questo vi attraete e per questo vi date sui nervi.',
      'Nello zodiaco SEGNO_A e SEGNO_B si guardano da lontano, e non riescono a smettere.',
    ],
    RelazioneFraSegni.tensione: <String>[
      'SEGNO_A e SEGNO_B appartengono a elementi che non si sono mai piaciuti, e le storie migliori nascono così.',
      'Fra SEGNO_A e SEGNO_B c\'è attrito, e l\'attrito è l\'unica cosa che produce calore.',
      'SEGNO_A e SEGNO_B si sfidano per natura: la domanda non è se litigherete, è quanto vi divertirete.',
    ],
    RelazioneFraSegni.estranei: <String>[
      'SEGNO_A e SEGNO_B non hanno quasi niente in comune, e questo li rende reciprocamente inspiegabili.',
      'Fra un SEGNO_A e un SEGNO_B non c\'è una lingua comune: si comincia imparandola.',
      'SEGNO_A e SEGNO_B vengono da due mondi che non si erano mai parlati prima di adesso.',
    ],
  };

  /// Il cielo reso leggibile: prima cosa significa, poi come si chiama.
  static const Map<String, String> cieloLeggibile = <String, String>{
    'Venere congiunzione Venere': 'Vi piacciono le stesse cose, il che è comodo e pericoloso insieme.',
    'Venere opposizione Venere': 'Vi piacciono cose opposte, e nessuno dei due ha intenzione di cedere.',
    'Venere trigono Venere': 'Avete lo stesso gusto senza esservi messi d\'accordo.',
    'Venere sestile Mercurio': 'Uno parla e l\'altro trova affascinante il modo in cui lo dice.',
    'Sole opposizione Venere': 'Lui è esattamente il tipo che non dovresti trovare interessante.',
    'Venere quadrato Marte': 'Vi attirate e vi irritate nello stesso istante, ed è quello il punto.',
    'Luna congiunzione Luna': 'Reagite alle cose nello stesso modo, spesso nello stesso momento.',
    'Marte sestile Luna': 'Uno si muove e l\'altro lo sente prima che accada.',
    'Luna opposizione Sole': 'Uno illumina, l\'altro assorbe: funziona finché nessuno pretende il contrario.',
    'Luna quadrato Mercurio': 'Uno sente, l\'altro spiega, e non si trovano mai sulla stessa frase.',
    'Marte congiunzione Marte': 'Stessa energia, stessa fretta, stesso muro contro cui andare.',
    'Marte sestile Ascendente': 'Uno entra in una stanza e l\'altro se ne accorge subito.',
    'Marte trigono Sole': 'Uno spinge e l\'altro non si tira indietro.',
    'Mercurio congiunzione Sole': 'Pensa a voce alta e voi lo capite al primo tentativo.',
    'Mercurio trigono Mercurio': 'Due teste che corrono alla stessa velocità, e si annoiano insieme del resto del mondo.',
    'Mercurio quadrato Saturno': 'Uno propone, l\'altro obietta, e alla fine hanno ragione entrambi.',
  };

  /// La riga generica del pianeta piu' lento, quando la combinazione non ha
  /// una riga sua. Non si inventa nulla.
  static const Map<String, String> genericoPerPianeta = <String, String>{
    'Sole': 'C\'è qualcosa nel suo modo di stare al mondo che non ti lascia indifferente.',
    'Luna': 'Vi toccate un nervo scoperto, e non sempre nello stesso modo.',
    'Mercurio': 'Il modo in cui pensate si incrocia più di quanto sembri.',
    'Venere': 'Sul bello e sul piacere avete parecchio da dirvi.',
    'Marte': 'Quando si tratta di agire, vi accorgete l\'uno dell\'altro.',
    'Saturno': 'C\'è un peso in mezzo, e i pesi tengono insieme più di quanto separino.',
  };

  /// Le cinquanta presentazioni: la carta d'identita' pubblica, che non
  /// scade mai. La chiave e' lo stem del ritratto.
  static const Map<String, String> presentazioni = <String, String>{
    'vip_angelina-jolie': 'divide la vita fra un set e mezzo mondo da salvare.',
    'vip_ariana-grande': 'arriva a note che il resto dell\'umanità nemmeno immagina.',
    'vip_bad-bunny': 'riempie gli stadi cantando in spagnolo e non ha mai chiesto permesso.',
    'vip_beyonce': 'quando entra lei, le altre luci si spengono da sole.',
    'vip_bill-gates': 'ha riscritto il mondo partendo da un garage, e adesso prova a ripararlo.',
    'vip_billie-eilish': 'sussurra, e la ascoltano in milioni.',
    'vip_brad-pitt': 'invecchia meglio del vino e lo sa benissimo.',
    'vip_chiara-ferragni': 'di un post ha saputo fare un impero.',
    'vip_damiano-david': 'sul palco perde la camicia ma mai il ritmo.',
    'vip_dicaprio': 'colleziona Oscar e tramonti, in quest\'ordine.',
    'vip_drake': 'trasforma ogni dispiacere in un disco di platino.',
    'vip_dwayne-johnson': 'solleva più peso del tuo intero condominio.',
    'vip_elon-musk': 'twitta a mezzanotte e sposta i mercati.',
    'vip_emma-watson': 'dai libri di magia è passata a quelli veri.',
    'vip_federer': 'perdeva con eleganza anche quando vinceva.',
    'vip_fedez': 'fa notizia più di un telegiornale, e con meno sforzo.',
    'vip_giorgio-armani': 'ha vestito il mondo di grigio elegante.',
    'vip_jeff-bezos': 'ti consegna tutto tranne il suo tempo libero.',
    'vip_kanye-west': 'una ne fa e cento ne pensa, e le pensa ad alta voce.',
    'vip_keanu-reeves': 'resta gentile pure mentre salva il mondo.',
    'vip_kim-kardashian': 'della propria vita ha fatto un impero quotato.',
    'vip_kylie-jenner': 'a vent\'anni contava già i miliardi.',
    'vip_lady-gaga': 'cambia faccia a ogni canzone ma non cambia mai voce.',
    'vip_lebron-james': 'a quarant\'anni vola ancora, e la cosa comincia a innervosire.',
    'vip_margot-robbie': 'ha reso una bambola un fenomeno mondiale.',
    'vip_mark-zuckerberg': 'sa tutto di te ma non risponde ai messaggi.',
    'vip_mbappe': 'corre più veloce del tuo wifi.',
    'vip_messi': 'parla poco e segna sempre, che è il modo migliore di rispondere.',
    'vip_michelle-obama': 'ha rimesso di moda l\'intelligenza.',
    'vip_monica-bellucci': 'il tempo lo guarda passare senza farsi toccare.',
    'vip_nadal': 'non molla un punto nemmeno per sbaglio.',
    'vip_oprah-winfrey': 'regala macchine e cambia vite, spesso nello stesso pomeriggio.',
    'vip_priyanka-chopra': 'ha conquistato due continenti senza chiedere il permesso a nessuno.',
    'vip_rihanna': 'tra un disco e l\'altro ti ha pure venduto il fondotinta.',
    'vip_ronaldo': 'si allena mentre tu dormi, e te lo fa sapere.',
    'vip_scarlett-johansson': 'ha dato la voce persino ai robot.',
    'vip_selena-gomez': 'sopravvive a Hollywood col sorriso, che è la cosa più difficile.',
    'vip_serena-williams': 'serve più forte di quanto tu discuta.',
    'vip_shakira': 'con i fianchi non sa mentire, con il resto nemmeno.',
    'vip_sinner': 'resta di ghiaccio anche quando il campo prende fuoco.',
    'vip_snoop-dogg': 'se la prende comoda da trent\'anni e non ha mai avuto fretta.',
    'vip_steve-jobs': 'ha messo il futuro nella tasca di tutti.',
    'vip_taylor-swift': 'se la lasci ci scrive un album, e vende tutto.',
    'vip_the-weeknd': 'canta le notti che tu dimentichi.',
    'vip_timothee-chalamet': 'fa sospirare due generazioni contemporaneamente.',
    'vip_tom-cruise': 'gli stunt se li fa da solo, e a una certa età è quasi un dispetto.',
    'vip_usain-bolt': 'ha corso piano solo per salutare.',
    'vip_valentino-rossi': 'in curva piega più di te sotto le scadenze.',
    'vip_warren-buffett': 'a colazione compra aziende.',
    'vip_zendaya': 'a ogni tappeto rosso manda in tilt internet.',
  };

  /// Le tre giunture con cui l'attualita' entra nella presentazione.
  static const List<String> giunture = <String>[
    'NOME, che PRESENTAZIONE, e che in questi mesi FATTO.',
    'NOME PRESENTAZIONE. Di questi tempi, poi, FATTO.',
    'Aggiungi che NOME FATTO, e capisci con chi hai a che fare.',
  ];

  /// Le cinque stoccate per fascia: l'ultima frase della bolla.
  static const Map<FasciaDiAffinita, List<String>> stoccate =
      <FasciaDiAffinita, List<String>>{
    FasciaDiAffinita.leggendaria: <String>[
      'Un cielo così non capita a tutti. Fanne buon uso, o almeno raccontalo bene.',
      'Se credi ai numeri, questo è di quelli che non si spiegano.',
      'Percentuali così alte di solito le vede solo chi bara.',
      'Il cosmo ha fatto la sua parte. Il resto, come sempre, è un altro discorso.',
      'Tienitelo stretto questo risultato: non ne arrivano molti.',
    ],
    FasciaDiAffinita.alta: <String>[
      'Il cielo dice di sì con una certa convinzione.',
      'Su carta funzionereste benissimo. La carta, si sa, sopporta tutto.',
      'Un\'intesa così andrebbe sprecata a non usarla.',
      'Le stelle hanno votato compatte, per una volta.',
      'C\'è più di quanto ti aspettassi, ammettilo.',
    ],
    FasciaDiAffinita.buona: <String>[
      'Non male, considerando che uno dei due non sa nemmeno che esisti.',
      'Ci sono le basi. Manca solo tutto il resto.',
      'Il cielo dice che potreste andare d\'accordo. Il cielo è ottimista di natura.',
      'Abbastanza per una bella serata, forse anche per due.',
      'Un buon risultato, di quelli che non si vantano ma tengono.',
    ],
    FasciaDiAffinita.curiosa: <String>[
      'Il cielo non si sbilancia, e fa bene.',
      'Né un sì né un no: il cosmo prende tempo.',
      'Abbastanza per incuriosirsi, non abbastanza per fare progetti.',
      'Una di quelle percentuali che dipendono più da voi che dalle stelle.',
      'Il cielo lascia la porta socchiusa, e vediamo chi la spinge.',
    ],
    FasciaDiAffinita.attrito: <String>[
      'Il cielo è stato chiaro, e non è colpa nostra.',
      'Su questo, francamente, le stelle hanno delle riserve.',
      'Poche percentuali, ma le storie migliori nascono così, dicono.',
      'Il cosmo dice di no. Il cosmo però ha sbagliato altre volte.',
      'Numeri bassi, ma nessuno ha mai chiesto il permesso allo zodiaco.',
    ],
  };

  /// Le tre chiusure per chi non c'e' piu'. Nessuna ironia sulla morte.
  static const List<String> memoria = <String>[
    'Un cielo che continua a dire la sua, anche adesso.',
    'I cieli restano, anche quando le persone se ne vanno.',
    'Certe carte del cielo non smettono di parlare.',
  ];

  /// La nota fuori dalla bolla, in corpo minore.
  static const String notaOraIgnota = 'Del suo cielo non si conosce l\'ora esatta di nascita: questa lettura guarda i pianeti, non l\'Ascendente. Non si finge di sapere ciò che nessuna fonte dichiara.';
  static const String notaLuogoIgnoto = 'Dove viva non è cosa pubblica, quindi la distanza non entra nel conto.';
  static const String notaAttualita = 'Le notizie su questa persona sono aggiornate al GIORNO.';

  /// Le cinque sfide da condividere. NOME e PERCENTO si sostituiscono.
  static const List<String> sfide = <String>[
    'E tu con NOME quanto fai? Sfida i tuoi amici.',
    'PERCENTO con NOME. Scommetti che il tuo amico fa peggio?',
    'Manda questa a chi giura di essere l\'anima gemella di NOME.',
    'Chi dei tuoi amici batte PERCENTO con NOME? Scoprilo.',
    'NOME e te, PERCENTO. Vediamo chi fa meglio nel tuo giro.',
  ];
}

/// Le sette relazioni fra due segni, dal documento del corpus.
enum RelazioneFraSegni {
  stesso,
  elemento,
  fuocoaria,
  terracqua,
  opposti,
  tensione,
  estranei
}

/// Le cinque fasce di affinita', dal documento del corpus.
enum FasciaDiAffinita { leggendaria, alta, buona, curiosa, attrito }

enum _Elemento { fuoco, terra, aria, acqua }
