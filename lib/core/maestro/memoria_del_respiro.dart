import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'chakra_del_giorno.dart';

/// **CHE COSA LA MEDITAZIONE RICORDA.** Ordine DB voci 07 e 09, 9 settembre
/// 2026.
///
/// **Parole dell'ordine**: *"E' la voce che rende la funzione parte dell'app
/// invece che un accessorio... La Meditazione scrive nella memoria dell'utente,
/// la stessa a cui attingono i Maestri."*
///
/// **DOVE VIVE LA MEMORIA OGGI, verificato prima di scrivere una riga.**
/// L'ordine chiede di guardare com'e' fatta e di usare quella invece di
/// inventarne una seconda. Il censimento:
///
/// - **`MaestroMemory`**, in `lib/core/chat/maestro_memory.dart`: fatti
///   stabili piu' sintesi di sessione, **una per Maestro**, su Firestore. E'
///   la memoria di cio' che si e' DETTO parlando, e la scrive il modello
///   distillando la conversazione.
/// - **`UserProfile`**: chi sei, i dati stabili.
/// - **`NatalContext`**: il cielo di nascita.
/// - Le tracce delle singole funzioni sul telefono, come `TracciaDelLoto` e
///   `FaceHistory`.
///
/// **PERCHE' QUESTA NON ENTRA IN `MaestroMemory` E NON NE E' UNA SECONDA.**
/// Quella memoria e' fatta di **frasi che il modello ha distillato**, e vive
/// su Firestore per Maestro. Il respiro produce **numeri**, non frasi: quante
/// sessioni, quanto lunghe, su quale centro, a che ora. Scriverli come frasi
/// dentro la sintesi di un Maestro vorrebbe dire farli rileggere e
/// reinterpretare a ogni turno, e farli sapere ad Aura e non a Medora.
///
/// **La regola che l'ordine detta e' un'altra, ed e' quella che si applica**:
/// *"Il riassunto della pratica entra nel contesto passato al modello, come
/// gia' ci entrano gli altri dati della persona. Non il dato grezzo di ogni
/// sessione: il riassunto."* Questa classe tiene il dato grezzo **sul
/// telefono**, dove nasce, e produce **il riassunto** che entra nel contesto:
/// e' la stessa relazione che c'e' fra la carta natale e `NatalContext`.
///
/// **E NON ESCE DAL TELEFONO.** Il conto dei respiri di una persona non serve
/// a nessun server: sta dove sta la traccia del Loto, e la dimenticanza lo
/// porta via col prefisso che gia' esiste.
class MemoriaDelRespiro {
  MemoriaDelRespiro({DateTime Function()? orologio})
      : _orologio = orologio ?? DateTime.now;

  final DateTime Function() _orologio;

  static const String _chiave = 'loto.sessioni';

  /// **QUANTE SESSIONI SI CONSERVANO.** Novanta: bastano per dire *"da quanti
  /// giorni pratichi"* su tre mesi, e sono meno di venti chilobyte.
  static const int quanteNeTiene = 90;

  List<SessioneDiRespiro> _sessioni = const [];

