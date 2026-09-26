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
import '../../design_system/tokens/spacing_tokens.dart';
import '../schede/la_scheda_dell_arte.dart';
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
  /// La prima riga, le arti preferite, nel formato quadrato.
  static const String preferite = 'preferite';

  /// Le altre nove, nell'ordine del fondatore.
  static const List<RigaDellaCasa> righe = [
    (
      chiave: 'da_condividere',
      titolo: 'Da condividere',
      formato: FormatoDellaScheda.verticale,
      arti: [
        'face_constellation',
        'synastry_vip',
        'angel_numbers',
        'aura_analysis',
        'friends_compatibility',
        'magic_sigil',
        'lunar_affinity',
        'numerology',
        'pet_astrology',
      ],
    ),
    (
      chiave: 'amore_e_affinita',
      titolo: 'Amore e affinità',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'synastry_vip',
        'lunar_affinity',
        'synastry_depth',
        'friends_compatibility',
        'pet_astrology',
      ],
    ),
    (
      chiave: 'cerca_una_risposta',
      titolo: 'Cerca una risposta',
      formato: FormatoDellaScheda.verticale,
      arti: [
        'tarot_spread_three',
        'rune_draw',
        'crystal_oracle',
        'angels_oracle',
        'pendulum',
        'dream_reading',
        'i_ching',
        'coffee_reading',
      ],
    ),
    (
      chiave: 'le_stelle_parlano',
      titolo: 'Le stelle parlano',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'horoscope',
        'lunology',
        'narrative_destiny',
        'pet_astrology',
      ],
    ),
    (
      chiave: 'conosci_te_stesso',
      // Il titolo del fondatore; la marca del genere (ordine DL) lo accorda a
      // chi legge: al femminile "te stessa", altrimenti come l'ha scritto lui.
      titolo: '[Conosci te stesso|Conosci te stessa|Conosci te stesso]',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'numerology',
        'narrative_destiny',
        'guide_animal',
        'mood_tracker',
        'dream_reading',
      ],
    ),
    (
      chiave: 'il_tuo_corpo',
      titolo: 'Il tuo corpo',
      formato: FormatoDellaScheda.verticale,
      arti: [
        'face_constellation',
        'chakra_scan',
        'aura_analysis',
        'biorhythm',
      ],
    ),
    (
      chiave: 'la_tua_serenita',
      titolo: 'La tua serenità',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'meditation',
        'sleep_stories',
        'daily_affirmations',
        'micro_rituals',
        'mood_tracker',
      ],
    ),
    (
      chiave: 'la_tua_intenzione',
      titolo: 'La tua intenzione',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'magic_sigil',
        'daily_affirmations',
        'micro_rituals',
        'angel_numbers',
        'guide_animal',
      ],
    ),
    (
      chiave: 'la_tua_energia',
      titolo: 'La tua energia',
      formato: FormatoDellaScheda.orizzontale,
      arti: [
        'chakra_scan',
        'crystal_oracle',
        'aura_analysis',
        'energy_cleansing',
        'biorhythm',
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
    final scheda =
        LaSchedaDellArte.larghezzaPer(formato, scalaDelTesto: scalaDelTesto);
    var quante = 0;
    while (SpacingTokens.lg + quante * (scheda + LaRigaDelleSchede.spazio) <
        larghezzaVista) {
      quante++;
    }
    return quante;
  }

  /// **NESSUNA SCHEDA DOPPIA IN VISTA.** Richiesta del fondatore del 26
  /// settembre 2026, a ordine EO aperto: *"dalla apertura della home Senza
  /// spostare le categorie verso destra, fai in modo che scorrendo verso il
  /// basso non si vedano la stessa scheda funzionalità ... Se capitasse z
  /// cambia ordine di apparizione orizzontale e sposta la scheda doppione
  /// fuori dalla vista, cioè verso il fondo orizzontale della categoria."*
  ///
  /// Si scorrono le righe dall'alto. In ciascuna, i posti in vista
  /// ([visibili]) si riempiono con le arti non ancora viste piu' su,
  /// nell'ordine del fondatore; un'arte gia' vista che cadrebbe in vista va
  /// in fondo alla riga; le altre restano dove sono. **Dove le arti nuove non
  /// bastano a riempire la vista** il doppione resta, il primo dei rimandati:
  /// una riga non si accorcia per nasconderlo.
  static List<List<ArtEntry>> senzaDoppioniInVista(
      List<({List<ArtEntry> arti, int visibili})> righe) {
    final viste = <String>{};
    return [
      for (final r in righe)
        () {
          final davanti = <ArtEntry>[];
          final rimandate = <ArtEntry>[];
          final resto = <ArtEntry>[];
          for (final a in r.arti) {
            if (davanti.length < r.visibili) {
              (viste.contains(a.id) ? rimandate : davanti).add(a);
            } else {
              resto.add(a);
            }
          }
          while (davanti.length < r.visibili && resto.isNotEmpty) {
            final a = resto.removeAt(0);
            (viste.contains(a.id) ? rimandate : davanti).add(a);
          }
          while (davanti.length < r.visibili && rimandate.isNotEmpty) {
            davanti.add(rimandate.removeAt(0));
          }
          viste.addAll(davanti.map((a) => a.id));
          return [...davanti, ...resto, ...rimandate];
        }(),
    ];
  }
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
    // Le schede in vista si calcolano sulla larghezza vera dello schermo e
    // sulla scala del testo, che allarga le schede.
    final larghezzaVista = MediaQuery.sizeOf(context).width;
    final scala = MediaQuery.textScalerOf(context).scale(1);
    int inVista(FormatoDellaScheda f) =>
        LeRigheDellaCasa.visibiliSenzaScorrere(f,
            larghezzaVista: larghezzaVista, scalaDelTesto: scala);
    final ordinate = LeRigheDellaCasa.senzaDoppioniInVista([
      (
        arti: LeRigheDellaCasa.artiDi(ids),
        visibili: inVista(FormatoDellaScheda.quadrata)
      ),
      for (final r in LeRigheDellaCasa.righe)
        (arti: LeRigheDellaCasa.artiDi(r.arti), visibili: inVista(r.formato)),
    ]);
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
            formato: FormatoDellaScheda.quadrata,
            arti: ordinate.first,
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
              arti: ordinate[i + 1],
            ),
        ],
      ),
    );
  }
}
