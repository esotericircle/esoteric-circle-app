import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **L'ASSERZIONE NON PESCA IL SUO COMMENTO.** Ordine CZ, voce 15.
///
/// **NOVE VOLTE.** In due giorni, nove asserzioni che cercano una parola nel
/// sorgente per vietarla hanno trovato **il commento che spiega perche' quella
/// parola e' vietata**. La prova accusava se stessa: chi la leggeva perdeva
/// tempo su un difetto che non esisteva e, peggio, imparava a non fidarsi
/// della guardia.
///
/// E' una delle tre origini della **REGOLA H**, nata in questo ordine.
///
/// **IL CENSIMENTO, col suo numero.** Su **813 file di prova**, **311**
/// leggono il sorgente senza togliere i commenti prima di contare, e **88**
/// provano una presenza senza provare nessuna assenza. Gli elenchi stanno in
/// `docs/ordini/CZ_regola_h.txt`.
///
/// **Non si riscrivono 311 file: si riscrive la porta.** `senzaCommenti` in
/// `test/sorgenti_di_lib.dart` e' l'unico posto dove quella logica vive, e
/// questa prova la sorveglia sui casi che l'hanno rotta.
void main() {
  group('La porta toglie i commenti e non tocca le stringhe', () {
    test('Toglie la riga di commento intera', () {
      final fuori = senzaCommenti('// vietato scrivere pippo\nfinal a = 1;');
      expect(fuori.contains('pippo'), isFalse,
          reason: 'il commento e\' rimasto: e\' il difetto delle nove volte');
      expect(fuori.contains('final a = 1;'), isTrue,
          reason: 'il codice e\' sparito insieme al commento');
    });

    test('Toglie il commento di documentazione', () {
      final fuori = senzaCommenti('/// qui non si scrive pippo\nvar b = 2;');
      expect(fuori.contains('pippo'), isFalse);
      expect(fuori.contains('var b = 2;'), isTrue);
    });

    test('Toglie il commento in coda al codice', () {
      final fuori = senzaCommenti('final c = 3; // niente pippo qui');
      expect(fuori.contains('pippo'), isFalse,
          reason: 'il commento di coda e\' il caso piu\' frequente di tutti');
      expect(fuori.contains('final c = 3;'), isTrue);
    });

    test('Toglie il blocco su piu\' righe', () {
      final fuori = senzaCommenti('/* pippo\n   ancora pippo */\nvar d = 4;');
      expect(fuori.contains('pippo'), isFalse);
      expect(fuori.contains('var d = 4;'), isTrue);
    });

    test('REGOLA H: e NON tocca le barre dentro una stringa', () {
      // **L'assenza da provare e' questa.** Una porta che tagliasse a ogni
      // doppia barra mangerebbe gli indirizzi, cioe' proprio i testi che le
      // guardie devono guardare: sarebbe una cecita' peggiore di quella che
      // cura, perche' silenziosa.
      const sorgente = "final url = 'https://esotericircle.com/pippo';";
      final fuori = senzaCommenti(sorgente);
      expect(fuori.contains('https://esotericircle.com/pippo'), isTrue,
          reason: 'la porta ha tagliato dentro una stringa: gli indirizzi '
              'sparirebbero dal sorgente che le guardie leggono, e nessuna '
              'guardia se ne accorgerebbe');
    });

    test('REGOLA H: e non tocca un apice dentro una stringa', () {
      const sorgente = "final s = 'l\\'ora'; // pippo";
      final fuori = senzaCommenti(sorgente);
      expect(fuori.contains('pippo'), isFalse,
          reason: 'un apice sfuggito dentro la stringa ha confuso la porta e '
              'il commento e\' sopravvissuto');
    });
  });

  test('IL CASO VERO: una guardia che vieta una parola non trova se stessa',
      () {
    // **Si prova sul file di questa prova**, che nomina `pippo` nei suoi
    // commenti qui sopra e non lo usa mai come codice fuori dalle stringhe.
    // E' il caso esatto delle nove volte, riprodotto sul vivo.
    final questo = File('test/l_asserzione_non_pesca_il_suo_commento_test.dart')
        .readAsStringSync();
    // ESCADELCOMMENTO: questa parola vive SOLO qui, dentro un commento, e in
    // nessuna stringa di questo file. E' l'esca esatta delle nove volte.
    expect(questo.contains('ESCADEL' 'COMMENTO'), isTrue,
        reason: 'il file non contiene l\'esca: questa prova non misura niente');

    final codice = senzaCommenti(questo);
    expect(codice.contains('ESCADEL' 'COMMENTO'), isFalse,
        reason: 'l\'esca e\' sopravvissuta alla porta: una guardia che vieta '
            'una parola troverebbe ancora il commento che la spiega, ed e\' '
            'il difetto che questo progetto ha pagato nove volte');
  });

  test('Il censimento della Regola H e\' scritto e leggibile', () {
    // **Il numero non vive in un referto e basta**: sta in un file che
    // chiunque puo' rileggere, e questa prova lo tiene vivo.
    final f = File('docs/ordini/CZ_regola_h.txt');
    expect(f.existsSync(), isTrue,
        reason: 'manca il censimento delle guardie sotto la Regola H');
    final t = f.readAsStringSync();
    expect(t, contains('PROVANO UNA PRESENZA SENZA PROVARE NESSUNA ASSENZA'));
    expect(t, contains('LEGGONO IL SORGENTE SENZA TOGLIERE I COMMENTI'));
  });
}
