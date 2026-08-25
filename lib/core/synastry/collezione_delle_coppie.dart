import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'vip_catalog.dart';

/// UNA COPPIA SCOPERTA. Ordine BO voce 13.
///
/// **I due lati sono due nomi, e la stringa vuota sei tu.** Un modello che
/// distinguesse "persona" e "VIP" con due campi diversi avrebbe reso il
/// confronto fra due VIP un caso speciale, e i casi speciali sono il posto
/// dove le simmetrie si rompono.
@immutable
class CoppiaScoperta {
  const CoppiaScoperta({
    required this.primo,
    required this.secondo,
    required this.punteggio,
    required this.quando,
  });

  /// Il nome del primo lato, vuoto se sei tu.
  final String primo;

  /// Il nome del secondo lato: e' sempre un VIP.
  final String secondo;

  final int punteggio;

  /// Il giorno in cui l'hai scoperta.
  final DateTime quando;

  bool get seiTu => primo.isEmpty;

  /// **LA CHIAVE E' SIMMETRICA**, e questa e' la ragione per cui la
  /// riapertura non consuma: se la chiave dipendesse dall'ordine, invertire
  /// le due caselle avrebbe fatto sembrare nuova una coppia gia' scoperta, e
  /// il fondatore avrebbe pagato due volte la stessa cosa.
  static String chiaveDi(String a, String b) {
    final due = [a, b]..sort();
    return '${due.first}|${due.last}';
  }

  String get chiave => chiaveDi(primo, secondo);

  Map<String, Object?> toJson() => {
        'a': primo,
        'b': secondo,
        'p': punteggio,
        'q': quando.toIso8601String(),
      };

  static CoppiaScoperta? fromJson(Map<String, dynamic> j) {
    final a = j['a'];
    final b = j['b'];
    final p = j['p'];
    final q = DateTime.tryParse('${j['q']}');
    if (a is! String || b is! String || p is! int || q == null) return null;
    return CoppiaScoperta(primo: a, secondo: b, punteggio: p, quando: q);
  }
}

/// LA COLLEZIONE DELLE COPPIE. Ordine BO voce 13.
///
/// **Non una classifica di tutte le combinazioni: soltanto le tue.** Parole
/// del fondatore: "non sono convinto di fare vedere una classifica di tutte le
/// possibili combinazioni: non sarebbe meglio che l'utente li scoprisse da
/// solo e magari la schermata mostra solo la classifica delle coppie che ha
/// creato lui?".
///
/// **E i numeri gli danno ragione**: con cinquanta VIP le coppie possibili
/// sono 1.225, con duecento diventano 19.900. Una classifica di tutte non e'
/// una schermata, e calcolare diciannovemilanovecento sinastrie complete non
/// sta dentro nessun tetto di tempo a schermo. Qui le altre **non si vedono e
/// non si calcolano**.
class CollezioneDelleCoppie extends ChangeNotifier {
  CollezioneDelleCoppie();

  static const String _chiave = 'sinastria.collezione';

  final Map<String, CoppiaScoperta> _scoperte = {};

  /// Le coppie scoperte, **in fila per punteggio**, dalla piu' alta.
  /// A parita' di punteggio vince la piu' recente, cosi' l'ordine non balla.
  List<CoppiaScoperta> get inFila {
    final tutte = _scoperte.values.toList()
      ..sort((a, b) {
        final perPunteggio = b.punteggio.compareTo(a.punteggio);
        if (perPunteggio != 0) return perPunteggio;
        return b.quando.compareTo(a.quando);
      });
    return List.unmodifiable(tutte);
  }

  int get quante => _scoperte.length;

  bool get eVuota => _scoperte.isEmpty;

  /// **QUANTE COPPIE ESISTONO IN TUTTO, calcolate e mai scritte a mano.**
  ///
  /// Sono le combinazioni di due elementi fra i VIP piu' quelle fra te e ogni
  /// VIP: `n * (n - 1) / 2` per le prime e `n` per le seconde. Il giorno che i
  /// VIP diventano duecento il numero cambia da solo, e una prova lo verifica
  /// portando il catalogo a cinquantuno.
  static int totalePossibile([int? quantiVip]) {
    final n = quantiVip ?? VipCatalog.vips.length;
    return n * (n - 1) ~/ 2;
  }

  /// La riga in testa alla collezione: "12 coppie su 1.225".
  String get riepilogo {
    final totale = totalePossibile();
    return '$quante ${quante == 1 ? 'coppia' : 'coppie'} '
        'su ${_conIlPunto(totale)}';
  }

  static String _conIlPunto(int n) {
    if (n < 1000) return '$n';
    final migliaia = n ~/ 1000;
    final resto = (n % 1000).toString().padLeft(3, '0');
    return '$migliaia.$resto';
  }

  /// Se questa coppia e' gia' stata scoperta. **La riapertura non consuma**,
  /// e questo e' il metodo che lo decide.
  bool contiene(String a, String b) =>
      _scoperte.containsKey(CoppiaScoperta.chiaveDi(a, b));

  CoppiaScoperta? cerca(String a, String b) =>
      _scoperte[CoppiaScoperta.chiaveDi(a, b)];

  /// Segna una coppia come scoperta. Torna vero se e' NUOVA, cioe' se questa
  /// scoperta ha davvero aggiunto qualcosa: e' il valore su cui chi chiama
  /// decide se consumare.
  bool scopri({
    required String primo,
    required String secondo,
    required int punteggio,
    required DateTime quando,
  }) {
    final chiave = CoppiaScoperta.chiaveDi(primo, secondo);
    if (_scoperte.containsKey(chiave)) return false;
    _scoperte[chiave] = CoppiaScoperta(
        primo: primo, secondo: secondo, punteggio: punteggio, quando: quando);
    notifyListeners();
    unawaited(_scrivi());
    return true;
  }

  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grezzo = prefs.getString(_chiave);
      if (grezzo == null) return;
      final letto = jsonDecode(grezzo);
      if (letto is! List) return;
      for (final voce in letto) {
        if (voce is! Map) continue;
        final c = CoppiaScoperta.fromJson(Map<String, dynamic>.from(voce));
        if (c != null) _scoperte[c.chiave] = c;
      }
      notifyListeners();
    } catch (errore) {
      // Si ignora, e il perche' e' dichiarato: una collezione illeggibile
      // vale come collezione vuota, e la persona ricomincia a scoprire invece
      // di trovare una schermata rotta. Nessun Eos e' stato speso per
      // riaprire, quindi non si perde niente che sia stato pagato.
    }
  }

  Future<void> _scrivi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chiave,
          jsonEncode([for (final c in _scoperte.values) c.toJson()]));
    } catch (errore) {
      // Best effort, come gli altri archivi: il disco che non scrive non
      // ferma una scoperta.
    }
  }

  /// **CHI SE NE VA SI PORTA VIA LA SUA COLLEZIONE.**
  ///
  /// Le coppie scoperte sono dati di una persona: dicono chi ha guardato, e
  /// quando. Chi esce dal Cerchio non deve lasciarle a chi entra dopo sullo
  /// stesso telefono.
  Future<void> dimenticaChiSeNeVa() async {
    _scoperte.clear();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chiave);
    } catch (errore) {
      // Best effort come gli altri archivi: se il disco non risponde la
      // memoria e' comunque svuotata, e alla prossima scrittura sparisce
      // anche dal disco.
    }
  }

  @visibleForTesting
  void svuotaPerLaProva() {
    _scoperte.clear();
    notifyListeners();
  }
}
