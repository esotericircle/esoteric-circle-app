import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL PULSANTE DEL DOMINIO NON STA SOPRA LA CARTA DEL MAESTRO.
///
/// **La segnalazione, fatta quattro volte.** Nella home il pulsante "Entra nel
/// Dominio di <Maestro>" e il sottotitolo sotto di esso si sovrappongono alla
/// carta del Maestro centrale: si vede l'avatar ATTRAVERSO il pulsante. Nello
/// stesso momento sopra le tre carte avanza molto spazio vuoto.
///
/// **Perche' la prova esistente non lo prendeva.** `bolla_non_copre_avatar_test`
/// guarda la zona della BOLLA e chiede se li' sotto arriva la figura. E' una
/// misura giusta e resta, ma e' cieca su due cose: gira per il solo Maestro
/// predefinito, e a una sola posizione di scorrimento. Il difetto vive nelle
/// posizioni che quella prova non visita.
///
/// **Perche' la misura e' differenziale e non geometrica.** L'ombra del
/// pulsante dipinge FUORI dal proprio rettangolo: qualunque distanza fra i
/// rettangoli dei widget incontra l'ombra prima della carta, e ha gia' prodotto
/// tre misure cieche. Qui si rende due volte, con e senza il pulsante, e si
/// confrontano i pixel DENTRO il rettangolo della carta. Se togliendo il
/// pulsante quei pixel cambiano, il pulsante li stava dipingendo.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silence() {
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

  /// Rende la home per un Maestro dato, a una posizione di scorrimento data.
  Future<({ui.Image img, Rect carta, Rect bolla, Rect carosello})> rendi(
    WidgetTester tester, {
    required Maestro maestro,
    required double scorrimento,
    required bool disegnaIngresso,
    bool disegnaTrio = true,
    double larghezzaFisica = 1080,
    double altezzaFisica = 2392,
  }) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = Size(larghezzaFisica, altezzaFisica);
    // LE BARRE DI SISTEMA CI SONO, e mangiano altezza. Un telefono vero ha la
    // barra di stato in alto e quella dei gesti in fondo: senza dichiararle, la
    // prova dispone di un'altezza utile che sul telefono non esiste, e il
    // difetto vive proprio nell'altezza che manca. E' il motivo per cui tre
    // stesure di questa misura sono restate verdi mentre a schermo si vedeva.
    tester.view.padding = const FakeViewPadding(top: 108, bottom: 72);
    tester.view.viewPadding = const FakeViewPadding(top: 108, bottom: 72);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    final maestri = MaestroController()..selectMaestro(maestro);
    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<MaestroController>.value(value: maestri),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => GreetingController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          // Fermo: una parallasse che respira farebbe differire le due rese per
          // conto proprio, e la differenza non sarebbe piu' la sovrapposizione.
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true, textScaler: const TextScaler.linear(1.6)),
          child: MaestroScope(child: child!),
        ),
        home: RepaintBoundary(
          key: radice,
          child: SantuarioScreen(
            clock: () => DateTime(2026, 7, 30, 21),
            disegnaIngresso: disegnaIngresso,
            disegnaTrio: disegnaTrio,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // L'AVATAR VA PRECARICATO, altrimenti non c'e' nessuna figura sotto il
    // pulsante e qualunque misura di sovrapposizione risulta verde. E' il
    // motivo per cui cinque misure in fila sono nate cieche in questo progetto.
    await tester.runAsync(() async {
      final elemento = tester.element(find.byType(MaterialApp));
      for (final m in Maestro.values) {
        await precacheImage(AssetImage(m.avatarAsset), elemento);
      }
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    if (scorrimento > 0) {
      final scorrevole = find.byType(Scrollable);
      if (scorrevole.evaluate().isNotEmpty) {
        await tester.drag(scorrevole.first, Offset(0, -scorrimento));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    final carta =
        tester.getRect(find.byKey(const Key('santuario_central_bust')));
    // Il fondo del blocco del cielo: sotto di lui comincia lo spazio che
    // separa il cielo dalla carta, ed e' quello che avanza.
    final carosello =
        tester.getRect(find.byKey(const Key('santuario_carosello')));
    // LA ZONA D'INGRESSO E' PULSANTE PIU' SOTTOTITOLO, non il solo pulsante.
    // La segnalazione nomina tutti e due: "il pulsante Entra nel Dominio E il
    // sottotitolo sotto di esso". Guardare il solo pulsante lascia scoperta
    // proprio la riga che cade sopra il bordo inferiore della cornice, e la
    // seconda stesura di questa prova e' restata verde per questo.
    final bolla = tester
        .getRect(find.byKey(const Key('santuario_enter_domain')))
        .expandToInclude(
            tester.getRect(find.byKey(const Key('santuario_domain_arts'))));

    late ui.Image img;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      img = await rb.toImage(pixelRatio: 3.0);
    });
    return (img: img, carta: carta, bolla: bolla, carosello: carosello);
  }

  /// Quanti pixel differiscono fra due immagini, dentro un rettangolo.
  Future<int> pixelDiversi(ui.Image a, ui.Image b, Rect zona) async {
    final da = await a.toByteData();
    final db = await b.toByteData();
    if (da == null || db == null) return -1;
    final w = a.width;
    final y0 = (zona.top * 3).round().clamp(0, a.height - 1);
    final y1 = (zona.bottom * 3).round().clamp(0, a.height - 1);
    final x0 = (zona.left * 3).round().clamp(0, w - 1);
    final x1 = (zona.right * 3).round().clamp(0, w - 1);
    var diversi = 0;
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        final i = (y * w + x) * 4;
        // Una differenza di pochi livelli e' rumore di antialias: si conta solo
        // cio' che si vede davvero.
        var scarto = 0;
        for (var c = 0; c < 4; c++) {
          scarto += (da.getUint8(i + c) - db.getUint8(i + c)).abs();
        }
        if (scarto > 24) diversi++;
      }
    }
    return diversi;
  }

  // Tre Maestri e due posizioni di scorrimento: in cima e a meta'. Il difetto
  // vive nelle combinazioni che la prova vecchia non visitava.
  for (final maestro in Maestro.values) {
    for (final (nome, scorrimento) in const [
      ('in cima', 0.0),
      ('a meta', 240.0),
    ]) {
      testWidgets(
          'Il pulsante non copre la carta di ${maestro.name}, $nome',
          (tester) async {
        // TRE RESE, e servono tutte. Confrontare "con pulsante" e "senza
        // pulsante" dentro una zona non basta: dove il fondo e' vuoto il
        // pulsante dipinge comunque, quindi la misura conta sempre qualcosa e
        // non distingue la sovrapposizione dal semplice esistere del pulsante.
        // La prima stesura di questa prova contava novantamila pixel anche
        // senza difetto.
        //
        // Si guarda la ZONA DEL PULSANTE e ci si chiede: li' sotto arriva la
        // figura? Lo dice il confronto fra la resa senza pulsante e quella
        // senza pulsante ne trio. Se differiscono, la figura arriva fin li',
        // quindi il pulsante la copre.
        final senzaPulsante = await rendi(tester,
            maestro: maestro, scorrimento: scorrimento, disegnaIngresso: false);
        final zona = senzaPulsante.bolla;
        final nuda = await rendi(tester,
            maestro: maestro,
            scorrimento: scorrimento,
            disegnaIngresso: false,
            disegnaTrio: false);

        // L'ingombro resta in ogni caso, con Visibility che mantiene la misura:
        // togliere il pulsante dal LAYOUT farebbe salire il carosello, e allora
        // le due immagini differirebbero per intero invece che per la sola
        // sovrapposizione. Se i rettangoli non coincidono, la misura non vale.
        expect(nuda.bolla, zona,
            reason: 'il layout e cambiato fra le due rese: il confronto non '
                'misurerebbe la sovrapposizione');

        late int figuraSottoIlPulsante;
        await tester.runAsync(() async {
          figuraSottoIlPulsante =
              await pixelDiversi(senzaPulsante.img, nuda.img, zona);
          senzaPulsante.img.dispose();
          nuda.img.dispose();
        });

        expect(figuraSottoIlPulsante, 0,
            reason: 'con il Maestro ${maestro.name}, $nome, la figura dipinge '
                '$figuraSottoIlPulsante pixel dentro la zona che il pulsante '
                'occupa: si vede l avatar attraverso il pulsante. Misura '
                'differenziale a tre rese, non geometrica, perche l ombra del '
                'pulsante dipinge fuori dal proprio rettangolo');
      });

      testWidgets(
          'Lo spazio che avanza sopra la carta di ${maestro.name} lo prende la '
          'carta, $nome', (tester) async {
        final resa = await rendi(tester,
            maestro: maestro, scorrimento: scorrimento, disegnaIngresso: true);
        resa.img.dispose();

        // Qui la geometria BASTA, ed e' giusta: non si misura una distanza fra
        // un elemento e un altro, dove l'ombra falserebbe tutto. Si misura
        // quanta parte del proprio contenitore la carta occupa, e un
        // contenitore non ha ombre.
        //
        // I numeri del difetto, a 360 per 797: la carta e' alta 297 punti
        // dentro un contenitore alto 510, cioe' ne usa il 58 per cento. Sopra
        // di lei avanzano piu' di 350 punti mentre sotto ne restano 35: lo
        // spazio non manca, e' distribuito male.
        // LA MISURA E' CAMBIATA DI GRANDEZZA, ordine M, dichiarato: la quota
        // si misura sullo SPAZIO CHE L'EROE POSSIEDE, cioe' lo schermo meno
        // la zona della barra, non sullo schermo intero. Prima il divisore
        // era lo schermo pieno, ma l'imbracatura montava la schermata SENZA
        // la barra: sul telefono vero la barra c'e' sempre, l'eroe vive in
        // schermo meno barra, e la prova misurava un mondo che non esiste.
        // Quando la coda della barra e' diventata costante (voce 1e), la
        // cecita' e' emersa: o si mentiva sul divisore o si mentiva sul
        // mondo. Il senso della regola resta lo stesso: la carta domina lo
        // spazio suo.
        final schermo =
            tester.view.physicalSize.height / tester.view.devicePixelRatio;
        final spazioDellEroe =
            schermo - SantuarioScreen.zonaDellaBarraPerLaProva;
        final quota = resa.carta.height / spazioDellEroe;

        // **LA REGOLA SI RI-MIRA, e la premessa che aveva sotto e' cambiata.**
        // Ordine AU voce 05.
        //
        // Questa prova nasce da un difetto vero: la carta era alta 297 punti
        // dentro un contenitore di 510 mentre sopra di lei avanzavano piu' di
        // 350 punti VUOTI. Il senso della regola e' "lo spazio che avanza
        // sopra la carta lo prende la carta", e la quota del 33 per cento era
        // il modo di misurarlo.
        //
        // **Adesso sopra la carta non avanza piu' niente**: c'e' il blocco del
        // cielo, il titolo, la Luna e la riga personale, che fino a ieri il
        // busto COPRIVA. Misurato: 4.323 pixel di testo coperti su questa
        // stessa misura di schermo. Pretendere ancora il 33 per cento vorrebbe
        // dire pretendere che la carta si riprenda quei punti, cioe' che
        // torni a coprire il testo.
        //
        // La regola non si allenta: cambia di misura. Si pretende che la
        // carta prenda TUTTO lo spazio che il vincolo le concede, che e'
        // esattamente "non sprecare quello che c'e'". Se domani qualcuno
        // rimpicciolisse la carta senza motivo, questa riga lo direbbe come
        // prima.
        final misura = ultimaMisuraDelBusto;
        expect(misura, isNotNull,
            reason: 'la diagnostica del busto non c e: senza di lei non si '
                'puo dire se la carta ha preso tutto lo spazio o no');
        expect(misura!.busto,
            closeTo(math.max(altezzaMinimaDelBusto, misura.concessa), 1.0),
            reason: 'la carta di ${maestro.name} non prende tutto lo spazio '
                'che il vincolo le concede: il busto e ${misura.busto} punti '
                'mentre lo spazio concesso e ${misura.concessa}');
        // ignore: avoid_print
        print('ORDINE AU VOCE 05: la carta di ${maestro.name} occupa il '
            '${(quota * 100).round()} per cento dello spazio dell eroe, '
            '${resa.carta.height.round()} punti, e lo spazio concesso al busto '
            'era ${misura.concessa.toStringAsFixed(1)}');
        expect(quota, greaterThan(0.20),
            reason: 'la carta di ${maestro.name} occupa il '
                '${(quota * 100).round()} per cento dell altezza dello '
                'schermo, ${resa.carta.height.round()} punti su '
                '${schermo.round()}, mentre sopra di lei restano '
                '${resa.carta.top.round()} punti e sotto solo '
                '${(resa.bolla.top - resa.carta.bottom).round()}: lo spazio '
                'che avanza sopra resta vuoto invece di andare alla carta');
      });
    }
  }
}
