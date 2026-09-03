import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/app_flags.dart';
import '../../core/entitlement/entitlement_service.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../../core/entitlement/question_allowance.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import '../../services/app_services.dart';
import '../../services/server/porta_del_cerchio.dart';

/// La schermata dei piani del Cerchio, in stile 2.5D.
///
/// Mostra i quattro livelli canonici (Viandante, Iniziato, Adepto, Illuminato),
/// ciascuno con i tre cicli di prezzo, la loro identita' e i vantaggi in
/// evidenza, piu' la tabella comparativa completa delle funzioni. In Demo, in
/// cima, una card "Demo" con il badge "Piano Attuale" sblocca tutto per la
/// presentazione, dietro il flag `AppFlags.isDemo`: nell'MVP sparisce da sola.
/// Il pagamento non e' integrato nella Demo, dichiarato in fondo.
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key, this.isDemo = AppFlags.isDemo});

  final bool isDemo;

  static Route<void> route() {
    return PassaggioDelCerchio.rotta<void>(
        (_) => const MaestroScope(child: PricingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final current = context.watch<EntitlementService>().tier;

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('I piani del Cerchio',
            style: TypographyTokens.titoloDiSchermata()),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                key: const Key('pricing_list'),
                padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                    SpacingTokens.md, SpacingTokens.lg, SpacingTokens.xl),
                children: [
                  Text(
                    'Scegli quanto lontano portare il tuo cammino. Ogni livello '
                    'apre nuove porte del cerchio.',
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  if (isDemo) ...[
                    _DemoCard(palette: palette),
                    const SizedBox(height: SpacingTokens.md),
                  ],
                  for (final plan in PlanCatalog.plans) ...[
                    _PlanCard(
                      plan: plan,
                      // In Demo il "Piano Attuale" sta sulla card Demo, non sui
                      // livelli; fuori Demo sta sul tier corrente.
                      isCurrent: !isDemo && plan.tier == current,
                      palette: palette,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                  ],
                  const SizedBox(height: SpacingTokens.sm),
                  Text('Confronto completo',
                      style: TypographyTokens.titoloScheda()
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.sm),
                  _ComparativeTable(palette: palette),
                ],
              ),
            ),
            // Testo persistente in basso, sempre visibile.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(SpacingTokens.lg,
                  SpacingTokens.sm, SpacingTokens.lg, SpacingTokens.sm),
              decoration: BoxDecoration(
                color: palette.deepest.withValues(alpha: 0.6),
                border: Border(
                    top: BorderSide(
                        color: palette.gold.withValues(alpha: 0.25))),
              ),
              child: SafeArea(
                top: false,
                child: Text(
                  'Nella demo i piani sono visibili ma il pagamento non è integrato.',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.corpo().copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La card Demo, in cima: sblocca tutto per la presentazione, col badge "Piano
/// Attuale". Dietro il flag isDemo, sparisce nell'MVP.
class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      key: const Key('plan_demo'),
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: palette.goldSoft, size: 22),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text('Demo', style: TypographyTokens.titoloSezione()),
              ),
              _Badge(text: 'Piano Attuale', palette: palette),
            ],
          ),
          const SizedBox(height: 2),
          Text('Tutte le funzioni attive, per la presentazione.',
              style:
                  TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
        ],
      ),
    );
  }
}

