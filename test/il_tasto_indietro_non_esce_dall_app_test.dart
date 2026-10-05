import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/account/account_screen.dart';
import 'package:esoteric_circle/features/calendario/calendario_degli_eventi_screen.dart';
import 'package:esoteric_circle/features/settings/settings_screen.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/features/shell/il_tasto_indietro_della_home.dart';
import 'package:esoteric_circle/features/shell/navigation_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// IL TASTO INDIETRO NON ESCE MAI DALL'APP. Ordine FD voce 04.
///
/// **Il difetto.** Nel giro sul Realme dell'ordine FC quattro pressioni del
/// tasto indietro, partite dall'oroscopo di un'amica, hanno portato fuori
/// dall'app: la pila delle rotte era giusta, ma la home, la rotta 0, non
/// aveva nessun `PopScope`, e Android chiudeva l'attivita' al primo tocco.
///
/// **Cosa si prova, col tasto vero.** Il gesto arriva come `popRoute` sul
/// canale `flutter/navigation`, cioe' come lo manda Android, e l'uscita si
/// conta intercettando `SystemNavigator.pop` sul canale della piattaforma.
/// a) da ogni rotta spinta il tasto torna alla precedente, fino alla home,
///    senza mai uscire; dal Passport torna al Cerchio;
/// b) sulla home un tocco non esce e mostra l'avviso, due tocchi entro due
///    secondi escono, un secondo tocco dopo due secondi riaccende l'avviso;
/// c) la guardia: in `lib` chiude l'app un punto solo, e ogni `PopScope` che
///    trattiene il tasto e' dichiarato con cio' che fa.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  var uscite = 0;
  var ora = DateTime(2026, 10, 5, 10);

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
    m.setMockMethodCallHandler(SystemChannels.platform, (c) async {
      if (c.method == 'SystemNavigator.pop') uscite++;
      return null;
    });
  }

  Future<void> passi(WidgetTester tester, [int n = 6]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> apri(WidgetTester tester) async {
    uscite = 0;
    ora = DateTime(2026, 10, 5, 10);
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(EsotericCircleApp(
        conIntro: false, services: AppServices.offline(), clock: () => ora));
    await passi(tester, 8);
  }

  Future<void> indietro(WidgetTester tester) async {
    await binding.defaultBinaryMessenger.handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
      (_) {},
    );
    await passi(tester);
  }

  final avviso = find.text(IlTastoIndietroDellaHome.avviso);

  testWidgets('a) da ogni rotta spinta il tasto torna alla precedente',
      (tester) async {
    await apri(tester);
    final pila = tester.state<NavigatorState>(find.byType(Navigator).first);
    // Tre rotte vere, una sopra l'altra, come le spinge l'app.
    pila.push(AccountScreen.route());
    await passi(tester);
    pila.push(SettingsScreen.route());
    await passi(tester);
    pila.push(CalendarioDegliEventiScreen.route(adesso: ora));
    await passi(tester, 10);
    expect(find.byType(CalendarioDegliEventiScreen), findsOneWidget);

    await indietro(tester);
    expect(find.byType(CalendarioDegliEventiScreen), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget,
        reason: 'dal Calendario il tasto non e\' tornato alle impostazioni');
    await indietro(tester);
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(AccountScreen), findsOneWidget,
        reason: 'dalle impostazioni il tasto non e\' tornato all\'account');
    await indietro(tester);
    expect(find.byType(AccountScreen), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
    expect(uscite, 0, reason: 'una rotta interna ha chiuso l\'app');
    expect(avviso, findsNothing,
        reason: 'tornare alla home non e\' un tocco sulla home');
  });

  testWidgets('a) dal Passport il tasto torna al Cerchio e non esce',
      (tester) async {
    await apri(tester);
    final nav = Provider.of<NavigationController>(
        tester.element(find.byType(AppShell)),
        listen: false);
    nav.goToPassport();
    await passi(tester);
    expect(nav.view, ShellView.passport);

    await indietro(tester);
    expect(nav.view, ShellView.santuario,
        reason: 'dal Passport il tasto non e\' tornato al Cerchio');
    expect(uscite, 0, reason: 'dal Passport il tasto ha chiuso l\'app');
    expect(avviso, findsNothing);
  });

  testWidgets('b) sulla home un tocco avvisa, due entro due secondi escono',
      (tester) async {
    await apri(tester);

    await indietro(tester);
    expect(uscite, 0, reason: 'il primo tocco sulla home ha chiuso l\'app');
    expect(avviso, findsOneWidget, reason: 'il primo tocco non ha avvisato');
    // Fuori da un Material il testo prende la sottolineatura gialla di
    // debug: l'ha mostrata l'anteprima dell'ordine FD.
    expect(find.ancestor(of: avviso, matching: find.byType(Material)),
        findsWidgets,
        reason: 'l\'avviso sta fuori da un Material: sottolineatura gialla');

    ora = ora.add(const Duration(milliseconds: 1500));
    await indietro(tester);
    expect(uscite, 1, reason: 'il secondo tocco entro due secondi non esce');
    await tester.pump(IlTastoIndietroDellaHome.finestra);
  });

  testWidgets('b) l\'avviso dura due secondi, e dopo si ricomincia',
      (tester) async {
    await apri(tester);

    await indietro(tester);
    expect(avviso, findsOneWidget);
    // `indietro` ha gia' fatto scorrere 720 millisecondi: a 1,9 secondi
    // l'avviso c'e' ancora, a 2,3 non c'e' piu'.
    await tester.pump(const Duration(milliseconds: 1180));
    expect(avviso, findsOneWidget, reason: 'l\'avviso e\' sparito prima');
    await tester.pump(const Duration(milliseconds: 400));
    await passi(tester, 3);
    expect(avviso, findsNothing, reason: 'l\'avviso resta oltre i due secondi');

    ora = ora.add(const Duration(milliseconds: 2500));
    await indietro(tester);
    expect(uscite, 0,
        reason: 'un secondo tocco dopo due secondi ha chiuso l\'app');
    expect(avviso, findsOneWidget,
        reason: 'dopo due secondi il tocco non ha riacceso l\'avviso');
    await tester.pump(IlTastoIndietroDellaHome.finestra);
  });

  // c) LA GUARDIA. Due regole sui sorgenti di `lib`, coi commenti tolti.
  test('c) in lib chiude l\'app un punto solo, e ogni PopScope e\' dichiarato',
      () {
    const laPortaDellUscita =
        'lib/features/shell/il_tasto_indietro_della_home.dart';
    // Ogni modo di chiudere l'app o di svuotare la pila sotto la home.
    final uscita = RegExp(r'SystemNavigator\.pop|\bexit\(|moveTaskToBack|'
        r'pushAndRemoveUntil|popUntil\(\s*\(_\)\s*=>\s*false');
    // I `PopScope` che trattengono il tasto, ciascuno con cio' che fa.
    const dichiarati = {
      'lib/features/shell/il_tasto_indietro_della_home.dart':
          'la home: Passport al Cerchio, poi il doppio tocco',
      'lib/features/onboarding/onboarding_screen.dart':
          'il rito: torna di un passo, al primo passo non fa niente',
      'lib/features/onboarding/risveglio_journey.dart':
          'il Risveglio: torna di una fase',
      'lib/core/permissions/app_permission.dart':
          'un dialogo, non una schermata',
    };

    final fuori = <String>[];
    final scope = <String>[];
    var file = 0;
    for (final f in righeDiLib()) {
      file++;
      final testo = senzaCommenti(f.righe.join('\n'));
      final righe = testo.split('\n');
      for (var i = 0; i < righe.length; i++) {
        if (uscita.hasMatch(righe[i]) && f.percorso != laPortaDellUscita) {
          fuori.add('${f.percorso}:${i + 1}: ${righe[i].trim()}');
        }
        if (righe[i].contains('PopScope(')) scope.add(f.percorso);
      }
    }
    cardinaleMinimo(file, quantiFileHaLib, cosa: 'file di lib');
    cardinaleMinimo(scope.length, dichiarati.length,
        cosa: 'PopScope in lib',
        perche: 'I quattro dichiarati sono stati tolti o rinominati.');

    expect(fuori, isEmpty,
        reason: 'Fuori dal tasto indietro della home qualcosa chiude l\'app o '
            'svuota la pila sotto la home:\n${fuori.join('\n')}');
    final ignoti = scope.where((p) => !dichiarati.containsKey(p)).toList();
    expect(ignoti, isEmpty,
        reason: 'Un PopScope nuovo trattiene il tasto indietro senza essere '
            'dichiarato qui con cio\' che fa: ${ignoti.join(', ')}');

    // La home deve essere avvolta, e la porta deve davvero uscire.
    final guscio = File('lib/features/shell/app_shell.dart').readAsStringSync();
    expect(guscio.contains('return IlTastoIndietroDellaHome('), isTrue,
        reason: 'la home non e\' piu\' avvolta dal tasto indietro');
    final porta = senzaCommenti(File(laPortaDellUscita).readAsStringSync());
    expect('SystemNavigator.pop()'.allMatches(porta).length, 1);
    expect(porta.contains('canPop: false'), isTrue);
  });
}
