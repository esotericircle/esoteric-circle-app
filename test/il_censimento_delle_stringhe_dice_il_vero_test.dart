import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

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

  test(
      'NESSUN TESTO PASSA DA UN SISTEMA DI TRADUZIONE, e l\'impalcatura c\'e\'',
      () {
    // **QUESTA PROVA E' STATA RISCRITTA, E LO DICEVA DA SE'.** Ordine DM, 16
    // settembre 2026.
    //
    // Nella forma dell'ordine CE voce 15 pretendeva che **non esistesse
    // nessun sistema di localizzazione**: niente `flutter_localizations`,
    // niente `intl`, nessuna `Locale`. Era la premessa di quella voce, ed era
    // vera. Il suo stesso commento diceva come sarebbe finita: *"il giorno
    // che esiste, questa riga cade e il documento va rifatto insieme alla
    // decisione che ci sta sopra"*. **Quel giorno e' l'ordine DM**, che ha
    // aggiunto i delegati di sistema perche' i selettori di data smettessero
    // di parlare inglese.
    //
    // **Cio' che la prova sorveglia adesso e' la cosa vera.** Non che
    // l'impalcatura non esista: che **i testi non ci passino ancora**.
    // L'ordine DM dice per nome che l'app e' predisposta e non tradotta, e il
    // giorno che qualcuno comincia a tradurre il corpus questa riga cade e il
    // censimento va rifatto insieme alla decisione che ci sta sopra.
    expect(marca('DA_UN_SISTEMA_DI_TRADUZIONE'), 0,
        reason: 'qualcosa passa da un sistema di traduzione: il censimento e\' '
            'da rifare');
    expect(Directory('lib/l10n').existsSync(), isFalse,
        reason: 'e\' comparsa lib/l10n: il generatore di Flutter e\' entrato, '
            'e con lui un secondo posto dove vivono i testi');
    final arb = Directory('.')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.arb') && !f.path.contains('.dart_tool'))
        .toList();
    expect(arb, isEmpty, reason: 'sono comparsi file .arb: $arb');

    // **E L'IMPALCATURA DEVE ESSERCI**, che e' il rovescio della stessa
    // moneta: se qualcuno la togliesse, i selettori di sistema tornerebbero
    // a parlare inglese e nessuna prova se ne accorgerebbe.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    for (final segno in ['flutter_localizations', 'intl:']) {
      expect(pubspec.contains(segno), isTrue,
          reason: 'pubspec.yaml non dichiara piu $segno: l impalcatura '
              'dell ordine DM e stata tolta, e i widget di sistema tornano '
              'a parlare inglese');
    }
  });

  test('la voce non ha tradotto niente, come chiedeva', () {
    // **NESSUNA RIGA DI TRADUZIONE.** L'ordine e' esplicito: il documento e'
    // il prodotto della voce, e non doveva nascerne codice di traduzione.
    final segni = <String>[];
    for (final f in sorgentiDiLib()) {
      final s = f.readAsStringSync();
      if (s.contains('AppLocalizations') ||
          s.contains('S.of(context)') ||
          s.contains('.tr()')) {
        segni.add(f.path);
      }
    }
    expect(segni, isEmpty, reason: 'e\' comparso codice di traduzione: $segni');
  });
}
