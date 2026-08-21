import '../astro/moon_phase.dart';
import '../astro/zodiac.dart';
import 'rune_cast.dart' show RuneVerso;
import 'sunset_rune.dart';

/// Le due voci di una runa in un verso: cosa lasci fuori e cosa porti dentro.
class VoceRuna {
  const VoceRuna(this.lasciare, this.porta);

  /// Voce A, "Cosa lasci fuori": l'atto di posare qualcosa sulla soglia.
  final String lasciare;

  /// Voce B, "Cosa porti dentro la notte": l'atto di portare dentro.
  final String porta;
}

/// Il corpus della Runa del Tramonto, nella voce di Caligo, custode delle
/// soglie. Le righe sono coerenti coi campi upright e shadow di runes.dart, che
/// restano la fonte semantica: qui il significato diventa gesto di soglia, cosa
/// lasciare fuori e cosa portare nella notte. Nessuna riga è variante
/// stilistica di un'altra. Deterministico, offline, nessuna AI.
class SunsetRuneCorpus {
  const SunsetRuneCorpus._();

  /// La nota sotto il nome per una runa senza rovescio.
  static const String noteSimmetrica = "segno simmetrico, non ha rovescio";

  /// L'INVITO A GIRARE LA PIETRA, per le rune che un rovescio non ce l'hanno.
  ///
  /// **Segnalazione della fondatrice Dora su Gebo, ordine 2171 voce 4.** L'app
  /// invitava a girare la pietra promettendo "il suo rovescio", e subito sotto
  /// dichiarava che quella runa il rovescio non ce l'ha. Il difetto non era il
  /// contenuto, che era giusto: era la promessa.
  ///
  /// Il gesto resta, perche' girare la pietra e' parte del rito e il retro
  /// inciso c'e' comunque: cambia cio' che si promette.
  static const String invitoSimmetrica =
      "Tocca due volte: la pietra mostra il suo retro.";

  static const String invitoSimmetricaConInclinazione =
      "Inclina il telefono sull'asse lungo, oppure tocca due volte: la pietra "
      "mostra il suo retro.";

  /// PERCHE' QUESTA RUNA NON SI ROVESCIA, e come si legge invece.
  ///
  /// Otto rune dell'Elder Futhark sono identiche se le giri: Gebo, Hagalaz,
  /// Isa, Jera, Eihwaz, Sowilo, Ingwaz e Dagaz. Alcune scuole aggiungono
  /// Nauthiz; il Cerchio adotta le otto, e l'insieme vive in un punto solo,
  /// `kRuneSimmetriche`.
  static String perche(String nome) =>
      "$nome e' identica se la giri: il suo segno non ha un sopra e un sotto, "
      "quindi non ha verso d'ombra. Non e' un'informazione che manca: si legge "
      "dal contesto della sera e dalla posizione che occupa nella stesa.";

  /// LA TRASPARENZA SUL ROVESCIO, che vale per tutte e ventiquattro.
  ///
  /// Il verso d'ombra e' pratica moderna: nelle fonti storiche, dai poemi
  /// runici anglosassone, norvegese e islandese alle iscrizioni, non c'e'
  /// traccia di una lettura al contrario. Dirlo non toglie niente al rito, e
  /// non dirlo sarebbe far passare per antico cio' che antico non e'.
  static const String rovescioEPraticaModerna =
      "Il verso d'ombra e' pratica moderna: le fonti storiche non attestano "
      "una lettura al contrario delle rune.";

