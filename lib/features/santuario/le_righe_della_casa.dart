import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/chat/la_marca_del_genere.dart';
import '../../core/arts/arti_preferite.dart';
import '../../core/arts/gli_sfondi_delle_schede.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../schede/la_luce_delle_schede.dart';
import '../maestri/rotta_arte.dart';
import '../schede/la_riga_delle_schede.dart';
import '../schede/la_scheda_dell_arte.dart';
import 'la_categoria_intera.dart';
import 'widgets/tue_arti_view.dart' show mostraSceltaArti;

/// Una riga della home: la chiave, il titolo, il formato, le arti in ordine.
typedef RigaDellaCasa = ({
  String chiave,
  String titolo,
  FormatoDellaScheda formato,
  List<String> arti,
});

/// **LE RIGHE DELLA HOME.** Ordine EO voce 09, 26 settembre 2026.
///
/// Il fondatore: *"Mi serve una proposta di ordine di comparsa di categorie
/// e arti"*, *"Le stelle parlano"*, e sulla proposta dell'Architetto *"Ok le
/// schede non funzionanti possiamo aggiungere in alto a sinistra un lucchetto
/// dorato anche"*; ogni categoria scorre in orizzontale e la pagina in
/// verticale, come Netflix; *"Le arti preferite"* restano in cima, gia'
/// compilate e personalizzabili. **Le righe e le schede stanno qui, in
/// quest'ordine, e in nessun altro posto.** Una stessa arte in righe diverse
/// apre sempre la stessa schermata, perche' la scheda chiede la rotta al
/// catalogo (`artRouteFor`).
abstract final class LeRigheDellaCasa {
  /// La prima riga, le arti preferite. **Verticale dall'ordine ER voce 08**:
  /// prima era quadrata.
  static const String preferite = 'preferite';

  /// La forma della riga delle preferite.
  static const FormatoDellaScheda formatoDellePreferite =
      FormatoDellaScheda.verticale;

