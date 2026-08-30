import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/identity/profile_controller.dart';
import '../../design_system/components/user_avatar.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../synastry/user_photo.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// La sezione Profilo dell'Area Utente: qui l'utente da' un volto al suo posto
/// nel Cerchio, la sua foto oppure l'identita' di default a tema (il segno, le
/// iniziali o il sigillo neutro).
///
/// La foto resta SOLO in locale sul dispositivo, mai caricata. Il consenso e'
/// esplicito, con lo stesso tono della Sinastria.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.photoService});

  /// Sorgente foto iniettabile per i test; in produzione usa image_picker.
  final UserPhotoService? photoService;

  static Route<void> route({UserPhotoService? photoService}) =>
      PassaggioDelCerchio.rotta<void>((_) => ProfileScreen(photoService: photoService));

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileController>();

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: ColorTokens.textPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Profilo', style: TypographyTokens.titoloDiSchermata()),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
              SpacingTokens.lg, SpacingTokens.xxxl),
          children: [
            Center(
              child: UserAvatar.forUser(context,
                  size: 128, key: const Key('profile_avatar')),
            ),
            const SizedBox(height: SpacingTokens.md),
            Center(
              child: Text(
                profile.hasName ? profile.vocative : 'Anima del Cerchio',
                style: TypographyTokens.titoloSezione(),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Center(
              child: Text(
                profile.hasAvatarPhoto
                    ? 'Questo è il tuo volto nel Cerchio.'
                    : 'Metti il tuo volto nel Cerchio, o lascia parlare il tuo segno.',
                key: const Key('profile_avatar_invite'),
                textAlign: TextAlign.center,
                style: TypographyTokens.corpo()
                    .copyWith(color: ColorTokens.textSecondary, height: 1.4),
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),
            _Action(
              key: const Key('profile_avatar_pick'),
              icon: Icons.add_a_photo_outlined,
              label: 'Scatta o scegli una foto',
              onTap: () => _pickPhoto(context),
            ),
            const SizedBox(height: SpacingTokens.sm),
            if (profile.hasAvatarPhoto)
              _Action(
                key: const Key('profile_avatar_remove'),
                icon: Icons.auto_awesome_outlined,
                label: 'Rimuovi la foto e usa il tuo segno',
                onTap: () => context.read<ProfileController>().clearAvatarPhoto(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final controller = context.read<ProfileController>();
    final service = photoService ?? ImagePickerPhotoService();
    final source = await showModalBottomSheet<UserPhotoSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ConsentSheet(),
    );
    if (source == null) return;
    try {
      final bytes = await service.pick(source);
      if (bytes != null && bytes.isNotEmpty) {
        controller.setAvatarPhoto(bytes);
      }
    } catch (_) {
      // Permesso negato o plugin assente: si resta all'avatar di default.
    }
  }
}

/// Il foglio del consenso: scegliere la sorgente con garbo, dichiarando che la
/// foto resta solo sul dispositivo.
class _ConsentSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('profile_avatar_consent'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
          SpacingTokens.lg, SpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ColorTokens.neutralSurface, ColorTokens.neutralDeepest],
        ),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(SpacingTokens.radiusXl)),
        border: Border.all(color: ColorTokens.gold.withValues(alpha: 0.3)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Il tuo volto nel Cerchio',
                style: TypographyTokens.titoloDiSchermata()
                    .copyWith(color: ColorTokens.goldLight)),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'La tua foto resta solo su questo dispositivo, non lascia mai il '
              'Cerchio. Puoi toglierla quando vuoi.',
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.4),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SourceButton(
              key: const Key('profile_source_camera'),
              icon: Icons.photo_camera_outlined,
              label: 'Scatta una foto',
              onTap: () =>
                  Navigator.of(context).pop(UserPhotoSource.camera),
            ),
            const SizedBox(height: SpacingTokens.sm),
            _SourceButton(
              key: const Key('profile_source_gallery'),
              icon: Icons.photo_library_outlined,
              label: 'Scegli dalla galleria',
              onTap: () =>
                  Navigator.of(context).pop(UserPhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton(
      {super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            color: ColorTokens.neutralDeep.withValues(alpha: 0.6),
            border: Border.all(color: ColorTokens.gold.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(icon, color: ColorTokens.goldLight, size: 22),
              const SizedBox(width: SpacingTokens.md),
              Text(label,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action(
      {super.key, required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            color: ColorTokens.neutralSurface.withValues(alpha: 0.5),
            border: Border.all(color: ColorTokens.gold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: ColorTokens.goldLight, size: 22),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Text(label,
                    style: TypographyTokens.corpo()
                        .copyWith(color: ColorTokens.textPrimary)),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: ColorTokens.goldLight, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
