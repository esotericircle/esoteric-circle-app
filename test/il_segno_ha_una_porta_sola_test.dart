// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **IL SEGNO HA UNA PORTA SOLA. Ordine FC voce 10.3 e, 5 ottobre 2026.**
///
/// Il fondatore: *"Scrivi una guardia che diventa rossa se nasce una seconda
/// funzione che ricava il segno da una data."* La porta e'
/// `lib/core/astro/il_segno_del_cielo.dart` (`IlSegnoDelCielo`): una data
/// diventa un segno solo li', e una longitudine diventa un segno solo li'.
///
/// Prima della cura le strade erano parecchie (l'elenco e' nel rapporto
/// dell'ordine FC): una tabella di date fisse (`Zodiac.fromDate`), due
/// funzioni del cielo di adesso (`NightSky.sunSign` e `moonSign`), due
/// gemelle del segno di un corpo a una data, e l'aritmetica dei trenta gradi
/// scritta a mano in tredici punti. La guardia ne riconosce le tre forme:
///
/// 1. **L'aritmetica dei trenta gradi** che da' un segno: un indice di
///    `Zodiac.values` o un numero di segno fatto dividendo per 30.
/// 2. **Una funzione che rende un segno e legge il calendario**: dichiara di
///    rendere `Zodiac` e nel suo corpo legge `.month` o `.day`, cioe' una
///    tabella di date fisse.
/// 3. **Una funzione che rende un segno da una data senza la porta**:
///    dichiara di rendere `Zodiac`, prende un `DateTime`, e nel corpo non
///    chiama `IlSegnoDelCielo`.
///
/// I commenti non contano: la guardia legge il codice.
void main() {
  const porta = 'lib/core/astro/il_segno_del_cielo.dart';

  /// Il codice di un file, senza i commenti di riga.
  String codice(String sorgente) => sorgente
      .split('\n')
      .map((r) => r.trimLeft().startsWith('//') ? '' : r)
      .join('\n');

  /// Il corpo di una dichiarazione che comincia a [inizio]: fino al `;`
  /// della freccia, o fino alla graffa che chiude quella aperta.
  String corpoDa(String t, int inizio) {
    final freccia = t.indexOf('=>', inizio);
    final graffa = t.indexOf('{', inizio);
    final puntoEVirgola = t.indexOf(';', inizio);
    if (freccia >= 0 &&
        (graffa < 0 || freccia < graffa) &&
        (puntoEVirgola < 0 || freccia < puntoEVirgola)) {
      // Con la freccia il corpo finisce al primo `;` fuori dalle parentesi.
      var profondita = 0;
      for (var i = freccia; i < t.length; i++) {
        final c = t[i];
        if (c == '(' || c == '[' || c == '{') profondita++;
        if (c == ')' || c == ']' || c == '}') profondita--;
        if (c == ';' && profondita <= 0) return t.substring(inizio, i + 1);
      }
      return t.substring(inizio);
    }
    if (graffa < 0) return '';
    var profondita = 0;
    for (var i = graffa; i < t.length; i++) {
      if (t[i] == '{') profondita++;
      if (t[i] == '}') {
        profondita--;
        if (profondita == 0) return t.substring(inizio, i + 1);
      }
    }
    return t.substring(inizio);
  }

  final trentaGradi = RegExp(
      r'Zodiac\.values\s*\[[^\]]*(~/|/)\s*30\b|(~/|/)\s*30\)?(\.floor\(\))?\)?\s*%\s*12');
  final dichiarazione = RegExp(
      r'^\s*(?:static\s+)?Zodiac\??\s+(?:get\s+)?(\w+)\s*(\(|=>|\{)',
      multiLine: true);

  /// Le tre forme del difetto in un file; vuoto se non ce ne sono.
  List<String> gemelleIn(String percorso, String sorgente) {
    if (percorso == porta) return const [];
    final t = codice(sorgente);
    final trovate = <String>[];
    for (final m in trentaGradi.allMatches(t)) {
      final riga = '\n'.allMatches(t.substring(0, m.start)).length + 1;
      trovate.add('$percorso:$riga, i trenta gradi a mano: "${m.group(0)}"');
    }
    for (final m in dichiarazione.allMatches(t)) {
      final corpo = corpoDa(t, m.start);
      final riga = '\n'.allMatches(t.substring(0, m.start)).length + 1;
      final nome = m.group(1);
      if (RegExp(r'\.(month|day)\b').hasMatch(corpo)) {
        trovate.add('$percorso:$riga, $nome rende un segno leggendo il '
            'calendario');
      }
      final firma = corpo.substring(
          0, corpo.contains('{') ? corpo.indexOf('{') : corpo.length);
      if (firma.contains('DateTime') && !corpo.contains('IlSegnoDelCielo.')) {
        trovate.add('$percorso:$riga, $nome rende un segno da una data '
            'senza la porta');
      }
    }
    return trovate;
  }

  test('FC.10.3 e: una data diventa un segno solo nella porta', () {
    final file = sorgentiDiLib();
    cardinaleMinimo(file.length, 800, cosa: 'file di lib guardati');
    final gemelle = <String>[];
    var dichiarazioniDiSegni = 0;
    var chiamateAllaPorta = 0;
    for (final f in file) {
      final percorso = f.path.replaceAll('\\', '/');
      final sorgente = f.readAsStringSync();
      gemelle.addAll(gemelleIn(percorso, sorgente));
      dichiarazioniDiSegni += dichiarazione.allMatches(codice(sorgente)).length;
      chiamateAllaPorta +=
          'IlSegnoDelCielo.'.allMatches(codice(sorgente)).length;
    }
    // Il riconoscitore deve avere qualcosa da guardare: le funzioni che
    // rendono un segno ci sono, e la porta e' chiamata.
    cardinaleMinimo(dichiarazioniDiSegni, 10,
        cosa: 'dichiarazioni che rendono un segno');
    cardinaleMinimo(chiamateAllaPorta, 40, cosa: 'chiamate alla porta');
    print('FC.10.3 LA PORTA DEL SEGNO: file ${file.length}, dichiarazioni '
        'che rendono un segno $dichiarazioniDiSegni, chiamate alla porta '
        '$chiamateAllaPorta, gemelle ${gemelle.length} $gemelle');
    expect(gemelle, isEmpty,
        reason:
            'una seconda strada dalla data al segno: ${gemelle.join('; ')}');
  });

  test('FC.10.3 e: il riconoscitore prende le tre forme del difetto', () {
    // La tabella delle date fisse, com'era.
    const tabella = '''
  static Zodiac fromDate(DateTime date) {
    final m = date.month;
    final d = date.day;
    return Zodiac.capricorn;
  }
''';
    // I trenta gradi scritti a mano.
    const aMano = 'final z = Zodiac.values[(l ~/ 30) % 12];';
    // Una data senza la porta.
    const senzaPorta = '''
  static Zodiac sunSign(DateTime date) =>
      _signOfLongitude(sunEclipticLongitude(date));
''';
    // Una che passa dalla porta: non e' una gemella.
    const buona = '''
  Zodiac get segno =>
      IlSegnoDelCielo.diNascita(momento, oraNota: oraNota, fuso: fuso);
''';
    expect(gemelleIn('lib/x.dart', tabella), isNotEmpty);
    expect(gemelleIn('lib/x.dart', aMano), isNotEmpty);
    expect(gemelleIn('lib/x.dart', senzaPorta), isNotEmpty);
    expect(gemelleIn('lib/x.dart', buona), isEmpty);
  });
}
