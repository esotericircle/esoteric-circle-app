import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cielo_evolutivo.dart';
import 'legame_e_eta.dart';

/// **LE COPPIE GIA' SCOPERTE.** Ordine GD voci GD.16 e GD.22, 23 ottobre
/// 2026.
///
/// Il fondatore, GD.16: *"L'utente potrà scoprire la sinastria solo di una
/// tipologia alla volta [...] Se vorrà la sinastria di un'altra tipologia,
/// dovrà rifare una sinastria nuova"*. E la proposta approvata della GD.22:
/// la scheda di una coppia gia' scoperta porta la riga viva di oggi, e
/// rileggerla non consuma niente.
///
/// **COSA SI RICORDA, E COSA NO.** Per ogni sinastria letta il telefono
/// tiene solo un'impronta ([impronta]): un numero che nasce dal nome,
/// dal cielo dell'altra persona e dal legame, da cui la nascita non si
/// ricava. Nessuna data di nascita esce da qui: quelle degli amici offline
/// restano nella loro porta sola (`AmiciOffline`, GD.20). Sotto il prefisso
/// `sinastria.`, che l'uscita dall'account toglie con il resto
/// (`CioCheETuo`).
///
/// **LA COPPIA E' COPPIA PIU' LEGAME**: la stessa persona con un altro legame
/// ha un'altra impronta e quindi e' una sinastria nuova che consuma come
/// una coppia nuova (GD.16).
abstract final class LeCoppieScoperte {
  static const String chiave = 'sinastria.coppie_scoperte';

  /// Quante impronte si tengono: le piu' vecchie escono per prime.
  static const int massimo = 200;

  /// L'impronta della sinastria con [nome], dal suo [cielo], per il
  /// [legame]. FNV-1a a 64 bit, in esadecimale: stessa coppia e stesso
  /// legame, stessa impronta, su ogni telefono.
  static String impronta(String nome, CieloEvolutivo cielo, Legame legame) {
    final punti = [
      for (final p in PuntoDelCieloEvolutivo.values)
        // In centesimi di grado, interi: l'impronta non si mostra mai.
        ((cielo.longitudini[p] ?? -1) * 100).round(),
    ].join(',');
    final testo = '${nome.trim().toLowerCase()}|$punti|${cielo.oraNota}|'
        '${legame.name}';
    var h = 0xcbf29ce484222325;
    for (final unita in testo.codeUnits) {
      h ^= unita;
      // La moltiplicazione degli interi a 64 bit si avvolge da sola.
      h = h * 0x100000001b3;
    }
    return h.toUnsigned(64).toRadixString(16);
  }

  /// Se la sinastria con questa [impronta] e' gia' stata letta.
  static Future<bool> giaScoperta(String impronta) async {
    try {
      final p = await SharedPreferences.getInstance();
      return (p.getStringList(chiave) ?? const []).contains(impronta);
    } catch (senzaDisco) {
      debugPrint('Le coppie scoperte non si leggono: $senzaDisco');
      return false;
    }
  }

  /// Ricorda la sinastria con questa [impronta].
  static Future<void> segna(String impronta) async {
    try {
      final p = await SharedPreferences.getInstance();
      final tutte = [...?p.getStringList(chiave)]..remove(impronta);
      tutte.add(impronta);
      while (tutte.length > massimo) {
        tutte.removeAt(0);
      }
      await p.setStringList(chiave, tutte);
    } catch (senzaDisco) {
      debugPrint('La coppia scoperta non si ricorda: $senzaDisco');
    }
  }
}
