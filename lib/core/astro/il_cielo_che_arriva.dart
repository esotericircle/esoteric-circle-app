import 'dart:isolate';

import 'natal_chart.dart';
import 'prossimi_eventi.dart';
import 'zodiac.dart';

/// **IL CIELO CHE ARRIVA SI CALCOLA FUORI DAL FILO, UNA VOLTA. Ordine FE
/// voce 01.**
///
/// Il crash del tester sul Redmi Note 14 Pro 5G, build 2298: Crashlytics ha un
/// ANR, e lo stack tradotto coi simboli della stessa build dice dove. Alla
/// chiusura del LIVE la chat prepara il "Vai piu' a fondo", compone
/// l'istruzione del Maestro, e l'istruzione calcolava gli eventi in arrivo
/// dei prossimi 400 giorni ([ProssimiEventi.da]) giorno per giorno col motore
/// di Meeus, due volte di seguito, sul filo dell'interfaccia: 2,9 secondi sul
/// PC, oltre i cinque dell'ANR sul telefono. Lo stesso calcolo stava nel
/// `build` del calendario e nell'apertura del Passport.
///
/// Adesso e' la porta sola degli eventi in arrivo: [prepara] li calcola in un
/// isolate a parte e li tiene per quel giorno e quella persona; [gia] li
/// rende senza calcolare niente, o `null` se non sono ancora pronti. Fuori
/// da qui `lib` non chiama [ProssimiEventi.da] (la guardia
/// `il_cielo_che_arriva_non_ferma_l_interfaccia_test.dart`).
abstract final class IlCieloCheArriva {
  static final Map<String, List<EventoInArrivo>> _pronti = {};
  static final Map<String, Future<List<EventoInArrivo>>> _inCorso = {};

  /// Le prove contano i calcoli fatti davvero.
  static int calcoli = 0;

  static String _chiave(
          DateTime adesso, NatalChart? carta, Zodiac? segno, int orizzonte) =>
      '${adesso.year}-${adesso.month}-${adesso.day}|${segno?.name}|'
      '${carta == null ? '-' : identityHashCode(carta)}|$orizzonte';

  /// Gli eventi gia' pronti per quel giorno e quella persona, o `null`.
  static List<EventoInArrivo>? gia({
    required DateTime adesso,
    NatalChart? carta,
    Zodiac? segno,
    int orizzonte = ProssimiEventi.orizzonteDiGiorni,
  }) =>
      _pronti[_chiave(adesso, carta, segno, orizzonte)];

  /// Calcola gli eventi in arrivo in un isolate a parte, una volta per
  /// giorno e persona, e li rende.
  static Future<List<EventoInArrivo>> prepara({
    required DateTime adesso,
    NatalChart? carta,
    Zodiac? segno,
    int orizzonte = ProssimiEventi.orizzonteDiGiorni,
  }) {
    final chiave = _chiave(adesso, carta, segno, orizzonte);
    final pronti = _pronti[chiave];
    if (pronti != null) return Future.value(pronti);
    return _inCorso.putIfAbsent(chiave, () async {
      calcoli++;
      try {
        final eventi = await Isolate.run(() => ProssimiEventi.da(
            adesso: adesso, carta: carta, segno: segno, orizzonte: orizzonte));
        // Si tiene solo il giorno di oggi: i giorni passati non servono piu'.
        _pronti.removeWhere((k, _) => !k.startsWith(chiave.split('|').first));
        _pronti[chiave] = eventi;
        return eventi;
      } finally {
        _inCorso.remove(chiave);
      }
    });
  }

  /// Le prove ripartono da vuoto.
  static void dimentica() {
    _pronti.clear();
    _inCorso.clear();
    calcoli = 0;
  }
}
