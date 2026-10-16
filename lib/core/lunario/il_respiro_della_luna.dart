import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'il_giorno_lunare.dart';
import 'il_motore_lunare.dart';

/// **I TEMPI DEL RESPIRO DELLA LUNA.** Ordine FX voce FX.04, 16 ottobre 2026.
///
/// **La scelta, e la ragione.** Alla Luna crescente l'inspiro dura piu'
/// dell'espiro (cinque tempi dentro, tre fuori): nelle pratiche di controllo
/// del fiato un'inspirazione piu' lunga dell'espirazione e' il rapporto che
/// si usa per respirare energizzante. Alla Luna calante il rapporto si
/// inverte (tre dentro, cinque fuori), che nelle stesse pratiche e' il
/// respiro che si dice calmante: un'espirazione piu' lunga placa. Alle due
/// sizigie, la Luna nuova e la Luna piena, i due tempi pesano uguale, quattro
/// e quattro, ne' la spinta ne' la resa: sono il cardine fra le due meta'
/// del mese.
///
/// **E' CHIAVE DI MEDORA, non tradizione.** Nessuna fonte documentata lega
/// l'accordatura alla fase lunare a un tempo di respiro preciso: il rapporto
/// energizzante/calmante viene dalla pratica generale del respiro, applicarlo
/// alla Luna crescente e calante e' una scelta del Cerchio. I testi del rito
/// lo dicono con queste parole, mai "tradizione" (ordine FX, regola
/// generale).
class TempiDelRespiroDellaLuna {
  const TempiDelRespiroDellaLuna(
      {required this.inspiro, required this.espiro});

  /// Quanto dura l'inspiro.
  final Duration inspiro;

  /// Quanto dura l'espiro.
  final Duration espiro;

  /// Un giro intero, inspiro piu' espiro.
  Duration get ciclo => inspiro + espiro;

  /// **QUANTI CICLI SERVONO PER AVVICINARSI A UN MINUTO.** Ordine FX voce
  /// FX.04: "un minuto di respiro guidato". Un minuto esatto taglierebbe un
  /// ciclo a meta', e un respiro interrotto a meta' e' peggio di un respiro
  /// un po' piu' lungo o un po' piu' corto: si arrotonda al ciclo intero
  /// piu' vicino ai sessanta secondi.
  int get cicliPerUnMinuto {
    final secondi = ciclo.inSeconds;
    if (secondi <= 0) return 1;
    final n = (60 / secondi).round();
    return n < 1 ? 1 : n;
  }

  /// Quanto dura il rito per intero, a cicli interi.
  Duration get interoRito => ciclo * cicliPerUnMinuto;

  /// Vero se questi tempi hanno senso: un respiro di zero secondi non e' un
  /// respiro.
  bool get reggono => inspiro > Duration.zero && espiro > Duration.zero;

  /// I tempi dalla fase lunare.
  static TempiDelRespiroDellaLuna perFase(FaseLunare fase) {
    switch (fase) {
      case FaseLunare.nuova:
      case FaseLunare.piena:
        return const TempiDelRespiroDellaLuna(
            inspiro: Duration(seconds: 4), espiro: Duration(seconds: 4));
      case FaseLunare.crescente:
      case FaseLunare.primoQuarto:
      case FaseLunare.gibbosaCrescente:
        return const TempiDelRespiroDellaLuna(
            inspiro: Duration(seconds: 5), espiro: Duration(seconds: 3));
      case FaseLunare.gibbosaCalante:
      case FaseLunare.ultimoQuarto:
      case FaseLunare.calante:
        return const TempiDelRespiroDellaLuna(
            inspiro: Duration(seconds: 3), espiro: Duration(seconds: 5));
    }
  }

  /// La stessa scelta, dall'elongazione vera di un istante (mezzogiorno
  /// locale, come il resto del lunario).
  static TempiDelRespiroDellaLuna diOggi(DateTime istante) =>
      perFase(IlMotoreLunare.faseDi(IlMotoreLunare.elongazione(istante)));
}

/// **I GIORNI RESPIRATI.** Ordine FX voce FX.04 e FX.05, 16 ottobre 2026.
///
/// Il flag locale che segna, per ogni giorno di calendario, se il Respiro
/// della Luna e' stato compiuto almeno una volta. E' la sola verita' che la
/// Collana delle Lune (FX.05) legge per accendere le sue perle: non e' una
/// striscia da non rompere, e' un elenco di giorni, e un giorno saltato
/// resta saltato, senza nessun rimprovero (la stessa regola della Collana,
/// scritta nell'ordine: "nessuna punizione").
///
/// **Dove vive**: sul telefono, nelle preferenze locali, come il portafoglio
/// del lunario (`GliEosDelLunario`) e i promemoria (`IPromemoriaDelLunario`):
/// stesso stile, stessa cartella.
class IlRespiroDellaLuna extends ChangeNotifier {
  static const String _chiave = 'respiro.giorniRespirati';

  final Set<String> _giorni = {};
  bool _letto = false;

  bool get letto => _letto;

  /// I giorni respirati, come 'aaaa-mm-gg'.
  Set<String> get giorni => Set.unmodifiable(_giorni);

  static String data(DateTime g) =>
      '${g.year.toString().padLeft(4, '0')}-'
      '${g.month.toString().padLeft(2, '0')}-'
      '${g.day.toString().padLeft(2, '0')}';

  /// Vero se [giorno] e' stato respirato, qualunque ora del giorno sia stata.
  bool eRespirato(DateTime giorno) => _giorni.contains(data(giorno));

  Future<void> leggi() async {
    try {
      final p = await SharedPreferences.getInstance();
      final grezzo = p.getString(_chiave);
      if (grezzo != null) {
        for (final g in (jsonDecode(grezzo) as List)) {
          _giorni.add('$g');
        }
      }
    } catch (errore) {
      debugPrint(
          'Respiro della Luna: i giorni respirati non si leggono ($errore)');
    }
    _letto = true;
    notifyListeners();
  }

  /// Segna [giorno] come respirato. **Idempotente**: rifare il rito piu'
  /// volte nello stesso giorno non accende una seconda perla, come vuole
  /// FX.04, "si puo' rifare quante volte si vuole, la perla resta una".
  Future<void> segnaRespirato(DateTime giorno) async {
    final chiave = data(giorno);
    if (_giorni.contains(chiave)) return;
    _giorni.add(chiave);
    notifyListeners();
    await _scrivi();
  }

  Future<void> _scrivi() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_chiave, jsonEncode(_giorni.toList()));
    } catch (errore) {
      debugPrint(
          'Respiro della Luna: i giorni respirati non si scrivono ($errore)');
    }
  }
}
