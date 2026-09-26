import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/riga_del_consiglio.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL CONSIGLIO E' SEMPRE L'ULTIMA RIGA DELLA BOLLA.
///
/// **E' il vincolo che decide dove si infila il seguito.** La bolla e' corpo,
/// poi seguito rivelato, poi stella: un consiglio che finisse in mezzo al
/// testo non sarebbe piu' un consiglio, sarebbe una frase come le altre con
/// un'icona davanti.
void main() {
  const corpo = 'Il tuo Sole in Cancro chiede riparo prima di chiedere '
      'strada. Quello che senti come confusione è un confine che si sposta. '
      'Guarda dove ti fermi a respirare: quella è la direzione.';
  const seguito = 'Sotto la superficie lavora un secondo movimento, più '
      'lento, che dura da mesi senza chiedere il tuo permesso. Non è la '
      'scelta a spaventarti, è quello che la scelta rende definitivo. '
      'Aspetta la prossima luna nuova e rileggi queste stesse parole.';
  const sintesi = 'Non decidere adesso: guarda dove ti fermi.';
  const testo = '$corpo\n\n$seguito\n${ConsiglioFinale.stella} $sintesi';

  Widget host(Widget figlio) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            maestro: Maestro.medora,
            child: Scaffold(body: SingleChildScrollView(child: figlio)),
          ),
        ),
      );

  Future<void> monta(WidgetTester tester, {required bool rivelato}) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(ChatBubble(
      message: ChatMessage(
        role: ChatRole.maestro,
        text: testo,
        at: DateTime(2026, 8, 4, 10),
        approfondita: rivelato,
      ),
      maestro: Maestro.medora,
      durataMassimaDiScrittura: TempiDellAttesa.tettoAlTestoCompleto,
    )));
    await tester.pump();
  }

  testWidgets('La riga in oro c\'e\', e sta SOTTO il corpo', (tester) async {
    await monta(tester, rivelato: false);
    final riga = find.byKey(const Key('consiglio_medora'));
    expect(riga, findsOneWidget,
        reason: 'la risposta non porta nessun consiglio finale');
    final corpoTrovato = find.textContaining('chiede riparo');
    expect(corpoTrovato, findsWidgets);
    expect(tester.getTopLeft(riga).dy,
        greaterThan(tester.getTopLeft(corpoTrovato.first).dy),
        reason: 'il consiglio e\' disegnato sopra il corpo della risposta');
  });

  testWidgets('La sintesi NON compare due volte', (tester) async {
    await monta(tester, rivelato: true);
    // Se il corpo mostrasse anche la riga marcata, la persona leggerebbe la
    // stessa frase due volte, una in bianco e una in oro.
    expect(find.textContaining(sintesi), findsOneWidget,
        reason: 'la sintesi del consiglio compare anche dentro il corpo');
  });

  testWidgets('Col SEGUITO rivelato resta l\'ultima riga', (tester) async {
    await monta(tester, rivelato: true);
    final riga = find.byKey(const Key('consiglio_medora'));
    expect(riga, findsOneWidget);
    // Il seguito e' a schermo, e il consiglio sta sotto anche a lui.
    final seguitoTrovato = find.textContaining('secondo movimento');
    expect(seguitoTrovato, findsWidgets,
        reason: 'col seguito rivelato il seguito deve essere a schermo, '
            'altrimenti questa prova non misura il caso che deve misurare');
    expect(tester.getTopLeft(riga).dy,
        greaterThan(tester.getTopLeft(seguitoTrovato.first).dy),
        reason: 'il consiglio finisce IN MEZZO al testo appena si rivela il '
            'seguito: e\' il difetto che questa prova esiste per impedire');
  });

  testWidgets('La stella c\'e\', e la freccia orizzontale no', (tester) async {
    await monta(tester, rivelato: false);
    final riga = find.byKey(const Key('consiglio_medora'));
    expect(find.descendant(of: riga, matching: find.byIcon(Icons.auto_awesome)),
        findsOneWidget,
        reason: 'la stella non c\'e\'');
    // E IL MARCATORE NON ARRIVA MAI A SCHERMO.
    //
    // Il font del progetto non ha il glifo U+2726, e un carattere che il font
    // non conosce diventa un quadratino vuoto: si e' visto nell'anteprima, non
    // in una prova. La stella la disegna un'icona, che Material porta con se'.
    expect(find.textContaining(ConsiglioFinale.stella), findsNothing,
        reason: 'il marcatore e\' finito a video, e a video e\' una scatola');
    expect(
        find.descendant(of: riga, matching: find.byIcon(Icons.arrow_forward)),
        findsNothing,
        reason: 'e\' tornata la freccia, che prometteva un altrove e non era '
            'nemmeno toccabile');
  });

  testWidgets('La riga in oro sta SOPRA i comandi, non sotto', (tester) async {
    // **NELL'ANTEPRIMA SI E' VISTO PERCHE' CONTA.** Il consiglio finiva dopo
    // "Vai piu\' a fondo", e la freccia in giu\' promette "qui sotto c\'e\' altro
    // testo": sotto ci trovava il consiglio, quindi sembrava indicare lui.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(ChatBubble(
      message: ChatMessage(
        role: ChatRole.maestro,
        text: testo,
        at: DateTime(2026, 8, 4, 10),
      ),
      maestro: Maestro.medora,
      durataMassimaDiScrittura: TempiDellAttesa.tettoAlTestoCompleto,
      onApprofondisci: () {},
    )));
    await tester.pump();
    final riga = find.byKey(const Key('consiglio_medora'));
    final freccia = find.byKey(const Key('chat_approfondisci'));
    expect(riga, findsOneWidget);
    expect(freccia, findsOneWidget);
    expect(tester.getTopLeft(riga).dy, lessThan(tester.getTopLeft(freccia).dy),
        reason: 'la freccia sta sopra il consiglio, quindi punta a lui: i '
            'comandi non sono testo del Maestro, e vanno dopo tutto cio\' che '
            'ha detto');
  });

  testWidgets('Senza consiglio la riga non si disegna vuota', (tester) async {
    // Una stella con niente accanto sarebbe la decorazione da cui questa riga
    // e' nata per liberarci.
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(360 * 3, 797 * 3);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(host(RigaDelConsiglio(
      maestro: Maestro.medora,
      testo: '   ',
      quando: DateTime(2026, 8, 4),
    )));
    await tester.pump();
    expect(find.byIcon(Icons.auto_awesome), findsNothing);
  });
}
