import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/identity/birth_identity.dart';
import '../../core/identity/circle_seal.dart';
import '../../core/identity/numerology.dart';
import '../../core/voice/voice_greeting.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'seal_painter.dart';

/// Il Sigillo del Cerchio, a fine onboarding subito dopo la carta natale.
///
/// Non un emblema statico ma un'esperienza: la ruota si disegna, il Sole scende
/// sul segno, l'elemento invade la scena, il Numero della vita si forma al
/// centro, mentre Medora accompagna con una frase (sottotitolo sempre attivo,
/// voce Gemini-TTS quando c'e'). Sotto, il pannello "Cosa significa" spiega da
/// dove nasce ogni cosa, per chi vuole capire. Chi vuole solo l'emblema usa
/// "Condividi il sigillo". Il disegno procedurale resta la base, sostituibile
/// con l'arte definitiva.
class CircleSealScreen extends StatefulWidget {
  const CircleSealScreen({
    super.key,
    this.name = 'Anima del Cerchio',
    this.identity,
    this.voice = const SilentVoiceGreeting(),
  });

  final String name;
  final BirthIdentity? identity;

  /// Voce dei Maestri: parla la frase di Medora quando disponibile, altrimenti
  /// resta il solo sottotitolo.
  final VoiceGreeting voice;

  static Route<void> route({
    String name = 'Anima del Cerchio',
    BirthIdentity? identity,
  }) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          MaestroScope(child: CircleSealScreen(name: name, identity: identity)),
    );
  }

  @override
  State<CircleSealScreen> createState() => _CircleSealScreenState();
}

