import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'codice_senza_testo.dart';

/// **LA CHAT NON SI APRE SU MEZZO SCHERMO DI VUOTO.**
/// Ordine CO voce 12, 3 settembre 2026.
///
/// Fatto del fondatore: fra il benvenuto e ciò che sta sotto c'è mezzo schermo
/// di vuoto. **Misurato con una sonda su un telefono da 844 punti:
/// duecentosessantanove punti di nulla fra la barra e la prima bolla**, cioè
/// quasi un terzo dello schermo.
///
/// ## Due cose che la sonda ha detto e che a leggere il codice non si vedevano
///
/// **Il vuoto non era dove sembrava.** La fascia che `ScenaSopraLaConversazione`
/// riserva alla scena misura ZERO: la lista si prende tutta l'altezza che le si
/// offre, quindi non avanza mai niente. Il vuoto è DENTRO il riquadro della
/// lista, sopra i messaggi, che stanno in basso perché la lista è rovesciata.
/// La prima stesura di questa voce metteva la presenza nella fascia della
/// scena, e la presenza non compariva mai.
///
/// **E non si toglie spostando i messaggi.** La conversazione sta ancorata in
/// basso per una decisione presa e scritta: ancorata in alto, due messaggi
/// restavano appesi sotto la barra con mezzo schermo fra loro e il campo di
/// scrittura. Sono lo stesso vuoto visto dall'altro lato. **Muoverlo non lo
/// toglie, lo sposta: si toglie riempiendolo.**
///
/// Ciò che ci va era già deciso: la chat vuota mostrava il mezzo busto grande, e
/// a conversazione avviata quel busto si è rimpicciolito nella barra. Giusto a
/// conversazione piena, dove la fascia non esiste. Fra le due c'è lo stato in
/// cui il fondatore è entrato, la conversazione APPENA cominciata, dove la
/// fascia c'è tutta e non la occupa più nessuno.
void main() {
  final chat = File('lib/features/maestri/chat/maestro_chat_screen.dart')
      .readAsStringSync();
  final codice = codiceSenzaTesto(chat);

  test('la conversazione porta una voce in piu, ed e la presenza', () {
    expect(codice, contains('itemCount: messaggi.length + 1'),
        reason: 'la lista e tornata a contare i soli messaggi: sopra di loro '
            'resta il vuoto che il fondatore ha misurato a occhio e la sonda '
            'in punti');
    expect(codice, contains('_PresenzaARiposo(maestro:'),
        reason: 'nessuno costruisce piu la presenza a riposo');
  });

  test('la presenza sta in CIMA, che con la lista rovesciata e in fondo', () {
    // Rovesciata la lista, l'indice piu' alto si disegna piu' in alto: la
    // presenza deve essere l'ULTIMA voce, non la prima, o comparirebbe sotto
    // l'ultimo messaggio invece che sopra il primo.
    expect(codice, contains('if (index == messaggi.length) {'),
        reason: 'la presenza non e piu l ultima voce della lista: con la '
            'lista rovesciata comparirebbe in fondo alla conversazione invece '
            'che in cima');
  });

  test('si dichiara la propria altezza, che dentro una lista e obbligatorio',
      () {
    // I vincoli verticali dentro una lista sono senza fondo: un volto che si
    // misurasse dal genitore verrebbe alto zero, ed e' cio' che la sonda ha
    // visto alla prima stesura, un rettangolo da 148 a 148.
    expect(codice, contains('height: alta'),
        reason: 'la presenza non dichiara piu la sua altezza: dentro una '
            'lista viene alta zero e non si vede, restando verde per '
            'chiunque guardi solo se il widget c e');
    expect(codice, contains('MediaQuery.sizeOf(context).height'),
        reason: 'la presenza non misura piu lo schermo: dentro una lista non '
            'c e nessun vincolo di altezza da cui dedurre quanto spazio abbia');
  });

  test('e si toglie da sola quando non ci sta', () {
    expect(codice, contains('alta < quandoCiSta'),
        reason: 'la presenza non si toglie piu quando lo spazio manca, e '
            'mezzo volto e peggio di nessun volto');
    // **CENTODIECI E NON CENTOCINQUANTA, e il numero e' misurato.** Con la
    // prima soglia la presenza non compariva mai.
    expect(chat, contains('quandoCiSta = 110'),
        reason: 'la soglia e cambiata senza che nessuno rimisurasse la fascia '
            'vera: la prima volta era centocinquanta, scelta a occhio, ed '
            'escludeva proprio il caso per cui questa classe esiste');
  });
}
