import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:esoteric_circle/core/rituals/rito_alba_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA PAROLA DEL GIORNO APPARTIENE AL GESTO. Ordine AS voce 06.
///
/// **Il fatto di Mauro**: la parola del giorno non ha attinenza col testo e col
/// rito.
///
/// **La causa, letta nel codice e non supposta.** I tre momenti del rito si
/// estraevano con TRE semi derivati distinti, e c'era pure scritto perche':
/// "cosi' i tre momenti non si muovono insieme". Il gesto poteva dire "conta
/// quante ore mancano a stasera" e la parola essere "Ombra": sessantaquattro
/// combinazioni per forma, e la maggior parte senza nessun legame di senso.
///
/// **Cosa pretendono queste righe.** Che ogni gesto del corpus nomini una
/// parola che nella sua forma esiste davvero, e che il rito composto porti
/// proprio quella. Il legame sta nel DATO, quindi si puo' controllare voce per
/// voce invece di fidarsi.
void main() {
  test('ogni gesto nomina una parola che esiste nella sua forma', () {
    var osservati = 0;
    final orfani = <String>[];
    for (final forma in RitoAlbaCorpus.forme) {
      final parole = forma.parole.map((p) => p.parola).toSet();
      for (final gesto in forma.gesti) {
        osservati++;
        if (!parole.contains(gesto.parola)) {
          orfani.add('${forma.nome}: il gesto nomina "${gesto.parola}", che '
              'fra le sue parole non c\'e (${parole.join(", ")})');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 06: gesti osservati $osservati, senza la loro parola '
        '${orfani.length}');
    expect(osservati, 36,
        reason: 'i gesti guardati sono $osservati: il corpus e cambiato e '
            'questa prova va rifatta sul numero vero');
    expect(orfani, isEmpty, reason: orfani.take(5).join('; '));
  });

  test('il rito di oggi porta la parola del suo gesto, per un anno intero', () {
    // **SI ENUMERA UN ANNO, e non un giorno.** Il legame passa da un
    // `firstWhere` con un ripiego: un giorno solo direbbe che il ripiego non
    // e' scattato quel giorno, non che non scatta mai.
    var osservati = 0;
    final scollegati = <String>[];
    for (final maestro in Maestro.values) {
      for (var giorno = 0; giorno < 365; giorno++) {
        final quando = DateTime.utc(2026, 1, 1).add(Duration(days: giorno));
        // Un cielo con TUTTI i dati, cosi' nessuna variante resta fuori per
        // mancanza di dato e la prova guarda l'intero corpus.
        final cielo = CieloDiStamattina(
          faseLunare: 'crescente',
          segnoLunare: Zodiac.leo,
          oraDellAlba: DateTime.utc(2026, 1, 1, 6, 30),
        );
        final rito = RitoAlba.componi(quando, maestro, cielo);
        if (rito == null) continue;
        osservati++;
        final forma = RitoAlbaCorpus.forme
            .firstWhere((f) => f.nome == rito.forma, orElse: () => forma0);
        // **IL GESTO SI RICONOSCE DALLA VIA TATTILE, e il primo tentativo
        // sbagliava.** Cercarlo dal prefisso del testo prima del segnaposto
        // trovava il primo gesto che comincia con "La Luna e in ", e sono
        // parecchi: la prova accusava 289 riti su 1095 di essere scollegati,
        // ed era la RICERCA a prendere il gesto sbagliato, non il codice a
        // scegliere la parola sbagliata. La via tattile invece e' scritta una
        // volta sola per gesto e arriva intera nel rito, senza segnaposti.
        final gesto = forma.gesti.firstWhere(
          (g) => g.viaTattile == rito.viaTattile,
          orElse: () => forma.gesti.first,
        );
        if (gesto.parola != rito.parola) {
          scollegati.add('${rito.forma} il ${quando.toIso8601String()}: gesto '
              'con "${gesto.parola}", rito con "${rito.parola}"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 06: riti osservati su un anno e tre Maestri '
        '$osservati, scollegati ${scollegati.length}');
    expect(osservati, greaterThan(300),
        reason: 'i riti osservati sono $osservati: la prova gira quasi a vuoto');
    expect(scollegati, isEmpty,
        reason: 'in questi giorni la parola non e quella del gesto: '
            '${scollegati.take(4).join("; ")}');
  });
}

/// Una forma di ripiego che non esiste nel corpus, cosi' un `orElse` che
/// scattasse si vedrebbe subito invece di passare per una forma vera.
final forma0 = RitoAlbaCorpus.forme.first;
