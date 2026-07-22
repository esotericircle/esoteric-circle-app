import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/archetypes/archetype_corpus.dart';
import '../../core/archetypes/archetype_history.dart';
import '../../core/astro/night_sky.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/identity/birth_moon.dart';
import '../../core/identity/numerology.dart';
import '../../core/identity/profile_controller.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/user_avatar.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../identity/circle_seal_screen.dart';
import '../maestri/aura/archetype/archetype_test_screen.dart';
import '../santuario/sky_overview_screen.dart';
import '../santuario/widgets/moon_widget.dart';
import '../settings/settings_screen.dart';

/// Schermata del Cosmic Passport.
///
/// I fatti identitari deterministici, quelli che nascono dalla sola data di
/// nascita, sono gia' vivi e mostrano il valore reale calcolato: Numero della
/// vita (numerologia) e Fase lunare di nascita (fase e segno lunare). Le voci
/// che richiedono servizi o asset esterni (carta natale completa, Angelo,
/// Archetipo, Animale guida) restano dietro il velo. Finche' l'onboarding non
/// fornisce la data vera, i fatti attivi usano `BirthIdentity.example`,
/// dichiarato in-world, e si popolano da soli quando arriva il dato reale.
///
/// Non ha un proprio Scaffold, AppBar o sfondo cosmico: e' solo contenuto,
/// destinato a essere inserito in un contenitore che fornisce navigazione e
/// sfondo.
class CosmicPassport extends StatelessWidget {
  const CosmicPassport({super.key, this.identity});

  /// Identita' di nascita da cui nascono i fatti deterministici. Se assente si
  /// usa il dato d'esempio, dichiarato in-world: passando un'identita' reale le
  /// tessere si popolano da sole.
  final BirthIdentity? identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final id = identity ?? BirthIdentity.example;
    final profile = context.watch<ProfileController>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.lg,
                SpacingTokens.lg,
                SpacingTokens.lg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Margine in alto: il titolo non deve mai finire sotto un
                  // eventuale pulsante nell'angolo in alto a sinistra.
                  const SizedBox(height: SpacingTokens.xl),
                  // Header cerimoniale: titolo e ingresso pulito alle
                  // Impostazioni, nell'angolo del documento.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Il volto dell'utente in testa al suo passaporto: la foto,
                      // o l'emblema del suo segno solare (sempre noto qui dalla
                      // data), o le iniziali, o il sigillo neutro.
                      UserAvatar(
                        key: const Key('passport_user_avatar'),
                        photo: profile.hasAvatarPhoto
                            ? MemoryImage(profile.avatarPhoto!)
                            : null,
                        sign: NightSky.sunSign(id.birthMoment),
                        name: profile.hasName
                            ? profile.profile.displayName
                            : null,
                        size: 52,
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Text(
                          'Cosmic Passport',
                          style: TypographyTokens.display(size: 30),
                        ),
                      ),
                      IconButton(
                        key: const Key('passport_settings'),
                        icon: const Icon(Icons.settings_outlined),
                        color: palette.goldSoft,
                        tooltip: 'Impostazioni',
                        onPressed: () =>
                            Navigator.of(context).push(SettingsScreen.route()),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'La tua identità cosmica, che si compone nel tempo.',
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: palette.goldSoft),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // Testo introduttivo: spiega la natura fissa del documento.
                  Text(
                    'Qui vivono i fatti identitari fissi del tuo cammino: la '
                    'carta natale non cambia mai.',
                    style: TypographyTokens.body(size: 16)
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                ],
              ),
            ),
          ),
          // Le tessere gia' vive: il portale del cielo di nascita e i due fatti
          // deterministici dalla sola data. Le altre restano dietro il velo.
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _BirthSkyPortalCard(birthMoment: id.birthMoment),
                  const SizedBox(height: SpacingTokens.sm),
                  _CircleSealCard(identity: id),
                  const SizedBox(height: SpacingTokens.sm),
                  _LifePathCard(identity: id),
                  const SizedBox(height: SpacingTokens.sm),
                  _BirthMoonCard(identity: id),
                  const SizedBox(height: SpacingTokens.sm),
                  // La faccia archetipo, viva quando c'e' un risultato salvato.
                  const _ArchetypeFaceCard(),
                  const SizedBox(height: SpacingTokens.sm),
                  for (final entry in _passportEntries) ...[
                    _PassportEntryCard(entry: entry),
                    const SizedBox(height: SpacingTokens.sm),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: SpacingTokens.xxxl),
          ),
        ],
      ),
    );
  }
}

/// Il portale gia' attivo del passaporto: apre "Il tuo cielo di nascita", la
/// volta immersiva ancorata alla notte di nascita. Finche' non ci sono nascita
/// e luogo reali (BirthIdentity dalle effemeridi), usa un momento d'esempio,
/// dichiarato in-world nella schermata stessa.
class _BirthSkyPortalCard extends StatelessWidget {
  const _BirthSkyPortalCard({required this.birthMoment});

