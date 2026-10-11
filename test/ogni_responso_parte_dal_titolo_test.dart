// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/responsi/il_titolo_del_responso.dart';
import 'package:esoteric_circle/core/ricordi/arti_con_responso.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// OGNI RESPONSO PARTE DAL TITOLO. Ordine FK, aggiunta voce A1, 11 ottobre
/// 2026.
///
/// Il fondatore: *"ti avevo anche indicato che ogni risposta doveva partire
/// da un titolo."* La regola era applicata una funzione per volta, otto arti
/// su dodici ognuna col suo `Text` mentre quattro non lo avevano. Adesso il titolo di ogni
/// responso si disegna con `TitoloDelResponso`, direttamente o da una delle
/// porte dichiarate in `IlTitoloDelResponso.porte`: questa guardia
/// **enumera le arti che producono un responso e cade col nome di quella che
/// non passa da li'**.
///
/// La si e' vista rossa (Regola A) togliendo il titolo comune da un'arte, da
/// una porta e una parola del fondatore dal documento:
/// `docs/collaudo/FK/fk_aggiunta_regola_a.txt`.

/// Il sorgente senza le righe di commento: un nome citato in un commento non
/// e' un titolo disegnato.
String _codice(String percorso) => File(percorso)
    .readAsLinesSync()
    .where((r) => !r.trimLeft().startsWith('//'))
    .join('\n');

/// Gli spazi contano come uno, e il segno di citazione a inizio riga del
/// Markdown non e' una parola del fondatore.
String _normale(String s) => s
    .replaceAll(RegExp(r'\n>\s?'), ' ')
    .replaceAll(RegExp(r'\s+'), ' ')
    .replaceAll('\u2019', "'")
    .trim();

void main() {
  const widget = '${IlTitoloDelResponso.widget}(';

  test('A1: ogni arte con un responso disegna il titolo dal punto comune', () {
    const arti = ArtiConResponso.tutte;
    cardinaleMinimo(arti.length, 12,
        cosa: 'arti con un responso',
        perche: 'Le arti sono dodici dall\'ordine DW voce 02.');
    final fuori = <String>[];
    for (final a in arti) {
      final file = File(a.doveViveIlResponso);
      expect(file.existsSync(), isTrue,
          reason: '${a.arte}: ${a.doveViveIlResponso} non esiste');
      final codice = _codice(a.doveViveIlResponso);
      final passa = codice.contains(widget) ||
          IlTitoloDelResponso.porte.keys.any((p) => codice.contains('$p('));
      if (!passa) fuori.add('${a.arte} (${a.doveViveIlResponso})');
    }
    print('ORDINE FK VOCE A1: arti con responso ${arti.length}, '
        'senza il titolo comune ${fuori.length}');
    expect(fuori, isEmpty,
        reason: 'queste arti non partono dal titolo comune: '
            '${fuori.join(', ')}. Il titolo di un responso si disegna con '
            '${IlTitoloDelResponso.widget}, oppure con una porta di '
            'IlTitoloDelResponso.porte');
  });

  test('A1: ogni porta disegna davvero il titolo comune', () {
    cardinaleMinimo(IlTitoloDelResponso.porte.length, 2, cosa: 'porte');
    for (final e in IlTitoloDelResponso.porte.entries) {
      expect(_codice(e.value), contains(widget),
          reason: 'la porta ${e.key} (${e.value}) non disegna il titolo con '
              '${IlTitoloDelResponso.widget}: le arti che passano da lei non '
              'partono piu\' dal titolo comune');
    }
  });

  test('A6: il documento porta le parole del fondatore, uguali', () {
    final doc = File('docs/responsi/il_titolo_e_il_formato.md');
    expect(doc.existsSync(), isTrue);
    final testo = _normale(doc.readAsStringSync());
    cardinaleMinimo(IlTitoloDelResponso.paroleDelFondatore.length, 3,
        cosa: 'frasi del fondatore');
    for (final e in IlTitoloDelResponso.paroleDelFondatore.entries) {
      expect(testo, contains(_normale(e.value)),
          reason: 'il documento non porta le parole del ${e.key}');
    }
  });
}
