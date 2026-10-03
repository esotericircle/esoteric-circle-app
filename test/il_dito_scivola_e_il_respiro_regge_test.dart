import 'package:esoteric_circle/core/sensi/respiro_guidato_dal_dito.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL DITO SCIVOLA E IL RESPIRO REGGE.** Ordine DA voci 01 e 02,
/// 10 settembre 2026.
///
/// **DA DOVE NASCE, e non da una prova.** Nel manifesto dell'ordine DB, alla
/// voce 12, avevo scritto dove il gesto del dito si sarebbe rotto davvero:
///
/// 1. **quando la persona chiude gli occhi**, che e' proprio quello che l'app
///    le chiede. Un dito fermo a occhi chiusi scivola, e uno scivolo valeva
///    come un dito alzato: il respiro risultava finito quando non lo era;
/// 2. **quando arriva una telefonata**. L'app va in secondo piano col dito
///    giu' e al ritorno il respiro e' aperto da tre minuti, e quel numero
///    entra nella media, nella figura della card e nella memoria.
///
/// **Il fondatore ha detto di procedere, e questa guardia e' la misura.**
///
/// **REGOLA H, la presenza non basta.** Non si prova solo che il tremolio
/// venga assorbito: si prova anche che **un espiro vero continui a contare**,
/// altrimenti la cura si mangerebbe i respiri di chi respira corto, e che
/// **il fiore non riparta da chiuso** dopo uno scivolo, perche' quella
/// sarebbe la bugia visibile dello stesso difetto.
void main() {
  final zero = DateTime(2026, 9, 10, 8);

  test('LO SCIVOLO DI UN ATTIMO NON CHIUDE IL RESPIRO', () {
    final r = RespiroGuidatoDalDito();
    r.ditoGiu(zero);
    // Tre secondi di inspiro, poi il contatto salta per centoventi
    // millisecondi, sotto la soglia dei duecento.
    r.ditoSu(zero.add(const Duration(seconds: 3)));
    r.ditoGiu(zero.add(const Duration(seconds: 3, milliseconds: 120)));
    // ignore: avoid_print
    print('ORDINE DA VOCE 01: dopo lo scivolo la fase e ${r.fase}, tremolii '
        'assorbiti ${r.tremoliiAssorbiti}, respiri chiusi ${r.quanti}');
    expect(r.fase, FaseDelRespiro.dentro,
        reason: 'dopo uno scivolo di 120 millisecondi il respiro risulta '
            'finito: a occhi chiusi la meditazione si spezza da sola');
    expect(r.tremoliiAssorbiti, 1);
    expect(r.quanti, 0,
        reason: 'lo scivolo ha chiuso un respiro che non era finito');
  });

  test('E IL FIORE NON RIPARTE DA CHIUSO, che sarebbe la bugia visibile', () {
    final r = RespiroGuidatoDalDito();
    r.ditoGiu(zero);
    final primaDelloScivolo =
        r.aperturaAdesso(zero.add(const Duration(seconds: 3)));
    r.ditoSu(zero.add(const Duration(seconds: 3)));
    r.ditoGiu(zero.add(const Duration(seconds: 3, milliseconds: 120)));
    final dopoLoScivolo =
        r.aperturaAdesso(zero.add(const Duration(seconds: 3, milliseconds: 200)));
    // ignore: avoid_print
    print('ORDINE DA VOCE 01: apertura prima dello scivolo '
        '${primaDelloScivolo.toStringAsFixed(3)}, subito dopo '
        '${dopoLoScivolo.toStringAsFixed(3)}');
    expect(dopoLoScivolo, greaterThanOrEqualTo(primaDelloScivolo),
        reason: 'dopo lo scivolo il fiore e tornato indietro: il tempo '
            'dell inspiro e ripartito da zero, e chi guarda vede il respiro '
            'annullarsi mentre lui non ha smesso');
  });

  test('REGOLA H: UN ESPIRO VERO CONTINUA A CONTARE', () {
    // **Senza questa prova la cura si mangerebbe i respiri veri.** Chi respira
    // corto alza il dito e lo rimette giu' dopo mezzo secondo, e quello e' un
    // respiro, non un tremolio.
    final r = RespiroGuidatoDalDito();
    r.ditoGiu(zero);
    r.ditoSu(zero.add(const Duration(seconds: 2)));
    r.ditoGiu(zero.add(const Duration(seconds: 2, milliseconds: 600)));
    // ignore: avoid_print
    print('ORDINE DA VOCE 01: con un espiro da 600 millisecondi i respiri '
        'chiusi sono ${r.quanti} e i tremolii ${r.tremoliiAssorbiti}');
    expect(r.tremoliiAssorbiti, 0,
        reason: 'un espiro da 600 millisecondi e stato scambiato per un '
            'tremolio: la cura si mangia i respiri di chi respira corto');
  });

  test('IL DISTACCO ESATTAMENTE SULLA SOGLIA E UN ESPIRO', () {
    // Il confine si dichiara invece di lasciarlo al caso: duecento
    // millisecondi netti stanno DALLA PARTE del respiro vero.
    final r = RespiroGuidatoDalDito();
    r.ditoGiu(zero);
    r.ditoSu(zero.add(const Duration(seconds: 2)));
    r.ditoGiu(zero.add(const Duration(seconds: 2)).add(
        RespiroGuidatoDalDito.sogliaDelTremolio));
    expect(r.tremoliiAssorbiti, 0,
        reason: 'il distacco lungo esattamente quanto la soglia e stato '
            'assorbito: il confine e dichiarato al contrario di come e '
            'scritto');
  });

  test('UN RESPIRO PIU LUNGO DI UN MINUTO NON ENTRA', () {
    final r = RespiroGuidatoDalDito();
    // Il caso vero: la telefonata arriva col dito giu'.
    r.ditoGiu(zero);
    r.ditoSu(zero.add(const Duration(minutes: 3)));
    final chiuso = r.chiudiIlRespiro(
        zero.add(const Duration(minutes: 3, seconds: 4)));
    // ignore: avoid_print
    print('ORDINE DA VOCE 02: dopo un dentro da tre minuti i respiri sono '
        '${r.quanti}, gli scartati ${r.scartati}, la figura ha '
        '${r.figura.length} punti');
    expect(chiuso, isNull,
        reason: 'un mezzo respiro da tre minuti e stato accettato come '
            'respiro');
    expect(r.quanti, 0);
    expect(r.scartati, 1,
        reason: 'il respiro scartato non viene contato: un conto che cala in '
            'silenzio e il modo migliore per non accorgersi mai di un difetto');
    expect(r.figura, isEmpty,
        reason: 'il respiro impossibile e finito nella figura della card');
  });

  test('REGOLA H: UN RESPIRO LENTO MA UMANO ENTRA', () {
    // **Il confine e largo apposta.** Venti secondi dentro e venti fuori sono
    // un respiro lentissimo ma vero, e chi lo fa non deve vederselo buttare.
    final r = RespiroGuidatoDalDito();
    r.ditoGiu(zero);
    r.ditoSu(zero.add(const Duration(seconds: 20)));
    final chiuso = r.chiudiIlRespiro(zero.add(const Duration(seconds: 40)));
    // ignore: avoid_print
    print('ORDINE DA VOCE 02: un respiro da 20 secondi dentro e 20 fuori '
        'entra: ${chiuso != null}, scartati ${r.scartati}');
    expect(chiuso, isNotNull,
        reason: 'un respiro lento ma umano e stato scartato: la soglia e '
            'stretta e punisce proprio chi medita davvero');
    expect(r.scartati, 0);
  });

  test('LE DUE SOGLIE SONO DICHIARATE E HANNO UN ORDINE DI GRANDEZZA SENSATO',
      () {
    // Una guardia che non guarda i numeri lascia che qualcuno li cambi per far
    // passare una prova. Qui il rapporto fra le due e' dichiarato.
    const tremolio = RespiroGuidatoDalDito.sogliaDelTremolio;
    const massimo = RespiroGuidatoDalDito.respiroPiuLungoCheAbbiaSenso;
    const riferimento = RespiroGuidatoDalDito.riferimentoDelRespiro;
    // ignore: avoid_print
    print('ORDINE DA: tremolio ${tremolio.inMilliseconds} ms, riferimento '
        '${riferimento.inSeconds} s, massimo ${massimo.inSeconds} s');
    expect(tremolio.inMilliseconds * 5, lessThan(riferimento.inMilliseconds),
        reason: 'la soglia del tremolio non e molto piu piccola del respiro '
            'di riferimento: cosi non separa il rumore dal gesto');
    expect(massimo.inSeconds, greaterThan(riferimento.inSeconds * 4),
        reason: 'il tetto del respiro e troppo vicino al riferimento, e '
            'butterebbe via i respiri lenti di chi medita davvero');
  });
}
