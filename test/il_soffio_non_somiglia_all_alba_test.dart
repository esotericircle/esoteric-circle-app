import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/design_system/theme/abito_del_responso.dart';
import 'package:esoteric_circle/features/rituals/ritual_gift_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL SOFFIO NON SOMIGLIA ALL ALBA. Ordine BB voce 09.
///
/// **Il fatto del fondatore**: il responso del Soffio del Destino somiglia a
/// quello del Rito dell Alba.
///
/// **Aveva ragione, e il difetto era piu largo della voce.** I Doni sono
/// CINQUE: alba, soffio, oracolo, rune, notte. Portavano tutti la stessa
/// identica scheda, dallo stesso file, con lo stesso vetro crema e lo stesso
/// inchiostro scuro. Non si somigliavano il Soffio e l Alba: si somigliavano
/// tutti e cinque, e curare la sola coppia guardata sarebbe stato un tampone.
///
/// **UN TENTATIVO E STATO FATTO E BUTTATO.** L idea era dare a ogni Dono una
/// tinta diversa dello stesso vetro chiaro. Non funziona, e il conto lo dice
/// senza appello: gli inchiostri del regime chiaro discendono dal fondo
/// peggiore misurato, quindi nessuna tinta poteva scurirsi molto, e cinque
/// tinte chiare gravitano tutte verso il bianco. La coppia piu vicina distava
/// **7 punti su 255**, e allentando il vincolo fino a perdere il 12 per cento
/// di luce si arrivava a 21: un cambiamento che nessuno nota, pagato con testo
/// meno leggibile ovunque.
///
/// **La risposta era gia scritta nel codice.** Il regime chiaro esiste perche
/// l alba e l unico momento in cui il buio finisce: una ragione che nessun
/// altro rito ha. Il Soffio e un rito della sera, l app e notturna, e la
/// scheda chiara era arrivata agli altri quattro per eredita, non per scelta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  double canale(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  double luce(Color c) =>
      0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);
  double contrasto(Color a, Color b) {
    final x = luce(a), y = luce(b);
    return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
  }

  /// La scheda montata sola, sopra un fondo dichiarato.
  Future<void> monta(WidgetTester tester, DailyElement dono,
      {Color sotto = Colors.white}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: sotto,
        body: RepaintBoundary(
          key: const Key('la_scheda'),
          child: Center(
            child: RitualGiftCard(
              gift: DawnGift.forMaestro(DateTime(2026, 8, 6), Maestro.medora),
              dono: dono,
              giorno: DateTime(2026, 8, 6),
              streak: 3,
              onShare: () {},
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  /// I pixel veri della scheda, come li vede chi guarda.
  Future<List<int>> pixelDellaScheda(WidgetTester tester) async {
    final confine = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('la_scheda')));
    final immagine = await confine.toImage();
    final dati =
        await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
    return dati!.buffer.asUint8List();
  }

  test('BB.09: l Alba porta il giorno, gli altri quattro la notte', () {
    final diGiorno = <String>[];
    final diNotte = <String>[];
    for (final d in DailyElement.values) {
      (AbitoDelResponso.di(d).diGiorno ? diGiorno : diNotte).add(d.name);
    }
    // ignore: avoid_print
    print('ORDINE BB VOCE 09: di giorno $diGiorno, di notte $diNotte');
    expect(diGiorno, ['dawn'],
        reason: 'il regime chiaro esiste per la sola ragione che l alba e l '
            'unico momento in cui il buio finisce: nessun altro rito ha quella '
            'ragione, e chi ce l ha non deve perderla');
    expect(diNotte, hasLength(4));
  });

  test('BB.09: i due abiti sono opposti, non due sfumature', () {
    final giorno = AbitoDelResponso.di(DailyElement.dawn);
    final notte = AbitoDelResponso.di(DailyElement.breath);
    final quanto = contrasto(giorno.velatura, notte.velatura);
    // ignore: avoid_print
    print('ORDINE BB VOCE 09: fra il vetro del giorno e quello della notte '
        'corrono ${quanto.toStringAsFixed(1)} a 1');
    // **La soglia e quella della lettura, e non e un caso**: due superfici che
    // stanno fra loro come un testo sta al suo fondo sono distinguibili da
    // chiunque, in qualunque luce. Il tentativo buttato arrivava a 1,1 a 1.
    expect(quanto, greaterThan(4.5),
        reason: 'i due abiti sono due sfumature dello stesso vetro: e da qui '
            'che nasce la somiglianza');
  });

  test('BB.09: e l abito di notte si legge, che era il rischio vero', () {
    // **LA CONTROPROVA CHE VALE PIU DELLA PROVA.** Distinguere i riti era
    // facile: bastava cambiare colore. Il pericolo era distinguerli
    // rendendone uno illeggibile, e la lezione dell ordine P voce 12 dice
    // esattamente questo: un regime che non sa su cosa poggia non e
    // governato, e sperato.
    final notte = AbitoDelResponso.di(DailyElement.breath);
    final forte = contrasto(notte.inchiostro, notte.superficiePeggiore);
    final muto = contrasto(notte.inchiostroMuto, notte.superficiePeggiore);
    final accento =
        contrasto(notte.accentoDi(Maestro.medora), notte.superficiePeggiore);
    // ignore: avoid_print
    print('ORDINE BB VOCE 09: sull abito di notte l inchiostro forte misura '
        '${forte.toStringAsFixed(2)} a 1, quello muto '
        '${muto.toStringAsFixed(2)}, l accento ${accento.toStringAsFixed(2)}');
    expect(forte, greaterThanOrEqualTo(4.5),
        reason: 'il testo dell abito di notte non arriva alla soglia di '
            'lettura');
    expect(muto, greaterThanOrEqualTo(4.5),
        reason: 'le note dell abito di notte non arrivano alla soglia');
    expect(accento, greaterThanOrEqualTo(4.5),
        reason: 'l accento del Maestro non si legge sull abito di notte');
  });

  testWidgets('BB.09: e il fondo dichiarato di notte e VERO, misurato a video',
      (tester) async {
    // **IL DIFETTO CHE L ORDINE P HA DOVUTO SCOPRIRE A VIDEO, e che qui non si
    // ripete.** Il vetro chiaro dichiarava 0xFBF4E2 ma stava al 78 per cento
    // sopra una scena di sole: cio che una lettera trovava sotto di se non era
    // il vetro, era la composizione, e il contrasto tornava sulla carta e non
    // a schermo. Quindi l abito di notte non si crede sulla parola.
    //
    // Si monta la scheda **sopra il bianco**, che per un testo chiaro e il
    // fondo peggiore possibile, e si guarda il colore piu frequente dentro di
    // lei: quello e il fondo vero.
    late Color fondoVero;
    await monta(tester, DailyElement.breath);
    await tester.runAsync(() async {
      final px = await pixelDellaScheda(tester);
      final conte = <int, int>{};
      for (var i = 0; i < px.length; i += 4) {
        final chiave = (px[i] << 16) | (px[i + 1] << 8) | px[i + 2];
        conte[chiave] = (conte[chiave] ?? 0) + 1;
      }
      var vincitore = 0, quante = 0;
      conte.forEach((c, n) {
        if (n > quante) {
          quante = n;
          vincitore = c;
        }
      });
      fondoVero = Color(0xFF000000 | vincitore);
    });
    final dichiarato =
        AbitoDelResponso.di(DailyElement.breath).superficiePeggiore;
    // ignore: avoid_print
    print('ORDINE BB VOCE 09: il fondo misurato a video e '
        '${fondoVero.toARGB32().toRadixString(16)}, quello dichiarato '
        '${dichiarato.toARGB32().toRadixString(16)}');
    // **Il dichiarato deve essere il PEGGIORE, cioe non piu scuro del vero.**
    // Dove il fondo reso e piu scuro, un testo chiaro si legge meglio: quindi
    // il dichiarato puo essere piu chiaro del misurato, mai il contrario.
    expect(luce(dichiarato), greaterThanOrEqualTo(luce(fondoVero) - 0.001),
        reason: 'il fondo che il testo trova davvero e piu chiaro di quello '
            'dichiarato: gli inchiostri sono stati scelti su un fondo che non '
            'esiste, ed e lo stesso difetto dell ordine P voce 12');
  });

  testWidgets('BB.09: a video le due schede non si somigliano piu',
      (tester) async {
    // **QUESTA E LA PROVA CHE IL FONDATORE PUO CONTROLLARE CON GLI OCCHI.**
    // Tutto il resto sono numeri sui token: qui si dipingono le due schede e
    // si conta quanti punti su cento cambiano.
    late List<int> alba;
    await monta(tester, DailyElement.dawn);
    await tester.runAsync(() async => alba = await pixelDellaScheda(tester));

    // **LA CONTROPROVA VIENE PRIMA**, perche una misura differenziale che non
    // sa dare zero non sa dare nemmeno il resto: la stessa scheda ridipinta
    // deve cambiare zero punti.
    late List<int> ancoraAlba;
    await monta(tester, DailyElement.dawn);
    await tester
        .runAsync(() async => ancoraAlba = await pixelDellaScheda(tester));
    var uguali = 0;
    for (var i = 0; i < math.min(alba.length, ancoraAlba.length); i += 4) {
      if (alba[i] != ancoraAlba[i]) uguali++;
    }
    // ignore: avoid_print
    print('ORDINE BB VOCE 09: controprova, la stessa scheda ridipinta cambia '
        '$uguali punti');
    expect(uguali, 0,
        reason: 'la misura si muove da sola: qualunque numero desse dopo non '
            'vorrebbe dire niente');

    late List<int> soffio;
    await monta(tester, DailyElement.breath);
    await tester.runAsync(() async => soffio = await pixelDellaScheda(tester));
    expect(alba, hasLength(soffio.length),
        reason: 'le due schede non hanno nemmeno la stessa misura: il '
            'confronto punto per punto non direbbe niente');

    var cambiati = 0, totale = 0;
    for (var i = 0; i < alba.length; i += 4) {
      totale++;
      final scarto = (alba[i] - soffio[i]).abs() +
          (alba[i + 1] - soffio[i + 1]).abs() +
          (alba[i + 2] - soffio[i + 2]).abs();
      if (scarto > 24) cambiati++;
    }
    final quota = cambiati / totale;
    // ignore: avoid_print
    print('ORDINE BB VOCE 09: fra l Alba e il Soffio cambiano $cambiati punti '
        'su $totale, cioe il ${(quota * 100).toStringAsFixed(1)} per cento');
    expect(quota, greaterThan(0.6),
        reason: 'a video le due schede sono ancora la stessa scheda, ed e '
            'esattamente il fatto del fondatore');
  });

  test('BB.09: e la scheda non tiene piu colori suoi per tutti', () {
    // **DOVE STAVA IL DIFETTO**: costanti private dentro la scheda, lette
    // anche dai sottocomponenti, uguali per cinque riti. Se tornano, questa
    // cade.
    final sorgente =
        File('lib/features/rituals/ritual_gift_card.dart').readAsStringSync();
    expect(sorgente, contains('AbitoDelResponso.di(widget.dono)'),
        reason: 'la scheda non chiede piu l abito al Dono che sta mostrando');
    for (final morta in const [
      'const Color _dayGlass =',
      'const Color _dayInk =',
      'const Color _dayInset =',
    ]) {
      expect(sorgente, isNot(contains(morta)),
          reason: 'e tornata la costante "$morta": cinque riti torneranno a '
              'somigliarsi');
    }
  });
}
