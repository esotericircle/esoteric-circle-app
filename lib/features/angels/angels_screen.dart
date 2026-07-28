import 'package:flutter/material.dart';

import '../../core/angels/angel_catalog.dart';
import '../../core/angels/guardian_angels.dart';
import '../../core/assets/family_image.dart';
import '../../core/identity/birth_identity.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// I tre Angeli della persona, di dominio Medora.
///
/// La tradizione dello Shemhamphorash assegna tre angeli da tre sorgenti
/// diverse: il grado del Sole alla nascita, il giorno, l'ora. Qui si vedono
/// tutti e tre con la loro arte, e in fondo si spiega come sono stati scelti,
/// perche' un responso che non dice da dove viene chiede fiducia cieca.
class AngelsScreen extends StatefulWidget {
  const AngelsScreen({super.key, required this.identity});

  final BirthIdentity identity;

  /// L'ingresso delle tre carte: un trionfo, non un'attesa. Ogni carta entra
  /// dopo l'altra con una luce che si accende dietro e si posa. Tutto sotto i
  /// due secondi e mezzo, ritardi compresi.
  static const Duration ingresso = Duration(milliseconds: 2200);

  static Route<void> route({required BirthIdentity identity}) =>
      MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: AngelsScreen(identity: identity)),
      );

  @override
  State<AngelsScreen> createState() => _AngelsScreenState();
}

