import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../rituals/filo_del_giorno.dart';

/// Un responso che la persona ha avuto davanti oggi.
@immutable
class ResponsoDiOggi {
  const ResponsoDiOggi({
    required this.arte,
    required this.titolo,
    required this.testo,
  });

  /// L'arte o il Dono, l'identificativo di `ContiDelleArti`.
  final String arte;
  final String titolo;

  /// Il testo come la persona lo ha letto, con il suo "Da dove viene"
  /// quando l'arte ne ha uno.
  final String testo;

  Map<String, String> toJson() => {'a': arte, 't': titolo, 'x': testo};

  static ResponsoDiOggi? fromJson(Object? j) {
    if (j is! Map) return null;
    final a = j['a'], t = j['t'], x = j['x'];
    if (a is! String || t is! String || x is! String) return null;
    return ResponsoDiOggi(arte: a, titolo: t, testo: x);
  }
}

/// **I RESPONSI DI OGGI, PER IL MAESTRO.** Ordine EV voce 04, il fondatore:
/// *"Medora nega il transito del responso dell'oroscopo o altra funzionalità
/// da cui parte la domanda."*
///
/// Sulle catture dei fondatori la persona chiedeva a Medora che cosa volesse
/// dire "Urano è retrogrado", che l'Oroscopo le aveva appena mostrato, e
/// Medora rispondeva di non saperlo e chiedeva chi l'avesse scritto. Il
/// pulsante "Parlane con..." passava alla chat una sola frase con il segno,
/// e il responso restava fuori.
///
/// Qui si tengono i responsi che la persona ha avuto davanti oggi (ognuno
/// li registra quando compare, con le sue azioni), e quello da cui la persona
/// e' partita toccando "Parlane con...". Il Maestro li riceve tutti nel suo
/// contesto, quello di partenza per primo e per intero, e la regola di non
/// negarli. Si tengono sul telefono, per il giorno rituale: domani non
/// valgono piu'.
abstract final class IResponsiDiOggi {
  static const String _chiave = 'chat.responsi_di_oggi';

  /// Quanti responsi si tengono al massimo: gli ultimi. Dodici sono tutte
  /// le arti col responso di un giorno pieno, e l'Oroscopo del mattino non
  /// esce dal contesto la sera.
  static const int quanti = 12;

  /// Quanti caratteri di ogni responso arrivano al modello, quello di
  /// partenza escluso, che arriva intero. L'Oroscopo intero, con le sue
  /// schede e i loro "Da dove viene", sta sotto i 2400.
  static const int caratteri = 2400;

  static String _giorno = '';
  static final List<ResponsoDiOggi> _elenco = [];
  static ResponsoDiOggi? _partenza;
  static bool _caricati = false;

  /// Per le prove.
  @visibleForTesting
  static void dimentica() {
    _giorno = '';
    _elenco.clear();
    _partenza = null;
    _caricati = false;
  }

  static void _giornoDi(DateTime adesso) {
    final oggi = FiloDelGiorno.giornoRituale(adesso);
    if (oggi != _giorno) {
      _giorno = oggi;
      _elenco.clear();
      _partenza = null;
    }
  }

  /// Legge dal disco i responsi di oggi, una volta.
  static Future<void> carica({DateTime? adesso}) async {
    if (_caricati) return;
    _caricati = true;
    try {
      final p = await SharedPreferences.getInstance();
      final grezzo = p.getString(_chiave);
      if (grezzo == null) return;
      final j = jsonDecode(grezzo);
      if (j is! Map || j['g'] != FiloDelGiorno.giornoRituale(adesso ?? DateTime.now())) {
        return;
      }
      _giornoDi(adesso ?? DateTime.now());
      for (final r in (j['r'] as List? ?? const [])) {
        final v = ResponsoDiOggi.fromJson(r);
        if (v != null && !_elenco.any((e) => _stesso(e, v))) _elenco.add(v);
      }
    } catch (errore) {
      debugPrint('Responsi di oggi: il disco non si legge. $errore');
    }
  }

  static bool _stesso(ResponsoDiOggi a, ResponsoDiOggi b) =>
      a.arte == b.arte && a.titolo == b.titolo;

