import 'package:flutter/services.dart';

/// I CONTORNI VERI DELLE NAZIONI. Ordine BE voce 03.
///
/// **Parole del fondatore sulla 2199, maiuscole sue**: "la selezione della
/// citta' straniera FA SCHIFO, NON SI CAPISCE E NON SI INDIVIDUA NIENTE
/// PERCHE' LA NAZIONE NON E' RICOSTRUITA". Aveva ragione: la regione a
/// griglia dell'ordine BD usava i poligoni grossolani del planisfero, che
/// reggono da lontano e allo zoom diventano macchie.
///
/// **La fonte e' Natural Earth 1:110m, pubblico dominio**, gia' nominata nel
/// codice come lavoro di un altro giorno. L'asset `assets/data/nazioni.csv`
/// nasce da `tool/genera_nazioni.py`: 184 paesi agganciati al catalogo dei
/// luoghi COL VOTO DELLE LORO CITTA', non con una tavola di nomi che
/// invecchierebbe. I 57 rimasti fuori sono isole e microstati che la scala
/// 1:110m non disegna: per loro resta la regione con le coste, dichiarato.
class NazioniDelMondo {
  const NazioniDelMondo._();

  static Map<String, List<List<({double lat, double lon})>>>? _contorni;
  static Future<void>? _caricamento;

  /// Carica l'asset una volta sola.
  static Future<void> ensureLoaded({AssetBundle? bundle}) {
    return _caricamento ??= _carica(bundle ?? rootBundle);
  }

  static Future<void> _carica(AssetBundle bundle) async {
    final testo = await bundle.loadString('assets/data/nazioni.csv');
    final righe = testo.split('\n');
    final contorni = <String, List<List<({double lat, double lon})>>>{};
    var i = 1; // la prima riga e' la versione
    while (i < righe.length) {
      final testa = righe[i].trim();
      i++;
      if (testa.isEmpty) continue;
      final parti = testa.split(';');
      if (parti.length != 2) continue;
      final quanti = int.tryParse(parti[1]) ?? 0;
      final anelli = <List<({double lat, double lon})>>[];
      for (var k = 0; k < quanti && i < righe.length; k++, i++) {
        final punti = <({double lat, double lon})>[];
        for (final coppia in righe[i].trim().split(' ')) {
          final lonlat = coppia.split(',');
          if (lonlat.length != 2) continue;
          final lon = double.tryParse(lonlat[0]);
          final lat = double.tryParse(lonlat[1]);
          if (lon == null || lat == null) continue;
          punti.add((lat: lat, lon: lon));
        }
        if (punti.length >= 3) anelli.add(punti);
      }
      if (anelli.isNotEmpty) contorni[parti[0]] = anelli;
    }
    _contorni = contorni;
  }

  /// I contorni del paese, col nome italiano del catalogo, o nulla.
  static List<List<({double lat, double lon})>>? contorniDi(String paese) =>
      _contorni?[paese];

  /// Vero se quel punto cade dentro il paese.
  static bool dentro(
      double lat, double lon, List<List<({double lat, double lon})>> anelli) {
    for (final anello in anelli) {
      var dentro = false;
      var j = anello.length - 1;
      for (var i = 0; i < anello.length; i++) {
        final xi = anello[i].lon, yi = anello[i].lat;
        final xj = anello[j].lon, yj = anello[j].lat;
        if ((yi > lat) != (yj > lat) &&
            lon < (xj - xi) * (lat - yi) / (yj - yi) + xi) {
          dentro = !dentro;
        }
        j = i;
      }
      if (dentro) return true;
    }
    return false;
  }
}
