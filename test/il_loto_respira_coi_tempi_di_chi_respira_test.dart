import 'package:esoteric_circle/core/sensi/respiro_guidato_dal_dito.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL LOTO RESPIRA COI TEMPI DI CHI RESPIRA.** Ordine CZ, voce 08.
///
/// **Parole del fondatore**: *"Il ritmo non e' un preset. L'utente tiene il
/// dito sullo schermo mentre inspira e lo alza quando espira, e sono i suoi
/// tempi reali a muovere il fiore."*
///
/// **REGOLA H.** Non basta provare che il fiore si apre: si prova anche che
/// **nessun ritmo fisso** lo governa. Una prova che guardasse solo l'apertura
/// sarebbe verde anche su un cerchio che si gonfia da solo a quattro secondi,
/// cioe' su quello che il fondatore ha chiesto di togliere.
void main() {
  final t0 = DateTime(2026, 9, 8, 6, 0, 0);

  test('Di partenza il fiore e\' chiuso e nessun respiro e\' compiuto', () {
    final r = RespiroGuidatoDalDito();
    expect(r.fase, FaseDelRespiro.attesa);
    expect(r.aperturaAdesso(t0), 0.0);
    expect(r.quanti, 0);
  });

  test('Col dito giu\' il fiore si apre, e si apre col TEMPO VERO', () {
    final r = RespiroGuidatoDalDito(riferimento: const Duration(seconds: 4));
    r.ditoGiu(t0);
    expect(r.aperturaAdesso(t0), 0.0,
        reason: 'appena posato il dito il fiore e\' gia\' aperto');
    expect(r.aperturaAdesso(t0.add(const Duration(seconds: 2))), closeTo(0.5, 0.01),
        reason: 'a meta\' del riferimento il fiore non e\' a meta\'');
    expect(r.aperturaAdesso(t0.add(const Duration(seconds: 4))), 1.0);
    expect(r.aperturaAdesso(t0.add(const Duration(seconds: 9))), 1.0,
        reason: 'chi tiene il dito piu\' a lungo deve trovare il fiore tutto '
            'aperto, non oltre: l\'apertura e\' una quota, non un conto');
  });

  test('Alzato il dito il fiore si chiude, e ci mette QUANTO L\'INSPIRO', () {
    // **LA SIMMETRIA SENZA IL RITMO.** Chi ha inspirato sei secondi vede il
    // fiore chiudersi in sei: il gesto e' simmetrico e nessuno gli ha imposto
    // un numero.
    final r = RespiroGuidatoDalDito();
    r.ditoGiu(t0);
    r.ditoSu(t0.add(const Duration(seconds: 6)));
    final su = t0.add(const Duration(seconds: 6));
    expect(r.aperturaAdesso(su), 1.0);
    expect(r.aperturaAdesso(su.add(const Duration(seconds: 3))),
        closeTo(0.5, 0.01),
        reason: 'a meta\' dell\'espiro il fiore non e\' a meta\': la chiusura '
            'non segue la durata dell\'inspiro');
    expect(r.aperturaAdesso(su.add(const Duration(seconds: 6))), 0.0);
  });

  test('REGOLA H: NESSUN RITMO FISSO governa il fiore', () {
    // **L'assenza da provare.** Due persone che respirano in modo diverso
    // devono vedere due fiori diversi nello stesso istante. Se un preset
    // governasse il movimento, i due sarebbero identici.
    final lento = RespiroGuidatoDalDito()..ditoGiu(t0);
    final svelto = RespiroGuidatoDalDito(
        riferimento: const Duration(seconds: 4))
      ..ditoGiu(t0);
    svelto.ditoSu(t0.add(const Duration(seconds: 1)));

    final quando = t0.add(const Duration(seconds: 2));
    expect(lento.aperturaAdesso(quando), isNot(svelto.aperturaAdesso(quando)),
        reason: 'due respiri diversi danno la stessa apertura nello stesso '
            'istante: il fiore segue un orologio suo, e non il dito');
  });

  test('Un respiro compiuto porta i suoi tempi veri', () {
    final r = RespiroGuidatoDalDito();
    r.ditoGiu(t0);
    r.ditoSu(t0.add(const Duration(seconds: 5)));
    final fatto = r.chiudiIlRespiro(t0.add(const Duration(seconds: 8)));
    expect(fatto, isNotNull, reason: 'il respiro non si e\' chiuso');
    expect(fatto!.dentro, const Duration(seconds: 5));
    expect(fatto.fuori, const Duration(seconds: 3));
    expect(fatto.quotaDelDentro, closeTo(5 / 8, 0.001));
    expect(r.quanti, 1);
  });

  test('LA FIGURA E\' DIVERSA PER OGNUNO, ed e\' il motivo per condividerla',
      () {
    // Due persone, stessa durata totale, forma diversa: la figura deve
    // distinguerle. Se la card disegnasse la sola durata, tutte le card
    // sarebbero uguali e non ci sarebbe niente da mandare a nessuno.
    final unoLungoDentro = RespiroGuidatoDalDito();
    unoLungoDentro.ditoGiu(t0);
    unoLungoDentro.ditoSu(t0.add(const Duration(seconds: 6)));
    unoLungoDentro.chiudiIlRespiro(t0.add(const Duration(seconds: 8)));

    final unoLungoFuori = RespiroGuidatoDalDito();
    unoLungoFuori.ditoGiu(t0);
    unoLungoFuori.ditoSu(t0.add(const Duration(seconds: 2)));
    unoLungoFuori.chiudiIlRespiro(t0.add(const Duration(seconds: 8)));

    expect(unoLungoDentro.compiuti.first.intero,
        unoLungoFuori.compiuti.first.intero,
        reason: 'la premessa non regge: i due respiri non durano uguale, e la '
            'prova non sta misurando la FORMA');
    expect(unoLungoDentro.figura, isNot(unoLungoFuori.figura),
        reason: 'due respiri della stessa durata ma di forma opposta danno la '
            'stessa figura: la card sarebbe uguale per tutti');
  });

  test('REGOLA H: il dito alzato due volte non conta due respiri', () {
    // L'assenza: nessun respiro fantasma. Un tocco che rimbalza non deve
    // riempire la figura di respiri che nessuno ha fatto.
    final r = RespiroGuidatoDalDito();
    r.ditoSu(t0);
    expect(r.quanti, 0, reason: 'alzare un dito mai posato ha contato un '
        'respiro');
    r.ditoGiu(t0);
    r.ditoGiu(t0.add(const Duration(seconds: 1)));
    r.ditoSu(t0.add(const Duration(seconds: 4)));
    expect(r.compiuti.length, 0,
        reason: 'un respiro risulta compiuto prima che l\'espiro sia chiuso');
    r.chiudiIlRespiro(t0.add(const Duration(seconds: 6)));
    expect(r.quanti, 1,
        reason: 'due dita giu\' di fila hanno prodotto ${r.quanti} respiri '
            'invece di uno');
  });
}
