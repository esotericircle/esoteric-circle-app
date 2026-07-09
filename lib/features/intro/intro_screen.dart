import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Intro cinematografica.
///
/// Integra il video pre-renderizzato di brand. Per evitare lo sfarfallio
/// bianco al caricamento c'e' sempre un primo frame statico nero (l'intro apre
/// sul nulla), mostrato finche' il video non e' pronto. Per i device lenti o in
/// caso di errore c'e' un fallback: se il video non parte, si offre comunque
/// l'ingresso al Risveglio, senza schermate tecniche. Un tocco Salta e' sempre
/// disponibile.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _failed = false;
  bool _finished = false;
  Timer? _slowTimer;

  @override
  void initState() {
    super.initState();
    _init();
    // Fallback per device lenti: se dopo qualche secondo il video non e'
    // ancora pronto, si sblocca comunque l'ingresso manuale.
    _slowTimer = Timer(const Duration(seconds: 6), () {
      if (!_ready && mounted) setState(() => _failed = true);
    });
  }

  Future<void> _init() async {
    final controller =
        VideoPlayerController.asset('brand_assets/intro/Intro-Test-1.mp4');
    _controller = controller;
    controller.addListener(_onTick);
    try {
      await controller.initialize();
      if (!mounted) return;
      await controller.setVolume(1);
      await controller.play();
      setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  void _onTick() {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    // Fine del video: passa all'onboarding.
    if (!_finished &&
        c.value.position >= c.value.duration &&
        c.value.duration > Duration.zero) {
      _finish();
    }
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    widget.onFinish();
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Primo frame statico: nero come l'apertura dell'intro, evita il
          // lampo bianco al caricamento e fa da fallback ai device lenti.
          const _IntroPoster(),
          if (_ready && c != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: c.value.size.width,
                height: c.value.size.height,
                child: VideoPlayer(c),
              ),
            ),
          // Fallback: se il video non parte, invito elegante a entrare.
          if (_failed && !_ready)
            Center(
              child: _EnterButton(label: 'Entra nel Risveglio', onTap: _finish),
            ),
          // Salta, sempre disponibile.
          Positioned(
            top: SpacingTokens.md,
            right: SpacingTokens.md,
            child: SafeArea(
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Salta',
                  style: TypographyTokens.body(size: 14).copyWith(
                    color: ColorTokens.goldLight,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Poster statico dell'intro: nero profondo con un filo d'oro, coerente con
/// l'apertura In principio era il nulla.
class _IntroPoster extends StatelessWidget {
  const _IntroPoster();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [Color(0xFF0A0A12), Colors.black],
        ),
      ),
      child: Center(
        child: Text(
          'ESOTERIC CIRCLE',
          style: TypographyTokens.display(size: 16).copyWith(
            color: ColorTokens.gold.withValues(alpha: 0.4),
            letterSpacing: 6,
          ),
        ),
      ),
    );
  }
}

class _EnterButton extends StatelessWidget {
  const _EnterButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: ColorTokens.gold,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.xl,
          vertical: SpacingTokens.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        ),
      ),
      onPressed: onTap,
      child: Text(
        label,
        style: TypographyTokens.body(size: 15, weight: 600)
            .copyWith(color: Colors.black),
      ),
    );
  }
}
