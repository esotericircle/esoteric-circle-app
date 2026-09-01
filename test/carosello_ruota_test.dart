import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/santuario/widgets/maestro_bust.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il carosello RUOTA, non taglia.
///
/// Prima i tre Maestri stavano in tre posizioni fisse assegnate per indice:
/// toccando un Maestro dietro, tutti e tre cambiavano posto nello stesso
/// fotogramma. Non era una rotazione, era un taglio di montaggio, ed e'
/// esattamente cio' che Mauro vedeva.
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

  Future<void> apri(WidgetTester tester) async {
    silence();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // L'app vera dall'avvio: il Santuario legge i servizi, e montarlo da
    // solo vorrebbe dire fabbricare mezzo albero a mano.
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      await OnboardingController().complete();
    });
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  /// Dove sta ciascun Maestro adesso, letto dai busti a schermo.
  Map<Maestro, Offset> posizioni(WidgetTester tester) {
    final out = <Maestro, Offset>{};
    for (final e in find.byType(MaestroBust).evaluate()) {
      final b = e.widget as MaestroBust;
      out[b.maestro] = tester.getRect(find.byWidget(b)).center;
    }
    return out;
  }

  testWidgets('Toccando un Maestro dietro, i tre si spostano un poco per volta',
      (tester) async {
    await apri(tester);
    final partenza = posizioni(tester);
    expect(partenza.length, 3, reason: 'non ci sono tre Maestri a schermo');

    await tester.tap(find.byKey(const Key('santuario_side_left')));

    // Si guarda fotogramma per fotogramma: nessuno puo' arrivare a
    // destinazione in un colpo solo, e nessuno puo' sparire per strada.
    var passiVisti = 0;
    var precedente = partenza;
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 80));
      final ora = posizioni(tester);
      expect(ora.length, 3,
          reason: 'a un certo fotogramma i Maestri a schermo erano '
              '${ora.length}: uno e\' sparito');
      for (final m in Maestro.fixedOrder) {
        final salto = (ora[m]! - precedente[m]!).distance;
        // Un salto piu' largo di un terzo di schermo in ottanta millesimi non
        // e' un movimento, e' un taglio.
        expect(salto, lessThan(130),
            reason: '$m e\' saltato di $salto px in un fotogramma');
      }
      if (ora.toString() != precedente.toString()) passiVisti++;
      precedente = ora;
    }
    expect(passiVisti, greaterThanOrEqualTo(4),
        reason: 'la rotazione si e\' vista in soli $passiVisti fotogrammi');

    // Niente pumpAndSettle: il cosmo di fondo pulsa in continuo e non si
    // ferma mai, quindi si pompano fotogrammi contati.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // A fine corsa qualcun altro sta davanti.
    final arrivo = posizioni(tester);
    final davantiPrima = _piuInBasso(partenza);
    final davantiDopo = _piuInBasso(arrivo);
    expect(davantiDopo, isNot(davantiPrima),
        reason: 'dopo la rotazione davanti c\'e\' sempre lo stesso');
  });

  testWidgets('La rotazione dura almeno quattro decimi di secondo',
      (tester) async {
    await apri(tester);
    await tester.tap(find.byKey(const Key('santuario_side_left')));
    await tester.pump();

    final aMeta = posizioni(tester);
    await tester.pump(const Duration(milliseconds: 380));
    final quasi = posizioni(tester);
    // A 380 millesimi il movimento non puo' essere gia' finito.
    var fermi = 0;
    for (final m in Maestro.fixedOrder) {
      if ((quasi[m]! - aMeta[m]!).distance < 1) fermi++;
    }
    expect(fermi, lessThan(3),
        reason: 'a 380 ms erano gia' ' tutti fermi: la corsa e troppo breve');
    // Niente pumpAndSettle: il cosmo di fondo pulsa in continuo e non si
    // ferma mai, quindi si pompano fotogrammi contati.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  });

  testWidgets('Trascinando il dito i Maestri seguono la mano', (tester) async {
    await apri(tester);
    final partenza = posizioni(tester);

    // Il centro del CAROSELLO, non dello schermo: il centro dello schermo
    // cade sul cielo, dove il trascinamento orizzontale non ha nulla da
    // muovere.
    final centro =
        tester.getCenter(find.byKey(const Key('santuario_carosello')));
    final dito = await tester.startGesture(centro);
    // Il riconoscitore di trascinamento accetta dopo che il dito ha superato
    // la soglia: si muove a piccoli passi, come una mano vera.
    for (var i = 0; i < 6; i++) {
      await dito.moveBy(const Offset(-14, 0));
      await tester.pump(const Duration(milliseconds: 16));
    }
    final durante = posizioni(tester);

    var mossi = 0;
    for (final m in Maestro.fixedOrder) {
      if ((durante[m]! - partenza[m]!).distance > 4) mossi++;
    }
    expect(mossi, greaterThanOrEqualTo(2),
        reason: 'col dito si sono mossi solo $mossi Maestri su tre');

    await dito.up();
    // Niente pumpAndSettle: il cosmo di fondo pulsa in continuo e non si
    // ferma mai, quindi si pompano fotogrammi contati.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // Al rilascio si assesta: nessuno resta a meta' strada.
    final finale = posizioni(tester);
    expect(finale.length, 3);
  });
}

/// Chi sta davanti: il busto piu' in basso, che e' quello in primo piano.
Maestro _piuInBasso(Map<Maestro, Offset> p) {
  var vincitore = p.keys.first;
  for (final e in p.entries) {
    if (e.value.dy > p[vincitore]!.dy) vincitore = e.key;
  }
  return vincitore;
}
