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
/// **I DUE TITOLI SELEZIONABILI, ORDINE 2164 VOCE 7, E QUESTA RIGA DISFA UNA
/// DECISIONE DELL'ARCHITETTO.** Con l'ordine 2163 voce 3 le due famiglie
/// erano state unite in un solo riquadro scorrevole con le intestazioni
/// appiccicate, perche' l'ordine diceva "le due famiglie insieme, non a
/// linguette": era una lettura sbagliata delle parole di Mauro. Lui vuole i
/// DUE TITOLI, com'era nelle build precedenti, e questa scelta supera la
/// mia: non e' una regressione, e nessuno la ribalti domani.
///
/// In cima al pannello due titoli affiancati, DOMANDE FREQUENTI e DOMANDE
/// PERSONALI. All'apertura e' gia' selezionato DOMANDE FREQUENTI con sotto
/// le sue domande; toccando l'altro l'elenco si aggiorna. Il titolo scelto
/// si distingue da quello spento in modo evidente. Le liste arrivano dalla
/// schermata GIA' filtrate sul vero: una famiglia vuota non porta il suo
/// titolo, per la regola del vero. Il tocco su una domanda la invia e
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

class _SuggestionsPanel extends StatefulWidget {
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

  @override
  State<_SuggestionsPanel> createState() => _SuggestionsPanelState();
}

class _SuggestionsPanelState extends State<_SuggestionsPanel> {
  /// LA FAMIGLIA SCELTA: all'apertura sono le FREQUENTI, come ordina la
  /// voce 7. Vive nello State del pannello, che e' il solo posto che la
  /// conosce: il chiamante passa le liste, non la scelta.
  SuggestionGroup _scelta = SuggestionGroup.frequent;

  void _send(String question) {
    widget.onSend(question);
    Navigator.of(context).pop();
  }

  List<String> get _domande => switch (_scelta) {
        SuggestionGroup.frequent => widget.frequenti,
        SuggestionGroup.personal => widget.personali,
      };

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
          // I DUE TITOLI AFFIANCATI. Una famiglia vuota non porta il suo
          // titolo: la regola del vero, mai un titolo che apre il nulla.
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            child: Row(
              children: [
                if (widget.frequenti.isNotEmpty)
                  Expanded(
                    child: _TitoloDiFamiglia(
                      key: const Key('titolo_frequenti'),
                      testo: 'DOMANDE FREQUENTI',
                      scelto: _scelta == SuggestionGroup.frequent,
                      palette: palette,
                      onTap: () => setState(
                          () => _scelta = SuggestionGroup.frequent),
                    ),
                  ),
                if (widget.personali.isNotEmpty)
                  Expanded(
                    child: _TitoloDiFamiglia(
                      key: const Key('titolo_personali'),
                      testo: 'DOMANDE PERSONALI',
                      scelto: _scelta == SuggestionGroup.personal,
                      palette: palette,
                      onTap: () => setState(
                          () => _scelta = SuggestionGroup.personal),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.55,
              ),
              child: ListView.separated(
                key: const Key('elenco_suggerimenti'),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.lg),
                itemCount: _domande.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: palette.gold.withValues(alpha: 0.12),
                ),
                itemBuilder: (context, i) => _QuestionRow(
                  question: _domande[i],
                  onTap: () => _send(_domande[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Uno dei due titoli in cima al pannello: acceso quello scelto, spento
/// l'altro. La differenza NON e' solo di colore: il titolo scelto porta
/// anche la sua riga sotto, cosi' si distingue anche a colpo d'occhio e
/// anche per chi il colore lo vede male.
class _TitoloDiFamiglia extends StatelessWidget {
  const _TitoloDiFamiglia({
    super.key,
    required this.testo,
    required this.scelto,
    required this.palette,
    required this.onTap,
  });

  final String testo;
  final bool scelto;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: scelto
                  ? palette.gold
                  : palette.gold.withValues(alpha: 0.12),
              width: scelto ? 2 : 1,
            ),
          ),
        ),
        child: Text(
          testo,
          textAlign: TextAlign.center,
          style: TypographyTokens.label(size: 12).copyWith(
            color: scelto ? palette.goldSoft : ColorTokens.textMuted,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
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
