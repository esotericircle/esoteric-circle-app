import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/cammino/ritrovamento.dart';
import 'package:flutter_test/flutter_test.dart';

/// CHI RIENTRA RIPRENDE IL RITO, NON LO RIFA'. Ordine AZ, fatto F2.
///
/// **Visto sul telefono del fondatore il 22 agosto 2026.** Dopo la cura del
/// server, il rientro funziona: il Cerchio lo riconosce e gli restituisce
/// settecentoquindici Eos. Ma al tocco di "Entra nel Cerchio" **il rito
/// riparte dall'accoglienza**, ed e' esattamente "sono costretto a rifare
/// l'onboarding per intero".
///
/// **La causa non era dove sembrava.** La logica per riprendere esiste da
/// tempo e funziona: `_riprendiCioCheIlCerchioSapeva` precompila cio' che si
/// sa e comincia dal primo passo che manca davvero. Ma vive nell'`initState`
/// del Risveglio, quindi **si applica solo a uno schermo costruito con
/// l'identita' ritrovata**. Chi rientrava trovava lo schermo gia' montato
/// senza, e quella logica non girava mai: era codice giusto che non veniva
/// mai eseguito.
///
/// **Cosa si misura qui**: che il Ritrovamento porti con se' l'identita', che
/// e' cio' che serve a rimontare il Risveglio dal punto giusto. Senza quel
/// campo la cura non e' nemmeno possibile.
void main() {
  Ritrovamento ritrovamentoCon({
    DateTime? giorno,
    String? ora,
    String? luogo,
    String? nome,
  }) =>
      Ritrovamento.da(
        CamminoDaCustodire(
          identita: IdentitaDaCustodire(
            giorno: giorno,
            ora: ora,
            luogo: luogo,
            nome: nome,
          ),
        ),
        saldoEos: 715,
      );

  test('il Ritrovamento porta l identita che il Cerchio custodiva', () {
    final esito = ritrovamentoCon(
      giorno: DateTime(1975, 3, 14),
      nome: 'Mauro',
    );
    // ignore: avoid_print
    print('ORDINE AZ, F2: identita nel ritrovamento '
        '${esito.identita == null ? "assente" : "presente"}, giorno '
        '${esito.identita?.giorno}, passi da chiedere '
        '${esito.passiDaChiedere.map((p) => p.name).toList()}');

    expect(esito.identita, isNotNull,
        reason: 'il ritrovamento non porta l identita: chi rientra non ha di '
            'che rimontare il rito, e lo rifa da capo');
    expect(esito.identita!.giorno, DateTime(1975, 3, 14));
    expect(esito.identita!.nome, 'Mauro');
  });

  test('col Cerchio che sa tutto non resta niente da chiedere', () {
    final esito = ritrovamentoCon(
      giorno: DateTime(1975, 3, 14),
      ora: '07:30',
      luogo: 'Milano',
      nome: 'Mauro',
    );
    // ignore: avoid_print
    print('ORDINE AZ, F2: col Cerchio che sa tutto, si salta ${esito.siSalta}');
    expect(esito.siSalta, isTrue,
        reason: 'il rito si rifa anche a chi ha dato tutto');
  });

  test('col Cerchio che sa a meta, si riprende dal passo che manca', () {
    // **IL CASO VERO DEL FONDATORE**, per quanto se ne sa: il Cerchio gli ha
    // restituito gli Eos ma non un'identita' intera, se no sarebbe andato
    // dritto in home.
    final esito = ritrovamentoCon(giorno: DateTime(1975, 3, 14));
    // ignore: avoid_print
    print('ORDINE AZ, F2: col giorno soltanto, mancano '
        '${esito.passiDaChiedere.map((p) => p.name).toList()}, il primo e '
        '${esito.passiDaChiedere.first.name}');

    expect(esito.siSalta, isFalse);
    expect(esito.passiDaChiedere.first, PassoDelRito.ora,
        reason: 'il primo passo da chiedere non e quello giusto: chi ha gia '
            'dato il giorno se lo vedrebbe chiedere di nuovo');
    // **E l'identita' c'e' lo stesso**, che e' il punto: senza, il Risveglio
    // ripartirebbe dall'accoglienza invece che dall'ora.
    expect(esito.identita?.giorno, isNotNull);
  });

  test('senza niente dal Cerchio, il rito comincia davvero da capo', () {
    // **LA CONTROPROVA.** A chi il Cerchio non conosce il rito va rifatto per
    // intero, e l'identita' non c'e' da rimontare.
    final esito = Ritrovamento.da(null);
    // ignore: avoid_print
    print('ORDINE AZ, F2: senza niente, passi ${esito.passiDaChiedere.length}, '
        'identita ${esito.identita == null ? "assente" : "presente"}');
    expect(esito.passiDaChiedere, hasLength(4));
    expect(esito.identita, isNull,
        reason: 'si sta rimontando il rito con un identita che non esiste');
  });
}
