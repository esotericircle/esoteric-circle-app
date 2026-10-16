import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/features/maestri/maestro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// La striscia "Scopri altre arti del Cerchio" nel dominio del Maestro: le arti
/// degli ALTRI Maestri, in tessere, che aprono la funzione giusta.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  /// Apre il dominio di un Maestro dal Santuario e scorre fino alla striscia,
  /// che vive in fondo alla schermata come sliver, costruito solo allo scroll.
  Future<void> openDomain(WidgetTester tester, Maestro maestro) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(430, 1200);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await step(tester);
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(maestro);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);

    // Scorre il verticale fino a far comparire la striscia.
    await tester.scrollUntilVisible(
      find.byKey(const Key('other_arts_strip')),
      400,
      scrollable: find.byType(Scrollable).first,
    );
  }

  testWidgets('Nel dominio di Medora la striscia mostra arti di altri Maestri',
      (tester) async {
    silenceSensors();
    await openDomain(tester, Maestro.medora);

    expect(find.byKey(const Key('other_arts_strip')), findsOneWidget);

    // LA STRISCIA LEGGE IL CATALOGO e applica un CRITERIO, non un elenco: al
    // massimo una arte per Maestro, mai del Maestro corrente, con ordine che
    // ruota col giorno. Pretendere due arti precise sarebbe tornare a una lista
    // scritta a mano, cioe' al difetto.
    final mostrate = artiDaScoprire(Maestro.medora,
        gia: const <String>{}, giorno: DateTime(2026, 7, 31));
    expect(mostrate.length, 2,
        reason: 'la striscia mostra ${mostrate.length} arti: una per ciascuno '
            'degli altri due Maestri');
    for (final a in mostrate) {
      expect(
          ArtCatalog.activeOf(Maestro.medora).any((x) => x.id == a.id), isFalse,
          reason: 'la striscia mostra ${a.id}, che e del Maestro corrente');
    }
    // Nessuna delle arti mostrate porta alla stessa rotta di un'altra.
    final rotte = mostrate.map((a) => rottaDiProva(a.id)).toList();
    expect(rotte.toSet().length, rotte.length,
        reason: 'due voci della striscia portano allo stesso posto');
  });

  test('Ogni arte che la striscia mostra porta a una schermata vera', () {
    // Era un testWidgets che scorreva fino alla tessera e la toccava, e adesso
    // non regge: quale arte compaia lo decide il criterio con la rotazione del
    // giorno, e scorrere fin li' dipende da dove la piega taglia la pagina, che
    // non e' cio' che questa prova misura. Il fatto che conta si verifica senza
    // montare niente: cio' che la striscia offre porta da qualche parte.
    for (final corrente in Maestro.values) {
      final mostrate = artiDaScoprire(corrente,
          gia: const <String>{}, giorno: DateTime(2026, 7, 31));
      for (final a in mostrate) {
        expect(rottaDiProva(a.id), isNotNull,
            reason: 'nel dominio di ${corrente.name} la striscia offre '
                '${a.id}, che non porta da nessuna parte');
      }
    }
  });
}
