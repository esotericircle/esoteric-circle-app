import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/lunario/i_giorni_tuoi.dart';
import 'package:esoteric_circle/core/lunario/il_segno_del_giorno_tuo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I GIORNI TUOI.** Ordine FV voce FV.07, 15 ottobre 2026.
///
/// `IGiorniTuoi.delMese` calcola i quattro segni che solo la persona vede,
/// dalla sola astronomia (`IlCieloDiMeeus`), senza modello e senza rete
/// (regola R2). Questa prova pretende che:
///
/// 1. con una nascita vera e l'ora nota, nel corso di un anno ogni tipo
///    compaia un numero di volte coerente col suo periodo astronomico (il
///    cardinale minimo, non un giorno esatto: il giorno esatto lo misura
///    l'effemeride, non questa prova);
/// 2. senza l'ora di nascita, [TipoDelGiornoTuo.ritornoLunare] e
///    [TipoDelGiornoTuo.faseDiNascita] (che dipendono dall'ora) non
///    compaiono mai, mentre [TipoDelGiornoTuo.lunaSulTuoSole] e
///    [TipoDelGiornoTuo.lunaNelTuoSegno] (che non dipendono dall'ora)
///    continuano a comparire;
/// 3. nessun testo porta parole di fertilita' o di concepimento (la PRIMA
///    VIA, LA SIMBOLICA del 4 settembre 2026).
void main() {
  final nascitaConOra = BirthIdentity.fromParts(
    birthDate: DateTime(1990, 6, 15),
    birthHour: 14,
    birthMinute: 30,
  );
  final nascitaSenzaOra = BirthIdentity.fromParts(
    birthDate: DateTime(1990, 6, 15),
  );

  /// Tutti i segni tuoi dei dodici mesi di [anno], per [nascita].
  List<SegnoDelGiornoTuo> unAnno(BirthIdentity nascita, int anno) => [
        for (var mese = 1; mese <= 12; mese++)
          ...IGiorniTuoi.delMese(nascita, anno, mese),
      ];

  group('con l\'ora di nascita nota', () {
    final anno = unAnno(nascitaConOra, 2026);

    test('il ritorno della Luna compare circa una volta per mese siderale', () {
      final quanti =
          anno.where((s) => s.tipo == TipoDelGiornoTuo.ritornoLunare).length;
      cardinaleMinimo(quanti, 10,
          cosa: 'ritorni della Luna nel 2026',
          perche: 'la Luna torna al suo grado ogni 27,3 giorni, circa 13 '
              'volte l\'anno');
      expect(quanti, inInclusiveRange(10, 15));
    });

    test('la Luna sul Sole compare circa una volta per mese siderale', () {
      final quanti =
          anno.where((s) => s.tipo == TipoDelGiornoTuo.lunaSulTuoSole).length;
      cardinaleMinimo(quanti, 10,
          cosa: 'passaggi della Luna sul Sole nel 2026');
      expect(quanti, inInclusiveRange(10, 15));
    });

    test(
        'la Luna nel segno solare compare per circa due o tre giorni, '
        'una volta per mese siderale (la Luna resta nel segno piu\' a '
        'lungo di quanto duri l\'attraversamento di un grado solo)', () {
      final quanti =
          anno.where((s) => s.tipo == TipoDelGiornoTuo.lunaNelTuoSegno).length;
      cardinaleMinimo(quanti, 20,
          cosa: 'giorni di transito nel segno solare nel 2026',
          perche: 'la Luna attraversa un segno in circa 2,3 giorni, e lo '
              'fa circa tredici volte l\'anno: 20-35 giorni in tutto');
      expect(quanti, inInclusiveRange(20, 35));
    });

    test(
        'il ritorno della fase di nascita compare circa una volta al mese '
        'sinodico', () {
      final quanti =
          anno.where((s) => s.tipo == TipoDelGiornoTuo.faseDiNascita).length;
      cardinaleMinimo(quanti, 10,
          cosa: 'ritorni della fase di nascita nel 2026');
      expect(quanti, inInclusiveRange(10, 15));
    });

    test('ogni segno tuo porta un titolo e un testo non vuoti', () {
      cardinaleMinimo(anno.length, 40, cosa: 'segni tuoi del 2026');
      for (final s in anno) {
        expect(s.titolo, isNotEmpty, reason: '${s.tipo}: titolo vuoto');
        expect(s.testo, isNotEmpty, reason: '${s.tipo}: testo vuoto');
      }
    });
  });

  group('senza l\'ora di nascita', () {
    final anno = unAnno(nascitaSenzaOra, 2026);

    test('il ritorno della Luna e la fase di nascita non compaiono mai', () {
      final dipendentiDallOra = anno
          .where((s) =>
              s.tipo == TipoDelGiornoTuo.ritornoLunare ||
              s.tipo == TipoDelGiornoTuo.faseDiNascita)
          .toList();
      expect(dipendentiDallOra, isEmpty,
          reason: 'senza l\'ora di nascita questi due tipi devono tacere: '
              '${dipendentiDallOra.map((s) => s.tipo).toList()}');
    });

    test('la Luna sul Sole e nel segno continuano a comparire', () {
      final indipendentiDallOra = anno
          .where((s) =>
              s.tipo == TipoDelGiornoTuo.lunaSulTuoSole ||
              s.tipo == TipoDelGiornoTuo.lunaNelTuoSegno)
          .length;
      cardinaleMinimo(indipendentiDallOra, 20,
          cosa: 'segni tuoi senza l\'ora nel 2026');
    });
  });

  test('nessun testo porta parole di fertilita\' o concepimento', () {
    final vietate = RegExp(
        r'(?<![A-Za-zÀ-ÿ])(fertil\w*|fecond\w*|steril\w*|gravid\w*|incint\w*|'
        r'concepi\w*)(?![A-Za-zÀ-ÿ])',
        caseSensitive: false);
    final anno = unAnno(nascitaConOra, 2026);
    cardinaleMinimo(anno.length, 40,
        cosa: 'segni tuoi guardati per la politica');
    final trovate = <String>[];
    for (final s in anno) {
      final m = vietate.firstMatch('${s.titolo} ${s.testo}');
      if (m != null) trovate.add('${s.tipo}: "${m.group(0)}"');
    }
    expect(trovate, isEmpty,
        reason: 'parole vietate dalla PRIMA VIA, LA '
            'SIMBOLICA: $trovate');
  });

  test('senza una nascita vera (dato d\'esempio) non compare nessun segno', () {
    expect(IGiorniTuoi.delMese(BirthIdentity.example, 2026, 6), isEmpty);
  });
}
