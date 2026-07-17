import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/night_sky.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/circle_seal.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/onboarding/onboarding_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../santuario/sky_overview_screen.dart';

/// La rivelazione, ultimo atto del Risveglio: il Cerchio chiama la persona per
/// nome, col vocativo giusto, e le apre il cielo reale che l'ha vista nascere.
///
/// Il cielo non e' una ruota astratta: e' lo stesso motore immersivo del cielo
/// di stanotte (`SkyOverviewScreen`), ancorato alla notte di nascita, con
/// costellazioni reali dal catalogo, Luna in fase reale e parallasse a tre
/// piani. Un portale lo riapre a tutto schermo, esplorabile e cliccabile.
///
/// Sotto, i tre pilastri: il Sole e' reale, dal segno ricavato dalla data; Luna
/// e Ascendente richiedono il calcolo a effemeridi e restano marcati provvisori,
/// nessuna invenzione. Il contenuto verificato arrivera' da FreeAstroAPI in un
/// secondo anello, tramite un backend che tiene la chiave, mai nel client.
///
/// Nessun colore di Maestro: al Risveglio non e' ancora scelto. La base e' la
/// tavolozza cosmica neutra del Cerchio (fondo nero, oro, alone viola).
class RevealScreen extends StatefulWidget {
  const RevealScreen({super.key, this.clock});

  final DateTime Function()? clock;

  static Route<void> route({DateTime Function()? clock}) {
    return MaterialPageRoute<void>(
      builder: (_) => RevealScreen(clock: clock),
    );
  }

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;

