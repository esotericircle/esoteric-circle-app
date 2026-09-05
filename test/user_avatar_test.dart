import 'dart:convert';
import 'dart:typed_data';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/identity/profile_store.dart';
import 'package:esoteric_circle/design_system/components/user_avatar.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il volto dell'utente nel Cerchio: quattro ripieghi in ordine di priorita', e
/// la scelta salvata e riletta in locale.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  Widget host(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  // Un PNG 1x1 trasparente valido: non fa scattare l'errorBuilder, cosi' il
  // ramo foto resta in scena.
  final photo = MemoryImage(base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=='));

  testWidgets('Priorita\' 1: la foto vince su tutto', (tester) async {
    await tester.pumpWidget(host(
      UserAvatar(photo: photo, sign: Zodiac.leo, name: 'Sofia Rossi', size: 48),
    ));
    await tester.pump();
    // C'e' la foto; nessun ripiego.
    final img = tester.widget<Image>(find.byType(Image));
    expect(img.image, photo);
    expect(find.byType(ZodiacEmblem), findsNothing);
    expect(find.byKey(const Key('user_avatar_initials')), findsNothing);
    expect(find.byKey(const Key('user_avatar_neutral')), findsNothing);
  });

  testWidgets('Priorita\' 2: senza foto, l\'emblema del segno', (tester) async {
    await tester.pumpWidget(host(
      const UserAvatar(sign: Zodiac.leo, name: 'Sofia Rossi', size: 48),
    ));
    await tester.pump();
    expect(find.byKey(const Key('user_avatar_sign')), findsOneWidget);
    final emblem = tester.widget<ZodiacEmblem>(find.byType(ZodiacEmblem));
    expect(emblem.sign, Zodiac.leo);
    expect(find.byKey(const Key('user_avatar_initials')), findsNothing);
  });

  testWidgets('Priorita\' 3: senza foto e senza segno, le iniziali',
      (tester) async {
    await tester.pumpWidget(host(
      const UserAvatar(name: 'Sofia Rossi', size: 48),
    ));
    await tester.pump();
    expect(find.byKey(const Key('user_avatar_initials')), findsOneWidget);
    expect(find.text('SR'), findsOneWidget);
    expect(find.byKey(const Key('user_avatar_neutral')), findsNothing);
  });

  testWidgets('Priorita\' 4: senza nulla, il sigillo neutro', (tester) async {
    await tester.pumpWidget(host(const UserAvatar(size: 48)));
    await tester.pump();
    expect(find.byKey(const Key('user_avatar_neutral')), findsOneWidget);
  });

  test('Le iniziali: prima e ultima parola, o la sola prima', () {
    expect(UserAvatar.initialsOf('Sofia Rossi'), 'SR');
    expect(UserAvatar.initialsOf('Sofia'), 'S');
    expect(UserAvatar.initialsOf('  '), '');
    expect(UserAvatar.initialsOf(null), '');
    expect(UserAvatar.initialsOf('anna maria de luca'), 'AL');
  });

  test('Il profilo salva e rilegge la foto dell\'avatar in locale', () async {
    final bytes = Uint8List.fromList(List<int>.generate(64, (i) => i));
    final controller = ProfileController(store: const ProfileStore());

    // All'inizio nessuna foto.
    expect(controller.hasAvatarPhoto, isFalse);

    controller.setAvatarPhoto(bytes);
    expect(controller.hasAvatarPhoto, isTrue);
    // Lascia sedimentare la scrittura best effort.
    await Future<void>.delayed(Duration.zero);

    // Un nuovo controller rilegge la foto dal locale.
    final ripreso = ProfileController(store: const ProfileStore());
    await ripreso.load();
    expect(ripreso.hasAvatarPhoto, isTrue);
    expect(ripreso.avatarPhoto, bytes);

    // Rimozione: torna al default e sparisce dal locale.
    ripreso.clearAvatarPhoto();
    await Future<void>.delayed(Duration.zero);
    final dopoRimozione = ProfileController(store: const ProfileStore());
    await dopoRimozione.load();
    expect(dopoRimozione.hasAvatarPhoto, isFalse);
  });
}
