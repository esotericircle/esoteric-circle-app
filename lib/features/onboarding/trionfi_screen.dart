import 'package:flutter/material.dart';

import '../../core/angels/angel_catalog.dart';
import '../../core/angels/guardian_angels.dart';
import '../../core/rituals/animal_catalog.dart';
import '../../core/assets/family_image.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestri/caligo/animal/animal_reveal.dart';

/// I due traguardi dell'onboarding, messi in scena come traguardi.
///
/// Prima l'Animale Guida e i tre Angeli venivano assegnati in silenzio: il
/// nome compariva dentro una tessera della carta natale, come un campo di un
/// modulo. Sono traguardi, e un traguardo che non si vede arrivare non e' un
/// traguardo.

/// Il trionfo dell'Animale Guida: la nebbia si dirada e il totem emerge.
///
/// La nebbia e' la metafora di Caligo, gia' prescritta per lui, quindi non
/// nasce qui: qui viene messa al servizio di una rivelazione. L'animale
/// emerge INTERO, mai ritagliato, perche' un totem tagliato non e' un totem.
class TrionfoAnimale extends StatefulWidget {
  const TrionfoAnimale({
    super.key,
    required this.animale,
    required this.palette,
    required this.onContinue,
    this.reduceMotion = false,
  });

  final GuideAnimal animale;
  final MaestroPalette palette;
  final VoidCallback onContinue;
  final bool reduceMotion;

  @override
  State<TrionfoAnimale> createState() => _TrionfoAnimaleState();
}

class _TrionfoAnimaleState extends State<TrionfoAnimale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scena;

  @override
  void initState() {
    super.initState();
    // Un tempo solo governa tutta la scena: la nebbia che si apre, il nome che
    // si scrive, l'invito che compare. Cosi' nulla resta appeso quando la
    // schermata muore.
    _scena = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.reduceMotion ? 1 : 2600),
    )..forward();
  }

  @override
  void dispose() {
    _scena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scena,
      builder: (context, _) {
        final t = _scena.value;
        // Il nome arriva DOPO che l'animale si e' visto: prima si riconosce,
        // poi si impara come si chiama.
        final nome = ((t - 0.45) / 0.35).clamp(0.0, 1.0);
        final invito = ((t - 0.8) / 0.2).clamp(0.0, 1.0);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Text('Chi ti accompagna',
                    key: const Key('trionfo_animale'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.label(size: 13).copyWith(
                        color: widget.palette.goldSoft, letterSpacing: 3)),
                const SizedBox(height: SpacingTokens.lg),
                // La rivelazione con la nebbia, gia' scritta per Caligo.
                AnimalReveal(
                  assetTotem: widget.animale.fullPath,
                  palette: widget.palette,
                  lato: 280,
                ),
                const SizedBox(height: SpacingTokens.lg),
                Opacity(
                  opacity: nome,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - nome)),
                    child: Column(
                      children: [
                        Text(widget.animale.name,
                            textAlign: TextAlign.center,
                            style: TypographyTokens.display(size: 32)
                                .copyWith(color: widget.palette.goldSoft)),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(widget.animale.summary,
                            textAlign: TextAlign.center,
                            style: TypographyTokens.body(size: 15).copyWith(
                                color: ColorTokens.textPrimary, height: 1.45)),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                Opacity(
                  opacity: invito,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('trionfo_animale_avanti'),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.palette.gold,
                        foregroundColor: widget.palette.deepest,
                        padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.md),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusPill),
                        ),
                      ),
                      onPressed: invito > 0.5 ? widget.onContinue : null,
                      child: Text('Chi altro veglia su di me',
                          style: TypographyTokens.body(size: 16, weight: 600)
                              .copyWith(color: widget.palette.deepest)),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Il trionfo dei tre Angeli: arrivano UNO ALLA VOLTA.
///
/// Mai tutti e tre insieme di colpo: tre luci che si accendono insieme sono
/// un'immagine, tre luci che si accendono in fila sono un racconto, e i tre
/// Angeli non hanno lo stesso ruolo (custode, cuore, intelletto).
class TrionfoAngeli extends StatefulWidget {
  const TrionfoAngeli({
    super.key,
    required this.triade,
    required this.palette,
    required this.onContinue,
    this.reduceMotion = false,
  });

  final AngelTriad triade;
  final MaestroPalette palette;
  final VoidCallback onContinue;
  final bool reduceMotion;

  /// Quanto passa fra un Angelo e il successivo.
  static const Duration passo = Duration(milliseconds: 900);

  @override
  State<TrionfoAngeli> createState() => _TrionfoAngeliState();
}

class _TrionfoAngeliState extends State<TrionfoAngeli>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scena;

  @override
  void initState() {
    super.initState();
    final quanti = widget.triade.known.length;
    _scena = AnimationController(
      vsync: this,
      duration: widget.reduceMotion
          ? const Duration(milliseconds: 1)
          : TrionfoAngeli.passo * (quanti + 1),
    )..forward();
  }

  @override
  void dispose() {
    _scena.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final angeli = widget.triade.known;
    return AnimatedBuilder(
      animation: _scena,
      builder: (context, _) {
        final t = _scena.value;
        final invito = ((t - 0.85) / 0.15).clamp(0.0, 1.0);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            child: Column(
              children: [
                const Spacer(),
                Text('I tuoi Angeli',
                    key: const Key('trionfo_angeli'),
                    textAlign: TextAlign.center,
                    style: TypographyTokens.label(size: 13).copyWith(
                        color: widget.palette.goldSoft, letterSpacing: 3)),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  'Tre custodi dalla tradizione dei settantadue nomi.',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.body(size: 14).copyWith(
                      color: ColorTokens.textSecondary, height: 1.45),
                ),
                const SizedBox(height: SpacingTokens.xl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < angeli.length; i++)
                      Expanded(
                        child: _AngeloInScena(
                          angelo: angeli[i],
                          ruolo: _ruolo(i),
                          palette: widget.palette,
                          // La finestra di ciascuno: il primo apre, gli altri
                          // seguono a distanza, mai insieme.
                          avanzamento: ((t * (angeli.length + 1) - i) / 1.0)
                              .clamp(0.0, 1.0),
                        ),
                      ),
                  ],
                ),
                const Spacer(flex: 2),
                Opacity(
                  opacity: invito,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('trionfo_angeli_avanti'),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.palette.gold,
                        foregroundColor: widget.palette.deepest,
                        padding: const EdgeInsets.symmetric(
                            vertical: SpacingTokens.md),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(SpacingTokens.radiusPill),
                        ),
                      ),
                      onPressed: invito > 0.5 ? widget.onContinue : null,
                      child: Text('Continua',
                          style: TypographyTokens.body(size: 16, weight: 600)
                              .copyWith(color: widget.palette.deepest)),
                    ),
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _ruolo(int i) => switch (i) {
        0 => 'Custode',
        1 => 'Del cuore',
        _ => 'Dell\'intelletto',
      };
}

