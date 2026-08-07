import 'dart:io';

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// I TRE ESITI DEL PERMESSO POSIZIONE RESTANO DISTINTI FINO A SCHERMO.
///
/// Ordine 2161, voce 10. Il pulsante "Attiva la posizione" chiamava davvero,
/// ma `chiedi()` APPIATTIVA `denied` e `deniedForever` in un solo esito:
/// a chi aveva negato per sempre il dialogo di sistema non sarebbe comparso
/// mai piu', e la schermata non portava mai alle impostazioni.
///
/// Appiattire due esiti diversi in uno solo e' la stessa forma di difetto
/// della regola messa in una porta sola: un'informazione che esisteva e
/// viene buttata a monte.
void main() {
  test('denied e deniedForever non tornano mai lo stesso valore', () {
    final testo =
        File('lib/core/astro/sky_location.dart').readAsStringSync();
    // La forma dell'appiattimento: i due permessi OR-ati verso un esito
    // unico. Se ricompare, la quarta prova cade qui.
    final appiattimento = RegExp(
        r'LocationPermission\.denied\s*\|\|\s*\n?\s*permission\s*==\s*LocationPermission\.deniedForever');
    expect(appiattimento.hasMatch(testo), isFalse,
        reason: 'In sky_location.dart denied e deniedForever sono di nuovo '
            'lo stesso ramo: l\'informazione che esisteva viene buttata a '
            'monte, e chi ha negato per sempre non arrivera\' mai alle '
            'impostazioni.');
    expect(testo.contains('negataPerSempre'), isTrue,
        reason: 'L\'esito negataPerSempre non esiste piu\': i tre esiti '
            'devono restare distinti fino a schermo.');
  });

  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final ora = DateTime(2026, 8, 6, 21, 30);

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  Future<void> monta(WidgetTester tester, SkyLocation sorgente) async {
    SharedPreferences.setMockInitialValues({});
    silenzia();
    tester.view.physicalSize = const Size(430, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: SunsetRuneScreen(
        now: ora,
        dataNascita: DateTime(1988, 7, 5),
        location: sorgente,
      ),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
  }

  testWidgets('concesso: la posizione si usa e il pulsante sparisce',
      (tester) async {
    await monta(tester, const _Sorgente(EsitoPosizione.concessa));
    await tester.ensureVisible(find.byKey(const Key('sunset_attiva')));
    await tester.tap(find.byKey(const Key('sunset_attiva')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byKey(const Key('sunset_ora')), findsOneWidget,
        reason: 'Col permesso concesso l\'ora deve essere quella vera.');
    expect(find.byKey(const Key('sunset_attiva')), findsNothing,
        reason: 'Col luogo vero il pulsante non ha piu\' ragione di esistere.');
  });

  testWidgets('negato una volta: si spiega il ripiego e si puo\' richiedere',
      (tester) async {
    const sorgente = _Sorgente(EsitoPosizione.negata);
    await monta(tester, sorgente);
    await tester.ensureVisible(find.byKey(const Key('sunset_attiva')));
    await tester.tap(find.byKey(const Key('sunset_attiva')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byKey(const Key('sunset_posizione_negata')), findsOneWidget,
        reason: 'Il ripiego non viene dichiarato.');
    expect(find.text('Attiva la posizione'), findsOneWidget,
        reason: 'Dopo un no semplice il pulsante deve poter chiedere ancora.');
  });

  testWidgets('negato per sempre: il pulsante porta alle impostazioni',
      (tester) async {
    final sorgente = _SorgenteChePuoAprire(EsitoPosizione.negataPerSempre);
    await monta(tester, sorgente);
    await tester.ensureVisible(find.byKey(const Key('sunset_attiva')));
    await tester.tap(find.byKey(const Key('sunset_attiva')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byKey(const Key('sunset_posizione_negata_per_sempre')),
        findsOneWidget,
        reason: 'Il no per sempre non viene spiegato a schermo.');
    expect(find.text('Apri le impostazioni'), findsOneWidget,
        reason: 'Il pulsante ripete una richiesta che il sistema non '
            'mostrera\' mai piu\', invece di portare alle impostazioni.');
    await tester.ensureVisible(find.byKey(const Key('sunset_attiva')));
    await tester.tap(find.byKey(const Key('sunset_attiva')));
    await tester.pump(const Duration(milliseconds: 150));
    expect(sorgente.impostazioniAperte, 1,
        reason: 'Il tocco su "Apri le impostazioni" non apre le '
            'impostazioni del sistema.');
  });
}

/// Una sorgente finta con l'esito deciso dalla prova.
class _Sorgente extends SkyLocation {
  const _Sorgente(this.esito);

  final EsitoPosizione esito;

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async => (await chiedi()).luogo;

  @override
  Future<RispostaPosizione> chiedi() async => RispostaPosizione(
        esito,
        esito == EsitoPosizione.concessa
            ? const SkyPlace(latitude: 45.46, longitude: 9.19)
            : null,
      );

  @override
  Future<SkyPlace?> resolveSeConcesso() async => null;
}

/// Come [_Sorgente], ma conta le aperture delle impostazioni.
class _SorgenteChePuoAprire extends SkyLocation {
  _SorgenteChePuoAprire(this.esito);

  final EsitoPosizione esito;
  int impostazioniAperte = 0;

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async => null;

  @override
  Future<RispostaPosizione> chiedi() async => RispostaPosizione(esito);

  @override
  Future<SkyPlace?> resolveSeConcesso() async => null;

  @override
  Future<bool> apriImpostazioni() async {
    impostazioniAperte++;
    return true;
  }
}
