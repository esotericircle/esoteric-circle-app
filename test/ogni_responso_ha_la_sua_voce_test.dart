import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/sensi/palette_sensoriale.dart';
import 'package:esoteric_circle/core/sensi/voce_del_responso.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/maestro_del_gesto.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// OGNI RESPONSO HA LA SUA VOCE. Ordine BX voce 05.
///
/// **Il fatto del fondatore**: "gli effetti sonori ci sono solo su alcune
/// funzioni e mancano sugli altri responsi". **Verificato prima di scrivere
/// una riga**: degli otto responsi che l'ordine BV voce 06 enumera, UNO
/// suonava, l'Oroscopo; gli altri sette non chiamavano ne' suono ne'
/// vibrazione, e sei di loro non avevano una sola riga sensoriale.
///
/// **LE DUE GRANDEZZE MISURATE, che l'ordine chiede per nome.** Quanti degli
/// otto responsi producono suono a comando ACCESO, che deve essere otto; e
/// quanti a comando SPENTO, che deve essere zero.
///
/// **Non si misura leggendo il sorgente**: si fa arrivare al cammino il gesto
/// di ognuno degli otto responsi, come fa la schermata vera, e si conta chi
/// ha parlato. La spia sta nella palette, che e' il punto da cui ogni suono
/// dell'app deve passare.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // **IL CANALE AUDIO, muto in prova.** Il plugin non esiste qui dentro, e
  // il solo costruire il lettore solleva sul canale degli eventi: quella
  // eccezione farebbe cadere la prova per un motivo che non c'entra col
  // numero misurato. E' lo stesso silenziamento che usano le catture.
  setUp(() {
    final messenger = binding.defaultBinaryMessenger;
    for (final canale in const [
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers/events',
      'xyz.luan/audioplayers.global/events',
    ]) {
      messenger.setMockMethodCallHandler(
          MethodChannel(canale), (call) async => null);
      messenger.setMockStreamHandler(
          EventChannel(canale), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  });

  /// I gesti degli otto responsi, come li chiama il corpus.
  final ottoResponsi = VoceDelResponso.deiResponsi.keys.toList();

  /// Monta l'albero minimo che un responso trova sotto di se': il diario del
  /// cammino e le impostazioni.
  Future<BuildContext> monta(WidgetTester tester,
      {required bool effettiSonori, bool suonoEVibrazione = true}) async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    late BuildContext preso;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider(
            create: (_) => SettingsController(
                suonoEVibrazione: suonoEVibrazione,
                effettiSonori: effettiSonori)),
      ],
      child: MaterialApp(
        home: Builder(builder: (context) {
          preso = context;
          return const SizedBox.shrink();
        }),
      ),
    ));
    return preso;
  }

  group('BX.05, gli otto responsi suonano', () {
    tearDown(() => PaletteSensoriale.spiaDelResponso = null);

    testWidgets('A comando acceso parlano tutti e otto, ognuno col suo Maestro',
        (tester) async {
      final context = await monta(tester, effettiSonori: true);
      final chiHaParlato = <String, Maestro>{};
      // **DENTRO runAsync, e senza non finisce mai.** Il diario scrive su
      // SharedPreferences, che passa dal canale della piattaforma: nel
      // tempo finto di una prova a widget quel futuro non si chiude, e la
      // prova muore con "did not complete" invece di dire un numero.
      // Misurato: sei minuti e mezzo appesa alla prima riga.
      await tester.runAsync(() async {
        for (final gesto in ottoResponsi) {
          PaletteSensoriale.spiaDelResponso = (m) => chiHaParlato[gesto] = m;
          await RegiaDelCammino.dopoUnGesto(context, gesto);
        }
      });
      await tester.pump();
      // ignore: avoid_print
      print('ORDINE BX VOCE 5: a comando acceso parlano '
          '${chiHaParlato.length} responsi su ${ottoResponsi.length}: '
          '${chiHaParlato.map((g, m) => MapEntry(g, m.id))}');
      expect(chiHaParlato.length, ottoResponsi.length,
          reason: 'solo ${chiHaParlato.length} responsi su '
              '${ottoResponsi.length} producono suono: gli altri sono muti '
              'come li ha trovati il fondatore');
      // E ognuno con la voce del proprio Maestro.
      for (final gesto in ottoResponsi) {
        expect(chiHaParlato[gesto], VoceDelResponso.deiResponsi[gesto],
            reason: 'il responso "$gesto" parla con la voce di un altro '
                'Maestro');
      }
    });

    testWidgets('A comando spento non parla nessuno', (tester) async {
      final context = await monta(tester, effettiSonori: false);
      var quanti = 0;
      PaletteSensoriale.spiaDelResponso = (_) => quanti++;
      // **DENTRO runAsync, e senza non finisce mai.** Il diario scrive su
      // SharedPreferences, che passa dal canale della piattaforma: nel
      // tempo finto di una prova a widget quel futuro non si chiude, e la
      // prova muore con "did not complete" invece di dire un numero.
      // Misurato: sei minuti e mezzo appesa alla prima riga.
      await tester.runAsync(() async {
        for (final gesto in ottoResponsi) {
          await RegiaDelCammino.dopoUnGesto(context, gesto);
        }
      });
      await tester.pump();
      // ignore: avoid_print
      print('ORDINE BX VOCE 5: a comando spento parlano $quanti responsi su '
          '${ottoResponsi.length}');
      expect(quanti, 0,
          reason: '$quanti responsi suonano lo stesso col comando degli '
              'effetti sonori spento');
    });

    testWidgets('E l\'interruttore unico comanda su tutti e due',
        (tester) async {
      // Chi spegne "Suono e vibrazione" vuole silenzio: il comando degli
      // effetti sonori acceso non lo puo' contraddire.
      final context = await monta(tester,
          effettiSonori: true, suonoEVibrazione: false);
      var quanti = 0;
      PaletteSensoriale.spiaDelResponso = (_) => quanti++;
      // **DENTRO runAsync, e senza non finisce mai.** Il diario scrive su
      // SharedPreferences, che passa dal canale della piattaforma: nel
      // tempo finto di una prova a widget quel futuro non si chiude, e la
      // prova muore con "did not complete" invece di dire un numero.
      // Misurato: sei minuti e mezzo appesa alla prima riga.
      await tester.runAsync(() async {
        for (final gesto in ottoResponsi) {
          await RegiaDelCammino.dopoUnGesto(context, gesto);
        }
      });
      await tester.pump();
      // ignore: avoid_print
      print('ORDINE BX VOCE 5: con l\'interruttore unico spento parlano '
          '$quanti responsi');
      expect(quanti, 0,
          reason: 'il livello sensoriale e\' spento e qualcosa suona lo '
              'stesso');
    });

    testWidgets('Un gesto che non e\' un responso resta muto', (tester) async {
      // Il silenzio e' cio' che rende un suono importante: la regola del
      // catalogo non e' cambiata, e un suono a ogni gesto sarebbe il rumore
      // che quella regola vieta.
      final context = await monta(tester, effettiSonori: true);
      var quanti = 0;
      PaletteSensoriale.spiaDelResponso = (_) => quanti++;
      // **DENTRO runAsync, e senza non finisce mai.** Il diario scrive su
      // SharedPreferences, che passa dal canale della piattaforma: nel
      // tempo finto di una prova a widget quel futuro non si chiude, e la
      // prova muore con "did not complete" invece di dire un numero.
      // Misurato: sei minuti e mezzo appesa alla prima riga.
      await tester.runAsync(() async {
        for (final gesto in const ['bosco', 'condivisione', 'due_volti']) {
          await RegiaDelCammino.dopoUnGesto(context, gesto);
        }
      });
      await tester.pump();
      // ignore: avoid_print
      print('ORDINE BX VOCE 5: tre gesti che non sono responsi fanno suonare '
          '$quanti voci');
      expect(quanti, 0,
          reason: 'suona anche cio\' che non e\' un responso: e\' il rumore '
              'che il catalogo dei suoni vieta dal primo giorno');
    });
  });

  group('BX.05, la scelta resta e le voci sono coerenti', () {
    test('Il comando spento sopravvive alla riapertura dell\'app', () async {
      SharedPreferences.setMockInitialValues(const {});
      final prima = SettingsController();
      expect(prima.effettiSonori, isTrue,
          reason: 'di partenza l\'app deve suonare');
      prima.setEffettiSonori(false);
      // Il salvataggio e' best effort e asincrono: si lascia girare.
      await Future<void>.delayed(Duration.zero);

      // L'app si riapre: un controller nuovo che legge dal disco.
      final dopo = SettingsController();
      await dopo.load();
      // ignore: avoid_print
      print('ORDINE BX VOCE 5: riaperta l\'app, gli effetti sonori sono '
          '${dopo.effettiSonori ? "accesi" : "spenti"}');
      expect(dopo.effettiSonori, isFalse,
          reason: 'la scelta di spegnere i suoni non sopravvive alla '
              'riapertura dell\'app');
      expect(dopo.suonoPermesso, isFalse);
    });

    test('Le tre voci sono tre, e non le ho decise io', () {
      // **L'appartenenza viene dal corpus**, che dichiara di chi e' ogni
      // gesto: se un giorno il corpus cambiasse padrone a un responso, questa
      // prova cadrebbe invece di lasciare due verita' diverse nell'app.
      const sentieroDelMaestro = {
        'costellazione': Maestro.medora,
        'loto': Maestro.aura,
        'albero': Maestro.caligo,
      };
      final divergenti = <String>[];
      for (final voce in VoceDelResponso.deiResponsi.entries) {
        final dalCorpus = sentieroDelMaestro[sentieroDelGesto[voce.key]];
        if (dalCorpus == null) continue;
        if (dalCorpus != voce.value) {
          divergenti.add('${voce.key}: voce ${voce.value.id}, corpus '
              '${dalCorpus.id}');
        }
      }
      // ignore: avoid_print
      print('ORDINE BX VOCE 5: responsi confrontati col corpus '
          '${VoceDelResponso.deiResponsi.length}, divergenti $divergenti');
      expect(divergenti, isEmpty,
          reason: 'la voce di questi responsi non e\' quella del Maestro che '
              'il corpus dichiara: $divergenti');
      final fondamentali = {
        for (final m in Maestro.values) VoceDelResponso.fondamentaleDi(m),
      };
      expect(fondamentali, hasLength(3),
          reason: 'due Maestri parlano con la stessa nota');
      // E la voce dura meno di un secondo, come ogni suono del Cerchio.
      expect(VoceDelResponso.durata.inMilliseconds, lessThan(1000));
      // I byte esistono davvero: un WAV con la sua intestazione.
      final byte = VoceDelResponso.byteDi(Maestro.medora);
      expect(byte.length, greaterThan(1000));
      expect(String.fromCharCodes(byte.sublist(0, 4)), 'RIFF',
          reason: 'la voce non e\' un WAV: il motore non la sapra\' suonare');
    });
  });
}
