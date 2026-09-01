import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// L'avatar accanto alla bolla del Maestro e' un ritratto contenuto nel tondo:
/// l'icona lineare di riferimento non e' piu' un fondale fisso, resta solo come
/// ripiego su errore. La bolla dell'utente, a destra, mostra il suo avatar.
void main() {
  Widget host(Widget child, Maestro maestro) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController()..selectMaestro(maestro)),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: Scaffold(body: child),
          ),
        ),
      );

  testWidgets('La bolla del Maestro non mostra l\'icona di riferimento a vista',
      (tester) async {
    const message = ChatMessage(
      role: ChatRole.maestro,
      text: 'Le stelle ti ascoltano.',
    );
    await tester.pumpWidget(host(
      const ChatBubble(message: message, maestro: Maestro.medora),
      Maestro.medora,
    ));
    await tester.pump();

    // L'avatar disegna l'asset del Maestro, e l'icona lineare non affiora: sta
    // solo nell'errorBuilder, che qui non scatta.
    final immagini = tester.widgetList<Image>(find.byType(Image));
    expect(
      immagini.any((i) => i.image == AssetImage(Maestro.medora.avatarAsset)),
      isTrue,
    );
    expect(find.byIcon(Maestro.medora.icon), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('La bolla dell\'utente mostra il suo avatar sul lato destro',
      (tester) async {
    const message = ChatMessage(
      role: ChatRole.user,
      text: 'Devo cambiare lavoro?',
    );
    await tester.pumpWidget(host(
      const ChatBubble(message: message, maestro: Maestro.medora),
      Maestro.medora,
    ));
    await tester.pump();

    // C'e' l'avatar dell'utente: senza foto ne carta, il sigillo con le iniziali
    // del nome della Demo (Sofia).
    expect(find.byKey(const Key('chat_user_avatar')), findsOneWidget);
    expect(find.byKey(const Key('user_avatar_initials')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
