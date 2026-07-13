import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/identity/birth_identity.dart';
import '../../core/identity/circle_seal.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'seal_painter.dart';

/// Il Sigillo del Cerchio, a fine onboarding subito dopo la carta natale.
///
/// Un emblema personale deterministico dai dati di nascita, disegnato dal codice
/// e composto con una breve animazione, che porta il nome dell'utente. E'
/// deterministico, quindi a costo zero. La condivisione e' predisposta come
/// card. L'arte definitiva del sigillo la fornira' Mauro: il disegno procedurale
/// resta la base sostituibile.
class CircleSealScreen extends StatefulWidget {
  const CircleSealScreen({super.key, this.name = 'Viandante', this.identity});

  final String name;
  final BirthIdentity? identity;

  static Route<void> route({String name = 'Viandante', BirthIdentity? identity}) {
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

  @override
  void initState() {
    super.initState();
    _seal = CircleSeal.from(
      name: widget.name,
      identity: widget.identity ?? BirthIdentity.example,
    );
    _compose = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();
  }

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
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: AnimatedBuilder(
                    animation: _compose,
                    builder: (context, _) => CustomPaint(
                      key: const Key('circle_seal'),
                      painter: SealPainter(seal: _seal, progress: _compose.value),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                  SpacingTokens.lg, SpacingTokens.lg),
              child: Column(
                children: [
                  Text(_seal.name,
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
                  _ShareButton(palette: palette, onTap: _share),
                  const SizedBox(height: SpacingTokens.sm),
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
          ],
        ),
      ),
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
              horizontal: SpacingTokens.lg, vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
            gradient: LinearGradient(colors: [
              palette.primary.withValues(alpha: 0.7),
              palette.surfaceElevated.withValues(alpha: 0.7),
            ]),
            border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.ios_share_rounded, size: 18, color: palette.goldSoft),
              const SizedBox(width: SpacingTokens.sm),
              Text('Condividi il sigillo',
                  style: TypographyTokens.display(size: 15)
                      .copyWith(color: palette.goldSoft)),
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
