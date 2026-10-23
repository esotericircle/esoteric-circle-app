// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/oracolo_angeli/le_domande_dell_oracolo.dart';
import 'package:esoteric_circle/core/tarot/domanda_della_persona.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **DIECI DOMANDE PER ARGOMENTO.** Ordine FY voce FY.13, 16 ottobre 2026.
/// Il fondatore: *"Oracolo Angeli: 10 domande suggerite per argomento"*.
///
/// Per ogni argomento dell'Oracolo dieci domande proposte, nella voce di
/// Medora (la persona le affida cosi' come sono: prima persona, concrete,
/// mai sulle intenzioni di altre persone), diverse fra loro. **Diverse si
/// misura**, non si dichiara: nessuna domanda ripete un'altra, e due domande
/// qualsiasi delle settanta condividono meno della meta' delle loro parole
/// portanti (`DomandaDellaPersona.portanti`, la stessa misura della Stesa).
/// E ogni domanda e' riconosciuta dal telefono come del suo argomento, cosi'
/// il titolo di ripiego senza modello parla dell'argomento giusto.
void main() {
  const temi = TemaDellOracolo.values;

  double somiglianza(String a, String b) {
    final pa = DomandaDellaPersona.portanti(a).toSet();
    final pb = DomandaDellaPersona.portanti(b).toSet();
    final unione = pa.union(pb);
    if (unione.isEmpty) return 1;
    return pa.intersection(pb).length / unione.length;
  }

  test('ogni argomento ha dieci domande', () {
    cardinaleMinimo(temi.length, 7, cosa: 'argomenti dell\'Oracolo');
    final conti = {for (final t in temi) t.nome: t.domande.length};
    print('FY.13 MISURA domande per argomento: $conti');
    for (final t in temi) {
      expect(t.domande, hasLength(10), reason: '${t.nome}: non sono dieci');
    }
  });

  test('le settanta domande sono diverse fra loro', () {
    final tutte = [for (final t in temi) ...t.domande];
    cardinaleMinimo(tutte.length, 70, cosa: 'domande proposte');
    final normali = {
      for (final d in tutte) d.toLowerCase().replaceAll(RegExp(r'\W'), ''),
    };
    expect(normali.length, tutte.length, reason: 'una domanda si ripete');
    var peggiore = 0.0;
    var coppia = '';
    for (var i = 0; i < tutte.length; i++) {
      for (var j = i + 1; j < tutte.length; j++) {
        final s = somiglianza(tutte[i], tutte[j]);
        if (s > peggiore) {
          peggiore = s;
          coppia = '"${tutte[i]}" e "${tutte[j]}"';
        }
      }
    }
    print('FY.13 MISURA somiglianza massima fra due domande: '
        '${peggiore.toStringAsFixed(2)} ($coppia)');
    expect(peggiore, lessThan(0.5),
        reason: 'due domande dicono quasi la stessa cosa: $coppia');
  });

  test('ogni domanda e\' riconosciuta come del suo argomento', () {
    final fuori = <String>[];
    for (final t in temi) {
      for (final d in t.domande) {
        if (TemaDellOracolo.di(d) != t) fuori.add('${t.nome}: $d');
      }
    }
    print('FY.13 MISURA domande fuori dal loro argomento: ${fuori.length}');
    expect(fuori, isEmpty);
  });

  test(
      'la voce di Medora: una domanda, in prima persona, senza le regole '
      'rotte di casa', () {
    // Mai sulle intenzioni o sui sentimenti di altre persone, mai una
    // promessa d'esito, mai il trattino lungo ne' la virgola prima di "e".
    final trattini =
        '${String.fromCharCode(0x2014)}|${String.fromCharCode(0x2013)}';
    final vietate = RegExp(
        'mi ama|mi pensa|pensa di me|tornera|tornerà|vincer|otterr|'
        'sicuramente|$trattini|, e |, ed ',
        caseSensitive: false);
    final prima = RegExp(r'\b(mi|mio|mia|miei|mie|io|sono|devo|posso|trovo|'
        r'decido|ritrovo|porto|sto|ho|tengo|reggo|sciolgo|lascio|stringo|'
        r'sostengo|ascolto|nutro|curo|parlo|miglioro|affronto|onoro|rendo|'
        r'accompagno|distinguo)\b');
    for (final t in temi) {
      for (final d in t.domande) {
        expect(d.endsWith('?'), isTrue, reason: 'non e\' una domanda: $d');
        expect(vietate.hasMatch(d), isFalse, reason: 'regola rotta: $d');
        expect(prima.hasMatch(d.toLowerCase()), isTrue,
            reason: 'non e\' in prima persona: $d');
      }
    }
  });
}
