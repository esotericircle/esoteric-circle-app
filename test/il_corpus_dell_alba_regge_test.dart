// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/rituals/arcano_dell_alba/attribuzioni_degli_arcani.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/diario_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/forme_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/lettura_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/letture_dell_alba_dati.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/sacchetto_dell_alba.dart';
import 'package:esoteric_circle/core/tarot/figure_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'nucleo_del_responso.dart';

/// **IL CORPUS DELL'ARCANO DELL'ALBA REGGE, o non entra.** Ordine DT voci 07,
/// 09, 11, 13 e 24, 17 settembre 2026.
///
/// A corpus il testo e' scritto prima e non cambia: **i controlli che una
/// generazione avrebbe fatto a runtime si fanno qui, su ogni lettura di ogni
/// stato**, e un corpus che non li passa non entra nell'applicazione. Sono la
/// sola difesa rimasta contro due movimenti che dicono la stessa cosa, e sono
/// stati scritti prima del corpus e visti rossi sul corpus vuoto.
void main() {
  const corpus = lettureDellAlba;
  final stati = [
    for (var i = 0; i < SacchettoDellAlba.stati; i++) StatoDellAlba.daId(i),
  ];

  test('ogni stato ha almeno tre letture, numerate da uno senza buchi', () {
    expect(corpus.length, greaterThanOrEqualTo(SacchettoDellAlba.stati * 3),
        reason: 'il corpus ha ${corpus.length} letture');
    for (final s in stati) {
      final numeri = ResponsoDellAlba.lettureDi(s).map((l) => l.numero).toList()
        ..sort();
      expect(numeri.length, greaterThanOrEqualTo(3),
          reason: '${ResponsoDellAlba.cartaColVerso(s)}: ${numeri.length}');
      expect(numeri, List.generate(numeri.length, (i) => i + 1));
    }
  });

  test(
      'LA FAMIGLIA DECIDE LA FORMA: la parola solo alle zodiacali, e il dono '
      'la porta', () {
    expect(corpus, isNotEmpty);
    for (final l in corpus) {
      final zodiacale = l.attribuzione.famiglia == FamigliaDellArcano.zodiacale;
      final nome = ResponsoDellAlba.cartaColVerso(l.stato);
      expect(l.parola != null, zodiacale,
          reason: '$nome lettura ${l.numero}: la parola spetta alle zodiacali');
      if (l.parola != null) {
        expect(NucleoDelResponso.nomina(l.dono, l.parola!), isTrue,
            reason: '$nome: il dono non porta la parola ${l.parola}');
      }
    }
  });

  test(
      'carte diverse danno responsi diversi, e i due versi di una carta sono '
      'la stessa forma con un altro dono', () {
    expect(corpus, isNotEmpty);
    expect(corpus.map((l) => l.dono).toSet(), hasLength(corpus.length));
    expect(corpus.map((l) => l.medora).toSet(), hasLength(corpus.length));
    final stessoDono = <String>[];
    for (var c = 0; c < SacchettoDellAlba.carte; c++) {
      final dritte =
          ResponsoDellAlba.lettureDi(StatoDellAlba(c, rovescio: false));
      final rovesce =
          ResponsoDellAlba.lettureDi(StatoDellAlba(c, rovescio: true));
      for (final d in dritte) {
        for (final r in rovesce) {
          expect(d.parola == null, r.parola == null);
          expect(d.dono, isNot(r.dono));
          final comune = NucleoDelResponso.condiviso(d.dono, r.dono);
          if (comune != null) {
            stessoDono.add('${d.attribuzione.nomeDellaCarta}: il dritto '
                '${d.numero} e il rovescio ${r.numero}, $comune');
          }
        }
      }
    }
    expect(stessoDono, isEmpty, reason: stessoDono.join('\n'));
  });

  test(
      'LE LETTURE DELLO STESSO STATO SONO DAVVERO DIVERSE: nessuna coppia '
      'condivide il nucleo', () {
    expect(corpus, isNotEmpty);
    final cadute = <String>[];
    for (final s in stati) {
      final letture = ResponsoDellAlba.lettureDi(s);
      for (var i = 0; i < letture.length; i++) {
        for (var j = i + 1; j < letture.length; j++) {
          final a = letture[i], b = letture[j];
          if (a.parola != null &&
              NucleoDelResponso.nomina(a.parola!, b.parola!)) {
            cadute.add('${ResponsoDellAlba.cartaColVerso(s)} ${a.numero} e '
                '${b.numero}: la stessa parola');
          }
          final comune = NucleoDelResponso.condiviso(
              '${a.dono} ${a.medora}', '${b.dono} ${b.medora}');
          if (comune != null) {
            cadute.add('${ResponsoDellAlba.cartaColVerso(s)} ${a.numero} e '
                '${b.numero}: $comune');
          }
        }
      }
    }
    expect(cadute, isEmpty, reason: cadute.join('\n'));
  });

  test(
      'I REGISTRI POSSONO RESTARE A ZERO: parole, aperture del dono e di '
      'Medora tutte distinte, e piu aperture del primo movimento che giorni',
      () {
    expect(corpus, isNotEmpty);
    final parole = [
      for (final l in corpus)
        if (l.parola != null) DiarioDellAlba.apertura(l.parola!),
    ];
    expect(parole.toSet(), hasLength(parole.length),
        reason: 'una parola del giorno si ripete nel corpus');
    for (final (nome, di) in [
      ('dono', (LetturaDellAlba l) => l.dono),
      ('Medora', (LetturaDellAlba l) => l.medora),
    ]) {
      final viste = <String, String>{};
      for (final l in corpus) {
        final a = DiarioDellAlba.apertura(di(l));
        final prima = viste[a];
        expect(prima, isNull,
            reason: 'l\'apertura "$a" del $nome torna in '
                '${ResponsoDellAlba.cartaColVerso(l.stato)} ${l.numero} e in '
                '$prima');
        viste[a] = '${ResponsoDellAlba.cartaColVerso(l.stato)} ${l.numero}';
      }
    }
    final aperture =
        FormeDellAlba.aperture.map(DiarioDellAlba.apertura).toSet();
    expect(aperture, hasLength(FormeDellAlba.aperture.length));
    expect(aperture.length, greaterThanOrEqualTo(SacchettoDellAlba.stati));
  });

  test(
      'NESSUN MOVIMENTO FA IL COMPITO DI UN ALTRO, in ogni lettura, con ogni '
      'apertura, ogni clausola e ogni filo possibile', () {
    expect(corpus, isNotEmpty);
    // Le parti che si combinano, ciascuna con le sue radici e le sue figure,
    // calcolate una volta: le combinazioni sono milioni.
    ({Set<String> radici, Set<String> figure, String testo}) parte(String t) =>
        (
          radici: NucleoDelResponso.radici(t),
          figure: FigureDellaStesa.di(t.toLowerCase()),
          testo: t,
        );
    String? comune(
        List<({Set<String> radici, Set<String> figure, String testo})> a,
        List<({Set<String> radici, Set<String> figure, String testo})> b) {
      final fa = {for (final x in a) ...x.figure};
      final fb = {for (final x in b) ...x.figure};
      final f = fa.intersection(fb);
      if (f.isNotEmpty) return 'la figura ${f.join(', ')}';
      final ra = {for (final x in a) ...x.radici};
      final rb = {for (final x in b) ...x.radici};
      final r = ra.intersection(rb);
      return r.length >= 2 ? 'le radici ${r.join(', ')}' : null;
    }

    final cadute = <String>{};
    var combinazioni = 0;
    for (final l in corpus) {
      final nomeCarta = l.attribuzione.nomeDellaCarta;
      final nomeAttribuzione = l.attribuzione.nome;
      final chi = '${ResponsoDellAlba.cartaColVerso(l.stato)} ${l.numero}';

      // Il dono e Medora non nominano la carta ne la sua attribuzione.
      for (final (movimento, testo) in [
        ('dono', l.dono),
        ('Medora', l.medora)
      ]) {
        if (NucleoDelResponso.contieneIlNome(testo, nomeCarta) ||
            NucleoDelResponso.contieneIlNome(testo, nomeAttribuzione)) {
          cadute.add('$chi: $movimento nomina la carta o l\'attribuzione');
        }
      }

      final primi = <({Set<String> radici, Set<String> figure, String testo})>[
        for (var a = 0; a < FormeDellAlba.aperture.length; a++)
          for (var c = 0; c < 4; c++)
            parte(ResponsoDellAlba.componi(l, apertura: a, clausola: c).primo),
      ];
      final fili = <({Set<String> radici, Set<String> figure, String testo})?>[
        null,
        for (final ieri in stati)
          if (ieri.carta != l.carta &&
              ResponsoDellAlba.relazioneFra(l.stato, ieri) != null)
            for (var f = 0; f < 2; f++)
              parte(ResponsoDellAlba.componi(l,
                      apertura: 0, clausola: 0, ieri: ieri, filo: f)
                  .terzo
                  .substring(l.medora.length)
                  .trim()),
      ];
      final dono = parte(l.dono);
      final medora = parte(l.medora);

      for (final filo in fili) {
        final terzo = [medora, if (filo != null) filo];
        final c23 = comune([dono], terzo);
        if (c23 != null) cadute.add('$chi, dono e Medora: $c23');
        if (filo != null) {
          if (NucleoDelResponso.contieneIlNome(filo.testo, nomeAttribuzione) ||
              (l.parola != null &&
                  NucleoDelResponso.nomina(filo.testo, l.parola!))) {
            cadute.add('$chi, il filo "${filo.testo}" dice cio che tocca ad '
                'altri');
          }
        }
        for (final primo in primi) {
          combinazioni++;
          final c12 = comune([primo], [dono]);
          if (c12 != null) cadute.add('$chi, "${primo.testo}" e dono: $c12');
          final c13 = comune([primo], terzo);
          if (c13 != null) {
            cadute.add('$chi, "${primo.testo}" e Medora: $c13');
          }
        }
      }
      if (l.parola != null) {
        if (NucleoDelResponso.nomina(l.medora, l.parola!)) {
          cadute.add('$chi: Medora ripete la parola ${l.parola}');
        }
        for (final primo in primi) {
          if (NucleoDelResponso.nomina(primo.testo, l.parola!)) {
            cadute.add('$chi: "${primo.testo}" dice la parola ${l.parola}');
          }
        }
      }
    }
    print('sovrapposizione: $combinazioni combinazioni guardate, '
        '${cadute.length} cadute');
    for (final c in cadute) {
      print('CADUTA $c');
    }
    expect(combinazioni, greaterThan(100000));
    expect(cadute, isEmpty, reason: cadute.take(40).join('\n'));
  });

  test(
      'la lingua del corpus: niente virgola davanti alla e, niente trattino '
      'lungo, e la parola voce resta all\'audio', () {
    expect(corpus, isNotEmpty);
    final testi = [
      for (final l in corpus) ...[l.dono, l.medora],
      ...FormeDellAlba.aperture,
      for (final f in FormeDellAlba.filo.values) ...f,
    ];
    for (final t in testi) {
      expect(RegExp(r',\s+ed?\b').hasMatch(t), isFalse, reason: t);
      expect(t.contains('—'), isFalse, reason: t);
      expect(NucleoDelResponso.parole(t), isNot(contains('voce')), reason: t);
    }
  });

  test('IL FILE DEI DATI DICE CIO CHE DICE IL CORPUS, lettura per lettura', () {
    // I fine riga si normalizzano: su Windows git scrive il corpus con CRLF,
    // e le righe con un ritorno a capo in coda non somigliano a quelle dei
    // dati.
    final testo = File('docs/corpus/tarocchi.md')
        .readAsStringSync()
        .replaceAll('\r\n', '\n');
    final inizio = testo.indexOf('## Arcano dell\'Alba, le letture del dono');
    expect(inizio, isNot(-1),
        reason: 'il corpus non ha la sezione delle letture');
    final fine = testo.indexOf('\n## ', inizio + 1);
    final sezione =
        fine < 0 ? testo.substring(inizio) : testo.substring(inizio, fine);
    final dalCorpus = <String>[];
    var carta = '';
    var voce = <String, String>{};
    void chiudi() {
      if (voce.isEmpty) return;
      dalCorpus.add([
        carta,
        voce['verso'],
        voce['numero'],
        voce['parola'] ?? '',
        voce['dono'],
        voce['medora'],
      ].join(' | '));
      voce = {};
    }

    for (final riga in sezione.split('\n')) {
      final c = RegExp(r'^### (?:0|[IVXL]+) (.+?), [^,]+, '
              r'(respiro|azione|parola)$')
          .firstMatch(riga);
      if (c != null) {
        chiudi();
        carta = c.group(1)!;
        continue;
      }
      final l = RegExp(r'^- \*\*(dritto|rovesciato), lettura (\d+)\*\*$')
          .firstMatch(riga);
      if (l != null) {
        chiudi();
        voce = {'verso': l.group(1)!, 'numero': l.group(2)!};
        continue;
      }
      final campo =
          RegExp(r'^  - (parola|dono|medora): (.+)$').firstMatch(riga);
      if (campo != null) voce[campo.group(1)!] = campo.group(2)!.trim();
    }
    chiudi();
    final dalCodice = [
      for (final l in corpus)
        [
          l.attribuzione.nomeDellaCarta,
          l.rovescio ? 'rovesciato' : 'dritto',
          '${l.numero}',
          l.parola ?? '',
          l.dono,
          l.medora,
        ].join(' | '),
    ];
    expect(dalCodice, dalCorpus,
        reason: 'rigenerare con python tool/genera_letture_dell_alba.py');
  });

  group('il rilevatore del nucleo vede cio che deve vedere', () {
    test('la stessa figura detta con due parole', () {
      expect(
          NucleoDelResponso.condiviso(
              'Sciogli il nodo che ti stringe.', 'Ogni legame si scioglie.'),
          isNotNull);
    });
    test('due radici di contenuto in comune', () {
      expect(
          NucleoDelResponso.condiviso(
              'Scrivi una lettera di gratitudine a chi ti ha aiutato.',
              'La gratitudine scritta aiuta chi la riceve.'),
          isNotNull);
    });
    test('un caso costruito apposta: il dono e Medora dicono la stessa cosa',
        () {
      const doppia = LetturaDellAlba(
        carta: 1,
        rovescio: false,
        numero: 1,
        dono: 'Manda un messaggio sincero a una persona lontana.',
        medora: 'Un messaggio sincero accorcia ogni distanza da una persona.',
      );
      expect(NucleoDelResponso.condiviso(doppia.dono, doppia.medora), isNotNull,
          reason: 'se questo passa, la prova della sovrapposizione non vede');
    });
    test('e non vede cio che non c\'e', () {
      expect(
          NucleoDelResponso.condiviso(
              'Tieni il passo leggero.', 'Le intenzioni diventano reali.'),
          isNull);
    });
  });

  test('NESSUN TESTO DELL\'ALBA NOMINA UN\'ORA CHE PUO\' ESSERE FALSA', () {
    // **Il fatto, visto a video il 17 settembre 2026** sulla 2266: la carta
    // girata alle 18:01 diceva *"Stamani hai rivelato l'Imperatrice"*. La
    // carta si gira a qualunque ora dopo le sette, quindi un testo che
    // nomina il mattino, il risveglio o la sera mente a chi la gira dopo.
    // **Una lettura puo' invitare a un momento che verra'** (*"al risveglio
    // di domani"*), non dire che quel momento e' adesso.
    final dellOra = RegExp(
        r'stamattin|stamani|mattin|risvegli|\bsera\b|\balba\b|'
        r'giornata si apre|apre la (tua )?giornata|giorno comincia',
        caseSensitive: false);
    final aperture = [
      for (final a in FormeDellAlba.aperture)
        if (dellOra.hasMatch(a)) a,
    ];
    final dellaLettura = RegExp(
        r'stamattin|stamani|questa mattina|del mattino|della mattina|'
        r'al mattino|risveglio(?! di domani)',
        caseSensitive: false);
    final letture = [
      for (final l in corpus)
        for (final t in [l.dono, l.medora])
          if (dellaLettura.hasMatch(t)) '${l.carta} ${l.numero}: $t',
    ];
    print('ORDINE DT: aperture guardate ${FormeDellAlba.aperture.length}, '
        'con l\'ora ${aperture.length}; letture guardate ${corpus.length}, '
        'con l\'ora ${letture.length}');
    cardinaleMinimo(FormeDellAlba.aperture.length, 44,
        cosa: 'aperture dell\'Alba',
        perche: 'Su un elenco vuoto nessuna apertura nominerebbe l\'ora.');
    expect(aperture, isEmpty,
        reason: 'queste aperture nominano un\'ora: $aperture');
    expect(letture, isEmpty,
        reason: 'queste letture nominano il mattino come se fosse adesso:\n'
            '${letture.join('\n')}');
  });
}