/// La tessera di un livello: identita', vantaggi in evidenza e i tre cicli di
/// prezzo. Il Viandante gratuito non ha prezzo, ha la nota del banner.
class _PlanCard extends StatefulWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrent,
    required this.palette,
  });

  final Plan plan;
  final bool isCurrent;
  final MaestroPalette palette;

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  // Ciclo scelto, con l'Annuale evidenziato di default: e' il piu' conveniente.
  PriceCycle _cycle = PriceCycle.yearly;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final isCurrent = widget.isCurrent;
    final palette = widget.palette;
    return DepthCard(
      key: Key('plan_${plan.tier.name}'),
      raised: plan.highlighted,
      opacity: plan.highlighted ? 1.0 : 0.7,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(plan.name, style: TypographyTokens.titoloSezione()),
              ),
              if (isCurrent)
                _Badge(text: 'Piano Attuale', palette: palette)
              else if (plan.highlighted)
                _Badge(text: 'Consigliato', palette: palette),
            ],
          ),
          const SizedBox(height: 2),
          Text(plan.identity,
              style:
                  TypographyTokens.corpo().copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.md),
          for (final benefit in plan.highlights) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 16, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(benefit,
                      style: TypographyTokens.corpo().copyWith(
                          color: ColorTokens.textPrimary, height: 1.3)),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.xs),
          ],
          if (plan.isFree)
            Padding(
              padding: const EdgeInsets.only(top: SpacingTokens.xs),
              child: Text('Accesso base, con un piccolo banner in basso.',
                  style: TypographyTokens.corpo().copyWith(
                    color: ColorTokens.textSecondary,
                    letterSpacing: 0.2,
                  )),
            ),
          if (plan.price != null) ...[
            const SizedBox(height: SpacingTokens.md),
            _PriceCycles(
              price: plan.price!,
              palette: palette,
              selected: _cycle,
              onSelect: (c) => setState(() => _cycle = c),
            ),
            const SizedBox(height: SpacingTokens.sm),
            if (!isCurrent)
              _ChoosePlanButton(
                plan: plan,
                palette: palette,
                cycle: _cycle,
              ),
          ],
        ],
      ),
    );
  }
}

/// I tre cicli di prezzo affiancati come selettore: uno solo è scelto, l'Annuale
/// di default. Il riquadro scelto è distinto (riempito, cornice piena, spunta),
/// gli altri restano sobri. L'equivalenza mensile e lo sconto vivono sull'anno.
class _PriceCycles extends StatelessWidget {
  const _PriceCycles({
    required this.price,
    required this.palette,
    required this.selected,
    required this.onSelect,
  });

  final PlanPrice price;
  final MaestroPalette palette;
  final PriceCycle selected;
  final ValueChanged<PriceCycle> onSelect;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final cycle in PriceCycle.values) ...[
            Expanded(
              child: _CycleBox(
                cycle: cycle,
                price: price,
                palette: palette,
                selected: cycle == selected,
                onTap: () => onSelect(cycle),
              ),
            ),
            if (cycle != PriceCycle.values.last)
              const SizedBox(width: SpacingTokens.sm),
          ],
        ],
      ),
    );
  }
}

