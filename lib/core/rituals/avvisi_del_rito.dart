import 'package:shared_preferences/shared_preferences.dart';

import '../astro/sunset_time.dart';
import 'rito_alba.dart';
import 'ritual_streak.dart';

/// L'ESITO DI UNA PROGRAMMAZIONE, per poterla raccontare e provare.
enum EsitoAvviso {
  /// Programmato per l'alba vera del luogo.
  programmatoSullAlbaVera,

  /// Programmato sull'ora media, perché la posizione non c'è o è solo stimata
  /// dal fuso. **Non si dichiara nessuna ora esatta alla persona.**
  programmatoSullOraMedia,

  /// Non programmato: il permesso non c'è.
  senzaPermesso,

  /// Non programmato: il rito di quel giorno è già stato aperto.
  ritoGiaAperto,
}

/// IL TRASPORTO VERSO LE NOTIFICHE DI SISTEMA, dietro un'astrazione.
///
/// L'orchestrazione non sa se dietro c'è il plugin, uno spento o un finto nei
/// test. Cosi' le regole (quando si programma, quando no, cosa si scrive) si
/// verificano senza toccare la piattaforma.
abstract class ServizioAvvisi {
  const ServizioAvvisi();

  /// Se su questa piattaforma ha senso proporre gli avvisi.
  bool get disponibile;

  /// Chiede il permesso di sistema. Torna se è stato concesso.
  Future<bool> chiediPermesso();

  /// Se il permesso c'è già, senza chiederlo.
  Future<bool> permessoConcesso();

  /// Programma un avviso. [quando] è ora locale a muro.
  ///
  /// **La consegna è APPROSSIMATA, non all'istante esatto**, ed è una scelta
  /// obbligata: vedi la nota su Android 14 in [AvvisiDelRito].
  ///
  /// [canale] è il canale di sistema su cui l'avviso arriva: ogni chiamata
  /// ha il suo, con nome e descrizione chiari, e si spegne da solo nelle
  /// impostazioni. [carico] è cio' che l'apertura riceve per portare alla
  /// SCENA che l'avviso promette, mai alla home.
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  });

  /// Annulla un avviso già programmato.
  Future<void> annulla(int id);

  /// Gli id degli avvisi in attesa, per poterli contare in una prova.
  Future<List<int>> inAttesa();
}

/// Avvisi spenti: non chiede niente, non programma niente, non fallisce mai.
///
/// È il valore di difetto ovunque, cosi' nessuna prova e nessuna schermata
/// tocca il sistema di notifiche per sbaglio.
class AvvisiSpenti extends ServizioAvvisi {
  const AvvisiSpenti();

  @override
  bool get disponibile => false;

  @override
  Future<bool> chiediPermesso() async => false;

  @override
  Future<bool> permessoConcesso() async => false;

  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {}

  @override
  Future<void> annulla(int id) async {}

  @override
  Future<List<int>> inAttesa() async => const [];
}

/// L'AVVISO DEL RITO DELL'ALBA, e questa è **l'unica porta** che programma
/// avvisi in tutta l'app.
///
/// **Perché una porta sola.** Un avviso programmato da due punti diversi si
/// sdoppia, oppure uno dei due lo annulla e l'altro non lo sa: la persona
/// riceve due notifiche o nessuna, e non c'è modo di capire quale dei due
/// abbia deciso. Una prova enumera i punti che programmano e cade se diventano
/// due.
///
/// **L'ORA È APPROSSIMATA, e non è una scelta di comodo.** Da Android 14 il
/// permesso `SCHEDULE_EXACT_ALARM` è negato di default alle app che puntano API
/// 33 o superiore, e l'alternativa `USE_EXACT_ALARM` è una permission
/// ristretta che Google Play concede soltanto ad app la cui funzione centrale è
/// la sveglia o il calendario. Esoteric Circle non è né l'una né l'altra:
/// dichiararla ci esporrebbe al rifiuto della pubblicazione. Percio' si usa la
/// modalità inesatta, che il sistema consegna in una finestra attorno all'ora
/// chiesta, e **non si promette alla persona un orario al minuto**.
class AvvisiDelRito {
  const AvvisiDelRito._();

  /// L'id dell'avviso del Rito dell'Alba. Uno solo, sempre lo stesso, cosi'
  /// riprogrammarlo sostituisce il precedente invece di affiancarlo.
  static const int idAvvisoAlba = 1001;

  /// Il titolo dell'avviso.
  ///
  /// **Non nomina il Maestro di turno e non anticipa il dono.** Sapere prima
  /// che cosa arriva toglie al rito la sola cosa che ha, cioe' l'apertura. E
  /// non promette niente: dice che c'è, non che farà bene.
  static const String titolo = 'Il Rito dell\'Alba';

  /// Il testo dell'avviso, che invita ad aprire e basta.
  static const String testo =
      'Il sole è sorto. Il rito di oggi ti aspetta quando vuoi.';

