import 'dart:io';

import 'package:esoteric_circle/core/cammino/ritrovamento.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UN CERCHIO APPENA NATO NON RICEVE IL BENTORNATO. Ordine BG voce 01.
///
/// **Il fatto del fondatore sulla 2201**: account e dati cancellati, build
/// nuova, tocco su "Faccio gia' parte del Cerchio" con la solita email
/// Google, e la scena gli dice "Bentornato nel Cerchio. Il Cerchio ti aveva
/// tenuto tutto. 270 Eos". **La causa, in due meta'**: con Google non esiste
/// "email gia' in uso", il provider CREA un account nuovo in silenzio; e il
/// ritrovamento decideva "c'e' qualcosa da mostrare" con `Eos > 0`, ma un
/// Cerchio appena nato ha GIA' 270 Eos di dote (benvenuto piu' giorno),
/// quindi ogni neonato sembrava un ritorno.
///
/// **Il segnale vero e' il benvenuto**: si accredita una volta sola nella
/// vita di un Cerchio. Se l'ultima sincronia lo ha accreditato, il Cerchio
/// e' nato adesso: niente Bentornato, niente "ti aveva tenuto tutto", e alla
/// persona si dice la verita' con la riga del Cerchio appena nato.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('la dote di nascita non e\' una cosa tenuta', () {
    final neonato = Ritrovamento.da(
      null,
      saldoEos: 270,
      cerchioAppenaNato: true,
    );
    expect(neonato.qualcosaDaMostrare, isFalse,
        reason: 'un Cerchio appena nato con la sola dote riceve di nuovo il '
            'Bentornato: e\' il fatto della 2201');

    final ritorno = Ritrovamento.da(null, saldoEos: 715);
    expect(ritorno.qualcosaDaMostrare, isTrue,
        reason: 'un ritorno vero con gli Eos tenuti non mostra piu\' niente: '
            'la cura ha ucciso il ritrovamento buono');
  });

  test('la borsa riconosce la nascita dal benvenuto, e solo da quello',
      () async {
    final porta = _PortaConMemoria();
    final borsa = QuestionAllowance(porta: porta);

    // Prima sincronia: il benvenuto arriva, il Cerchio e' appena nato.
    porta.accreditati = const [
      {'motivo': 'benvenuto', 'quanti': 250},
      {'motivo': 'accredito_del_giorno', 'quanti': 20},
    ];
    await borsa.sincronizza();
    expect(borsa.cerchioAppenaNato, isTrue,
        reason: 'il benvenuto e\' appena stato accreditato e la borsa non '
            'riconosce la nascita');

    // Seconda sincronia: solo il giorno. Non e' piu' una nascita.
    porta.accreditati = const [
      {'motivo': 'accredito_del_giorno', 'quanti': 20},
    ];
    await borsa.sincronizza();
    expect(borsa.cerchioAppenaNato, isFalse,
        reason: 'la nascita e\' rimasta appiccicata oltre la sua chiamata: '
            'ogni apertura sembrerebbe un primo giorno');
  });

  test('il Custode passa la nascita e la dice con la riga onesta', () {
    final sorgente =
        File('lib/core/cammino/custode_del_cammino.dart').readAsStringSync();
    expect('cerchioAppenaNato: '.allMatches(sorgente).length,
        greaterThanOrEqualTo(2),
        reason: 'una delle due strade del ritrovamento non passa piu\' la '
            'nascita: da quella strada il Bentornato tornerebbe');
    expect(sorgente.contains("Key('cerchio_appena_nato')"), isTrue,
        reason: 'a chi entra su un Cerchio appena nato non si dice piu\' '
            'niente: si ritrova nell\'onboarding senza sapere perche\'');
  });
}

/// Una porta che accredita cio' che le si dice, chiamata dopo chiamata.
class _PortaConMemoria extends PortaDelCerchio {
  List<Map<String, Object>> accreditati = const [];

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-08-24',
        'spesi': const {'domande': 0},
        'saldoEos': 270,
        'accreditati': accreditati,
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
