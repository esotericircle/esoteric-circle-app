import 'package:flutter/widgets.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/astro/zodiac.dart';
import '../../core/maestro/maestro.dart';
import 'art_intro_screen.dart';
import 'aura/archetype/archetype_test_screen.dart';
import 'aura/face/face_constellation_screen.dart';
import 'caligo/animal/guide_animal_screen.dart';
import 'caligo/rune/rune_draw_screen.dart';
import '../horoscope/oroscopo_screen.dart';
import '../maestri/aura/meditation/meditation_screen.dart';
import '../rituals/breath_destiny_screen.dart';
import '../rituals/day_oracle_screen.dart';
import '../rituals/sunset_rune_screen.dart';
import '../synastry/sinastria_gallery_screen.dart';
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
/// Le arti dichiarate vive che non hanno ancora la loro esperienza scritta.
///
/// Si aprono sulla SOGLIA dell'arte, che le presenta e porta alla Consulta del
/// Maestro che le custodisce: una destinazione vera, mai un vicolo cieco. Ogni
/// riga qui e' un debito dichiarato, e sparisce da sola il giorno in cui
/// l'esperienza arriva e prende il suo posto nello switch qui sotto.
///
/// Oggi la mappa e' VUOTA: ogni arte dichiarata attiva ha la sua esperienza
/// vera. L'Albero della Vita, l'ultima che stava qui, e' uscito del tutto dalla
/// Demo; il concetto resta nei documenti per la Fase 2 del Journal. La mappa
/// resta come meccanismo, pronta se una nuova arte nascesse prima della sua
/// esperienza.
const Map<String, Maestro> artiSullaSoglia = <String, Maestro>{};

Route<void>? artRouteFor(
  String id, {
  required Zodiac userSign,
  DateTime? userBirth,
  String? userName,
}) {
  final sullaSoglia = artiSullaSoglia[id];
  if (sullaSoglia != null) {
    final art = ArtCatalog.all.firstWhere((a) => a.id == id);
    return ArtIntroScreen.route(art: art, maestro: sullaSoglia);
  }
  switch (id) {
    // Il Test Archetipo ha ora la sua esperienza vera, non piu' la soglia.
    case 'archetype_test':
      return ArchetypeTestScreen.route();
    // La Costellazione del Viso ha ora la sua esperienza vera, non piu' la soglia.
    case 'face_constellation':
      return FaceConstellationScreen.route();
    // L'Animale Guida ha ora la sua esperienza vera, non piu' la soglia. Nasce
    // dal segno; l'archetipo, se c'e', lo legge da se' dallo storico locale.
    case 'guide_animal':
      return GuideAnimalScreen.route(userSign: userSign, userBirth: userBirth);
    // L'Estrazione Rune ha ora la sua esperienza vera, non piu' la soglia:
    // lettura a richiesta e ripetibile, col selettore delle gettate.
    case 'rune_draw':
      return RuneDrawScreen.route(userSign: userSign, userBirth: userBirth);
    case 'horoscope':
      return OroscopoScreen.route(userSign: userSign);
    // La Sinastria VIP apre sulla galleria di scelta del VIP, non piu' su un
    // risultato precaricato: si sceglie, poi si vede il responso.
    case 'synastry_vip':
      return SinastriaGalleryScreen.route(
          userSign: userSign, userBirth: userBirth, userName: userName);
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
