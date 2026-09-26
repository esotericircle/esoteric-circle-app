import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'sorgenti_di_lib.dart';

/// **IL CUORICINO E' UNO SOLO, A SCHERMO.** Ordine DD voce 07, 10 settembre
/// 2026.
///
/// **Il fatto del fondatore**: nell'Oroscopo si vedono **due cuoricini**.
///
/// **REGOLA C, il padre del difetto: ordine DC voce 15, 10 settembre 2026**,
/// ed e' mio, del giorno prima. Quella voce curava la "i" del tooltip che
/// finiva sotto il cuore sovrapposto, e la cura fu mettere il cuore dentro
/// [AngoloDellaBarra], che sedici schermate montano gia'. Il commento che
/// scrissi allora diceva: *"il difetto si chiude in un punto solo e non puo'
/// tornare in una quarta schermata"*.
///
/// **Quel ragionamento aveva un buco, e questa guardia esiste per quello.**
/// [AngoloDellaBarra] e' diventato un cuore, ma **non ha smesso di essere
/// montato dalle schermate che gia' hanno un cuore per un'altra via**: chi
/// passa dalla [BarraArte] comune ne riceve uno dentro `actions`, e se poi
/// monta anche l'angolo ne ha due. Il cuore era stato dato a un posto, non
/// tolto agli altri.
///
/// **PERCHE' QUESTA GUARDIA MONTA LA SCHERMATA VERA.** Esiste gia'
/// `il_cuore_sta_sempre_nello_stesso_angolo_test.dart`, ed e' **rimasta verde
/// tutto il tempo**: legge il testo dei sorgenti e verifica che il cuore sia
/// dichiarato nel posto giusto. Era vero. **Due cuori dichiarati bene in due
/// posti giusti fanno due cuori a schermo**, e nessuna lettura di sorgenti
/// puo' accorgersene. Qui si contano i [CuorePreferita] montati davvero.
///
/// **REGOLA H, e sono due meta'.** Non basta provare che il cuore c'e': si
/// prova che ce n'e' **esattamente uno**, e lo si prova **prima e dopo aver
/// chiesto il responso**, perche' il difetto poteva anche essere un secondo
/// cuore che compare quando la schermata si ricompone.
void main() {
  /// La rotta vera di un'arte: [SogliaArte] con dentro la schermata, che e'
  /// come l'app la apre. Montare la schermata nuda non mostrerebbe **nessun**
  /// cuore, e la prova sarebbe verde per non aver guardato niente.
  Future<void> apriUnArte(
    WidgetTester tester, {
    required String id,
    required Maestro maestro,
    required Widget schermata,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        // **SENZA QUESTO IL CUORE NON SI DISEGNA AFFATTO**: CuorePreferita
        // torna vuoto quando il controller non c'e', e la prova conterebbe
        // zero cuori dichiarando che non ce ne sono due.
        ChangeNotifierProvider(
            create: (_) => ArtiPreferiteController(maestroAssegnato: maestro)),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: SogliaArte(id: id, maestro: maestro, child: schermata),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  int quantiCuori(WidgetTester tester) =>
      tester.widgetList(find.byType(CuorePreferita)).length;

  testWidgets('L OROSCOPO PORTA UN CUORE SOLO, PRIMA E DOPO IL RESPONSO',
      (tester) async {
    await apriUnArte(
      tester,
      id: 'horoscope',
      maestro: Maestro.medora,
      schermata:
          OroscopoScreen(userSign: Zodiac.leo, now: DateTime(2026, 7, 10)),
    );

    final prima = quantiCuori(tester);
    // ignore: avoid_print
    print('ORDINE DD VOCE 07: oroscopo appena aperto, cuoricini a schermo '
        '$prima');
    expect(prima, 1,
        reason: 'appena aperto l oroscopo mostra $prima cuoricini invece di '
            'uno: sono due segni identici nello stesso angolo, e chi guarda '
            'non sa quale premere');

    // **E ADESSO SI CHIEDE IL RESPONSO**, che e il gesto con cui questa
    // schermata si ricompone da cima a fondo.
    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    // I due momenti della riflessione, poi la dissolvenza della corsa: si
    // pompa finche ogni tempo di questa schermata e finito, o la prova cade
    // con un timer ancora in volo invece che sul conto dei cuori.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 5));

    final dopo = quantiCuori(tester);
    // ignore: avoid_print
    print('ORDINE DD VOCE 07: oroscopo dopo il responso, cuoricini a schermo '
        '$dopo');
    expect(dopo, 1,
        reason: 'dopo il responso l oroscopo mostra $dopo cuoricini invece di '
            'uno: il secondo nasce quando la schermata si ricompone');
  });

  testWidgets('LA STESA DI TAROCCHI PORTA UN CUORE SOLO', (tester) async {
    // **LA STESSA PROVA GIRA SU UN ALTRA SCHERMATA COL CUORE**, come l ordine
    // chiede: un difetto che sta nel meccanismo comune non si prova su una
    // schermata sola, o si cura dove si e guardato e resta dove non si e
    // guardato. Questa e la seconda delle tre che l ordine DC voce 15 tocco.
    await apriUnArte(
      tester,
      id: 'tarot',
      maestro: Maestro.medora,
      schermata: const StesaTreCarteScreen(),
    );
    final quanti = quantiCuori(tester);
    // ignore: avoid_print
    print('ORDINE DD VOCE 07: stesa di tarocchi, cuoricini a schermo $quanti');
    expect(quanti, 1,
        reason: 'la stesa di tarocchi mostra $quanti cuoricini invece di uno');
  });

  testWidgets('IL CUORE NON SI SDOPPIA QUANDO LA SCHERMATA SI RICOMPONE',
      (tester) async {
    // **QUESTA E LA PROVA CHE RIPRODUCE IL FATTO DEL FONDATORE**, e le due
    // sopra da sole non ci riuscivano.
    //
    // **Cosa si vede sul telefono 767f596c.** Aperto l oroscopo: **un cuore**.
    // Premuto INTERROGA IL CIELO: **due cuori**, affiancati e sovrapposti in
    // alto a destra, e restano li. Le due fotografie stanno in
    // `dd07_oroscopo_prima.png` e `dd07_oroscopo_dopo.png`.
    //
    // **LA CAUSA, e non e dove sembrava.** `SogliaArte.build` costruisce il
    // `ValueNotifier` del reclamo **dentro build**:
    //
    //     ArteCorrente(id: ..., reclamato: ValueNotifier<bool>(false), ...)
    //
    // Ogni ricomposizione di un antenato ne fabbrica **uno nuovo, a false**.
    // Il cuore sovrapposto guarda quello e torna a disegnarsi; il cuore della
    // barra rialza il reclamo, ma **solo nel giro dopo la fine del
    // fotogramma**. Il fotogramma in mezzo viene disegnato con due cuori, e
    // se le ricomposizioni si susseguono quel fotogramma e' quello che si
    // guarda.
    //
    // **Percio questa prova conta i cuori nel fotogramma della
    // ricomposizione**, non dopo che tutto si e' assestato: e' quel
    // fotogramma che finisce negli occhi.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    late void Function(void Function()) ricomponi;
    var giro = 0;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(
            create: (_) =>
                ArtiPreferiteController(maestroAssegnato: Maestro.medora)),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: StatefulBuilder(builder: (context, setState) {
          ricomponi = setState;
          return SogliaArte(
            id: 'horoscope',
            maestro: Maestro.medora,
            // Una barra qualunque col cuore, che e' quello che ogni arte ha:
            // qui non serve l oroscopo intero, serve la coppia barra piu'
            // scena che tutte e sedici le schermate montano.
            child: Scaffold(
              appBar: AppBar(
                title: Text('giro $giro'),
                actions: const [AngoloDellaBarra()],
              ),
              body: const SizedBox.expand(),
            ),
          );
        }),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final prima = quantiCuori(tester);
    // ignore: avoid_print
    print('ORDINE DD VOCE 07: prima della ricomposizione, cuoricini $prima');
    expect(prima, 1,
        reason: 'gia a riposo i cuoricini sono $prima invece di uno');

    // **E ADESSO UN ANTENATO SI RICOMPONE**, che e cio che succede quando la
    // schermata riceve il responso.
    ricomponi(() => giro++);
    await tester.pump();

    final durante = quantiCuori(tester);
    // ignore: avoid_print
    print('ORDINE DD VOCE 07: nel fotogramma della ricomposizione, cuoricini '
        '$durante');
    expect(durante, 1,
        reason: 'nel fotogramma in cui la schermata si ricompone i cuoricini '
            'sono $durante invece di uno: il reclamo del cuore della barra e '
            'stato buttato via insieme al ValueNotifier costruito dentro '
            'build, e il cuore sovrapposto e tornato a disegnarsi');

    // **E NON BASTA CHE SI RIASSESTI DOPO**: si guarda anche il fotogramma
    // successivo, perche una schermata che alterna uno e due cuori a ogni
    // ricomposizione sfarfalla, e sul telefono i due si vedono fermi.
    await tester.pump(const Duration(milliseconds: 600));
    final dopo = quantiCuori(tester);
    // ignore: avoid_print
    print('ORDINE DD VOCE 07: assestato dopo la ricomposizione, cuoricini '
        '$dopo');
    expect(dopo, 1,
        reason: 'dopo la ricomposizione restano $dopo cuoricini');
  });

  test('REGOLA H: NESSUNA SCHERMATA DICHIARA IL CUORE DUE VOLTE', () {
    // **LA META CHE GUARDA LA CAUSA, non l esito.** Le due prove sopra
    // contano cio che si vede in due schermate; questa conta le
    // **dichiarazioni** in tutte quante, cosi una diciassettesima schermata
    // che nasce domani col difetto cade qui invece che sul telefono del
    // fondatore.
    //
    // La regola: **una schermata che passa dalla BarraArte comune non deve
    // montare anche l AngoloDellaBarra**, perche il cuore la barra glielo da
    // gia dentro `actions`.
    final sorgenti = sorgentiDiLib();
    final doppie = <String>[];
    for (final f in sorgenti) {
      final codice = f.readAsStringSync();
      // Il file che DEFINISCE i due widget non conta: li dichiara, non li
      // monta.
      if (codice.contains('class AngoloDellaBarra')) continue;
      final usaLaBarra = codice.contains('BarraArte(');
      final usaLAngolo = codice.contains('AngoloDellaBarra(');
      if (usaLaBarra && usaLAngolo) doppie.add(f.path.split('lib').last);
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 07: file di lib guardati ${sorgenti.length}, '
        'schermate che dichiarano il cuore due volte ${doppie.length}');
    expect(doppie, isEmpty,
        reason: 'queste schermate prendono il cuore dalla BarraArte E montano '
            'anche AngoloDellaBarra, quindi ne mostrano due: '
            '${doppie.join(" | ")}');
  });
}
