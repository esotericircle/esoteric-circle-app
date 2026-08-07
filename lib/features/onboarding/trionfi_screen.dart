import 'package:flutter/material.dart';

import '../../core/angels/angel_catalog.dart';
import '../../core/angels/guardian_angels.dart';
import '../../core/onboarding/scheda_della_scelta.dart';
import '../../core/rituals/animal_catalog.dart';
import '../angels/angelo_ingrandito.dart';
import '../../core/assets/family_image.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestri/caligo/animal/animal_reveal.dart';
import 'riquadro_della_scelta.dart';

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
    this.onBack,
    this.reduceMotion = false,
    this.mostraImmagine = true,
    this.mostraNebbia = true,
  });

  /// SOLO PER LA BUILD DIAGNOSTICA (kDiagnosiAttiva): l'ingresso a tappe
  /// monta prima i testi senza immagine, poi l'immagine senza nebbia, poi
  /// tutto. Fuori dalla diagnosi restano veri e non cambiano niente.
  final bool mostraImmagine;
  final bool mostraNebbia;

  final GuideAnimal animale;
  final MaestroPalette palette;
  final VoidCallback onContinue;

  /// Torna al trionfo precedente. Nullo sul primo, dove un indietro non esiste:
  /// una freccia che non porta da nessuna parte e' peggio di nessuna freccia.
  final VoidCallback? onBack;

  final bool reduceMotion;

  @override
  State<TrionfoAnimale> createState() => _TrionfoAnimaleState();
}

class _TrionfoAnimaleState extends State<TrionfoAnimale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scena;

  /// La scheda del riquadro, generata UNA volta: il contenuto viene dal
  /// generatore in core/onboarding, non da questa schermata (ordine 2163,
  /// voce 12).
  late final SchedaDellaScelta _scheda;

  @override
  void initState() {
    super.initState();
    _scheda = GeneratoreDellaScheda.perAnimale(widget.animale);
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
          child: Stack(
            children: [
              _corpoAnimale(t, nome, invito),
              // La freccia indietro, in alto a sinistra: c'e' solo quando un
              // indietro esiste davvero.
              if (widget.onBack != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    key: const Key('trionfo_animale_indietro'),
                    tooltip: 'Indietro',
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: widget.palette.goldSoft,
                    onPressed: widget.onBack,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _corpoAnimale(double t, double nome, double invito) {
    return Padding(
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
                // In diagnosi l'immagine e la nebbia entrano a tappe: senza
                // immagine resta il suo ingombro, cosi' i testi non saltano.
                if (!widget.mostraImmagine)
                  const SizedBox(width: 280, height: 280)
                else
                  AnimalReveal(
                    assetTotem: widget.animale.fullPath,
                    palette: widget.palette,
                    lato: 280,
                    conNebbia: widget.mostraNebbia,
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
                        // IL RIQUADRO DELLA SCELTA, ordine 2163 voce 12:
                        // sotto il nome restava mezzo schermo vuoto. Entra
                        // col nome, perche' e' parte della stessa risposta.
                        const SizedBox(height: SpacingTokens.md),
                        RiquadroDellaScelta(
                            scheda: _scheda, palette: widget.palette),
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
    this.onBack,
    this.reduceMotion = false,
  });

  final AngelTriad triade;
  final MaestroPalette palette;
  final VoidCallback onContinue;

  /// Torna al trionfo precedente, quello dell'Animale.
  final VoidCallback? onBack;

  final bool reduceMotion;

  /// Quanto passa fra un Angelo e il successivo.
  static const Duration passo = Duration(milliseconds: 900);

  @override
  State<TrionfoAngeli> createState() => _TrionfoAngeliState();
}

class _TrionfoAngeliState extends State<TrionfoAngeli>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scena;

  /// La scheda del riquadro, la STESSA forma del trionfo dell'Animale:
  /// un componente solo, usato due volte (ordine 2163, voce 12).
  late final SchedaDellaScelta _scheda;

  @override
  void initState() {
    super.initState();
    _scheda = GeneratoreDellaScheda.perAngeli(widget.triade);
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
          child: Stack(
            children: [
              _corpoAngeli(angeli, t, invito),
              // La freccia indietro: dal trionfo degli Angeli si torna a quello
              // dell'Animale.
              if (widget.onBack != null)
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    key: const Key('trionfo_angeli_indietro'),
                    tooltip: 'Indietro',
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: widget.palette.goldSoft,
                    onPressed: widget.onBack,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _corpoAngeli(List<Angel> angeli, double t, double invito) {
    return Padding(
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
                  'Tre nomi dalla tradizione dei settantadue. Tocca una '
                  'carta per conoscerla.',
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
                          ruolo: RuoloAngelo.perIndice(i),
                          palette: widget.palette,
                          // La finestra di ciascuno: il primo apre, gli altri
                          // seguono a distanza, mai insieme.
                          avanzamento: ((t * (angeli.length + 1) - i) / 1.0)
                              .clamp(0.0, 1.0),
                        ),
                      ),
                  ],
                ),
                // IL RIQUADRO DELLA SCELTA, la stessa forma dell'Animale:
                // arriva con l'invito, quando i tre si sono gia' accesi.
                const SizedBox(height: SpacingTokens.md),
                Opacity(
                  opacity: invito,
                  child: RiquadroDellaScelta(
                      scheda: _scheda, palette: widget.palette),
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
    );
  }
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
  final RuoloAngelo ruolo;
  final MaestroPalette palette;

  /// Da 0 (ancora al buio) a 1 (acceso del tutto).
  final double avanzamento;

  @override
  Widget build(BuildContext context) {
    final k = Curves.easeOut.transform(avanzamento);
    final nome = ((avanzamento - 0.55) / 0.45).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xxs),
      // Al tocco si apre l'ingrandimento: sotto le tre carte restava
      // mezzo schermo vuoto, e tre nomi da soli non dicono niente a chi
      // non li conosce gia'.
      child: GestureDetector(
        key: Key('angelo_carta_${angelo.number}'),
        onTap: () =>
            AngeloIngrandito.apri(context, angelo: angelo, ruolo: ruolo),
        behavior: HitTestBehavior.opaque,
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
                // Una riga sola e nessuna spezzatura: "Dell\'intelletto" si
                // rompeva a meta' parola su due righe, che e' il modo piu'
                // rapido per rendere illeggibile un'etichetta corta.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(ruolo.titolo,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      softWrap: false,
                      style: TypographyTokens.label(size: 11).copyWith(
                          color: palette.goldSoft.withValues(alpha: 0.75),
                          letterSpacing: 1.2)),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

/// Quante posizioni distinte ha la sequenza: serve ai test per sapere quando
/// un Angelo e' gia' acceso e un altro non ancora.
double avanzamentoAngelo(double t, int indice, int quanti) =>
    ((t * (quanti + 1) - indice) / 1.0).clamp(0.0, 1.0);
