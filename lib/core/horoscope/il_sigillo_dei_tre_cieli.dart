import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../rituals/filo_del_giorno.dart';
import 'astro_tradition.dart';
import 'i_tre_cieli.dart';

/// Lo stato del Sigillo in un giorno: quali tradizioni sono state lette, se
/// si e' acceso oggi, in quanti giorni si e' acceso in tutto.
class StatoDeiTreCieli {
  const StatoDeiTreCieli({
    required this.letteOggi,
    required this.accesoOggi,
    required this.giorni,
    this.appenaAcceso = false,
  });

  static const StatoDeiTreCieli vuoto =
      StatoDeiTreCieli(letteOggi: {}, accesoOggi: false, giorni: 0);

  final Set<AstroTradition> letteOggi;
  final bool accesoOggi;
  final int giorni;

  /// Vero solo nella lettura che l'ha acceso.
  final bool appenaAcceso;

  /// Le tradizioni che mancano ancora oggi, nell'ordine dei tre cieli.
  List<AstroTradition> get mancano => [
        for (final t in ITreCieli.tradizioni)
          if (!letteOggi.contains(t)) t,
      ];
}

/// **IL SIGILLO DEI TRE CIELI, ordine ES voce 37.**
///
/// La riga dell'Architetto, approvata dal fondatore con l'ordine: *"un
/// Sigillo "Tre Cieli" per chi legge tutte e tre le tradizioni nello stesso
/// giorno."*
///
/// **E' un Sigillo a parte, e non un gradino dei Sentieri**, per una ragione
/// che va detta: i gradini sono i 165 del corpus del fondatore
/// (`docs/corpus/Traguardi_165_Revisione_F.json`), ognuno con la sua
/// posizione e i suoi Eos, e il corpus non si cambia senza il suo si'. Questo
/// Sigillo si accende, si conta e si mostra accanto ai tre cieli, e non conia
/// Eos: l'economia dei Sentieri resta quella che il fondatore ha approvato.
/// Il giorno che lo vorra' fra i gradini, basta aggiungerlo al corpus.
///
/// **Il giorno e' quello rituale** (`FiloDelGiorno`), come per tutto cio' che
/// e' "di oggi" nel Cerchio: chi legge l'Occidentale alle undici di sera e la
/// Vedica all'una di notte le ha lette nella stessa giornata. Sta sul
/// telefono col prefisso `oroscopo_`, quindi se ne va coi dati e compare
/// nello scarico.
abstract final class IlSigilloDeiTreCieli {
  static const String chiave = 'oroscopo_tre_cieli';

  static Future<Map<String, Object?>> _leggi() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grezzo = prefs.getString(chiave);
      if (grezzo == null) return {};
      final j = jsonDecode(grezzo);
      return j is Map<String, Object?> ? j : {};
    } catch (errore) {
      // Un disco muto vale come nessuna lettura: il Sigillo riparte da zero
      // invece di fermare l'Oroscopo.
      return {};
    }
  }

  static StatoDeiTreCieli _stato(Map<String, Object?> j, String oggi,
      {bool appenaAcceso = false}) {
    final lette = j['giorno'] == oggi
        ? {
            for (final n in (j['lette'] as List? ?? const []))
              for (final t in ITreCieli.tradizioni)
                if (t.name == n) t,
          }
        : <AstroTradition>{};
    return StatoDeiTreCieli(
      letteOggi: lette,
      accesoOggi: j['ultimo'] == oggi,
      giorni: (j['giorni'] as num?)?.toInt() ?? 0,
      appenaAcceso: appenaAcceso,
    );
  }

  /// Lo stato di oggi, senza segnare niente.
  static Future<StatoDeiTreCieli> di(DateTime adesso) async =>
      _stato(await _leggi(), FiloDelGiorno.giornoRituale(adesso));

  /// Segna la lettura di [tradizione] e torna lo stato, con
  /// [StatoDeiTreCieli.appenaAcceso] vero se questa lettura ha acceso il
  /// Sigillo.
  static Future<StatoDeiTreCieli> segna(
      AstroTradition tradizione, DateTime adesso) async {
    if (!ITreCieli.tradizioni.contains(tradizione)) return di(adesso);
    final oggi = FiloDelGiorno.giornoRituale(adesso);
    final j = await _leggi();
    final lette = <String>{
      if (j['giorno'] == oggi) ...[
        for (final n in (j['lette'] as List? ?? const [])) '$n'
      ],
      tradizione.name,
    };
    var giorni = (j['giorni'] as num?)?.toInt() ?? 0;
    var ultimo = j['ultimo'];
    var appena = false;
    if (lette.length == ITreCieli.tradizioni.length && ultimo != oggi) {
      giorni++;
      ultimo = oggi;
      appena = true;
    }
    final nuovo = <String, Object?>{
      'giorno': oggi,
      'lette': lette.toList()..sort(),
      'giorni': giorni,
      'ultimo': ultimo,
    };
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(chiave, jsonEncode(nuovo));
    } catch (errore) {
      // Vale per questa sessione: lo stato torna comunque a chi lo mostra.
    }
    return _stato(nuovo, oggi, appenaAcceso: appena);
  }
}
