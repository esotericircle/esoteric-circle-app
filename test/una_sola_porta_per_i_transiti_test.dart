import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/core/archetypes/archetype_sky.dart';
import 'package:esoteric_circle/core/archetypes/archetype_transits.dart';
import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/transiti_del_giorno.dart';
import 'package:esoteric_circle/core/tempo/confine_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE CINQUE PROVE DEL ROSSO DELLA VOCE 1, piu' quella sulle firme.
///
/// Ognuna nasce da un modo preciso in cui questo lavoro poteva andare storto, e
/// ognuna e' stata vista fallire prima di essere vista passare.
void main() {
  group('Una porta sola per la longitudine', () {
    test('nessun file calcola una seconda volta la stessa serie', () {
      // Le costanti che identificano le serie: se compaiono fuori da
      // `effemeridi.dart`, qualcuno ha riscritto la formula invece di chiedere.
      const impronte = <String, String>{
        '280.460': 'longitudine media del Sole',
        '0.9856474': 'moto medio del Sole',
        '1.915': 'equazione del centro del Sole',
        '218.316': 'longitudine media della Luna',
        '13.176396': 'moto medio della Luna',
        '6.289': 'termine principale della Luna',
      };

      // Il confronto e' sul numero INTERO, non sul prefisso: `gmstDegrees`
      // usa 280.46061837, che comincia per 280.460 senza essere la longitudine
      // media del Sole. La prima stesura di questa prova ci e' cascata, ed e'
      // il genere di falso positivo che fa disattivare le prove.
      RegExp intero(String numero) =>
          RegExp('(?<![0-9.])${RegExp.escape(numero)}(?![0-9])');

      final colpevoli = <String, List<String>>{};
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final testo = f.readAsStringSync();
        final normalizzato = f.path.replaceAll(r'\', '/');
        if (normalizzato.endsWith('lib/core/astro/effemeridi.dart')) continue;
        for (final voce in impronte.entries) {
          if (intero(voce.key).hasMatch(testo)) {
            (colpevoli[normalizzato] ??= []).add('${voce.key} (${voce.value})');
          }
        }
      }

      expect(colpevoli, isEmpty,
          reason: 'la longitudine di un corpo si calcola in un punto solo, '
              'ma queste serie vivono anche altrove: $colpevoli');
    });

    test('il Sole non si e\' spostato di un millesimo con l\'unificazione', () {
      // I valori verificati il 1 agosto 2026 poggiano su questa formula. La
      // prova la ricalcola a mano, come stava scritta prima, e pretende che
      // coincida cifra per cifra: se qualcuno "migliora" il Sole, cade.
      for (final giorno in [0.0, 9000.0, 12000.0, -3000.0]) {
        final jd = 2451545.0 + giorno;
        final n = jd - 2451545.0;
        final l = (280.460 + 0.9856474 * n) % 360.0;
        final g = (357.528 + 0.9856003 * n) * 3.141592653589793 / 180.0;
        var atteso =
            (l + 1.915 * _sin(g) + 0.020 * _sin(2 * g)) % 360.0;
        if (atteso < 0) atteso += 360.0;
        expect(
          Effemeridi.longitudineEclittica(CorpoCeleste.sole, jd),
          closeTo(atteso, 1e-9),
          reason: 'la formula del Sole e\' cambiata',
        );
      }
    });
  });

  group('L\'istante del giorno e\' uno solo', () {
    test('non cambia fra due momenti dello stesso giorno civile', () {
      final mattina = DateTime(2026, 8, 4, 0, 1);
      final sera = DateTime(2026, 8, 4, 23, 59);

      expect(TransitiDelGiorno.istanteDi(mattina),
          TransitiDelGiorno.istanteDi(sera),
          reason: 'due momenti dello stesso giorno danno istanti diversi');

      final aMattina = TransitiDelGiorno.posizioni(mattina);
      final aSera = TransitiDelGiorno.posizioni(sera);
      for (final corpo in CorpoCeleste.values) {
        expect(aSera[corpo], aMattina[corpo],
            reason: '${corpo.nome} si e\' mosso dentro lo stesso giorno');
      }
    });

    test('cambia quando cambia il giorno civile', () {
      final oggi = DateTime(2026, 8, 4, 23, 59);
      final domani = DateTime(2026, 8, 5, 0, 1);

      // Il confine e' quello di ConfineDelGiorno, non un secondo confine.
      expect(ConfineDelGiorno.chiaveDi(oggi),
          isNot(ConfineDelGiorno.chiaveDi(domani)));
      expect(TransitiDelGiorno.istanteDi(oggi),
          isNot(TransitiDelGiorno.istanteDi(domani)));
      expect(TransitiDelGiorno.posizioni(domani)[CorpoCeleste.luna],
          isNot(TransitiDelGiorno.posizioni(oggi)[CorpoCeleste.luna]),
          reason: 'la Luna deve muoversi da un giorno all\'altro');
    });

    test('l\'istante e\' quello che ConfineDelGiorno chiama giorno', () {
      final quando = DateTime(2026, 12, 31, 22, 30);
      final istante = TransitiDelGiorno.istanteDi(quando);
      expect(ConfineDelGiorno.chiaveDi(quando),
          '${istante.year}-${istante.month}-${istante.day}');
    });
  });

  group('ConfineDelGiorno non e\' stato toccato', () {
    test('vive in un punto solo e ha ancora i suoi due metodi', () {
      final definizioni = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .where((f) => f.readAsStringSync().contains('class ConfineDelGiorno'))
          .map((f) => f.path.replaceAll(r'\', '/'))
          .toList();
      expect(definizioni, hasLength(1),
          reason: 'un secondo confine del giorno: $definizioni');

      final testo = File('lib/core/tempo/confine_del_giorno.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');
      expect(
        testo,
        contains("static String chiaveDi(DateTime istante) =>\n"
            "      '\${istante.year}-\${istante.month}-\${istante.day}';"),
        reason: 'chiaveDi e\' stata modificata',
      );
      expect(
        testo,
        contains('static bool eOggi(String chiave, DateTime istante) =>\n'
            '      chiave == chiaveDi(istante);'),
        reason: 'eOggi e\' stata modificata',
      );
    });
  });

  group('Niente rete nel cammino dei transiti', () {
    test('i file del calcolo non importano nulla che parli fuori', () {
      const cammino = [
        'lib/core/astro/effemeridi.dart',
        'lib/core/astro/transiti_del_giorno.dart',
        'lib/core/astro/aspetti_di_oggi.dart',
      ];
      const vietati = [
        'package:http',
        'cloud_functions',
        'firebase',
        'dart:io',
        'HttpClient',
      ];
      for (final percorso in cammino) {
        final testo = File(percorso).readAsStringSync();
        for (final v in vietati) {
          expect(testo.contains(v), isFalse,
              reason: '$percorso tocca la rete con "$v"');
        }
      }
    });
  });

  group('Ogni corpo consegnato ha la sua verifica', () {
    test('nessun corpo esce senza il confronto con la fonte terza', () {
      final prova =
          File('test/effemeridi_contro_fonte_terza_test.dart').readAsStringSync();
      for (final corpo in CorpoCeleste.values) {
        // Si pretende la RIGA DEI VALORI, non il nome: il nome compare anche
        // nella tavola delle tolleranze, quindi cercarlo e basta lasciava
        // passare un corpo con la sua tolleranza e nessun riferimento. L'ha
        // trovata la mutazione, non la lettura.
        expect(
          RegExp('CorpoCeleste\\.${corpo.name}: \\[').hasMatch(prova),
          isTrue,
          reason: '${corpo.nome} si consegna senza i valori di JPL Horizons '
              'contro cui confrontarlo',
        );
      }
    });
  });

  group('Le firme di fuori non sono cambiate', () {
    test('cio\' che lib/features/maestri chiama risponde ancora', () {
      // `pianetiDelGiorno` e' usata da due schermate sotto lib/features/maestri,
      // cartella fuori dal perimetro di quest'ordine: se la firma cambiasse,
      // quelle schermate non compilerebbero piu' e non potrei aggiustarle.
      final Set<Pianeta> attivi =
          ArchetypeSky.pianetiDelGiorno(DateTime(2026, 8, 4));
      expect(attivi, contains(Pianeta.sole));
      expect(ArchetypeSky.pianetiCalcolabili, 2);

      // Le altre firme pubbliche che il resto dell'app usa.
      expect(NightSky.sunSign(DateTime(2026, 8, 4)), isNotNull);
      expect(NightSky.moonSign(DateTime(2026, 8, 4)), isNotNull);
      expect(NightSky.sunEclipticLongitude(DateTime(2026, 8, 4)),
          inInclusiveRange(0, 360));
      expect(NightSky.moonEclipticLongitude(DateTime(2026, 8, 4)),
          inInclusiveRange(0, 360));
      expect(Celestial.sunEclipticLongitude(2451545.0), inInclusiveRange(0, 360));
      expect(Celestial.moonEquatorial(2451545.0).raDeg, inInclusiveRange(0, 360));
      expect(Celestial.moonIllumination(2451545.0).fraction,
          inInclusiveRange(0, 1));
      expect(MoonPhase.forDate(DateTime(2026, 8, 4)).italianName, isNotEmpty);
    });
  });
}

double _sin(double x) => math.sin(x);