  // Verso dritto: tutte e ventiquattro le rune.
  static const Map<String, VoceRuna> _dritto = {
    "Fehu": VoceRuna(
      "Lascia fuori la stretta sulle cose: stanotte non devi far fruttare nulla.",
      "Porta dentro la certezza che l'abbondanza scorre, anche mentre dormi.",
    ),
    "Uruz": VoceRuna(
      "Lascia fuori lo sforzo del giorno: il vigore si rifà nel sonno, non nella veglia.",
      "Porta dentro la forza quieta, quella che ti rimette in piedi domani.",
    ),
    "Thurisaz": VoceRuna(
      "Lascia fuori le difese: dietro questa soglia nessun ostacolo ti punge.",
      "Porta dentro la misura, la forza che protegge senza ferire.",
    ),
    "Ansuz": VoceRuna(
      "Lascia fuori le parole del giorno: la notte ascolta senza rispondere.",
      "Porta dentro il segno che ti ha raggiunto, la voce che sapeva.",
    ),
    "Raidho": VoceRuna(
      "Lascia fuori la strada: stanotte il viaggio si ferma e va bene così.",
      "Porta dentro la cadenza giusta, il ritmo che tieni dentro e fuori di te.",
    ),
    "Kenaz": VoceRuna(
      "Lascia fuori la torcia accesa: al buio non serve vederci, serve riposare.",
      "Porta dentro la luce che oggi si è accesa dove prima era buio.",
    ),
    "Gebo": VoceRuna(
      "Lascia fuori il conto di ciò che hai dato e ricevuto: stanotte lo scambio riposa.",
      "Porta dentro l'equilibrio del dono, che non chiede di essere pareggiato subito.",
    ),
    "Wunjo": VoceRuna(
      "Lascia fuori la ricerca della gioia: ce l'hai già, posala accanto a te.",
      "Porta dentro il frutto dolce dello sforzo, un momento di pienezza vera.",
    ),
    "Hagalaz": VoceRuna(
      "Lascia fuori ciò che oggi è crollato: la grandine ha già fatto spazio.",
      "Porta dentro il campo pulito, pronto per quello che verrà.",
    ),
    "Nauthiz": VoceRuna(
      "Lascia fuori la prova del giorno: l'attrito che tempra non si porta a letto.",
      "Porta dentro la pazienza che qui è potere, non fatica.",
    ),
    "Isa": VoceRuna(
      "Lascia fuori la voglia di muovere le cose: stanotte tutto può stare fermo.",
      "Porta dentro il silenzio del ghiaccio, la chiarezza che nasce nell'attesa.",
    ),
    "Jera": VoceRuna(
      "Lascia fuori l'attesa del raccolto: il ciclo matura a suo tempo, non stanotte.",
      "Porta dentro la calma di chi ha seminato e sa aspettare.",
    ),
    "Eihwaz": VoceRuna(
      "Lascia fuori la tensione fra ciò che è e ciò che sarà: il tasso regge da solo.",
      "Porta dentro la resistenza quieta, il ponte che non si spezza.",
    ),
    "Perthro": VoceRuna(
      "Lascia fuori la voglia di sapere: la sorte, stanotte, resta nascosta.",
      "Porta dentro il mistero che si muove sotto, ancora invisibile.",
    ),
    "Algiz": VoceRuna(
      "Lascia fuori la guardia: qui sei più difeso di quanto credi.",
      "Porta dentro il legame con l'alto, l'istinto che veglia mentre dormi.",
    ),
    "Sowilo": VoceRuna(
      "Lascia fuori la volontà che vince: il sole tramonta anche sui vincitori.",
      "Porta dentro la luce che ha guidato la via, ora che si spegne piano.",
    ),
    "Tiwaz": VoceRuna(
      "Lascia fuori la battaglia per il giusto: la lancia si posa con l'onore intatto.",
      "Porta dentro la vittoria che si merita, non quella che si strappa.",
    ),
    "Berkano": VoceRuna(
      "Lascia fuori la cura del giorno: ciò che germoglia cresce anche nel buio.",
      "Porta dentro il nuovo che chiede riparo, la radice da custodire.",
    ),
    "Ehwaz": VoceRuna(
      "Lascia fuori il passo condiviso: stanotte cammini con te solo.",
      "Porta dentro la fiducia nell'altro, l'armonia che porta lontano.",
    ),
    "Mannaz": VoceRuna(
      "Lascia fuori gli altri e i loro sguardi: stanotte torni solo a te stesso.",
      "Porta dentro il te che si riconosce attraverso gli altri.",
    ),
    "Laguz": VoceRuna(
      "Lascia fuori il bisogno di capire: la corrente sa dove va senza di te.",
      "Porta dentro l'intuito, quello che senti sotto la superficie.",
    ),
    "Ingwaz": VoceRuna(
      "Lascia fuori il lavoro visibile: il seme matura in silenzio, senza di te.",
      "Porta dentro il potenziale che cresce al buio, prima di mostrarsi.",
    ),
    "Dagaz": VoceRuna(
      "Lascia fuori la svolta del giorno: il chiarore torna domani, non stanotte.",
      "Porta dentro la soglia fra due giorni, il cambio quieto di stato.",
    ),
    "Othala": VoceRuna(
      "Lascia fuori la casa e i suoi doveri: le radici tengono anche mentre riposi.",
      "Porta dentro il valore che viene da lontano e ti sostiene.",
    ),
  };