  static Future<void> _salva() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
          _chiave,
          jsonEncode({
            'g': _giorno,
            'r': [for (final r in _elenco) r.toJson()],
          }));
    } catch (errore) {
      debugPrint('Responsi di oggi: il disco non si scrive. $errore');
    }
  }

  /// Un responso e' comparso davanti alla persona.
  static void ricorda(ResponsoDiOggi r, {DateTime? adesso}) {
    if (r.testo.trim().isEmpty) return;
    _giornoDi(adesso ?? DateTime.now());
    _elenco.removeWhere((e) => _stesso(e, r));
    _elenco.add(r);
    while (_elenco.length > quanti) {
      _elenco.removeAt(0);
    }
    unawaited(_salva());
  }

  /// La persona ha toccato "Parlane con..." sotto questo responso.
  static void apri(ResponsoDiOggi r, {DateTime? adesso}) {
    ricorda(r, adesso: adesso);
    _partenza = r;
  }

  /// I responsi di oggi, il piu' recente per ultimo.
  static List<ResponsoDiOggi> di(DateTime adesso) {
    _giornoDi(adesso);
    return List.unmodifiable(_elenco);
  }

  /// Il responso da cui la persona e' partita, se e' di oggi.
  static ResponsoDiOggi? partenza(DateTime adesso) {
    _giornoDi(adesso);
    return _partenza;
  }

  /// **IL MAESTRO CHE CHIEDE QUALE RESPONSO, CON IL RESPONSO DAVANTI.**
  /// Ordine EV voce 04, banco del 1 ottobre 2026, seconda persona: a "Cosa
  /// vuol dire la carta che mi è uscita al centro della stesa?" Medora ha
  /// risposto "[[CHIEDO]] dovrei sapere quale carta ti è uscita", con la
  /// stesa nel contesto. Vero quando la risposta chiede un chiarimento e
  /// domanda quale, o dice di aver bisogno di sapere.
  static bool chiedeQuale(String risposta) =>
      risposta.contains('[[CHIEDO]]') &&
      RegExp(r'\b(quale|quali|dovrei sapere|ho bisogno di (sapere|conoscere)|'
              r'dimmi|raccontami)\b',
              caseSensitive: false)
          .hasMatch(risposta);

  /// La seconda richiesta, quando la prima risposta [chiedeQuale].
  static const String sollecito = 'Se la mia domanda parla di un responso '
      'che ho letto oggi, è tra quelli che hai nel contesto: rispondimi '
      'partendo da lì, senza chiedermelo. Se non ne parla, chiedimi pure '
      'quello che ti serve.';

  static String _taglia(String t, int n) =>
      t.length <= n ? t : '${t.substring(0, n).trimRight()} [...]';

  /// **IL BLOCCO PER IL MODELLO**, nullo quando oggi non c'e' niente.
  static String? bloccoPerIlModello(DateTime adesso) {
    final elenco = di(adesso);
    if (elenco.isEmpty) return null;
    final p = partenza(adesso);
    final righe = <String>[
      'I RESPONSI CHE LA PERSONA HA LETTO OGGI NELL\'APP. Sono fatti che '
          'l\'app le ha mostrato, calcolati dal cielo vero: se la persona ne '
          'chiede, parti da qui. Non dire mai di non saperli, non negarli, '
          'non chiedere chi li ha scritti: li ha scritti il Cerchio, cioè '
          'tu e gli altri Maestri. I pianeti e la Luna che un responso '
          'nomina sono quelli del cielo di oggi, salvo dove dice che sono '
          'di nascita: la Luna di oggi non è «la sua Luna», che è quella '
          'di nascita. Se la persona chiede di un responso di oggi senza '
          'nominarlo (la carta della stesa, le rune, la carta dell\'Alba, il '
          'messaggio, il saluto), è quello qui sotto: non chiederle quale.',
    ];
    if (p != null) {
      righe.add('LA PERSONA TI SCRIVE PARTENDO DA QUESTO RESPONSO '
          '(${p.titolo}):\n${p.testo}');
    }
    for (final r in elenco) {
      if (p != null && _stesso(r, p)) continue;
      righe.add('${r.titolo}:\n${_taglia(r.testo, caratteri)}');
    }
    return righe.join('\n\n');
  }
}
