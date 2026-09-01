import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NESSUN FOGLIO E' BIANCO. Ordine AL voce 04.
///
/// **La causa vera del foglio bianco del traguardo, misurata in banco**: non
/// era un colore mancante ne' un effetto di composizione di Impeller. Tutte le
/// porte dichiarano il fondo; ma i fogli dal basso e i dialoghi vivono come
/// rotte del Navigator RADICE, e `MaestroScope` stava dentro `home`: per loro
/// lo scope non esisteva. `MaestroScope.of` ha solo un assert, che in release
/// sparisce; il `!` lancia sul nullo, il builder muore e il foglio si disegna
/// MUTO. La card del traguardo e le vie della condivisione chiedono entrambe
/// `context.palette`, ed ecco il foglio bianco toccato da Mauro sulla 2179.
///
/// Due cure a strati: lo scope neutro SOPRA il Navigator (il pavimento: dopo,
/// nessun foglio puo' restare orfano) e il foglio del traguardo che veste il
/// Maestro del suo sentiero, lo stesso disegno di paletteDelSentiero.
///
/// Tre prove: l'enumerazione di TUTTE le porte pretende il fondo dichiarato;
/// il foglio del traguardo si apre nell'app vera con la card visibile e zero
/// eccezioni; una sonda qualunque sul Navigator radice trova lo scope.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  test('ogni foglio e ogni dialogo dichiarano il loro fondo', () {
    final porte = <String>[];
    final orfane = <String>[];
    // **I NOMI SONO CAMBIATI, ordine CF voce 09.** Dopo che fogli e dialoghi
    // sono passati sotto la legge del velo, nell'app le funzioni del
    // framework non le chiama piu' nessuno: le chiamano le tre porte del
    // velo, e chiunque altro chiama LORO. Cercando i vecchi nomi questa
    // enumerazione trovava tre porte invece di trentaquattro, e per poco non
    // dichiarava guarita un'app che aveva solo cambiato parola.
    final nomi = RegExp(
        r'(show(ModalBottomSheet|Dialog|GeneralDialog|CupertinoModalPopup)'
        r'|foglioDelCerchio|dialogoDelCerchio|dialogoGeneraleDelCerchio)\b');
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = file.readAsStringSync();
      for (final m in nomi.allMatches(testo)) {
        var i = m.end;
        while (i < testo.length && testo[i].trim().isEmpty) {
          i++;
        }
        // Il generico puo' contenere parentesi, come <(String, String)>: si
        // salta a profondita' di angolari, altrimenti il blocco misurato e'
        // quello sbagliato ed e' esattamente l'inciampo trovato in diagnosi.
        if (i < testo.length && testo[i] == '<') {
          var angoli = 0;
          while (i < testo.length) {
            if (testo[i] == '<') angoli++;
            if (testo[i] == '>') {
              angoli--;
              if (angoli == 0) {
                i++;
                break;
              }
            }
            i++;
          }
        }
        while (i < testo.length && testo[i].trim().isEmpty) {
          i++;
        }
        if (i >= testo.length || testo[i] != '(') continue;
        var tonde = 0;
        final da = i;
        while (i < testo.length) {
          if (testo[i] == '(') tonde++;
          if (testo[i] == ')') {
            tonde--;
            if (tonde == 0) break;
          }
          i++;
        }
        final blocco = testo.substring(da, i);
        final riga = testo.substring(0, m.start).split('\n').length;
        final dove = '${file.path.replaceAll('\\', '/')}:$riga';
        final velo = blocco.contains('barrierColor:')
            ? 'velo dichiarato'
            : 'velo di legge';
        porte.add('$dove ($velo)');
        // **LA PORTA STESSA NON E' UNA PORTA, ordine CF voce 09.** Dentro
        // `velo_del_cerchio.dart` vivono le tre funzioni che TUTTI
        // chiamano: li' dentro il fondo si INOLTRA, non si sceglie, e
        // pretenderlo vorrebbe dire chiedere alla porta di decidere al
        // posto di chi la usa. Che il foglio lo inoltri davvero lo
        // pretende la prova qui sotto.
        if (dove.contains('velo_del_cerchio.dart')) continue;
        if (!blocco.contains('backgroundColor:')) orfane.add(dove);
      }
    }
    // **E LA PORTA INOLTRA DAVVERO IL FONDO.** Senza questa riga
    // l'esenzione qui sopra sarebbe un buco: basterebbe togliere
    // `backgroundColor` dalla porta e tutti i fogli dell'app tornerebbero
    // bianchi con la prova verde.
    final porta = File('lib/design_system/transizioni/velo_del_cerchio.dart')
        .readAsStringSync();
    expect(porta.contains('backgroundColor: backgroundColor,'), isTrue,
        reason: 'la porta del velo non inoltra piu\' il fondo: ogni foglio '
            'dell\'app torna bianco e nessuna delle porte enumerate se ne '
            'accorge');
    // ignore: avoid_print
    print('ORDINE AL VOCE 04: porte enumerate ${porte.length}');
    expect(porte.length, greaterThanOrEqualTo(30),
        reason: 'l\'enumerazione ha perso le porte: oggi sono 34, se il conto '
            'crolla e\' il parser che si e\' rotto, non l\'app che e\' guarita');
    expect(orfane, isEmpty,
        reason: 'queste porte restano col fondo predefinito di Material: '
            '${orfane.join(", ")}');
  });

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

  Future<BuildContext> appVera(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    return tester.element(find.byType(Navigator).first);
  }

  testWidgets(
      'il foglio del traguardo si apre con la card viva e zero '
      'eccezioni', (tester) async {
    final contesto = await appVera(tester);
    final med27 = Sentieri.tuttiITraguardi.singleWhere((t) => t.id == 'med_27');
    mostraLaCardDelTraguardo(contesto,
        traguardo: med27, sentiero: RegiaDelCammino.sentieroDi(med27));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(tester.takeException(), isNull,
        reason: 'il builder del foglio e\' morto: in release questo e\' il '
            'foglio BIANCO della 2179');
    expect(find.byKey(const Key('card_del_traguardo')), findsOneWidget,
        reason: 'il foglio si e\' aperto ma la card non c\'e\'');
    expect(find.byKey(const Key('condividi_traguardo_compatto')), findsNothing);
  });

  testWidgets('ogni foglio sul Navigator radice trova uno scope',
      (tester) async {
    final contesto = await appVera(tester);
    showModalBottomSheet<void>(
      context: contesto,
      backgroundColor: Colors.transparent,
      builder: (foglio) => Container(
        key: const Key('sonda_del_pavimento'),
        height: 80,
        // La sonda chiede la palette ESATTAMENTE come una card qualunque:
        // senza il pavimento sopra il Navigator, qui casca tutto.
        color: MaestroScope.of(foglio).deepest,
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(tester.takeException(), isNull,
        reason: 'un foglio qualunque sul Navigator radice non trova lo scope: '
            'ogni card che chiede context.palette e\' un foglio bianco in '
            'attesa');
    expect(find.byKey(const Key('sonda_del_pavimento')), findsOneWidget);
  });
}