class _AngelsScreenState extends State<AngelsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrata;

  @override
  void initState() {
    super.initState();
    _entrata = AnimationController(vsync: this, duration: AngelsScreen.ingresso);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Con Riduci Movimento le carte sono gia' posate: nessun moto, nessuna
      // attesa, la stessa scena ferma.
      if (MediaQuery.of(context).disableAnimations) {
        _entrata.value = 1;
      } else {
        _entrata.forward();
      }
    });
  }

  @override
  void dispose() {
    _entrata.dispose();
    super.dispose();
  }

  /// La nota su tradizione e metodo, come prescrivono le Linee Guida: un
  /// punto interrogativo discreto che apre poche righe, non un trattato.
  ///
  /// Dice anche la cosa scomoda, cioe' che le tavole originali non sono state
  /// lette in edizione primaria. Un responso che tace su cosa non ha verificato
  /// chiede fiducia cieca, e questa app non la chiede.
  void _mostraFonti(BuildContext context) {
    final palette = context.palette;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusLg)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fonti e metodo',
                style: TypographyTokens.display(size: 20)),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Sono i settantadue nomi dello Shemhamphorash, dalla tradizione '
              'cabalistica: dal versetto triplice dell\'Esodo si ricavano '
              'settantadue nomi, disposti in nove cori da otto.',
              style: TypographyTokens.body(size: 15).copyWith(height: 1.45),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'I tuoi tre si ricavano da tre cose diverse: la posizione del '
              'Sole alla tua nascita, in archi di cinque gradi, il giorno in '
              'cui sei nato, l\'ora esatta.',
              style: TypographyTokens.body(size: 15).copyWith(height: 1.45),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              key: const Key('angeli_nota_edizioni'),
              'Le fonti sono repertori che dichiarano di derivare da Lenain e '
              'da Ambelain. Le tavole originali non sono state consultate in '
              'edizione primaria.',
              style: TypographyTokens.body(size: 15)
                  .copyWith(color: ColorTokens.textSecondary, height: 1.45),
            ),
            const SizedBox(height: SpacingTokens.md),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final triade = GuardianAngels.forBirth(widget.identity.toBirthDetails());

    return Scaffold(
      key: const Key('angels_screen'),
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('I tuoi tre Angeli',
            style: TypographyTokens.display(size: 20)),
        actions: [
          IconButton(
            key: const Key('angeli_fonti_metodo'),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: 'Fonti e metodo',
            onPressed: () => _mostraFonti(context),
          ),
        ],
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.lg,
              SpacingTokens.md,
              SpacingTokens.lg,
              SpacingTokens.xxxl,
            ),
            children: [
              Text(
                'La tradizione ne assegna tre, uno per ogni strato: il corpo, '
                'il cuore, la mente.',
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: TypographyTokens.guide)
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4),
              ),
              const SizedBox(height: SpacingTokens.lg),

              _CartaAngelo(
                key: const Key('angelo_custode'),
                indice: 0,
                entrata: _entrata,
                angelo: triade.guardian,
                ruolo: 'Angelo Custode',
                sottotitolo: 'del corpo fisico',
                perche: 'Nasce dal grado in cui il Sole stava alla tua '
                    'nascita, ${triade.sunLongitude.toStringAsFixed(1)} gradi '
                    'dello zodiaco. Veglia su cio\' che sei nel corpo e nel '
                    'temperamento.',
                palette: palette,
              ),
              const SizedBox(height: SpacingTokens.md),

              _CartaAngelo(
                key: const Key('angelo_cuore'),
                indice: 1,
                entrata: _entrata,
                angelo: triade.heart,
                ruolo: 'Angelo del Cuore',
                sottotitolo: 'del corpo astrale',
                perche: 'Nasce dal giorno in cui sei nato, il '
                    '${triade.dayOfYear}esimo dell\'anno. Veglia su cio\' che '
                    'senti e su come ami.',
                palette: palette,
              ),
              const SizedBox(height: SpacingTokens.md),

              if (triade.intellect != null)
                _CartaAngelo(
                  key: const Key('angelo_intelletto'),
                  indice: 2,
                  entrata: _entrata,
                  angelo: triade.intellect!,
                  ruolo: 'Angelo dell\'Intelletto',
                  sottotitolo: 'delle missioni',
                  perche: 'Nasce dall\'ora della tua nascita. Veglia sul tuo '
                      'pensiero e su cio\' che sei venuto a fare.',
                  palette: palette,
                )
              else
                _IntellettoMancante(palette: palette),

              const SizedBox(height: SpacingTokens.xl),
              _ComeSonoScelti(triade: triade, palette: palette),
              const SizedBox(height: SpacingTokens.lg),
              Text(
                'I settantadue Angeli vengono dalla tradizione cabalistica '
                'dello Shemhamphorash. Sono uno specchio per guardarti, non '
                'una sentenza sul tuo destino.',
                key: const Key('angeli_disclaimer'),
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 13)
                    .copyWith(color: ColorTokens.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Una carta d'angelo: arte reale, nome, numero, coro col suo arcangelo, e la
/// ragione per cui e' toccato a questa persona.
class _CartaAngelo extends StatelessWidget {
  const _CartaAngelo({
    super.key,
    required this.indice,
    required this.entrata,
    required this.angelo,
    required this.ruolo,
    required this.sottotitolo,
    required this.perche,
    required this.palette,
  });

  final int indice;
  final Animation<double> entrata;
  final Angel angelo;
  final String ruolo;
  final String sottotitolo;
  final String perche;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final lore = angelo.lore;
    return AnimatedBuilder(
      animation: entrata,
      builder: (context, child) {
        // Le tre carte si scaglionano dentro la stessa corsa: la prima parte
        // subito, le altre a un quinto di distanza l'una dall'altra, e ognuna
        // impiega poco piu' di meta' corsa. Cosi' l'ultima chiude entro la fine.
        final inizio = indice * 0.2;
        final t = ((entrata.value - inizio) / 0.6).clamp(0.0, 1.0);
        final curva = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curva,
          child: Transform.translate(
            offset: Offset(0, (1 - curva) * 28),
            child: Transform.scale(scale: 0.96 + 0.04 * curva, child: child),
          ),
        );
      },
      child: DepthCard(
        raised: true,
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Ritratto(angelo: angelo, entrata: entrata, indice: indice,
                    palette: palette),
                const SizedBox(width: SpacingTokens.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ruolo.toUpperCase(),
                          style: TypographyTokens.label(size: 11).copyWith(
                              color: palette.goldSoft, letterSpacing: 2)),
                      Text(sottotitolo,
                          style: TypographyTokens.body(size: 13)
                              .copyWith(color: ColorTokens.textMuted)),
                      const SizedBox(height: SpacingTokens.xs),
                      Text('${angelo.number}. ${angelo.name}',
                          style: TypographyTokens.display(size: 22)),
                      const SizedBox(height: 2),
                      Text(
                        'Coro dei ${angelo.choir.name}, retto da '
                        '${angelo.choir.archangel}',
                        style: TypographyTokens.body(size: 13)
                            .copyWith(color: ColorTokens.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Il suo coro veglia su ${angelo.choir.domain}.',
              style: TypographyTokens.body(size: 15).copyWith(height: 1.4),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(perche,
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
            const SizedBox(height: SpacingTokens.sm),
            if (lore != null) ...[
              // L'arco di cinque gradi col suo segno: e' la ragione per cui
              // questo angelo e' il tuo, detta col cielo alla mano.
              Text(
                '${lore.degrees} dello zodiaco, nel segno ${lore.sign}.',
                style: TypographyTokens.body(size: 15)
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4),
              ),
              if (lore.psalm.isNotEmpty) ...[
                const SizedBox(height: SpacingTokens.xs),
                Text(lore.psalm,
                    style: TypographyTokens.body(size: 15)
                        .copyWith(height: 1.45)),
              ],
              if (lore.tradition.isNotEmpty && !lore.confidenzaBassa) ...[
                const SizedBox(height: SpacingTokens.xs),
                Text(lore.tradition,
                    style: TypographyTokens.body(size: 15)
                        .copyWith(height: 1.45)),
              ],
              if (lore.reading.isNotEmpty) ...[
                const SizedBox(height: SpacingTokens.sm),
                // La chiave di lettura e' scritta in redazione, non e'
                // tradizione documentata: si mostra come voce del Maestro,
                // staccata da cio' che viene dalle fonti.
                Text('MEDORA LA LEGGE COSI',
                    style: TypographyTokens.label(size: 11).copyWith(
                        color: palette.goldSoft, letterSpacing: 2)),
                const SizedBox(height: 2),
                Text(lore.reading,
                    style: TypographyTokens.body(size: 15).copyWith(
                        color: ColorTokens.textSecondary, height: 1.45)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Il ritratto dell'angelo, con la luce che si accende dietro mentre entra.
class _Ritratto extends StatelessWidget {
  const _Ritratto({
    required this.angelo,
    required this.entrata,
    required this.indice,
    required this.palette,
  });

  final Angel angelo;
  final Animation<double> entrata;
  final int indice;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entrata,
      builder: (context, child) {
        final inizio = indice * 0.2;
        final t = ((entrata.value - inizio) / 0.6).clamp(0.0, 1.0);
        return Container(
          width: 92,
          height: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            boxShadow: [
              BoxShadow(
                color: palette.gold.withValues(alpha: 0.45 * t),
                blurRadius: 26 * t,
                spreadRadius: 2 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Image.asset(
          FamilyImage.full(AssetFamily.angeli, angelo.artStem),
          width: 92,
          height: 132,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 92,
            height: 132,
            color: palette.surface,
            child: Icon(Icons.auto_awesome, color: palette.goldSoft, size: 28),
          ),
        ),
      ),
    );
  }
}

/// Senza ora di nascita il terzo angelo non esiste, e lo si dice.
class _IntellettoMancante extends StatelessWidget {
  const _IntellettoMancante({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      key: const Key('angelo_intelletto_assente'),
      raised: false,
      opacity: 0.7,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ANGELO DELL\'INTELLETTO',
              style: TypographyTokens.label(size: 11)
                  .copyWith(color: palette.goldSoft, letterSpacing: 2)),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Questo terzo angelo nasce dall\'ora esatta della nascita, che non '
            'ci hai ancora detto. Quando la troverai, comparira\' qui: come '
            'l\'Ascendente e le case, senza ora non si calcola.',
            style: TypographyTokens.body(size: 15)
                .copyWith(color: ColorTokens.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// Come i tre vengono scelti, in linguaggio piano.
class _ComeSonoScelti extends StatelessWidget {
  const _ComeSonoScelti({required this.triade, required this.palette});

  final AngelTriad triade;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    Widget riga(String titolo, String testo) => Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titolo,
                  style: TypographyTokens.body(size: 15, weight: 600)
                      .copyWith(color: palette.goldSoft)),
              Text(testo,
                  style: TypographyTokens.body(size: 15)
                      .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
            ],
          ),
        );

    return DepthCard(
      key: const Key('angeli_come_scelti'),
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Come vengono scelti',
              style: TypographyTokens.display(size: 18)),
          const SizedBox(height: SpacingTokens.sm),
          riga(
            'Il Custode, dal cielo',
            'Il cerchio dello zodiaco ha trecentosessanta gradi e gli angeli '
                'sono settantadue: cinque gradi per ciascuno. Si guarda dove '
                'stava il Sole nel momento in cui sei nato, non il giorno sul '
                'calendario, poi si legge a chi tocca quel tratto di cielo.',
          ),
          riga(
            'Il Cuore, dal giorno',
            'I settantadue si susseguono un giorno ciascuno e ricominciano da '
                'capo lungo l\'anno. Il tuo e\' quello del '
                '${triade.dayOfYear}esimo giorno.',
          ),
          riga(
            'L\'Intelletto, dall\'ora',
            'Il giorno ha millequattrocentoquaranta minuti e gli angeli sono '
                'settantadue: venti minuti per ciascuno. Senza l\'ora di '
                'nascita questo angelo non si puo\' sapere.',
          ),
        ],
      ),
    );
  }
}
