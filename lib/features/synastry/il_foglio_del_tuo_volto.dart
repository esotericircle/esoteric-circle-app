import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/identity/profile_controller.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/transizioni/velo_del_cerchio.dart';
import 'user_photo.dart';

/// Le tre cose che la persona puo' mettere nella sua carta.
enum SceltaDelVolto { fotocamera, galleria, avatar }

/// **IL TUO VOLTO NELLA CORNICE, UNA SCELTA SOLA PER TUTTA LA SINASTRIA.**
/// Ordine ER voce 04, 27 settembre 2026.
///
/// **Parole del fondatore:** "se faccio click sulla mia carta, mi fa scegliere
/// un vip anziché farmi scegliere un avatar o di inserire una mia foto o
/// immagine".
///
/// **Da dove veniva il difetto.** Il foglio della foto c'era, ma viveva solo
/// nel responso, sul polo della persona. Quando l'ordine CA ha messo la porta
/// con le due carte davanti a tutto (voce CA.01), la carta "Tu" della porta ha
/// preso il tocco che sceglie un VIP (voce CA.02), che serviva al confronto
/// fra due VIP: la carta che la persona tocca per prima non portava piu' al
/// suo volto.
///
/// **Adesso il foglio e' uno, e la scelta si scrive in un posto solo**, la
/// foto del profilo, tenuta in locale: la porta e il responso la leggono da
/// li', e la card da condividere la riceve dal responso. Cambiarla in un posto
/// la cambia in tutti. Se il profilo non c'e' (prove isolate) la scelta resta
/// nel controller di chi l'ha chiesta.
class IlFoglioDelTuoVolto {
  const IlFoglioDelTuoVolto._();

  /// Apre il foglio e restituisce la scelta, oppure nulla se la persona lo
  /// chiude senza scegliere.
  static Future<SceltaDelVolto?> apri(
    BuildContext context, {
    required MaestroPalette palette,
    required bool haUnaFoto,
  }) {
    return foglioDelCerchio<SceltaDelVolto>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SpacingTokens.radiusLg)),
      ),
      builder: (sheetContext) {
        void scegli(SceltaDelVolto s) => Navigator.of(sheetContext).pop(s);
        return SafeArea(
          child: Padding(
            key: const Key('il_foglio_del_tuo_volto'),
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Il tuo volto nella cornice',
                    style: TypographyTokens.titoloScheda()
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                    'La foto resta sul tuo dispositivo e non viene caricata da nessuna parte: la vedi nella tua carta, nel responso e nella card che decidi di condividere. Se preferisci, resta il tuo avatar a costellazione.',
                    style: TypographyTokens.corpo().copyWith(
                        color: ColorTokens.textSecondary, height: 1.4)),
                const SizedBox(height: SpacingTokens.lg),
                FilledButton.icon(
                  key: const Key('photo_camera'),
                  style: FilledButton.styleFrom(
                      backgroundColor: palette.gold,
                      foregroundColor: palette.deepest),
                  onPressed: () => scegli(SceltaDelVolto.fotocamera),
                  icon: const Icon(Icons.photo_camera_rounded, size: 18),
                  label: const Text('Usa la fotocamera'),
                ),
                const SizedBox(height: SpacingTokens.sm),
                OutlinedButton.icon(
                  key: const Key('photo_gallery'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: palette.goldSoft,
                      side: BorderSide(
                          color: palette.gold.withValues(alpha: 0.6))),
                  onPressed: () => scegli(SceltaDelVolto.galleria),
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Scegli un\'immagine dalla galleria'),
                ),
                const SizedBox(height: SpacingTokens.sm),
                TextButton.icon(
                  key: const Key('photo_clear'),
                  style: TextButton.styleFrom(
                      foregroundColor: ColorTokens.textSecondary),
                  onPressed: () => scegli(SceltaDelVolto.avatar),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 18),
                  label: Text(haUnaFoto
                      ? 'Togli la foto, torna al tuo avatar'
                      : 'Tieni il tuo avatar a costellazione'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Apre il foglio, esegue la scelta sul controller di chi chiede e la
  /// scrive nel profilo, cosi' che ogni altra schermata la veda.
  static Future<void> scegliERicorda(
    BuildContext context, {
    required MaestroPalette palette,
    required UserPhotoController foto,
  }) async {
    final profilo = profiloDi(context);
    final scelta =
        await apri(context, palette: palette, haUnaFoto: foto.hasPhoto);
    switch (scelta) {
      case null:
        return;
      case SceltaDelVolto.avatar:
        foto.clear();
        profilo?.clearAvatarPhoto();
      case SceltaDelVolto.fotocamera:
      case SceltaDelVolto.galleria:
        final prima = foto.bytes;
        await foto.pickFrom(scelta == SceltaDelVolto.fotocamera
            ? UserPhotoSource.camera
            : UserPhotoSource.gallery);
        final dopo = foto.bytes;
        if (dopo != null && !identical(dopo, prima)) {
          profilo?.setAvatarPhoto(dopo);
        }
    }
  }

  /// Il profilo, se e' nell'albero. Nelle prove isolate non c'e', e la scelta
  /// resta nel controller di chi l'ha chiesta.
  static ProfileController? profiloDi(BuildContext context) {
    try {
      return context.read<ProfileController>();
    } on ProviderNotFoundException {
      return null;
    }
  }
}
