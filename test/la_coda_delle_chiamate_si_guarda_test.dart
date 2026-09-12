import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/notifiche_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA CODA DELLE CHIAMATE SI GUARDA, invece di supporla. Ordine CF voce 04,
/// parte uno.
///
/// **Il fatto del fondatore, verbatim**: "da quando ho iniziato a installare
/// le varie build dell'APP NON HO MAI RICEVUTO ALCUNA NOTIFICA PUSH PER I
/// DONI, MAI!"
///
/// **Il fatto contraddice una voce data per chiusa**: l'ordine BZ voce 04
/// dichiarava il difetto curato, con la misura "cinque chiamate su cinque in
/// coda con la cura, zero senza". Sul suo RMX5056 con Android 16 la cura non
/// regge.
///
/// **Da fuori due difetti diversi si vedono uguali**: il Cerchio che non
/// programma niente, e il telefono che non esegue cio' che ha in coda. Il
/// secondo e' una causa nota sui telefoni che addormentano le chiamate
/// approssimate per risparmiare batteria. **Senza un modo di guardare, la
/// diagnosi sarebbe una supposizione**, e questa voce costruisce il modo di
/// guardare invece di indovinare.
class _TelefonoCheDice extends ServizioAvvisi {
  _TelefonoCheDice({this.coda = const []});

  /// Cio' che il telefono dichiara di avere in coda.
  final List<int> coda;

  /// I titoli suonati subito: e' la prova del canale.
  final List<String> suonateSubito = <String>[];

  @override
  bool get disponibile => true;
  @override
  Future<bool> chiediPermesso() async => true;
  @override
  Future<bool> permessoConcesso() async => true;
  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async {}
  @override
  Future<void> annulla(int id) async {}
  @override
  Future<List<int>> inAttesa() async => coda;
  @override
  Future<void> mostraAdesso({
    required String titolo,
    required String testo,
  }) async {
    suonateSubito.add(titolo);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> apri(WidgetTester tester, _TelefonoCheDice telefono) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider<SceltaDegliAvvisi>(
            create: (_) => SceltaDegliAvvisi()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: NotificheScreen(avvisi: telefono),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    // **IL BLOCCO STA IN FONDO, e ci si scorre. Ordine CF voce 04.**
    // Sta dopo i cinque Doni di proposito: le scelte vengono prima, lo
    // strumento di misura dopo. Una prova che non scorresse misurerebbe
    // uno schermo dove il blocco non c'e' ancora.
    await tester.scrollUntilVisible(
      find.byKey(const Key('notifiche_coda_detto')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));
  }

  String detto(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('notifiche_coda_detto'))).data!;

  testWidgets('col telefono che ha cinque chiamate in coda, lo dice',
      (tester) async {
    final telefono = _TelefonoCheDice(coda: const [1, 2, 3, 4, 5]);
    await apri(tester, telefono);
    // ignore: avoid_print
    print('ORDINE CF VOCE 04: prima di guardare, la riga dice '
        '"${detto(tester)}"');
    expect(detto(tester).contains('ancora'), isTrue,
        reason: 'la schermata dichiara una coda che non ha ancora guardato');
    await tester.tap(find.byKey(const Key('notifiche_guarda_la_coda')));
    await tester.pump(const Duration(milliseconds: 300));
    // ignore: avoid_print
    print('ORDINE CF VOCE 04: dopo aver guardato, la riga dice '
        '"${detto(tester)}"');
    expect(detto(tester).contains('5'), isTrue,
        reason: 'il telefono ha cinque chiamate in coda e la schermata non lo '
            'dice: senza questo numero non si distingue il Cerchio che non '
            'programma dal telefono che non esegue');
  });

  testWidgets(
      'col telefono che non ha niente in coda, lo dice e dice cosa fare',
      (tester) async {
    final telefono = _TelefonoCheDice();
    await apri(tester, telefono);
    await tester.tap(find.byKey(const Key('notifiche_guarda_la_coda')));
    await tester.pump(const Duration(milliseconds: 300));
    // ignore: avoid_print
    print('ORDINE CF VOCE 04: a coda vuota la riga dice "${detto(tester)}"');
    expect(detto(tester).contains('Nessuna'), isTrue,
        reason: 'a coda vuota la schermata non lo dichiara');
    expect(detto(tester).contains('accendi'), isTrue,
        reason: 'a coda vuota la schermata dice il fatto e non la via: un '
            'vicolo cieco, che in questo progetto non si lascia mai');
  });

  testWidgets('la prova immediata passa dal canale vero', (tester) async {
    final telefono = _TelefonoCheDice();
    await apri(tester, telefono);
    await tester.tap(find.byKey(const Key('notifiche_prova_adesso')));
    await tester.pump(const Duration(milliseconds: 300));
    // ignore: avoid_print
    print('ORDINE CF VOCE 04: suonate subito ${telefono.suonateSubito}');
    expect(telefono.suonateSubito, hasLength(1),
        reason: 'il tocco non manda nessun avviso immediato: senza, non c\'e\' '
            'modo di sapere se il canale funziona');
    expect(find.byKey(const Key('notifiche_esito_prova')), findsOneWidget,
        reason: 'l\'avviso parte e la schermata non dice niente: chi non lo '
            'riceve non sa se e\' partito');
  });
}