  final DateTime birthMoment;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return GestureDetector(
      key: const Key('passport_birth_sky'),
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        SkyOverviewScreen.birthRoute(birthMoment: birthMoment),
      ),
      child: DepthCard(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.nights_stay, color: palette.goldSoft, size: 28),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Il tuo cielo di nascita',
                    style: TypographyTokens.display(size: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'La volta della tua prima notte, da esplorare con Medora.',
                    style: TypographyTokens.body(size: 14)
                        .copyWith(color: ColorTokens.textSecondary),
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

/// Tessera del Sigillo del Cerchio: apre l'emblema personale deterministico.
class _CircleSealCard extends StatelessWidget {
  const _CircleSealCard({required this.identity});

  final BirthIdentity identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: const Key('passport_seal'),
      raised: true,
      onTap: () => Navigator.of(context).push(CircleSealScreen.route(
          name: context.read<ProfileController>().vocative,
          identity: identity)),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.primary.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.workspace_premium_rounded,
                color: palette.goldSoft, size: 24),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Il tuo Sigillo del Cerchio',
                    style: TypographyTokens.display(size: 18)),
                const SizedBox(height: 2),
                Text(
                  'Il tuo emblema, dal segno, dal numero e dall\'elemento.',
                  style: TypographyTokens.body(size: 14)
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}

/// Tessera del Numero della vita: numerologia deterministica dalla data, con
/// un emblema a sigillo e una riga di significato.
class _LifePathCard extends StatelessWidget {
  const _LifePathCard({required this.identity});

  final BirthIdentity identity;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final lp = LifePath.forDate(identity.birthMoment);
    return _ActiveFactCard(
      cardKey: const Key('passport_life_path'),
      overline: 'Numero della vita',
      value: '${lp.number} · ${lp.title}',
      meaning: lp.meaning,
      isExample: identity.isExample,
      emblem: SizedBox(
        width: 52,
        height: 52,
        child: CustomPaint(
          painter: _LifePathSigil(number: lp.number, palette: palette),
        ),
      ),
    );
  }
}

/// Tessera della Fase lunare di nascita: fase e segno lunare del giorno di
/// nascita, con l'emblema della Luna gia' esistente e una riga di significato.
class _BirthMoonCard extends StatelessWidget {
  const _BirthMoonCard({required this.identity});

  final BirthIdentity identity;

  @override
  Widget build(BuildContext context) {
    final moon = BirthMoon.forDate(identity.birthMoment);
    return _ActiveFactCard(
      cardKey: const Key('passport_birth_moon'),
      overline: 'Fase lunare di nascita',
      value: moon.label,
      meaning: moon.meaning,
      isExample: identity.isExample,
      emblem: SizedBox(
        width: 52,
        height: 52,
        child: Center(child: MoonWidget(phase: moon.phase, size: 24)),
      ),
    );
  }
}

/// Tessera viva di un fatto identitario deterministico: emblema, etichetta,
/// valore reale calcolato e riga di significato. Se il dato e' d'esempio lo
/// dichiara in-world, senza il badge "Dietro il velo".
class _ActiveFactCard extends StatelessWidget {
  const _ActiveFactCard({
    required this.cardKey,
    required this.overline,
    required this.value,
    required this.meaning,
    required this.emblem,
    required this.isExample,
  });