  /// La spiegazione che si mostra PRIMA di chiedere il permesso.
  ///
  /// Dice cosa si riceve, quanto spesso, e **che l'ora è approssimata**: chi
  /// accetta sa cosa sta accettando. Chi rifiuta continua a usare tutto.
  static const String spiegazione =
      'Posso avvisarti una volta al giorno, quando il sole sorge da te, che il '
      'Rito dell\'Alba è pronto. Un avviso solo, nessun altro. L\'orario è '
      'indicativo: il sistema consegna l\'avviso in una finestra attorno a '
      'quell\'ora, non al minuto. Se preferisci di no, il rito resta intero e '
      'lo apri quando vuoi.';

  /// QUANDO mandare l'avviso, per il giorno civile di [quando].
  ///
  /// Con una posizione dichiarabile è il sorgere vero. Altrimenti è l'ora media
  /// di `SunsetTime.oraMediaAlba`, la stessa che il resto dell'app usa gia' per
  /// il ripiego, **e in quel caso non si dichiara nessuna ora esatta**.
  static ({DateTime istante, bool albaVera}) istanteDellAvviso(
    DateTime quando,
    PosizioneDiStamattina? posizione,
  ) {
    if (posizione != null && posizione.oraDichiarabile) {
      final alba = SunsetTime.albaPerData(
        quando,
        lat: posizione.lat,
        lon: posizione.lon,
        offset: posizione.scartoDiFuso,
      );
      // Nei casi polari il Sole non sorge: si ripiega sull'ora media, come
      // ovunque nel progetto, invece di non avvisare affatto.
      if (alba != null) return (istante: alba, albaVera: true);
    }
    return (istante: SunsetTime.oraMediaAlba(quando), albaVera: false);
  }

  /// PROGRAMMA l'avviso del prossimo risveglio, se ha senso farlo.
  ///
  /// Le regole, tutte qui e in nessun altro posto:
  ///
  /// - senza permesso non si programma niente;
  /// - **se il rito di oggi è già stato aperto, l'avviso di oggi non parte**,
  ///   perché avvisare di fare una cosa già fatta è rumore;
  /// - l'avviso guarda al giorno che viene, non a quello passato.
  ///
  /// [streak] è la stessa continuità che il rito registra: "aperto oggi" si
  /// legge da li', non da un secondo posto.
  static Future<EsitoAvviso> programmaProssimo({
    required ServizioAvvisi servizio,
    required DateTime adesso,
    PosizioneDiStamattina? posizione,
    RitualStreak streak = const RitualStreak(),
  }) async {
    if (!servizio.disponibile || !await servizio.permessoConcesso()) {
      return EsitoAvviso.senzaPermesso;
    }

    final giaFatto = await streak.fattoOggi(adesso);
    // Se il rito di oggi è gia' stato aperto si guarda a domani; altrimenti si
    // guarda a oggi, e se l'ora e' passata si scivola comunque a domani.
    var giorno = giaFatto ? adesso.add(const Duration(days: 1)) : adesso;
    var quando = istanteDellAvviso(giorno, posizione);
    if (!giaFatto && !quando.istante.isAfter(adesso)) {
      giorno = adesso.add(const Duration(days: 1));
      quando = istanteDellAvviso(giorno, posizione);
    }

    await servizio.annulla(idAvvisoAlba);
    await servizio.programma(
      id: idAvvisoAlba,
      quando: quando.istante,
      titolo: titolo,
      testo: testo,
    );

    if (giaFatto) return EsitoAvviso.ritoGiaAperto;
    return quando.albaVera
        ? EsitoAvviso.programmatoSullAlbaVera
        : EsitoAvviso.programmatoSullOraMedia;
  }

  /// Spegne l'avviso. Chi cambia idea non deve disinstallare l'app.
  static Future<void> spegni(ServizioAvvisi servizio) =>
      servizio.annulla(idAvvisoAlba);

  /// La chiave che ricorda se il permesso e' gia' stato chiesto una volta.
  static const String _chiaveChiesto = 'avvisi.alba.giaChiesto';

