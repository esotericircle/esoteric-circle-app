import 'package:esoteric_circle/core/sigilli/ancoraggi_dei_sentieri.dart';
import 'package:esoteric_circle/core/sigilli/regole_delle_tre_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/features/sigilli/journal_dall_arte.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL LOTO E' FATTO DI CINQUE FIORI. Ordine Y voce 01.
///
/// **La struttura non e' un'ipotesi ricavata dai pixel**: e' un fatto dichiarato
/// da chi ha disegnato l'arte, cinque fiori con un centro e dieci petali
/// ciascuno. Questa prova non lo scopre, lo SORVEGLIA: il giorno in cui il file
/// dei pallini cambiasse e un fiore si trovasse con nove petali o con undici, la
/// struttura su cui si appoggiano le misure per fiore e per petalo smetterebbe
/// di reggere, e ogni tabella scritta con quei numeri direbbe il falso senza che
/// nessuno se ne accorga.
void main() {
  test('il Loto porta cinque fiori, ognuno con un centro e dieci petali', () {
    final ancoraggi = AncoraggiDeiSentieri.di(Sentiero.loto);
    expect(ancoraggi, isNotNull,
        reason: 'senza ancoraggi non c\'e' ' niente da enumerare');

    final quanti = <int, int>{};
    final centri = <int, int>{};
    for (final a in ancoraggi!) {
      quanti[a.gruppo] = (quanti[a.gruppo] ?? 0) + (a.eGrande ? 0 : 1);
      centri[a.gruppo] = (centri[a.gruppo] ?? 0) + (a.eGrande ? 1 : 0);
    }

    final guasti = <String>[];
    var osservati = 0;
    for (var fiore = 0; fiore < StrutturaDelLoto.quantiFiori; fiore++) {
      osservati++;
      final petali = quanti[fiore] ?? 0;
      final centro = centri[fiore] ?? 0;
      if (petali != StrutturaDelLoto.petaliPerFiore) {
        guasti.add('il fiore $fiore ha $petali petali invece di '
            '${StrutturaDelLoto.petaliPerFiore}');
      }
      if (centro != 1) {
        guasti.add('il fiore $fiore ha $centro centri invece di uno');
      }
      // L'ordine attorno al giro deve dare esattamente i dieci petali, senza
      // perderne per strada ne' contarne due volte.
      final giro = StrutturaDelLoto.petaliInSensoOrario(
        ancoraggi,
        fiore,
        larghezzaArte: ArteDelSentiero.larghezzaArte(Sentiero.loto),
        altezzaArte: ArteDelSentiero.altezzaArte(Sentiero.loto),
      );
      if (giro.length != petali) {
        guasti.add('il fiore $fiore ha $petali petali ma il giro in senso '
            'orario ne ordina ${giro.length}');
      }
      if (giro.toSet().length != giro.length) {
        guasti.add('il fiore $fiore ha un petalo contato due volte nel giro');
      }
    }

    // **QUANTI FIORI GUARDATI, e cade se sono zero.**
    // ignore: avoid_print
    print('ORDINE Y VOCE 01: fiori osservati $osservati, '
        'ancoraggi ${ancoraggi.length}');
    expect(osservati, StrutturaDelLoto.quantiFiori);
    expect(
        ancoraggi.length,
        StrutturaDelLoto.quantiFiori *
            (StrutturaDelLoto.petaliPerFiore + 1),
        reason: 'cinque fiori per undici elementi fanno cinquantacinque, che e\' '
            'il numero dei traguardi: se questo conto non torna, la struttura '
            'dichiarata e quella disegnata si sono separate');
    expect(guasti, isEmpty, reason: guasti.join(' | '));
  });
}
