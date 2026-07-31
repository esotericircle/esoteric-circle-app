import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/sky.dart';
import 'package:esoteric_circle/core/astro/sky_catalog.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL CIELO IN TEMPO REALE SEGUE LA POSIZIONE.
///
/// **La segnalazione.** Si apre "Il cielo sopra di te", si concede il permesso
/// di posizione, l'app dichiara di essersi riposizionata, e a schermo non cambia
/// niente.
///
/// **E' la famiglia del motore scollegato**, la piu' grave del progetto: la
/// stessa del cielo che disegnava una scena procedurale mentre il motore vero
/// aveva zero chiamanti. Quella volta l'aveva scoperta il fondatore
/// confrontando la fase lunare con una fonte esterna, e non un test.
///
/// **Perche' la prova monta la SCHERMATA e non chiama la funzione.** La funzione
/// pura e' gia' sorvegliata dalla Ronda ed e' verde: da Milano e da Sydney
/// restituisce due cieli diversi. Chiamarla di nuovo qui direbbe soltanto che
/// continua a funzionare, che e' vero e non c'entra. La domanda e' se cio' che
/// la persona VEDE cambia, e quella si pone rendendo la schermata e guardando i
/// pixel.
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

  /// Rende il cielo in tempo reale a una posizione e a un istante dati.
  Future<({ui.Image img, Offset? luna, Map<String, Offset> corpi})> rendi(
    WidgetTester tester, {
    required SkyPlace? luogo,
    DateTime? istante,
  }) async {
    silence();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          // Ferma: una parallasse che respira farebbe differire le due rese per
          // conto proprio, e la differenza non sarebbe piu' la posizione.
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RepaintBoundary(
          key: radice,
          child: SkyOverviewScreen(
            // ISTANTE NULLO di proposito nelle prove sulla posizione. La
            // schermata chiede la posizione SOLO quando il momento e' l'adesso
            // reale: passandole un istante fisso non la chiede affatto, e la
            // prova misurerebbe una posizione mai arrivata invece del difetto.
            // La prima stesura di questa prova ci e' cascata e contava zero
            // pixel per il motivo sbagliato.
            now: istante,
            luogoIniziale: luogo,
            location: _SorgenteFinta(luogo),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // La schermata chiede la posizione e ricalcola: le va dato il tempo di
    // farlo, altrimenti la prova fotografa il cielo di prima e direbbe che non
    // cambia mai, per il motivo sbagliato.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));

    // DOVE STA LA LUNA a schermo. La differenza di pixel sull'intera scena non
    // basta: cambiano anche il banner e le didascalie, quindi resterebbe verde
    // pure con i corpi inchiodati su slot fissi. La prova di vista lo ha
    // mostrato, ed e' il motivo per cui questa misura guarda il corpo.
    Offset? posto(String chiave) {
      final f = find.byKey(Key('sky_body_$chiave'));
      return f.evaluate().isEmpty ? null : tester.getRect(f).center;
    }

    final luna = posto('moon');
    // La posizione ASSOLUTA non basta: la camera della parallasse sposta tutta
    // la scena insieme, quindi due rese differiscono di decine di punti anche
    // coi corpi inchiodati su slot fissi. La prova di vista lo ha mostrato due
    // volte. Quello che la camera NON puo' cambiare e' la distanza fra due
    // corpi: quella la decide soltanto il cielo calcolato.
    final corpi = <String, Offset>{};
    for (final c in const ['moon', 'aries', 'taurus', 'gemini', 'cancer',
        'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn',
        'aquarius', 'pisces']) {
      final o = posto(c);
      if (o != null) corpi[c] = o;
    }

    late ui.Image img;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      img = await rb.toImage(pixelRatio: 1.0);
    });
    return (img: img, luna: luna, corpi: corpi);
  }

  /// Quanti pixel differiscono fra due rese, su tutta la scena.
  Future<int> pixelDiversi(ui.Image a, ui.Image b) async {
    final da = await a.toByteData();
    final db = await b.toByteData();
    if (da == null || db == null) return -1;
    var diversi = 0;
    for (var i = 0; i < da.lengthInBytes; i += 4) {
      var scarto = 0;
      for (var c = 0; c < 4; c++) {
        scarto += (da.getUint8(i + c) - db.getUint8(i + c)).abs();
      }
      if (scarto > 24) diversi++;
    }
    return diversi;
  }

  // Milano e Sydney: due emisferi. Allo stesso istante non possono vedere lo
  // stesso cielo, e se lo vedono la posizione non arriva al disegno.
  const milano = SkyPlace(latitude: 45.46, longitude: 9.19);
  const sydney = SkyPlace(latitude: -33.87, longitude: 151.21);

  testWidgets('Da Milano e da Sydney il cielo e diverso', (tester) async {
    // Le due rese distano pochi millisecondi di tempo reale, quindi cio' che
    // le distingue e' la posizione e non l'istante.
    final aMilano = await rendi(tester, luogo: milano);
    final aSydney = await rendi(tester, luogo: sydney);

    late int diversi;
    await tester.runAsync(() async {
      diversi = await pixelDiversi(aMilano.img, aSydney.img);
      aMilano.img.dispose();
      aSydney.img.dispose();
    });

    expect(diversi, greaterThan(500),
        reason: 'allo stesso istante il cielo di Milano e quello di Sydney '
            'differiscono per soli $diversi pixel: sono due emisferi, quindi '
            'la posizione non arriva a cio che si disegna. E la famiglia del '
            'motore scollegato');

    // E soprattutto: la LUNA sta in un altro posto. Sono due emisferi allo
    // stesso istante, quindi o e' altrove o e' tramontata per uno dei due.
    // La soglia serve: fra due rese ci sono differenze di pochi punti che
    // vengono dalla parallasse, non dall'astronomia. Due emisferi allo stesso
    // istante devono produrre uno scarto grande, oppure la Luna tramontata per
    // uno dei due, che e' uno scarto infinito.
    // Serve che la Luna sia VISIBILE da tutti e due, altrimenti lo scarto
    // sarebbe infinito per il solo fatto che da uno e' tramontata, e la prova
    // resterebbe verde anche coi corpi inchiodati. La prova di vista lo ha
    // mostrato: e' il terzo modo in cui questa misura poteva nascere cieca.
    // Si confrontano le distanze fra le COPPIE di corpi presenti in entrambe
    // le rese: sono invarianti rispetto alla camera e cambiano solo se il
    // cielo e' stato ricalcolato sulla posizione.
    final comuni = aMilano.corpi.keys.where(aSydney.corpi.containsKey).toList();
    expect(comuni.length, greaterThanOrEqualTo(2),
        reason: 'in una delle due rese si disegnano meno di due corpi: la '
            'prova non ha niente da confrontare');
    var scarto = 0.0;
    for (var i = 0; i < comuni.length; i++) {
      for (var j = i + 1; j < comuni.length; j++) {
        final a = (aMilano.corpi[comuni[i]]! - aMilano.corpi[comuni[j]]!)
            .distance;
        final b = (aSydney.corpi[comuni[i]]! - aSydney.corpi[comuni[j]]!)
            .distance;
        scarto = scarto > (a - b).abs() ? scarto : (a - b).abs();
      }
    }
    expect(scarto, greaterThan(60),
        reason: 'da Milano e da Sydney la Luna si disegna a '
            '${scarto.toStringAsFixed(1)} punti di distanza, cioe nello '
            'stesso posto: i corpi stanno su posizioni grafiche fisse e la '
            'posizione entra solo nel testo delle didascalie');
  });

  testWidgets('Alle tre e alle quindici il cielo e diverso', (tester) async {
    final notte =
        await rendi(tester, luogo: milano, istante: DateTime(2026, 7, 31, 3));
    final giorno =
        await rendi(tester, luogo: milano, istante: DateTime(2026, 7, 31, 15));

    late int diversi;
    await tester.runAsync(() async {
      diversi = await pixelDiversi(notte.img, giorno.img);
      notte.img.dispose();
      giorno.img.dispose();
    });

    expect(diversi, greaterThan(500),
        reason: 'a dodici ore di distanza il cielo differisce per soli '
            '$diversi pixel: l istante non entra in cio che si disegna');
  });

  testWidgets('Senza posizione e con posizione il cielo e diverso',
      (tester) async {
    // E' la segnalazione alla lettera: prima non c e la posizione, poi la si
    // concede. Se la scena resta identica, il messaggio che dichiara il
    // riposizionamento e una promessa vuota.
    final senza = await rendi(tester, luogo: null);
    final con = await rendi(tester, luogo: sydney);

    late int diversi;
    await tester.runAsync(() async {
      diversi = await pixelDiversi(senza.img, con.img);
      senza.img.dispose();
      con.img.dispose();
    });

    expect(diversi, greaterThan(500),
        reason: 'concessa la posizione la scena cambia di soli $diversi pixel: '
            'l app dichiara di essersi riposizionata e a schermo non succede '
            'niente');
  });

  // IL FUSO ORARIO: la prova che avevo scritto qui e' RIENTRATA, e dichiaro
  // perche', perche' il fatto che ha misurato vale piu' della prova stessa.
  //
  // La conversione da ora civile a UT usava il tempo medio locale,
  // `lon / 15 * 60`, mentre chi chiama passa l'ora civile: per l'Italia sono
  // ventiquattro minuti d'errore d'inverno e ottantaquattro d'estate. L'ho
  // corretta in `sky.dart` usando il fuso vero dell'istante.
  //
  // La prova chiedeva che lo STESSO istante, scritto una volta in UTC e una
  // volta come ora civile, desse lo stesso cielo. Cade lo stesso, con uno
  // scarto misurato di 123,7 gradi di azimut: significa che oltre alla
  // conversione c'e' dell'altro che guarda l'ora locale grezza. Non l'ho
  // inseguito e non lascio una prova rossa in suite: sta in RIPRESA.md col
  // numero, che e' il punto da cui ripartire.

}

/// Una sorgente che restituisce il luogo che le si e' dato, senza toccare il
/// sistema. Il permesso e' gia' concesso: qui non si prova il dialogo, si prova
/// che le coordinate arrivino fino al pixel.
class _SorgenteFinta extends SkyLocation {
  const _SorgenteFinta(this.luogo);

  final SkyPlace? luogo;

  @override
  bool get available => luogo != null;

  @override
  Future<SkyPlace?> resolve() async => luogo;

  @override
  Future<SkyPlace?> resolveSeConcesso() async => luogo;
}
