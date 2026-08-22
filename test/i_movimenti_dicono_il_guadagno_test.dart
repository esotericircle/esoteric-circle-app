import 'dart:io';

import 'package:esoteric_circle/core/sigilli/traguardo.dart';
import 'package:flutter_test/flutter_test.dart';

/// I MOVIMENTI DICONO IL GUADAGNO, NON IL SALDO. Ordine BB voce 03.
///
/// **Due difetti nello stesso riquadro, tutti e due misurati sullo screenshot
/// del fondatore.**
///
/// **UNO: quattro movimenti tutti da +445, mentre il saldo in cima allo stesso
/// foglio e' 445.** Il riquadro e' innocente e legge onestamente
/// `movimento.quanti`: **il numero sbagliato lo scrive chi lo compone**. Il
/// delta si calcola come `saldo - borsa.saldoEos`, e quella sottrazione e'
/// giusta finche' il borsellino conosce il proprio saldo. **Se non lo conosce
/// vale zero**, e allora il delta diventa il totale: quattro premi da pochi
/// Eos si scrivono tutti e quattro come il saldo intero.
///
/// **DUE: le maiuscole incoerenti.** Nello stesso elenco si leggevano "LA
/// PRIMA FIORITURA" e "Il tuo numero". **La causa sta nel corpus e non si cura
/// li'**: il maiuscolo integrale e' il modo in cui il corpus marca i traguardi
/// grandi, ed e' un'informazione vera. Si normalizza alla lettura.
void main() {
  test('BB.03: il nome si legge in tondo, e il dato non si tocca', () {
    // **I QUATTRO NOMI DELLO SCREENSHOT DEL FONDATORE**, uno per uno.
    final casi = <String, String>{
      'LA PRIMA FIORITURA': 'La prima fioritura',
      'LA COSTELLAZIONE NASCENTE': 'La costellazione nascente',
      // **Chi NON e' tutto maiuscolo si lascia com'e'**: li' le maiuscole
      // interne sono volute, e "abbassarle" sarebbe l'errore opposto.
      'Il tuo numero': 'Il tuo numero',
      "La tua carta e' nata": "La tua carta e' nata",
    };
    final letti = <String>[];
    casi.forEach((dato, atteso) {
      final reso = nomeInTondo(dato);
      letti.add('"$dato" si legge "$reso"');
      expect(reso, atteso,
          reason: '"$dato" si legge "$reso" invece di "$atteso"');
    });
    // ignore: avoid_print
    print('ORDINE BB VOCE 03: ${letti.join('; ')}');

    // **E TUTTI E QUATTRO NELLA STESSA FORMA**: e' la richiesta del fondatore,
    // "o tutti in maiuscolo o tutti in minuscolo con prima lettera maiuscola".
    final forme = casi.keys.map(nomeInTondo).map((n) {
      if (n == n.toUpperCase()) return 'tutto maiuscolo';
      if (n.isNotEmpty && n[0] == n[0].toUpperCase()) return 'tondo';
      return 'altro';
    }).toSet();
    // ignore: avoid_print
    print('ORDINE BB VOCE 03: le forme viste nell elenco sono $forme');
    expect(forme, hasLength(1),
        reason: 'nello stesso elenco convivono forme diverse: $forme');
  });

  test('BB.03: il riquadro dei movimenti usa la stessa regola della festa',
      () {
    // **UNA REGOLA SOLA, e non due.** Se il borsellino normalizzasse per conto
    // suo, un giorno la festa e il registro mostrerebbero lo stesso traguardo
    // in due modi diversi. Qui si pretende che il borsellino chiami proprio
    // `nomeInTondo`, che e' quella che usa la scheda della festa.
    final borsellino = File('lib/design_system/components/borsellino.dart')
        .readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    // ignore: avoid_print
    print('ORDINE BB VOCE 03: il borsellino chiama nomeInTondo '
        '${'nomeInTondo('.allMatches(borsellino).length} volte');
    expect(borsellino.contains('nomeInTondo(movimento.perche)'), isTrue,
        reason: 'il borsellino scrive il nome cosi come sta nel dato, quindi '
            'nello stesso elenco convivono maiuscolo integrale e tondo');
  });

  test('BB.03: il delta non nasce da un saldo che nessuno ha ancora letto',
      () {
    final regia = File('lib/features/sigilli/regia_del_cammino.dart')
        .readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    // ignore: avoid_print
    print('ORDINE BB VOCE 03: nella regia "saldoNoto" compare '
        '${'saldoNoto'.allMatches(regia).length} volte');
    expect(regia.contains('final saldoNoto = borsa.saldoEos > 0;'), isTrue,
        reason: 'il delta si calcola ancora sottraendo un saldo che potrebbe '
            'essere zero perche nessuno lo ha letto, non perche sia zero');
    expect(regia.contains('saldoNoto ? saldo - borsa.saldoEos : traguardo.eos'),
        isTrue,
        reason: 'quando il saldo non e noto non si usa cio che il traguardo '
            'dichiara: il movimento si scrive col totale invece che col '
            'guadagno, ed e il fatto del fondatore');
  });
}
