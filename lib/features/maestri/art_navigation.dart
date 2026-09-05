import 'package:flutter/widgets.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/astro/zodiac.dart';
import '../../core/maestro/maestro.dart';
import 'art_intro_screen.dart';
import 'aura/archetype/archetype_test_screen.dart';
import 'aura/face/face_constellation_screen.dart';
import 'caligo/animal/guide_animal_screen.dart';
import 'caligo/rune/rune_draw_screen.dart';
import 'caligo/sigillo/sigillo_intenzione_screen.dart';
import '../horoscope/oroscopo_screen.dart';
import '../maestri/aura/meditation/meditation_screen.dart';
import '../rituals/breath_destiny_screen.dart';
import '../rituals/day_oracle_screen.dart';
import '../rituals/sunset_rune_screen.dart';
import '../synastry/porta_della_sinastria.dart';
import '../tarot/stesa_tre_carte_screen.dart';
import '../../core/astro/night_sky.dart';
import '../account/dati_di_nascita_screen.dart';

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

/// IL SEGNO NON VIAGGIA PIU' COME PARAMETRO.
///
/// **Perche'.** L'Oroscopo diceva Gemelli a un Cancro. Questa funzione riceveva
/// `userSign` DA CHI APRE L'ARTE e lo passava a quattro schermate: chi chiamava
/// poteva comporlo a mano, e infatti lo componeva sbagliato. Nona occorrenza
/// della famiglia delle due porte.
///
/// Adesso il segno lo RICAVA la sorgente, dalla data di nascita che gia'
/// riceve, e nessun chiamante puo' comporlo: il parametro non esiste piu'.
///
/// **Senza data il segno NON esiste**, e non si ripiega su Gemelli ne su
/// nessun altro: le arti che hanno bisogno del segno mandano a darla, che e'
/// l'unica cosa utile da fare invece di mostrare il cielo di un altro.
Route<void>? artRouteFor(
  String id, {
  DateTime? userBirth,
  String? userName,
}) {
  // La sorgente unica: il segno discende dalla data, qui e in nessun altro
  // posto di questa catena.
  final Zodiac? userSign =
      userBirth == null ? null : NightSky.sunSign(userBirth);
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
      if (userSign == null) return DatiDiNascitaScreen.route();
      return GuideAnimalScreen.route(userSign: userSign, userBirth: userBirth);
    // L'Estrazione Rune ha ora la sua esperienza vera, non piu' la soglia:
    // lettura a richiesta e ripetibile, col selettore delle gettate.
    // Il Sigillo dell'Intenzione, terza distintiva di Caligo: dalla frase
    // scritta al glifo, col metodo di Spare sulla ruota della Golden Dawn.
    case 'magic_sigil':
      return SigilloIntenzioneScreen.route();
    case 'rune_draw':
      if (userSign == null) return DatiDiNascitaScreen.route();
      return RuneDrawScreen.route(userSign: userSign, userBirth: userBirth);
    case 'horoscope':
      // Senza data non c'e' oroscopo: si va a darla, invece di leggere il
      // cielo di qualcun altro.
      if (userSign == null) return DatiDiNascitaScreen.route();
      return OroscopoScreen.route(userSign: userSign);
    // **LA SINASTRIA VIP APRE SULLA PORTA, ordine CA voce 01.** Non piu' sulla
    // galleria di scelta: la prima cosa che si vede sono le due carte col
    // titolo sopra e le tre scelte, e la galleria e' il passo dopo.
    case 'synastry_vip':
      // Anche qui: senza data non c'e' sinastria, e si va a darla.
      if (userSign == null) return DatiDiNascitaScreen.route();
      return PortaDellaSinastria.route(
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
