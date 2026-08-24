import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../maestro/maestro.dart';

/// I permessi di sistema che l'app puo' chiedere. Ognuno si chiede solo nel
/// momento in cui serve la sua funzione, mai tutti all'avvio.
/// I permessi di sistema che l'app puo' chiedere. Ognuno si chiede solo nel
/// momento in cui serve la sua funzione, mai tutti all'avvio.
///
/// L'elenco delle chiavi di sistema, delle voci del manifest e dei ripieghi
/// vive in `registro_dei_permessi.dart`, che una prova confronta coi file
/// veri di iOS e di Android.
enum AppPermission {
  microphone,
  camera,
  photoLibrary,
  motion,
  notifications,
  location,
}

/// Testo del pre-avviso, nel tono del Maestro quando pertinente. E' onesto: dice
/// a cosa serve e cosa NON fa.
class PermissionCopy {
  const PermissionCopy({
    required this.icon,
    required this.title,
    required this.body,
    required this.cta,
    this.decline = 'Non ora',
  });

  final IconData icon;
  final String title;
  final String body;
  final String cta;
  final String decline;
}

PermissionCopy permissionCopy(AppPermission p, {Maestro? maestro}) {
  final name = maestro?.displayName ?? 'il cerchio';
  switch (p) {
    case AppPermission.microphone:
      return PermissionCopy(
        icon: Icons.mic_none_rounded,
        title: 'Il soffio ha bisogno del microfono',
        body:
            'Per soffiare con $name, il microfono ascolta solo il tuo soffio, non registra nulla né conserva audio.',
        cta: 'Attiva il microfono',
      );
    case AppPermission.photoLibrary:
      return const PermissionCopy(
        icon: Icons.photo_library_outlined,
        title: 'La tua foto entra solo nella card',
        body:
            'Scegli tu quale immagine mettere nella card della Sinastria. Resta sul dispositivo e non viene caricata da nessuna parte.',
        cta: 'Scegli una foto',
      );
    case AppPermission.camera:
      return const PermissionCopy(
        icon: Icons.photo_camera_outlined,
        title: 'Questo rito ha bisogno della fotocamera',
        body:
            'Serve solo per leggere il gesto nel momento, sul tuo dispositivo. Nessuna immagine viene salvata ne inviata.',
        cta: 'Attiva la fotocamera',
      );
    case AppPermission.motion:
      return const PermissionCopy(
        icon: Icons.screen_rotation_outlined,
        title: 'Il cielo segue il tuo movimento',
        body:
            'Con i sensori di movimento il cielo si muove quando inclini il telefono. Puoi sempre usare il dito.',
        cta: 'Attiva il movimento',
      );
    case AppPermission.notifications:
      return const PermissionCopy(
        icon: Icons.notifications_none_rounded,
        title: 'I tuoi cinque Doni del giorno',
        // Ordine BG voce 03: il testo di prima prometteva avvisi che nessuno
        // programma (le ricorrenze del cielo e i transiti). Gli avvisi veri
        // sono i cinque Doni, ognuno col suo interruttore e il suo orario.
        body:
            'Un avviso per ciascun Dono del giorno, alla sua ora: Alba, Soffio, Arcano, Tramonto e Sogno. Ognuno si spegne e si sposta da solo.',
        cta: 'Attiva gli avvisi',
      );
    case AppPermission.location:
      return const PermissionCopy(
        icon: Icons.place_outlined,
        title: 'Il cielo del luogo in cui sei',
        body:
            'La posizione serve a mostrare il cielo sopra di te ora. Le coordinate restano qui; il solo nome del luogo lo chiedo al sistema del telefono.',
        cta: 'Usa la mia posizione',
      );
  }
}

/// Chiede un permesso con garbo: prima un pre-avviso in tono, poi (se accettato)
/// la richiesta di sistema. Se il pre-avviso viene rifiutato, non parte alcuna
/// richiesta di sistema e resta il fallback: si potra' riproporre piu' avanti.
///
/// [systemRequest] incapsula la vera richiesta di sistema (il plugin), cosi' lo
/// schema resta riusabile per microfono, fotocamera, movimento, notifiche e
/// posizione.
Future<bool> requestPermissionWithPrelude(
  BuildContext context, {
  required AppPermission permission,
  required MaestroPalette palette,
  required Future<bool> Function() systemRequest,
  Maestro? maestro,
  PermissionCopy? copy,
}) async {
  final c = copy ?? permissionCopy(permission, maestro: maestro);
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    // La spiegazione NON sparisce da sola. Con i valori di difetto un tocco
    // fuori o uno sfioramento la chiudevano, e succedeva proprio dove succede
    // di piu': nella schermata del soffio si tocca e si trascina per far
    // muovere la scena, quindi il foglio spariva prima di essere letto e il
    // permesso restava non concesso senza che nessuno capisse perche'.
    //
    // Si esce con una scelta dichiarata, mai per caso.
    isDismissible: false,
    enableDrag: false,
    builder: (ctx) => PopScope(
      // Anche il gesto Indietro di sistema vale come "non ora", non come una
      // chiusura muta: cosi' chi esce sa di aver scelto.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(ctx).pop(false);
      },
      child: _PreludeSheet(copy: c, palette: palette),
    ),
  );
  if (accepted != true) return false;
  return systemRequest();
}

class _PreludeSheet extends StatelessWidget {
  const _PreludeSheet({required this.copy, required this.palette});
  final PermissionCopy copy;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(SpacingTokens.md),
        padding: const EdgeInsets.all(SpacingTokens.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [palette.surfaceElevated, palette.deepest],
          ),
          borderRadius: BorderRadius.circular(SpacingTokens.radiusXl),
          border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.primary.withValues(alpha: 0.4),
                border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
              ),
              child: Icon(copy.icon, color: palette.goldSoft, size: 30),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(copy.title,
                textAlign: TextAlign.center,
                style: TypographyTokens.display(size: 21)),
            const SizedBox(height: SpacingTokens.sm),
            Text(copy.body,
                textAlign: TextAlign.center,
                style: TypographyTokens.body(size: TypographyTokens.guide)
                    .copyWith(color: ColorTokens.textSecondary, height: 1.45)),
            const SizedBox(height: SpacingTokens.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: palette.gold,
                  foregroundColor: palette.deepest,
                  padding:
                      const EdgeInsets.symmetric(vertical: SpacingTokens.md),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(SpacingTokens.radiusPill),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(copy.cta,
                    style: TypographyTokens.body(size: 17, weight: 600)
                        .copyWith(color: palette.deepest)),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            TextButton(
              key: const Key('permesso_non_ora'),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(copy.decline,
                  style: TypographyTokens.body(size: 16)
                      .copyWith(color: ColorTokens.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }
}