/// Un Angelo che si accende: prima la luce, poi la carta, poi il nome.
class _AngeloInScena extends StatelessWidget {
  const _AngeloInScena({
    required this.angelo,
    required this.ruolo,
    required this.palette,
    required this.avanzamento,
  });

  final Angel angelo;
  final String ruolo;
  final MaestroPalette palette;

  /// Da 0 (ancora al buio) a 1 (acceso del tutto).
  final double avanzamento;

  @override
  Widget build(BuildContext context) {
    final k = Curves.easeOut.transform(avanzamento);
    final nome = ((avanzamento - 0.55) / 0.45).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
      child: Column(
        children: [
          // L'alone che si accende dietro la carta.
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: k,
                  child: Container(
                    width: 110 * (0.6 + 0.4 * k),
                    height: 110 * (0.6 + 0.4 * k),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        palette.goldSoft.withValues(alpha: 0.45 * k),
                        Colors.transparent,
                      ]),
                    ),
                  ),
                ),
                Opacity(
                  opacity: k,
                  child: Transform.scale(
                    scale: 0.88 + 0.12 * k,
                    // Proporzione da carta, non quadrata: l'arte degli Angeli
                    // e' verticale, e in un quadrato perderebbe i bordi.
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(SpacingTokens.radiusSm),
                        child: Image.asset(
                          FamilyImage.thumb(AssetFamily.angeli, angelo.artStem),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.auto_awesome,
                            color: palette.goldSoft,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Opacity(
            opacity: nome,
            child: Column(
              children: [
                Text(angelo.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: TypographyTokens.body(size: 14)
                        .copyWith(color: ColorTokens.textPrimary)),
                Text(ruolo,
                    textAlign: TextAlign.center,
                    style: TypographyTokens.label(size: 11).copyWith(
                        color: palette.goldSoft.withValues(alpha: 0.75),
                        letterSpacing: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quante posizioni distinte ha la sequenza: serve ai test per sapere quando
/// un Angelo e' gia' acceso e un altro non ancora.
double avanzamentoAngelo(double t, int indice, int quanti) =>
    ((t * (quanti + 1) - indice) / 1.0).clamp(0.0, 1.0);
