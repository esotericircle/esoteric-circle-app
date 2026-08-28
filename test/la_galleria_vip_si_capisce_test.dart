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
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:esoteric_circle/features/synastry/sinastria_vip_screen.dart';

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
    expect(larghezze.length, greaterThanOrEqualTo(6),
        reason: 'in scena ci sono solo ${larghezze.length} ritratti: la '
            'prova non sta guardando la griglia');
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

  testWidgets('Le due funzioni virali sono porte grandi, non righe di testo',
      (tester) async {
    // **LA GRANDEZZA MISURATA E' L'ALTEZZA DELLA PORTA E IL CORPO DEL SUO
    // TITOLO.** Erano due pulsanti di testo alti quarantotto punti con
    // l'etichetta a dodici; una funzione che deve risaltare non si scrive
    // cosi'.
    await monta(tester);
    for (final porta in const [
      ('sinastria_cerca_gemello', 'Trova il tuo gemello astrale VIP'),
      ('sinastria_due_vip', 'Confronta 2 VIP'),
    ]) {
      final f = find.byKey(Key(porta.$1));
      expect(f, findsOneWidget, reason: 'la porta ${porta.$1} non c\'e\'');
      final r = tester.getRect(f);
      final titolo = tester.widget<Text>(find.descendant(
          of: f, matching: find.text(porta.$2)));
      // ignore: avoid_print
      print('ORDINE DEL 28 AGOSTO: la porta "${porta.$2}" e\' alta '
          '${r.height.toStringAsFixed(1)} punti e il titolo e\' scritto a '
          '${titolo.style!.fontSize}');
      expect(r.height, greaterThanOrEqualTo(64),
          reason: 'la porta "${porta.$2}" e\' alta '
              '${r.height.toStringAsFixed(1)} punti: non risalta');
      expect(titolo.style!.fontSize,
          greaterThanOrEqualTo(TypographyTokens.titoloScheda().fontSize!),
          reason: 'il titolo di "${porta.$2}" e\' scritto a '
              '${titolo.style!.fontSize}, cioe\' come un\'etichetta');
    }
  });

  testWidgets('Il confronto fra due VIP non parte da un VIP scelto dall\'app',
      (tester) async {
    // **IL DIFETTO ERA UNA RIGA SOLA**: il pulsante chiamava
    // `_sostituisciLaPrimaCasella(VipCatalog.first)`, e il primo del catalogo
    // e' Angelina Jolie. Adesso il tocco apre la scelta.
    await monta(tester);
    await tester.tap(find.byKey(const Key('sinastria_due_vip')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // ignore: avoid_print
    print('ORDINE DEL 28 AGOSTO: dopo il tocco su "Confronta 2 VIP" la '
        'schermata chiede di scegliere? '
        '${find.text('Scegli il primo dei due VIP').evaluate().isNotEmpty}');
    expect(find.text('Scegli il primo dei due VIP'), findsOneWidget,
        reason: 'il confronto non chiede chi mettere per primo');
    expect(find.byKey(const Key('sinastria_gauge')), findsNothing,
        reason: 'il confronto e\' partito da solo su un VIP che nessuno ha '
            'scelto: era sempre Angelina Jolie');
    // E la via del ritorno a se stessi c'e', in quel momento.
    expect(find.byKey(const Key('sinastria_torna_a_te')), findsOneWidget,
        reason: 'da qui non si torna a mettere se stessi');
  });

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

  testWidgets('Alla fine del percorso doppio i due soggetti sono i due VIP',
      (tester) async {
    // **ORDINE BX VOCE 06, SETTIMO RILIEVO**: "nel confronto doppio si
    // finisce per tornare a se\' stessi". La guardia sopra misura come
    // COMINCIA il percorso; questa misura come FINISCE, che e\' quello che
    // l'ordine chiede per nome: l'identita\' dei due soggetti confrontati
    // alla fine del percorso doppio.
    await monta(tester);
    // Si chiede il confronto fra due VIP.
    await tester.tap(find.byKey(const Key('sinastria_due_vip')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Si sceglie il PRIMO, e non e\' il primo del catalogo: si prende il
    // terzo, cosi\' se un giorno tornasse un valore scritto a mano si vede.
    final primo = VipCatalog.vips[2];
    await tester.scrollUntilVisible(find.byKey(Key('vip_${primo.name}')), 120,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(Key('vip_${primo.name}')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Adesso la galleria si e\' riaperta per il secondo, e lo dice.
    expect(find.textContaining(primo.name), findsWidgets,
        reason: 'la seconda galleria non dice chi e\' il primo scelto');

    // Si sceglie il SECONDO.
    final secondo = VipCatalog.vips[5];
    // **SOLO LA GALLERIA IN CIMA.** Le due gallerie convivono nella pila del
    // Navigator, e ognuna ha la sua carta per lo stesso VIP: cercare per
    // chiave senza dire dove trova due widget con la stessa chiave.
    final inCima = find.byType(SinastriaGalleryScreen).last;
    final cartaDelSecondo = find.descendant(
        of: inCima, matching: find.byKey(Key('vip_${secondo.name}')));
    await tester.scrollUntilVisible(cartaDelSecondo, 120,
        scrollable: find
            .descendant(of: inCima, matching: find.byType(Scrollable))
            .first);
    await tester.tap(cartaDelSecondo);
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    // **E ADESSO SI GUARDA CHI E\' A CONFRONTO.** Non i testi, che potrebbero
    // nominare chiunque: la schermata del responso dichiara i suoi due
    // soggetti, e sono quelli che si leggono.
    final schermata =
        tester.widget<SinastriaVipScreen>(find.byType(SinastriaVipScreen));
    // ignore: avoid_print
    print('ORDINE BX VOCE 6: alla fine del percorso doppio si confrontano '
        '"${schermata.primoVip?.name ?? "TU"}" e "${schermata.vip?.name}"');
    expect(schermata.primoVip?.name, primo.name,
        reason: 'il primo soggetto non e\' il VIP scelto: il confronto e\' '
            'tornato a te');
    expect(schermata.vip?.name, secondo.name,
        reason: 'il secondo soggetto non e\' il VIP scelto per secondo');
    // E a schermo compaiono tutti e due i nomi, nessuno dei due sostituito.
    for (final chi in [primo, secondo]) {
      expect(find.textContaining(chi.name), findsWidgets,
          reason: 'il nome di ${chi.name} non compare nel confronto');
    }
  });
}
