import 'package:flutter/material.dart';

import '../../../../core/maestro/maestro.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// Le due famiglie di suggerimenti.
enum SuggestionGroup { frequent, personal }

extension SuggestionGroupLabel on SuggestionGroup {
  String get label => switch (this) {
        SuggestionGroup.frequent => 'Domande frequenti',
        SuggestionGroup.personal => 'Domande personali',
      };
}

/// Insiemi di domande suggerite per Maestro.
///
/// I Frequenti sono un piccolo insieme curato. I Personali pescano dalla carta
/// dell'utente, Sole, Luna e Ascendente. Finche' l'onboarding non fornisce i
/// segni reali, le formule restano generiche sui tre luminari, pronte a ricevere
/// i segni veri. L'aggancio agli scheletri e al Gateway arrivera' nel passo
/// dedicato.
class SuggestionSets {
  const SuggestionSets._();

  // Le cinque categorie canoniche in testa (amore, lavoro, fortuna, successo,
  // relazioni), declinate nel dominio del Maestro, poi qualche apertura propria.
  static const List<String> _frequentMedora = [
    'Cosa dicono le stelle sul mio amore?',
    'Che indicano gli astri sul mio lavoro?',
    'Dove si apre la mia fortuna in questi giorni?',
    'Le stelle sostengono un mio traguardo?',
    'Cosa muove le mie relazioni ora?',
    'Parlami del mio segno',
    'Tira una carta per me',
    'Parlami dei miei transiti',
  ];

  static const List<String> _personalMedora = [
    'Cosa illumina il mio Sole?',
    'Parlami del mio Sole',
    'La forza del mio Sole',
    'Il mio Sole come mi guida?',
    'Cosa sente la mia Luna?',
    'Parlami della mia Luna',
    'La mia Luna e le emozioni',
    'Il bisogno della mia Luna',
    'Cosa mostra il mio Ascendente?',
    'Parlami del mio Ascendente',
    'L\'Ascendente e la mia maschera',
    'La prima impressione del mio Ascendente',
  ];

  static const List<String> _frequentAura = [
    'Come apro il cuore all\'amore?',
    'Un respiro per la tensione del lavoro',
    'Come mi apro al flusso che arriva?',
    'Come trovo la calma prima di un traguardo?',
    'Come porto equilibrio nelle mie relazioni?',
    'Guidami in una meditazione breve',
    'Quale chakra devo riequilibrare?',
    'Un respiro per calmare la mente',
  ];

  static const List<String> _personalAura = [
    'Il mio Sole e la mia energia vitale',
    'Come nutro la luce del mio Sole?',
    'Il mio Sole e il chakra del plesso',
    'La forza del mio Sole nel corpo',
    'La mia Luna e il chakra del cuore',
    'Come accolgo le emozioni della mia Luna?',
    'La mia Luna e il respiro',
    'Il bisogno di quiete della mia Luna',
    'Il mio Ascendente e la mia presenza',
    'Come abito il mio Ascendente col respiro?',
    'Il mio Ascendente e l\'energia che mostro',
    'La prima impressione del mio Ascendente',
  ];

  static const List<String> _frequentCaligo = [
    'Quale runa parla del mio amore?',
    'Un simbolo per la forza nel lavoro',
    'Una runa per attirare abbondanza',
    'Quale rito sostiene un mio traguardo?',
    'Cosa dicono i simboli delle mie relazioni?',
    'Estrai una runa per me',
    'Un simbolo di protezione',
    'Qual è il mio animale guida?',
  ];

  static const List<String> _personalCaligo = [
    'Il mio Sole e la runa del potere',
    'Quale simbolo veste il mio Sole?',
    'Il mio Sole e la mia volontà',
    'L\'archetipo del mio Sole',
    'La mia Luna e la runa dell\'acqua',
    'Quale simbolo abita la mia Luna?',
    'La mia Luna e l\'ombra',
    'L\'archetipo della mia Luna',
    'Il mio Ascendente e la maschera rituale',
    'Quale runa apre il mio Ascendente?',
    'Il mio Ascendente e la soglia',
    'L\'archetipo del mio Ascendente',
  ];

  static List<String> frequent(Maestro maestro) => switch (maestro) {
        Maestro.medora => _frequentMedora,
        Maestro.aura => _frequentAura,
        Maestro.caligo => _frequentCaligo,
      };

  static List<String> personal(Maestro maestro) => switch (maestro) {
        Maestro.medora => _personalMedora,
        Maestro.aura => _personalAura,
        Maestro.caligo => _personalCaligo,
      };

  /// Quante vie si propongono sotto il benvenuto.
  ///
  /// **TRE, e non quattro.** Un invito iniziale e' un assaggio, non un menu:
  /// col quarto la colonna sotto il benvenuto diventa un elenco, e un elenco
  /// chiede di scegliere invece di invitare a cominciare. Il numero sta qui
  /// perche' possa essere letto e provato, invece di stare dentro la chiamata.
  static const int quanteVie = 3;

  /// I pochi chip d'avvio dello stato vuoto, un invito iniziale.
  static List<String> starters(Maestro maestro) =>
      frequent(maestro).take(quanteVie).toList(growable: false);

  static List<String> forGroup(Maestro maestro, SuggestionGroup group) =>
      switch (group) {
        SuggestionGroup.frequent => frequent(maestro),
        SuggestionGroup.personal => personal(maestro),
      };

