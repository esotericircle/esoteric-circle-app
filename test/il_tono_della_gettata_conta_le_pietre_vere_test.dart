// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/domande/domande_del_cerchio.dart';
import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL TONO DELLA GETTATA CONTA LE PIETRE VERE.** Ordine GA voce GA.06, la
/// cura delle Rune di Caligo, 21 ottobre 2026.
///
/// I lettori ciechi (docs/collaudo/GA/lettori_ciechi/esiti/
/// esito_tre_domande_rune.md, sul commit 1804c7d7): *"Il tono della gettata
/// non viene dalle pietre uscite"*: "La gettata intera parla di
/// maturazione" con la sola Eihwaz, "La gettata è tutta dritta" detto di una
/// pietra sola, "Il segno sta tutto dalla parte della giustizia" senza
/// Tiwaz, "le pietre rovesciate" con una sola pietra in ombra. Il difetto e'
/// di sistema: una frase scritta per una famiglia di rune o per un tono
/// d'insieme finisce sotto gettate in cui non e' vera.
///
/// La guardia compone presagi veri dal corpus vero, nelle quattro gettate,
/// Breve e Lunga, con domande di ogni tipo, e legge ogni testo che la
/// persona vede (il paragrafo, il riquadro, l'approfondimento, i titoli e i
/// paragrafi delle schede). Cade quando un testo:
/// - nomina una runa che non e' uscita;
/// - dice "tutta dritta", "tutte dritte" con una pietra in ombra;
/// - dice "le pietre rovesciate", "quelle in ombra", "qualche pietra
///   capovolta" (un plurale d'ombra) con meno di due pietre in ombra;
/// - dice "una sola pietra in ombra", "la pietra in ombra" con un numero
///   di pietre in ombra diverso da uno;
/// - conta le pietre ("le tre pietre", "due pietre su cinque") con un numero
///   che non e' quello della gettata;
/// - parla di "pietre" al plurale quando la pietra e' una sola (salvo il
///   plurale dell'oracolo in generale, "le pietre non predicono", vedi
///   `pluraleDellOracolo`).
void main() {
  const rune = [
    'Fehu', 'Uruz', 'Thurisaz', 'Ansuz', 'Raidho', 'Kenaz', 'Gebo', 'Wunjo',
    'Hagalaz', 'Nauthiz', 'Isa', 'Jera', 'Eihwaz', 'Perthro', 'Algiz', //
    'Sowilo', 'Tiwaz', 'Berkano', 'Ehwaz', 'Mannaz', 'Laguz', 'Ingwaz',
    'Dagaz', 'Othala',
  ];
  const numeri = {
    'una': 1, 'due': 2, 'tre': 3, 'quattro': 4, 'cinque': 5, 'sei': 6, //
    'sette': 7,
  };
  final b = RegExp(r'(?<![a-zà-ÿ])');
  final e = RegExp(r'(?![a-zà-ÿ])');
  RegExp parola(String s) =>
      RegExp('${b.pattern}(?:$s)${e.pattern}', caseSensitive: false);

  // "La croce non è tutta in luce" dice il vero: la negazione non conta.
  final tuttaDritta = parola(r'(?<!non è )(?<!non sono )(tutta dritta|'
      r'tutte dritte|tutta in luce|tutte in luce|nessuna pietra è in ombra|'
      r'stanno tutte dritte)');
  final pluraleDOmbra = parola(
      r'(le|delle|alcune|altre) pietre (in ombra|rovesciate|capovolte|'
      r'sfumate|velate|scure)|qualche pietra (in ombra|rovesciata|capovolta|'
      r'velata)|quelle (in ombra|rovesciate|capovolte|sfumate|velate)|'
      r'(le|delle) posizioni rovesciate|le pietre velate|pietre lievi in ombra|'
      r'le zone in ombra|le porte segnate dall.ombra');
  // "Se una pietra in ombra cade vicino al cuore" e' un'ipotesi, non un
  // conto: conta solo l'articolo determinativo o "una sola".
  final unaDOmbra = parola(r'una sola pietra (su \w+ )?è in ombra|'
      r'la pietra in ombra|la pietra rovesciata');
  final contate = RegExp(
      '${b.pattern}(le |delle |tutte e )?(due|tre|quattro|cinque|sei|sette) '
      r'pietre( su (due|tre|cinque|sette))?( (sono )?(in ombra|in luce|'
      r'dritte|rovesciate))?',
      caseSensitive: false);
  final plurale = parola(r'pietre');
  // **IL PLURALE DELL'ORACOLO NON E' UN CONTO**, ordine GA voce GA.06,
  // secondo giro: le risposte dirette dicono "Le pietre non predicono
  // l'esito", "Ciò che prova un'altra persona non entra nelle pietre",
  // "torna alle pietre con una domanda precisa". E' l'oracolo delle rune in
  // generale, vero anche sotto una pietra sola; il difetto da prendere resta
  // "le pietre" che descrivono questa gettata ("le pietre uscite dicono").
  // Qui si tolgono dal testo solo gli usi generali, prima di cercare il
  // plurale.
  final pluraleDellOracolo = parola(r'le pietre non|(alle|nelle|dalle) pietre|'
      r'pietre non');

  /// Le colpe di un testo letto sotto una gettata di [n] pietre con [k] in
  /// ombra; [uscite] le rune uscite (null: non si guardano i nomi).
  List<String> colpe(String testo, int n, int k, Set<String>? uscite) {
    final fuori = <String>[];
    for (final r in rune) {
      if (uscite != null &&
          !uscite.contains(r) &&
          RegExp('\\b$r\\b').hasMatch(testo)) {
        fuori.add('nomina $r, che non e\' uscita');
      }
    }
    if (k > 0 && tuttaDritta.hasMatch(testo)) {
      fuori.add('«${tuttaDritta.firstMatch(testo)![0]}» con $k pietre in '
          'ombra');
    }
    if (k < 2 && pluraleDOmbra.hasMatch(testo)) {
      fuori.add('«${pluraleDOmbra.firstMatch(testo)![0]}» con $k pietre in '
          'ombra');
    }
    if (k != 1 && unaDOmbra.hasMatch(testo)) {
      fuori.add('«${unaDOmbra.firstMatch(testo)![0]}» con $k pietre in '
          'ombra');
    }
    for (final m in contate.allMatches(testo)) {
      final x = numeri[m[2]!.toLowerCase()]!;
      final su = m[4] == null ? null : numeri[m[4]!.toLowerCase()];
      final verso = m[7];
      final giusto = su != null
          ? su == n && (verso == null || verso == 'in ombra' ? x == k : true)
          : switch (verso) {
              'in ombra' || 'rovesciate' => x == k,
              'in luce' || 'dritte' => x == n - k,
              _ => x == n,
            };
      if (!giusto) fuori.add('«${m[0]}» con $n pietre, $k in ombra');
    }
    if (n == 1 && plurale.hasMatch(testo.replaceAll(pluraleDellOracolo, ' '))) {
      fuori.add('«pietre» al plurale con una pietra sola');
    }
    return fuori;
  }

  List<String> colpeDi(String testo, EsitoGettata esito) => colpe(
      testo,
      esito.rune.length,
      esito.rune.where((p) => p.inOmbra).length,
      {for (final p in esito.rune) p.rune.name});

  /// Quante pietre ha ogni gettata e quante possono essere in ombra in ogni
  /// tono (IlPresagioDalCorpus.tono: luce nessuna, ombra piu' della meta').
  (int, List<int>) possibili(String gettata, String tono) {
    final n =
        switch (gettata) { 'odino' => 1, 'norne' => 3, 'croce' => 5, _ => 7 };
    final ks = [
      for (var k = 0; k <= n; k++)
        if (switch (tono) {
          'luce' => k == 0,
          'ombra' => k * 2 > n,
          _ => k > 0 && k * 2 <= n,
        })
          k
    ];
    return (n, ks);
  }

  test(
      'OGNI VOCE DEL LEGAME E\' VERA SOTTO OGNI GETTATA DEL SUO GRUPPO: '
      'nessun numero o verso che il gruppo non garantisce', () {
    final sbagliate = <String>[];
    var voci = 0;
    for (final MapEntry(key: gruppo, value: elenco)
        in corpusDelPresagio.voci['legame']!.entries) {
      final (n, ks) = possibili(gruppo.split('/')[0], gruppo.split('/')[1]);
      for (var i = 0; i < elenco.length; i++) {
        if (elenco[i].trim().isEmpty) continue;
        voci++;
        for (final k in ks) {
          final c = colpe(elenco[i], n, k, null);
          if (c.isNotEmpty) {
            sbagliate.add('legame/$gruppo/${i + 1}, con $k in ombra: '
                '${c.first}\n    «${elenco[i]}»');
            break;
          }
        }
      }
    }
    print('ORDINE GA VOCE GA.06, RUNE: voci del LEGAME lette $voci, che '
        'dicono un numero o un verso non garantito ${sbagliate.length}');
    cardinaleMinimo(voci, 500, cosa: 'voci del LEGAME');
    expect(sbagliate, isEmpty, reason: sbagliate.join('\n'));
  });

  final domande = <String>[
    '',
    for (final d in DomandeDelCerchio.generichePerLaGettata) d.testo,
    'Devo accettare l’offerta della nuova azienda?',
    'Come posso fare pace con mia sorella?',
    'Passerò l’esame di stato a dicembre?',
    'Andrà tutto bene?',
    'Cosa prova davvero Marco per me?',
    'Devo trasferirmi a Milano o restare a Bari?',
    'Quando finirà questo periodo di stallo?',
    'Lui mi ama ancora e troverò lavoro entro Natale?',
    'L’operazione al ginocchio del mese prossimo andrà bene?',
  ];

  test('il tono, i numeri e i nomi delle rune dicono la gettata vera', () {
    final colpe = <String>[];
    var composti = 0;
    var testi = 0;
    for (final g in gettate) {
      for (var seme = 0; seme < 60; seme++) {
        final esito = RuneCast.getta(g, random: Random(7000 + seme));
        for (final d in domande) {
          final p = IlPresagioDalCorpus.componi(
            corpus: corpusDelPresagio,
            esito: esito,
            domanda: d,
            persona: 'tono-$seme',
            oggi: DateTime(2026, 10, 21),
            memoria: LaMemoriaDelPresagio(),
            lunga: true,
          );
          composti++;
          final r = p.principale;
          final daLeggere = <String, String>{
            'il paragrafo': r.risposta,
            'il riquadro': r.cosaFare,
            'l\'approfondimento': r.approfondimento ?? '',
            for (var i = 0; i < p.schede.length; i++) ...{
              'il titolo della scheda $i': p.schede[i].titolo,
              'la scheda $i': p.schede[i].risposta,
              'il riquadro della scheda $i': p.schede[i].cosaFare,
            },
          };
          for (final MapEntry(key: dove, value: testo) in daLeggere.entries) {
            testi++;
            for (final c in colpeDi(testo, esito)) {
              colpe.add('${g.id}, seme $seme, «$d», $dove: $c\n    «$testo»');
            }
          }
        }
      }
    }
    final uniche = colpe.toSet().toList();
    print('ORDINE GA VOCE GA.06, RUNE: presagi composti $composti, testi '
        'letti $testi, testi che dicono una gettata che non c\'e\' '
        '${uniche.length}');
    cardinaleMinimo(composti, 4 * 60 * 15,
        cosa: 'presagi composti',
        perche: 'quattro gettate, sessanta semi, quindici domande');
    expect(uniche, isEmpty, reason: uniche.take(25).join('\n'));
  }, timeout: const Timeout(Duration(minutes: 10)));
}
