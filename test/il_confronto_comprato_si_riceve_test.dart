// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **CHI COMPRA UN CONFRONTO LO RICEVE.** Ordine EE voce 08, 23 settembre
/// 2026.
///
/// **Il fatto del fondatore, verbatim**: *"ho fatto test a partire da una
/// stesa di tarocchi: dopo il responso ho acquistato con 150 EOS
/// l'approfondimento con il confronto dei 3 maestri. prima di tutto il
/// contatore non mostrava che avevo ancora un'approfondimento, ma ho potuto
/// aprirlo e, una volta aperto l'approfondimento, mi ha mostrato solo la
/// risposta di Medora e non gli altri Maestri. allora ho sottoscritto
/// l'abbonamento e i contatori si sono aggiornati"*.
///
/// **LA CAUSA, ed era una riga.** Il Consiglio chiedeva a `canCompare`, che
/// guarda **il piano**: sul piano senza confronti la risposta e' no, e le
/// altre due lenti non venivano nemmeno chieste. Ma chi compra un confronto
/// con gli Eos **non cambia piano**: il riscatto porta il contatore sotto
/// zero, e il credito vive nei rimasti.
///
/// **Padre: ordine BG voce 05.** Quella voce ha scritto la regola giusta,
/// *"il cancello guarda i rimasti, non il piano, cosi' il credito riscattato
/// con gli Eos si spende davvero"*, e l'ha applicata agli approfondimenti e
/// alle stese: **la porta del confronto e' rimasta fuori**.
///
/// **Questa prova misura il contatore, non la schermata**, ed e' voluto: il
/// difetto non era nel disegno delle carte, era nella domanda che la
/// schermata faceva. Che la schermata chieda ai rimasti lo pretende la terza
/// prova, sul sorgente.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('sul piano senza confronti, il piano dice no e i rimasti pure', () {
    final contatore = QuestionAllowance();
    print('ORDINE EE VOCE 08, piano Free: il piano concede '
        '${contatore.canCompare(Tier.free)}, rimasti '
        '${contatore.confrontiRimasti(Tier.free)}');
    expect(contatore.canCompare(Tier.free), isFalse,
        reason: 'il piano Free comprende gia\' i confronti: questa prova non '
            'distinguerebbe piu\' il piano dal credito comprato');
    expect(contatore.puoiConfrontare(Tier.free), isFalse);
  });

  test('col credito comprato il piano dice ancora no, e i rimasti dicono si',
      () {
    // **Il caso del fondatore.** Il riscatto porta il contatore sotto zero:
    // qui si simula quello che `riscatta` fa dopo che il server ha risposto,
    // senza passare dalla porta, che in una prova non c'e'.
    final contatore = QuestionAllowance()..confrontiPerLaProva = -1;
    final ilPiano = contatore.canCompare(Tier.free);
    final iRimasti = contatore.puoiConfrontare(Tier.free);
    print('ORDINE EE VOCE 08, col credito comprato: il piano concede '
        '$ilPiano, i rimasti concedono $iRimasti');
    expect(iRimasti, isTrue,
        reason: 'chi ha comprato un confronto non lo puo\' spendere');
    expect(ilPiano, isFalse,
        reason: 'il piano si e\' messo a concedere il confronto: la prova non '
            'starebbe piu\' misurando la differenza fra i due cancelli, che '
            'e\' tutto il difetto di questa voce');
  });

  test('e il Consiglio chiede ai RIMASTI, non al piano', () {
    // **La meta' che prende il difetto vero.** Le due prove qui sopra dicono
    // che i due cancelli rispondono diverso; questa dice quale dei due la
    // schermata interroga prima di chiedere le altre due letture.
    final sorgente = File('lib/features/maestri/ask/ask_maestri_screen.dart')
        .readAsStringSync();
    final dove = sorgente.indexOf('final puoConfrontare');
    expect(dove, greaterThan(-1),
        reason: 'la schermata non decide piu\' se confrontare: la prova '
            'misurerebbe il vuoto');
    final riga =
        sorgente.substring(dove, (dove + 120).clamp(0, sorgente.length));
    print('ORDINE EE VOCE 08, la schermata chiede a: '
        '${riga.contains('puoiConfrontare') ? 'i rimasti' : 'il piano'}');
    expect(riga.contains('puoiConfrontare'), isTrue,
        reason: 'il Consiglio chiede al PIANO se confrontare, quindi chi ha '
            'comprato un confronto con gli Eos vede una sola lettura: e\' il '
            'difetto della voce EE.08');
  });
}