  /// Se la spiegazione e' gia' stata mostrata una volta.
  ///
  /// **Si chiede UNA volta sola.** Chi ha detto no non deve ritrovarsi la
  /// stessa domanda ogni mattina: sarebbe un modo di non accettare la
  /// risposta. Chi cambia idea passa dalle impostazioni di sistema.
  static Future<bool> giaChiesto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_chiaveChiesto) ?? false;
    } catch (errore) {
      // L'errore si IGNORA, e si dichiara perche'. L'unica cosa che puo'
      // fallire e' l'apertura della memoria locale, e l'unico effetto e' che
      // non sappiamo se la spiegazione e' gia' stata mostrata. Rispondere vero
      // significa NON insistere: chi ha gia' detto no non se lo vede
      // richiedere, che e' il caso da proteggere.
      assert(() {
        // ignore: avoid_print
        print('AvvisiDelRito.giaChiesto: memoria non leggibile ($errore)');
        return true;
      }());
      return true;
    }
  }

  // ------------------- LE CHIAMATE DEL GIORNO, ordine M -------------------

  /// QUANTE CHIAMATE AL GIORNO, in tutto. Vive QUI, nel dato, in un punto
  /// solo: Mauro sta decidendo se portarle a tre come prevede il Briefing
  /// Operativo V5, e il cambio deve essere una riga, non una caccia nel
  /// codice. Oggi due: una del mattino e una della sera.
  static const int chiamateAlGiorno = 2;

  /// Gli id delle chiamate del giorno: uno per chiamata, sempre gli stessi,
  /// cosi' riprogrammare sostituisce invece di affiancare.
  static const int idChiamataDellaSera = 1002;
  static const int idChiamataDelMattino = 1003;

  /// I canali e i carichi delle chiamate: il carico apre la SCENA promessa.
  static const String canaleTramonto = 'runa_tramonto';
  static const String canaleOroscopo = 'oroscopo_giorno';
  static const String canaleGettate = 'gettate_rune';
  static const String caricoTramonto = 'runa_tramonto';
  static const String caricoOroscopo = 'oroscopo';
  static const String caricoGettate = 'gettate';

  /// PROGRAMMA LE CHIAMATE DEL GIORNO. Le regole, tutte qui:
  ///
  /// - senza permesso non parte niente;
  /// - LA SERA: la Runa del Tramonto chiama all'ora del tramonto gia'
  ///   calcolata dalla scena ([tramonto]); se l'ora e' passata si guarda al
  ///   tramonto di domani, che il chiamante fornisce con [tramontoDiDomani];
  /// - IL MATTINO (ora media dell'alba di domani): UNA chiamata sola, la
  ///   prima disponibile fra il ritorno delle gettate (per chi ha chiuso la
  ///   giornata a zero) e l'oroscopo col FATTO VERO del giorno
  ///   ([fattoDiDomani], nullo se il cielo non dice niente). QUANDO NON C'E'
  ///   NIENTE DI VERO DA DIRE, LA CHIAMATA NON PARTE: meglio zero che rumore;
  /// - MAI piu' di [chiamateAlGiorno] chiamate: i candidati oltre il tetto
  ///   non si programmano.
  ///
  /// Torna gli id programmati, cosi' una prova li conta.
  static Future<List<int>> programmaLeChiamateDelGiorno({
    required ServizioAvvisi servizio,
    required DateTime adesso,
    DateTime? tramonto,
    DateTime? tramontoDiDomani,
    String? fattoDiDomani,
    bool gettateEsaurite = false,
  }) async {
    if (!servizio.disponibile || !await servizio.permessoConcesso()) {
      return const [];
    }

    final candidate = <({int id, DateTime quando, String titolo, String testo,
        String canale, String carico})>[];

    // LA SERA.
    final seraOggi = tramonto != null && tramonto.isAfter(adesso)
        ? tramonto
        : tramontoDiDomani;
    if (seraOggi != null && seraOggi.isAfter(adesso)) {
      candidate.add((
        id: idChiamataDellaSera,
        quando: seraOggi,
        titolo: 'La Runa del Tramonto',
        testo: 'Il sole scende: la tua runa della sera ti aspetta.',
        canale: canaleTramonto,
        carico: caricoTramonto,
      ));
    }

    // IL MATTINO: una sola voce, con le gettate davanti all'oroscopo perche'
    // parlano di un limite che la persona ha toccato ieri con le sue mani.
    final mattino = SunsetTime.oraMediaAlba(adesso.add(const Duration(days: 1)));
    if (gettateEsaurite) {
      candidate.add((
        id: idChiamataDelMattino,
        quando: mattino,
        titolo: 'Le tue gettate sono tornate',
        testo: 'Il giorno è nuovo: le tue tre gettate di rune sono di '
            'nuovo intere.',
        canale: canaleGettate,
        carico: caricoGettate,
      ));
    } else if (fattoDiDomani != null && fattoDiDomani.trim().isNotEmpty) {
      candidate.add((
        id: idChiamataDelMattino,
        quando: mattino,
        titolo: 'Il tuo cielo di oggi',
        testo: fattoDiDomani,
        canale: canaleOroscopo,
        carico: caricoOroscopo,
      ));
    }

    final programmate = <int>[];
    for (final c in candidate.take(chiamateAlGiorno)) {
      await servizio.annulla(c.id);
      await servizio.programma(
        id: c.id,
        quando: c.quando,
        titolo: c.titolo,
        testo: c.testo,
        canale: c.canale,
        carico: c.carico,
      );
      programmate.add(c.id);
    }
    return programmate;
  }

  /// Segna che la spiegazione e' stata mostrata, quale che sia stata la
  /// risposta.
  static Future<void> segnaChiesto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_chiaveChiesto, true);
    } catch (errore) {
      // L'errore si IGNORA, e si dichiara perche'. Non essere riusciti a
      // ricordare che si e' chiesto costa, al massimo, una richiesta di troppo
      // alla prossima apertura. Non c'e' niente da dire alla persona e non c'e'
      // niente da riprovare.
      assert(() {
        // ignore: avoid_print
        print('AvvisiDelRito.segnaChiesto: memoria non scrivibile ($errore)');
        return true;
      }());
    }
  }
}
