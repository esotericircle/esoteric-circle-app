import 'dart:io';

import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// LA FESTA NON COPRE UN'ANIMAZIONE IN CORSO. Ordine BU voci 03 e 05.
///
/// **Parole del fondatore sulla build 2208**: "quando parte il calcolo con
/// l'animazione di riflessione, se c'e' una festa la riflessione non si vede
/// perche' sopra c'e' la festa". E: "le feste ce ne sono ancora attaccate".
///
/// **Non e' un timer e non e' una coda a freddo**: e' una condizione sulla
/// scena. La festa non viene rimandata di un tempo, viene rimandata finche' la
/// scena sta raccontando qualcosa, e l'immediatezza dell'ordine BS resta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    RiflessioniInCorso.azzera();
    FesteInCorso.azzera();
    RegistroDelleFeste.azzera();
  });

  tearDown(RiflessioniInCorso.azzera);

  group('BU.03, la festa aspetta che la scena sia libera', () {
    testWidgets('Con una riflessione in corso la festa non si apre',
        (tester) async {
      final traguardo = Sentieri.tuttiITraguardi.firstWhere((t) => !t.dormiente);
      var riflessioneViva = true;
      RiflessioniInCorso.entra(() => riflessioneViva);

      // **LA FESTA PRETENDE IL DIARIO E LO SCOPE DEL MAESTRO**, e senza di
      // loro cadrebbe per il motivo sbagliato: qui si misura la regola, non
      // l'impalcatura.
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      late BuildContext ctx;
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: Builder(builder: (c) {
              ctx = c;
              return const SizedBox.expand();
            }),
          ),
        ),
      ));

      var apparsa = false;
      var alFotogramma = -1;
      // Trenta fotogrammi con la riflessione che va: la festa non deve
      // comparire in nessuno.
      for (var i = 0; i < 30; i++) {
        final mostrata = await Celebrazione.festeggiaInsieme(
          ctx,
          traguardi: [traguardo],
          sentieri: [Sentiero.costellazione],
          primoInAssoluto: false,
        );
        if (mostrata) {
          apparsa = true;
          alFotogramma = i;
          break;
        }
        await tester.pump(const Duration(milliseconds: 16));
      }
      // ignore: avoid_print
      print('ORDINE BU VOCE 3: con la riflessione in corso la festa e\' '
          'comparsa ${apparsa ? "al fotogramma $alFotogramma" : "zero volte"} '
          'su 30 fotogrammi');
      expect(apparsa, isFalse,
          reason: 'la festa e\' comparsa al fotogramma $alFotogramma mentre '
              'la riflessione stava ancora andando: e\' esattamente cio\' che '
              'il fondatore ha visto');

      // Finita la riflessione, la scena e' libera: la festa passa subito.
      riflessioneViva = false;
      final dopo = await Celebrazione.festeggiaInsieme(
        ctx,
        traguardi: [traguardo],
        sentieri: [Sentiero.costellazione],
        primoInAssoluto: false,
      );
      // ignore: avoid_print
      print('ORDINE BU VOCE 3: finita la riflessione, la festa passa: $dopo');
      expect(dopo, isTrue,
          reason: 'finita la riflessione la festa non parte piu\': il rinvio '
              'e\' diventato una perdita');
      // La scena della festa gira per sempre: si pompa quanto basta e si
      // chiude, senza pumpAndSettle, che con un'animazione continua non si
      // ferma mai.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    test('Le tre riflessioni dell\'app si dichiarano tutte', () {
      // **LE TRE SCENE, enumerate sul sorgente.** La stesa, l'Oroscopo e la
      // Sinastria: se domani ne nasce una quarta che non si dichiara, la festa
      // tornera' a coprirla, e questa riga e' il posto dove accorgersene.
      const scene = {
        'la stesa': 'lib/features/tarot/stesa_tre_carte_screen.dart',
        'l\'Oroscopo': 'lib/features/horoscope/oroscopo_screen.dart',
        'la Sinastria': 'lib/features/synastry/chiamata_del_vip.dart',
      };
      final mute = <String>[];
      scene.forEach((nome, percorso) {
        if (!File(percorso)
            .readAsStringSync()
            .contains('RiflessioniInCorso.entra(')) {
          mute.add('$nome ($percorso)');
        }
      });
      // ignore: avoid_print
      print('ORDINE BU VOCE 3: riflessioni dichiarate '
          '${scene.length - mute.length} su ${scene.length}');
      expect(mute, isEmpty,
          reason: 'queste scene animano senza dichiararlo, e una festa ci si '
              'dipingera\' sopra: $mute');
    });
  });

  group('BU.05, le feste attaccate, misurate', () {
    test('Sul percorso vero del fondatore, nessuna coppia dallo stesso gesto',
        () async {
      // **IL PERCORSO CHE IL FONDATORE HA FATTO**, nell'ordine in cui lo ha
      // fatto: l'onboarding che gli ha dato la carta e il Passaporto, poi il
      // primo soffio, la prima alba, il primo oroscopo, la prima stesa, la
      // prima gettata.
      SharedPreferences.setMockInitialValues(const {});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();

      const percorso = [
        'onboarding',
        'soffio',
        'alba',
        'oroscopo',
        'stesa',
        'gettata',
      ];
      final gesti = <String, int>{};
      final giorni = <String, int>{};
      final oggi = <String>{};
      final pezzi = <String>{};
      var feste = 0;
      var eventiConPiuDiUno = 0;
      final perGesto = <String, int>{};

      for (final passo in percorso) {
        if (passo == 'onboarding') {
          for (final g in const ['carta_natale', 'passaporto']) {
            gesti[g] = (gesti[g] ?? 0) + 1;
            giorni[g] = 1;
            oggi.add(g);
            pezzi.add(g);
          }
          pezzi.addAll(const [
            'numero_della_vita',
            'ora_di_nascita',
            'luogo_di_nascita'
          ]);
        } else {
          gesti[passo] = (gesti[passo] ?? 0) + 1;
          giorni[passo] = 1;
          oggi.add(passo);
        }
        final stato = StatoDelCammino(
          gestiCompiuti: Map.of(gesti),
          giorniConGesto: Map.of(giorni),
          oggiHaFatto: Set.of(oggi),
          pezziDellIdentita: Set.of(pezzi),
          gradiniAlleSpalle: {
            for (final s in Sentiero.values) s.name: diario.quantiAccesiDi(s),
          },
        );
        final soddisfatti = diario.quelliSoddisfatti(stato).length;
        final accesi = await diario.quelliCheSiAccendono(stato);
        for (final t in accesi) {
          await diario.accendi(t.id);
        }
        feste += accesi.length;
        perGesto[passo] = accesi.length;
        if (accesi.length > 1) eventiConPiuDiUno++;
        // ignore: avoid_print
        print('ORDINE BU VOCE 5: $passo -> soddisfatti $soddisfatti, feste '
            '${accesi.length} (${accesi.map((t) => t.id).join(", ")})');
      }

      // ignore: avoid_print
      print('ORDINE BU VOCE 5: sul percorso del fondatore, feste $feste da '
          '${percorso.length} gesti distinti; coppie di feste nate dallo '
          'stesso gesto $eventiConPiuDiUno');
      expect(eventiConPiuDiUno, 0,
          reason: 'ci sono $eventiConPiuDiUno gesti che hanno acceso piu\' di '
              'una festa: la legge dell\'ordine BS e\' rotta, e va detto '
              'invece di curare il sintomo');
      expect(feste, greaterThan(0),
          reason: 'sul percorso del fondatore non si accende niente: la '
              'simulazione non sta misurando il percorso vero');
    });

    test('Il registro delle feste sa dire da quale gesto vengono', () {
      RegistroDelleFeste.azzera();
      RegistroDelleFeste.segna(gesto: 'stesa', traguardo: 'med_3');
      RegistroDelleFeste.segna(gesto: 'gettata', traguardo: 'cal_1');
      expect(RegistroDelleFeste.coppieDalloStessoGesto, 0);
      RegistroDelleFeste.segna(gesto: 'gettata', traguardo: 'cal_2');
      expect(RegistroDelleFeste.coppieDalloStessoGesto, 1,
          reason: 'il registro non riconosce due feste nate dallo stesso '
              'gesto: senza questo conto la domanda del fondatore resta '
              'un\'opinione');
      RegistroDelleFeste.azzera();
    });
  });
}
