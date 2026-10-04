// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/cerchio/i_nomi_iniziatici.dart';
import 'package:esoteric_circle/core/cerchio/il_nome_iniziatico.dart';
import 'package:esoteric_circle/core/cerchio/le_regole_del_nome.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL NOME NEL CERCHIO, ordine EY voce 01**, dal lato del telefono.
///
/// Tre cose: le regole del telefono decidono come quelle del server sugli
/// stessi nomi (il file condiviso `il_nome_del_cerchio_prove.json`); nessun
/// nome riservato passa in nessuna sua forma; e il generatore del nome
/// iniziatico, su mille nascite d'esempio, non produce mai un nome che
/// contenga il nome proprio della persona.
void main() {
  final regole =
      LeRegoleDelNome.da(File(LeRegoleDelNome.percorso).readAsStringSync());

  test('il telefono decide come il server sugli stessi nomi', () {
    final prove = jsonDecode(
        File('functions/src/il_nome_del_cerchio_prove.json')
            .readAsStringSync()) as Map<String, dynamic>;
    final casi = prove['casi'] as List<dynamic>;
    final diversi = <String>[];
    for (final c in casi) {
      final nome = (c as List<dynamic>)[0] as String;
      final atteso = c[1] as String?;
      final dato = regole.verdetto(nome)?.name;
      if (dato != atteso) diversi.add('${jsonEncode(nome)}: $atteso, $dato');
    }
    print('EY.01 TELEFONO E SERVER: ${casi.length} casi, diversi '
        '${diversi.length}');
    expect(casi.length, greaterThanOrEqualTo(40));
    expect(diversi, isEmpty);
  });

  test('GUARDIA EY.01: nessun nome riservato passa, in nessuna sua forma', () {
    const cifre = {'e': '3', 'a': '4', 'o': '0', 'i': '1', 's': '5', 't': '7'};
    final passati = <String>[];
    var provati = 0;
    for (final r in regole.riservati) {
      final forme = <String>[
        r,
        r.toLowerCase(),
        r.toUpperCase(),
        '$r.',
        '.$r',
        '${r}_',
        '${r}77',
        r.replaceAll(' ', '.'),
        r.replaceAll(' ', ''),
        [for (final c in r.split('')) cifre[c.toLowerCase()] ?? c].join(),
        for (var i = 0; i < r.length; i++)
          if (cifre[r[i].toLowerCase()] != null)
            r.substring(0, i) + cifre[r[i].toLowerCase()]! + r.substring(i + 1),
      ].where((f) => f.length >= 3 && f.length <= 20);
      for (final f in forme) {
        provati++;
        if (regole.verdetto(f) == null) passati.add(f);
      }
    }
    print('EY.01 RISERVATI SUL TELEFONO: ${regole.riservati.length} nomi, '
        '$provati forme, passate ${passati.length}');
    expect(regole.riservati, hasLength(15));
    expect(passati, isEmpty);
  });

  test('gli elenchi del nome iniziatico: quanti, e nessun grado promesso', () {
    print('EY.01 ELENCHI: appellativi ${INomiIniziatici.appellativi.length}, '
        'qualita\' ${INomiIniziatici.qualita.length}');
    expect(INomiIniziatici.appellativi.length, greaterThanOrEqualTo(50));
    expect(INomiIniziatici.qualita.length, greaterThanOrEqualTo(60));
    expect(INomiIniziatici.appellativi.toSet(),
        hasLength(INomiIniziatici.appellativi.length));
    expect(INomiIniziatici.qualita.toSet(),
        hasLength(INomiIniziatici.qualita.length));
    const gradi = [
      'maestro',
      'maestra',
      'adepto',
      'adepta',
      'iniziato',
      'iniziata',
      'illuminato',
      'illuminata',
      'sacerdote',
      'sacerdotessa',
      'gran',
      'magister',
      'ierofante',
      'gerarca',
      'eletto',
      'eletta',
      'gradi',
    ];
    final tutte = [...INomiIniziatici.appellativi, ...INomiIniziatici.qualita];
    final colGrado = [
      for (final p in tutte)
        if (gradi.contains(p.toLowerCase())) p,
    ];
    expect(colGrado, isEmpty);
    // Ogni parola passa le regole del nome da sola.
    final cadute = [
      for (final p in tutte)
        if (p.length >= 3 && regole.verdetto(p) != null) p,
    ];
    expect(cadute, isEmpty);
  });

  test(
      'GUARDIA EY.01: su mille nascite il nome proposto non contiene mai il '
      'nome proprio, e passa sempre le regole', () {
    // I nomi propri scelti apposta fra quelli che sono anche simboli o
    // parole degli elenchi: Stella, Luna, Leone, Alba, Giada, Perla, Ambra...
    const nomi = [
      'Stella',
      'Luna',
      'Leone',
      'Alba',
      'Giada',
      'Perla',
      'Ambra',
      'Aurora',
      'Celeste',
      'Fiamma',
      'Sole',
      'Marco',
      'Giulia',
      'Lupo',
      'Corvo',
      'Mago',
      'Salvia',
      'Edera',
      'Felice',
      'Fedele',
      'Serena',
      'Vergine',
      'Gemelli',
      'Orso',
      'Volpe',
      'Elena',
      'Matteo',
      'Anna',
      'Luca',
      'Sofia',
    ];
    final luoghi = [
      const BirthPlace(
          city: 'Roma',
          latitude: 41.9,
          longitude: 12.5,
          timeZoneId: 'Europe/Rome',
          utcOffsetMinutes: 60,
          isApproximate: false),
      null,
    ];
    final contengono = <String>[];
    final rifiutati = <String>[];
    final nomiDati = <String>{};
    var provate = 0;
    // Mille nascite vere fra il 1940 e il 2012, da un generatore col seme
    // fisso: la prova rifa' sempre le stesse.
    final caso = Random(2026);
    for (var i = 0; i < 1000; i++) {
      final nascita = DateTime(1940 + caso.nextInt(72), 1 + caso.nextInt(12),
          1 + caso.nextInt(28), caso.nextInt(24), caso.nextInt(60));
      final identita = BirthIdentity(
        birthMoment: nascita,
        hasBirthTime: i.isEven,
        birthPlace: luoghi[i % 2],
      );
      final proprio = nomi[i % nomi.length];
      final nome =
          IlNomeIniziatico.per(identita: identita, nomeProprio: proprio);
      provate++;
      nomiDati.add(nome);
      final piano = nome.toLowerCase();
      if (piano.contains(proprio.toLowerCase())) {
        contengono.add('$proprio: $nome');
      }
      if (regole.verdetto(nome) != null || nome.length > 20) {
        rifiutati.add('$nome (${regole.verdetto(nome)?.name})');
      }
      // Stessa nascita, stesso nome: e' deterministico.
      expect(
          IlNomeIniziatico.per(identita: identita, nomeProprio: proprio), nome);
    }
    print('EY.01 GENERATORE: $provate nascite, ${nomiDati.length} nomi '
        'diversi, col nome proprio ${contengono.length}, rifiutati '
        '${rifiutati.length}. Esempi: ${nomiDati.take(6).join(' | ')}');
    expect(contengono, isEmpty);
    expect(rifiutati, isEmpty);
    expect(nomiDati.length, greaterThan(500),
        reason: 'mille nascite danno troppo pochi nomi');
  });
}