class _CircleSealScreenState extends State<CircleSealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _compose;
  late final CircleSeal _seal;
  late final BirthIdentity _identity;
  late final String _phrase;
  bool _showMeaning = false;

  @override
  void initState() {
    super.initState();
    _identity = widget.identity ?? BirthIdentity.example;
    _seal = CircleSeal.from(name: widget.name, identity: _identity);
    _phrase = _medoraPhrase(widget.name);
    _compose = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    // La voce e' un di piu': se non parla, resta il sottotitolo, sempre attivo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.voice.speak(_phrase);
    });
  }

  // La frase di Medora che accompagna la comparsa, breve e nella sua voce.
  static String _medoraPhrase(String name) =>
      '$name, guarda: il Sole si posa nel tuo segno e accende il tuo Sigillo.';

  @override
  void dispose() {
    _compose.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    try {
      final bytes = await _renderSeal(_seal, 1080);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/sigillo_del_cerchio.png');
      await file.writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'image/png')],
          text:
              'Il mio Sigillo del Cerchio. Scopri il tuo con Esoteric Circle. #EsotericCircle',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Non è stato possibile condividere ora.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
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
        title: Text('Il tuo Sigillo del Cerchio',
            style: TypographyTokens.display(size: 18)),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
              SpacingTokens.lg, SpacingTokens.xxxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Livello visivo: il sigillo che si compone.
              AspectRatio(
                aspectRatio: 1,
                child: AnimatedBuilder(
                  animation: _compose,
                  builder: (context, _) => CustomPaint(
                    key: const Key('circle_seal'),
                    painter: SealPainter(seal: _seal, progress: _compose.value),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(_seal.name,
                  textAlign: TextAlign.center,
                  style: TypographyTokens.display(size: 24)
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: 4),
              Text(
                '${_seal.sign.italianName} · Elemento ${_seal.element.label} · '
                'Numero ${_seal.lifePath}',
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: 14)
                    .copyWith(color: ColorTokens.textSecondary),
              ),
              const SizedBox(height: SpacingTokens.md),
              // La frase di Medora, sottotitolo sempre attivo, con la voce quando c'e'.
              _MedoraSubtitle(text: _phrase, palette: palette),
              const SizedBox(height: SpacingTokens.md),
              _ShareButton(palette: palette, onTap: _share),
              const SizedBox(height: SpacingTokens.md),
              // Chi vuole capire tocca e legge: il pannello si apre a richiesta.
              _MeaningPanel(
                seal: _seal,
                identity: _identity,
                expanded: _showMeaning,
                onToggle: () => setState(() => _showMeaning = !_showMeaning),
                palette: palette,
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                'Disegno procedurale, base del sigillo: l\'arte definitiva '
                'arriva dopo.',
                textAlign: TextAlign.center,
                style: TypographyTokens.label(size: 10).copyWith(
                  color: palette.goldSoft.withValues(alpha: 0.6),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La frase di Medora sotto il sigillo, con l'icona della voce a indicare che il
/// sottotitolo e' sempre attivo, la voce quando il device la sa dire.
class _MedoraSubtitle extends StatelessWidget {
  const _MedoraSubtitle({required this.text, required this.palette});

  final String text;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('seal_greeting'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        gradient: LinearGradient(colors: [
          palette.surfaceElevated.withValues(alpha: 0.7),
          palette.deepest.withValues(alpha: 0.6),
        ]),
        border: Border.all(color: palette.gold.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.graphic_eq_rounded, size: 18, color: palette.goldSoft),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              text,
              style: TypographyTokens.body(size: 15).copyWith(
                color: ColorTokens.textPrimary,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Il pannello "Cosa significa": da dove nasce ogni cosa del sigillo. La ruota e
/// lo zodiaco col Sole nel segno, il Numero e la riduzione passo per passo, e
/// l'elemento con la sua natura.
class _MeaningPanel extends StatelessWidget {
  const _MeaningPanel({
    required this.seal,
    required this.identity,
    required this.expanded,
    required this.onToggle,
    required this.palette,
  });

  final CircleSeal seal;
  final BirthIdentity identity;
  final bool expanded;
  final VoidCallback onToggle;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final breakdown = LifePath.breakdown(identity.birthMoment);
    return DepthCard(
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const Key('seal_meaning_toggle'),
            onTap: onToggle,
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 20, color: palette.goldSoft),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text('Cosa significa',
                      style: TypographyTokens.display(size: 17)
                          .copyWith(color: palette.goldSoft)),
                ),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: palette.goldSoft,
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: SpacingTokens.md),
            Column(
              key: const Key('seal_meaning_panel'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MeaningBlock(
                  icon: Icons.brightness_7_rounded,
                  title: 'La ruota, lo zodiaco',
                  body:
                      'La ruota esterna è lo zodiaco. Il Sole si posa nel tuo '
                      'segno, ${seal.sign.italianName}: da lì nasce il tuo tono.',
                  palette: palette,
                ),
                const SizedBox(height: SpacingTokens.md),
                _MeaningBlock(
                  icon: Icons.tag_rounded,
                  title: 'Il Numero della vita: ${seal.lifePath}',
                  body:
                      'Nasce dalla tua data di nascita, ridotta a una cifra passo '
                      'per passo.',
                  palette: palette,
                  steps: breakdown.steps,
                ),
                const SizedBox(height: SpacingTokens.md),
                _MeaningBlock(
                  icon: Icons.local_fire_department_rounded,
                  title: 'L\'elemento: ${seal.element.label}',
                  body: seal.element.meaning,
                  palette: palette,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Un blocco del pannello: icona, titolo, riga di significato e, per il Numero,
/// i passaggi della riduzione.
class _MeaningBlock extends StatelessWidget {
  const _MeaningBlock({
    required this.icon,
    required this.title,
    required this.body,
    required this.palette,
    this.steps,
  });

  final IconData icon;
  final String title;
  final String body;
  final MaestroPalette palette;
  final List<String>? steps;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: palette.goldSoft),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TypographyTokens.display(size: 15)
                      .copyWith(color: ColorTokens.textPrimary)),
              const SizedBox(height: 2),
              Text(body,
                  style: TypographyTokens.body(size: 13).copyWith(
                      color: ColorTokens.textSecondary, height: 1.35)),
              if (steps != null) ...[
                const SizedBox(height: SpacingTokens.sm),
                for (final line in steps!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(line,
                        style: TypographyTokens.body(size: 13).copyWith(
                          color: palette.goldSoft,
                          height: 1.3,
                        )),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.palette, required this.onTap});

  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('seal_share'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            gradient: LinearGradient(colors: [
              palette.primary.withValues(alpha: 0.7),
              palette.surfaceElevated.withValues(alpha: 0.7),
            ]),
            border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ios_share_rounded, size: 18, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Flexible(
                child: Text('Condividi il sigillo',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.display(size: 15)
                        .copyWith(color: palette.goldSoft)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rende il sigillo in PNG per la condivisione, sfondo scuro incluso.
Future<List<int>> _renderSeal(CircleSeal seal, double side) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, side, side));
  canvas.drawRect(
    Rect.fromLTWH(0, 0, side, side),
    Paint()..color = ColorTokens.neutralDeepest,
  );
  SealPainter(seal: seal, progress: 1.0).paint(canvas, Size(side, side * 0.86));
  // Nome inciso in basso.
  final tp = TextPainter(
    text: TextSpan(
      text: seal.name,
      style: TextStyle(
        fontFamily: 'Cinzel',
        fontSize: side * 0.06,
        color: const Color(0xFFE8C463),
      ),
    ),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: side);
  tp.paint(canvas, Offset((side - tp.width) / 2, side * 0.88));
  final picture = recorder.endRecording();
  final image = await picture.toImage(side.toInt(), side.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  picture.dispose();
  image.dispose();
  return data!.buffer.asUint8List();
}
