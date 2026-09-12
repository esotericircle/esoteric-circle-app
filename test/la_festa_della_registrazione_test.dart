import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/features/account/festa_della_registrazione.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA FESTA DELLA REGISTRAZIONE E LE SUE TRE VERITA'. Ordine BH voce 02.
///
/// Parole del fondatore: "subito dopo, ovviamente, vorrei una festa
/// dedicata alla registrazione e al premio". La festa si apre solo se il
/// benvenuto e' DAVVERO arrivato; quando il premio non c'e' (la lapide lo
/// ha fermato) si dice il perche', mai un silenzio.
Widget _casa(Widget figlio, {QuestionAllowance? borsa}) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        if (borsa != null) ChangeNotifierProvider.value(value: borsa),
      ],
      child: MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaestroScope(child: figlio),
        ),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('la scena dice il premio col numero, e Continua la chiude',
      (tester) async {
    await tester.pumpWidget(_casa(const FestaDellaRegistrazione(premio: 250)));
    expect(find.byKey(const Key('festa_della_registrazione')), findsOneWidget);
    expect(find.text('Sei nel Cerchio'), findsOneWidget);
    expect(find.text('+250 Eos'), findsOneWidget,
        reason: 'la festa non dichiara il numero del premio');
    await tester.tap(find.byKey(const Key('festa_registrazione_continua')));
    await tester.pumpAndSettle();
  });

  testWidgets('senza numero dal server la festa parla del dono, senza cifre',
      (tester) async {
    await tester.pumpWidget(_casa(const FestaDellaRegistrazione()));
    final testo = tester
        .widget<Text>(find.byKey(const Key('festa_registrazione_premio')))
        .data;
    expect(testo!.contains(RegExp(r'\d')), isFalse,
        reason: 'senza il listino del server la festa inventa un numero');
  });

  testWidgets('col benvenuto arrivato la festa si apre da sola',
      (tester) async {
    final borsa = QuestionAllowance(porta: _PortaConBenvenuto());
    late BuildContext dentro;
    await tester.pumpWidget(_casa(
      Builder(builder: (context) {
        dentro = context;
        return const SizedBox.shrink();
      }),
      borsa: borsa,
    ));
    final futuro = FestaDellaRegistrazione.dopoLaCustodia(dentro);
    // Pompe a tempo, non pumpAndSettle: la rotta spinta sta sopra il
    // MediaQuery della prova e il fondo cosmico non si ferma mai.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('festa_della_registrazione')), findsOneWidget,
        reason: 'il benvenuto e\' arrivato e la festa non si e\' aperta');
    await tester.tap(find.byKey(const Key('festa_registrazione_continua')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await futuro;
  });

  testWidgets('col premio fermato dalla lapide si dice il perche\'',
      (tester) async {
    final borsa = QuestionAllowance(porta: _PortaSenzaBenvenuto());
    late BuildContext dentro;
    await tester.pumpWidget(_casa(
      Scaffold(
        body: Builder(builder: (context) {
          dentro = context;
          return const SizedBox.shrink();
        }),
      ),
      borsa: borsa,
    ));
    await FestaDellaRegistrazione.dopoLaCustodia(dentro);
    await tester.pump();
    expect(find.byKey(const Key('registrazione_senza_festa')), findsOneWidget,
        reason: 'il premio non e\' arrivato e nessuno lo ha detto');
    expect(find.textContaining('non si ripete'), findsOneWidget,
        reason: 'la riga onesta della lapide e\' sparita');
    expect(find.byKey(const Key('festa_della_registrazione')), findsNothing,
        reason: 'si festeggia un premio che non e\' arrivato');
  });

  test('i due atterraggi della custodia chiamano la festa', () {
    for (final percorso in const [
      'lib/features/account/custodia_del_cielo.dart',
      'lib/features/onboarding/custodia_del_cielo_step.dart',
    ]) {
      expect(
          File(percorso)
              .readAsStringSync()
              .contains('FestaDellaRegistrazione.dopoLaCustodia'),
          isTrue,
          reason: '$percorso registra senza festeggiare: la voce 02 e\' '
              'scollegata proprio dove la registrazione riesce');
    }
  });
}

class _PortaConBenvenuto extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-08-24',
        'spesi': const {'domande': 0},
        'saldoEos': 270,
        'cerchioNuovo': true,
        'listinoDellaRegistrazione': const {'benvenuto': 250},
        'accreditati': const [
          {'motivo': 'benvenuto', 'quanti': 250},
          {'motivo': 'accredito_del_giorno', 'quanti': 20},
        ],
      });

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      null;

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}

class _PortaSenzaBenvenuto extends _PortaConBenvenuto {
  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-08-24',
        'spesi': const {'domande': 0},
        'saldoEos': 20,
        'cerchioNuovo': true,
        'listinoDellaRegistrazione': const {'benvenuto': 250},
        'accreditati': const [
          {'motivo': 'accredito_del_giorno', 'quanti': 20},
        ],
      });
}
