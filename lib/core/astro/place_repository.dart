import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'birth_place.dart';

/// Sorgente dei luoghi di nascita con ricerca a completamento automatico.
///
/// L'implementazione attuale carica l'elenco completo dei comuni italiani
/// (nome, provincia, coordinate) da un asset locale, cosi' la ricerca e'
/// istantanea e funziona offline. L'astrazione e' pronta a estendersi alle
/// citta' internazionali: bastera' aggiungere una sorgente che interroga la
/// ricerca geografica dell'API, dietro la stessa interfaccia.
abstract interface class PlaceRepository {
  Future<void> ensureLoaded();

  /// Suggerimenti per una query, ordinati per pertinenza.
  List<BirthPlace> search(String query, {int limit = 20});
}

/// Comuni italiani da asset locale piu' alcune citta' internazionali di riserva.
class ItalianComuniRepository implements PlaceRepository {
  ItalianComuniRepository({this.assetPath = 'assets/data/comuni_it.json'});

  final String assetPath;
  final List<BirthPlace> _places = [];
  bool _loaded = false;

  @override
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString(assetPath);
    final list = jsonDecode(raw) as List<dynamic>;
    _places
      ..clear()
      ..addAll(list.map((e) {
        final row = e as List<dynamic>;
        return BirthPlace(
          label: row[0] as String,
          province: row[1] as String,
          latitude: (row[2] as num).toDouble(),
          longitude: (row[3] as num).toDouble(),
          timezone: 'Europe/Rome',
        );
      }));
    // Le citta' internazionali restano in coda, disponibili alla ricerca.
    _places.addAll(BirthPlaces.international);
    _loaded = true;
  }

  @override
  List<BirthPlace> search(String query, {int limit = 20}) {
    final q = _normalize(query);
    if (q.isEmpty) {
      // Senza query, mostra alcune citta' principali come punto di partenza.
      return _seed;
    }
    final starts = <BirthPlace>[];
    final contains = <BirthPlace>[];
    for (final p in _places) {
      final name = _normalize(p.label);
      if (name.startsWith(q)) {
        starts.add(p);
      } else if (name.contains(q)) {
        contains.add(p);
      }
      if (starts.length >= limit) break;
    }
    final result = [...starts, ...contains];
    return result.length > limit ? result.sublist(0, limit) : result;
  }

  static String _normalize(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll('à', 'a')
      .replaceAll('è', 'e')
      .replaceAll('é', 'e')
      .replaceAll('ì', 'i')
      .replaceAll('ò', 'o')
      .replaceAll('ù', 'u');

  List<BirthPlace> get _seed {
    const wanted = ['Roma', 'Milano', 'Napoli', 'Torino', 'Palermo', 'Firenze'];
    final out = <BirthPlace>[];
    for (final w in wanted) {
      final match = _places.where((p) => p.label == w);
      if (match.isNotEmpty) out.add(match.first);
    }
    return out;
  }
}
