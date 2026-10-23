import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE ARTI DEL GIORNO E IL LORO PUNTINO D'ORO.** Ordine EP voce 06, 26
/// settembre 2026.
///
/// Il fondatore, sui consigli presi dagli streaming: *"Puntino d'oro
/// nuovo"*, *"Sulle arti che cambiano ogni giorno, finché non le apri."*
///
/// **Quali sono**, lette dal catalogo: le arti il cui contenuto cambia da
/// solo col giorno, senza che la persona estragga o scriva qualcosa.
/// - `horoscope`, Oroscopo Personalizzato: *"Le quattro schede del tuo
///   giorno"*;
/// - `daily_affirmations`, Affermazioni del Giorno: *"cucita sul tuo cielo
///   del giorno"*;
/// - `biorhythm`, Bioritmo: le tre onde si spostano ogni giorno;
/// - `lunology`, Il Respiro della Luna: la fase e la Luna nel segno del
///   presente.
///
/// **Restano fuori**, con la ragione: l'Oracolo dei Cristalli (*"la pietra
/// che ti parla oggi"*) e le altre estrazioni, perche' il contenuto nasce
/// dal gesto e non dal giorno; il Mood Tracker, perche' il suo contenuto lo
/// scrive la persona.
///
/// Il puntino c'e' finche' quel giorno la persona non apre l'arte, da
/// qualunque strada; il giorno dopo torna. Il giorno si ricorda sul telefono.
class LeArtiDelGiorno extends ChangeNotifier {
  LeArtiDelGiorno._();

  /// Una sola memoria per tutta l'app: la scheda la ascolta, le porte che
  /// aprono un'arte la avvisano.
  static final LeArtiDelGiorno istanza = LeArtiDelGiorno._();

  static const Set<String> ids = {
    'horoscope',
    'daily_affirmations',
    'biorhythm',
    'lunology',
  };

  /// La chiave sul telefono: `aaaa-mm-gg|id,id`.
  static const String chiave = 'arti_del_giorno.aperte';

  /// L'ora del giorno; le prove la spostano per vedere tornare il puntino.
  static DateTime Function() adesso = DateTime.now;

  String? _giorno;
  Set<String> _aperte = <String>{};
  bool _letta = false;

  static String giornoDi(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Se sulla scheda di [id] ci va il puntino.
  bool daVedere(String id) {
    if (!ids.contains(id)) return false;
    _leggi();
    return !(_giorno == giornoDi(adesso()) && _aperte.contains(id));
  }

  /// L'arte [id] e' stata aperta adesso.
  Future<void> aperta(String id) async {
    if (!ids.contains(id)) return;
    await _leggi();
    final oggi = giornoDi(adesso());
    if (_giorno != oggi) {
      _giorno = oggi;
      _aperte = <String>{};
    }
    if (!_aperte.add(id)) return;
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(chiave, '$oggi|${_aperte.join(',')}');
    } catch (errore) {
      // Senza disco il puntino resta spento per oggi in memoria: si annota.
      debugPrint('LE ARTI DEL GIORNO: non ho scritto sul telefono: $errore');
    }
  }

  Future<void> _leggi() async {
    if (_letta) return;
    _letta = true;
    try {
      final p = await SharedPreferences.getInstance();
      final detto = p.getString(chiave);
      if (detto == null) return;
      final parti = detto.split('|');
      _giorno = parti.first;
      _aperte = parti.length > 1 && parti[1].isNotEmpty
          ? parti[1].split(',').toSet()
          : <String>{};
      notifyListeners();
    } catch (errore) {
      debugPrint('LE ARTI DEL GIORNO: non ho letto dal telefono: $errore');
    }
  }

  /// Per le prove: dimentica tutto e torna all'ora vera.
  @visibleForTesting
  void azzera() {
    _giorno = null;
    _aperte = <String>{};
    _letta = false;
    adesso = DateTime.now;
  }
}