  /// LE PERSONALI DISPONIBILI: una domanda che nomina un dato assente NON
  /// compare, invece di uscire col segnaposto. Il Sole chiede la data di
  /// nascita, la Luna e l'Ascendente chiedono la carta: se il contesto non
  /// li porta, le domande che li userebbero tacciono, per la regola del
  /// vero. Ordine 2161, voce 3.
  static List<String> personalDisponibili(
    Maestro maestro, {
    String? sunSign,
    String? moonSign,
    String? ascendant,
  }) =>
      personal(maestro).where((domanda) {
        final b = domanda.toLowerCase();
        if (b.contains('sole') && sunSign == null) return false;
        if (b.contains('luna') && moonSign == null) return false;
        if (b.contains('ascendente') && ascendant == null) return false;
        return true;
      }).toList(growable: false);

  /// LA ROTAZIONE E' DETERMINISTICA: stessa persona e stesso giorno, stesso
  /// ordine. E' l'hash FNV gia' usato altrove, mai un caso vero.
  static List<String> ruotaPerGiorno(
      List<String> domande, String persona, DateTime giorno) {
    if (domande.isEmpty) return domande;
    var h = 0x811c9dc5;
    for (final c
        in '$persona|${giorno.year}-${giorno.month}-${giorno.day}'.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    final da = h % domande.length;
    return [...domande.sublist(da), ...domande.sublist(0, da)];
  }
}

/// Apre il pannello dei suggerimenti che sale dal basso sopra il feed.
///
/// LE DUE FAMIGLIE INSIEME, ordine 2163 voce 3: prima erano due linguette
/// alternative e se ne leggeva una per volta. Adesso e' UN solo riquadro
/// scorrevole: l'intestazione DOMANDE FREQUENTI con le sue voci, poi
/// DOMANDE PERSONALI con le sue, e le intestazioni restano appiccicate in
/// alto mentre si scorre la loro sezione. Le liste arrivano dalla schermata
/// GIA' filtrate sul vero: una famiglia vuota non porta intestazione, per
/// la stessa regola del primo schermo. Il tocco su una domanda la invia e
/// chiude il pannello.
Future<void> showSuggestionsPanel(
  BuildContext context, {
  required Maestro maestro,
  required ValueChanged<String> onSend,
  required List<String> frequenti,
  required List<String> personali,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // Il foglio vive nell'overlay del navigator, fuori dal MaestroScope della
    // schermata: lo riavvolgiamo COL MAESTRO DELLA SCHERMATA, che arriva qui
    // dalla rotta. Ordine 2163, voce 2: senza il parametro lo scope leggeva
    // il controller, cioe' l'ultimo Maestro toccato altrove, e nella chat di
    // Medora il pannello usciva rosso di Caligo. Il colore si deriva dalla
    // rotta e si legge da UN punto, questo.
    builder: (_) => MaestroScope(
      maestro: maestro,
      child: _SuggestionsPanel(
        maestro: maestro,
        onSend: onSend,
        frequenti: frequenti,
        personali: personali,
      ),
    ),
  );
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.maestro,
    required this.onSend,
    required this.frequenti,
    required this.personali,
  });

  final Maestro maestro;
  final ValueChanged<String> onSend;
  final List<String> frequenti;
  final List<String> personali;

  void _send(BuildContext context, String question) {
    onSend(question);
    Navigator.of(context).pop();
  }

  /// Una famiglia: l'intestazione appiccicata e le sue voci. La forma e'
  /// una sola per tutte e due, cosi' non possono divergere.
  List<Widget> _famiglia(BuildContext context, String titolo,
      List<String> domande, MaestroPalette palette) {
    return [
      SliverPersistentHeader(
        pinned: true,
        delegate: _IntestazioneFamiglia(titolo: titolo, palette: palette),
      ),
      SliverList.separated(
        itemCount: domande.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: palette.gold.withValues(alpha: 0.12),
        ),
        itemBuilder: (context, i) => Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
          child: _QuestionRow(
            question: domande[i],
            onTap: () => _send(context, domande[i]),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: const Key('pannello_suggerimenti'),
      padding: EdgeInsets.only(
        top: SpacingTokens.md,
        bottom: SpacingTokens.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpacingTokens.radiusXl),
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: palette.gold.withValues(alpha: 0.5),
                borderRadius:
                    BorderRadius.circular(SpacingTokens.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: CustomScrollView(
                shrinkWrap: true,
                slivers: [
                  // La famiglia vuota non porta intestazione: la regola del
                  // vero vale anche qui, mai un segnaposto.
                  if (frequenti.isNotEmpty)
                    SliverMainAxisGroup(
                        slivers: _famiglia(context, 'DOMANDE FREQUENTI',
                            frequenti, palette)),
                  if (personali.isNotEmpty)
                    SliverMainAxisGroup(
                        slivers: _famiglia(context, 'DOMANDE PERSONALI',
                            personali, palette)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// L'intestazione di una famiglia, appiccicata in alto mentre si scorre la
/// sua sezione. Il fondo e' OPACO apposta (voce 1 dello stesso ordine): le
/// voci le scorrono sotto e spariscono, non si intravedono.
class _IntestazioneFamiglia extends SliverPersistentHeaderDelegate {
  const _IntestazioneFamiglia({required this.titolo, required this.palette});

  final String titolo;
  final MaestroPalette palette;

  static const double _altezza = 36;

  @override
  double get minExtent => _altezza;

  @override
  double get maxExtent => _altezza;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: _altezza,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
      color: palette.surfaceElevated,
      child: Text(
        titolo,
        style: TypographyTokens.label(size: 12.5).copyWith(
          color: palette.goldSoft,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_IntestazioneFamiglia old) =>
      old.titolo != titolo || old.palette != palette;
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.question, required this.onTap});

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        child: Row(
          children: [
            Icon(Icons.auto_awesome_outlined,
                color: palette.goldSoft, size: 18),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Text(
                question,
                style: TypographyTokens.body(size: 16),
              ),
            ),
            const Icon(Icons.north_east_rounded,
                color: ColorTokens.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
