import 'package:esoteric_circle/core/sigilli/sentiero_albero.dart';
import 'package:esoteric_circle/core/sigilli/sentiero_costellazione.dart';
import 'package:esoteric_circle/core/sigilli/sentiero_loto.dart';
import 'package:esoteric_circle/core/sigilli/traguardo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MISURA: come si classificano i 165', () {
    final tutti = <Traguardo>[
      ...sentieroDellaCostellazione,
      ...sentieroDelLoto,
      ...sentieroDellAlbero,
    ];
    // ignore: avoid_print
    print('TOTALE ${tutti.length}');

    var dormienti = 0;
    var cielo = 0;
    var altroGiorno = 0;
    var unaSessione = 0;
    final perFascia = <String, int>{};
    final unaSessionePerFascia = <String, int>{};
    final unaSessionePerMaestro = <String, int>{};
    var eosInUnaSessione = 0;
    final specie = <String, int>{};

    for (final t in tutti) {
      final c = t.condizione;
      specie[c.runtimeType.toString()] =
          (specie[c.runtimeType.toString()] ?? 0) + 1;
      perFascia[t.fascia] = (perFascia[t.fascia] ?? 0) + 1;
      if (c is Dormiente) {
        dormienti++;
        continue;
      }
      if (c is FinestraDelCielo) {
        cielo++;
        continue;
      }
      if (c.chiedeUnAltroGiorno) {
        altroGiorno++;
        continue;
      }
      unaSessione++;
      eosInUnaSessione += t.eos;
      unaSessionePerFascia[t.fascia] =
          (unaSessionePerFascia[t.fascia] ?? 0) + 1;
      final m = t.id.split('_').first;
      unaSessionePerMaestro[m] = (unaSessionePerMaestro[m] ?? 0) + 1;
    }

    // ignore: avoid_print
    print('DORMIENTI $dormienti');
    // ignore: avoid_print
    print('SOLO CIELO $cielo');
    // ignore: avoid_print
    print('CHIEDONO UN ALTRO GIORNO $altroGiorno');
    // ignore: avoid_print
    print('UNA SESSIONE $unaSessione');
    // ignore: avoid_print
    print('EOS IN UNA SESSIONE $eosInUnaSessione');
    // ignore: avoid_print
    print('PER FASCIA $perFascia');
    // ignore: avoid_print
    print('UNA SESSIONE PER FASCIA $unaSessionePerFascia');
    // ignore: avoid_print
    print('UNA SESSIONE PER MAESTRO $unaSessionePerMaestro');
    // ignore: avoid_print
    print('SPECIE $specie');
    final eos = tutti.fold<int>(0, (a, t) => a + t.eos);
    // ignore: avoid_print
    print('EOS TOTALI $eos');
  });
}
