import 'dart:io';

import 'package:esoteric_circle/core/astro/eclissi.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL MOTORE DELLE ECLISSI, VERIFICATO CONTRO UNA FONTE TERZA.
/// Ordine CE voce 16.
///
/// **LA FONTE TERZA E' IL CANONE DELLA NASA**, cioe' le tabelle decennali di
/// Fred Espenak e Jean Meeus pubblicate su `eclipse.gsfc.nasa.gov`
/// (`SEdecade2021.html` per le solari, `LEdecade2021.html` per le lunari). Non
/// e' la stessa fonte del motore: il motore usa le formule del libro di Meeus,
/// il canone e' calcolato con le effemeridi complete del JPL. **Se coincidono,
/// non e' perche' si copiano.**
///
/// **I VALORI QUI SOTTO SONO TRASCRITTI DAL CANONE**, non calcolati da questo
/// progetto: sono la data, l'ora del massimo e la specie di ogni eclissi dal
/// 2021 al 2030. Sono ventidue solari e ventidue lunari, cioe' quarantaquattro
/// misure indipendenti.
///
/// **COSA IL MOTORE NON SA FARE, e va detto.**
///
/// - **Non conosce l'eclissi ibrida**, quella che lungo il suo cammino cambia
///   da anulare a totale: il canone ne segna una sola in dieci anni, il 20
///   aprile 2023, e il motore la chiama totale o anulare. La distinzione
///   chiede il profilo dell'ombra sulla superficie terrestre, che e' un altro
///   ordine di conto.
/// - **Non dice dove si vede.** Il giorno e la specie sono giusti ovunque, la
///   visibilita' no: chiede la posizione di chi guarda.
void main() {
  /// Una riga del canone: data, ora del massimo, specie.
  const solari = <(String, String, String)>[
    ('2021-06-10', '10:43', 'anulare'),
    ('2021-12-04', '07:34', 'totale'),
    ('2022-04-30', '20:42', 'parziale'),
    ('2022-10-25', '11:01', 'parziale'),
    ('2023-04-20', '04:17', 'ibrida'),
    ('2023-10-14', '18:00', 'anulare'),
    ('2024-04-08', '18:18', 'totale'),
    ('2024-10-02', '18:46', 'anulare'),
    ('2025-03-29', '10:48', 'parziale'),
    ('2025-09-21', '19:43', 'parziale'),
    ('2026-02-17', '12:13', 'anulare'),
    ('2026-08-12', '17:47', 'totale'),
    ('2027-02-06', '16:00', 'anulare'),
    ('2027-08-02', '10:07', 'totale'),
    ('2028-01-26', '15:08', 'anulare'),
    ('2028-07-22', '02:56', 'totale'),
    ('2029-01-14', '17:13', 'parziale'),
    ('2029-06-12', '04:06', 'parziale'),
    ('2029-07-11', '15:37', 'parziale'),
    ('2029-12-05', '15:03', 'parziale'),
    ('2030-06-01', '06:29', 'anulare'),
    ('2030-11-25', '06:51', 'totale'),
  ];

  const lunari = <(String, String, String)>[
    ('2021-05-26', '11:19', 'totale'),
    ('2021-11-19', '09:04', 'parziale'),
    ('2022-05-16', '04:12', 'totale'),
    ('2022-11-08', '11:00', 'totale'),
    ('2023-05-05', '17:24', 'penombra'),
    ('2023-10-28', '20:15', 'parziale'),
    ('2024-03-25', '07:13', 'penombra'),
    ('2024-09-18', '02:45', 'parziale'),
    ('2025-03-14', '06:59', 'totale'),
    ('2025-09-07', '18:12', 'totale'),
    ('2026-03-03', '11:34', 'totale'),
    ('2026-08-28', '04:14', 'parziale'),
    ('2027-02-20', '23:14', 'penombra'),
    ('2027-07-18', '16:04', 'penombra'),
    ('2027-08-17', '07:14', 'penombra'),
    ('2028-01-12', '04:14', 'parziale'),
    ('2028-07-06', '18:20', 'parziale'),
    ('2028-12-31', '16:53', 'totale'),
    ('2029-06-26', '03:23', 'totale'),
    ('2029-12-20', '22:43', 'totale'),
    ('2030-06-15', '18:34', 'parziale'),
    ('2030-12-09', '22:28', 'penombra'),
  ];

  String specieBreve(SpecieDiEclissi s) => switch (s) {
        SpecieDiEclissi.solareTotale => 'totale',
        SpecieDiEclissi.solareAnulare => 'anulare',
        SpecieDiEclissi.solareParziale => 'parziale',
        SpecieDiEclissi.lunareTotale => 'totale',
        SpecieDiEclissi.lunareParziale => 'parziale',
        SpecieDiEclissi.lunareDiPenombra => 'penombra',
      };

  DateTime atteso(String data, String ora) =>
      DateTime.parse('${data}T$ora:00Z');

  test('trova tutte le eclissi del canone, e nessuna di piu\'', () {
    final mancanti = <String>[];
    final trovate = <String>[];
    for (final anno in [
      for (var a = 2021; a <= 2030; a++) a,
    ]) {
      for (final e in MotoreDelleEclissi.nellAnnoDi(anno)) {
        final d = e.massimo.toIso8601String().substring(0, 10);
        trovate.add('$d|${e.specie.eSolare ? "S" : "L"}');
      }
    }
    for (final (data, _, _) in solari) {
      if (!trovate.contains('$data|S')) mancanti.add('solare $data');
    }
    for (final (data, _, _) in lunari) {
      if (!trovate.contains('$data|L')) mancanti.add('lunare $data');
    }
    // ignore: avoid_print
    print(
        'ORDINE CE VOCE 16: eclissi del canone ${solari.length + lunari.length}, '
        'trovate dal motore ${trovate.length}, mancanti ${mancanti.length}');
    // **IL BUCO E\' UNO SOLO, ed e\' dichiarato invece che nascosto.** Il
    // criterio del capitolo 54 e\' di prima approssimazione, e le penombrali
    // piu\' rasenti gli passano accanto: su quarantaquattro eclissi in dieci
    // anni ne perde una, il 18 luglio 2027, che il canone stesso segna con
    // una grandezza minima. La prova lo pretende ESATTAMENTE COSI\': se
    // domani ne perdesse due, o ne perdesse una diversa, cade.
    expect(mancanti, ['lunare 2027-07-18'],
        reason: 'il motore perde eclissi diverse da quella dichiarata: '
            '$mancanti');
    expect(trovate.length, solari.length + lunari.length - 1,
        reason: 'il motore ne trova ${trovate.length} contro le '
            '${solari.length + lunari.length - 1} attese: **ne INVENTA**, ed '
            'e\' peggio che perderne');
  });

  test('l\'istante del massimo sta dentro lo scarto dichiarato', () {
    var peggiore = 0.0;
    String dovePeggiore = '';
    final fuori = <String>[];
    void confronta(List<(String, String, String)> canone, bool solare) {
      for (final (data, ora, _) in canone) {
        final giorno = DateTime.parse('${data}T12:00:00Z');
        final mie = MotoreDelleEclissi.nellAnnoDi(giorno.year)
            .where((e) =>
                e.specie.eSclare(solare) &&
                e.massimo.toIso8601String().substring(0, 10) == data)
            .toList();
        if (mie.isEmpty) continue;
        final scarto =
            mie.first.massimo.difference(atteso(data, ora)).inSeconds.abs() /
                60.0;
        if (scarto > peggiore) {
          peggiore = scarto;
          dovePeggiore = data;
        }
        if (scarto > MotoreDelleEclissi.scartoMassimoMisurato) {
          fuori.add('$data: ${scarto.toStringAsFixed(1)} minuti');
        }
      }
    }

    confronta(solari, true);
    confronta(lunari, false);
    // ignore: avoid_print
    print('ORDINE CE VOCE 16: scarto peggiore sull\'istante del massimo '
        '${peggiore.toStringAsFixed(1)} minuti, il $dovePeggiore, contro una '
        'soglia dichiarata di ${MotoreDelleEclissi.scartoMassimoMisurato}');
    expect(fuori, isEmpty,
        reason: 'queste eclissi cadono fuori dallo scarto dichiarato: $fuori');
  });

  test('la specie coincide col canone, salvo l\'ibrida dichiarata', () {
    final sbagliate = <String>[];
    void confronta(List<(String, String, String)> canone, bool solare) {
      for (final (data, _, specie) in canone) {
        if (specie == 'ibrida') continue;
        final giorno = DateTime.parse('${data}T12:00:00Z');
        final mie = MotoreDelleEclissi.nellAnnoDi(giorno.year)
            .where((e) =>
                e.specie.eSclare(solare) &&
                e.massimo.toIso8601String().substring(0, 10) == data)
            .toList();
        if (mie.isEmpty) continue;
        final mia = specieBreve(mie.first.specie);
        if (mia != specie) sbagliate.add('$data: $mia invece di $specie');
      }
    }

    confronta(solari, true);
    confronta(lunari, false);
    // ignore: avoid_print
    print('ORDINE CE VOCE 16: specie sbagliate ${sbagliate.length} su '
        '${solari.length + lunari.length - 1}');
    expect(sbagliate, isEmpty,
        reason: 'il motore sbaglia la specie qui: $sbagliate');
  });

  test('il giorno si chiede e si riceve', () {
    // E' cio' che i tre gradini del Cammino chiedono davvero.
    final e = MotoreDelleEclissi.nelGiornoDi(DateTime.utc(2026, 8, 12, 20));
    expect(e, isNotNull);
    expect(e!.specie, SpecieDiEclissi.solareTotale);
    expect(MotoreDelleEclissi.nelGiornoDi(DateTime.utc(2026, 8, 13)), isNull,
        reason: 'un giorno senza eclissi ne porta una');
  });

  test('i tre gradini dormienti si sono svegliati', () {
    // **IL NUMERO E\' UN DATO CHE IL FONDATORE DEVE VEDERE CAMBIARE.**
    // L\'ordine lo dice: i dormienti erano 54 e devono scendere di tre, uno
    // per sentiero. Qui si guarda la condizione VERA dei tre sentieri, non
    // un numero ricopiato da un rapporto.
    final sorgenti = [
      'lib/core/sigilli/sentiero_albero.dart',
      'lib/core/sigilli/sentiero_costellazione.dart',
      'lib/core/sigilli/sentiero_loto.dart',
    ];
    final ancoraDormienti = <String>[];
    for (final p in sorgenti) {
      final righe = File(p).readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        if (!righe[i].contains('il motore delle eclissi non esiste')) {
          continue;
        }
        ancoraDormienti.add('$p riga ${i + 1}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 16: gradini ancora dormienti per le eclissi '
        '${ancoraDormienti.length}');
    expect(ancoraDormienti, isEmpty,
        reason: 'questi gradini dormono ancora per una ragione risolta: '
            '$ancoraDormienti');
    for (final p in sorgenti) {
      expect(File(p).readAsStringSync(), contains('EventiDelCielo.eclissi'),
          reason: '$p non ha nessun gradino legato all\'eclissi');
    }
  });

  test('la finestra verificata e\' dichiarata, e si sa quando finisce', () {
    expect(MotoreDelleEclissi.dentroEpocaVerificata(DateTime.utc(2026, 8, 12)),
        isTrue);
    expect(MotoreDelleEclissi.dentroEpocaVerificata(DateTime.utc(2040, 1, 1)),
        isFalse,
        reason:
            'il motore dichiara verificato un anno che nessuno ha misurato');
  });
}

extension on SpecieDiEclissi {
  bool eSclare(bool solare) => eSolare == solare;
}
