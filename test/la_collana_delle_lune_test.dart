import 'dart:io';

import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/lunario/il_listino_del_respiro.dart';
import 'package:esoteric_circle/core/lunario/il_motore_lunare.dart';
import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/lunario/la_collana_delle_lune.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_delle_lune_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **LA COLLANA DELLE LUNE.** Ordine FX voce FX.05, 16 ottobre 2026.
///
/// Prova che il ciclo segue la lunazione vera (ventinove o trenta perle fra
/// due Lune nuove), che le perle si accendono solo sui giorni davvero
/// respirati e restano spente sui giorni passati, che la ricucitura rispetta
/// i suoi limiti, e che la schermata vera mostra la collana e lascia
/// ricucire una perla spenta col tocco.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Il ciclo vero, dalla Luna nuova alla prossima', () {
    test('il numero di perle e\' la differenza in giorni fra due Lune nuove',
        () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);

      final oggi = DateTime(2026, 10, 16);
      final ciclo = collana.cicloDi(oggi);
      final n = collana.numeroDiPerle(ciclo.inizio, ciclo.fine);

      expect(n, anyOf(29, 30),
          reason: 'una lunazione vera dura 29 o 30 giorni, non $n');
      expect(collana.perle(oggi).length, n);

      // L'inizio del ciclo e' davvero una Luna nuova vera, non un ripiego:
      // il motore ne trova una entro il giorno di calendario dichiarato
      // (l'istante esatto puo' cadere in un punto qualunque di quel giorno
      // locale).
      final luneVicineAllInizio = IlMotoreLunare.luneNuoveFra(
          ciclo.inizio, ciclo.inizio.add(const Duration(days: 1)));
      expect(luneVicineAllInizio, isNotEmpty,
          reason: 'l\'inizio del ciclo non cade su una Luna nuova vera');
    });

    test('i giorni respirati sono accesi, i passati non respirati spenti',
        () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);

      final oggi = DateTime(2026, 10, 16);
      final ciclo = collana.cicloDi(oggi);
      final treGiorniFa = oggi.subtract(const Duration(days: 3));
      await respiro.segnaRespirato(treGiorniFa);

      final perle = collana.perle(oggi);
      final quellaDiTreGiorniFa =
          perle.firstWhere((p) => p.giorno == treGiorniFa);
      expect(quellaDiTreGiorniFa.stato, StatoDellaPerla.accesa);
      expect(quellaDiTreGiorniFa.immagine, isNotNull,
          reason: 'una perla accesa porta la Luna vera di quel giorno');

      final giorniPassatiNonRespirati = perle.where((p) =>
          p.giorno.isBefore(DateTime(oggi.year, oggi.month, oggi.day)) &&
          p.giorno != treGiorniFa);
      // Nel ciclo in corso ci sono almeno alcuni giorni passati non
      // respirati (a meno che oggi sia l'inizio stesso del ciclo).
      if (ciclo.inizio.isBefore(oggi)) {
        expect(giorniPassatiNonRespirati, isNotEmpty);
        for (final p in giorniPassatiNonRespirati) {
          expect(p.stato, StatoDellaPerla.spenta,
              reason: 'il giorno ${p.giorno} non e\' stato respirato, non '
                  'deve essere acceso');
        }
      }

      // Oggi stesso e i giorni futuri del ciclo sono in attesa, non spenti:
      // "nessuna punizione" per un giorno che non e\' nemmeno finito.
      final giorniDaOggiInAvanti = perle.where(
          (p) => !p.giorno.isBefore(DateTime(oggi.year, oggi.month, oggi.day)));
      for (final p in giorniDaOggiInAvanti) {
        expect(p.stato, isNot(StatoDellaPerla.spenta),
            reason: 'il giorno ${p.giorno} non e\' ancora passato: non puo\' '
                'essere spento');
      }
    });
  });

  group('La ricucitura', () {
    test('ricuce un giorno spento recente, rispettando i due limiti', () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      final oggi = DateTime(2026, 10, 16);
      final tresGiorniFa = oggi.subtract(const Duration(days: 3));

      expect(collana.giorniRicucibili(oggi), contains(tresGiorniFa));

      final andata =
          await collana.ricuciUnaPerlaLocalmente(tresGiorniFa, now: oggi);
      expect(andata, isTrue);
      expect(respiro.eRespirato(tresGiorniFa), isTrue);
      final perla =
          collana.perle(oggi).firstWhere((p) => p.giorno == tresGiorniFa);
      expect(perla.stato, StatoDellaPerla.accesa);
    });

    test('non ricuce oltre il tetto per ciclo', () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      final oggi = DateTime(2026, 10, 16);

      var ricucite = 0;
      for (var i = 1;
          i <= IlListinoDelRespiro.massimePerleRicucitePerCiclo + 2;
          i++) {
        final giorno = oggi.subtract(Duration(days: i));
        if (await collana.ricuciUnaPerlaLocalmente(giorno, now: oggi)) {
          ricucite++;
        }
      }
      expect(ricucite, IlListinoDelRespiro.massimePerleRicucitePerCiclo,
          reason: 'il tetto per ciclo non ha fermato la ricucitura');
    });

    test('non ricuce oltre la finestra dei giorni indietro', () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      final oggi = DateTime(2026, 10, 16);
      final troppoIndietro = oggi.subtract(
          const Duration(days: IlListinoDelRespiro.massimoGiorniIndietro + 5));

      expect(collana.giorniRicucibili(oggi), isNot(contains(troppoIndietro)));
      final andata =
          await collana.ricuciUnaPerlaLocalmente(troppoIndietro, now: oggi);
      expect(andata, isFalse);
    });
  });

  group('La consegna, alla Luna nuova', () {
    test('non parte se nessun giorno del ciclo chiuso e\' stato respirato',
        () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      expect(collana.consegnaInAttesa(DateTime(2026, 10, 16)), isFalse);
    });

    test('segnaConsegnata archivia la collana e non la rifa\' partire',
        () async {
      SharedPreferences.setMockInitialValues({});
      final respiro = IlRespiroDellaLuna();
      await respiro.leggi();
      final collana = LaCollanaDelleLune(respiro: respiro);
      final oggi = DateTime(2026, 10, 16);
      final ciclo = collana.cicloDi(oggi);
      // Si simula un ciclo chiuso con un giorno respirato, scrivendo
      // direttamente lo stato persistito come lo troverebbe l'app, cosi'
      // la prova non dipende da quando la Luna nuova vera e' caduta.
      await respiro
          .segnaRespirato(ciclo.inizio.subtract(const Duration(days: 2)));

      await collana.segnaConsegnata(oggi);
      expect(collana.scrigno, isNotEmpty);
      expect(collana.scrigno.last.perleAccese, greaterThanOrEqualTo(1));
    });
  });

  group('La schermata vera', () {
    Widget host(Widget scena,
            {required QuestionAllowance borsa,
            required IlCerchioSociale sociale}) =>
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
            ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        );

    /// **LA RICUCITURA VERA, ordine FX aggiunta FXA.03.** Si tocca la perla
    /// spenta, compare l'ago col filo, poi la conferma della spesa vestita
    /// coi pezzi dipinti; pagato sul server (la porta finta risponde ok), la
    /// perla si accende e non offre piu' la ricucitura.
    testWidgets('mostra la collana dipinta e ricuce una perla pagando gli Eos',
        (tester) async {
      final oggi = DateTime(2026, 10, 16, 9);
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      final borsa = QuestionAllowance();
      await borsa.applicaSaldo(100);
      final porta = PortaFintaDelCerchioSociale();
      final sociale = IlCerchioSociale(porta: porta);

      await tester.pumpWidget(host(LaCollanaDelleLuneScreen(now: oggi),
          borsa: borsa, sociale: sociale));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(find.text('La Collana delle Lune'), findsOneWidget);
      expect(find.byKey(const Key('collana_nome_ciclo')), findsOneWidget);
      // La guida: dove sei, cosa fare, l'obiettivo.
      expect(find.byKey(const Key('collana_perla_di_oggi')), findsOneWidget);
      expect(find.byKey(const Key('collana_obiettivo')), findsOneWidget);
      expect(
          find.byKey(const Key('collana_invito_ricucitura')), findsOneWidget);

      final tresGiorniFa = oggi.subtract(const Duration(days: 3));
      final giorno =
          DateTime(tresGiorniFa.year, tresGiorniFa.month, tresGiorniFa.day);
      final tocco =
          find.byKey(Key('collana_ricuci_${IlRespiroDellaLuna.data(giorno)}'));
      expect(tocco, findsOneWidget,
          reason: 'un giorno spento recente dovrebbe offrire la ricucitura');

      await tester.tap(tocco, warnIfMissed: false);
      await tester.pump();
      expect(find.byKey(const Key('collana_ago_e_filo')), findsOneWidget,
          reason: 'l\'ago col filo compare sulla perla prima della conferma');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('conferma_spesa')), findsOneWidget);
      expect(
          find.text('Questa richiesta costa 25 Eos. Nel tuo borsellino ce '
              'ne sono 100.'),
          findsOneWidget);
      await tester.tap(find.byKey(const Key('conferma_spesa_procedi')));
      await tester.pumpAndSettle();

      expect(
          porta.chieste.map((c) => c.$1), contains('ricuciUnaPerlaDelRespiro'),
          reason: 'la ricucitura deve passare dal server, non solo dal '
              'telefono');
      expect(tocco, findsNothing,
          reason: 'ricucita, la perla non offre piu\' la ricucitura');
      expect(find.byKey(const Key('collana_ago_e_filo')), findsNothing);
    });

    test('nessuna finestra promette una funzione che non c\'e\'', () {
      final s = File(
              'lib/features/respiro_della_luna/la_collana_delle_lune_screen.dart')
          .readAsStringSync();
      expect(s.contains('prossimo aggiornamento'), isFalse,
          reason: 'FXA.03: via la finestra "arriva con il prossimo '
              'aggiornamento"');
    });
  });
}
