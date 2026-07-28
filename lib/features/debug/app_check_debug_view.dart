import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/identity/profile_store.dart';
import '../../core/onboarding/onboarding_controller.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../onboarding/onboarding_screen.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import '../../services/firebase/app_check_debug.dart';

/// Il token di debug di App Check, mostrato a video nelle build di debug.
///
/// Serve a chi installa l'APK sul telefono e non ha un PC accanto: senza questo
/// il token si leggerebbe solo da logcat. Due punti di lettura, entrambi spenti
/// in release: la striscia in alto sulla prima schermata, che si incontra prima
/// dell'onboarding, piu' la riga in fondo alle Impostazioni, che si raggiunge
/// solo dopo. Il tocco copia negli appunti e conferma con una parola.
///
/// Il token viene dai servizi quando App Check si e' attivato; se l'attivazione
/// e' fallita si legge comunque dalle preferenze, perche' non dipende da
/// Firebase. Cosi' la riga non resta mai vuota in debug.

/// Striscia sottile in alto, richiudibile, sopra qualunque schermata.
class AppCheckDebugBanner extends StatefulWidget {
  const AppCheckDebugBanner({super.key, required this.child});

  final Widget child;

  @override
  State<AppCheckDebugBanner> createState() => _AppCheckDebugBannerState();
}

class _AppCheckDebugBannerState extends State<AppCheckDebugBanner> {
  bool _chiusa = false;

  @override
  Widget build(BuildContext context) {
    final services = context.watch<AppServices>();
    if (_chiusa || !services.showAppCheckDebugToken) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Material(
              color: Colors.transparent,
              child: _TokenLine(
                bannerKey: const Key('app_check_debug_banner'),
                token: services.appCheckDebugToken,
                onClose: () => setState(() => _chiusa = true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Riga in fondo alle Impostazioni, con il suo titolo di sezione.
class AppCheckDebugTokenRow extends StatelessWidget {
  const AppCheckDebugTokenRow({super.key});

  @override
  Widget build(BuildContext context) {
    final services = context.watch<AppServices>();
    if (!services.showAppCheckDebugToken) return const SizedBox.shrink();

    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.xl),
      child: Container(
        key: const Key('app_check_debug_row'),
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          border: Border.all(color: palette.gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Token di debug App Check',
              style: TypographyTokens.body(size: 13, weight: 600)
                  .copyWith(color: palette.goldSoft),
            ),
            const SizedBox(height: SpacingTokens.xxs),
            Text(
              'Tocca per copiarlo. Serve solo per l\'enforcement. Questa riga '
              'non compare nelle build pubbliche.',
              style: TypographyTokens.body(size: 13)
                  .copyWith(color: ColorTokens.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.xs),
            _TokenLine(token: services.appCheckDebugToken),
          ],
        ),
      ),
    );
  }
}

/// Comando di servizio, solo in debug: ripristina il Risveglio.
///
/// Azzera profilo, identita' e stato del rito, poi riapre l'onboarding. Senza
/// questo, per rivedere il Risveglio su un telefono bisogna svuotare i dati
/// dell'app dalle impostazioni di sistema a ogni prova. Come la striscia del
/// token, in release non esiste.
class RipristinaRisveglioRow extends StatelessWidget {
  const RipristinaRisveglioRow({super.key});

  Future<void> _ripristina(BuildContext context) async {
    final onboarding = context.read<OnboardingController>();
    final navigator = Navigator.of(context);
    await const ProfileStore().clear();
    await onboarding.reset();
    if (!context.mounted) return;
    // Si torna alla radice, poi si spinge il rito: cosi' non resta sotto la
    // pila delle Impostazioni da cui il comando e' partito.
    navigator.popUntil((r) => r.isFirst);
    navigator.push(OnboardingScreen.route());
  }

  @override
  Widget build(BuildContext context) {
    final services = context.watch<AppServices>();
    if (!services.showAppCheckDebugToken) return const SizedBox.shrink();
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.sm),
      child: DepthCard(
        key: const Key('debug_ripristina_risveglio'),
        raised: false,
        onTap: () => _ripristina(context),
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: palette.goldSoft, size: 22),
            const SizedBox(width: SpacingTokens.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ripeti il Risveglio',
                      style: TypographyTokens.display(size: 16)),
                  const SizedBox(height: 2),
                  Text(
                    'Azzera profilo e identita, poi riapre il rito. Solo '
                    'nelle build di prova.',
                    style: TypographyTokens.body(size: 13)
                        .copyWith(color: ColorTokens.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.goldSoft),
          ],
        ),
      ),
    );
  }
}

/// Il pezzo comune ai due punti: risolve il token, lo mostra, lo copia al
/// tocco e conferma per un istante. Con [onClose] valorizzato prende la forma
/// della striscia richiudibile, altrimenti quella della riga.
class _TokenLine extends StatefulWidget {
  const _TokenLine({this.bannerKey, this.token, this.onClose});

  final Key? bannerKey;
  final String? token;
  final VoidCallback? onClose;

  @override
  State<_TokenLine> createState() => _TokenLineState();
}

class _TokenLineState extends State<_TokenLine> {
  String? _token;
  bool _copiato = false;
  Timer? _conferma;

  @override
  void initState() {
    super.initState();
    _risolvi();
  }

  @override
  void didUpdateWidget(_TokenLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) _risolvi();
  }

  Future<void> _risolvi() async {
    final t = await AppCheckDebugToken.risolvi(widget.token);
    if (!mounted) return;
    setState(() => _token = t);
  }

  @override
  void dispose() {
    _conferma?.cancel();
    super.dispose();
  }

  Future<void> _copia() async {
    final t = _token;
    if (t == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: t));
    } catch (_) {
      // Senza appunti resta comunque leggibile a schermo, che e' lo scopo.
    }
    if (!mounted) return;
    setState(() => _copiato = true);
    _conferma?.cancel();
    _conferma = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copiato = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = _token;
    if (token == null) return const SizedBox.shrink();
    final striscia = widget.onClose != null;

    final testo = Text(
      key: const Key('app_check_debug_token'),
      _copiato ? 'Token copiato' : token,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TypographyTokens.label(size: 11).copyWith(
        color: _copiato ? ColorTokens.gold : ColorTokens.textPrimary,
        letterSpacing: 0.2,
      ),
    );

    final riga = Row(
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: ColorTokens.gold.withValues(alpha: 0.9),
        ),
        const SizedBox(width: SpacingTokens.xs),
        Expanded(child: GestureDetector(onTap: _copia, child: testo)),
        if (striscia)
          GestureDetector(
            key: const Key('app_check_debug_close'),
            onTap: widget.onClose,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
              child: Icon(Icons.close_rounded,
                  size: 16, color: ColorTokens.textSecondary),
            ),
          ),
      ],
    );

    if (!striscia) return riga;

    return Container(
      key: widget.bannerKey,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xxs,
      ),
      color: ColorTokens.neutralDeepest.withValues(alpha: 0.88),
      child: riga,
    );
  }
}
