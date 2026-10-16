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
/// Dall'ordine ER voce 10 non ce n'e' nessuna.
/// **Chi vive solo nel Passaporto non sta in nessuna delle due** (voce EO.12).
abstract final class LOrdineDeiDomini {
  // **ORDINE ER VOCE 10, 27 settembre 2026: OGNI ARTE NELLA SEZIONE DEL SUO
  // MAESTRO.** Le sezioni sono quelle dell'ordine EO; in ognuna, dopo le arti
  // che c'erano, entrano nell'ordine del fondatore le arti che finivano nella
  // riga "In arrivo" in fondo al dominio e le dodici arti nuove del briefing.
  // La riga "In arrivo" resta vuota, e vuota non si mostra.
  static const Map<Maestro, List<SezioneDelDominio>> _ordine = {
    Maestro.medora: [
      (
        titolo: 'Astrologia',
        arti: [
          'horoscope',
          'pet_astrology',
          'natal_chart',
          'planetary_returns',
          'astrocartography',
          'time_machine',
        ],
      ),
      (
        titolo: 'Cartomanzia',
        arti: [
          'tarot_spread_three',
          'angels_oracle',
          'angel_cards',
          'cosmic_scan',
        ],
      ),
      (
        titolo: 'Compatibilità',
        arti: [
          'synastry_vip',
          'synastry_depth',
          'friends_compatibility',
          'cosmic_dating',
          'sinastria_nfc',
        ],
      ),
      (
        titolo: 'Lunologia',
        arti: [
          'lunology',
          'lunar_affinity',
          'fertility_windows',
          'lunar_calendar',
        ],
      ),
      (
        titolo: 'Destino',
        arti: [
          'narrative_destiny',
          'karmic_reading',
        ],
      ),
    ],
    Maestro.aura: [
      (
        titolo: 'Energia',
        arti: [
          'meditation',
          'daily_affirmations',
          'sleep_stories',
          'soglia_del_sonno',
          'mood_tracker',
          'biorhythm',
          'mudra',
          'belief_art',
          'lucid_dreams',
          'breathwork',
          'percorso_risveglio',
        ],
      ),
      (
        titolo: 'Chakra',
        arti: [
          'chakra_scan',
          'aura_analysis',
          'crystal_oracle',
          'energy_cleansing',
          'crystal_therapy',
          'crystal_ball',
          'feng_shui',
        ],
      ),
      (
        titolo: 'Fisiognomica',
        arti: [
          'face_constellation',
          'palmistry',
          'graphology',
          'voice_analysis',
          'specchio_anima',
          // Ordine ER voce 20: dopo lo Specchio dell'Anima.
          'segreto_iride',
        ],
      ),
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
      (
        titolo: 'Rituali',
        arti: [
          'guide_animal',
          'micro_rituals',
          'daily_invocation',
          'guided_rituals',
          'rituali_collettivi',
        ],
      ),
      (
        titolo: 'Magia',
        arti: [
          'magic_sigil',
          'magia_rossa',
          'magia_bianca',
          'magia_verde',
          'opera_al_nero',
          'alchimia',
        ],
      ),
      (
        titolo: 'Numerologia',
        arti: [
          'angel_numbers',
          'numerology',
          'kabbalah',
          'human_design',
          'cosmic_wrapped',
          'tree_of_life',
          'cosmic_academy',
        ],
      ),
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
