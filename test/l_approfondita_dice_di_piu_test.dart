// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'dart:io';

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/il_cielo_del_segno.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'package:esoteric_circle/core/astro/il_segno_del_cielo.dart';

/// **BREVE E APPROFONDITA, SENZA MEDIA; E L'APPROFONDITA DICE DI PIU' ANCHE
/// SENZA CARTA.** Ordine ES voce 01, 29 settembre 2026.
///
/// Il fatto dell'Architetto: senza carta natale l'Approfondita era identica
/// alla Breve, 48 schede su 48 (dodici segni per quattro domini). Qui si
/// contano le schede identiche, e si pretende che ogni frase aggiunta dica
/// dove sta davvero il corpo, rifatta col motore delle effemeridi.
void main() {
  test('senza carta natale, 48 schede Approfondite diverse dalla Breve', () {
    const giorno = 272; // 29 settembre 2026
    const anno = 2026;
    final mezzogiorno =
        DateTime.utc(anno).add(const Duration(days: giorno, hours: 12));
    var identiche = 0;
    var contate = 0;
    final righe = <String>[];
    for (final segno in Zodiac.values) {
      final brevi = Horoscope.forSign(
          sign: segno, dayOfYear: giorno, year: anno, opening: null);
      final profonde = Horoscope.forSign(
          sign: segno,
          dayOfYear: giorno,
          year: anno,
          opening: null,
          profonde: {for (final d in HoroscopeDomain.values) d: true});
      for (var i = 0; i < brevi.length; i++) {
        contate++;
        final b = brevi[i].text;
        final p = profonde[i].text;
        if (b == p) identiche++;
        final dominio = brevi[i].domain;
        // La frase aggiunta: la Luna, poi il corpo del dominio, coi segni
        // veri di oggi.
        final aggiunta = p.substring(b.length).trim();
        final luna = IlSegnoDelCielo.delCorpo(CorpoCeleste.luna, mezzogiorno);
        final corpo = IlCieloDelSegno.corpoDi[dominio]!;
        final l =
            IlCieloDiMeeus.longitudine(corpo, Celestial.julianDay(mezzogiorno));
        final suo = Zodiac.values[(l ~/ 30) % 12];
        expect(p.startsWith(b), isTrue,
            reason: '${segno.id} ${dominio.name}: l\'Approfondita non '
                'contiene la Breve');
        // LAPIDE, ordine EU voce 01, 1 ottobre 2026: qui si pretendeva che
        // la Lunga aggiungesse la Luna e il corpo del dominio coi loro segni,
        // cioe' il cielo dentro il testo. Il fondatore: *"per lunga
        // aggiungere altri 2 paragrafi mai di transiti o tecnicismi"*. Adesso
        // la Lunga aggiunge i due paragrafi lunghi della voce, e il cielo
        // resta in "Da dove viene".
        expect(aggiunta.split('\n\n').length, 2,
            reason: '${segno.id} ${dominio.name}: la Lunga non aggiunge due '
                'paragrafi: $aggiunta');
        expect(aggiunta, isNot(contains('la Luna è in ${luna.italianName}')));
        expect(aggiunta, isNot(contains('è in ${suo.italianName}')));
        if (segno == Zodiac.aries) righe.add('${dominio.name}: $aggiunta');
      }
    }
    cardinaleMinimo(contate, 48, cosa: 'schede senza carta');
    final sintesi = 'ORDINE ES VOCE 01: schede Approfondite identiche alla '
        'Breve senza carta natale, $identiche su $contate';
    print(sintesi);
    for (final r in righe) {
      print('  Ariete, $r');
    }
    if (Platform.environment['SCRIVI_LA_PROVA'] == '1') {
      File('docs/collaudo/ES/profondita.txt')
        ..createSync(recursive: true)
        ..writeAsStringSync('$sintesi\n\nAriete, 29 settembre 2026, le frasi '
            'che l\'Approfondita aggiunge:\n${righe.join('\n')}\n');
    }
    expect(identiche, 0);
  });

  test('le profondita\' sono due, e nessuna si chiama Media o Profonda', () {
    final nomi = AnswerDepth.values.map((d) => d.label).toList();
    // **"LUNGA", dal 30 settembre 2026.** Il fondatore: *"Nel selettore
    // profondità cambiamo "Approfondita" in Lunga"*. Prima questa prova
    // pretendeva "Approfondita" (ordine ES voce 01): il nome a video e'
    // cambiato, le voci restano due.
    expect(nomi, ['Breve', 'Lunga']);
    final righeDeiPiani = [
      for (final p in PlanCatalog.plans) ...p.highlights,
      for (final r in PlanCatalog.matrix) ...[r.label, ...r.values],
      // LAPIDE, ordine EU, sera del 1 ottobre 2026: la pagina dei piani non
      // dice piu' "profondita' dell'oroscopo: Breve o Lunga" ma, con le
      // parole di chi legge, "L'oroscopo completo". Le righe si cercano con
      // tutte e due le parole.
    ]
        .where((r) =>
            r.contains('profondità') ||
            r.toLowerCase().contains('oroscopo completo'))
        .toList();
    cardinaleMinimo(righeDeiPiani.length, 1,
        cosa: 'righe dei piani sulla profondita\'');
    final vecchie = righeDeiPiani
        .where((r) => r.contains('Media') || r.contains('Profonda'))
        .toList();
    print('ORDINE ES VOCE 01: voci "Media" e "Profonda" nella pagina dei '
        'piani ${vecchie.length}; ${righeDeiPiani.join(' | ')}');
    expect(vecchie, isEmpty);
  });
}
