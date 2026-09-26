import '../config/app_flags.dart';
import '../maestro/maestro.dart';
import 'art_catalog.dart';

/// Una sezione del dominio: il suo titolo e le arti, in ordine.
typedef SezioneDelDominio = ({String titolo, List<String> arti});

/// **L'ORDINE DI SEZIONI E SCHEDE NEI TRE DOMINI.** Ordine EO voce 10,
/// 26 settembre 2026.
///
/// Il fondatore: *"Bisogna decidere l'ordine di categorie e schede dei
/// singoli domini. Fai la tua proposta"*, poi *"Ok confermo, scrivi l'ordine
/// per Code."* **L'ordine vale anche contro la regola che mette prima le
/// sezioni con arti vive** (`ArtCatalog.visibleFor`): il dominio legge di
/// qui, e non da quella regola.
///
/// **Le arti del Maestro che non stanno qui** vanno nella riga "In arrivo"
/// in fondo al dominio (voce EO.13), se la regola di visibilita' le mostra.
/// **Chi vive solo nel Passaporto non sta in nessuna delle due** (voce EO.12).
abstract final class LOrdineDeiDomini {
  static const Map<Maestro, List<SezioneDelDominio>> _ordine = {
    Maestro.medora: [
      (titolo: 'Astrologia', arti: ['horoscope', 'pet_astrology']),
      (titolo: 'Cartomanzia', arti: ['tarot_spread_three', 'angels_oracle']),
      (
        titolo: 'Compatibilità',
        arti: ['synastry_vip', 'synastry_depth', 'friends_compatibility'],
      ),
      (titolo: 'Lunologia', arti: ['lunology', 'lunar_affinity']),
      (titolo: 'Destino', arti: ['narrative_destiny']),
    ],
    Maestro.aura: [
      (
        titolo: 'Energia',
        arti: [
          'meditation',
          'daily_affirmations',
          'sleep_stories',
          'mood_tracker',
          'biorhythm',
        ],
      ),
      (
        titolo: 'Chakra',
        arti: [
          'chakra_scan',
          'aura_analysis',
          'crystal_oracle',
          'energy_cleansing',
        ],
      ),
      (titolo: 'Fisiognomica', arti: ['face_constellation']),
    ],
    Maestro.caligo: [
      (
        titolo: 'Divinazione',
        arti: [
          'rune_draw',
          'pendulum',
          'dream_reading',
          'i_ching',
          'coffee_reading',
        ],
      ),
      (titolo: 'Rituali', arti: ['guide_animal', 'micro_rituals']),
      (titolo: 'Magia', arti: ['magic_sigil']),
      (titolo: 'Numerologia', arti: ['angel_numbers', 'numerology']),
    ],
  };

  /// Le sezioni del dominio di [maestro], nell'ordine del fondatore.
  static List<SezioneDelDominio> di(Maestro maestro) => _ordine[maestro]!;

  /// Le arti di una sezione come si mostrano: dal catalogo, nell'ordine
  /// della sezione, con la regola di visibilita'.
  static List<ArtEntry> artiDi(SezioneDelDominio sezione,
      {bool demo = AppFlags.isDemo}) {
    final tutte = {for (final a in ArtCatalog.all) a.id: a};
    return [
      for (final id in sezione.arti)
        if (tutte[id] case final a?)
          if (!a.soloNelPassaporto && ArtCatalog.isVisible(a, demo: demo)) a,
    ];
  }

  /// **LA RIGA "IN ARRIVO", ordine EO voce 13.** Le arti di [maestro] che
  /// non sono in nessuna sezione e che la regola di visibilita' mostra,
  /// nell'ordine del catalogo.
  static List<ArtEntry> inArrivo(Maestro maestro,
      {bool demo = AppFlags.isDemo}) {
    final nelleSezioni = {
      for (final s in di(maestro)) ...s.arti,
    };
    return [
      for (final s in ArtCatalog.forMaestro(maestro))
        for (final a in s.arts)
          if (!nelleSezioni.contains(a.id) &&
              !a.soloNelPassaporto &&
              ArtCatalog.isVisible(a, demo: demo))
            a,
    ];
  }
}
