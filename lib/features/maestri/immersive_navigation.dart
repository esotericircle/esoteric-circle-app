import 'package:flutter/widgets.dart';

import '../../core/chat/immersive_intents.dart';
import '../rituals/day_oracle_screen.dart';
import '../rituals/sunset_rune_screen.dart';
import '../synastry/sinastria_vip_screen.dart';
import 'aura/meditation/meditation_screen.dart';

/// La navigazione condivisa verso le funzioni immersive: mappa un
/// [ImmersiveTarget] alla sua rotta, quando la funzione e' viva, oppure null se
/// e' ancora dietro il velo.
///
/// Un solo punto per l'aggancio, cosi' la chat (che instrada dagli intenti) e la
/// striscia "Scopri altre arti del Cerchio" aprono le stesse funzioni con le
/// stesse rotte, senza duplicare la mappa.
Route<void>? immersiveRouteFor(ImmersiveTarget target) {
  switch (target) {
    case ImmersiveTarget.oroscopoGiorno:
      return DayOracleScreen.route();
    case ImmersiveTarget.meditazione:
    case ImmersiveTarget.breathwork:
    case ImmersiveTarget.frequenze:
      return MeditationScreen.route();
    case ImmersiveTarget.lancioRune:
      return SunsetRuneScreen.route();
    case ImmersiveTarget.sinastriaVip:
      return SinastriaVipScreen.route();
    case ImmersiveTarget.tarocchiStesa:
    case ImmersiveTarget.cartaNatale:
    case ImmersiveTarget.costellazioneViso:
    case ImmersiveTarget.scanChakra:
    case ImmersiveTarget.sigilloMagico:
    case ImmersiveTarget.iChing:
    case ImmersiveTarget.pendolo:
    case ImmersiveTarget.ritualeCandela:
      return null; // ancora dietro il velo
  }
}
