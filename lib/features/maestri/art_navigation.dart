import 'package:flutter/widgets.dart';

import '../../core/astro/zodiac.dart';
import '../horoscope/oroscopo_screen.dart';
import '../maestri/aura/meditation/meditation_screen.dart';
import '../rituals/breath_destiny_screen.dart';
import '../rituals/day_oracle_screen.dart';
import '../rituals/sunset_rune_screen.dart';
import '../synastry/sinastria_vip_screen.dart';
import '../tarot/stesa_tre_carte_screen.dart';

/// La navigazione condivisa verso le arti del Cerchio: mappa l'id di un'arte
/// alla sua rotta, quando l'arte e' viva, oppure null se e' ancora dietro il
/// velo.
///
/// E' il punto unico dell'aggancio: lo usano il dominio del Maestro (il catalogo
/// categorizzato) e lo scaffale del Santuario, cosi' la stessa arte si apre
/// sempre alla stessa schermata, senza mappe duplicate che possono divergere.
/// Un test verifica che ogni arte dichiarata attiva nel catalogo abbia qui una
/// rotta vera.
Route<void>? artRouteFor(String id, {required Zodiac userSign}) {
  switch (id) {
    case 'horoscope':
      return OroscopoScreen.route(userSign: userSign);
    case 'synastry_vip':
      return SinastriaVipScreen.route(userSign: userSign);
    case 'tarot_spread_three':
      return StesaTreCarteScreen.route();
    case 'meditation':
      return MeditationScreen.route();
    case 'day_oracle':
      return DayOracleScreen.route();
    case 'sunset_rune':
      return SunsetRuneScreen.route();
    case 'breath_destiny':
      return BreathDestinyScreen.route();
    default:
      return null; // ancora dietro il velo
  }
}