/// Un riquadro ciclo del selettore, distinto quando scelto.
class _CycleBox extends StatelessWidget {
  const _CycleBox({
    required this.cycle,
    required this.price,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final PriceCycle cycle;
  final PlanPrice price;
  final MaestroPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('cycle_${cycle.name}'),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: SpacingTokens.sm, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            gradient: selected
                ? LinearGradient(colors: [
                    palette.primary.withValues(alpha: 0.75),
                    palette.surfaceElevated.withValues(alpha: 0.75),
                  ])
                : null,
            color: selected
                ? null
                : palette.surfaceElevated.withValues(alpha: 0.3),
            border: Border.all(
              color: palette.gold.withValues(alpha: selected ? 0.9 : 0.22),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (selected) ...[
                    Icon(Icons.check_circle_rounded,
                        size: 12, color: palette.goldSoft),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(cycle.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TypographyTokens.etichetta().copyWith(
                          color: palette.goldSoft,
                          letterSpacing: 0.6,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(price.amount(cycle),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.titoloDiRiga().copyWith(
                      color: selected
                          ? ColorTokens.textPrimary
                          : ColorTokens.textSecondary)),
              if (cycle == PriceCycle.yearly) ...[
                const SizedBox(height: 4),
                Text(price.yearlyPerMonth,
                    textAlign: TextAlign.center,
                    style: TypographyTokens.etichetta().copyWith(
                      color: ColorTokens.textSecondary,
                      letterSpacing: 0.2,
                    )),
                Text('sconto ${price.yearlyDiscountPercent}%',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.etichetta().copyWith(
                      color: palette.goldSoft,
                      letterSpacing: 0.2,
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.palette});

  final String text;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xxs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.primary.withValues(alpha: 0.5),
        border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
      ),
      child: Text(text,
          style:
              TypographyTokens.etichetta().copyWith(color: palette.goldSoft)),
    );
  }
}

/// La tabella comparativa completa. La prima colonna delle funzioni resta fissa,
/// le colonne dei tier scorrono in orizzontale, con una sfumatura sul bordo
/// destro che segnala lo scorrimento. Tutti e quattro i livelli sono
/// raggiungibili, senza troncare nulla: le celle vanno a capo.
class _ComparativeTable extends StatelessWidget {
  const _ComparativeTable({required this.palette});

  final MaestroPalette palette;

  static const double _labelWidth = 150;
  static const double _cellWidth = 116;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
      child: Stack(
        children: [
          // La tabella intera scorre in orizzontale: definisce l'altezza dello
          // Stack e mostra i tier via via che si scorre.
          SingleChildScrollView(
            key: const Key('pricing_table'),
            scrollDirection: Axis.horizontal,
            child: _buildTable(),
          ),
          // Colonna delle funzioni congelata a sinistra, su fondo pieno cosi'
          // i tier che scorrono le passano sotto senza trasparire.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: _labelWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: ColorTokens.neutralDeepest,
                border: Border(
                  right: BorderSide(
                      color: palette.gold.withValues(alpha: 0.4), width: 1),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: _buildTable(),
              ),
            ),
          ),
          // Sfumatura sul bordo destro: dice che si scorre per vedere gli altri
          // livelli.
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 28,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ColorTokens.neutralDeepest.withValues(alpha: 0.0),
                      ColorTokens.neutralDeepest,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Intestazione con i nomi dei livelli.
        _row(
          label: 'Funzione',
          values: PlanCatalog.columns,
          header: true,
        ),
        for (var i = 0; i < PlanCatalog.matrix.length; i++)
          _row(
            label: PlanCatalog.matrix[i].label,
            values: PlanCatalog.matrix[i].values,
            shaded: i.isOdd,
          ),
      ],
    );
  }

  Widget _row({
    required String label,
    required List<String> values,
    bool header = false,
    bool shaded = false,
  }) {
    final labelStyle = header
        ? TypographyTokens.etichetta()
            .copyWith(color: palette.goldSoft, letterSpacing: 0.4)
        : TypographyTokens.corpo()
            .copyWith(color: ColorTokens.textPrimary, height: 1.25);
    final cellStyle = header
        ? TypographyTokens.titoloDiRiga().copyWith(color: palette.goldSoft)
        : TypographyTokens.corpo()
            .copyWith(color: ColorTokens.textSecondary, height: 1.25);
    return Container(
      color: shaded ? palette.surfaceElevated.withValues(alpha: 0.18) : null,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _cell(label, _labelWidth, labelStyle, alignStart: true),
            for (final value in values)
              _cell(value, _cellWidth, cellStyle, alignStart: false),
          ],
        ),
      ),
    );
  }

  Widget _cell(String text, double width, TextStyle style,
      {required bool alignStart}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: palette.gold.withValues(alpha: 0.1)),
          bottom: BorderSide(color: palette.gold.withValues(alpha: 0.1)),
        ),
      ),
      alignment: alignStart ? Alignment.centerLeft : Alignment.center,
      child: Text(text,
          textAlign: alignStart ? TextAlign.left : TextAlign.center,
          style: style),
    );
  }
}

/// Il pulsante per scegliere un piano. Nella Demo apre il foglio che spiega il
/// pagamento e consente la prova in modalita' Demo.
class _ChoosePlanButton extends StatelessWidget {
  const _ChoosePlanButton({
    required this.plan,
    required this.palette,
    required this.cycle,
  });

  final Plan plan;
  final MaestroPalette palette;
  final PriceCycle cycle;

