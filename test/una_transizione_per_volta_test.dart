import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/sigilli/transizione_di_stelle.dart';
import 'package:flutter_test/flutter_test.dart';

/// UNA FESTA, UN TRAGUARDO, UNA TRANSIZIONE. Ordine AT voci 05, 06, 07 e 08.
///
/// **Cosa si misura qui, e cosa no.** Le misure M3, M4 e M5 vogliono un
/// dispositivo vero e restano dell'Architetto. Qui si sorvegliano le cose che
/// vivono nel dato e nel codice: che ogni Maestro abbia il suo filmato, che il
/// tempo dello stacco sia quello dichiarato, che il lettore non venga montato
/// due volte insieme, e che la scheda resti invisibile fino allo stacco.
void main() {
  final scena =
      File('lib/features/sigilli/celebrazione.dart').readAsStringSync();
  final lettore =
      File('lib/features/sigilli/transizione_di_stelle.dart').readAsStringSync();
  final soloCodice = lettore
      .split(String.fromCharCode(10))
      .where((r) => !r.trimLeft().startsWith('//') && !r.trimLeft().startsWith('///'))
      .join(String.fromCharCode(10));

  test('ogni Maestro ha il suo filmato, e i tre sono diversi', () {
    final visti = <String>{};
    for (final maestro in Maestro.values) {
      final asse = TransizioneDiStelle.asseDi(maestro);
      expect(File(asse).existsSync(), isTrue,
          reason: 'il filmato di ${maestro.id} non esiste: $asse');
      visti.add(asse);
    }
    // ignore: avoid_print
    print('ORDINE AT VOCE 08: filmati distinti ${visti.length} su '
        '${Maestro.values.length}');
    expect(visti, hasLength(Maestro.values.length),
        reason: 'due Maestri condividono la stessa transizione');
  });

  test('lo stacco sta a 800 millesimi, cioe al frame 21 contato da uno', () {
    expect(TransizioneDiStelle.frameDelloStacco, 21);
    expect(TransizioneDiStelle.istanteDelloStacco.inMilliseconds, 800,
        reason: 'lo stacco non e piu a 800 millesimi');
    // **IL CONTO TORNA, e non e' una coincidenza**: il frame 21 contato da uno
    // e' l'indice 20 contato da zero, e a quaranta millesimi l'uno fa 800.
    expect((TransizioneDiStelle.frameDelloStacco - 1) *
            TransizioneDiStelle.passo.inMilliseconds,
        TransizioneDiStelle.istanteDelloStacco.inMilliseconds);
    expect(
        TransizioneDiStelle.quantiFotogrammi *
            TransizioneDiStelle.passo.inMilliseconds,
        TransizioneDiStelle.durata.inMilliseconds,
        reason: 'cinquanta fotogrammi da quaranta millesimi non fanno piu due '
            'secondi');
  });

  test('il lettore non precarica la sequenza, e libera cio che crea', () {
    // **LA REGOLA CHE SALVA L APP, ordine AT voce 04**: cinquanta fotogrammi a
    // 720 per 1280 in RGBA fanno 184 megabyte. Qui si pretende che non esista
    // nessuna raccolta di immagini e che il codec avanzi uno per volta.
    expect(soloCodice.contains('List<ui.Image>'), isFalse,
        reason: 'e tornata una raccolta di immagini: la sequenza intera in '
            'memoria fa 184 megabyte e l app muore');
    expect(soloCodice.contains('getNextFrame()'), isTrue,
        reason: 'il codec non avanza piu un fotogramma per volta');
    expect(soloCodice.contains('Image.asset'), isFalse,
        reason: 'il filmato torna a passare da Image.asset, che decodifica '
            'tutto da se');
    // Ogni immagine creata viene contata e scontata: il contatore rende la
    // regola verificabile invece che dichiarata.
    expect(soloCodice.contains('immaginiVive++'), isTrue);
    expect(soloCodice.contains('immaginiVive--'), isTrue);
    expect(soloCodice.contains('MaskFilter'), isFalse,
        reason: 'e tornato un filtro per fotogramma: a venticinque al secondo '
            'e il modo piu rapido di far cadere il conto');
  });

  test('la scheda resta invisibile fino allo stacco', () {
    expect(scena.contains('bool _traguardoVisibile = false;'), isTrue,
        reason: 'la scheda non nasce piu invisibile: si vedrebbe sotto le '
            'stelle dal primo fotogramma');
    expect(scena.contains('visible: _traguardoVisibile'), isTrue,
        reason: 'la scheda non e piu legata allo stacco');
    // **VISIBILITY E NON OPACITY**: un opacita a zero e una dissolvenza che
    // comincia, e l ordine chiede che al frame 21 la scheda appaia DI COLPO.
    expect(scena.contains('Opacity(opacity: _traguardoVisibile'), isFalse,
        reason: 'la scheda entra in dissolvenza: l ordine vuole uno stacco '
            'secco, perche il lampo della stella lo copre');
  });

  test('la parola di premio compare con la scheda, non prima', () {
    expect(scena.contains("Key('celebrazione_congratulazioni')"), isTrue,
        reason: 'la parola di premio non c e');
    // Sta DENTRO la scheda, quindi eredita la sua invisibilita': se stesse
    // fuori dal Visibility si leggerebbe sopra le stelle dal primo fotogramma.
    final doveVisibility = scena.indexOf('visible: _traguardoVisibile');
    final doveParola = scena.indexOf("Key('celebrazione_congratulazioni')");
    final doveTransizione = scena.indexOf('child: TransizioneDiStelle(');
    expect(doveVisibility, lessThan(doveParola),
        reason: 'la parola di premio sta fuori dalla scheda invisibile: si '
            'leggerebbe sopra le stelle dal primo fotogramma');
    expect(doveParola, lessThan(doveTransizione),
        reason: 'la transizione non sta piu sopra la scheda');
  });

  test('una transizione per volta, perche una festa per volta', () {
    // **IL CONFINE CON L ORDINE AU E DICHIARATO**: la coda dei traguardi in
    // attesa e la distanza fra due feste sono materia della voce AU.03. Qui
    // vale una cosa sola: il lettore non viene mai montato due volte insieme,
    // e lo garantisce il catenaccio che esisteva gia, FesteInCorso.
    expect(scena.contains('if (FesteInCorso.unaCeGia) return false;'), isTrue,
        reason: 'e sparito il catenaccio che impedisce due feste insieme: due '
            'transizioni sovrapposte sono due filmati a schermo pieno uno '
            'sull altro');
    // E il lettore vive DENTRO la scena della festa: non esiste un secondo
    // punto che lo monti.
    var quantiLoMontano = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      // **IL FILE CHE LO DEFINISCE NON LO MONTA**, e la prima stesura di
      // questa prova lo contava: `const TransizioneDiStelle({` e' la
      // dichiarazione del costruttore, non un uso. Si guarda chi lo monta,
      // cioe' chi scrive `child: TransizioneDiStelle(`.
      if (f.path.endsWith('transizione_di_stelle.dart')) continue;
      if (f.readAsStringSync().contains('TransizioneDiStelle(')) {
        quantiLoMontano++;
      }
    }
    // ignore: avoid_print
    print('ORDINE AT VOCE 06: punti che montano il lettore $quantiLoMontano');
    expect(quantiLoMontano, 1,
        reason: 'il lettore viene montato da $quantiLoMontano punti: con piu '
            'di uno due transizioni possono partire insieme');
  });
}
