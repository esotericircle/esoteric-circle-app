import 'package:esoteric_circle/core/rituals/tempi_del_respiro.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL PULSANTE DEL SOFFIO NON LO TAGLIA NESSUNO.
///
/// Ordine 2164, voce 8. Visto da Mauro: sotto "Preparati a respirare" il
/// pulsante "Tocca per cominciare" era tagliato a meta' dalla scheda
/// dell'intenzione del giorno che gli saliva sopra, quindi non si poteva
/// nemmeno premere per intero.
///
/// La misura NON conta widget: i widget ci sono tutti anche quando si
/// coprono. Si misurano i rettangoli della resa vera, e poi si TOCCA il
/// centro del pulsante per vedere se il gesto arriva davvero.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> soffio(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // **LE BARRE DI SISTEMA CI VOGLIONO, e la grandezza e' cambiata per
    // questo.** Montata su uno schermo nudo la scena aveva spazio in
    // abbondanza e le tre prove restavano verdi anche PRIMA della
    // correzione: il pulsante finiva a 419,7 e la scheda cominciava esatta a
    // 467,7, senza toccarsi. Sul Realme di Mauro in cima c'e' la barra di
    // stato e in fondo quella di navigazione, cioe' una quarantina di punti
    // in meno, ed e' li' che il pulsante entrava sotto la scheda. Senza
    // questi inserti la prova misurerebbe un telefono che non esiste.
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 797),
          padding: EdgeInsets.only(top: 40, bottom: 24),
        ),
        child: BreathDestinyScreen(now: DateTime(2026, 8, 7, 10, 30)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // Il gesto col ripiego tattile, sempre presente: il respiro compare a
    // dono rivelato.
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('il pulsante e\' intero e nessun altro widget lo copre',
      (tester) async {
    await soffio(tester);
    final pulsante = find.byKey(const Key('respiro_tocca'));
    if (pulsante.evaluate().isEmpty) {
      markTestSkipped('Il rito di questo giorno non porta un respiro '
          'contato: non c\'e\' nessun pulsante da misurare.');
      return;
    }
    final rPulsante = tester.getRect(pulsante);

    // LA SCHEDA DELL'INTENZIONE: e' cio' che saliva sopra il pulsante.
    final scheda = find.byKey(const Key('ritual_content'));
    expect(scheda, findsOneWidget,
        reason: 'La scheda dell\'intenzione non c\'e\': senza di lei questa '
            'prova non misura il difetto che deve misurare.');
    final rScheda = tester.getRect(scheda);
    final sovrapposti = rPulsante.overlaps(rScheda);
    final quantoCopre = rPulsante.bottom - rScheda.top;
    // ignore: avoid_print
    print('SOFFIO: pulsante ${rPulsante.top.toStringAsFixed(1)}-'
        '${rPulsante.bottom.toStringAsFixed(1)}, scheda da '
        '${rScheda.top.toStringAsFixed(1)}, coperti '
        '${sovrapposti ? quantoCopre.toStringAsFixed(1) : "0.0"} punti');
    expect(sovrapposti, isFalse,
        reason: 'La scheda dell\'intenzione sale sopra il pulsante e ne '
            'copre ${quantoCopre.toStringAsFixed(1)} punti: e\' il visto '
            'di Mauro, il pulsante tagliato a meta\'.');

    // E STA DENTRO LO SCHERMO, tutto: un pulsante mezzo fuori e' tagliato
    // uguale, solo da un altro bordo.
    expect(rPulsante.bottom,
        lessThanOrEqualTo(tester.view.physicalSize.height + 0.1),
        reason: 'Il pulsante esce dal fondo dello schermo.');
    expect(rPulsante.top, greaterThanOrEqualTo(0));
  });

  testWidgets('il tocco al centro del pulsante fa partire il conto',
      (tester) async {
    await soffio(tester);
    final pulsante = find.byKey(const Key('respiro_tocca'));
    if (pulsante.evaluate().isEmpty) {
      markTestSkipped('Il rito di questo giorno non porta un respiro '
          'contato.');
      return;
    }
    // SI TOCCA IL CENTRO VERO, non il widget per chiave: toccare per chiave
    // arriverebbe anche a un pulsante coperto, e proverebbe il contrario di
    // cio' che serve. Al centro ci arriva chi ha il dito.
    await tester.tapAt(tester.getCenter(pulsante));
    await tester.pump();
    expect(find.text('3'), findsOneWidget,
        reason: 'Il tocco al centro del pulsante non fa partire il conto: '
            'qualcosa sta davanti e se lo prende.');
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('2'), findsOneWidget);
    // Si lascia finire il conto, cosi' non restano timer pendenti.
    await tester.pump(ParoleDelRespiro.durataDelConto);
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('dietro il titolo non c\'e\' una macchia che tocca il mandala',
      (tester) async {
    await soffio(tester);
    final pulsante = find.byKey(const Key('respiro_tocca'));
    if (pulsante.evaluate().isEmpty) {
      markTestSkipped('Il rito di questo giorno non porta un respiro '
          'contato.');
      return;
    }
    // IL VELO DELLA PAROLA non deve arrivare sulla figura del respiro: sullo
    // scatto di Mauro entrava sopra il mandala. Si misura sui rettangoli
    // veri, non a occhio.
    final figura = find.byKey(const Key('respiro_figura'));
    expect(figura, findsOneWidget);
    final rFigura = tester.getRect(figura);
    final velo = find.byKey(const Key('respiro_velo'));
    expect(velo, findsOneWidget,
        reason: 'Il velo della parola non ha una chiave: non si misura.');
    final rVelo = tester.getRect(velo);
    final invasione = rFigura.bottom - rVelo.top;
    // ignore: avoid_print
    print('SOFFIO: figura fino a ${rFigura.bottom.toStringAsFixed(1)}, velo '
        'da ${rVelo.top.toStringAsFixed(1)}, invasione '
        '${invasione.toStringAsFixed(1)} punti');
    expect(rVelo.top, greaterThanOrEqualTo(rFigura.bottom - 0.5),
        reason: 'Il velo dietro il titolo entra ${invasione.toStringAsFixed(1)} '
            'punti sopra il mandala.');
  });
}
