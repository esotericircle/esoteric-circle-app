import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA DOTE RACCONTA LA SUA STORIA. Ordine BF voce 01.
///
/// **Il fatto del fondatore sulla 2200**: cancellato l'account, registrato di
/// nuovo con la stessa email, e "ancora 270 Eos che non dovevano piu'
/// esserci". **La verifica**: niente sopravvive. I 270 sono la dote di
/// nascita di ogni Cerchio nuovo, 250 di benvenuto piu' 20 del giorno
/// (ordine AN voce 07), e la registrazione riuscita con la stessa email e'
/// la prova che l'account vecchio era morto: Firebase l'avrebbe rifiutata.
///
/// **Il difetto vero**: il saldo arrivava in silenzio, senza raccontare da
/// dove veniva, e un numero senza ragione e' indistinguibile da un numero
/// che torna dal passato. La cura: il server dichiara gli accrediti compiuti
/// (`accreditati`), il client li mette da parte e il Custode li scrive nel
/// registro dei movimenti con parole di persona.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('la porta legge gli accrediti del server, e con prudenza', () {
    final stato = StatoDelCerchio.daMappa({
      'giorno': '2026-08-24',
      'spesi': const {'domande': 0},
      'saldoEos': 270,
      'accreditati': [
        {'motivo': 'benvenuto', 'quanti': 250},
        {'motivo': 'accredito_del_giorno', 'quanti': 20},
        // Voci rotte, che non devono far cadere niente:
        {'motivo': '', 'quanti': 5},
        {'quanti': 5},
        'spazzatura',
      ],
    });
    expect(stato, isNotNull);
    expect(stato!.accreditati, hasLength(2),
        reason: 'le voci rotte devono cadere da sole, non far cadere tutto');
    expect(stato.accreditati.first.motivo, 'benvenuto');
    expect(stato.accreditati.first.quanti, 250);
    expect(stato.accreditati.last.motivo, 'accredito_del_giorno');
    expect(stato.accreditati.last.quanti, 20);
  });

  test('un server vecchio senza accrediti non rompe niente', () {
    final stato = StatoDelCerchio.daMappa({
      'giorno': '2026-08-24',
      'spesi': const {'domande': 0},
      'saldoEos': 100,
    });
    expect(stato!.accreditati, isEmpty);
  });

  test('la borsa mette da parte gli accrediti, e la consegna li porta via',
      () async {
    final borsa = QuestionAllowance(porta: const _PortaConLaDote());
    await borsa.sincronizza();
    final primi = borsa.prendiGliAccreditiDaRaccontare();
    expect(primi, hasLength(2),
        reason: 'gli accrediti del server non arrivano alla consegna');
    expect(borsa.prendiGliAccreditiDaRaccontare(), isEmpty,
        reason: 'la consegna non svuota: lo stesso accredito verrebbe '
            'raccontato due volte nel registro');
  });

  test('il Custode li traduce in parole di persona, non in codici', () {
    final sorgente =
        File('lib/core/cammino/custode_del_cammino.dart').readAsStringSync();
    expect(sorgente.contains('prendiGliAccreditiDaRaccontare'), isTrue,
        reason: 'nessuno porta piu\' gli accrediti al registro: il saldo '
            'torna un numero senza ragione');
    // **"DONO DI BENVENUTO" E NON "BENVENUTO NEL CERCHIO", ordine CF voce
    // 05.** Era l'unica stringa dell'app che dichiarava un genere fuori
    // dalle porte del genere: qui non c'e' nessuna scelta di forma, quindi
    // a chi aveva scelto il femminile il registro diceva comunque
    // "Benvenuto". **La pretesa non cambia**: che il benvenuto abbia la
    // sua parola invece di un codice.
    expect(sorgente.contains('Dono di benvenuto'), isTrue,
        reason: 'il benvenuto non ha piu\' la sua parola nel registro');
    expect(sorgente.contains('Dono del giorno'), isTrue,
        reason: 'l\'accredito del giorno non ha piu\' la sua parola');
    // E il motivo sconosciuto non sparisce dalla storia.
    expect(sorgente.contains('Dono del Cerchio'), isTrue,
        reason: 'un motivo nuovo del server sparirebbe dalla storia');
  });
}

class _PortaConLaDote extends PortaDelCerchio {
  const _PortaConLaDote();

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-08-24',
        'spesi': const {'domande': 0},
        'saldoEos': 270,
        'accreditati': [
          {'motivo': 'benvenuto', 'quanti': 250},
          {'motivo': 'accredito_del_giorno', 'quanti': 20},
        ],
      });

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
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
