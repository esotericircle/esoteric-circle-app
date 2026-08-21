import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'rune_cast.dart' show RuneVerso;
import 'sunset_rune.dart';

/// Una sera salvata: il giorno rituale, la runa, il verso e le due voci.
class SeraSalvata {
  const SeraSalvata({
    required this.giorno,
    required this.rune,
    required this.inOmbra,
    required this.lasciare,
    required this.porta,
  });

  /// Il giorno rituale, in ISO yyyy-MM-dd.
  final String giorno;
  final String rune;
  final bool inOmbra;
  final String lasciare;
  final String porta;

  Map<String, dynamic> toJson() => {
        "giorno": giorno,
        "rune": rune,
        "ombra": inOmbra,
        "lasciare": lasciare,
        "porta": porta,
      };

  factory SeraSalvata.fromJson(Map<String, dynamic> j) => SeraSalvata(
        giorno: j["giorno"] as String,
        rune: j["rune"] as String,
        inOmbra: j["ombra"] as bool? ?? false,
        lasciare: j["lasciare"] as String? ?? "",
        porta: j["porta"] as String? ?? "",
      );

  DateTime get data => DateTime.parse(giorno);
}

/// La cerniera col Sigillo del Sogno: l'ultima runa portata dentro la notte.
class CernieraSogno {
  const CernieraSogno(
      {required this.giorno, required this.rune, required this.inOmbra});
  final String giorno;
  final String rune;
  final bool inOmbra;
}

/// La memoria settimanale della Runa del Tramonto, su `shared_preferences`.
///
/// Finestra mobile su SETTE GIORNI RITUALI, non su sette aperture: i giorni
/// saltati non consumano slot, la finestra e' per data. Best-effort come gli
/// altri store: se le preferenze non ci sono, non lancia, ritorna il vuoto.
class SunsetRuneMemory {
  const SunsetRuneMemory._();

  static const String _chiaveSettimana = "sunset_rune.settimana";
  static const int _giorniFinestra = 7;

  /// Le sere della settimana corrente, quelle entro i sette giorni rituali fino
  /// a [giornoRituale] compreso, in ordine dalla piu' vecchia alla piu' recente.
  static Future<List<SeraSalvata>> settimanaCorrente(
      DateTime giornoRituale) async {
    final tutte = await _leggi();
    final inizio =
        giornoRituale.subtract(const Duration(days: _giorniFinestra - 1));
    final dentro = tutte
        .where((s) => !s.data.isBefore(inizio) && !s.data.isAfter(giornoRituale))
        .toList()
      ..sort((a, b) => a.data.compareTo(b.data));
    return dentro;
  }

  /// Vero se la stessa runa e' gia' uscita nei sette giorni rituali che
  /// precedono [giornoRituale], oggi escluso.
  static Future<bool> runaRipetutaNegliUltimi7(
      String rune, DateTime giornoRituale) async {
    final tutte = await _leggi();
    final inizio =
        giornoRituale.subtract(const Duration(days: _giorniFinestra));
    return tutte.any((s) =>
        s.rune == rune &&
        s.data.isBefore(giornoRituale) &&
        !s.data.isBefore(inizio));
  }

  /// Salva la sera, una per giorno rituale, e pota la finestra ai sette giorni.
  /// Aggiorna anche la chiave della cerniera col Sigillo del Sogno.
  static Future<void> scriviEstrazione(SeraSalvata sera) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tutte = await _leggi();
      // Una sola sera per giorno rituale: si sostituisce quella del giorno.
      tutte.removeWhere((s) => s.giorno == sera.giorno);
      tutte.add(sera);
      // La finestra si ancora alla sera piu' recente fra tutte, non all'ordine
      // di scrittura, cosi' resta corretta anche se le sere arrivano fuori ordine.
      final recente = tutte
          .map((s) => s.data)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final inizio = recente.subtract(const Duration(days: _giorniFinestra - 1));
      final potate = tutte
          .where((s) => !s.data.isBefore(inizio) && !s.data.isAfter(recente))
          .toList()
        ..sort((a, b) => a.data.compareTo(b.data));
      await prefs.setString(
          _chiaveSettimana, jsonEncode(potate.map((s) => s.toJson()).toList()));
      await prefs.setString(
          SunsetRune.chiaveCerniera,
          jsonEncode({
            "giorno": sera.giorno,
            "rune": sera.rune,
            "ombra": sera.inOmbra,
          }));
    } catch (_) {
      // Best-effort: se le preferenze non ci sono, la sera non si salva.
    }
  }

  /// L'ultima runa portata dentro la notte, per la cerniera col Sogno.
  static Future<CernieraSogno?> ultimaPerCerniera() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(SunsetRune.chiaveCerniera);
      if (raw == null) return null;
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return CernieraSogno(
        giorno: j["giorno"] as String,
        rune: j["rune"] as String,
        inOmbra: j["ombra"] as bool? ?? false,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<List<SeraSalvata>> _leggi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_chiaveSettimana);
      if (raw == null) return [];
      final lista = jsonDecode(raw) as List<dynamic>;
      return lista
          .map((e) => SeraSalvata.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Costruisce la sera salvata da un'estrazione e dalle sue due voci.
  static SeraSalvata seraDa(
    EstrazioneTramonto e, {
    required String lasciare,
    required String porta,
  }) =>
      SeraSalvata(
        giorno: e.giornoIso,
        rune: e.rune.name,
        inOmbra: e.verso == RuneVerso.merkstave,
        lasciare: lasciare,
        porta: porta,
      );
}
