import 'package:flutter_test/flutter_test.dart';

import '../tool/controlli_ej.dart';

/// **I CONTROLLI DEL COLLAUDO EJ PRENDONO I DIFETTI DELLE CATTURE.** Ordine EJ
/// voci 05, 07 e 08, 24 settembre 2026.
///
/// Il collaudo con Gemini vero conta chiusure ripetute, frasi vietate, dati
/// ripetuti, anticipazioni ed errori di lingua. Se uno di questi conti fosse
/// cieco, il collaudo direbbe zero sul prodotto sbagliato. Qui ogni controllo
/// riceve le frasi vere delle catture del fondatore, e deve vederle.
void main() {
  const dati = [
    DatoDellaPersona('ascendente', ['Ascendente in Gemelli', 'Gemelli']),
    DatoDellaPersona('sole', ['Cancro']),
    DatoDellaPersona('numero', ['numero della vita', 'Creativo']),
  ];

  RispostaLetta r(String corpo, [String riga = '']) =>
      RispostaLetta(corpo: corpo, riga: riga);

  test('CINQUE RISPOSTE CON LA STESSA RIGA: OGNI SUA FRASE TORNA QUATTRO VOLTE',
      () {
    final conv = [
      for (var i = 0; i < 5; i++)
        r('Risposta numero $i.',
            'Parla chiaro al tuo capo. Ripassa fra 2 giorni, per la Luna piena.'),
    ];
    expect(chiusureRipetute(conv), 8,
        reason: 'la sintesi e l\'invito si ripetono quattro volte ciascuno');
    final diverse = [
      r('Uno.', 'Scrivi le tre cose che vuoi dirgli.'),
      r('Due.', 'Chiedi la riunione per giovedi.'),
    ];
    expect(chiusureRipetute(diverse), 0);
  });

  test('COMPRENDO LA TUA INQUIETUDINE E\' UNA FRASE VIETATA', () {
    expect(frasiVietate(r('Comprendo la tua inquietudine. Il cielo parla.')),
        hasLength(1));
    expect(
        frasiVietate(r('Il cielo parla. Capisco che sia dura.')), hasLength(1),
        reason: 'anche in mezzo al testo');
    expect(frasiVietate(r('Il tuo Cancro solare chiede riparo.')), isEmpty);
  });

  test('GLI STESSI TRE DATI IN OGNI RISPOSTA SI CONTANO DALLA SECONDA', () {
    final conv = [
      for (var i = 0; i < 3; i++)
        r('Con l\'Ascendente in Gemelli, il tuo Cancro solare e il numero '
            'della vita 3, oggi scegli.'),
    ];
    expect(datiRipetuti(conv, dati), 6);
    expect(
        datiRipetuti([
          r('Il tuo Cancro solare cerca casa.'),
          r('Parla col capo giovedi.'),
        ], dati),
        0);
  });

  test('LA RUNA E IL CHAKRA DI DOMANI SONO ANTICIPAZIONI', () {
    expect(
        anticipazioni(
            r('Corpo.', 'Torna domani sera: la runa che scende è Fehu.')),
        hasLength(1));
    expect(
        anticipazioni(r('Corpo.',
            'Torna domani: si apre la gola, che governa ciò che dici.')),
        hasLength(1));
    expect(
        anticipazioni(r('Corpo.', 'Torna domani sera, al tramonto.')), isEmpty,
        reason: 'invitare a tornare e\' permesso, svelare il dono no');
    // Falso positivo vero del collaudo EJ, Aura, 24 settembre 2026: parla di
    // adesso, e "scendere" non e' un futuro.
    expect(
        anticipazioni(r('Porta questa immagine nel tuo respiro, lasciala '
            'scendere verso il centro del tuo cuore, Anahata.')),
        isEmpty);
    expect(
        anticipazioni(r('Corpo.',
            'Ripassa quando sarà il giorno di Vishuddha, ciò che dici.')),
        hasLength(1),
        reason: 'e\' una delle forme vecchie dell\'invito di Aura');
  });

  test('LE REGOLE DI LINGUA DEL PROGETTO SI CONTANO', () {
    expect(erroriDiRegola(r('Il cielo — oggi — parla.')), hasLength(1));
    expect(erroriDiRegola(r('Guarda il cielo, e poi scegli.')), hasLength(1));
    expect(
        erroriDiRegola(r("Il cielo e' chiaro perche' parla.")), hasLength(2));
    expect(erroriDiRegola(r('Il cielo è chiaro e parla.')), isEmpty);
  });

  test('"IL CALMO DEL TUO RESPIRO" E\' UN ERRORE DI LINGUA', () {
    // Ordine EK voce 02: l'errore di Aura nel collaudo EJ, "senti il calmo
    // del tuo respiro", entra nel controllo della lingua. "Calmo" e'
    // aggettivo: usato come nome e' sbagliato ("la calma"); davanti a un nome
    // e' giusto ("il calmo respiro"), e il controllo non deve prenderlo.
    expect(erroriDiRegola(r('Senti il calmo del tuo respiro.')), hasLength(1));
    expect(erroriDiRegola(r('Resta nel calmo della sera.')), hasLength(1));
    expect(erroriDiRegola(r('Segui il calmo respiro della sera.')), isEmpty);
    expect(erroriDiRegola(r('Senti la calma del tuo respiro.')), isEmpty);
  });
}