  // Verso d'ombra, merkstave: le sedici rune asimmetriche.
  static const Map<String, VoceRuna> _ombra = {
    "Fehu": VoceRuna(
      "Lascia sulla soglia ciò a cui ti aggrappi: quello che stringi troppo, di notte pesa.",
      "Porta dentro la mano aperta, non il timore di perdere.",
    ),
    "Uruz": VoceRuna(
      "Lascia sulla soglia la corsa a vuoto: hai speso di slancio, ora basta.",
      "Porta dentro il ritmo ritrovato, non la fretta di caricare ancora.",
    ),
    "Thurisaz": VoceRuna(
      "Lascia sulla soglia la reazione a caldo: la fretta di stasera ha già pizzicato abbastanza.",
      "Porta dentro l'istante di sosta che stamani ti è mancato.",
    ),
    "Ansuz": VoceRuna(
      "Lascia sulla soglia il messaggio frainteso: al buio non va soppesato.",
      "Porta dentro l'ascolto più lento, non il peso di ciò che hai sentito male.",
    ),
    "Raidho": VoceRuna(
      "Lascia sulla soglia il viaggio a scatti: il ritmo perso si ritrova dormendo.",
      "Porta dentro la promessa che la strada, domani, torna piana.",
    ),
    "Kenaz": VoceRuna(
      "Lascia sulla soglia l'idea ancora informe: al buio non va forzata.",
      "Porta dentro la pazienza della fiamma, che prende quando è pronta.",
    ),
    "Wunjo": VoceRuna(
      "Lascia sulla soglia l'armonia incrinata: al legame si torna domani.",
      "Porta dentro la fiducia che la pienezza, curata, ritorna.",
    ),
    "Nauthiz": VoceRuna(
      "Lascia sulla soglia il vincolo che pesa: l'impazienza di oggi resta fuori.",
      "Porta dentro la chiave che la prova ti ha lasciato in mano.",
    ),
    "Perthro": VoceRuna(
      "Lascia sulla soglia il caso che non svela: non si forza dal buio.",
      "Porta dentro la resa che lascia maturare la sorte.",
    ),
    "Algiz": VoceRuna(
      "Lascia sulla soglia la difesa allentata: al riparo non serve.",
      "Porta dentro l'istinto riascoltato, quello che oggi avevi ignorato.",
    ),
    "Tiwaz": VoceRuna(
      "Lascia sulla soglia il coraggio incerto: la mira si ritrova dormendo.",
      "Porta dentro il tuo giusto ritrovato, non l'energia che oggi calava.",
    ),
    "Berkano": VoceRuna(
      "Lascia sulla soglia il germoglio che stenta: forzarlo di notte non aiuta.",
      "Porta dentro la cura ripresa, quella che nutre la radice.",
    ),
    "Ehwaz": VoceRuna(
      "Lascia sulla soglia l'alleanza sfasata: il ritmo comune si riallinea domani.",
      "Porta dentro la fiducia da riprendere, non lo sfasamento di oggi.",
    ),
    "Mannaz": VoceRuna(
      "Lascia sulla soglia il giudizio severo su di te: al buio non serve.",
      "Porta dentro il legame da ritrovare, non la distanza di oggi.",
    ),
    "Laguz": VoceRuna(
      "Lascia sulla soglia l'emozione confusa: lascia posare la corrente.",
      "Porta dentro l'attesa che schiarisce, finché il fondo torna visibile.",
    ),
    "Othala": VoceRuna(
      "Lascia sulla soglia il legame col passato che pesa: la radice si rivede a luce.",
      "Porta dentro ciò che ti sostiene, lascia fuori ciò che ti trattiene.",
    ),
  };

