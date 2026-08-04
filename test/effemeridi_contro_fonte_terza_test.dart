import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA PROVA CHE DECIDE SE UN CORPO SI CONSEGNA.
///
/// L'ordine dice: per ogni corpo aggiunto, confronto con una fonte indipendente
/// su almeno tre date distanti, e i numeri delle due parti nel rapporto. Se un
/// corpo non raggiunge una precisione utile non lo si consegna impreciso, si
/// dichiara che manca.
///
/// **La fonte terza e' JPL Horizons**, il sistema di effemeridi del Jet
/// Propulsion Laboratory della NASA, interrogato il 4 agosto 2026 per la
/// longitudine eclittica geocentrica apparente all'equinozio della data
/// (quantita' 31, centro 500@399). I valori stanno qui sotto come li ha
/// restituiti, e non si aggiustano: se il motore sbaglia, deve dirlo la prova.
///
/// **Cosa NON copre.** Horizons da' la posizione APPARENTE, che include
/// aberrazione della luce e nutazione; il motore locale calcola la posizione
/// geometrica all'equinozio della data. Lo scarto sistematico che ne viene e'
/// dell'ordine dei venti secondi d'arco, cioe' sei millesimi di grado, ed e'
/// dentro le tolleranze qui sotto invece di essere corretto: correggerlo
/// costerebbe codice per una quantita' cento volte piu' piccola dell'orbo piu'
/// stretto che l'app usa.
void main() {
  /// Le tre date, distanti fra loro piu' di sei mesi ciascuna.
  final date = <DateTime>[
    DateTime.utc(2026, 2, 15),
    DateTime.utc(2026, 8, 24),
    DateTime.utc(2027, 3, 2),
  ];

  /// Longitudine eclittica in gradi, da JPL Horizons, nello stesso ordine.
  const riferimento = <CorpoCeleste, List<double>>{
    CorpoCeleste.sole: [326.3027589, 150.8707097, 341.1694145],
    CorpoCeleste.luna: [296.7180045, 283.4112053, 270.6952698],
    CorpoCeleste.mercurio: [343.2646735, 147.0774313, 321.0518366],
    CorpoCeleste.venere: [335.7234261, 196.4160559, 300.8637367],
    CorpoCeleste.marte: [317.7167381, 98.2740346, 146.7824558],
    CorpoCeleste.giove: [106.0295382, 131.9994354, 139.6331963],
    CorpoCeleste.saturno: [0.1095289, 14.0890698, 13.1880644],
  };

  /// Lo scarto in gradi fra due longitudini, tenendo conto del giro.
  double scarto(double a, double b) {
    final d = (a - b).abs() % 360.0;
    return d > 180.0 ? 360.0 - d : d;
  }

  /// La tolleranza per corpo, in gradi. Non e' un numero comodo: e' quello che
  /// il motore raggiunge davvero, misurato, con un margine che non nasconde un
  /// peggioramento. L'orbo piu' stretto che l'app usa e' due gradi, quindi uno
  /// scarto sotto il decimo di grado non sposta nessun aspetto.
  const tolleranza = <CorpoCeleste, double>{
    CorpoCeleste.sole: 0.010, // misurato al massimo 0,0062
    CorpoCeleste.luna: 0.200, // misurato al massimo 0,1542
    CorpoCeleste.mercurio: 0.015, // misurato al massimo 0,0084
    CorpoCeleste.venere: 0.015, // misurato al massimo 0,0078
    CorpoCeleste.marte: 0.060, // misurato al massimo 0,0424
    CorpoCeleste.giove: 0.040, // misurato al massimo 0,0216
    CorpoCeleste.saturno: 0.200, // misurato al massimo 0,1414
  };

  group('Le effemeridi locali contro JPL Horizons', () {
    test('nessun corpo esce senza riferimento e senza tolleranza', () {
      // La cintura di questa prova: se domani si aggiunge un corpo all'enum e
      // ci si dimentica di verificarlo, si scopre qui e non a schermo.
      expect(riferimento.keys.toSet(), CorpoCeleste.values.toSet());
      expect(tolleranza.keys.toSet(), CorpoCeleste.values.toSet());
      for (final valori in riferimento.values) {
        expect(valori, hasLength(date.length));
      }
    });

    for (final corpo in CorpoCeleste.values) {
      test('${corpo.nome} sta dove dice Horizons, su tre date', () {
        final atteso = riferimento[corpo]!;
        final scarti = <double>[];
        for (var i = 0; i < date.length; i++) {
          final calcolata = Effemeridi.longitudineEclittica(
            corpo,
            Celestial.julianDay(date[i]),
          );
          final d = scarto(calcolata, atteso[i]);
          scarti.add(d);
          expect(
            d,
            lessThan(tolleranza[corpo]!),
            reason: '${corpo.nome} il ${date[i].toIso8601String()}: '
                'il motore dice ${calcolata.toStringAsFixed(4)}, '
                'Horizons dice ${atteso[i].toStringAsFixed(4)}, '
                'scarto ${d.toStringAsFixed(4)} gradi',
          );
        }
        // I numeri delle due parti finiscono nel rapporto, non solo l'esito.
        // ignore: avoid_print
        print('${corpo.nome}: scarti in gradi '
            '${scarti.map((s) => s.toStringAsFixed(4)).join(', ')}');
      });
    }
  });
}
