// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL CORPUS DELLE RUNE DELL'ARCHITETTO. Ordine EX voce 03, EX Aggiunta 2.**
///
/// Le prove della specifica (`docs/corpus/rune/SPECIFICA.md`, sezione 7) sul
/// corpus vero: la forma, la quantita', le ripetizioni a sessanta giorni, la
/// parola per parola. Le chiamate al modello per gettata, zero, le prova
/// `il_presagio_passa_dal_modello_test.dart` sulla schermata.
///
/// Code non scrive ne' corregge nessuna voce: una voce che non passa si
/// riporta col file, il gruppo e il numero, e la corregge l'Architetto.
void main() {
  const rune = [
    'Fehu',
    'Uruz',
    'Thurisaz',
    'Ansuz',
    'Raidho',
    'Kenaz',
    'Gebo',
    'Wunjo',
    'Hagalaz',
    'Nauthiz',
    'Isa',
    'Jera',
    'Eihwaz',
    'Perthro',
    'Algiz',
    'Sowilo',
    'Tiwaz',
    'Berkano',
    'Ehwaz',
    'Mannaz',
    'Laguz',
    'Ingwaz',
    'Dagaz',
    'Othala',
  ];

  /// Per campo: gli spazi permessi, la lunghezza minima e massima (a spazi
  /// riempiti con valori medi), e se la voce nomina la sua runa.
  const regole = <String, (Set<String>, int, int, bool)>{
    CampiDelPresagio.risposta: ({'cosa'}, 60, 160, false),
    CampiDelPresagio.verdetto: ({'cosa'}, 60, 160, false),
    // **SOLO {glossa}, MAI {posizione}**: la scelta dell'Architetto (EX
    // Aggiunta 2), perche' "Al centro" o "Skuld" non entrano in una frase.
    CampiDelPresagio.pietra: ({'cosa', 'glossa'}, 80, 240, true),
    CampiDelPresagio.legame: ({'gettata'}, 60, 200, false),
    CampiDelPresagio.gesto: ({'cosa'}, 40, 140, false),
  };
  const riempi = {
    'cosa': 'il lavoro',
    'glossa': 'ciò che diviene',
    'gettata': 'le tre norne',
  };
  const vietate = [
    'guarigion',
    'guarir',
    'salute',
    'malatt',
    'fertilit',
    'longevit',
    'vittori',
    'ricchezz',
    'tesor',
    'armi',
  ];
  const astri = ['pianet', 'zodiac', 'oroscop', 'astral', 'costellazion'];

  Map<String, Map<String, int>> leVociCheServono() {
    final out = <String, Map<String, int>>{};
    String? campo;
    for (final r
        in File('docs/corpus/rune/le_voci_che_servono.txt').readAsLinesSync()) {
      final testa = RegExp(r'^([A-Z]+): \d+ gruppi').firstMatch(r);
      if (testa != null) {
        campo = testa.group(1)!.toLowerCase();
        out[campo] = {};
        continue;
      }
      final v = RegExp(r'^  (\S+) / (\S+): (\d+)$').firstMatch(r);
      if (v != null && campo != null) {
        out[campo]!['${v.group(1)}/${v.group(2)}'] = int.parse(v.group(3)!);
      }
    }
    return out;
  }

  test('il corpus e\' completo', () {
    expect(corpusDelPresagio.completo, isTrue);
    cardinaleMinimo(corpusDelPresagio.quante, 4929,
        cosa: 'voci del corpus delle rune');
    print('ORDINE EX VOCE 03: voci del corpus ${corpusDelPresagio.quante}');
  });

  test('1. LA FORMA: gruppi, spazi, lunghezze, parole, nomi di runa', () {
    final difetti = <String>[];
    var guardate = 0;
    for (final campo in CampiDelPresagio.tutti) {
      final (spazi, minimo, massimo, nomina) = regole[campo]!;
      final gruppi = corpusDelPresagio.voci[campo]!;
      expect(gruppi.keys.toSet(), IlPresagioDalCorpus.gruppiDi(campo).toSet(),
          reason: campo);
      for (final MapEntry(key: gruppo, value: voci) in gruppi.entries) {
        for (var i = 0; i < voci.length; i++) {
          final voce = voci[i];
          if (voce.trim().isEmpty) continue;
          guardate++;
          final dove = '$campo.md, $gruppo, voce ${i + 1}';
          final usati = RegExp(r'\{([a-z]+)\}')
              .allMatches(voce)
              .map((m) => m.group(1)!)
              .toSet();
          if (usati.difference(spazi).isNotEmpty) {
            difetti.add('$dove: spazio non permesso '
                '${usati.difference(spazi)}');
          }
          final piena = voce.replaceAllMapped(
              RegExp(r'\{([a-z]+)\}'), (m) => riempi[m.group(1)] ?? '');
          if (piena.length < minimo || piena.length > massimo) {
            difetti.add('$dove: lunghezza ${piena.length} fuori da '
                '$minimo-$massimo');
          }
          if (voce.contains('—') || voce.contains('–')) {
            difetti.add('$dove: trattino lungo');
          }
          if (RegExp(r',\s+e\s').hasMatch(voce)) {
            difetti.add('$dove: virgola prima della "e"');
          }
          final basso = voce.toLowerCase();
          for (final p in vietate) {
            if (RegExp('\\b$p').hasMatch(basso)) {
              difetti.add('$dove: parola vietata "$p"');
            }
          }
          for (final p in astri) {
            if (basso.contains(p)) difetti.add('$dove: astro "$p"');
          }
          if (voce.contains('[') || voce.contains(']')) {
            difetti.add('$dove: marca del genere o parentesi quadra');
          }
          final nominate = [
            for (final r in rune)
              if (RegExp('\\b$r\\b').hasMatch(voce)) r
          ];
          final sua = gruppo.split('/').first;
          if (!nomina && nominate.isNotEmpty) {
            difetti.add('$dove: nomina la runa $nominate');
          }
          if (nomina && !nominate.contains(sua)) {
            difetti.add('$dove: non nomina la sua runa $sua');
          }
          if (nomina && nominate.any((r) => r != sua)) {
            difetti.add('$dove: nomina un\'altra runa $nominate');
          }
          if (RegExp(r"\b(e|perche|poiche|cosi|gia|piu|puo|cio|pero|sara)'")
              .hasMatch(basso)) {
            difetti.add('$dove: apostrofo al posto dell\'accento');
          }
          if (basso.contains('ascolta te stess')) {
            difetti.add('$dove: "ascolta te stesso"');
          }
        }
      }
    }
    cardinaleMinimo(guardate, 4929, cosa: 'voci guardate');
    print('ORDINE EX VOCE 03: voci guardate $guardate, difetti '
        '${difetti.length}');
    expect(difetti, isEmpty, reason: difetti.take(30).join('\n'));
  });

  test('2. LA QUANTITA\': ogni gruppo ha almeno le voci che servono', () {
    final servono = leVociCheServono();
    final sotto = <String>[];
    var gruppi = 0;
    for (final campo in CampiDelPresagio.tutti) {
      for (final MapEntry(key: gruppo, value: quante)
          in servono[campo]!.entries) {
        gruppi++;
        // Le voci trattenute in attesa dell'Architetto non contano: non si
        // scelgono (`IlPresagioDalCorpus.vociTrattenute`).
        final voci = corpusDelPresagio.voci[campo]?[gruppo] ?? const [];
        final piene = [
          for (var i = 0; i < voci.length; i++)
            if (voci[i].trim().isNotEmpty &&
                !IlPresagioDalCorpus.vociTrattenute
                    .contains('$campo/$gruppo/${i + 1}'))
              i
        ].length;
        if (piene < quante) sotto.add('$campo/$gruppo: $piene su $quante');
      }
    }
    cardinaleMinimo(gruppi, 140, cosa: 'gruppi');
    print('ORDINE EX VOCE 03: gruppi $gruppi, sotto il numero che serve '
        '${sotto.length}');
    expect(sotto, isEmpty);
  });

  test('4. PAROLA PER PAROLA: il codice dice i file dell\'Architetto', () {
    var diverse = 0;
    for (final campo in CampiDelPresagio.tutti) {
      final dalFile = <String, List<String>>{};
      String? gruppo;
      for (final riga in File('docs/corpus/rune/$campo.md').readAsLinesSync()) {
        final t = RegExp(r'^## (.+)$').firstMatch(riga);
        if (t != null) {
          final parti = t.group(1)!.split(',').map((x) => x.trim()).toList();
          gruppo = campo == CampiDelPresagio.verdetto ||
                  campo == CampiDelPresagio.legame
              ? '${parti[0]}/${parti[1]}'
              : '${parti[0]}/${parti[1] == 'in ombra' ? 'ombra' : 'dritta'}';
          dalFile[gruppo] = [];
          continue;
        }
        final v = RegExp(r'^(\d+)\.\s?(.*)$').firstMatch(riga);
        if (v != null && gruppo != null) {
          dalFile[gruppo]!.add(v.group(2)!.trimRight());
        }
      }
      final nelCodice = corpusDelPresagio.voci[campo]!;
      final uguale = dalFile.length == nelCodice.length &&
          dalFile.entries.every((e) =>
              nelCodice[e.key] != null &&
              nelCodice[e.key]!.length == e.value.length &&
              List.generate(
                      e.value.length, (i) => nelCodice[e.key]![i] == e.value[i])
                  .every((x) => x));
      if (!uguale) diverse++;
    }
    print('ORDINE EX VOCE 03: file del codice diversi da quelli '
        'dell\'Architetto $diverse su ${CampiDelPresagio.tutti.length}');
    expect(diverse, 0);
  });

  /// **LE VOCI RIPORTATE ALL'ARCHITETTO**, scritte qui e non lette dal
  /// codice: la prova deve sapere da sola quali voci non possono uscire, se
  /// no un elenco svuotato per errore nel codice la lascerebbe verde.
  /// Quando una voce arriva corretta, si toglie da qui e da
  /// `IlPresagioDalCorpus.vociTrattenute`.
  const daCorreggere = {'pietra/Uruz/dritta/56', 'pietra/Mannaz/ombra/38'};

  test(
      '3. SESSANTA GIORNI AL MASSIMO DELL\'ILLUMINATO SUL CORPUS VERO: '
      'nessuna voce torna alla stessa persona', () {
    const persone = 1000;
    var ripetute = 0;
    var lette = 0;
    var parti = 0;
    var trattenuteUscite = 0;
    for (final peggiore in [false, true]) {
      for (var persona = 0; persona < persone; persona++) {
        final caso = Random(7000 * (peggiore ? 2 : 1) + persona);
        final memoria = LaMemoriaDelPresagio();
        final ultimaLettura = <String, int>{};
        for (var giorno = 0; giorno < 60; giorno++) {
          final oggi = DateTime(2026, 10, 2).add(Duration(days: giorno));
          for (var g = 0; g < 3; g++) {
            final gettata =
                peggiore ? gettate.last : gettate[caso.nextInt(gettate.length)];
            final esito = RuneCast.getta(gettata, random: caso);
            // Nel peggiore la domanda e' sempre la stessa; la stessa firma
            // lo stesso giorno ridà lo stesso presagio, ed e' voluto
            // (SPECIFICA.md, sezione 5): non e' una ripetizione.
            final domanda = peggiore
                ? 'Che cosa mi dicono le rune?'
                : 'domanda ${caso.nextInt(12)}';
            final firma = IlPresagioDalCorpus.firma(esito, domanda);
            final giaOggi = memoria.diOggi.containsKey(firma);
            final r = IlPresagioDalCorpus.componi(
              corpus: corpusDelPresagio,
              esito: esito,
              domanda: domanda,
              persona: 'persona-$persona',
              oggi: oggi,
              memoria: memoria,
            );
            for (final parte in [r.risposta, r.cosaPuoiFare, r.daDoveViene]) {
              parti++;
              expect(parte.contains('{'), isFalse, reason: parte);
            }
            if (giaOggi) continue;
            for (final id in memoria.diOggi[firma]!) {
              if (daCorreggere.contains(id)) {
                trattenuteUscite++;
              }
              final prima = ultimaLettura[id];
              if (prima != null && giorno - prima < 60) ripetute++;
              ultimaLettura[id] = giorno;
            }
            lette++;
          }
        }
      }
    }
    print('ORDINE EX VOCE 03 SUL CORPUS VERO: persone ${persone * 2} '
        '(due scenari), gettate $lette, voci ripetute in 60 giorni '
        '$ripetute, voci trattenute uscite $trattenuteUscite');
    cardinaleMinimo(lette, 300000, cosa: 'gettate simulate');
    expect(trattenuteUscite, 0,
        reason: 'una voce trattenuta in attesa dell\'Architetto e\' uscita');
    cardinaleMinimo(parti, 900000, cosa: 'parti composte');
    expect(ripetute, 0);
  }, timeout: const Timeout(Duration(minutes: 20)));
}
