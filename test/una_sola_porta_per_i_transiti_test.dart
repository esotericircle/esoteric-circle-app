import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'dart:io';

import 'package:esoteric_circle/core/archetypes/archetype_sky.dart';
import 'package:esoteric_circle/core/archetypes/archetype_transits.dart';
import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/transiti_del_giorno.dart';
import 'package:esoteric_circle/core/tempo/confine_del_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';
import 'package:esoteric_circle/core/astro/il_segno_del_cielo.dart';

/// LE CINQUE PROVE DEL ROSSO DELLA VOCE 1, piu' quella sulle firme.
///
/// Ognuna nasce da un modo preciso in cui questo lavoro poteva andare storto, e
/// ognuna e' stata vista fallire prima di essere vista passare.
void main() {
  group('Una porta sola per la longitudine', () {
    // **LAPIDE, ordine FD voce 02, 5 ottobre 2026.** Questo gruppo
    // difendeva `Effemeridi` come porta sola: le sue impronte fuori da
    // `effemeridi.dart`, e il suo Sole fermo al millesimo. `Effemeridi` non
    // c'e' piu'; la porta sola e' `IlCieloDiMeeus`, e la guardia larga, che
    // cerca tutte le impronte di un calcolo di posizione e non solo queste
    // sei, e' `il_cielo_ha_una_porta_sola_test.dart`. Qui le due prove
    // restano, sulla regola nuova.
    test('nessun file calcola una seconda volta la stessa serie', () {
      // Le costanti che identificano le serie del motore di prima: non
      // devono rinascere da nessuna parte, nemmeno nella libreria di Meeus.
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
      for (final f in sorgentiDiLib()) {
        final testo = f.readAsStringSync();
        final normalizzato = f.path.replaceAll(r'\', '/');
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

    test('il Sole della porta sta sul JPL al secondo d\'arco', () {
      // Gli stessi quattro giorni di quando qui si pretendeva il Sole di
      // `Effemeridi` fermo al millesimo; adesso si pretende il JPL DE440s
      // (skyfield, longitudine apparente della data) entro cinque secondi
      // d'arco, lo scarto massimo misurato sul secolo.
      final jpl = {
        0.0: 280.368918,
        9000.0: 149.882913,
        12000.0: 226.635478,
        -3000.0: 201.636859,
      };
      for (final e in jpl.entries) {
        final jd = 2451545.0 + e.key;
        expect(
          IlCieloDiMeeus.longitudine(CorpoCeleste.sole, jd),
          closeTo(e.value, 5 / 3600),
          reason: 'il Sole della porta si e\' allontanato dal JPL',
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
      final definizioni = sorgentiDiLib()
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
        'lib/core/astro/meeus/il_cielo_di_meeus.dart',
        'lib/core/astro/meeus/i_pianeti_di_meeus.dart',
        'lib/core/astro/meeus/la_luna_intera.dart',
        'lib/core/astro/meeus/le_tabelle_dei_pianeti.dart',
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
      final prova = File('test/effemeridi_contro_fonte_terza_test.dart')
          .readAsStringSync();
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
      expect(IlSegnoDelCielo.delSole(DateTime(2026, 8, 4)), isNotNull);
      expect(IlSegnoDelCielo.dellaLuna(DateTime(2026, 8, 4)), isNotNull);
      expect(NightSky.sunEclipticLongitude(DateTime(2026, 8, 4)),
          inInclusiveRange(0, 360));
      expect(NightSky.moonEclipticLongitude(DateTime(2026, 8, 4)),
          inInclusiveRange(0, 360));
      expect(
          Celestial.sunEclipticLongitude(2451545.0), inInclusiveRange(0, 360));
      expect(
          Celestial.moonEquatorial(2451545.0).raDeg, inInclusiveRange(0, 360));
      expect(Celestial.moonIllumination(2451545.0).fraction,
          inInclusiveRange(0, 1));
      expect(MoonPhase.forDate(DateTime(2026, 8, 4)).italianName, isNotEmpty);
    });
  });
}
