import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'face_classifier.dart';
import 'face_trait.dart';

/// Una Costellazione del Viso gia' letta, con la sua data e la lettura intera.
@immutable
class FaceEsito {
  const FaceEsito({required this.quando, required this.reading});

  final DateTime quando;
  final FaceReading reading;

  Map<String, dynamic> toJson() => {
        'quando': quando.toIso8601String(),
        'letture': [
          for (final l in reading.letture)
            {'tratto': l.tratto.name, 'marcatezza': l.marcatezza},
        ],
      };

  static FaceEsito? fromJson(Map<String, dynamic> j) {
    final quando = DateTime.tryParse(j['quando'] as String? ?? '');
    if (quando == null) return null;
    final grezze = j['letture'];
    if (grezze is! List) return null;
    final letture = <TraitLettura>[];
    for (final r in grezze) {
      if (r is! Map) continue;
      final nome = r['tratto'];
      final marc = r['marcatezza'];
      FaceTrait? t;
      for (final v in FaceTrait.values) {
        if (v.name == nome) t = v;
      }
      if (t != null && marc is num) {
        letture.add(TraitLettura(tratto: t, marcatezza: marc.toDouble()));
      }
    }
    if (letture.isEmpty) return null;
    return FaceEsito(quando: quando, reading: FaceReading(letture: letture));
  }
}

/// Lo storico delle letture del viso, SOLO in locale sul dispositivo.
///
/// Serve al conteggio del giorno per il limite di frequenza, unica verita', e a
/// mostrare l'ultima lettura quando il limite e' raggiunto, cosi' non c'e' mai
/// un vicolo cieco. Nessuna immagine e nessuna foto: si salva solo la lettura
/// dei tratti, che sono testo.
class FaceHistory extends ChangeNotifier {
  FaceHistory({DateTime Function()? clock, int massimo = 40})
      : _clock = clock ?? DateTime.now,
        _massimo = massimo;

  static const String _chiave = 'viso.storico';

  final DateTime Function() _clock;
  final int _massimo;

  List<FaceEsito> _esiti = const [];

  List<FaceEsito> get esiti => List.unmodifiable(_esiti);

  FaceEsito? get ultimo => _esiti.isEmpty ? null : _esiti.first;

  int get fattiOggi {
    final oggi = _clock();
    return _esiti
        .where((e) =>
            e.quando.year == oggi.year &&
            e.quando.month == oggi.month &&
            e.quando.day == oggi.day)
        .length;
  }

  /// **IL VOLTO E' CAMBIATO DAVVERO? Ordine BX voce 11.**
  ///
  /// Il corpus chiede "la Costellazione del Viso ti rilegge a distanza di un
  /// mese e trova un tratto diverso": due condizioni insieme, la distanza e
  /// la differenza. Si guarda la lettura piu' RECENTE fra quelle vecchie di
  /// almeno un mese, e si confronta il tratto dominante di allora con quello
  /// di adesso.
  ///
  /// **Perche' vive qui e non nella schermata.** Stava dentro `_concludi`,
  /// in mezzo alla fotocamera e allo stato della scena, e nessuna prova
  /// poteva chiedergli niente: la guardia del mese passava anche togliendo
  /// il mese, perche' misurava la reazione del diario a un dettaglio scritto
  /// a mano invece della regola. **La grandezza misurata e' cambiata, non la
  /// soglia**: adesso e' la regola stessa a rispondere, e con le date vere.
  ///
  /// **Meno di un mese non basta**, e non e' pedanteria: due letture fatte
  /// nello stesso pomeriggio possono dare tratti diversi solo per la luce, e
  /// il gradino direbbe che il volto e' cambiato quando non e' cambiato
  /// niente.
  bool ilTrattoECambiatoInUnMese(FaceReading adesso) {
    final ora = _clock();
    final vecchie =
        _esiti.where((e) => ora.difference(e.quando).inDays >= 30).toList();
    if (vecchie.isEmpty) return false;
    final piuRecente =
        vecchie.reduce((a, b) => a.quando.isAfter(b.quando) ? a : b);
    return piuRecente.reading.dominante != adesso.dominante;
  }

  Future<void> carica() async {
    try {
      final p = await SharedPreferences.getInstance();
      final grezzo = p.getStringList(_chiave) ?? const [];
      final letti = <FaceEsito>[];
      for (final riga in grezzo) {
        final j = jsonDecode(riga);
        if (j is Map<String, dynamic>) {
          final e = FaceEsito.fromJson(j);
          if (e != null) letti.add(e);
        }
      }
      letti.sort((a, b) => b.quando.compareTo(a.quando));
      _esiti = letti;
      notifyListeners();
    } catch (_) {
      // Memoria non disponibile: si continua senza storico, mai un errore.
    }
  }

  Future<FaceEsito> registra(FaceReading reading) async {
    final esito = FaceEsito(quando: _clock(), reading: reading);
    _esiti = [esito, ..._esiti].take(_massimo).toList(growable: false);
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setStringList(
          _chiave, [for (final e in _esiti) jsonEncode(e.toJson())]);
    } catch (_) {
      // best effort: lo storico in memoria resta buono per la sessione.
    }
    return esito;
  }
}
