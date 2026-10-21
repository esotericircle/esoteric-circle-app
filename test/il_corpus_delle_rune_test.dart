// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/domande/domande_del_cerchio.dart';
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
///
/// **LA MISURA DELL'ORDINE GA, voci GA.03 e GA.07, 20 ottobre 2026.** Il
/// fondatore, 19 ottobre 2026 alle 23:08: *"tutte le risposte composte da
/// paragrafi ognuno con tra 40 a 50 parole ognuno"*. La forma qui sotto
/// misurava i cinque campi dell'ordine EX in CARATTERI, con un valore medio
/// per spazio ("il lavoro", "ciò che diviene"): adesso misura i sei campi in
/// PAROLE, contate come `LaFormaDelResponso.parole`, con OGNI valore di
/// `{cosa}` che il compositore conosce e ogni nome di gettata, nelle
/// finestre di `docs/corpus/rune/SPECIFICA.md` sezione 3: RISPOSTA da 20 a
/// 28 riempita con un solo `{cosa}`, VERDETTO da 20 a 22 senza spazi (e la
/// loro somma, il paragrafo della risposta, sempre fra 40 e 50), PIETRA da
/// 40 a 50 con un solo `{cosa}` e niente `{glossa}`, GESTO e LEGAME da 40 a
/// 50 con al piu' uno spazio, CONSIGLIO, il campo nuovo, da 40 a 50 senza
/// spazi. Il cardinale sale a 7.380 voci, i sessanta giorni si contano sul
/// presagio composto nella Lunga e sulle schede. Dall'ordine GA i testi li
/// riscrivono gli scrittori di Code, per ordine del fondatore (SPECIFICA.md,
/// in testa).
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

  /// Per campo, dall'ordine GA: gli spazi permessi, quanti spazi (il primo e
  /// l'ultimo numero), le parole a spazi riempiti con OGNI valore, e se la
  /// voce nomina la sua runa. **Prima dell'ordine GA** qui c'erano le
  /// lunghezze in caratteri dell'ordine EX e `{glossa}` in PIETRA.
  const regole = <String, (Set<String>, int, int, int, int, bool)>{
    CampiDelPresagio.risposta: ({'cosa'}, 1, 1, 20, 28, false),
    CampiDelPresagio.verdetto: (<String>{}, 0, 0, 20, 22, false),
    CampiDelPresagio.pietra: ({'cosa'}, 1, 1, 40, 50, true),
    CampiDelPresagio.legame: ({'cosa', 'gettata'}, 0, 1, 40, 50, false),
    CampiDelPresagio.gesto: ({'cosa'}, 0, 1, 40, 50, false),
    CampiDelPresagio.consiglio: (<String>{}, 0, 0, 40, 50, false),
  };

  /// OGNI VALORE DI `{cosa}`, letto dal compositore e non scritto qui:
  /// nessuna domanda, le domande del Cerchio, una domanda per famiglia di
  /// parole e una che l'app non riconosce.
  final valoriDiCosa = <String>{
    for (final d in [
      '',
      for (final d in DomandeDelCerchio.generichePerLaGettata) d.testo,
      for (final d in DomandeDelCerchio.personaliPerLaGettata) d.testo,
      'Il mio amore tornerà?',
      'Il colloquio andrà bene?',
      'Devo cambiare casa?',
      'Con mio fratello come va?',
      'Un amico mi ha deluso',
      'I soldi bastano?',
      'Passerò l’esame?',
      'Quale decisione prendere?',
      'Che cosa mi aspetta?',
      // Ordine GA voce GA.06: le famiglie nuove del compositore, la domanda
      // su un'altra persona, quella delicata e quella che l'app non
      // riconosce ("Che cosa mi aspetta?" adesso vale "il tuo momento").
      'Come faccio a dimenticarlo?',
      'Il progetto verrà approvato?',
      'Il cambiamento sarà positivo?',
      'Arriverà la risposta che aspetto?',
      'Quando finirà questo periodo?',
      'Incontrerò qualcuno di importante?',
      'Devo trasferirmi a Milano?',
      'Cosa prova davvero per me?',
      'L’operazione andrà bene?',
    ])
      IlPresagioDalCorpus.cosaDellaDomanda(d),
  };
  int parole(String t) =>
      t.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length;

  /// Le parole di una voce col minimo e il massimo fra i valori dei suoi
  /// spazi; `{gettata}` vale il nome della gettata del gruppo del LEGAME.
  (int, int) misura(String gruppo, String voce) {
    final gettata = gettate
        .where((g) => g.id == gruppo.split('/').first)
        .map((g) => g.nome.toLowerCase())
        .toList();
    final valori = voce.contains('{cosa}') ? valoriDiCosa : <String>{''};
    var lo = 1 << 30;
    var hi = -1;
    for (final v in valori) {
      var piena = voce.replaceAll('{cosa}', v);
      if (gettata.isNotEmpty) {
        piena = piena.replaceAll('{gettata}', gettata.first);
      }
      final n = parole(piena);
      if (n < lo) lo = n;
      if (n > hi) hi = n;
    }
    return (lo, hi);
  }

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
    // Dall'ordine GA voce GA.07: 4.929 voci dei cinque campi e 2.451 del
    // CONSIGLIO, il riquadro delle schede.
    cardinaleMinimo(corpusDelPresagio.quante, 7380,
        cosa: 'voci del corpus delle rune');
    print('ORDINE EX VOCE 03: voci del corpus ${corpusDelPresagio.quante}');
  });

  test('1. LA FORMA: gruppi, spazi, parole, nomi di runa', () {
    final difetti = <String>[];
    var guardate = 0;
    // Il paragrafo della risposta e' RISPOSTA piu' VERDETTO, e ogni verdetto
    // puo' seguire ogni risposta: bastano il minimo e il massimo di ognuno.
    var risposteMin = 1 << 30, risposteMax = -1;
    var verdettiMin = 1 << 30, verdettiMax = -1;
    cardinaleMinimo(valoriDiCosa.length, 20,
        cosa: 'valori di {cosa} misurati',
        perche: 'venti valori nel compositore al 20 ottobre 2026');
    for (final campo in CampiDelPresagio.tutti) {
      final (spazi, pochi, tanti, minimo, massimo, nomina) = regole[campo]!;
      final gruppi = corpusDelPresagio.voci[campo]!;
      expect(gruppi.keys.toSet(), IlPresagioDalCorpus.gruppiDi(campo).toSet(),
          reason: campo);
      for (final MapEntry(key: gruppo, value: voci) in gruppi.entries) {
        for (var i = 0; i < voci.length; i++) {
          final voce = voci[i];
          if (voce.trim().isEmpty) continue;
          guardate++;
          final dove = '$campo.md, $gruppo, voce ${i + 1}';
          final tutti = RegExp(r'\{([a-z]+)\}')
              .allMatches(voce)
              .map((m) => m.group(1)!)
              .toList();
          final usati = tutti.toSet();
          if (usati.difference(spazi).isNotEmpty) {
            difetti.add('$dove: spazio non permesso '
                '${usati.difference(spazi)}');
          }
          if (tutti.length < pochi || tutti.length > tanti) {
            difetti.add('$dove: ${tutti.length} spazi, ne vuole da $pochi a '
                '$tanti');
          }
          final (lo, hi) = misura(gruppo, voce);
          if (lo < minimo || hi > massimo) {
            difetti.add('$dove: da $lo a $hi parole fuori da '
                '$minimo-$massimo');
          }
          if (campo == CampiDelPresagio.risposta) {
            risposteMin = lo < risposteMin ? lo : risposteMin;
            risposteMax = hi > risposteMax ? hi : risposteMax;
          }
          if (campo == CampiDelPresagio.verdetto) {
            verdettiMin = lo < verdettiMin ? lo : verdettiMin;
            verdettiMax = hi > verdettiMax ? hi : verdettiMax;
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
    cardinaleMinimo(guardate, 7380, cosa: 'voci guardate');
    if (risposteMin + verdettiMin < 40 || risposteMax + verdettiMax > 50) {
      difetti.add('il paragrafo della risposta va da '
          '${risposteMin + verdettiMin} a ${risposteMax + verdettiMax} '
          'parole, fuori da 40-50');
    }
    print('ORDINE GA VOCE 07: voci guardate $guardate, il paragrafo della '
        'risposta da ${risposteMin + verdettiMin} a '
        '${risposteMax + verdettiMax} parole, difetti ${difetti.length}');
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
    // Dall'ordine GA: i 40 gruppi del CONSIGLIO.
    cardinaleMinimo(gruppi, 180, cosa: 'gruppi');
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
  /// `IlPresagioDalCorpus.vociTrattenute`, e passa fra le [rientrate].
  const daCorreggere = <String>{};

  /// **LE VOCI CORRETTE DALL'ARCHITETTO E RIENTRATE**, 2 ottobre 2026: erano
  /// trattenute e adesso devono tornare a uscire, se no il blocco e' rimasto.
  const rientrate = {'pietra/Uruz/dritta/56', 'pietra/Mannaz/ombra/38'};

  test(
      '3. SESSANTA GIORNI AL MASSIMO DELL\'ILLUMINATO SUL CORPUS VERO: '
      'nessuna voce torna alla stessa persona', () {
    const persone = 1000;
    var ripetute = 0;
    var lette = 0;
    var parti = 0;
    var trattenuteUscite = 0;
    final rientrateUscite = <String>{};
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
            // Dall'ordine GA: la Lunga, che legge anche il LEGAME, e le
            // schede, che leggono PIETRA e CONSIGLIO.
            final r = IlPresagioDalCorpus.componi(
              corpus: corpusDelPresagio,
              esito: esito,
              domanda: domanda,
              persona: 'persona-$persona',
              oggi: oggi,
              memoria: memoria,
              lunga: true,
            );
            for (final parte in [
              ...r.principale.paragrafi,
              for (final s in r.schede) ...s.paragrafi,
            ]) {
              parti++;
              if (parte.contains('{')) {
                fail('uno spazio non riempito: $parte');
              }
            }
            if (giaOggi) continue;
            for (final id in memoria.diOggi[firma]!.values) {
              if (daCorreggere.contains(id)) {
                trattenuteUscite++;
              }
              if (rientrate.contains(id)) rientrateUscite.add(id);
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
    print('ORDINE EX VOCE 03: voci corrette e rientrate uscite '
        '${rientrateUscite.length} su ${rientrate.length}');
    expect(rientrateUscite, rientrate,
        reason: 'una voce corretta dall\'Architetto non esce: e\' ancora '
            'trattenuta');
    expect(trattenuteUscite, 0,
        reason: 'una voce trattenuta in attesa dell\'Architetto e\' uscita');
    // Dall'ordine GA: almeno quattro paragrafi per gettata nella Lunga.
    cardinaleMinimo(parti, 1400000, cosa: 'paragrafi composti');
    expect(ripetute, 0);
  }, timeout: const Timeout(Duration(minutes: 20)));
}
