import 'package:shared_preferences/shared_preferences.dart';

import 'chakra_del_giorno.dart';

/// **LA TRACCIA CHE CRESCE NEL LOTO.** Ordine CZ voce 10, 8 settembre 2026.
///
/// **Parole del fondatore**: *"Ogni sessione lascia una goccia di luce nel
/// centro del Loto, e il fiore si riempie con i giorni. Il centro respirato di
/// piu' e' visibile, quello mai respirato resta spento: chi guarda il proprio
/// fiore vede da solo di avere lavorato sette volte sulla gola e mai sul
/// cuore. E' il richiamo a tornare, e non ha bisogno di una notifica per
/// funzionare."*
///
/// **Perche' non serve una notifica.** Un fiore con un petalo spento e' una
/// domanda che si pone da sola ogni volta che lo si guarda. Una notifica e'
/// una voce da fuori che chiede di tornare; questo e' un vuoto che chi torna
/// vede da se'. Il primo si spegne dalle impostazioni, il secondo no.
///
/// **Sta tutto sul dispositivo.** E' un conto di sette numeri, e non esce di
/// qui: non c'e' niente in questa traccia che qualcuno debba sapere all'infuori
/// di chi respira.
class TracciaDelLoto {
  TracciaDelLoto({DateTime Function()? orologio})
      : _orologio = orologio ?? DateTime.now;

  final DateTime Function() _orologio;

  static const String _chiave = 'loto.respiri_per_centro';

  /// Quante sessioni per ogni centro, nell'ordine di `ChakraDelGiorno.tutti`.
  List<int> _gocce = List<int>.filled(ChakraDelGiorno.tutti.length, 0);

  /// Le gocce di adesso, una per centro.
  List<int> get gocce => List.unmodifiable(_gocce);

  /// Legge la traccia dal dispositivo. Chiamarla due volte non raddoppia.
  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final salvate = prefs.getStringList(_chiave);
      if (salvate == null) return;
      final letti = <int>[];
      for (final s in salvate) {
        letti.add(int.tryParse(s) ?? 0);
      }
      // **SI ADATTA AL NUMERO DI CENTRI DI OGGI, e non a quello di ieri.** Se
      // un domani i centri diventassero otto, una lista di sette salvata
      // prima non deve far cadere niente: si riempie, non si rifiuta.
      _gocce = List<int>.generate(ChakraDelGiorno.tutti.length,
          (i) => i < letti.length ? letti[i] : 0);
    } catch (errore) {
      // Memoria non leggibile: la traccia riparte da zero e il fiore si
      // riempie di nuovo. Non c'e' niente da dire alla persona, e niente da
      // riprovare.
      _gocce = List<int>.filled(ChakraDelGiorno.tutti.length, 0);
    }
  }

  /// **UNA SESSIONE COMPIUTA LASCIA LA SUA GOCCIA**, sul centro di quel
  /// giorno.
  ///
  /// Il centro non si sceglie: e' quello acceso nel giorno in cui si respira,
  /// e viene dalla stessa porta che decide la frequenza. Una sola sorgente per
  /// il centro, come per la frequenza.
  Future<void> unaGoccia({DateTime? quando}) async {
    final giorno = quando ?? _orologio();
    final centro = ChakraDelGiorno.di(giorno);
    final i = ChakraDelGiorno.tutti.indexWhere((c) => c.nome == centro.nome);
    if (i < 0) return;
    _gocce[i] = _gocce[i] + 1;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _chiave, _gocce.map((n) => n.toString()).toList());
    } catch (errore) {
      // Non salvato: la goccia di questa sessione si perde alla chiusura, e
      // il fiore resta com'era. Meglio di un'app che si ferma.
    }
  }

  /// Quante volte si e' respirato su un centro.
  int goccePer(Chakra centro) {
    final i = ChakraDelGiorno.tutti.indexWhere((c) => c.nome == centro.nome);
    return i < 0 ? 0 : _gocce[i];
  }

  /// **I CENTRI MAI RESPIRATI**, che sono quelli che il fiore lascia spenti.
  ///
  /// E' la domanda che il Loto pone da solo, ed e' il richiamo a tornare.
  List<Chakra> get maiRespirati => [
        for (var i = 0; i < ChakraDelGiorno.tutti.length; i++)
          if (_gocce[i] == 0) ChakraDelGiorno.tutti[i],
      ];

  /// Il centro su cui si e' lavorato di piu', oppure nulla se il fiore e'
  /// ancora tutto spento.
  Chakra? get ilPiuRespirato {
    var quale = -1;
    var quante = 0;
    for (var i = 0; i < _gocce.length; i++) {
      if (_gocce[i] > quante) {
        quante = _gocce[i];
        quale = i;
      }
    }
    return quale < 0 ? null : ChakraDelGiorno.tutti[quale];
  }

  /// **QUANTO E' PIENO IL FIORE**, da 0 a 1: la quota di centri accesi almeno
  /// una volta.
  ///
  /// Non conta le sessioni: conta i centri. Chi respira sette volte sulla gola
  /// ha un fiore pieno per un settimo, ed e' esattamente cio' che il fondatore
  /// vuole che si veda.
  double get quantoEPieno {
    final accesi = _gocce.where((n) => n > 0).length;
    return accesi / _gocce.length;
  }

  /// Il totale delle sessioni, su tutti i centri.
  int get sessioniInTutto => _gocce.fold(0, (a, b) => a + b);
}
