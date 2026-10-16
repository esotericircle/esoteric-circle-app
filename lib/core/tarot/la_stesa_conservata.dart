/// LA STESA SI CONSERVA. Ordine FI voci 26, 27 e 28, 10 ottobre 2026.
///
/// **Il difetto.** Il seme della stesa nasceva dal caso a ogni apertura della
/// schermata: chi usciva e rientrava con la stessa domanda vedeva carte
/// diverse, e poteva rilanciare finche' non usciva il responso che gli
/// piaceva. Il Master Briefing Tecnico prescrive il contrario, "la stessa
/// estrazione di carte (deterministica, dal motore oracoli)", e RETENTION
/// alla legge 6 vieta la ricompensa variabile sui responsi.
///
/// **La cura, scelta dal fondatore ("il tuo suggerimento", la via che
/// conserva).** Una stesa compiuta su una domanda resta quella per la
/// giornata: si conserva qui quando il responso si apre, e chi riapre la
/// stessa stesa con la stessa domanda ritrova le sue carte. Il motore del
/// mescolamento non si tocca, e il gesto resta vivo DENTRO la stesa in corso:
/// cio' che non cambia piu' e' la stesa gia' compiuta su quella domanda.
///
/// Come la memoria del presagio delle rune ("la stessa gettata con la stessa
/// domanda, lo stesso giorno, ridia lo stesso presagio"), vive in una chiave
/// sola, si cancella con cio' che e' tuo e torna col tuo account.
library;

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'tarot_card.dart';
import 'tarot_spread.dart';
import 'tarot_spread_type.dart';
import 'tarot_topic.dart';

abstract final class LaStesaConservata {
  /// La riga di Medora quando le carte tornano: la schermata lo dice invece
  /// di far finta di niente (voce 27).
  static const String riga = 'Su questa domanda le carte hanno già parlato '
      'oggi: sono le stesse di prima.';

  /// La chiave del telefono: giorno e stese di quel giorno.
  static const String chiave = 'tarot.stesa_conservata';

  /// LA FIRMA DI UNA STESA: il tipo e la domanda. La domanda scritta conta
  /// senza maiuscole, spazi doppi e punteggiatura in fondo ("Lo rivedrò?" e
  /// "lo rivedrò" sono la stessa domanda); senza domanda scritta conta
  /// l'argomento scelto.
  static String firma(TarotSpreadType tipo,
      {String? domandaScritta, required TarotTopic argomento}) {
    final scritta = (domandaScritta ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[\s?!.,;:…]+$'), '')
        .trim();
    return '${tipo.name}|${scritta.isEmpty ? 'argomento:${argomento.name}' : scritta}';
  }

  static String _giorno(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static Map<String, dynamic> _leggi(SharedPreferences prefs) {
    final testo = prefs.getString(chiave);
    if (testo == null || testo.isEmpty) return {};
    try {
      return jsonDecode(testo) as Map<String, dynamic>;
    } on FormatException {
      return {};
    }
  }

  /// La stesa conservata oggi con questa [firma], o nulla. Le posizioni sono
  /// quelle del [tipo], nell'ordine in cui la stesa e' stata posata.
  static Future<List<DrawnCard>?> ritrova(String firma, TarotSpreadType tipo,
      {DateTime? oggi}) async {
    final prefs = await SharedPreferences.getInstance();
    final dati = _leggi(prefs);
    if (dati['giorno'] != _giorno(oggi ?? DateTime.now())) return null;
    final carte = (dati['stese'] as Map? ?? {})[firma] as List?;
    if (carte == null || carte.length != tipo.posizioni.length) return null;
    final esce = <DrawnCard>[];
    for (var i = 0; i < carte.length; i++) {
      final voce = carte[i] as Map;
      final stem = voce['stem'] as String?;
      final carta = TarotDeck.cards.where((c) => c.stem == stem).firstOrNull;
      if (carta == null) return null;
      esce.add(DrawnCard(
        card: carta,
        position: tipo.posizioni[i],
        reversed: voce['rovescia'] == true,
      ));
    }
    return esce;
  }

  /// Le uscite delle carte della stesa conservata oggi con questa [firma],
  /// nello stesso ordine; zero per una carta conservata senza.
  static Future<List<int>?> usciteDi(String firma, {DateTime? oggi}) async {
    final prefs = await SharedPreferences.getInstance();
    final dati = _leggi(prefs);
    if (dati['giorno'] != _giorno(oggi ?? DateTime.now())) return null;
    final carte = (dati['stese'] as Map? ?? {})[firma] as List?;
    if (carte == null) return null;
    return [
      for (final voce in carte)
        (voce as Map)['uscita'] is int ? voce['uscita'] as int : 0,
    ];
  }

  /// Conserva la stesa compiuta con questa [firma] per la giornata. Le stese
  /// di ieri si tolgono: la chiave tiene solo il giorno di oggi.
  ///
  /// Con le [uscite] di ogni carta (voce FI.18): chi rilegge la stesa
  /// ritrova anche le stesse varianti, senza contarla di nuovo.
  static Future<void> conserva(String firma, List<DrawnCard> carte,
      {List<int>? uscite, DateTime? oggi}) async {
    final prefs = await SharedPreferences.getInstance();
    final giorno = _giorno(oggi ?? DateTime.now());
    final dati = _leggi(prefs);
    final stese = dati['giorno'] == giorno
        ? Map<String, dynamic>.of(
            (dati['stese'] as Map? ?? {}).cast<String, dynamic>())
        : <String, dynamic>{};
    stese[firma] = [
      for (var i = 0; i < carte.length; i++)
        {
          'stem': carte[i].card.stem,
          'rovescia': carte[i].reversed,
          if (uscite != null && i < uscite.length) 'uscita': uscite[i],
        },
    ];
    await prefs.setString(
        chiave, jsonEncode({'giorno': giorno, 'stese': stese}));
  }
}
