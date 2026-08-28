import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL DIARIO DEI SOGNI. Ordine BX voce 10.
///
/// **Perche' nasce.** Il corpus della revisione E porta tre voci del sentiero
/// dell'Albero che parlano di sogni ANNOTATI: "torni su un sogno annotato e lo
/// rileggi a distanza di giorni", "lo stesso simbolo torna in due sogni
/// annotati", "il tuo Animale Guida compare in un sogno che hai annotato".
/// Tutte e tre dormivano con la stessa ragione scritta dal generatore, "il
/// rito del sogno non passa cio' che si e' sognato: la scena manda il gesto e
/// basta". Non mancava una condizione: mancava il sogno annotato.
///
/// **Cosa tiene, e cosa non tiene.** Tiene la data, i simboli scelti e le
/// parole che la persona scrive. Non manda niente a nessuno: e' un quaderno
/// sul telefono, come il diario del cammino, e nessuna riga di questo file
/// parla col server. Il testo di un sogno e' la cosa piu' privata che questa
/// app possa custodire.
///
/// **Quanti se ne tengono, dichiarato**: gli ultimi [quantiSogni]. Un diario
/// che cresce senza fine su `SharedPreferences` diventa un file di megabyte
/// che si rilegge a ogni avvio.
class SognoAnnotato {
  const SognoAnnotato({
    required this.quando,
    required this.simboli,
    required this.parole,
    this.riletto = false,
  });

  /// Il giorno in cui e' stato annotato.
  final DateTime quando;

  /// I simboli scelti fra quelli offerti dalla scena.
  final List<String> simboli;

  /// Le parole della persona, che restano sul telefono.
  final String parole;

  /// Vero da quando quel sogno e' stato riaperto e riletto.
  final bool riletto;

  SognoAnnotato conRiletto() => SognoAnnotato(
        quando: quando,
        simboli: simboli,
        parole: parole,
        riletto: true,
      );

  Map<String, Object?> get json => {
        'quando': quando.toIso8601String(),
        'simboli': simboli,
        'parole': parole,
        'riletto': riletto,
      };

  static SognoAnnotato? da(Object? grezzo) {
    if (grezzo is! Map) return null;
    final quando = DateTime.tryParse('${grezzo['quando']}');
    if (quando == null) return null;
    final simboli = grezzo['simboli'];
    return SognoAnnotato(
      quando: quando,
      simboli: [
        if (simboli is List)
          for (final s in simboli) '$s',
      ],
      parole: '${grezzo['parole'] ?? ''}',
      riletto: grezzo['riletto'] == true,
    );
  }
}

/// Il quaderno dei sogni annotati, sul telefono e in nessun altro posto.
class DiarioDeiSogni extends ChangeNotifier {
  DiarioDeiSogni({DateTime Function()? orologio})
      : _orologio = orologio ?? DateTime.now;

  final DateTime Function() _orologio;

  static const String _chiave = 'sogni.annotati';

  /// Quanti sogni si tengono. Oltre, il piu' vecchio esce.
  static const int quantiSogni = 60;

  final List<SognoAnnotato> _sogni = [];

  List<SognoAnnotato> get sogni => List.unmodifiable(_sogni);

  bool get vuoto => _sogni.isEmpty;

  /// **I SIMBOLI CHE LA SCENA OFFRE.** Non sono un elenco inventato: sono le
  /// figure che questa app gia' custodisce e sa nominare, cosi' un simbolo
  /// scelto qui parla la stessa lingua del resto del Cerchio. Gli animali
  /// guida ci sono tutti e dodici, perche' una delle tre voci chiede proprio
  /// che il PROPRIO animale compaia in un sogno.
  static const List<String> simboliOfferti = [
    'Lupo', 'Cervo', 'Corvo', 'Orso', 'Serpente', 'Gufo',
    'Aquila', 'Volpe', 'Cavallo', 'Farfalla', 'Delfino', 'Ragno',
    'Acqua', 'Fuoco', 'Bosco', 'Casa', 'Volo', 'Caduta',
    'Porta', 'Strada', 'Specchio', 'Luce', 'Buio', 'Voce',
  ];

  /// **CHI SE NE VA PORTA VIA ANCHE I SOGNI. Ordine BE voce 07, richiamato
  /// dall'ordine BX voce 11.** La cancellazione porta via tutto, telefono,
  /// server e backup insieme, e questa memoria non e' l'eccezione che
  /// sopravvive: qui si svuota cio' che sta in mano, e la chiave sul disco la
  /// porta via `DimenticanzaDelTelefono` col prefisso `sogni.`.
  void dimenticaChiSeNeVa() {
    _sogni.clear();
    notifyListeners();
  }

  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grezzo = prefs.getString(_chiave);
      if (grezzo == null) return;
      final letto = jsonDecode(grezzo);
      if (letto is! List) return;
      _sogni.clear();
      for (final v in letto) {
        final sogno = SognoAnnotato.da(v);
        if (sogno != null) _sogni.add(sogno);
      }
      notifyListeners();
    } catch (errore) {
      // Un quaderno illeggibile vale come quaderno vuoto: si riparte, e non
      // si spegne il rito per una chiave.
    }
  }

  Future<void> _salva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _chiave, jsonEncode([for (final s in _sogni) s.json]));
    } catch (errore) {
      // Stessa ragione del caricamento: il rito non si ferma per il disco.
    }
  }

  /// Annota un sogno e lo mette in cima.
  Future<SognoAnnotato> annota({
    required List<String> simboli,
    required String parole,
  }) async {
    final sogno = SognoAnnotato(
      quando: _orologio(),
      simboli: List.unmodifiable(simboli),
      parole: parole.trim(),
    );
    _sogni.insert(0, sogno);
    if (_sogni.length > quantiSogni) _sogni.removeRange(quantiSogni, _sogni.length);
    notifyListeners();
    await _salva();
    return sogno;
  }

  /// Segna che un sogno e' stato riletto, e dice **quanti giorni erano
  /// passati**: e' la grandezza che il corpus chiede, "a distanza di giorni".
  Future<int> rileggi(SognoAnnotato sogno) async {
    final i = _sogni.indexWhere((s) => s.quando == sogno.quando);
    if (i < 0) return 0;
    _sogni[i] = _sogni[i].conRiletto();
    notifyListeners();
    await _salva();
    return _orologio().difference(sogno.quando).inDays;
  }

  /// Quante volte torna il simbolo piu' insistente, fra tutti i sogni
  /// annotati. E' la risposta a "lo stesso simbolo torna in due sogni".
  int get quanteVolteIlSimboloPiuInsistente {
    final conta = <String, int>{};
    for (final sogno in _sogni) {
      // Lo stesso simbolo scelto due volte nello stesso sogno conta una:
      // il corpus chiede DUE SOGNI.
      for (final s in sogno.simboli.toSet()) {
        conta[s] = (conta[s] ?? 0) + 1;
      }
    }
    if (conta.isEmpty) return 0;
    return conta.values.reduce((a, b) => a > b ? a : b);
  }

  /// Vero se [animale] compare in almeno un sogno annotato.
  bool portaLAnimale(String animale) {
    final cercato = animale.toLowerCase();
    for (final sogno in _sogni) {
      for (final s in sogno.simboli) {
        if (s.toLowerCase() == cercato) return true;
      }
    }
    return false;
  }
}