  // Registro lunare, Voce A frase due: una per ognuna delle otto fasi reali.
  static const Map<String, String> _registroLunare = {
    "Luna nuova":
        "Sotto la luna nuova il cielo trattiene il fiato: è la sera per posare, non per iniziare.",
    "Luna crescente":
        "La luna cresce sottile: ciò che lasci fuori stasera fa spazio a ciò che nasce.",
    "Primo quarto":
        "Al primo quarto la luce spinge: lascia fuori la spinta, la notte non chiede sforzo.",
    "Gibbosa crescente":
        "La luna gibbosa si gonfia di luce: lascia fuori l'attesa, matura da sé.",
    "Luna piena":
        "Sotto la luna piena la luce si versa intera: lascia fuori ciò che illumina troppo, per dormire.",
    "Gibbosa calante":
        "La luna gibbosa cala: è l'ora della gratitudine, lascia fuori il resto.",
    "Ultimo quarto":
        "All'ultimo quarto la luce si ritira: lascia fuori ciò che si è concluso.",
    "Luna calante":
        "La luna cala verso il buio: lascia fuori il vecchio, la notte lo prende con sé.",
  };

  // Clausola di segno, Voce B frase due: l'incrocio col segno solare, dodici,
  // una per segno, che si innesta sulla notte.
  static const Map<String, String> _clausolaSegno = {
    "aries":
        "Con l'ardore d'Ariete nel petto, lascia che la brace covi: domani riaccende da sé.",
    "taurus":
        "Con la calma del Toro, posa il corpo come un peso che finalmente si appoggia.",
    "gemini":
        "Con la mente dei Gemelli ancora viva, lascia posare le parole: al buio non chiedono risposta.",
    "cancer":
        "Con la Luna del Cancro a casa sua, la notte ti custodisce come un guscio.",
    "leo":
        "Con il cuore del Leone, abbassa la fiamma senza spegnerla: brilla piano anche nel sonno.",
    "virgo":
        "Con la cura della Vergine, lascia i dettagli al domani: stanotte niente va sistemato.",
    "libra":
        "Con la soglia della Bilancia, posa i piatti: la notte non chiede equilibrio, chiede riposo.",
    "scorpio":
        "Con la profondità dello Scorpione, lascia scendere lo sguardo al fondo: al buio la verità non ferisce.",
    "sagittarius":
        "Con lo slancio del Sagittario, abbassa l'arco: gli orizzonti aspettano il mattino.",
    "capricorn":
        "Con la misura del Capricorno, lascia la salita: stanotte nessuna vetta ti chiama.",
    "aquarius":
        "Con l'ampiezza dell'Acquario, lascia andare il pensiero largo: la notte lo custodisce.",
    "pisces":
        "Con il sogno dei Pesci, lascia sciogliere i confini: l'acqua che confonde qui guarisce.",
  };

  // Le quattro clausole di insistenza, per la runa che torna entro sette sere.
  static const List<String> _insistenza = [
    "E se torna: non hai ancora finito di ascoltarla.",
    "Una runa che insiste chiede più tempo, non più fretta.",
    "Il ritorno non è ripetizione: è la stessa soglia vista due volte.",
    "Ciò che torna porta lo stesso segno, ma tu non sei più lo stesso.",
  ];

  /// Il ripiego neutro della runa, in voce di Caligo, quando manca la voce.
  static const VoceRuna _voceNeutra = VoceRuna(
    "Lascia fuori il giorno: la soglia lo trattiene al posto tuo.",
    "Porta dentro la notte così com'è, senza chiederle un nome.",
  );

  /// Il ripiego neutro del registro lunare, quando la fase non è in mappa.
  static const String _registroNeutro =
      "Il cielo stasera non si sbilancia: prendi la runa per quello che dice.";

  /// Le due voci della runa nel suo verso. In merkstave ripiega sulla voce
  /// dritta se manca il rovescio, e se manca anche quella sul ripiego neutro:
  /// nessun bang, nessuna eccezione, sempre una frase piena.
  static VoceRuna voceRuna(String name, RuneVerso verso) {
    if (verso == RuneVerso.merkstave) {
      final ombra = _ombra[name];
      if (ombra != null) return ombra;
    }
    return _dritto[name] ?? _voceNeutra;
  }

  /// Il registro lunare della fase, col ripiego neutro se la fase non c'è.
  static String registroLunare(MoonPhase fase) =>
      _registroLunare[fase.italianName] ?? _registroNeutro;

  /// La clausola del segno solare, oppure stringa vuota quando il segno non si
  /// sa o non e' in mappa: la frase deve reggere anche senza, e la Voce B non
  /// lascia mai uno spazio pendente ne' nomina un segno che l'utente non ha dato.
  static String clausolaSegno(Zodiac? segno) =>
      segno == null ? "" : (_clausolaSegno[segno.id] ?? "");