  /// **LE UNDICI RIGHE DELL'ORDINE ER, voce 08, 27 settembre 2026**: dopo le
  /// preferite, dieci righe in quest'ordine, con la loro forma e le loro arti
  /// in quest'ordine. Il fondatore: *"rivediamo l'ordinamento delle categorie
  /// della home in modo da avere righe con schede verticali, poi orizzontali e
  /// poi quadrate"*, e sull'elenco dell'Architetto *"Per ora va bene così"*.
  ///
  /// **Le forme si alternano**: verticale (le preferite), orizzontale,
  /// quadrata, e da capo, cosi' che due righe vicine non abbiano mai la stessa
  /// forma. **I doppioni sono voluti**: le arti piu' virali stanno in due o tre
  /// righe per farsi vedere di piu'. Il Viaggio dello Sciamano sta solo in
  /// "Trova una risposta". In tutto si vedono le 66 arti del catalogo che hanno
  /// una scheda; l'Angelo Custode e il Test Archetipo restano nel Passaporto.
  ///
  /// **Prima** le righe erano dieci (con "Amore e affinità", "Da condividere" e
  /// "Le stelle parlano"), cinque coppie vicine su nove avevano la stessa
  /// forma, e in home stavano le sole trenta arti con lo sfondo.
  static const List<RigaDellaCasa> righe = [
    (
      chiave: 'trova_una_risposta',
      // Ordine EP voce 05: *"dopo le arti preferite, metti la categoria
      // "Cerca una risposta", ma cambiagli il nome in "trova una risposta""*.
      titolo: 'Trova una risposta',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'rune_draw',
        'tarot_spread_three',
        'guide_animal',
        'crystal_oracle',
        'i_ching',
        'angels_oracle',
        'pendulum',
        'crystal_ball',
        'coffee_reading',
        'cosmic_scan',
      ],
    ),
    (
      chiave: 'per_partner_e_amici',
      // Era "Da condividere". Il fondatore: *"La categoria "da condividere"
      // cambia in "per partner e in amici" e ci inserisci tutte le
      // compatibilità"*; la riga "Amore e affinità" non c'e' piu'.
      titolo: 'Per partner e amici',
      formato: FormatoDellaScheda.quadrata,
      arti: [
        'synastry_vip',
        'magia_rossa',
        'synastry_depth',
        'lunar_affinity',
        'friends_compatibility',
        'cosmic_dating',
        'sinastria_nfc',
      ],
    ),
    (
      chiave: 'il_cielo_ti_parla',
      // Era "Le stelle parlano". Il fondatore: *""le stelle parlano" cambia
      // in "il cielo ti parla" perché c'è Lunologia dentro"*.
      titolo: 'Il cielo ti parla',
      formato: FormatoDellaScheda.verticale,
      arti: [
        'horoscope',
        'mood_tracker',
        'lunology',
        'angel_numbers',
        'natal_chart',
        'biorhythm',
        'pet_astrology',
      ],
    ),
    (
      chiave: 'i_piu_condivisi',
      // Riga nuova. Il fondatore: *"le categorie della home sono create per
      // duplicare o triplicare alcune arti, le più virali, per dar loro
      // maggiore visibilità"*.
      titolo: 'I più condivisi',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'synastry_vip',
        'face_constellation',
        'horoscope',
        'magic_sigil',
        'tarot_spread_three',
        'cosmic_wrapped',
        'lunar_affinity',
      ],
    ),
    (
      chiave: 'conosci_te_stesso',
      // Il titolo del fondatore; la marca del genere (ordine DL) lo accorda a
      // chi legge: al femminile "te stessa", altrimenti come l'ha scritto lui.
      titolo: '[Conosci te stesso|Conosci te stessa|Conosci te stesso]',
      formato: FormatoDellaScheda.quadrata,
      arti: [
        'narrative_destiny',
        'specchio_anima',
        'human_design',
        'aura_analysis',
        'numerology',
        'percorso_risveglio',
        'cosmic_academy',
        'graphology',
        'cosmic_wrapped',
      ],
    ),
    (
      chiave: 'il_tuo_corpo',
      titolo: 'Il tuo corpo',
      formato: FormatoDellaScheda.verticale,
      arti: [
        'face_constellation',
        'fertility_windows',
        'palmistry',
        'magia_verde',
        'voice_analysis',
      ],
    ),
    (
      chiave: 'la_tua_serenita',
      titolo: 'La tua serenità',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'meditation',
        'dream_reading',
        'sleep_stories',
        'angel_cards',
        'breathwork',
        'daily_invocation',
        'lucid_dreams',
      ],
    ),
    (
      chiave: 'la_tua_energia',
      // Rifatta nell'ordine ER: il fondatore, *"Non ha senso avere categorie di
      // un solo colore, tanto vale che l'utente vada direttamente nel singolo
      // dominio"*.
      titolo: 'La tua energia',
      formato: FormatoDellaScheda.quadrata,
      arti: [
        'chakra_scan',
        'magia_bianca',
        'crystal_therapy',
        'astrocartography',
        'energy_cleansing',
        'alchimia',
        'mudra',
        'opera_al_nero',
      ],
    ),
    (
      chiave: 'la_tua_intenzione',
      titolo: 'La tua intenzione',
      formato: FormatoDellaScheda.verticale,
      arti: [
        'magic_sigil',
        'daily_affirmations',
        'micro_rituals',
        'lunar_calendar',
        'guided_rituals',
        'belief_art',
        'rituali_collettivi',
        'feng_shui',
      ],
    ),
    (
      chiave: 'il_tuo_destino',
      // Riga nuova dell'ordine ER.
      titolo: 'Il tuo destino',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'karmic_reading',
        'tree_of_life',
        'planetary_returns',
        'kabbalah',
        'time_machine',
      ],
    ),
  ];

  /// Le arti di una riga come si mostrano: dal catalogo, con la regola di
  /// visibilita' (nella Demo si mostra tutto).
  static List<ArtEntry> artiDi(List<String> ids) {
    final tutte = {for (final a in ArtCatalog.all) a.id: a};
    return [
      for (final id in ids)
        if (tutte[id] != null && ArtCatalog.isVisible(tutte[id]!)) tutte[id]!,
    ];
  }

  /// **Quante schede di una riga si vedono senza scorrere di lato**, in una
  /// vista larga [larghezzaVista]: conta anche quella tagliata dal bordo,
  /// perche' l'occhio la riconosce.
  static int visibiliSenzaScorrere(FormatoDellaScheda formato,
      {required double larghezzaVista, double scalaDelTesto = 1}) {
    final scheda = LaSchedaDellArte.larghezzaPer(formato,
        scalaDelTesto: scalaDelTesto, inCasa: true);
    var quante = 0;
    while (LaRigaDelleSchede.margineInCasa +
            quante * (scheda + LaRigaDelleSchede.spazioInCasa) <
        larghezzaVista) {
      quante++;
    }
    return quante;
  }

  // **LAPIDE, ordine ER voce 08, 27 settembre 2026.** Qui viveva
  // `senzaDoppioniInVista`, la richiesta del fondatore del 26 settembre: in
  // ogni riga le arti gia' viste piu' su andavano in fondo, fuori dalla vista.
  // Il fondatore l'ha tolta: *"Ok, togli regola del 26 settembre"*. Ogni riga
  // mostra le sue arti nell'ordine scritto qui sopra, anche quando un'arte si
  // vede gia' in una riga piu' su: i doppioni adesso sono voluti.
}

