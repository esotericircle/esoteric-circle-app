import 'package:esoteric_circle/core/rituals/tempi_del_respiro.dart';
import 'package:esoteric_circle/design_system/components/guida_del_respiro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL RESPIRO PARTE QUANDO DECIDE LA PERSONA, DOPO IL CONTO ALLA ROVESCIA.
///
/// Ordine 2163, voce 11. Prima il respiro partiva DA SOLO due secondi dopo
/// "Preparati a respirare". Adesso: sotto la frase c'e' il pulsante "Tocca
/// per cominciare"; al tocco parte il conto da 3 a 0, un numero al secondo,
/// deterministico; solo a conto finito comincia il respiro guidato coi
/// tempi veri del corpus. Niente parte prima del tocco.
///
/// La prova monta la guida, che e' il punto unico della partenza: la
/// schermata del Soffio la monta identica.
void main() {
  Widget host({bool riduci = false}) => MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: riduci),
          child: child!,
        ),
        home: const Scaffold(
          backgroundColor: Color(0xFF0B1020),
          body: Center(
            child: GuidaDelRespiro(
              tempi: TempiDelRespiro(tempi: 4, giri: 3),
              colore: Color(0xFF66BB6A),
            ),
          ),
        ),
      );

  testWidgets('senza tocco il respiro NON parte, neanche dopo molto',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();
    // Venti secondi: dieci volte il vecchio timer automatico.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text(ParoleDelRespiro.preparati), findsOneWidget,
        reason: 'La frase di apertura non c\'e\' piu\': qualcosa e\' '
            'partito da solo.');
    expect(find.text('Inspira'), findsNothing,
        reason: 'Il respiro e\' partito DA SOLO senza il tocco: e\' '
            'esattamente cio\' che Mauro ha revocato.');
    expect(find.byKey(const Key('respiro_tocca')), findsOneWidget,
        reason: 'Manca il pulsante per cominciare.');
  });

  testWidgets('al tocco parte il conto, e il respiro solo dopo il conto',
      (tester) async {
    await tester.pumpWidget(host());
    await tester.pump();
    await tester.tap(find.byKey(const Key('respiro_tocca')));
    await tester.pump();
    expect(find.text('3'), findsOneWidget,
        reason: 'Al tocco il conto non parte da 3.');
    // Un numero al secondo: a ogni passo il numero giusto, mai il respiro.
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('2'), findsOneWidget,
        reason: 'Dopo un secondo il conto non dice 2.');
    expect(find.text('Inspira'), findsNothing,
        reason: 'Il respiro e\' partito durante il conto.');
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('0'), findsOneWidget);
    // Il passo che chiude il conto: da qui, e solo da qui, il respiro.
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Inspira'), findsOneWidget,
        reason: 'A conto finito il respiro non comincia.');
  });

  testWidgets(
      'con Riduci Movimento i numeri non rimpiccioliscono, il conto '
      'resta', (tester) async {
    await tester.pumpWidget(host(riduci: true));
    await tester.pump();
    await tester.tap(find.byKey(const Key('respiro_tocca')));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    // Nessuna scala attorno al numero: si risale dagli antenati del testo e
    // non si trova nessun Transform di scala vivo.
    final numero = tester.element(find.text('3'));
    final scala = numero.findAncestorWidgetOfExactType<Transform>();
    expect(scala, isNull,
        reason: 'Con Riduci Movimento il numero e\' ancora dentro una '
            'scala: deve apparire e sparire senza rimpicciolire.');
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('2'), findsOneWidget,
        reason: 'Con Riduci Movimento il conto si e\' perso.');
  });
}