  // Tavolozza cosmica neutra: nessun accento di Maestro, non ancora scelto.
  static const MaestroPalette _palette = MaestroPalette.neutral;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _enter.value = 1.0;
    } else if (!_enter.isAnimating && _enter.value == 0) {
      _enter.forward();
    }
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  void _enterCircle() {
    context.read<OnboardingController>().complete();
    Navigator.of(context).maybePop();
  }

  // Il momento del cielo di nascita: data piu' ora se nota, altrimenti la
  // mezzanotte simbolica di quel giorno. Il cielo esatto con l'ora arriva col
  // motore a effemeridi.
  DateTime _birthMoment(BirthIdentity identity) {
    if (identity.hasBirthTime) return identity.birthMoment;
    final d = identity.birthDate;
    return DateTime(d.year, d.month, d.day);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>();
    final identity = profile.identity;
    final name = profile.vocative;
    final courtesy = profile.courtesy;
    final sign = NightSky.sunSign(identity.birthDate);
    final element = SealElement.of(sign);
    final birthMoment = _birthMoment(identity);

    // La frase che chiama per nome, concordata al vocativo. Il neutro evita la
    // desinenza di genere.
    final line = courtesy.agree(
      masculine: '$name, ecco il cielo che ti ha visto nascere.',
      feminine: '$name, ecco il cielo che ti ha vista nascere.',
      neutral: '$name, ecco il cielo che ha vegliato sulla tua nascita.',
    );

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.2,
            colors: [
              _palette.surfaceElevated.withValues(alpha: 0.55),
              ColorTokens.neutralDeepest,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _enter,
            child: Column(
              key: const Key('reveal_screen'),
              children: [
                const SizedBox(height: SpacingTokens.lg),
                _RevealVoice(palette: _palette, line: line),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.xl),
                    child: Column(
                      children: [
                        const SizedBox(height: SpacingTokens.md),
                        _BirthSkyPortal(
                          birthMoment: birthMoment,
                          palette: _palette,
                        ),
                        const SizedBox(height: SpacingTokens.lg),
                        _Pillar(
                          icon: Icons.wb_sunny_rounded,
                          title: 'Sole in ${sign.italianName}',
                          line: element.meaning,
                          palette: _palette,
                          provvisorio: false,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        const _Pillar(
                          icon: Icons.nightlight_round,
                          title: 'Luna',
                          line:
                              'Il suo segno nasce dal calcolo a effemeridi con '
                              'la tua ora. Arriva col tuo cielo completo.',
                          palette: _palette,
                          provvisorio: true,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        _Pillar(
                          icon: Icons.trip_origin_rounded,
                          title: 'Ascendente',
                          line: identity.hasBirthTime
                              ? 'Sorge all\'orizzonte del tuo luogo e della tua '
                                  'ora. Arriva col calcolo a effemeridi.'
                              : 'Serve l\'ora di nascita: per ora resta in '
                                  'ombra, senza forzature.',
                          palette: _palette,
                          provvisorio: true,
                        ),
                        const SizedBox(height: SpacingTokens.xl),
                        Text(
                          'Questo cielo è solo tuo.',
                          textAlign: TextAlign.center,
                          style: TypographyTokens.display(size: 20)
                              .copyWith(color: _palette.goldSoft),
                        ),
                        const SizedBox(height: SpacingTokens.xl),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(SpacingTokens.xl, 0,
                      SpacingTokens.xl, SpacingTokens.lg),
                  child: _EnterButton(palette: _palette, onTap: _enterCircle),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La voce del Cerchio che chiama per nome. Nessun volto di Maestro, non ancora
/// scelto: solo un segno di luce dorato accanto alla frase.
class _RevealVoice extends StatelessWidget {
  const _RevealVoice({required this.palette, required this.line});

  final MaestroPalette palette;
  final String line;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                palette.primary.withValues(alpha: 0.4),
                palette.deepest.withValues(alpha: 0.2),
              ]),
              border: Border.all(
                  color: palette.gold.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Icon(Icons.auto_awesome, color: palette.goldSoft, size: 22),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Text(
              line,
              style: TypographyTokens.body(size: 16).copyWith(
                color: ColorTokens.textPrimary,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il portale del cielo reale di nascita: apre a tutto schermo la volta
/// immersiva ancorata alla notte di nascita (`SkyOverviewScreen`), lo stesso
/// motore del cielo di stanotte, esplorabile e cliccabile. Niente ruota
/// astratta: costellazioni reali, Luna in fase reale, parallasse a tre piani.
class _BirthSkyPortal extends StatelessWidget {
  const _BirthSkyPortal({required this.birthMoment, required this.palette});

  final DateTime birthMoment;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('reveal_birth_sky'),
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        SkyOverviewScreen.birthRoute(birthMoment: birthMoment),
      ),
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 1.3,
            colors: [
              palette.surfaceElevated.withValues(alpha: 0.55),
              palette.deepest.withValues(alpha: 0.4),
            ],
          ),
          border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.primary.withValues(alpha: 0.4),
                border:
                    Border.all(color: palette.gold.withValues(alpha: 0.6)),
              ),
              child: Icon(Icons.nights_stay_rounded,
                  color: palette.goldSoft, size: 26),
            ),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Il tuo cielo di nascita',
                      style: TypographyTokens.display(size: 18)
                          .copyWith(color: palette.goldSoft)),
                  const SizedBox(height: 2),
                  Text(
                    'La volta della tua prima notte, reale ed esplorabile. '
                    'Tocca per aprirla a tutto schermo.',
                    style: TypographyTokens.body(size: 13).copyWith(
                        color: ColorTokens.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
          ],
        ),
      ),
    );
  }
}

/// Un pilastro del cielo: Sole, Luna o Ascendente. Quando [provvisorio] e' vero,
/// porta il distintivo che lo dichiara segnaposto, mai spacciato per reale.
class _Pillar extends StatelessWidget {
  const _Pillar({
    required this.icon,
    required this.title,
    required this.line,
    required this.palette,
    required this.provvisorio,
  });

  final IconData icon;
  final String title;
  final String line;
  final MaestroPalette palette;
  final bool provvisorio;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        color: palette.deepest.withValues(alpha: 0.35),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: palette.goldSoft),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(title,
                          style: TypographyTokens.display(size: 17)
                              .copyWith(color: ColorTokens.textPrimary)),
                    ),
                    if (provvisorio) ...[
                      const SizedBox(width: SpacingTokens.sm),
                      const _ProvvisorioTag(),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(line,
                    style: TypographyTokens.body(size: 13).copyWith(
                        color: ColorTokens.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Il distintivo "Provvisorio".
class _ProvvisorioTag extends StatelessWidget {
  const _ProvvisorioTag();

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFE8C463);
    return Container(
      key: const Key('reveal_provvisorio'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: gold.withValues(alpha: 0.18),
      ),
      child: Text('Provvisorio',
          style: TypographyTokens.body(size: 10)
              .copyWith(color: gold, letterSpacing: 0.5)),
    );
  }
}

/// Il pulsante che entra nel Cerchio, chiudendo il rito.
class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.palette, required this.onTap});

  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('onboarding_enter'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              gradient: LinearGradient(colors: [
                palette.primary.withValues(alpha: 0.85),
                palette.surfaceElevated.withValues(alpha: 0.85),
              ]),
              border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
            ),
            child: Text('Entra nel Cerchio',
                style: TypographyTokens.display(size: 17)
                    .copyWith(color: palette.goldSoft)),
          ),
        ),
      ),
    );
  }
}
