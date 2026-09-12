import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/collezione_delle_coppie.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA GALLERIA VIP SI CAPISCE. Ordine del fondatore del 28 agosto 2026.
///
/// **Parole sue, sette rilievi in un messaggio solo**: "elimina la sezione Vip
/// in evidenza che non serve a nulla"; "anziche' usare un pulsante per ogni
/// categoria, usa un unico selettore menu' a tendina Categoria VIP con tutte
/// le opzioni"; "il confronto tra 2 vip lo da' sempre con Angelina Jolie e non
/// ha senso, l'utente fa click sulla carta e puo' cambiare il vip"; "quando
/// l'utente e' in modalita' confronto tra 2 VIP, come fa a tornare a mettere
/// se stesso?"; "la visualizzazione dei vip come le carte mischiate senza
/// ordine e con dimensioni diverse non va bene, non si vedono i nomi dei vip,
/// ma non si riconoscono nemmeno i volti"; il gemello astrale "e' una funzione
/// potenzialmente virale e deve risaltare"; e il confronto fra due VIP "deve
/// essere anche una funzione ben visibile".
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
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

  Future<void> monta(WidgetTester tester) async {
    silenzia();
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => CollezioneDelleCoppie()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: const SinastriaGalleryScreen(
          userSign: Zodiac.leo,
          userName: 'Mauro',
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('I volti stanno in fila, della stessa misura, col nome leggibile',
      (tester) async {
    // **LA GRANDEZZA MISURATA E' LA DIFFERENZA FRA LE LARGHEZZE**, ed e' cio'
    // che il fondatore ha visto: i ritratti stavano su tre piani di
    // profondita', quindi tre misure diverse, e il nome scendeva fino al 55
    // per cento di opacita' sul piano piu' lontano.
    await monta(tester);
    final larghezze = <double>[];
    final righe = <double>{};
    for (final vip in VipCatalog.vips.take(12)) {
      final f = find.byKey(Key('vip_${vip.name}'));
      if (f.evaluate().isEmpty) continue;
      final r = tester.getRect(f);
      larghezze.add(r.width);
      righe.add(r.top.roundToDouble());
    }
    // **QUATTRO E NON PIU' SEI, ordine BZ voce 09.** Parole del fondatore:
    // "l'elenco delle carte adesso sono in ordine, ma andrebbero un po'
    // ingrandite". Le colonne sono passate da tre a due, quindi in una
    // schermata ne entrano meno: il numero cala PERCHE' la misura cresce, ed
    // e' la misura che questa prova difende. La larghezza vera si misura piu'
    // sotto, e quella e' una soglia che sale.
    expect(larghezze.length, greaterThanOrEqualTo(4),
        reason: 'in scena ci sono solo ${larghezze.length} ritratti: la '
            'prova non sta guardando la griglia');
    expect(larghezze.first, greaterThanOrEqualTo(140),
        reason: 'i ritratti della lista sono larghi '
            '${larghezze.first.toStringAsFixed(1)} punti: il fondatore li ha '
            'chiesti piu\' grandi, ed erano 101');
    final piuLarga = larghezze.reduce((a, b) => a > b ? a : b);
    final piuStretta = larghezze.reduce((a, b) => a < b ? a : b);
    // ignore: avoid_print
    print('ORDINE DEL 28 AGOSTO: ${larghezze.length} ritratti in scena, il '
        'piu\' largo ${piuLarga.toStringAsFixed(1)} e il piu\' stretto '
        '${piuStretta.toStringAsFixed(1)} punti, su ${righe.length} righe');
    expect(piuLarga - piuStretta, lessThan(1.0),
        reason: 'i ritratti hanno misure diverse, dal '
            '${piuStretta.toStringAsFixed(1)} al '
            '${piuLarga.toStringAsFixed(1)}: e\' la galleria mischiata che il '
            'fondatore ha fermato');

    // **E I VOLTI SONO ALTI UGUALI.** Ordine BX voce 06, trovato guardando
    // l'anteprima: col nome libero di stare su una riga o su due, il
    // ritratto sopra prendeva cio\' che restava, e nella stessa riga della
    // griglia un volto stava piu\' in alto dell'altro. E\' la stessa "galleria
    // mischiata" che il fondatore aveva gia\' fermato, arrivata da un'altra
    // strada.
    final altezzeDeiVolti = <double>[];
    for (final vip in VipCatalog.vips.take(12)) {
      final f = find.descendant(
          of: find.byKey(Key('vip_${vip.name}')),
          matching: find.byType(ClipRRect));
      if (f.evaluate().isEmpty) continue;
      altezzeDeiVolti.add(tester.getRect(f.first).height);
    }
    final piuAlto = altezzeDeiVolti.reduce((a, b) => a > b ? a : b);
    final piuBasso = altezzeDeiVolti.reduce((a, b) => a < b ? a : b);
    // ignore: avoid_print
    print('ORDINE BX VOCE 6: ${altezzeDeiVolti.length} volti, il piu\' alto '
        '${piuAlto.toStringAsFixed(1)} e il piu\' basso '
        '${piuBasso.toStringAsFixed(1)} punti');
    expect(piuAlto - piuBasso, lessThan(1.0),
        reason: 'i volti hanno altezze diverse, dal '
            '${piuBasso.toStringAsFixed(1)} al ${piuAlto.toStringAsFixed(1)}: '
            'un nome su due righe sposta il ritratto e la griglia si '
            'scompiglia');

    // I nomi si leggono: colore pieno, non una velatura.
    final nome = tester.widget<Text>(find.descendant(
        of: find.byKey(Key('vip_${VipCatalog.first.name}')),
        matching: find.text(VipCatalog.first.name)));
    // ignore: avoid_print
    print('ORDINE DEL 28 AGOSTO: il nome del VIP e\' scritto in '
        '${nome.style!.color}');
    expect(nome.style!.color, ColorTokens.textPrimary,
        reason: 'il nome del VIP non e\' a pieno contrasto: e\' per questo '
            'che non si leggeva');
  });

  // **TRE PROVE HANNO TRASLOCATO, ordine CA voce 01.** Misuravano le due
  // porte virali, il confronto che non parte da un VIP scelto dall'app e le
  // due carte in cima: tutte e tre quelle cose adesso vivono nella PORTA
  // della Sinastria, non nella galleria, per parole del fondatore ("le bolle
  // ... devono stare nella prima schermata che vede l'utente e non nella
  // schermata di scelta del vip"). Le stesse misure, sulla schermata giusta,
  // stanno in test/la_porta_della_sinastria_test.dart. **Nessuna e' stata
  // cancellata**: una guardia che misura una cosa spostata si sposta con lei.

  testWidgets('I titoli non rubano il posto al contenuto', (tester) async {
    // **ORDINE BX VOCE 06, QUARTO RILIEVO: "i titoli della schermata sono
    // troppo grandi".** L'ordine lascia scegliere la grandezza misurabile e
    // chiede di dichiararla prima: **il corpo del titolo piu\' grande della
    // schermata, in rapporto al corpo del testo che si legge**, che vale
    // sedici punti in tutta l'app. Un titolo e\' troppo grande quando pesa
    // piu\' di una volta e mezza cio\' che deve far leggere.
    //
    // **MISURATO, IL RILIEVO NON SI E\' RIPRODOTTO.** Sulla galleria il
    // titolo piu\' grande e\' quello della barra, diciannove punti, e le due
    // porte grandi stanno a diciotto; sul responso il titolo della barra sta
    // a venti. Nessuno arriva a ventiquattro, cioe\' una volta e mezza il
    // testo. Nel codice della Sinastria esistono due soli corpi sopra i
    // ventidue, e nessuno dei due e\' un titolo: il ventisei della cartolina
    // da condividere, che e\' un'immagine e non una schermata, e il trentasei
    // del numero dentro la ruota, che e\' il responso stesso.
    //
    // La guardia resta perche\' da qui in avanti il fatto sia sorvegliato: se
    // un titolo cresce oltre la misura, cade.
    await monta(tester);
    final corpi = <String, double>{};
    for (final e in find.byType(Text).evaluate()) {
      final w = e.widget as Text;
      final testo = w.data ?? '';
      final corpo = w.style?.fontSize;
      if (testo.trim().isEmpty || corpo == null) continue;
      // Le sole voci che contano sono i TITOLI, cioe\' le righe brevi: un
      // paragrafo lungo non e\' un titolo nemmeno se e\' scritto grande.
      if (testo.length > 40) continue;
      // **E NON E\' UN TITOLO NEANCHE UN SIMBOLO DENTRO UNA CARTA.**
      // Ordine BZ voce 09: l\'intestazione nuova monta la carta della
      // persona, e dove non c\'e\' una foto la cornice disegna il simbolo
      // del segno in grande. E\' un DISEGNO, non una riga che ruba il posto:
      // un carattere solo non e\' un titolo.
      if (testo.trim().length <= 2) continue;
      corpi[testo] = corpo;
    }
    final piuGrande =
        corpi.entries.reduce((a, b) => a.value >= b.value ? a : b);
    // ignore: avoid_print
    print('ORDINE BX VOCE 6: il titolo piu\' grande della galleria e\' '
        '"${piuGrande.key}" a ${piuGrande.value} punti, su un testo di '
        'lettura da 16');
    expect(piuGrande.value, lessThanOrEqualTo(24.0),
        reason: 'il titolo "${piuGrande.key}" e\' scritto a '
            '${piuGrande.value} punti, cioe\' piu\' di una volta e mezza il '
            'testo che deve far leggere');
  });

  // **E ANCHE LA QUARTA HA TRASLOCATO, ordine CA voce 01.** "Alla fine del
  // percorso doppio i due soggetti sono i due VIP" cominciava toccando
  // "Confronta 2 VIP", che adesso sta nella porta: la stessa misura, sulla
  // strada nuova, sta in test/la_porta_della_sinastria_test.dart.
}
