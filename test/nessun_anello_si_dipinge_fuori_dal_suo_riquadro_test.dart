import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/features/maestri/widgets/maestro_bust.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// NESSUN ANELLO SI DIPINGE FUORI DAL SUO RIQUADRO. Ordine CT, voce 02.
///
/// **Il fatto.** Parole del fondatore, collaudo del 4 settembre 2026: *"poco
/// sotto sullo sfondo c'e' un cerchio fisso che credo sia un refuso da
/// eliminare"*. Compariva in tutte e cinque le schermate, sempre nello stesso
/// posto, e non apparteneva a nessun elemento.
///
/// **Da dove nasceva, misurato e non dedotto.** Una sonda ha stampato i busti
/// a video nella chat: uno solo, con anello cento, dentro il riquadro
/// `Rect.fromLTRB(145, 148, 245, 148)`, cioe' **alto zero**. Lo `Stack` del
/// busto ha `Clip.none`, quindi l'anello si dipinge lo stesso, fuori dal
/// proprio riquadro, fermo sul fondo: non apparteneva a nessun elemento
/// perche' il suo elemento non aveva altezza.
///
/// **La causa.** La presenza a riposo decideva se costruirsi guardando lo
/// SCHERMO invece dello spazio ricevuto: un quinto di ottocentoquarantaquattro
/// fa centosessantotto, sopra la soglia dei centodieci, quindi si costruiva
/// anche quando il genitore le stava dando zero.
///
/// **Lo stesso residuo era gia' stato visto e curato male.** Il commento
/// accanto al codice citava *"un rettangolo da 148 a 148"*, cioe' lo stesso
/// identico riquadro, e la cura era stata dichiarare l'altezza DENTRO con un
/// `SizedBox`. Un figlio puo' dichiarare l'altezza che vuole: chi lo stringe
/// decide lo stesso.
///
/// **Cio' che si misura qui.** Non che il cerchio non ci sia: che nessun
/// anello si dipinga in un riquadro piu' corto di se stesso. Una prova che
/// cercasse l'assenza del busto sarebbe verde anche togliendo la presenza
/// dovunque, cioe' spegnendo una funzione invece di ripararla.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzio() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
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

  Future<void> passo(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> apriLaChat(WidgetTester tester, Maestro maestro) async {
    // **LA FINESTRA E' UN TELEFONO**, non il default largo e corto: su una
    // geometria che nessun telefono ha, lo spazio sopra la conversazione non
    // e' quello che il fondatore vede.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await passo(tester);
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(maestro);
    await passo(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await passo(tester);
    await passo(tester);
    await tester.ensureVisible(find.text('Consulta ${maestro.displayName}'));
    await tester.pump();
    await tester.tap(find.text('Consulta ${maestro.displayName}'));
    await passo(tester);
  }

  /// I busti a video con la misura del riquadro che li contiene davvero.
  List<String> anelliFuoriDalRiquadro(WidgetTester tester) {
    final fuori = <String>[];
    for (final elemento in find.byType(MaestroBust).evaluate()) {
      final busto = elemento.widget as MaestroBust;
      final riquadro = tester.getRect(find.byWidget(busto));
      // Il riquadro deve contenere almeno il diametro dell'anello. Meno di
      // cosi' vuol dire che l'anello sta dipingendo dove non gli spetta.
      if (riquadro.height + 0.5 < busto.ring) {
        fuori.add('anello ${busto.ring} in un riquadro alto '
            '${riquadro.height.toStringAsFixed(1)}, a $riquadro');
      }
    }
    return fuori;
  }

  testWidgets('A chat aperta nessun anello esce dal proprio riquadro',
      (tester) async {
    silenzio();
    await apriLaChat(tester, Maestro.medora);
    final fuori = anelliFuoriDalRiquadro(tester);
    expect(fuori, isEmpty,
        reason: 'QUESTI ANELLI SI DIPINGONO FUORI DAL LORO RIQUADRO, e sono '
            '${fuori.length}:\n${fuori.join("\n")}\n'
            'Con Clip.none un busto in un riquadro troppo corto lascia a '
            'video il solo anello, fermo sul fondo, che e\' il cerchio che il '
            'fondatore ha chiamato refuso');
  });

  testWidgets('E nemmeno dopo che si e\' mandata una domanda', (tester) async {
    silenzio();
    await apriLaChat(tester, Maestro.medora);
    await tester.enterText(
        find.byType(TextField).first, 'Cosa dice il mio cielo');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.send);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    final fuori = anelliFuoriDalRiquadro(tester);
    expect(fuori, isEmpty,
        reason: 'con la conversazione avviata questi anelli escono dal loro '
            'riquadro, e sono ${fuori.length}:\n${fuori.join("\n")}');
  });

  // **LA REGOLA VALE PER TUTTI E TRE, una prova per ciascuno.** In un
  // ciclo dentro una prova sola il secondo giro ripartiva a chat gia' aperta
  // e non trovava piu' il busto del Santuario: la prova cadeva per come era
  // scritta, non per cio' che misura.
  for (final maestro in Maestro.values) {
    testWidgets('Nella chat di ${maestro.id} nessun anello esce dal riquadro',
        (tester) async {
      silenzio();
      await apriLaChat(tester, maestro);
      expect(anelliFuoriDalRiquadro(tester), isEmpty,
          reason: 'nella chat di ${maestro.displayName} un anello esce dal '
              'suo riquadro');
    });
  }
}