  /// La clausola di insistenza numero [i], modulo quattro.
  static String insistenza(int i) => _insistenza[i % _insistenza.length];

  /// La Voce A completa: cosa lasci fuori, più il registro lunare, più la
  /// clausola di insistenza quando la runa ritorna.
  static String vocePrimaLasciare(EstrazioneTramonto e, {String? insistenzaClausola}) {
    final voce = voceRuna(e.rune.name, e.verso);
    return _unisci([voce.lasciare, registroLunare(e.fase), insistenzaClausola]);
  }

  /// La Voce B completa: cosa porti dentro la notte, più la clausola di segno,
  /// più la clausola di insistenza quando la runa ritorna.
  static String vocePortare(EstrazioneTramonto e, {String? insistenzaClausola}) {
    final voce = voceRuna(e.rune.name, e.verso);
    return _unisci([voce.porta, clausolaSegno(e.segno), insistenzaClausola]);
  }

  /// Unisce i pezzi non vuoti con un solo spazio, così una clausola assente non
  /// lascia mai due spazi né uno spazio in coda.
  static String _unisci(List<String?> pezzi) => pezzi
      .whereType<String>()
      .map((p) => p.trim())
      .where((p) => p.isNotEmpty)
      .join(" ");

  /// **IL PICCOLO RITO PROPIZIATORIO DELLA SERA. Ordine AS voce 09.**
  ///
  /// **Perche' esiste.** Il Tramonto diceva cosa lasciare fuori e cosa portare
  /// dentro la notte, e finiva li': due frasi da leggere. La voce chiede un
  /// gesto, perche' il tramonto e' l'ora in cui si chiude qualcosa, e chiudere
  /// e' una cosa che si FA. E' veloce per progetto: dura quanto un respiro, si
  /// puo' fare da seduti e al buio, e non chiede niente che non si abbia
  /// addosso.
  ///
  /// **Non promette esiti**, come vuole la regola di casa: e' un modo di
  /// segnare il passaggio, non una protezione ne' una fortuna.
  ///
  /// Sono quattro, e la sera ne sceglie una col GIORNO RITUALE, cosi' chi torna
  /// ogni sera non ripete sempre lo stesso gesto e chi riapre la stessa sera
  /// ritrova il suo.
  static const List<String> ritiDellaSera = [
    'Apri la mano verso la finestra, poi chiudila piano: quello che resta '
        'fuori, resta fuori.',
    'Spegni una luce che non ti serve e resta un respiro nel buio che si '
        'apre.',
    'Appoggia la mano dove il giorno ti ha stancato di più e tienicela per tre '
        'respiri.',
    'Di’ il nome della runa a voce bassa, una volta sola: lascia che finisca '
        'lì.',
  ];

  /// Il rito propiziatorio di questa sera.
  static String ritoDellaSera(EstrazioneTramonto e) {
    final giorno = e.giornoRituale;
    final seme = giorno.year * 372 + giorno.month * 31 + giorno.day;
    return ritiDellaSera[seme % ritiDellaSera.length];
  }

  /// La riga di trasparenza dei fattori: runa e verso, fase lunare, e il segno
  /// solo quando si sa. Senza segno la riga si chiude sulla fase, senza nominare
  /// un segno che l'utente non ha dato.
  static String trasparenza(EstrazioneTramonto e) {
    // Merkstave si traduce, ordine AS voce 09.
    final v = e.inOmbra ? "in merkstave (rovesciata)" : "dritta";
    final segno = e.segno;
    final testa = "${e.rune.name} $v, ${e.fase.italianName.toLowerCase()}";
    return segno == null
        ? "$testa."
        : "$testa, sotto il segno ${segno.italianName}.";
  }

  /// L'intestazione della runa che torna entro sette sere.
  static String intestazioneRitorno(String name) =>
      "$name torna. Nella lettura antica una runa che ritorna non è caso: "
      "è insistenza.";

  // Accessori per la copertura nei test.
  static Map<String, VoceRuna> get dritto => _dritto;
  static Map<String, VoceRuna> get ombra => _ombra;
  static Map<String, String> get registri => _registroLunare;
  static Map<String, String> get clausole => _clausolaSegno;
  static List<String> get insistenze => _insistenza;
}
