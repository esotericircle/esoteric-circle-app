import 'dart:io';

import 'package:esoteric_circle/core/rituals/chiamata_del_primo_giorno.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE NOTIFICHE SI CHIEDONO AL PRIMO DONO, IN DUE RIGHE.** Ordine EV, il
/// fondatore il 1 ottobre 2026, con la cattura della scheda all'avvio:
/// *"Il pulsante giallo non si può cliccare perché è sotto il menù esplora.
/// Il testo è eccessivo. Cmq elimina tutta la scheda all'avvio. Serve solo una
/// scheda "Attiva le notifiche" quando l'utente apre la prima volta un dono e
/// con il testo minimo indispensabile Senza dire 4 notifiche al giorno e altri
/// dettagli"*; e poi: *"Aggiungi magari, che potrà attivare e disattivare le
/// notifiche dal menù notifiche"*.
///
/// La scheda veniva da `ChiamataDelPrimoGiorno.forseChiedi` in `app.dart`
/// (ordine BZ voce 04) col testo lungo di `AvvisiDelRito.spiegazione`.
void main() {
  /// Il codice senza i commenti: le spiegazioni nominano la porta di prima.
  String codice(String percorso) => File(percorso)
      .readAsLinesSync()
      .where((r) => !r.trimLeft().startsWith('//'))
      .join('\n');

  test('all\'avvio nessuna scheda delle notifiche', () {
    final app = codice('lib/app.dart');
    expect(app, isNot(contains('ChiamataDelPrimoGiorno.')),
        reason: 'l\'avvio chiede ancora il permesso con la scheda: il '
            'fondatore l\'ha fatta togliere');
  });

  test('ogni Dono chiede alla sua prima apertura', () {
    const doni = [
      'lib/features/rituals/arcano_dell_alba_screen.dart',
      'lib/features/rituals/breath_destiny_screen.dart',
      'lib/features/rituals/sunset_rune_screen.dart',
      'lib/features/rituals/dream_rite_screen.dart',
    ];
    final senza = [
      for (final d in doni)
        if (!codice(d).contains('ChiamataDelPrimoGiorno.alPrimoDono(context)'))
          d,
    ];
    // ignore: avoid_print
    print('ORDINE EV, NOTIFICHE: Doni che chiedono alla prima apertura '
        '${doni.length - senza.length} su ${doni.length}');
    expect(senza, isEmpty);
  });

  test('il testo e\' il minimo indispensabile', () {
    // Non const: l'innesto della Regola A ne fa un getter.
    // ignore: prefer_const_declarations
    final testo = ChiamataDelPrimoGiorno.testo;
    // ignore: avoid_print
    print('ORDINE EV, NOTIFICHE: titolo "${ChiamataDelPrimoGiorno.titolo}", '
        'testo di ${testo.length} caratteri: "$testo"');
    expect(ChiamataDelPrimoGiorno.titolo, 'Attiva le notifiche');
    expect(testo.length, lessThanOrEqualTo(100),
        reason: 'il foglio torna lungo: il fondatore ha chiesto il minimo');
    expect(RegExp(r'\d|quattro|cinque|al giorno|orario|indicativ')
        .hasMatch(testo.toLowerCase()), isFalse,
        reason: 'il foglio torna a dire quanti avvisi e a che ora');
    expect(testo, contains('menù Notifiche'));
  });
}
