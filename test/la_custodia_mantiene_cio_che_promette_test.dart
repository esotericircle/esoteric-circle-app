import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CUSTODIA MANTIENE CIO' CHE PROMETTE. Ordine CF voce 07.
///
/// **Il fatto del fondatore, verbatim**: "poi in effetti scopro che i miei
/// dati di nascita, luogo ecc non sono rimasti memorizzati e ho dovuto
/// reinserirli quando mi ha mostrato la schermata popup apposita."
///
/// **Perche' questa e' la piu' grave delle voci del rientro.** Dentro l'app
/// c'e' scritta una promessa: il cielo di nascita e i traguardi tornano su
/// qualsiasi telefono. Se la carta natale non torna, quella promessa e' una
/// bugia, e una bugia scritta vale meno di un difetto taciuto.
///
/// **Le prove ENUMERANO invece di elencare a mano, ed e' il punto.** Il
/// giorno che nasce un campo nuovo nella custodia, o torna davvero oppure
/// una di queste prove cade: nessuno deve ricordarsi di aggiungerlo qui.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
  });

  /// I campi che `IdentitaDaCustodire` dichiara, letti dal sorgente.
  ///
  /// Si legge il sorgente e non si scrive un elenco a mano, perche' un elenco
  /// a mano invecchia in silenzio: e' esattamente il modo in cui `scarto` e'
  /// rimasto per mesi un campo che nessuno riempiva.
  List<String> campiDichiarati() {
    final sorgente =
        File('lib/core/cammino/cammino_da_custodire.dart').readAsStringSync();
    final da = sorgente.indexOf('class IdentitaDaCustodire');
    expect(da, greaterThan(0), reason: 'la classe della custodia non c\'e\'');
    final corpo = sorgente.substring(da);
    return RegExp(r'^  final [A-Za-z<>?]+ (\w+);', multiLine: true)
        .allMatches(corpo)
        .map((m) => m.group(1)!)
        .toList();
  }

  test('ogni campo dichiarato viaggia e torna', () {
    final campi = campiDichiarati();
    final sorgente =
        File('lib/core/cammino/cammino_da_custodire.dart').readAsStringSync();
    final daA = sorgente.indexOf('Map<String, Object?> aMappa() => {',
        sorgente.indexOf('class IdentitaDaCustodire'));
    final aMappa = sorgente.substring(daA, sorgente.indexOf('};', daA));
    final daD = sorgente.indexOf('static IdentitaDaCustodire? daMappa');
    final daMappa = sorgente.substring(daD, sorgente.indexOf('\n  }', daD));

    final muti = <String>[];
    for (final campo in campi) {
      if (!aMappa.contains("'$campo'")) muti.add('$campo non parte (aMappa)');
      if (!daMappa.contains("'$campo'")) {
        muti.add('$campo non torna (daMappa)');
      }
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 07: campi dichiarati dalla custodia ${campi.length} '
        '(${campi.join(", ")}), muti ${muti.length}');
    expect(muti, isEmpty,
        reason: 'questi campi la custodia li dichiara e non li porta: $muti. '
            'Un campo dichiarato e non portato e\' una promessa scritta e '
            'non mantenuta');
  });

  test('un giro intero non perde niente per strada', () {
    // **IL GIRO VERO, coi valori dentro.** La prova sopra guarda il sorgente;
    // questa guarda i dati, perche' un campo puo' comparire in tutte e due le
    // mappe e perdersi lo stesso su una conversione.
    final partita = IdentitaDaCustodire(
      nome: 'Mauro',
      forma: 'masculine',
      giorno: DateTime(1972, 5, 20),
      ora: '09:15',
      luogo: 'Tokyo',
      latitudine: 35.6895,
      longitudine: 139.6917,
      fuso: 'Asia/Tokyo',
      scarto: 540,
    );
    final tornata = IdentitaDaCustodire.daMappa(partita.aMappa());
    expect(tornata, isNotNull, reason: 'la custodia non e\' tornata affatto');
    final perse = <String>[];
    void confronta(String nome, Object? prima, Object? dopo) {
      if (prima != dopo) perse.add('$nome: partito "$prima", tornato "$dopo"');
    }

    confronta('nome', partita.nome, tornata!.nome);
    confronta('forma', partita.forma, tornata.forma);
    confronta('giorno', partita.giorno, tornata.giorno);
    confronta('ora', partita.ora, tornata.ora);
    confronta('luogo', partita.luogo, tornata.luogo);
    confronta('latitudine', partita.latitudine, tornata.latitudine);
    confronta('longitudine', partita.longitudine, tornata.longitudine);
    confronta('fuso', partita.fuso, tornata.fuso);
    confronta('scarto', partita.scarto, tornata.scarto);
    // ignore: avoid_print
    print('ORDINE CF VOCE 07: giro intero, voci perse ${perse.length}');
    expect(perse, isEmpty, reason: 'la custodia ha perso: $perse');
  });

  test('senza lo scarto il cielo non finisce a Roma per tutti', () {
    // **IL CAMPO CHE NESSUNO RIEMPIVA.** `daiDettagli` non puo' scrivere lo
    // scarto, perche' il `BirthPlace` dell'astronomia porta il fuso IANA e
    // non i minuti: al ritorno `scarto` e' sempre nullo. Prima di questa voce
    // la ricostruzione metteva sessanta a chiunque, cioe' l'ora di Roma anche
    // a chi e' nato dall'altra parte del mondo, e la carta natale nasceva
    // spostata di ore.
    const senzaScarto = IdentitaDaCustodire(
      nome: 'Mauro',
      giorno: null,
      luogo: 'Tokyo, Giappone',
      latitudine: 35.6895,
      longitudine: 139.6917,
      fuso: 'Asia/Tokyo',
    );
    final conGiorno = IdentitaDaCustodire(
      nome: senzaScarto.nome,
      giorno: DateTime(1972, 5, 20),
      ora: '09:15',
      luogo: senzaScarto.luogo,
      latitudine: senzaScarto.latitudine,
      longitudine: senzaScarto.longitudine,
      fuso: senzaScarto.fuso,
    );
    final identita = conGiorno.aBirthIdentity();
    expect(identita, isNotNull);
    final minuti = identita!.birthPlace?.utcOffsetMinutes;
    // ignore: avoid_print
    print('ORDINE CF VOCE 07: senza scarto custodito, Tokyo ricostruita a '
        '$minuti minuti dal tempo universale');
    expect(minuti, isNot(60),
        reason: 'una nascita a Tokyo torna con lo scarto di Roma: la carta '
            'natale nasce spostata di ore e nessuno lo dice');
  });
}
