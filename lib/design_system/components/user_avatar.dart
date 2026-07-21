import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/zodiac.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../tokens/color_tokens.dart';
import '../tokens/typography_tokens.dart';
import 'zodiac_glyph.dart';

/// Il volto dell'utente nel Cerchio, in un tondo, con quattro ripieghi in ordine
/// di priorita', cosi' non c'e' mai un cerchio vuoto:
///
/// 1. la foto dell'utente, se ne ha scelta una (tenuta solo in locale);
/// 2. altrimenti l'emblema del suo segno solare, riusando l'arte gia' esistente;
/// 3. altrimenti un sigillo con le iniziali del nome;
/// 4. altrimenti un sigillo neutro del Cerchio.
///
/// E' un widget puro e testabile: i dati arrivano dai parametri. Per l'uso vivo
/// c'e' [UserAvatar.forUser], che li legge dai controller.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.photo,
    this.sign,
    this.name,
    this.size = 40,
  });

  /// La foto dell'utente, se presente. Ha la precedenza su tutto.
  final ImageProvider? photo;

  /// Il segno solare, per l'emblema di default quando non c'e' la foto.
  final Zodiac? sign;

  /// Il nome, da cui nascono le iniziali del sigillo di ripiego.
  final String? name;

  final double size;

  /// Le iniziali dal nome: la prima lettera del primo e dell'ultimo nome, o la
  /// sola prima se il nome e' unico. Maiuscole, accenti rispettati.
  static String initialsOf(String? name) {
    if (name == null) return '';
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  /// Costruisce l'avatar dai controller: la foto dal profilo, il segno dalla
  /// carta di nascita, il nome dal profilo. Un solo punto per l'aggancio.
  static Widget forUser(BuildContext context, {double size = 40, Key? key}) {
    final profile = context.watch<ProfileController>();
    final birth = context.watch<BirthIdentityController>();
    return UserAvatar(
      key: key,
      photo:
          profile.hasAvatarPhoto ? MemoryImage(profile.avatarPhoto!) : null,
      sign: birth.chart?.sunSign,
      name: profile.hasName ? profile.profile.displayName : null,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorTokens.neutralDeep,
        border: Border.all(
          color: ColorTokens.gold.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: _content(),
    );
  }

  Widget _content() {
    if (photo != null) {
      return Image(
        image: photo!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Se la foto locale sparisce, non un vuoto: si ripiega sul default.
        errorBuilder: (_, __, ___) => _defaultContent(),
      );
    }
    return _defaultContent();
  }

  Widget _defaultContent() {
    // 2. L'emblema del segno solare, se la carta lo conosce.
    if (sign != null) {
      return ZodiacEmblem(
        key: const Key('user_avatar_sign'),
        sign: sign!,
        size: size * 0.82,
        art: ZodiacEmblemArt.emblem,
      );
    }
    // 3. Il sigillo con le iniziali del nome.
    final initials = initialsOf(name);
    if (initials.isNotEmpty) {
      return Text(
        initials,
        key: const Key('user_avatar_initials'),
        style: TypographyTokens.display(size: size * 0.42)
            .copyWith(color: ColorTokens.goldLight),
      );
    }
    // 4. Il sigillo neutro del Cerchio.
    return Icon(
      Icons.brightness_3_rounded,
      key: const Key('user_avatar_neutral'),
      size: size * 0.5,
      color: ColorTokens.goldLight.withValues(alpha: 0.85),
    );
  }
}
