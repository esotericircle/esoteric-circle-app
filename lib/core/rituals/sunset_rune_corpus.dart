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
/// lasciare fuori e cosa portare nella notte. Nessuna riga e' variante
/// stilistica di un'altra. Deterministico, offline, nessuna AI.
class SunsetRuneCorpus {
  const SunsetRuneCorpus._();

  /// La nota sotto il nome per una runa senza rovescio.
  static const String noteSimmetrica = "segno simmetrico, non ha rovescio";

  // Verso dritto: tutte e ventiquattro le rune.
  static const Map<String, VoceRuna> _dritto = {
    "Fehu": VoceRuna(
      "Lascia fuori la stretta sulle cose: stanotte non devi far fruttare nulla.",
      "Porta dentro la certezza che l'abbondanza scorre, anche mentre dormi.",
    ),
    "Uruz": VoceRuna(
      "Lascia fuori lo sforzo del giorno: il vigore si rifa' nel sonno, non nella veglia.",
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
      "Lascia fuori la strada: stanotte il viaggio si ferma e va bene cosi'.",
      "Porta dentro la cadenza giusta, il ritmo che tieni dentro e fuori di te.",
    ),
    "Kenaz": VoceRuna(
      "Lascia fuori la torcia accesa: al buio non serve vederci, serve riposare.",
      "Porta dentro la luce che oggi si e' accesa dove prima era buio.",
    ),
    "Gebo": VoceRuna(
      "Lascia fuori il conto di cio' che hai dato e ricevuto: stanotte lo scambio riposa.",
      "Porta dentro l'equilibrio del dono, che non chiede di essere pareggiato subito.",
    ),
    "Wunjo": VoceRuna(
      "Lascia fuori la ricerca della gioia: ce l'hai gia', posala accanto a te.",
      "Porta dentro il frutto dolce dello sforzo, un momento di pienezza vera.",
    ),
    "Hagalaz": VoceRuna(
      "Lascia fuori cio' che oggi e' crollato: la grandine ha gia' fatto spazio.",
      "Porta dentro il campo pulito, pronto per quello che verra'.",
    ),
    "Nauthiz": VoceRuna(
      "Lascia fuori la prova del giorno: l'attrito che tempra non si porta a letto.",
      "Porta dentro la pazienza che qui e' potere, non fatica.",
    ),
    "Isa": VoceRuna(
      "Lascia fuori la voglia di muovere le cose: stanotte tutto puo' stare fermo.",
      "Porta dentro il silenzio del ghiaccio, la chiarezza che nasce nell'attesa.",
    ),
    "Jera": VoceRuna(
      "Lascia fuori l'attesa del raccolto: il ciclo matura a suo tempo, non stanotte.",
      "Porta dentro la calma di chi ha seminato e sa aspettare.",
    ),
    "Eihwaz": VoceRuna(
      "Lascia fuori la tensione fra cio' che e' e cio' che sara': il tasso regge da solo.",
      "Porta dentro la resistenza quieta, il ponte che non si spezza.",
    ),
    "Perthro": VoceRuna(
      "Lascia fuori la voglia di sapere: la sorte, stanotte, resta nascosta.",
      "Porta dentro il mistero che si muove sotto, ancora invisibile.",
    ),
    "Algiz": VoceRuna(
      "Lascia fuori la guardia: qui sei piu' difeso di quanto credi.",
      "Porta dentro il legame con l'alto, l'istinto che veglia mentre dormi.",
    ),
    "Sowilo": VoceRuna(
      "Lascia fuori la volonta' che vince: il sole tramonta anche sui vincitori.",
      "Porta dentro la luce che ha guidato la via, ora che si spegne piano.",
    ),
    "Tiwaz": VoceRuna(
      "Lascia fuori la battaglia per il giusto: la lancia si posa con l'onore intatto.",
      "Porta dentro la vittoria che si merita, non quella che si strappa.",
    ),
    "Berkano": VoceRuna(
      "Lascia fuori la cura del giorno: cio' che germoglia cresce anche nel buio.",
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
      "Lascia sulla soglia cio' a cui ti aggrappi: quello che stringi troppo, di notte pesa.",
      "Porta dentro la mano aperta, non il timore di perdere.",
    ),
    "Uruz": VoceRuna(
      "Lascia sulla soglia la corsa a vuoto: hai speso di slancio, ora basta.",
      "Porta dentro il ritmo ritrovato, non la fretta di caricare ancora.",
    ),
    "Thurisaz": VoceRuna(
      "Lascia sulla soglia la reazione a caldo: la fretta di stasera ha gia' pizzicato abbastanza.",
      "Porta dentro l'istante di sosta che stamani ti e' mancato.",
    ),
    "Ansuz": VoceRuna(
      "Lascia sulla soglia il messaggio frainteso: al buio non va soppesato.",
      "Porta dentro l'ascolto piu' lento, non il peso di cio' che hai sentito male.",
    ),
    "Raidho": VoceRuna(
      "Lascia sulla soglia il viaggio a scatti: il ritmo perso si ritrova dormendo.",
      "Porta dentro la promessa che la strada, domani, torna piana.",
    ),
    "Kenaz": VoceRuna(
      "Lascia sulla soglia l'idea ancora informe: al buio non va forzata.",
      "Porta dentro la pazienza della fiamma, che prende quando e' pronta.",
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
      "Porta dentro l'attesa che schiarisce, finche' il fondo torna visibile.",
    ),
    "Othala": VoceRuna(
      "Lascia sulla soglia il legame col passato che pesa: la radice si rivede a luce.",
      "Porta dentro cio' che ti sostiene, lascia fuori cio' che ti trattiene.",
    ),
  };

