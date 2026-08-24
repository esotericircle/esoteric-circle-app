import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/promessa_della_registrazione.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL PREMIO DELLA REGISTRAZIONE SI DICHIARA, E COL NUMERO DEL SERVER.
/// Ordine BH voce 01. Parole del fondatore: il premio "proprio scritto
/// nell'invito a registrarsi, cosi' l'utente e' piu' motivato", e i 250
/// legati SOLO alla prima registrazione. Qui le guardie del lato client:
/// il numero viaggia dal server, la promessa lo scrive, e gli inviti la
/// portano tutti e tre.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('la porta legge il listino della registrazione', () {
    final stato = StatoDelCerchio.daMappa({
      'giorno': '2026-08-24',
      'spesi': const {'domande': 0},
      'saldoEos': 20,
      'listinoDellaRegistrazione': const {'benvenuto': 250},
    });
    expect(stato!.premioDellaRegistrazione, 250,
        reason: 'il premio della registrazione non arriva piu\' dalla porta');
    final muto = StatoDelCerchio.daMappa({
      'giorno': '2026-08-24',
      'spesi': const {'domande': 0},
      'saldoEos': 20,
    });
    expect(muto!.premioDellaRegistrazione, isNull,
        reason: 'un server piu\' vecchio non deve inventare un premio');
  });

  testWidgets('la promessa scrive il numero del server, e senza tace',
      (tester) async {
    final borsa = QuestionAllowance(porta: _PortaDelPremio());
    await borsa.sincronizza();
    late String conNumero;
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: borsa,
      child: Builder(builder: (context) {
        conNumero = PromessaDellaRegistrazione.frase(context);
        return const SizedBox.shrink();
      }),
    ));
    expect(conNumero, contains('250 Eos'),
        reason: 'la promessa non scrive il numero del server');

    // Senza borsa (albero parziale) la promessa resta viva ma senza numero:
    // un numero inventato e' una bugia in attesa.
    late String senzaNumero;
    await tester.pumpWidget(Builder(builder: (context) {
      senzaNumero = PromessaDellaRegistrazione.frase(context);
      return const SizedBox.shrink();
    }));
    expect(senzaNumero.contains(RegExp(r'\d')), isFalse,
        reason: 'senza server la promessa scrive un numero inventato');
    expect(senzaNumero, contains('dono'),
        reason: 'senza numero la promessa deve restare viva');
  });

  test('i tre inviti portano la promessa, enumerati', () {
    const inviti = [
      'lib/features/account/custodia_del_cielo.dart',
      'lib/features/onboarding/custodia_del_cielo_step.dart',
      'lib/features/account/account_screen.dart',
    ];
    for (final percorso in inviti) {
      expect(
          File(percorso)
              .readAsStringSync()
              .contains('PromessaDellaRegistrazione.'),
          isTrue,
          reason: '$percorso invita a registrarsi senza dichiarare il '
              'premio: la regola di BH.01 e\' caduta proprio dove serve');
    }
  });

  test('chi torna non riceve la promessa del premio', () {
    // Il foglio per chi torna entra con un account che il benvenuto lo ha
    // gia' consumato: promettere il premio li' sarebbe promettere il falso.
    final s = File('lib/features/account/custodia_del_cielo.dart')
        .readAsStringSync();
    expect(s.contains('if (!widget.perChiTorna) ...['), isTrue,
        reason: 'la promessa compare anche nel foglio per chi torna');
  });
}

class _PortaDelPremio extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-08-24',
        'spesi': const {'domande': 0},
        'saldoEos': 20,
        'listinoDellaRegistrazione': const {'benvenuto': 250},
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
