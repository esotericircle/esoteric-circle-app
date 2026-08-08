import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'natal_chart.dart';
import 'zodiac.dart';

/// LA CARTA NATALE SI CONSERVA, PERCHE' SENZA DI LEI L'APP DICE IL FALSO.
///
/// **Il difetto che ha fatto nascere questo file, voce 60 del Registro.** In
/// fondo all'Oroscopo compariva "senza ora e luogo di nascita i transiti sulla
/// tua carta non si possono calcolare" a Mauro, che ora e luogo li aveva dati.
/// La condizione non era scritta al rovescio e non guardava il campo
/// sbagliato: guardava il campo giusto, che pero' era VUOTO. La carta veniva
/// calcolata una volta sola, alla fine del Risveglio, e viveva solo in
/// memoria; riaperta l'app quel campo era nullo, il livello ricadeva su
/// "solo segno" e l'avviso compariva pur essendo ora e luogo salvi nel
/// profilo. Su iOS, dove il sistema uccide il processo di continuo, capitava
/// ancora piu' spesso.
///
/// **Non e' una cache: e' il posto dove la carta vive.** L'archivio del
/// profilo conserva data, ora e luogo, cioe' cio' che la persona ha DATO. La
/// carta e' il calcolo che ne discende, e ricalcolarla vuol dire una chiamata
/// di rete: conservarla qui e' cio' che permette all'app di sapere il vero
/// anche appena riaperta e anche senza rete.
class CartaConservata {
  const CartaConservata._();

  static const String _chiave = 'natal.chart.v1';

  /// Scrive la carta. Chiamata dove la carta nasce o cambia.
  static Future<void> conserva(NatalChart? carta) async {
    final prefs = await SharedPreferences.getInstance();
    if (carta == null) {
      await prefs.remove(_chiave);
      return;
    }
    await prefs.setString(_chiave, jsonEncode(_aMappa(carta)));
  }

  /// Rilegge la carta. Nulla quando non e' mai stata scritta, oppure quando
  /// cio' che e' scritto non si sa piu' leggere: in quel caso si torna a
  /// nulla invece di sollevare, perche' una carta illeggibile e' come una
  /// carta assente e l'app ha gia' il suo ripiego dichiarato per quel caso.
  static Future<NatalChart?> riprendi() async {
    final prefs = await SharedPreferences.getInstance();
    final testo = prefs.getString(_chiave);
    if (testo == null || testo.isEmpty) return null;
    try {
      final mappa = jsonDecode(testo) as Map<String, dynamic>;
      return _daMappa(mappa);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _aMappa(NatalChart c) => {
        'sunSign': c.sunSign.id,
        'moonSign': c.moonSign?.id,
        'ascendant': c.ascendant?.id,
        'ascendantLongitude': c.ascendantLongitude,
        'midheaven': c.midheaven?.id,
        'midheavenLongitude': c.midheavenLongitude,
        'hasTime': c.hasTime,
        'isEssential': c.isEssential,
        'planets': [
          for (final p in c.planets)
            {
              'id': p.id,
              'name': p.name,
              'glyph': p.glyph,
              'longitude': p.longitude,
              'sign': p.sign.id,
              'retrograde': p.retrograde,
              'house': p.house,
            }
        ],
        'houses': [
          for (final h in c.houses)
            {'number': h.number, 'longitude': h.longitude}
        ],
        'aspects': [
          for (final a in c.aspects)
            {
              'aLongitude': a.aLongitude,
              'bLongitude': a.bLongitude,
              'type': a.type.name,
              'aId': a.aId,
              'bId': a.bId,
              'applicativo': a.applicativo,
            }
        ],
      };

  static Zodiac? _segno(Object? id) {
    if (id is! String) return null;
    for (final z in Zodiac.values) {
      if (z.id == id) return z;
    }
    return null;
  }

  static NatalChart _daMappa(Map<String, dynamic> m) => NatalChart(
        sunSign: _segno(m['sunSign']) ?? Zodiac.aries,
        moonSign: _segno(m['moonSign']),
        ascendant: _segno(m['ascendant']),
        ascendantLongitude: (m['ascendantLongitude'] as num?)?.toDouble(),
        midheaven: _segno(m['midheaven']),
        midheavenLongitude: (m['midheavenLongitude'] as num?)?.toDouble(),
        hasTime: m['hasTime'] == true,
        isEssential: m['isEssential'] == true,
        planets: [
          for (final p in (m['planets'] as List? ?? []))
            PlanetPosition(
              id: p['id'] as String,
              name: p['name'] as String,
              glyph: p['glyph'] as String,
              longitude: (p['longitude'] as num).toDouble(),
              sign: _segno(p['sign']) ?? Zodiac.aries,
              retrograde: p['retrograde'] == true,
              house: (p['house'] as num?)?.toInt(),
            )
        ],
        houses: [
          for (final h in (m['houses'] as List? ?? []))
            HouseCusp(
              number: (h['number'] as num).toInt(),
              longitude: (h['longitude'] as num).toDouble(),
            )
        ],
        aspects: [
          for (final a in (m['aspects'] as List? ?? []))
            ChartAspect(
              aLongitude: (a['aLongitude'] as num).toDouble(),
              bLongitude: (a['bLongitude'] as num).toDouble(),
              type: AspectType.values.firstWhere(
                  (t) => t.name == a['type'],
                  orElse: () => AspectType.values.first),
              aId: a['aId'] as String?,
              bId: a['bId'] as String?,
              applicativo: a['applicativo'] as bool?,
            )
        ],
      );
}
