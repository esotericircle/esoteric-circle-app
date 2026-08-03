import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/ai/registro_dei_guasti.dart';
import '../tempo/confine_del_giorno.dart';
import 'eco_del_maestro.dart';

/// DOVE VIVE L'ECO, e quanto dura.
///
/// **Sopravvive alla chiusura dell'app**, perche' e' una cosa da ritrovare
/// domani: se sparisse spegnendo il telefono non sarebbe un'eco, sarebbe una
/// notifica. Sta nelle preferenze locali, come il contatore delle domande.
///
/// **Dura fino al confine di MEZZANOTTE locale**, lo stesso confine dei tetti
/// d'uso e non quello rituale di mezzogiorno: la definizione sta in un punto
/// solo, [ConfineDelGiorno], e questo archivio la legge invece di riscriverla.
class ArchivioDellEco extends ChangeNotifier {
  ArchivioDellEco({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  static const String _chiave = 'eco.del.maestro';

  EcoDelMaestro? _eco;

  /// L'Eco che vale ADESSO, oppure null.
  ///
  /// Il controllo del giorno si fa qui, in lettura, e non con una pulizia
  /// programmata: un'app che non e' aperta a mezzanotte non puo' eseguire
  /// niente, e un'Eco che sparisce solo se qualcuno la guarda al momento
  /// giusto non sparirebbe mai. Chiedendo, la risposta e' sempre vera.
  EcoDelMaestro? get viva {
    final e = _eco;
    if (e == null) return null;
    return e.valeA(_clock()) ? e : null;
  }

  /// Posa una nuova Eco. Quella di prima lascia il posto: se ne porta UNA.
  Future<void> posa(EcoDelMaestro eco) async {
    _eco = eco;
    notifyListeners();
    await _salva();
  }

  /// Rilegge l'Eco salvata. Best effort: un guasto delle preferenze non deve
  /// impedire di aprire l'app.
  Future<void> carica() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final grezzo = prefs.getString(_chiave);
      if (grezzo == null || grezzo.isEmpty) return;
      final decodificato = jsonDecode(grezzo);
      if (decodificato is! Map) return;
      _eco = EcoDelMaestro.daMappa(Map<String, Object?>.from(decodificato));
      notifyListeners();
    } catch (errore, traccia) {
      // Una preferenza illeggibile vale come nessuna Eco, e NON si tace: il
      // sintomo sarebbe "l'Eco non c'e' mai" senza nessun modo di sapere
      // perche'. Non si rilancia, perche' un'Eco mancante non deve impedire
      // di aprire l'app.
      annotaGuastoInnocuo('rileggendo l\'Eco salvata', errore, traccia);
    }
  }

  Future<void> _salva() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final e = _eco;
      if (e == null) {
        await prefs.remove(_chiave);
        return;
      }
      await prefs.setString(_chiave, jsonEncode(e.aMappa()));
    } catch (errore, traccia) {
      // Senza persistenza l'Eco vale per questa sessione e basta. Si scrive
      // comunque: una parola che sparisce spegnendo il telefono e' un difetto
      // da vedere, non da subire in silenzio.
      annotaGuastoInnocuo('salvando l\'Eco', errore, traccia);
    }
  }
}
