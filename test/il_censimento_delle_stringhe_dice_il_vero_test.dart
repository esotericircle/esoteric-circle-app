import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL CENSIMENTO DELLE STRINGHE DICE IL VERO. Ordine CE voce 15.
///
/// **Un documento scritto a mano invecchia il giorno dopo, e nessuno se ne
/// accorge.** E' la ragione per cui gli altri censimenti di questo progetto si
/// rigenerano: questa prova fa la stessa guardia sul censimento delle stringhe,
/// confrontando le marche in cima al documento con la struttura vera del
/// repository.
///
/// **E sorveglia la premessa della voce.** L'ordine chiede di verificare che
/// non esista gia' nessun sistema di traduzione: se domani qualcuno ne aggiunge
/// uno senza toccare il documento, il documento comincia a mentire.
void main() {
  final documento = File('docs/traduzione/censimento.md');

  int marca(String nome) {
    final m = RegExp('<!-- $nome: (\\d+) -->')
        .firstMatch(documento.readAsStringSync());
    expect(m, isNotNull,
        reason: 'la marca $nome non c\'e\' piu\' nel documento: rigeneralo con '
            'dart run tool/censimento_stringhe.dart');
    return int.parse(m!.group(1)!);
  }

  test('il documento esiste e porta i suoi numeri', () {
    expect(documento.existsSync(), isTrue,
        reason: 'il censimento delle stringhe non c\'e\': e\' il prodotto '
            'della voce, non un di piu\'');
    final totale = marca('TOTALE_STRINGHE');
    final contenuto = marca('NEI_CORPUS');
    final interfaccia = marca('NEL_CODICE');
    final accordo = marca('CON_ACCORDO');
    final file = marca('FILE_TOCCATI');
    // ignore: avoid_print
    print('ORDINE CE VOCE 15: stringhe $totale in $file file, contenuto '
        '$contenuto, interfaccia $interfaccia, con accordo $accordo');
    expect(totale, contenuto + interfaccia,
        reason: 'le due meta\' non fanno il totale: il documento si '
            'contraddice da solo');
    expect(totale, greaterThan(1000),
        reason: 'il censimento conta $totale stringhe: o l\'app si e\' '
            'svuotata, o il metodo si e\' rotto');
    expect(file, greaterThan(50));
  });

  test('nessun sistema di traduzione e\' comparso senza dirlo', () {
    // **LA PREMESSA DELLA VOCE, e va risorvegliata.** Il documento dichiara
    // zero stringhe da un sistema di localizzazione perche' quel sistema non
    // esiste: il giorno che esiste, questa riga cade e il documento va
    // rifatto insieme alla decisione che ci sta sopra.
    expect(marca('DA_UN_SISTEMA_DI_TRADUZIONE'), 0,
        reason: 'qualcosa passa da un sistema di traduzione: il censimento e\' '
            'da rifare');
    expect(Directory('lib/l10n').existsSync(), isFalse,
        reason: 'e\' comparsa lib/l10n');
    final arb = Directory('.')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) =>
            f.path.endsWith('.arb') && !f.path.contains('.dart_tool'))
        .toList();
    expect(arb, isEmpty, reason: 'sono comparsi file .arb: $arb');
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final segno in ['flutter_localizations', 'intl:']) {
      expect(pubspec.contains(segno), isFalse,
          reason: 'pubspec.yaml dichiara $segno: la voce diceva nessun '
              'pacchetto aggiunto');
    }
  });

  test('la voce non ha tradotto niente, come chiedeva', () {
    // **NESSUNA RIGA DI TRADUZIONE.** L'ordine e' esplicito: il documento e'
    // il prodotto della voce, e non doveva nascerne codice di traduzione.
    final segni = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final s = f.readAsStringSync();
      if (s.contains('AppLocalizations') ||
          s.contains('S.of(context)') ||
          s.contains('.tr()')) {
        segni.add(f.path);
      }
    }
    expect(segni, isEmpty,
        reason: 'e\' comparso codice di traduzione: $segni');
  });
}
