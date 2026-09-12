import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL RISCATTO COMPRA UN USO DEL GIORNO, COL PREZZO DEL SERVER. Ordine BG
/// voce 05.
///
/// Parole del fondatore: "quando esaurisco le gettate o le stese o altre
/// funzionalita' limitate, non dovrei poterle comprare spendendo i miei
/// Eos?". E' la strada degli Eos del gating a due strade (ordine AN): il
/// prezzo lo decide il server (`PREZZI_DEL_RISCATTO`), il movimento e'
/// idempotente, e nella stessa transazione il server scala il contatore del
/// giorno, cosi' il gesto si puo' rifare subito.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('la porta legge il listino del riscatto', () {
    final stato = StatoDelCerchio.daMappa({
      'giorno': '2026-08-24',
      'spesi': const {'domande': 0},
      'saldoEos': 300,
      'listinoDelRiscatto': const {'gettate': 60, 'domande': 80},
    });
    expect(stato!.listinoDelRiscatto['gettate'], 60);
    expect(stato.listinoDelRiscatto['domande'], 80);
  });

  test('il riscatto paga, scala il contatore locale e riapre il gesto',
      () async {
    final porta = _PortaDelRiscatto(saldoIniziale: 300);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();

    // La gettata del giorno si consuma: il gratuito e' fermo.
    borsa.registraGettata(Tier.free);
    expect(borsa.puoiGettare(Tier.free), isFalse);

    final pagato = await borsa.riscatta('gettate');
    expect(pagato, 60, reason: 'il prezzo pagato non e\' quello del listino');
    expect(borsa.saldoEos, 240,
        reason: 'il saldo non segue quello che il server ha risposto');
    expect(borsa.puoiGettare(Tier.free), isTrue,
        reason: 'il riscatto e\' stato pagato ma la gettata resta chiusa: '
            'il contatore locale non e\' sceso');
    expect(porta.movimenti, hasLength(1));
    expect(porta.movimenti.single['motivo'], 'riscatto_gettate');
  });

  test('senza saldo non si chiama nessuno, e si torna nullo', () async {
    final porta = _PortaDelRiscatto(saldoIniziale: 10);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    final pagato = await borsa.riscatta('gettate');
    expect(pagato, isNull);
    expect(porta.movimenti, isEmpty,
        reason: 'con gli Eos che non bastano non si disturba il server: il '
            'no si sa gia\'');
  });

  test('il credito riscattato apre anche fuori dal piano, una volta sola',
      () async {
    // Il Viandante non ha approfondimenti (limite zero): il riscatto compra
    // UN uso, il cancello lo vede, e consumarlo lo richiude.
    final porta = _PortaDelRiscatto(saldoIniziale: 300);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    expect(borsa.puoiApprofondire(Tier.free), isFalse);

    final pagato = await borsa.riscatta('approfondimenti');
    expect(pagato, 60);
    expect(borsa.puoiApprofondire(Tier.free), isTrue,
        reason: 'il credito comprato non apre il cancello del piano');

    borsa.registraApprofondimento(Tier.free);
    expect(borsa.puoiApprofondire(Tier.free), isFalse,
        reason: 'il credito non si e\' consumato: sarebbe infinito');
  });

  test('le quattro porte esauste offrono il corredo del riscatto', () {
    const dove = {
      'lib/features/maestri/caligo/rune/rune_draw_screen.dart': 'gettate',
      'lib/features/maestri/ask/ask_maestri_screen.dart': 'domande',
    };
    dove.forEach((percorso, budget) {
      final s = File(percorso).readAsStringSync();
      expect(s.contains("corredoDelRiscatto("), isTrue,
          reason: '$percorso non offre piu\' il riscatto');
      expect(s.contains("budget: '$budget'"), isTrue,
          reason: '$percorso non riscatta il budget $budget');
    });
    final chat = File('lib/features/maestri/chat/maestro_chat_screen.dart')
        .readAsStringSync();
    for (final budget in const ['confronti', 'approfondimenti']) {
      expect(chat.contains("budget: '$budget'"), isTrue,
          reason: 'la chat non riscatta il budget $budget');
    }
  });
}

/// Una porta che risponde al riscatto come il server vero: prezzo del
/// listino, saldo che scende, movimento registrato.
class _PortaDelRiscatto extends PortaDelCerchio {
  _PortaDelRiscatto({required this.saldoIniziale});

  final int saldoIniziale;
  int _saldo = 0;
  final List<Map<String, Object?>> movimenti = [];

  static const _listino = {
    'domande': 80,
    'approfondimenti': 60,
    'confronti': 150,
    'gettate': 60,
  };

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {Object? cammino, bool azzeraIlCammino = false}) async {
    _saldo = saldoIniziale;
    return StatoDelCerchio.daMappa({
      'giorno': '2026-08-24',
      'spesi': const {'domande': 0},
      'saldoEos': saldoIniziale,
      'listinoDelRiscatto': _listino,
    });
  }

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    movimenti.add({'causale': causale, 'motivo': motivo, 'id': idMovimento});
    final budget = motivo.replaceFirst('riscatto_', '');
    _saldo -= _listino[budget] ?? 0;
    return _saldo;
  }

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
