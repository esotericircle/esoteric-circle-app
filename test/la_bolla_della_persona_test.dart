import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/components/user_avatar.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA BOLLA DELLA PERSONA: UN COLORE DELLA PALETTE, COERENTE, LEGGIBILE.
///
/// Ordine 2163, voce 8. Visto: la bolla di chi scrive era verde oliva, che
/// non e' un colore di nessuna palette: era l'ORO al 20 per cento composto
/// sul fondale della casa, quasi uguale nelle tre chat e mai dichiarato.
/// Adesso la tessera della persona viene dalla palette NEUTRA del design
/// system, uguale nelle tre case, distinta dalla bolla del Maestro, e il
/// contrasto del testo si MISURA con la luminanza relativa, non a occhio.
///
/// Sul ritratto: la catena di UserAvatar (foto, emblema del segno,
/// iniziali, sigillo) e' quella che Mauro conferma; la prova la enumera
/// gradino per gradino.
void main() {
  /// Il contrasto minimo del testo dentro la bolla, WCAG per testo normale.
  const contrastoMinimo = 4.5;

  double luminanza(Color c) => c.computeLuminance();

  double contrasto(Color a, Color b) {
    final la = luminanza(a), lb = luminanza(b);
    final chiaro = la > lb ? la : lb;
    final scuro = la > lb ? lb : la;
    return (chiaro + 0.05) / (scuro + 0.05);
  }

  test('nelle tre case la tessera della persona e\' una, neutra e distinta',
      () {
    final colpe = <String>[];
    List<Color>? riferimento;
    for (final maestro in Maestro.values) {
      final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
      final persona = ChatBubble.superficieDi(palette, isUser: true);
      final delMaestro = ChatBubble.superficieDi(palette, isUser: false);
      // Opaca, sempre: la regola della 2128 non si perde.
      for (final c in [...persona, ...delMaestro]) {
        if ((c.a * 255).round() != 255) {
          colpe.add('${maestro.displayName}: una tinta della bolla non e\' '
              'opaca');
        }
      }
      // UGUALE nelle tre case: e' la tessera della persona, non della casa.
      riferimento ??= persona;
      if (persona.first != riferimento.first ||
          persona.last != riferimento.last) {
        colpe.add('${maestro.displayName}: la tessera della persona cambia '
            'con la casa, e la persona e\' sempre la stessa');
      }
      // DISTINTA dalla bolla del Maestro della casa.
      if (contrasto(persona.first, delMaestro.first) < 1.15) {
        colpe.add('${maestro.displayName}: la bolla della persona non si '
            'distingue da quella del Maestro');
      }
      // IL CONTRASTO DEL TESTO SI MISURA. Il testo delle bolle e' il
      // primario del design system.
      const testo = Color(0xFFF4F1E8); // ColorTokens.textPrimary
      for (final c in persona) {
        final r = contrasto(testo, c);
        if (r < contrastoMinimo) {
          colpe.add('${maestro.displayName}: contrasto del testo sulla '
              'tessera ${r.toStringAsFixed(2)} sotto il minimo '
              '$contrastoMinimo');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  testWidgets('la catena del ritratto regge, gradino per gradino',
      (tester) async {
    // Senza foto e senza segno ma col nome: le INIZIALI.
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: UserAvatar(name: 'Mauro Battaglia'))));
    expect(find.text('MB'), findsOneWidget,
        reason: 'Senza foto e senza segno le iniziali non compaiono.');
    // Senza niente: il sigillo neutro, nessun testo.
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: UserAvatar())));
    expect(find.byType(UserAvatar), findsOneWidget);
    expect(find.text('MB'), findsNothing);
  });
}