  @override
  Widget build(BuildContext context) {
    // Il pulsante dichiara il ciclo e il prezzo scelti, ad esempio
    // "Scegli L'Iniziato, 89,90 all'anno".
    final label =
        'Scegli ${plan.name}, ${plan.price!.amount(cycle)} ${cycle.per}';
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: Key('choose_${plan.tier.name}'),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          onTap: () => _openSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(
                vertical: SpacingTokens.sm, horizontal: SpacingTokens.md),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              gradient: LinearGradient(colors: [
                palette.primary.withValues(alpha: 0.7),
                palette.surfaceElevated.withValues(alpha: 0.7),
              ]),
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloDiRiga()
                    .copyWith(color: palette.goldSoft)),
          ),
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    final entitlement = context.read<EntitlementService>();
    foglioDelCerchio<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
          border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passa a ${plan.name}',
                  style: TypographyTokens.titoloDiSchermata()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                'Nella demo il pagamento non è integrato: l\'abbonamento reale '
                'arriverà dal web. Puoi comunque provare questo livello in '
                'modalità Demo, per vedere cosa apre.',
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text('Chiudi',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: ColorTokens.textSecondary)),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  TextButton(
                    key: const Key('activate_demo'),
                    onPressed: () async {
                      // Il messenger si prende PRIMA di mutare lo stato: il
                      // cambio di tier ricostruisce la schermata e puo'
                      // deattivare proprio questo bottone, e cercare un
                      // antenato da un elemento deattivato e' lo schianto
                      // "deactivated widget's ancestor" della famiglia dei
                      // difetti di ciclo di vita.
                      final messenger = ScaffoldMessenger.of(context);
                      // **E ANCHE LA PORTA E I CONTATORI, PRIMA DELL'ATTESA**,
                      // per la stessa ragione: dopo un await questo albero
                      // puo' non esserci piu'.
                      // **NON SI PRETENDE UN PROVIDER, ordine CQ voce
                      // 1.01.** Chiedere `AppServices` con un `read` nudo fa
                      // cadere ogni prova e ogni anteprima che monta questa
                      // schermata da sola, ed e' una famiglia di difetti gia'
                      // vista in questa casa: un provider preteso rompe
                      // lontano da dove e' scritto. Qui la porta e' un di
                      // piu': se non c'e', il piano vale su questo telefono e
                      // basta, che e' cio' che la Demo ha sempre fatto.
                      PortaDelCerchio? porta;
                      QuestionAllowance? borsa;
                      try {
                        porta = context.read<AppServices>().porta;
                        borsa = context.read<QuestionAllowance>();
                      } catch (senzaAlbero) {
                        porta = null;
                        borsa = null;
                      }
                      Navigator.of(sheetContext).pop();
                      // **IL PIANO SI SCRIVE SUL SERVER, ordine CQ voce
                      // 1.01.** Cambiarlo solo qui dentro lasciava il server
                      // a contare i budget sul Viandante: il telefono
                      // mostrava il tetto dell'Illuminato e il server negava
                      // alla prima gettata. Adesso si chiede al server di
                      // scriverlo, e **si dice alla persona cosa e'
                      // successo davvero**, invece di annunciare un piano
                      // attivo che il server non conosce.
                      final scritto = await porta?.attivaIlPianoInDemo(
                          EntitlementService.nomeDelServer(plan.tier));
                      if (scritto == null) {
                        // La porta e' spenta, chiusa o muta: si tiene il
                        // cambio locale, che e' cio' che la Demo senza rete
                        // ha sempre fatto, e lo si DICHIARA.
                        entitlement.setTier(plan.tier);
                        messenger.showSnackBar(
                          SnackBar(
                              content: Text(
                                  '${plan.name} attivo solo su questo telefono: il server non lo ha registrato.')),
                        );
                        return;
                      }
                      entitlement.applicaIlPianoDelServer(scritto);
                      // I residui si rileggono col piano nuovo, altrimenti
                      // restano quelli contati sul piano di prima.
                      await borsa?.sincronizza();
                      messenger.showSnackBar(
                        SnackBar(
                            content: Text(
                                '${plan.name} attivo in Demo. Il pagamento vero arriva dal web.')),
                      );
                    },
                    child: Text('Attiva in Demo',
                        style: TypographyTokens.label(size: 13)
                            .copyWith(color: palette.goldSoft)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