  /// Le sessioni conservate, dalla piu' recente.
  List<SessioneDiRespiro> get sessioni => List.unmodifiable(_sessioni);

  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final righe = prefs.getStringList(_chiave) ?? const [];
      final lette = <SessioneDiRespiro>[];
      for (final r in righe) {
        final j = jsonDecode(r);
        if (j is Map<String, dynamic>) {
          final s = SessioneDiRespiro.fromJson(j);
          if (s != null) lette.add(s);
        }
      }
      lette.sort((a, b) => b.quando.compareTo(a.quando));
      _sessioni = List.unmodifiable(lette);
    } catch (_) {
      // Senza memoria si medita lo stesso: la pratica non dipende dal ricordo.
    }
  }

  /// Segna una sessione appena conclusa.
  Future<void> segna(SessioneDiRespiro sessione) async {
    _sessioni = List.unmodifiable(
        [sessione, ..._sessioni].take(quanteNeTiene).toList());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _chiave, [for (final s in _sessioni) jsonEncode(s.toJson())]);
    } catch (_) {
      // best effort.
    }
  }

  // --- L'ANDAMENTO, che e' cio' che nessuna singola sessione dice ---

  /// Da quanti giorni distinti si pratica.
  int get giorniDiPratica =>
      _sessioni.map((s) => s.giorno).toSet().length;

  /// **QUANTI GIORNI DI SEGUITO**, contando all'indietro da oggi.
  int get giorniDiFila {
    if (_sessioni.isEmpty) return 0;
    final giorni = _sessioni.map((s) => s.giorno).toSet();
    var quanti = 0;
    var cursore = _orologio();
    // Se oggi non si e' ancora praticato, la striscia si conta da ieri: chi
    // apre la Meditazione la mattina non ha ancora perso la sua striscia.
    if (!giorni.contains(_giornoDi(cursore))) {
      cursore = cursore.subtract(const Duration(days: 1));
    }
    while (giorni.contains(_giornoDi(cursore))) {
      quanti++;
      cursore = cursore.subtract(const Duration(days: 1));
    }
    return quanti;
  }

  /// L'indice del centro piu' frequentato, o nulla se non si e' mai praticato.
  int? get centroPiuFrequentato {
    if (_sessioni.isEmpty) return null;
    final conto = <int, int>{};
    for (final s in _sessioni) {
      conto.update(s.centro, (n) => n + 1, ifAbsent: () => 1);
    }
    final ordinati = conto.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ordinati.first.key;
  }

  /// Gli indici dei centri **mai toccati**.
  List<int> get centriMaiToccati {
    final visti = _sessioni.map((s) => s.centro).toSet();
    return [
      for (var i = 0; i < ChakraDelGiorno.tutti.length; i++)
        if (!visti.contains(i)) i,
    ];
  }

  /// Quanti giorni sono passati dall'ultima sessione, o nulla se e' la prima.
  int? get giorniDallUltima {
    if (_sessioni.isEmpty) return null;
    return _orologio().difference(_sessioni.first.quando).inDays;
  }

  /// **SE LE SESSIONI SI ALLUNGANO O SI ACCORCIANO.**
  ///
  /// Confronta la durata media delle ultime tre con quella delle tre
  /// precedenti. Nulla quando non ci sono sei sessioni: **con meno non c'e'
  /// nessun andamento, c'e' rumore**, e dirlo lo stesso sarebbe la
  /// osservazione falsa che la voce DB.09 vieta.
  double? get quantoCambiaLaDurata {
    if (_sessioni.length < 6) return null;
    double media(Iterable<SessioneDiRespiro> quali) =>
        quali.map((s) => s.durata.inSeconds).reduce((a, b) => a + b) /
        quali.length;
    final recenti = media(_sessioni.take(3));
    final prima = media(_sessioni.skip(3).take(3));
    if (prima <= 0) return null;
    return (recenti - prima) / prima;
  }

  /// **L'ORA IN CUI SI TORNA PIU' SPESSO**, arrotondata alla fascia.
  /// Nulla sotto le tre sessioni: un'ora ricavata da due volte non e'
  /// un'abitudine.
  int? get oraPiuFrequente {
    if (_sessioni.length < 3) return null;
    final conto = <int, int>{};
    for (final s in _sessioni) {
      conto.update(s.quando.hour, (n) => n + 1, ifAbsent: () => 1);
    }
    final ordinati = conto.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    // Serve che una fascia si stacchi davvero: se la piu' frequente vale
    // quanto la seconda, non c'e' nessuna abitudine da dichiarare.
    if (ordinati.length > 1 && ordinati.first.value == ordinati[1].value) {
      return null;
    }
    return ordinati.first.key;
  }

  /// **IL RIASSUNTO CHE ENTRA NEL CONTESTO DEI MAESTRI.** Ordine DB voce 08.
  ///
  /// Non il dato grezzo di ogni sessione: **una riga breve**, in una forma che
  /// il modello possa usare senza doverla interpretare. Vuota quando non c'e'
  /// niente da dire, e in quel caso nel contesto non entra niente.
  ///
  /// **Nessun Maestro deve dire alla persona che la sta osservando**, ed e' un
  /// vincolo dell'ordine: questa riga gli dice cosa sa, non gli dice di
  /// dichiararlo.
  String get riassuntoPerIMaestri {
    if (_sessioni.isEmpty) return '';
    final pezzi = <String>[];
    pezzi.add('pratica il respiro da $giorniDiPratica giorni');
    final fila = giorniDiFila;
    if (fila >= 2) pezzi.add('$fila giorni di seguito');
    final piu = centroPiuFrequentato;
    if (piu != null) {
      pezzi.add('centro piu frequentato ${ChakraDelGiorno.tutti[piu].italiano}');
    }
    final mai = centriMaiToccati;
    if (mai.isNotEmpty && mai.length < ChakraDelGiorno.tutti.length) {
      pezzi.add('non ha mai respirato '
          '${mai.map((i) => ChakraDelGiorno.tutti[i].italiano).join(", ")}');
    }
    final da = giorniDallUltima;
    if (da != null && da >= 7) pezzi.add('ultima volta $da giorni fa');
    return pezzi.join('; ');
  }

  static String _giornoDi(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

/// Una sessione di respiro, come la memoria la conserva.
class SessioneDiRespiro {
  const SessioneDiRespiro({
    required this.quando,
    required this.centro,
    required this.durata,
    required this.compiuta,
    required this.guidato,
    this.mediaDentro = Duration.zero,
    this.mediaFuori = Duration.zero,
    this.respiri = 0,
  });

  /// Quando e' cominciata.
  final DateTime quando;

  /// L'indice del centro respirato.
  final int centro;

  /// Quanto e' durata.
  final Duration durata;

  /// **SE E' STATA PORTATA A TERMINE O INTERROTTA.** Ordine DB voce 07: e' la
  /// differenza fra chi ha finito e chi ha lasciato a meta', e senza di lei
  /// una sessione da dieci secondi conta quanto una da dieci minuti.
  final bool compiuta;

  /// Se il respiro era guidato dall'app o proprio della persona.
  final bool guidato;

  /// Il ritmo medio: quanto e' durato in media l'inspiro e quanto l'espiro.
  final Duration mediaDentro;
  final Duration mediaFuori;

  /// Quanti respiri interi.
  final int respiri;

  String get giorno => MemoriaDelRespiro._giornoDi(quando);

  Map<String, dynamic> toJson() => {
        'quando': quando.toIso8601String(),
        'centro': centro,
        'durata': durata.inMilliseconds,
        'compiuta': compiuta,
        'guidato': guidato,
        'dentro': mediaDentro.inMilliseconds,
        'fuori': mediaFuori.inMilliseconds,
        'respiri': respiri,
      };

  static SessioneDiRespiro? fromJson(Map<String, dynamic> j) {
    final quando = DateTime.tryParse(j['quando'] as String? ?? '');
    if (quando == null) return null;
    return SessioneDiRespiro(
      quando: quando,
      centro: (j['centro'] as num?)?.toInt() ?? 0,
      durata: Duration(milliseconds: (j['durata'] as num?)?.toInt() ?? 0),
      compiuta: j['compiuta'] == true,
      guidato: j['guidato'] == true,
      mediaDentro:
          Duration(milliseconds: (j['dentro'] as num?)?.toInt() ?? 0),
      mediaFuori: Duration(milliseconds: (j['fuori'] as num?)?.toInt() ?? 0),
      respiri: (j['respiri'] as num?)?.toInt() ?? 0,
    );
  }
}
