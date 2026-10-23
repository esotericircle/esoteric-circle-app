// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/brand/brand.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/letture_dell_alba_dati.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import 'package:esoteric_circle/features/rituals/arcano_dell_alba_share_card.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/core/sensi/palette_sensoriale.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/archivio_dell_alba.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/arcano_dell_alba_screen.dart';
import 'package:esoteric_circle/features/rituals/tavolo_dei_ventidue.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'alzare_il_sole.dart';

/// **L'ARCANO DELL'ALBA SI GIRA.** Ordine DT voci 02, 03 e 04, 17 settembre
/// 2026.
///
/// Si misura la schermata come la usa la persona: **ventidue carte coperte
/// tutte uguali**, ordine DU voce 02, coi soli due gesti del mazzo che il
/// fondatore ha lasciato, Mischia e Taglia; il verso deciso dal sistema e non
/// dalla carta toccata; il limite delle stese intatto; i due gesti del
/// cammino; il dono che, riaperto, e' quello di prima; e il dorso del mazzo che
/// al mezzo giro resta se stesso, cosi' che una carta coperta non dica niente.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final adesso = DateTime(2026, 9, 18, 7, 40);

  /// I sensori del telefono non esistono al banco: senza questo, la scena
  /// che entra nel cammino solleva una MissingPluginException e la prova
  /// cade per una ragione che non c'entra con cio' che misura.
  void zittisciISensori() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<({DiarioDelCammino diario, QuestionAllowance conto})> monta(
      WidgetTester tester,
      {Random? caso,
      bool suono = false,
      bool conIlSole = true}) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: () => adesso);
    final conto = QuestionAllowance();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider<QuestionAllowance>.value(value: conto),
        // **L'interruttore unico del suono.** Senza, la porta del Cerchio
        // tace per prudenza, e una prova sul suono misurerebbe la propria
        // mancanza invece della schermata.
        ChangeNotifierProvider<SettingsController>.value(
            value: SettingsController(effettiSonori: suono)),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ArcanoDellAlbaScreen(now: adesso, caso: caso ?? Random(21)),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    // **L'ARCANO SI APRE ALZANDO IL SOLE**, ordine EL: le carte arrivano
    // dopo il gesto. Riaprendo il dono nello stesso giorno il gesto non c'e'.
    if (conIlSole) await alzaIlSole(tester);
    return (diario: diario, conto: conto);
  }

  /// Tutti i dorsi montati, qualunque sia il loro indice.
  final dorsi = find.byWidgetPredicate(
      (w) => w.key.toString().contains('arcano_alba_dorso_'));

  /// L'opacita' con cui una carta e' disegnata: le non scelte si spengono
  /// invece di sparire, e senza guardare l'opacita' non si vedrebbe.
  double opacitaDi(WidgetTester tester, Finder chi) {
    final velo = find
        .ancestor(of: chi, matching: find.byType(Opacity))
        .evaluate()
        .map((e) => (e.widget as Opacity).opacity);
    return velo.isEmpty ? 1 : velo.reduce((a, b) => a * b);
  }

  Future<void> gira(WidgetTester tester, int quale) async {
    // L'ingresso a spirale dura un secondo e mezzo: si tocca dopo, come fa
    // la persona, se no il tocco cade su una carta che sta ancora volando.
    for (var i = 0; i < 18; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.byKey(Key('arcano_alba_carta_$quale')));
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ArchivioDellAlba.dimenticaLaMemoria();
    zittisciISensori();
  });

  testWidgets(
      'UN GESTO SOLO: carte coperte tutte uguali e nessun altro comando',
      (tester) async {
    await monta(tester);
    expect(dorsi, findsNWidgets(ArcanoDellAlbaScreen.dorsi));
    expect(ArcanoDellAlbaScreen.dorsi, 22,
        reason: 'i maggiori sono ventidue e si vedono tutti');
    final immagini = tester.widgetList<Image>(dorsi).toList();
    expect(immagini.map((i) => (i.image as AssetImage).assetName).toSet(),
        {TarotDeck.dorsoFull},
        reason: 'le carte coperte non hanno lo stesso dorso');
    final misure = [
      for (var i = 0; i < ArcanoDellAlbaScreen.dorsi; i++)
        tester.getSize(find.byKey(Key('arcano_alba_carta_$i'))),
    ];
    expect(misure.toSet(), hasLength(1),
        reason: 'le carte coperte non hanno la stessa misura: $misure');
    // **I SOLI DUE GESTI CHE IL FONDATORE HA LASCIATO**: Mischia e Taglia.
    // Niente cielo, transiti, arti, cuore, e nessun terzo pulsante entrato
    // per abitudine.
    expect(find.byKey(const Key('arcano_alba_mischia')), findsOneWidget);
    expect(find.byKey(const Key('arcano_alba_taglia')), findsOneWidget);
    expect(find.byType(TextButton), findsNWidgets(2),
        reason: 'oltre a Mischia e Taglia c\'e\' un altro pulsante');
    for (final tipo in [
      ElevatedButton,
      OutlinedButton,
      FilledButton,
      PopupMenuButton,
    ]) {
      expect(find.byType(tipo), findsNothing, reason: 'c\'e\' un $tipo');
    }
    expect(find.byType(IconButton), findsOneWidget,
        reason: 'oltre al ritorno c\'e\' un altro comando');
    expect(find.byType(TarotCardArt), findsNothing,
        reason: 'prima del gesto la faccia di una carta e\' gia\' montata');
  });

  testWidgets(
      'girata la carta: la faccia col suo verso e i tre movimenti, e '
      'le altre carte si spengono', (tester) async {
    await monta(tester);
    await gira(tester, 1);
    final oggi = await tester.runAsync(() => ArchivioDellAlba.diOggi(adesso));
    expect(oggi, isNotNull);
    final faccia = tester.widget<TarotCardArt>(find.byType(TarotCardArt));
    expect(faccia.card.name, oggi!.carta.name);
    expect(faccia.reversed, oggi.stato.rovescio,
        reason: 'la faccia non porta il verso estratto');
    // **Le altre non spariscono, si spengono**: restano montate perche' il
    // tavolo e' uno solo dall'inizio alla fine, e a rivelazione compiuta sono
    // a zero. Senza guardare l'opacita' questa riga non vedrebbe niente.
    for (final i in [0, 7, 21]) {
      if (i == 1) continue;
      expect(opacitaDi(tester, find.byKey(Key('arcano_alba_dorso_$i'))),
          lessThan(0.05),
          reason: 'il dorso $i e\' ancora acceso dietro la carta girata');
    }
    expect(find.text(oggi.primo), findsOneWidget);
    expect(find.text(oggi.terzo), findsOneWidget);
    expect(find.byKey(const Key('arcano_alba_dono')), findsOneWidget);
    expect(find.byKey(const Key('arcano_alba_parola')),
        oggi.parola == null ? findsNothing : findsOneWidget);
    print('ORDINE DT: ${oggi.primo} | ${oggi.secondo} | ${oggi.terzo}');
  });

  testWidgets(
      'IL VERSO NON LO DECIDE LA CARTA TOCCATA: stesso caso, carte '
      'diverse, stesso stato', (tester) async {
    final stati = <int>{};
    for (final quale in [0, 2]) {
      SharedPreferences.setMockInitialValues({});
      ArchivioDellAlba.dimenticaLaMemoria();
      // Albero vuoto fra i due giri, se no la schermata conserva lo stato.
      await tester.pumpWidget(const SizedBox());
      await monta(tester, caso: Random(77));
      await gira(tester, quale);
      final oggi = await tester.runAsync(() => ArchivioDellAlba.diOggi(adesso));
      stati.add(oggi!.stato.id);
    }
    expect(stati, hasLength(1),
        reason:
            'toccare un\'altra carta coperta ha cambiato lo stato estratto');
  });

  testWidgets('nella prima meta\' del giro si vede solo il dorso',
      (tester) async {
    await monta(tester);
    for (var i = 0; i < 18; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.byKey(const Key('arcano_alba_carta_0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(TarotCardArt), findsNothing,
        reason: 'la faccia, e con lei il verso, compare prima della meta\' del '
            'giro');
  });

  testWidgets(
      'IL LIMITE DELLE STESE NON SI TOCCA, e nel cammino entrano i due '
      'gesti', (tester) async {
    final montati = await monta(tester);
    final prima = montati.conto.steseRimaste(Tier.free);
    await gira(tester, 0);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    // **La vibrazione del giro dura oltre la fine della prova.** Lo schema
    // della rivelazione sono due colpi separati da 110 millesimi, e l'estrazione
    // che lo precede si compie solo dentro l'attesa vera qui sopra: senza
    // questo respiro il banco trova un temporizzatore acceso e boccia una
    // prova che parla d'altro.
    await tester.pump(const Duration(milliseconds: 300));
    expect(montati.conto.steseRimaste(Tier.free), prima,
        reason: 'l\'Arcano dell\'Alba ha consumato una stesa');
    expect(montati.diario.haFatto('alba'), isTrue,
        reason: 'il gesto alba non e\' entrato nel cammino');
    expect(montati.diario.haFatto('oracolo'), isTrue,
        reason: 'il gesto oracolo non e\' entrato nel cammino');
  });

  testWidgets(
      'riaperta, la carta e\' quella di prima e non si sceglie due volte',
      (tester) async {
    await monta(tester);
    await gira(tester, 2);
    final prima =
        (await tester.runAsync(() => ArchivioDellAlba.diOggi(adesso)))!;
    await tester.pumpWidget(const SizedBox());
    await monta(tester, caso: Random(999), conIlSole: false);
    await tester.pump(const Duration(milliseconds: 100));
    expect(dorsi, findsNothing,
        reason: 'riaprendo il dono si torna alle carte coperte');
    expect(find.text(prima.primo), findsOneWidget);
  });

  test('IL DORSO AL MEZZO GIRO RESTA SE STESSO', () async {
    final byte = await File(TarotDeck.dorsoFull).readAsBytes();
    final codice = await ui.instantiateImageCodec(byte);
    final immagine = (await codice.getNextFrame()).image;
    final dati = (await immagine.toByteData())!;
    final l = immagine.width, a = immagine.height;
    var somma = 0, oltre = 0, punti = 0;
    for (var y = 0; y < a; y += 3) {
      for (var x = 0; x < l; x += 3) {
        final i = (y * l + x) * 4;
        final j = ((a - 1 - y) * l + (l - 1 - x)) * 4;
        var scarto = 0;
        for (var c = 0; c < 3; c++) {
          scarto =
              max(scarto, (dati.getUint8(i + c) - dati.getUint8(j + c)).abs());
        }
        somma += scarto;
        if (scarto > 48) oltre++;
        punti++;
      }
    }
    final medio = somma / punti;
    print('ORDINE DT: il dorso ruotato di mezzo giro scarta in media '
        '${medio.toStringAsFixed(2)} su 255, e oltre 48 in $oltre punti su '
        '$punti');
    expect(medio, lessThan(8),
        reason: 'il dorso non e\' simmetrico: una carta coperta dice il verso');
    expect(oltre / punti, lessThan(0.01));
  });

  testWidgets('LA CARTA GIRATA PORTA I SUOI CARTIGLI, col numerale e col nome',
      (tester) async {
    // **Richiesta del fondatore del 17 settembre 2026**, guardando la 2266
    // sul telefono: i cartigli dell'Arcano dell'Alba erano vuoti, perche'
    // la faccia li spegneva. Una carta coi cartigli vuoti sembra incompiuta.
    await monta(tester);
    await gira(tester, 2);
    final oggi = await tester.runAsync(() => ArchivioDellAlba.diOggi(adesso));
    final faccia = tester.widget<TarotCardArt>(find.byType(TarotCardArt));
    expect(faccia.showCartigli, isTrue,
        reason: 'la faccia dell\'Arcano dell\'Alba spegne i cartigli');
    final numero = find.descendant(
        of: find.byType(TarotCardArt), matching: find.byType(CartiglioNumero));
    final nome = find.descendant(
        of: find.byType(TarotCardArt), matching: find.byType(CartiglioNome));
    expect(numero, findsOneWidget,
        reason: 'il cartiglio del numerale e\' vuoto');
    expect(nome, findsOneWidget, reason: 'il cartiglio del nome e\' vuoto');
    expect(tester.widget<CartiglioNome>(nome).nome, oggi!.carta.name);
    // **E SI VEDONO**: il testo e' dipinto dentro la carta, non solo montato.
    final scritti = [
      for (final t in tester.widgetList<Text>(find.descendant(
          of: find.byType(TarotCardArt), matching: find.byType(Text))))
        (t.data ?? '', t.style?.fontSize ?? 0),
    ];
    print('ORDINE DT, i cartigli di ${oggi.carta.name}: $scritti');
    expect(scritti.map((s) => s.$1).join(' '),
        contains(oggi.carta.numeral.toUpperCase()));
    expect(scritti.every((s) => s.$2 > 0), isTrue,
        reason: 'un cartiglio ha il testo a misura zero: $scritti');
  });

  testWidgets('IL TITOLO D\'ORO STA SOPRA L\'INVITO, e non lo sostituisce',
      (tester) async {
    // **Richiesta del fondatore del 17 settembre 2026**: *"il testo in alto
    // che invita a scegliere la carta e' un po' anonimo, serve un titolo in
    // giallo oro evocativo... e sotto il testo che c'e' gia'"*. Due cose da
    // misurare: che il titolo sia d'oro, e che l'invito sia ancora li' sotto.
    await monta(tester);
    final richiamo = find.byKey(const Key('arcano_alba_richiamo'));
    expect(richiamo, findsOneWidget,
        reason: 'il titolo della scena non c\'e\'');
    final testo = tester.widget<Text>(richiamo);
    final oro = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora)).gold;
    expect(testo.style?.color, oro,
        reason: 'il titolo non e\' dell\'oro del Cerchio: '
            '${testo.style?.color}');
    expect(testo.style!.fontSize!, greaterThanOrEqualTo(24),
        reason: 'il titolo e\' grande come il testo che introduce');
    final invito = find.byKey(const Key('arcano_alba_invito'));
    expect(invito, findsOneWidget,
        reason: 'il titolo ha preso il posto dell\'invito invece di stargli '
            'sopra');
    expect(
        tester.getTopLeft(richiamo).dy, lessThan(tester.getTopLeft(invito).dy),
        reason: 'il titolo non sta sopra l\'invito');
  });

  testWidgets('LA CARTA CHE SI GIRA SUONA, dalla porta unica del Cerchio',
      (tester) async {
    // Richiesta del fondatore: *"usa anche il suono della carta che si gira
    // che hai usato nella stesa dei tarocchi"*. **Si arma la spia sulla porta
    // del Cerchio**, come fa la guardia della Stesa: e' la sola forma di
    // prova che vede il suono uscire davvero, e non la mappa che lo sceglie.
    final sentiti = <SuonoDelCerchio>[];
    PaletteSensoriale.spia = sentiti.add;
    addTearDown(() => PaletteSensoriale.spia = null);
    await monta(tester, suono: true);
    await gira(tester, 4);
    expect(sentiti, contains(SuonoDelCerchio.carta),
        reason: 'girando la carta dell\'Alba non e\' uscito nessun suono '
            'della carta: sentiti $sentiti');
  });

  testWidgets('IL TITOLO SI SPEGNE MENTRE LA CARTA VOLA', (tester) async {
    // **Difetto visto sull'anteprima, non dedotto.** L'opacita' del titolo e
    // dell'invito si calcolava dentro la costruzione della schermata, che non
    // ascolta il comando della rivelazione: restavano accesi per tutto il volo
    // e sparivano di colpo alla fine. La grandezza misurata e' l'opacita' a
    // meta' volo, non la presenza del testo.
    await monta(tester);
    final titolo = find.byKey(const Key('arcano_alba_richiamo'));
    expect(opacitaDi(tester, titolo), greaterThan(0.9),
        reason: 'il titolo parte gia spento');
    for (var i = 0; i < 18; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.byKey(const Key('arcano_alba_carta_2')));
    // L'estrazione si compie in un'attesa vera: senza, il volo non parte.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(opacitaDi(tester, titolo), lessThan(0.5),
        reason: 'a meta\' volo il titolo e\' ancora acceso: la schermata non '
            'ascolta il comando della rivelazione');
    // E si lascia finire tutto, se no restano temporizzatori accesi.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  });

  testWidgets('LA CARTA RIVELATA RIEMPIE LA SCENA, e ci sta tutta',
      (tester) async {
    // **Il fondatore, guardando l'anteprima**: *"la carta scelta e rivelata mi
    // sembra piccola, c'e' molto spazio intorno e sembra una schermata
    // vuota"*. Aveva ragione, e si misurava: un tetto sulla scala la fermava a
    // 140 punti su 360, cioe' il 39 per cento della larghezza.
    //
    // Due grandezze, e la seconda e' quella che il primo rimedio ha rotto: la
    // carta deve essere **grande**, e deve starci **tutta**. Alzando solo la
    // scala, la pila del tavolo le tagliava la testa di trentasette punti,
    // perche' arrivava centrata sulla scatola di prima.
    await monta(tester);
    await gira(tester, 6);
    final carta = tester.getRect(find.byType(TarotCardArt));
    final tavolo = tester.getRect(find.byType(TavoloDeiVentidue));
    final schermo =
        tester.view.physicalSize.width / tester.view.devicePixelRatio;
    print('ORDINE DU: la carta rivelata e\' larga '
        '${carta.width.toStringAsFixed(1)} punti su $schermo, cioe\' il '
        '${(carta.width / schermo * 100).round()} per cento');
    expect(carta.width / schermo, greaterThan(0.55),
        reason: 'la carta rivelata occupa il '
            '${(carta.width / schermo * 100).round()} per cento della '
            'larghezza: intorno resta troppo vuoto');
    expect(tavolo.top, lessThanOrEqualTo(carta.top + 1),
        reason: 'la carta esce dalla scatola del tavolo in alto di '
            '${(tavolo.top - carta.top).toStringAsFixed(1)} punti, e la pila '
            'la taglia');
    expect(tavolo.bottom, greaterThanOrEqualTo(carta.bottom - 1),
        reason: 'la carta esce dalla scatola del tavolo in basso di '
            '${(carta.bottom - tavolo.bottom).toStringAsFixed(1)} punti');
  });

  testWidgets('IL RESPONSO SI PRESENTA: la parola ha un nome e un uso',
      (tester) async {
    // **Il fondatore**: *"la parola deve essere dichiarata tipo 'la parola di
    // oggi:' e l'utente deve sapere cosa farsene... vuole risposte chiare,
    // dirette e ognuna guida"*.
    //
    // Prima la parola stava da sola, in maiuscolo grande, e chi leggeva doveva
    // indovinare che cosa fosse e che cosa farsene. Qui si misura che ogni
    // pezzo del responso porti il suo nome, **e che i nomi stiano sopra la
    // cosa che nominano**: un'etichetta sotto il suo testo non guida nessuno.
    await monta(tester);
    await gira(tester, 9);
    final oggi = await tester.runAsync(() => ArchivioDellAlba.diOggi(adesso));
    expect(oggi!.parola, isNotNull,
        reason: 'ogni carta ha la sua parola, voce DU.08');

    final etichettaParola =
        find.byKey(const Key('arcano_alba_etichetta_parola'));
    final parola = find.byKey(const Key('arcano_alba_parola'));
    final uso = find.byKey(const Key('arcano_alba_uso_della_parola'));
    final etichettaGesto = find.byKey(const Key('arcano_alba_etichetta_gesto'));
    final dono = find.byKey(const Key('arcano_alba_dono'));
    for (final (nome, chi) in [
      ('l\'etichetta della parola', etichettaParola),
      ('la parola', parola),
      ('la riga che dice cosa farne', uso),
      ('l\'etichetta del gesto', etichettaGesto),
      ('il gesto', dono),
    ]) {
      expect(chi, findsOneWidget, reason: 'manca $nome');
    }
    expect(tester.widget<Text>(etichettaParola).data, 'La parola di oggi');
    expect(tester.widget<Text>(etichettaGesto).data, 'Il gesto di oggi');

    // L'ordine a video: nome, parola, uso, nome del gesto, gesto.
    final quote = [
      tester.getTopLeft(etichettaParola).dy,
      tester.getTopLeft(parola).dy,
      tester.getTopLeft(uso).dy,
      tester.getTopLeft(etichettaGesto).dy,
      tester.getTopLeft(dono).dy,
    ];
    for (var i = 1; i < quote.length; i++) {
      expect(quote[i], greaterThan(quote[i - 1]),
          reason: 'il responso non scorre nell\'ordine giusto: $quote');
    }
    print('ORDINE DU: il responso si legge in questo ordine, alle quote '
        '${quote.map((q) => q.round()).toList()}');
  });

  testWidgets(
      'IL TESTO HA IL SUO MARGINE E IL GESTO IL SUO RIQUADRO, col perche\', '
      'ordine DV voci 11 e 12', (tester) async {
    // **Il fondatore, sulle catture del telefono**: *"tutto il testo non ha
    // margini nel riquadro sottostante, il testo e' attaccato ai margini del
    // riquadro sia a destra che a sinistra"*. E: *"metti il gesto con titolo
    // in un riquadro per evidenziarlo dal resto del testo"*, con il perche'.
    //
    // Si misura la distanza vera fra il bordo del pannello e ogni testo, e
    // fra il bordo del riquadro e cio' che contiene.
    await monta(tester);
    await gira(tester, 3);
    final oggi = await tester.runAsync(() => ArchivioDellAlba.diOggi(adesso));
    final pannello =
        tester.getRect(find.byKey(const Key('arcano_alba_pannello')));
    final riquadro =
        tester.getRect(find.byKey(const Key('arcano_alba_riquadro_del_gesto')));
    const margine = 12.0;
    final misure = <String>[];
    for (final (nome, chiave) in [
      ('la carta', 'arcano_alba_carta'),
      ('la parola', 'arcano_alba_parola'),
      ('l\'uso della parola', 'arcano_alba_uso_della_parola'),
      ('la chiusura di Medora', 'arcano_alba_medora'),
      ('il riquadro del gesto', 'arcano_alba_riquadro_del_gesto'),
    ]) {
      final r = tester.getRect(find.byKey(Key(chiave)));
      final sinistra = r.left - pannello.left;
      final destra = pannello.right - r.right;
      misure.add('$nome ${sinistra.round()}/${destra.round()}');
      expect(sinistra, greaterThanOrEqualTo(margine),
          reason: '$nome sta a ${sinistra.toStringAsFixed(1)} punti dal bordo '
              'sinistro del pannello');
      expect(destra, greaterThanOrEqualTo(margine),
          reason: '$nome sta a ${destra.toStringAsFixed(1)} punti dal bordo '
              'destro del pannello');
    }
    // Dentro il riquadro: il titolo, il gesto, il titolo del perche' e il
    // perche', ognuno col suo margine.
    for (final chiave in [
      'arcano_alba_etichetta_gesto',
      'arcano_alba_dono',
      'arcano_alba_etichetta_perche',
      'arcano_alba_perche',
    ]) {
      final r = tester.getRect(find.byKey(Key(chiave)));
      expect(r.left - riquadro.left, greaterThanOrEqualTo(margine),
          reason: '$chiave non ha margine nel riquadro');
      expect(riquadro.right - r.right, greaterThanOrEqualTo(margine),
          reason: '$chiave non ha margine a destra nel riquadro');
      expect(r.top, greaterThanOrEqualTo(riquadro.top + margine),
          reason: '$chiave esce dal riquadro in alto');
      expect(r.bottom, lessThanOrEqualTo(riquadro.bottom - margine),
          reason: '$chiave esce dal riquadro in basso');
    }
    expect(
        tester
            .widget<Text>(find.byKey(const Key('arcano_alba_etichetta_perche')))
            .data,
        'Perché');
    expect(find.text(oggi!.perche, findRichText: true), findsWidgets,
        reason: 'il perche\' del corpus non arriva a video');
    print('ORDINE DV voce 11: margini sinistro/destro nel pannello $misure; '
        'il perche\' a video: ${oggi.perche}');
  });
  testWidgets(
      'DW.02: LA CARTA RIVELATA SI CUSTODISCE, SE NE PARLA E SI CONDIVIDE, '
      'e prima del gesto quei comandi non ci sono', (tester) async {
    // **Il fondatore, sul telefono**: *"ti sei dimenticato di aggiungere i
    // pulsanti per la condivisione che inserisci sempre e quindi non crea
    // nemmeno la card di condivisione"*. L'ordine DT voce 02 li aveva tolti
    // tutti; qui si pretende che ci siano, e solo a carta girata.
    await monta(tester);
    for (final chiave in [
      'responso_condividi',
      'responso_custodisci',
      'responso_parlane',
    ]) {
      expect(find.byKey(Key(chiave)), findsNothing,
          reason: '$chiave c\'e\' gia\' prima di girare la carta');
    }
    await gira(tester, 5);
    final trovate = <String>[];
    for (final chiave in [
      'responso_condividi',
      'responso_custodisci',
      'responso_parlane',
    ]) {
      if (find.byKey(Key(chiave)).evaluate().isNotEmpty) trovate.add(chiave);
    }
    print('ORDINE DW voce 02: azioni sotto la carta rivelata $trovate');
    expect(trovate, hasLength(3),
        reason: 'sotto la carta rivelata mancano delle azioni: ci sono '
            'soltanto $trovate');
  });

  testWidgets(
      'DW.02: LA CARD DA MANDARE porta la carta, la parola, il gesto col suo '
      'perche\' e il dominio del marchio', (tester) async {
    tester.view.physicalSize = const Size(600, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final lettura = lettureDellAlba.firstWhere((l) => l.parola != null);
    final responso =
        ResponsoDellAlba.componi(lettura, apertura: 0, clausola: 0);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ArcanoDellAlbaShareCard(
              responso: responso, palette: MaestroPalette.medora),
        ),
      ),
    ));
    await tester.pump();
    String testo(String chiave) =>
        tester.widget<Text>(find.byKey(Key(chiave))).data!;
    expect(find.byType(TarotCardArt), findsOneWidget,
        reason: 'la card non mostra la carta');
    expect(testo('arcano_card_parola'), lettura.parola!.toUpperCase());
    expect(testo('arcano_card_gesto'), lettura.dono);
    expect(testo('arcano_card_perche'), lettura.perche);
    expect(testo('arcano_card_dominio'), Brand.domain,
        reason: 'la card stampa un dominio che non e\' quello del marchio');
    final accompagna = testoDellArcanoCondiviso(responso);
    expect(accompagna, contains(Brand.url),
        reason: 'il testo che parte con la card non dice dove trovare l\'app');
    print('ORDINE DW voce 02: il testo che accompagna la card: $accompagna');
  });
}
