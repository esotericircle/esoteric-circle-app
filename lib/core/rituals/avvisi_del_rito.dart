import 'package:shared_preferences/shared_preferences.dart';

import '../astro/solar_time.dart';
import 'daily_elements.dart';
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
  ///
  /// **E' LO STESSO ID DEL DONO `dawn`, e deve restarlo.** Ordine BC voce 05.
  /// Due porte programmano l'avviso dell'Alba, e va bene cosi': la regia lo
  /// mette all'ora ancorata quando l'app si apre, e il Rito dell'Alba lo
  /// rimette **sull'alba vera del luogo** quando qualcuno lo apre e concede la
  /// posizione. Con lo stesso id il secondo sostituisce il primo; con due id
  /// diversi la persona riceverebbe due chiamate la stessa mattina.
  static int get idAvvisoAlba => idDelDono(DailyElement.dawn);

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
  /// **RISCRITTA PER I CINQUE DONI. Ordine BC voce 05.**
  ///
  /// Diceva *"Un avviso solo, nessun altro"*, ed era vero finche' l'avviso era
  /// uno. Con cinque Doni che possono chiamare quella frase diventa una bugia
  /// detta nel momento peggiore: **mentre si chiede un permesso**. Chi accetta
  /// deve sapere cosa sta accettando, e qui c'e' scritto il numero vero, chi
  /// sceglie e dove si cambia idea.
  static const String spiegazione =
      'Posso chiamarti quando un Dono del giorno è pronto: l\'Alba al '
      'mattino, il Soffio, l\'Arcano, il Tramonto e il Sigillo del Sogno, '
      'ciascuno alla sua ora. Sono cinque avvisi al giorno, e dal menù '
      'Notifiche puoi spegnere quelli che non vuoi e spostare l\'ora di '
      'quelli che tieni. L\'orario è indicativo, perché il sistema consegna '
      'l\'avviso in una finestra attorno a quell\'ora e non al minuto. Se '
      'preferisci di no, i riti restano interi e li apri quando vuoi.';

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
  static const int chiamateAlGiorno = 3;

  /// Gli id delle chiamate del giorno: uno per chiamata, sempre gli stessi,
  /// cosi' riprogrammare sostituisce invece di affiancare.
  // ===================================================================
  // I CINQUE AVVISI DEI DONI. Ordine BC voce 05.
  // ===================================================================

  /// **L'ID DI UN DONO, e perche' partono da 1100.**
  ///
  /// Sotto quel numero vivono gli id delle chiamate vecchie, 1001 e seguenti,
  /// e su un telefono che aggiorna l'app quelle chiamate sono **gia' in coda
  /// nel sistema**: riusare i loro numeri vorrebbe dire sovrascriverne una a
  /// caso e lasciare le altre a suonare per sempre. Con un blocco nuovo, le
  /// vecchie si annullano una per una e le nuove nascono pulite.
  static int idDelDono(DailyElement dono) =>
      1100 + DailyElement.values.indexOf(dono);

  /// Gli id delle chiamate di prima, che vanno spente sui telefoni che
  /// aggiornano: restano qui a nome perche' spegnere un numero a caso non e'
  /// una cosa che si scrive in linea.
  static const List<int> idDelleChiamateDiPrima = [1001, 1002, 1003, 1004];

  /// Il canale di sistema di un Dono: uno per ciascuno, cosi' **ognuno si
  /// spegne anche dalle impostazioni di Android**, e chi spegne il Sigillo del
  /// Sogno non perde l'Alba.
  static String canaleDelDono(DailyElement dono) => 'dono_${dono.name}';

  /// Il carico che l'apertura riceve: porta alla scena del Dono, mai alla home.
  static String caricoDelDono(DailyElement dono) => 'dono:${dono.name}';

  /// **IL TESTO DI UN AVVISO, e non anticipa il dono.**
  ///
  /// La regola era gia' scritta per l'Alba: *"non nomina il Maestro di turno e
  /// non anticipa il dono, perche' sapere prima che cosa arriva toglie al rito
  /// la sola cosa che ha, cioe' l'apertura"*. Vale per tutti e cinque: si dice
  /// che il momento e' arrivato, non cosa ci si trovera' dentro.
  static String testoDelDono(DailyElement dono) => switch (dono) {
        DailyElement.dawn =>
          'Il sole è sorto. Il rito di oggi ti aspetta quando vuoi.',
        DailyElement.breath =>
          'È l\'ora del respiro. Il Soffio del Destino ti aspetta.',
        DailyElement.oracle =>
          'La carta di oggi è pronta a scoprirsi.',
        DailyElement.rune =>
          'Il sole scende: la tua runa della sera ti aspetta.',
        DailyElement.night =>
          'La notte è cominciata. C\'è un Sigillo da chiudere prima di dormire.',
      };

  /// A che ora chiama, detto alla persona: e' cio' che si legge accanto
  /// all'interruttore nel menu' delle notifiche.
  static String oraDetta(DailyElement dono) =>
      '${dono.anchorHour.toString().padLeft(2, '0')}:'
      '${dono.anchorMinute.toString().padLeft(2, '0')}';

  static const int idChiamataDellaSera = 1002;
  static const int idChiamataDelMattino = 1003;

  /// LA TERZA CHIAMATA, ordine O: il traguardo a un passo. Parte solo se un
  /// traguardo e' davvero vicino, cioe' se il cammino ha qualcosa da dire:
  /// senza, resta zero, che sta sempre sopra il rumore.
  static const int idChiamataDelTraguardo = 1004;
  static const String canaleTraguardo = 'sigilli_del_cammino';
  static const String caricoTraguardo = 'sigilli';

  /// I canali e i carichi delle chiamate: il carico apre la SCENA promessa.
  static const String canaleTramonto = 'runa_tramonto';
  static const String canaleOroscopo = 'oroscopo_giorno';
  static const String canaleGettate = 'gettate_rune';
  static const String caricoTramonto = 'runa_tramonto';
  static const String caricoOroscopo = 'oroscopo';
  static const String caricoGettate = 'gettate';

  /// PROGRAMMA LE CHIAMATE DEL GIORNO: UNA PER DONO ACCESO.
  /// Ordine BC voce 05.
  ///
  /// **Parole del fondatore, maiuscole sue**: "BISOGNA ATTIVARE LE NOTIFICHE
  /// VERAMENTE e ne voglio 5, ovvero una per ogni dono con orario che avevamo
  /// gia' concordato."
  ///
  /// **Cosa c'era prima, e perche' non bastava.** Tre chiamate, nessuna legata
  /// a un Dono: la sera per la Runa del Tramonto, il mattino per le gettate
  /// tornate oppure per il cielo di oggi, e il traguardo a un passo dieci ore
  /// dopo. Si accendevano tutte insieme col permesso di sistema, e per
  /// spegnerne una sola bisognava uscire dall'app e andare a cercare i canali
  /// nelle impostazioni di Android.
  ///
  /// **Le regole, adesso:**
  ///
  /// - senza permesso non parte niente;
  /// - **un avviso per ogni Dono che la persona ha acceso**, all'ora che il
  ///   Dono porta scritta dentro di se': Alba 7:00, Soffio 10:30, Arcano
  ///   13:00, Tramonto 18:30, Notte 22:30;
  /// - se l'ora di oggi e' gia' passata si programma quella di domani, se no
  ///   l'avviso resterebbe muto fino al giorno dopo;
  /// - **l'ora dell'Alba la decide il Sole quando si puo'**: con una posizione
  ///   dichiarabile e' il sorgere vero, che e' l'unica cosa che l'app abbia
  ///   mai promesso a voce.
  ///
  /// Torna gli id programmati, cosi' una prova li conta.
  static Future<List<int>> programmaLeChiamateDelGiorno({
    required ServizioAvvisi servizio,
    required DateTime adesso,
    required List<DailyElement> doniAccesi,
    DateTime? albaVera,
    Map<DailyElement, int>? oreScelte,
  }) async {
    if (!servizio.disponibile || !await servizio.permessoConcesso()) {
      return const [];
    }

    // **PRIMA SI SPEGNE TUTTO, POI SI RIACCENDE CIO' CHE SERVE.**
    //
    // Un Dono appena spento ha un avviso gia' in coda nel sistema, e
    // riprogrammare i soli accesi non lo toglierebbe: la persona spegnerebbe
    // l'interruttore e riceverebbe lo stesso la chiamata, che e' il modo piu'
    // sicuro di far spegnere tutto dalle impostazioni di Android.
    for (final d in DailyElement.values) {
      await servizio.annulla(idDelDono(d));
    }

    final programmate = <int>[];
    for (final dono in doniAccesi) {
      final quando = _prossimaVolta(dono, adesso, albaVera,
          oreScelte?[dono] ?? dono.anchorMinutes);
      await servizio.programma(
        id: idDelDono(dono),
        quando: quando,
        titolo: dono.title,
        testo: testoDelDono(dono),
        canale: canaleDelDono(dono),
        carico: caricoDelDono(dono),
      );
      programmate.add(idDelDono(dono));
    }
    return programmate;
  }

  /// La prossima volta che questo Dono chiama.
  ///
  /// Oggi se la sua ora deve ancora arrivare, domani se e' passata.
  static DateTime _prossimaVolta(DailyElement dono, DateTime adesso,
      DateTime? albaVera, int minuti) {
    // **L'ALBA HA UN'ORA SUA quando il Sole la da'**, ed e' l'unica promessa
    // che questa app abbia mai fatto a voce: "quando il sole sorge da te".
    //
    // **MA SOLO SE NESSUNO L'HA CAMBIATA.** Ordine BC voce 05, coda: il
    // fondatore ha chiesto che ogni orario si possa cambiare, e un'ora
    // scelta a mano vale piu' del sorgere del Sole. Chi vuole il Sole
    // rimette l'ora di casa dal menu'.
    if (dono == DailyElement.dawn &&
        albaVera != null &&
        minuti == dono.anchorMinutes) {
      if (albaVera.isAfter(adesso)) return albaVera;
      return albaVera.add(const Duration(days: 1));
    }
    final oggi = DateTime(adesso.year, adesso.month, adesso.day,
        minuti ~/ 60, minuti % 60);
    if (oggi.isAfter(adesso)) return oggi;
    return oggi.add(const Duration(days: 1));
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
