// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/calendario/calendario_degli_eventi_screen.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/features/shell/navigation_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/chi_e_online.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **"ONLINE" NELLA BARRA IN ALTO E I PROSSIMI EVENTI COSMICI NEL PASSPORT.
/// Ordine ES voce 15, 29 settembre 2026.**
///
/// Il fondatore: *"in alto nella barra superiore al centro bisogerà inserire
/// "online" con lucina verde e n. di utenti online al posto di Eventi cosmici
/// che andrà in Passport in alto come "Prossimi Eventi Cosmici""*.
///
/// **Lapide.** Le prove dell'ordine AO voce 01 e AN voce 02 pretendevano al
/// centro della barra la scritta "Eventi Cosmici" e il tocco che apre il
/// Calendario: difendevano la regola di prima, e sono state riscritte con la
/// loro lapide. Qui si pretende la regola nuova, e che la porta al
/// Calendario non si sia persa: e' salita in cima al Passport.
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

  Future<void> apri(WidgetTester tester, {PortaDelCerchio? porta}) async {
    silenzia();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'santuario.greeted': true,
      'cammino.accesi': [for (final t in Sentieri.tuttiITraguardi) t.id],
      'cammino.generazione': 2,
    });
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(EsotericCircleApp(
        conIntro: false, services: AppServices.offline(null, porta)));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  final centro = find.byKey(const Key('barra_online'));
  final numero = find.byKey(const Key('barra_online_numero'));

  group('il contatore', () {
    test('chiede alla porta e dice il numero, senza inventarne', () async {
      final porta = _PortaCheConta(quanti: 7);
      final chi = ChiEOnline(porta: porta);
      var avvisi = 0;
      chi.addListener(() => avvisi++);
      expect(chi.quanti, isNull, reason: 'un numero prima della risposta');
      await chi.chiedi();
      expect(chi.quanti, 7);
      expect(avvisi, 1);
      // Lo stesso numero non ridisegna la barra.
      await chi.chiedi();
      expect(avvisi, 1);
      // Una risposta mancata non cancella il numero che si sapeva.
      porta.quanti = null;
      await chi.chiedi();
      expect(chi.quanti, 7);
      chi.dispose();
    });

    test('con la porta spenta non parte nessun passo', () async {
      final chi = ChiEOnline(porta: const PortaSpentaDelCerchio())..avvia();
      expect(chi.quanti, isNull);
      chi.dispose();
    });

    test('il passo del telefono e la finestra del server si tengono', () {
      // Il server conta chi ha chiesto negli ultimi FINESTRA millesimi: se il
      // telefono chiedesse piu' di rado, chi ha l'app aperta uscirebbe dal
      // conto fra una domanda e l'altra.
      final server = File('functions/src/presenza.ts').readAsStringSync();
      final passo =
          RegExp(r'OGNI_QUANTO_CHIEDE_MS = (\d+) \* 1000').firstMatch(server);
      expect(passo, isNotNull, reason: 'il passo del server non si legge');
      final msServer = int.parse(passo!.group(1)!) * 1000;
      print('ORDINE ES VOCE 15: passo del telefono '
          '${ChiEOnline.ogni.inMilliseconds} ms, del server $msServer ms');
      expect(ChiEOnline.ogni.inMilliseconds, msServer);
      expect(
          server.contains('FINESTRA_DELLA_PRESENZA_MS = '
              'OGNI_QUANTO_CHIEDE_MS + 30 * 1000'),
          isTrue,
          reason: 'la finestra non e\' piu\' il passo piu\' mezzo minuto');
    });

    test('la presenza se ne va con chi cancella, e si conta senza elenco', () {
      // LAPIDE, ordine FB voce 01 (4 ottobre 2026). Questa prova si
      // chiamava "la presenza sta nel ramo di chi chiama e se ne va con lui"
      // e pretendeva la presenza sotto users/{uid}, un conto `.count()` e il
      // suo indice. Dall'ordine FB la presenza e' la voce della persona in
      // un frammento condiviso (`scriviLaPresenza`), e il numero viene
      // dall'istantanea. I fatti che la prova difendeva restano: chi
      // cancella se ne va anche dal conto, e al telefono torna un numero,
      // mai l'elenco.
      final cerchio = File('functions/src/cerchio.ts').readAsStringSync();
      final sociale =
          File('functions/src/il_cerchio_sociale.ts').readAsStringSync();
      final i = cerchio.indexOf('export const chiEOnline');
      expect(i, greaterThan(0), reason: 'la porta chiEOnline non c\'e\'');
      final corpo = cerchio.substring(i, cerchio.indexOf('\n});', i));
      expect(corpo.contains('uidDi(request)'), isTrue,
          reason: 'l\'uid non arriva dal token');
      expect(corpo.contains('scriviLaPresenza(uid, {'), isTrue,
          reason: 'la porta non scrive la presenza');
      // Dall'ordine FD voce 05 col suo spazio della presenza.
      expect(
          corpo.contains(
              'istantanea({ricostruisci: true, spazio: spazioDi(uid)})'),
          isTrue,
          reason: 'il numero non viene dall\'istantanea');
      // Ogni risposta della porta e' un oggetto con la sola chiave quanti:
      // chi esce riceve zero, gli altri il numero da mostrare, e nient'altro.
      final risposte = RegExp(r'return \{').allMatches(corpo).length;
      final soloIlNumero =
          RegExp(r'return \{quanti: 0\};').allMatches(corpo).length +
              RegExp(r'return \{quanti: quantiDaMostrare\([^;{}]*\)\};')
                  .allMatches(corpo)
                  .length;
      print('ORDINE FB VOCE 01: risposte della porta chiEOnline $risposte, '
          'col solo numero $soloIlNumero');
      expect(risposte >= 2 && soloIlNumero == risposte, isTrue,
          reason: 'al telefono non torna un numero solo');
      // Chi cancella se ne va dal conto: le due porte passano da
      // cancellaIlSociale PRIMA di cancellare il ramo, e lei toglie la voce.
      final cancella = sociale.substring(
          sociale.indexOf('export async function cancellaIlSociale('));
      expect(
          cancella
              .substring(0, cancella.indexOf('\n}\n'))
              .contains('scriviLaPresenza(uid, null)'),
          isTrue,
          reason: 'chi cancella il Cerchio resta nel frammento');
      for (final porta in ['azzeraIDatiDelCerchio', 'cancellaIlCerchio']) {
        final p = cerchio.substring(cerchio.indexOf('export const $porta'));
        final ramo = p.indexOf('recursiveDelete(utente(uid))');
        final prima = p.indexOf('cancellaIlSociale(uid)');
        expect(prima >= 0 && prima < ramo, isTrue,
            reason: '$porta non toglie la voce prima di cancellare il ramo');
      }
      final index = File('functions/src/index.ts').readAsStringSync();
      expect(index.contains('  chiEOnline,'), isTrue,
          reason: 'la porta non si esporta: Firebase non la vede');
    });
  });

  group('la barra', () {
    testWidgets('al centro si legge Online con la lucina verde',
        (tester) async {
      await apri(tester);
      expect(find.byKey(const Key('barra_eventi_cosmici')), findsNothing,
          reason: 'al centro c\'e\' ancora la porta degli Eventi Cosmici');
      expect(centro, findsOneWidget, reason: 'al centro non c\'e\' Online');
      final scritta = tester.widget<Text>(find.descendant(
          of: centro, matching: find.byKey(const Key('barra_online_scritta'))));
      final lucina = tester.widget<Container>(find.descendant(
          of: centro, matching: find.byKey(const Key('barra_online_lucina'))));
      final colore = (lucina.decoration! as BoxDecoration).color;
      print('ORDINE ES VOCE 15: senza server si legge "${scritta.data}", '
          'lucina $colore, numero ${numero.evaluate().length}');
      expect(scritta.data, 'Online');
      expect(colore, ColorTokens.lucinaOnline);
      expect(numero, findsNothing,
          reason: 'senza server compare un numero, quindi inventato');
    });

    testWidgets('col server si legge anche il numero', (tester) async {
      await apri(tester, porta: _PortaCheConta(quanti: 1284));
      expect(numero, findsOneWidget,
          reason: 'il server ha detto il numero e la barra non lo mostra');
      final n = tester.widget<Text>(numero).data;
      final etichetta = tester.getSemantics(centro).label;
      print('ORDINE ES VOCE 15: col server si legge "$n", etichetta '
          '"$etichetta"');
      expect(n, '1.284');
      expect(etichetta, 'Online adesso: 1.284 persone');
      // Lucina, scritta e numero stanno dentro la barra, uno accanto
      // all'altro sulla stessa riga.
      final l = tester.getRect(find.byKey(const Key('barra_online_lucina')));
      final s = tester.getRect(find.byKey(const Key('barra_online_scritta')));
      final r = tester.getRect(numero);
      final barra =
          tester.getRect(find.byKey(const Key('barra_dell_identita')));
      expect(l.right <= s.left && s.right <= r.left, isTrue,
          reason: 'lucina $l, scritta $s, numero $r non sono in fila');
      for (final q in [l, s, r]) {
        expect(
            q.top >= barra.top - 0.5 && q.bottom <= barra.bottom + 0.5, isTrue,
            reason: '$q esce dalla barra $barra');
      }
    });
  });

  group('il Passport', () {
    Future<void> alPassport(WidgetTester tester) async {
      await apri(tester);
      final ctxNav = tester.element(find.byType(AppShell));
      Provider.of<NavigationController>(ctxNav, listen: false).goToPassport();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      // **Lapide dell'ordine FE voce 01**: gli eventi si calcolano in un
      // isolate (IlCieloCheArriva), che nel tempo finto della prova non
      // gira; si lascia correre il tempo vero, poi si ridisegna.
      await tester
          .runAsync(() => Future<void>.delayed(const Duration(seconds: 6)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    final tessera = find.byKey(const Key('passport_prossimi_eventi'));

    testWidgets('in cima ci sono i Prossimi Eventi Cosmici', (tester) async {
      await alPassport(tester);
      expect(tessera, findsOneWidget,
          reason: 'nel Passport non ci sono i Prossimi Eventi Cosmici');
      expect(
          find.descendant(
              of: tessera, matching: find.text('Prossimi Eventi Cosmici')),
          findsOneWidget);
      final righe = find
          .descendant(
              of: tessera,
              matching: find.byWidgetPredicate((w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>)
                      .value
                      .startsWith('passport_evento_')))
          .evaluate()
          .length;
      final cima = tester.getRect(tessera).top;
      final traguardi =
          tester.getRect(find.byKey(const Key('bolla_dei_traguardi'))).top;
      print('ORDINE ES VOCE 15: eventi in cima al Passport $righe, tessera a '
          '$cima, traguardi a $traguardi');
      expect(righe, 2,
          reason: 'la tessera non dice i due eventi che arrivano prima');
      expect(cima, lessThan(traguardi),
          reason: 'la tessera non sta in cima, sopra i traguardi');
      expect(cima, lessThan(844),
          reason: 'la tessera non si vede senza scorrere');
    });

    testWidgets('il tocco apre il Calendario degli Eventi', (tester) async {
      await alPassport(tester);
      await tester.tap(tessera, warnIfMissed: false);
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
      expect(find.byType(CalendarioDegliEventiScreen), findsOneWidget,
          reason: 'la tessera dei Prossimi Eventi Cosmici non apre il '
              'Calendario: una porta che non porta da nessuna parte');
    });
  });
}

/// Una porta viva che risponde solo alla domanda di chi e' online.
class _PortaCheConta extends PortaSpentaDelCerchio {
  _PortaCheConta({this.quanti});

  int? quanti;

  @override
  bool get viva => true;

  @override
  Future<int?> chiEOnline() async => quanti;
}