  // Registro lunare, Voce A frase due: una per ognuna delle otto fasi reali.
  static const Map<String, String> _registroLunare = {
    "Luna nuova":
        "Sotto la luna nuova il cielo trattiene il fiato: e' la sera per posare, non per iniziare.",
    "Luna crescente":
        "La luna cresce sottile: cio' che lasci fuori stasera fa spazio a cio' che nasce.",
    "Primo quarto":
        "Al primo quarto la luce spinge: lascia fuori la spinta, la notte non chiede sforzo.",
    "Gibbosa crescente":
        "La luna gibbosa si gonfia di luce: lascia fuori l'attesa, matura da se'.",
    "Luna piena":
        "Sotto la luna piena la luce si versa intera: lascia fuori cio' che illumina troppo, per dormire.",
    "Gibbosa calante":
        "La luna gibbosa cala: e' l'ora della gratitudine, lascia fuori il resto.",
    "Ultimo quarto":
        "All'ultimo quarto la luce si ritira: lascia fuori cio' che si e' concluso.",
    "Luna calante":
        "La luna cala verso il buio: lascia fuori il vecchio, la notte lo prende con se'.",
  };

  // Clausola di segno, Voce B frase due: l'incrocio col segno solare, dodici,
  // una per segno, che si innesta sulla notte.
  static const Map<String, String> _clausolaSegno = {
    "aries":
        "Con l'ardore d'Ariete nel petto, lascia che la brace covi: domani riaccende da se'.",
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
        "Con la profondita' dello Scorpione, lascia scendere il fondo: al buio la verita' non ferisce.",
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
    "Una runa che insiste chiede piu' tempo, non piu' fretta.",
    "Il ritorno non e' ripetizione: e' la stessa soglia vista due volte.",
    "Cio' che torna porta lo stesso segno, ma tu non sei piu' lo stesso.",
  ];

  /// Le due voci della runa nel suo verso.
  static VoceRuna voceRuna(String name, RuneVerso verso) =>
      verso == RuneVerso.merkstave ? _ombra[name]! : _dritto[name]!;

  /// Il registro lunare della fase.
  static String registroLunare(MoonPhase fase) =>
      _registroLunare[fase.italianName]!;

  /// La clausola del segno solare.
  static String clausolaSegno(Zodiac segno) => _clausolaSegno[segno.id]!;

  /// La clausola di insistenza numero [i], modulo quattro.
  static String insistenza(int i) => _insistenza[i % _insistenza.length];

  /// La Voce A completa: cosa lasci fuori, piu' il registro lunare, piu' la
  /// clausola di insistenza quando la runa ritorna.
  static String vocePrimaLasciare(EstrazioneTramonto e, {String? insistenzaClausola}) {
    final voce = voceRuna(e.rune.name, e.verso);
    final base = "${voce.lasciare} ${registroLunare(e.fase)}";
    return insistenzaClausola == null ? base : "$base $insistenzaClausola";
  }

  /// La Voce B completa: cosa porti dentro la notte, piu' la clausola di segno,
  /// piu' la clausola di insistenza quando la runa ritorna.
  static String vocePortare(EstrazioneTramonto e, {String? insistenzaClausola}) {
    final voce = voceRuna(e.rune.name, e.verso);
    final base = "${voce.porta} ${clausolaSegno(e.segno)}";
    return insistenzaClausola == null ? base : "$base $insistenzaClausola";
  }

  /// La riga di trasparenza dei tre fattori: runa e verso, fase lunare, segno.
  static String trasparenza(EstrazioneTramonto e) {
    final v = e.inOmbra ? "in merkstave" : "dritta";
    return "${e.rune.name} $v, ${e.fase.italianName.toLowerCase()}, "
        "sotto il segno ${e.segno.italianName}.";
  }

  /// L'intestazione della runa che torna entro sette sere.
  static String intestazioneRitorno(String name) =>
      "$name torna. Nella lettura antica una runa che ritorna non e' caso: "
      "e' insistenza.";

  // Accessori per la copertura nei test.
  static Map<String, VoceRuna> get dritto => _dritto;
  static Map<String, VoceRuna> get ombra => _ombra;
  static Map<String, String> get registri => _registroLunare;
  static Map<String, String> get clausole => _clausolaSegno;
  static List<String> get insistenze => _insistenza;
}