/// La vista delle righe, sotto il blocco dei Maestri.
class LeRigheDellaCasaView extends StatelessWidget {
  const LeRigheDellaCasaView({super.key, this.sensore = true});

  /// Falso nelle prove: il riflesso segue le righe.
  final bool sensore;

  @override
  Widget build(BuildContext context) {
    final preferite = context.watch<ArtiPreferiteController?>();
    final palette = MaestroScope.of(context);
    // Finche' il disco non ha risposto si mostra il seme, non un vuoto.
    final ids =
        preferite != null && preferite.caricato && preferite.ids.isNotEmpty
            ? preferite.ids
            : ArtiPreferiteController.semePer(
                context.read<MaestroController?>()?.activeMaestro);
    // Ogni riga nell'ordine scritto, doppioni compresi (ordine ER voce 08).
    final preferiteInOrdine = LeRigheDellaCasa.artiDi(ids);
    // "Vedi tutto" apre la riga intera nell'ordine del fondatore (EP.07).
    VoidCallback vediTutto(String chiave, String titolo, List<ArtEntry> arti) =>
        () => Navigator.of(context).push(LaCategoriaIntera.route(
            context: context, chiave: chiave, titolo: titolo, arti: arti));
    return LaLuceDelleSchede(
      sensore: sensore,
      child: Column(
        key: const Key('righe_della_casa'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LaRigaDelleSchede(
            key: const Key('tue_arti_titolo_riga'),
            chiave: LeRigheDellaCasa.preferite,
            titolo: 'Le arti preferite',
            chiaveDelTitolo: const Key('tue_arti_titolo'),
            // La pressione lunga toglie l'arte, senza dover entrare per
            // farlo: il gesto dello scaffale di prima resta.
            onTieni: preferite == null
                ? null
                : (art) => CuorePreferita.mostraEsito(
                      context,
                      preferite.cambia(art.id),
                      MaestroPalette.forKey(
                          ThemeKey.of(maestroDiArte(context, art.id))),
                    ),
            formato: LeRigheDellaCasa.formatoDellePreferite,
            arti: preferiteInOrdine,
            inCasa: true,
            onVediTutto: vediTutto(LeRigheDellaCasa.preferite,
                'Le arti preferite', preferiteInOrdine),
            azione: preferite == null
                ? null
                : IconButton(
                    key: const Key('tue_arti_matita'),
                    tooltip: 'Scegli le tue arti',
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.edit_outlined, color: palette.goldSoft),
                    onPressed: () => mostraSceltaArti(context),
                  ),
          ),
          for (var i = 0; i < LeRigheDellaCasa.righe.length; i++)
            LaRigaDelleSchede(
              chiave: LeRigheDellaCasa.righe[i].chiave,
              titolo:
                  LaMarcaDelGenere.risolvi(LeRigheDellaCasa.righe[i].titolo),
              formato: LeRigheDellaCasa.righe[i].formato,
              arti: LeRigheDellaCasa.artiDi(LeRigheDellaCasa.righe[i].arti),
              inCasa: true,
              onVediTutto: vediTutto(
                  LeRigheDellaCasa.righe[i].chiave,
                  LaMarcaDelGenere.risolvi(LeRigheDellaCasa.righe[i].titolo),
                  LeRigheDellaCasa.artiDi(LeRigheDellaCasa.righe[i].arti)),
            ),
        ],
      ),
    );
  }
}
