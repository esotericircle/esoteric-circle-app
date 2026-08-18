import 'dart:io';
import 'dart:ui';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/features/shell/barra_dell_identita.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA BARRA APERTA SI RITIRA DA SOLA. Ordine AO voce 02.
///
/// **Il difetto, dal collaudo della 2182.** La barra scendeva col tocco e
/// risaliva solo con un secondo tocco nello stesso punto. Chi la apriva per
/// leggere e poi tornava a fare altro se la ritrovava aperta addosso al
/// contenuto, e per chiuderla doveva ricordarsi di un gesto che non aveva
/// piu' niente a che fare con quello che stava facendo.
///
/// **LE QUATTRO VIE DEL RITIRO, enumerate.** Non sono quattro casi di
/// fantasia: sono i quattro modi in cui una persona smette di guardare la
/// barra.
///   1. SCORRE la schermata sotto: sta leggendo altro.
///   2. APRE UNA ROTTA: sta andando altrove.
///   3. TOCCA FUORI dalla barra: sta toccando un'altra cosa.
///   4. TORNA INDIETRO: la schermata di prima non e' quella che aveva aperto.
///
/// **La regola sta in UN punto solo**, ed e' la ventiduesima volta che questa
/// frase serve in questo progetto: se ogni schermata dovesse ricordarsi di
/// chiudere la barra, la barra resterebbe aperta esattamente nella schermata
/// che se ne dimentica. Il punto unico e' lo stato della barra stessa, che
/// ascolta cio' che succede sotto di se'.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  final barra = find.byKey(const Key('barra_dell_identita'));

  Future<void> apri(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> apriLaBarra(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('porta_dell_account')),
        warnIfMissed: false);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(tester.getRect(barra).height,
        greaterThan(BarraDellIdentita.altezzaChiusa + 20),
        reason: 'la barra non si e\' aperta: la prova non ha niente da '
            'misurare');
  }

  Future<void> assesta(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  void esigiRitirata(WidgetTester tester, String via) {
    final alta = tester.getRect(barra).height;
    // ignore: avoid_print
    print('ORDINE AO VOCE 02: dopo "$via" la barra e\' alta '
        '${alta.toStringAsFixed(1)}');
    expect(alta, lessThan(BarraDellIdentita.altezzaChiusa + 20),
        reason: 'dopo "$via" la barra e\' rimasta aperta a $alta punti: '
            'resta addosso al contenuto e per chiuderla serve un gesto che '
            'non c\'entra piu\' niente con quello che si sta facendo');
  }

  testWidgets('via 1: si ritira quando la schermata sotto scorre',
      (tester) async {
    await apri(tester);
    await apriLaBarra(tester);
    // Si scorre il corpo della home, sotto la barra.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -160));
    await assesta(tester);
    esigiRitirata(tester, 'scorrimento della schermata');
  });

  testWidgets('via 2: si ritira quando si apre una rotta', (tester) async {
    await apri(tester);
    await apriLaBarra(tester);
    // Si apre il Calendario dal centro della barra, che e' la rotta piu'
    // vicina: parte proprio da qui sopra.
    await tester.tap(find.byKey(const Key('barra_eventi_cosmici')),
        warnIfMissed: false);
    await assesta(tester);
    esigiRitirata(tester, 'apertura di una rotta');
  });

  testWidgets('via 3: si ritira al tocco fuori dalla barra', (tester) async {
    await apri(tester);
    // **SI SEGNA DOVE SI E', per nome della schermata.** Contare i widget
    // Navigator NON serve: una rotta nuova si apre DENTRO il Navigator che
    // c'e' gia', quindi il conteggio resta uguale mentre la scena cambia.
    // Si guarda la schermata in cima, che e' il dato con cui la barra stessa
    // decide.
    final schermate = find.byType(SantuarioScreen);
    expect(schermate, findsOneWidget,
        reason: 'la prova non parte dalla home');
    await apriLaBarra(tester);
    // **UN TOCCO SU UNA ZONA INERTE, e trovarla e' stato il lavoro.** Due
    // punti sono stati scartati misurando, non a occhio: quello in mezzo
    // allo schermo cadeva sul carosello dei Maestri e APRIVA IL DOMINIO,
    // quindi la barra si chiudeva per il cambio di schermata e questa prova
    // sarebbe stata verde senza provare niente; quello in basso a sinistra
    // cadeva dentro la barra di navigazione del Cerchio, che vive in un
    // altro ramo dell'albero e si prende il tocco prima che arrivi qui
    // sotto. Il corpo della home a meta' altezza e' fondo cosmico e non
    // porta da nessuna parte.
    await tester.tapAt(const Offset(8, 400));
    await assesta(tester);
    // **E SI CONTROLLA CHE IL TOCCO NON ABBIA NAVIGATO, altrimenti questa
    // prova sarebbe verde per la ragione sbagliata**: la barra si ritira gia'
    // quando cambia schermata, quindi un tocco che apre una rotta la
    // chiuderebbe comunque e la via 3 non proverebbe niente. Qui si pretende
    // di essere rimasti dove si era.
    expect(find.byType(SantuarioScreen), findsOneWidget,
        reason: 'il tocco ha portato via dalla home: sposta il punto, questa '
            'prova deve toccare una zona inerte');
    esigiRitirata(tester, 'tocco fuori dalla barra');
  });

  testWidgets('via 4: si ritira tornando indietro', (tester) async {
    await apri(tester);
    // Si va altrove, si apre la barra li', e si torna indietro.
    await tester.tap(find.byKey(const Key('barra_eventi_cosmici')),
        warnIfMissed: false);
    await assesta(tester);
    await apriLaBarra(tester);
    await tester.pageBack();
    await assesta(tester);
    esigiRitirata(tester, 'ritorno indietro');
  });

  testWidgets('il ritiro e\' morbido, e secco sotto Riduci Movimento',
      (tester) async {
    await apri(tester);
    await apriLaBarra(tester);
    await tester.tapAt(const Offset(8, 400));
    // UN SOLO fotogramma dopo il tocco: se il ritiro fosse istantaneo, la
    // barra sarebbe gia' bassa e il movimento non si vedrebbe.
    await tester.pump(const Duration(milliseconds: 16));
    final subito = tester.getRect(barra).height;
    await assesta(tester);
    final dopo = tester.getRect(barra).height;
    // ignore: avoid_print
    print('ORDINE AO VOCE 02: un fotogramma dopo ${subito.toStringAsFixed(1)}, '
        'a riposo ${dopo.toStringAsFixed(1)}');
    expect(subito, greaterThan(dopo),
        reason: 'il ritiro e\' uno scatto: la barra passa da aperta a chiusa '
            'senza attraversare le altezze in mezzo');
  });

  testWidgets('sotto Riduci Movimento il ritiro e\' secco', (tester) async {
    // **LA STESSA REGOLA DELL'APERTURA, e per la stessa ragione.** Chi ha
    // chiesto meno movimento non vuole vedere una fascia che scorre: vuole
    // che la cosa sia fatta. La barra legge `disableAnimations` dal
    // MediaQuery, ed e' il solo posto in cui questa scelta vive.
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 797);
    addTearDown(tester.view.reset);
    // Riduci Movimento acceso, come lo accende il sistema operativo: si
    // dichiara alla finestra, non all'app, cosi' l'app resta quella vera e
    // legge la scelta dalla stessa strada da cui la legge sul telefono.
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const _RiduciMovimentoAcceso();
    addTearDown(
        tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await apriLaBarra(tester);
    await tester.tapAt(const Offset(8, 400));
    // UN SOLO fotogramma: col passaggio secco la barra e' gia' a riposo.
    await tester.pump(const Duration(milliseconds: 16));
    final subito = tester.getRect(barra).height;
    // ignore: avoid_print
    print('ORDINE AO VOCE 02: con Riduci Movimento, un fotogramma dopo '
        '${subito.toStringAsFixed(1)}');
    expect(subito, closeTo(BarraDellIdentita.altezzaChiusa, 1),
        reason: 'con Riduci Movimento la barra sta ancora scorrendo a '
            '$subito punti: doveva essere gia\' a riposo');
  });

  test('la regola del ritiro sta in UN punto solo', () {
    // **L'ENUMERAZIONE, e guarda dalla parte giusta.** Non si conta quante
    // volte la barra si chiude: si conta chi altro, in tutta `lib`, sa che la
    // barra esiste e la comanda. Se una schermata cominciasse a chiuderla per
    // conto suo, la barra resterebbe aperta esattamente nella schermata che
    // se ne dimentica, ed e' la stessa ragione per cui la pillola e il volto
    // hanno una casa sola.
    final colpevoli = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll('\\', '/');
      if (percorso.endsWith('features/shell/barra_dell_identita.dart')) {
        continue;
      }
      final codice = f
          .readAsStringSync()
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (codice.contains('ritiraLaBarra') ||
          codice.contains('BarraDellIdentita.ritira')) {
        colpevoli.add(percorso);
      }
    }
    // ignore: avoid_print
    print('ORDINE AO VOCE 02: chi comanda il ritiro fuori dalla barra: '
        '$colpevoli');
    expect(colpevoli, isEmpty,
        reason: 'queste schermate chiudono la barra per conto loro, e la '
            'regola diventa una copia per schermata: $colpevoli');
  });
}

/// Riduci Movimento acceso, e nient'altro: il sistema operativo lo dice cosi'
/// e `MediaQuery.disableAnimations` lo legge da qui.
class _RiduciMovimentoAcceso implements AccessibilityFeatures {
  const _RiduciMovimentoAcceso();

  @override
  bool get accessibleNavigation => false;
  @override
  bool get boldText => false;
  @override
  bool get disableAnimations => true;
  @override
  bool get highContrast => false;
  @override
  bool get invertColors => false;
  @override
  bool get onOffSwitchLabels => false;
  @override
  bool get reduceMotion => true;
  @override
  bool get supportsAnnounce => false;
  @override
  bool get autoPlayAnimatedImages => false;
  @override
  bool get autoPlayVideos => false;
  @override
  bool get deterministicCursor => false;
}
