/// LE USCITE DELLE CARTE. Ordine FI voce 18, 11 ottobre 2026.
///
/// "La rotazione si guida dalla memoria, non dal caso": la variante dello
/// scheletro che si mostra dipende da quante volte quella carta, in quel
/// verso, e' gia' uscita a questa persona in quella posizione. La prima volta
/// la prima variante, la seconda la seconda, la terza la terza, poi si
/// ricomincia. Deterministico, come ogni elemento oracolare di questa app.
///
/// Si conta quando una stesa compiuta apre il responso, una volta sola:
/// rileggere la stesa conservata non conta di nuovo, come non spende carte
/// (voce FI.27). Vive in una chiave sola, si cancella con cio' che e' tuo e
/// torna col tuo account, come la stesa conservata.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'tarot_spread.dart';

abstract final class LeUsciteDelleCarte {
  /// La chiave del telefono: per posizione, carta e verso, quante uscite.
  static const String chiave = 'tarot.uscite_delle_carte';

  static String _di(DrawnCard d) =>
      '${d.position.name}|${d.card.name}|${d.reversed ? 'capovolta' : 'dritta'}';

  static Map<String, int> _leggi(SharedPreferences prefs) {
    final testo = prefs.getString(chiave);
    if (testo == null || testo.isEmpty) return {};
    try {
      return (jsonDecode(testo) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v is int ? v : 0));
    } on FormatException {
      return {};
    }
  }

  /// **CONTA LA STESA [carte]** e rende, per ogni carta nello stesso ordine,
  /// la sua uscita: quante volte era gia' uscita prima di questa, zero la
  /// prima volta. E' il numero che sceglie la variante
  /// (`LeCarteNellaPosizione.di`).
  static Future<List<int>> conta(List<DrawnCard> carte) async {
    final prefs = await SharedPreferences.getInstance();
    final uscite = _leggi(prefs);
    final esce = <int>[];
    for (final d in carte) {
      final n = uscite[_di(d)] ?? 0;
      esce.add(n);
      uscite[_di(d)] = n + 1;
    }
    await prefs.setString(chiave, jsonEncode(uscite));
    return esce;
  }
}
