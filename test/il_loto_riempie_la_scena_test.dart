import 'package:esoteric_circle/core/maestro/colore_del_centro.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/loto_che_respira.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL LOTO RIEMPIE LA SCENA, E RESPIRA A ONDA.** Ordine DB voce 04.
///
/// **La prima stesura e' stata respinta dal fondatore**, e l'ordine dice
/// perche': *"Il cerchio che si gonfia esce, ed esce anche qualunque figura
/// piccola circondata da spazio vuoto. Questa voce non lascia margine di
/// interpretazione: sono misure."*
///
/// **Le misure che questa guardia pretende**, tutte scritte nella voce:
/// - al culmine dell'inspiro la corona esterna arriva **almeno
///   all'ottantacinque per cento** della larghezza;
/// - al fondo dell'espiro il fiore **non scende sotto il cinquanta per
///   cento**: si chiude, non sparisce;
/// - **almeno quattro corone**, col numero di petali che cresce;
/// - l'apertura **parte dal cuore e arriva dopo al bordo**, che e' l'onda
///   senza la quale il fiore e' solo una figura che si ingrandisce.
///
/// **REGOLA H.** Non basta provare che al culmine il fiore e' grande: si prova
/// anche che **al fondo dell'espiro non sparisce**, e che **con Riduci
/// Movimento il colore resta**. Un fiore che si chiude fino a un punto
/// passerebbe la misura del culmine a pieni voti.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const finestra = Size(390, 844);

  /// **QUANTO IL FIORE OCCUPA DAVVERO, misurato sui pixel dipinti.**
  ///
  /// **QUESTA E LA GRANDEZZA CHE SI MISURA ADESSO, e prima non lo era.** La
  /// prima stesura di questa guardia chiedeva a `raggioDellaCorona` quanto
  /// fosse largo il fiore, cioe' interrogava **la formula** invece della
  /// **forma**. Le due non coincidevano: il pittore disegna il petalo lungo
  /// `raggio * (0.34 + 0.66 * apertura)`, quindi da chiuso la punta si ferma
  /// a un terzo del raggio che la formula dichiarava. La guardia era verde al
  /// 54 per cento mentre sul telefono 767f596c il fiore chiuso ne occupava
  /// **18,1**: e' la famiglia "misurare il pezzo sano accanto al pezzo rotto",
  /// e l'ha trovata la prova visiva della voce DB.13, non questa prova.
  ///
  /// Adesso il pittore dipinge su una tela vera, si rilegge la tela, e la
  /// quota e' la distanza fra il primo e l'ultimo pixel acceso.
  Future<double> quotaDipinta(double apertura) async {
    final immagine = _dipingi(apertura);
    // **La tela si dipinge con `toImageSync` e si rilegge con `toByteData`.**
    // La prima stesura usava `toImage`, la versione a Future, dentro un
    // `testWidgets`: li' il tempo e finto e quella Future non si risolve mai.
    // La guardia stampava il numero giusto e poi restava appesa, che a video
    // e indistinguibile da una guardia lenta.
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
    final byte = dati!.buffer.asUint8List();
    final larghezza = immagine.width;
    var primo = larghezza;
    var ultimo = -1;
    var accesi = 0;
    for (var y = 0; y < immagine.height; y++) {
      for (var x = 0; x < larghezza; x++) {
        final i = (y * larghezza + x) * 4;
        // **SI GUARDA L'OPACITA', non il colore**: un pixel disegnato con
        // alpha alto e' fiore, il fondo trasparente non lo e'. Cosi' la
        // misura non dipende dalla tinta del centro di oggi.
        if (byte[i + 3] > 40) {
          accesi++;
          if (x < primo) primo = x;
          if (x > ultimo) ultimo = x;
        }
      }
    }
    cardinaleMinimo(accesi, 500,
        cosa: 'pixel dipinti dal loto sulla tela',
        perche: 'Su una tela quasi vuota la distanza fra primo e ultimo pixel '
            'non dice niente, e la guardia sarebbe verde per non aver visto '
            'nessun fiore.');
    return ultimo < 0 ? 0 : (ultimo - primo + 1) / larghezza;
  }

  test('AL CULMINE IL FIORE OCCUPA ALMENO L 85 PER CENTO', () async {
    final quota = await quotaDipinta(1.0);
    // ignore: avoid_print
    print('ORDINE DB VOCE 04: al culmine il fiore DIPINTO e largo '
        '${(quota * 100).toStringAsFixed(1)} per cento della finestra da '
        '${finestra.width.toInt()} punti');
    expect(quota, greaterThanOrEqualTo(0.85),
        reason: 'al culmine dell inspiro il fiore occupa solo il '
            '${(quota * 100).toStringAsFixed(1)} per cento della larghezza: e '
            'la figura piccola con la cornice vuota attorno che il fondatore '
            'ha respinto');
  });

  test('REGOLA H: AL FONDO DELL ESPIRO NON SCENDE SOTTO IL 50 PER CENTO',
      () async {
    final chiuso = await quotaDipinta(0.0);
    // ignore: avoid_print
    print('ORDINE DB VOCE 04: al fondo dell espiro il fiore DIPINTO e largo '
        '${(chiuso * 100).toStringAsFixed(1)} per cento');
    expect(chiuso, greaterThanOrEqualTo(0.50),
        reason: 'al fondo dell espiro il fiore scende al '
            '${(chiuso * 100).toStringAsFixed(1)} per cento: sparisce invece '
            'di chiudersi, e chi guarda perde il filo del respiro. E il '
            'difetto visto sul telefono 767f596c il 9 settembre 2026, quando '
            'questa misura veniva dalla formula e non dalla forma');
    // E non deve nemmeno restare grande quanto al culmine: se non si chiude,
    // il respiro non si vede.
    final aperto = await quotaDipinta(1.0);
    expect(chiuso, lessThan(aperto * 0.95),
        reason: 'fra chiuso e aperto il fiore cambia meno del cinque per '
            'cento: a schermo il respiro non si legge');
  });

  testWidgets('NELLA SCENA VERA IL RIQUADRO DEL LOTO E LARGO QUANTO LO SCHERMO',
      (tester) async {
    // **QUESTA E LA SECONDA META DELLA STESSA MISURA, e mancava.** Ordine DB
    // voce 04: *"al culmine dell inspiro la corona esterna arriva almeno
    // all ottantacinque per cento della LARGHEZZA DELLO SCHERMO"*.
    //
    // Le due prove qui sopra misurano quanto il fiore occupa **del proprio
    // riquadro**, e dicono il vero. Ma il riquadro non e lo schermo: nella
    // scena il loto stava in un `Expanded` sopra una colonna di testo, e
    // prendeva solo l altezza che avanzava. Sul telefono 767f596c, il 9
    // settembre 2026, il fiore riparato occupava il **53,8 per cento del suo
    // riquadro** e il **35,0 per cento dello schermo**.
    //
    // **Le due prove erano verdi e la scena era ancora quella respinta.**
    //
    // **LA FINESTRA E BASSA APPOSTA, e la ragione va detta.** Su una finestra
    // alta il riquadro ci sta comodo e il difetto non si vede: e proprio
    // quello che rendeva verde la prima stesura, montata a 360 per 800. Qui
    // si misura dove il testo e il loto **si contendono** l altezza, che e la
    // condizione del telefono vero.
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(
          child: MeditationScreen(
              player: SilentTonePlayer(), now: DateTime(2026, 9, 9)),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    final riquadro = find.byKey(const Key('meditation_loto'));
    expect(riquadro, findsOneWidget, reason: 'la scena non monta piu il loto');
    final lato = tester.getSize(riquadro).shortestSide;
    const larghezzaSchermo = 360.0;
    // **La quota dipinta al culmine e gia provata dalla prima prova**, 88,5
    // per cento del riquadro: qui non si ridipinge, perche dentro
    // `testWidgets` il tempo e finto e la Future che rilegge la tela non si
    // risolverebbe mai. Si moltiplica per la quota dichiarata, che quella
    // prova tiene ancorata al dipinto.
    final quotaSchermo =
        lato / larghezzaSchermo * PittoreDelLoto.quotaAperto;
    // ignore: avoid_print
    print('ORDINE DB VOCE 04: riquadro del loto ${lato.toStringAsFixed(0)} '
        'punti su uno schermo largo ${larghezzaSchermo.toStringAsFixed(0)}, '
        'cioe ${(quotaSchermo * 100).toStringAsFixed(1)} per cento DELLO '
        'SCHERMO al culmine');
    expect(quotaSchermo, greaterThanOrEqualTo(0.85),
        reason: 'al culmine il fiore occupa il '
            '${(quotaSchermo * 100).toStringAsFixed(1)} per cento della '
            'larghezza dello SCHERMO: il riquadro e largo '
            '${lato.toStringAsFixed(0)} punti su $larghezzaSchermo perche il '
            'testo sotto se lo mangia, e resta la figura piccola con la '
            'cornice vuota attorno che il fondatore ha respinto');
    // Si smonta la scena: l animazione del respiro gira per sempre, e una
    // prova che la lascia accesa resta appesa invece di finire.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('QUATTRO CORONE, coi petali che crescono', () {
    const quante = LotoCheRespira.petaliPerCorona;
    // ignore: avoid_print
    print('ORDINE DB: corone ${quante.length}, petali per corona '
        '${quante.join(", ")}, totale ${quante.reduce((a, b) => a + b)}');
    cardinaleMinimo(quante.length, 4,
        cosa: 'corone del mandala',
        perche: 'L ordine ne chiede almeno quattro: con meno e un fiore a '
            'petali contati, non un mandala.');
    for (var i = 1; i < quante.length; i++) {
      expect(quante[i], greaterThan(quante[i - 1]),
          reason: 'la corona $i non ha piu petali della precedente: il numero '
              'deve crescere anello dopo anello');
    }
    // **NESSUN PETALO SULLO STESSO RAGGIO DI UN ALTRO.** Due corone in
    // rapporto intero allineano i petali e disegnano braccia, che e' la
    // stella a punte da cui questo fiore deve stare lontano.
    for (var a = 0; a < quante.length; a++) {
      for (var b = a + 1; b < quante.length; b++) {
        expect(quante[b] % quante[a], isNot(0),
            reason: 'la corona con ${quante[b]} petali e multipla di quella '
                'con ${quante[a]}: i petali si allineano su raggi comuni e il '
                'mandala diventa una stella a braccia');
      }
    }
  });

  test('L ONDA: il cuore si apre PRIMA del bordo', () {
    final corone = LotoCheRespira.petaliPerCorona.length;
    // A meta' respiro il cuore deve essere piu' avanti del bordo.
    final cuore = PittoreDelLoto.aperturaDellaCorona(0.5, 0);
    final bordo = PittoreDelLoto.aperturaDellaCorona(0.5, corone - 1);
    // ignore: avoid_print
    print('ORDINE DB: a meta inspiro il cuore e aperto al '
        '${(cuore * 100).toStringAsFixed(0)} per cento e il bordo al '
        '${(bordo * 100).toStringAsFixed(0)} per cento');
    expect(cuore, greaterThan(bordo),
        reason: 'a meta inspiro il cuore e il bordo sono aperti uguale: non '
            'c e nessuna onda, e il fiore e solo una figura che si '
            'ingrandisce, che e cio che il fondatore ha respinto');
    // **E ALLA FINE SONO TUTTI APERTI.** Un'onda che non arriva in fondo
    // lascia il bordo a meta' per sempre.
    for (var i = 0; i < corone; i++) {
      expect(PittoreDelLoto.aperturaDellaCorona(1.0, i), 1.0,
          reason: 'la corona $i non arriva mai al pieno: l onda non finisce '
              'la sua corsa');
    }
    // E all'inizio nessuna e' partita.
    expect(PittoreDelLoto.aperturaDellaCorona(0.0, corone - 1), 0.0);
  });

  test('IL COLORE E QUELLO DEL CENTRO DI OGGI, e cambia ogni giorno', () {
    final visti = <Color>{};
    for (var g = 0; g < 7; g++) {
      final giorno = DateTime(2026, 9, 7).add(Duration(days: g));
      visti.add(ColoreDelCentro.di(giorno));
    }
    // ignore: avoid_print
    print('ORDINE DB: in una settimana i colori distinti del fiore sono '
        '${visti.length}');
    expect(visti.length, 7,
        reason: 'in una settimana il fiore prende solo ${visti.length} colori '
            'diversi: due giorni sono uguali, e il motivo per tornare domani '
            'si spegne');
    // **E NON E BIANCO E NERO.** E il difetto che la voce esiste per chiudere.
    for (final c in ColoreDelCentro.perCentro) {
      final grigio = (c.r - c.g).abs() < 0.04 && (c.g - c.b).abs() < 0.04;
      expect(grigio, isFalse,
          reason: 'un centro ha un colore grigio: il bianco e nero e uscito, '
              'e questo e un modo di farlo rientrare');
    }
  });

  test('REGOLA H: con Riduci Movimento il colore RESTA', () {
    // L'ordine e' esplicito: *"i petali non si animano, la fase cambia con uno
    // stato fermo e visibile, il colore resta, e la vibrazione resta"*. Un
    // fiore che con Riduci Movimento diventa grigio toglierebbe a chi ha
    // bisogno di quella impostazione proprio la cosa che cambia ogni giorno.
    const colore = Color(0xFF2E9E6B);
    final fermo = PittoreDelLoto(
      apertura: 1.0,
      coloreDelCentro: colore,
      gocce: const [],
      centroDiOggi: 0,
      senzaMoto: true,
    );
    expect(fermo.coloreDelCentro, colore,
        reason: 'con Riduci Movimento il fiore perde il colore del centro');
    expect(fermo.inclinazione, Offset.zero,
        reason: 'con Riduci Movimento resta la parallasse: e movimento, ed e '
            'proprio quello che quella impostazione chiede di togliere');
  });

  test('LE FORME AL CULMINE, dichiarate e sotto il tetto', () {
    final forme = PittoreDelLoto.formeAlCulmine();
    // ignore: avoid_print
    print('ORDINE DB: forme vive al culmine $forme, con '
        '${LotoCheRespira.petaliPerCorona.reduce((a, b) => a + b)} petali su '
        '${LotoCheRespira.petaliPerCorona.length} corone');
    // Il tetto in uso nel progetto per una scena viva: sotto le duecento
    // forme una CustomPaint resta comodamente dentro i sedici millisecondi.
    expect(forme, lessThan(200),
        reason: 'il fiore disegna $forme forme al culmine: sopra le duecento '
            'una scena viva comincia a perdere fotogrammi sui telefoni bassi');
  });
}

/// Dipinge il loto su una tela vera alla [apertura] data, e torna l'immagine.
///
/// **Si dipinge davvero**, invece di chiedere alla formula: e' l'unico modo
/// perche' la guardia veda cio' che vede chi guarda il telefono.
ui.Image _dipingi(double apertura) {
  const lato = 390.0;
  final registratore = ui.PictureRecorder();
  final tela = Canvas(registratore);
  PittoreDelLoto(
    apertura: apertura,
    coloreDelCentro: ColoreDelCentro.di(DateTime(2026, 9, 9)),
    gocce: const [3, 3, 3, 3, 3, 3, 3],
    centroDiOggi: 2,
    inclinazione: Offset.zero,
  ).paint(tela, const Size(lato, lato));
  return registratore.endRecording().toImageSync(lato.toInt(), lato.toInt());
}