  final Key cardKey;
  final String overline;
  final String value;
  final String meaning;
  final Widget emblem;
  final bool isExample;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DepthCard(
      key: cardKey,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          emblem,
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overline.toUpperCase(),
                  style: TypographyTokens.label(size: 10).copyWith(
                    color: palette.goldSoft.withValues(alpha: 0.8),
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: TypographyTokens.display(size: 19)),
                const SizedBox(height: 4),
                Text(
                  meaning,
                  style: TypographyTokens.body(size: 14)
                      .copyWith(color: ColorTokens.textSecondary),
                ),
                if (isExample) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  _ExampleNote(palette: palette),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Nota in-world per i fatti che usano il dato d'esempio: si popolano da soli
/// quando arriva la data vera dall'onboarding.
class _ExampleNote extends StatelessWidget {
  const _ExampleNote({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.auto_awesome, size: 12, color: palette.goldSoft),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Valore d\'esempio: si compone con la tua data di nascita.',
            style: TypographyTokens.label(size: 10).copyWith(
              color: palette.goldSoft.withValues(alpha: 0.7),
              letterSpacing: 0.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Emblema a sigillo del Numero della vita: un cerchio dorato con la cifra al
/// centro e una corona di tacche, piu' fitta per i numeri maestri.
class _LifePathSigil extends CustomPainter {
  _LifePathSigil({required this.number, required this.palette});

  final int number;
  final MaestroPalette palette;

  bool get _isMaster => number == 11 || number == 22 || number == 33;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2;

    // Alone tenue.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.goldSoft.withValues(alpha: 0.18),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: center, radius: r)),
    );

    // Cerchio esterno.
    canvas.drawCircle(
      center,
      r * 0.86,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = palette.gold.withValues(alpha: 0.8),
    );

    // Corona di tacche: dodici, o ventiquattro per i numeri maestri.
    final ticks = _isMaster ? 24 : 12;
    final tick = Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.55);
    for (var i = 0; i < ticks; i++) {
      final a = 2 * math.pi * i / ticks - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(center + dir * (r * 0.9), center + dir * (r * 0.99), tick);
    }

    // La cifra al centro, in Cinzel.
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: TypographyTokens.display(size: _isMaster ? 18 : 22)
            .copyWith(color: palette.goldSoft),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(_LifePathSigil old) =>
      old.number != number || old.palette != palette;
}

/// Descrizione statica di una voce segnaposto del passaporto.
class _PassportEntry {
  const _PassportEntry({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}

/// Voci segnaposto dei fatti identitari che richiedono servizi o asset esterni.
/// Numero della vita e Fase lunare di nascita non sono qui: sono gia' vivi,
/// perche' nascono dalla sola data.
const List<_PassportEntry> _passportEntries = [
  _PassportEntry(
    icon: Icons.auto_awesome,
    title: 'Carta natale',
    description: 'La tua mappa celeste, calcolata sulle effemeridi.',
  ),
  _PassportEntry(
    icon: Icons.brightness_7,
    title: 'Angelo custode',
    description: 'Il tuo Angelo nella tradizione dei settantadue nomi.',
  ),
  // L'Archetipo non e' piu' qui: ha la sua faccia viva (_ArchetypeFaceCard).
  _PassportEntry(
    icon: Icons.pets,
    title: 'Animale guida',
    description: 'Il tuo alleato fra i dodici archetipi.',
  ),
];

/// La faccia archetipo del passaporto.
///
/// Legge l'ultimo risultato del Test Archetipo dallo storico locale: se c'e',
/// mostra il dominante con la sua statua, il nome e l'essenza, e al tocco
/// riapre l'ultimo responso. Senza risultati, un invito garbato a fare il test.
class _ArchetypeFaceCard extends StatefulWidget {
  const _ArchetypeFaceCard();

  @override
  State<_ArchetypeFaceCard> createState() => _ArchetypeFaceCardState();
}

class _ArchetypeFaceCardState extends State<_ArchetypeFaceCard> {
  final ArchetypeHistory _storico = ArchetypeHistory();
  bool _pronto = false;

  @override
  void initState() {
    super.initState();
    _storico.carica().then((_) {
      if (mounted) setState(() => _pronto = true);
    });
  }

  @override
  void dispose() {
    _storico.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final ultimo = _pronto ? _storico.ultimo : null;

    if (ultimo == null) {
      // Senza risultati: invito garbato, non un vicolo cieco.
      return DepthCard(
        key: const Key('passport_archetype_invite'),
        opacity: 0.6,
        onTap: () =>
            Navigator.of(context).push(ArchetypeTestScreen.route()),
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            Icon(Icons.psychology_alt, color: palette.goldSoft, size: 28),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Archetipo',
                      style: TypographyTokens.display(size: 18)),
                  const SizedBox(height: 2),
                  Text('Fai il Test Archetipo con Aura per scoprire la figura '
                      'che ti guida.',
                      style: TypographyTokens.body(size: 14)
                          .copyWith(color: ColorTokens.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
          ],
        ),
      );
    }

    final dom = ultimo.dominante;
    return DepthCard(
      key: const Key('passport_archetype_face'),
      onTap: () => Navigator.of(context)
          .push(ArchetypeTestScreen.route(riapriUltimo: true)),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          SizedBox(
            height: 64,
            child: Image.asset(dom.artePiena,
                key: Key('passport_archetype_statue_${dom.name}'),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.psychology_alt,
                    color: palette.goldSoft, size: 28)),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dom.conArticolo,
                    style: TypographyTokens.display(size: 18)
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: 2),
                Text(ArchetypeCorpus.di(dom).essenza,
                    style: TypographyTokens.body(size: 14)
                        .copyWith(color: ColorTokens.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
        ],
      ),
    );
  }
}

/// Tessera "in arrivo" di un singolo fatto identitario del passaporto.
class _PassportEntryCard extends StatelessWidget {
  const _PassportEntryCard({required this.entry});

  final _PassportEntry entry;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return DepthCard(
      opacity: 0.6,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(entry.icon, color: palette.goldSoft, size: 28),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TypographyTokens.display(size: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.description,
                  style: TypographyTokens.body(size: 14)
                      .copyWith(color: ColorTokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          _VeilBadge(palette: palette),
        ],
      ),
    );
  }
}

/// Piccolo badge testuale con l'etichetta in-world unica, "Dietro il velo",
/// per le voci non ancora pronte. Stessa etichetta del dominio.
class _VeilBadge extends StatelessWidget {
  const _VeilBadge({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.xs,
        vertical: SpacingTokens.xxs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Text(
        'Dietro il velo',
        style: TypographyTokens.label(size: 10).copyWith(color: palette.gold),
      ),
    );
  }
}
