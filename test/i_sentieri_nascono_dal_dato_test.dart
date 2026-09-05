import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// I TRE SENTIERI NASCONO DAL DATO. Ordine AR voce 02, portato alla
/// **revisione F** dall'ordine CP voce 05, 3 settembre 2026.
///
/// **Il corpus comanda, il codice e' la conseguenza.** I tre file dei sentieri
/// non si scrivono a mano: li genera `tool/genera_corpus_f.py` da
/// `tool/corpus_traguardi_dati.py`, e il JSON
/// `docs/corpus/Traguardi_165_Revisione_F.json` e' la fotografia leggibile di
/// quel dato. Queste prove confrontano il codice col file, voce per voce: se
/// qualcuno tocca un nome nel Dart senza toccare il corpus, cadono.
///
/// **Cosa e' cambiato con la revisione F, e perche' questa guardia e' piu'
/// forte di prima.** Fino alla revisione E il corpus scriveva la condizione
/// **in italiano** e un generatore di milleseicento righe la traduceva in
/// codice riconoscendo il testo: questa guardia poteva confrontare i NOMI, mai
/// le condizioni, perche' nel corpus non c'erano. Dalla F la condizione e' un
/// dato strutturato, e qui si confronta anche quella.
///
/// **E gli accenti non si trasformano piu'.** La E scriveva "affinita'" e il
/// generatore accentava mentre scriveva, quindi il confronto passava da
/// `conGliAccenti`. La F scrive "affinità" nel dato: il confronto e' byte per
/// byte, e una porta in meno e' una divergenza in meno.
void main() {
  final corpus = jsonDecode(
          File('docs/corpus/Traguardi_165_Revisione_F.json').readAsStringSync())
      as Map<String, dynamic>;
  final voci = <Map<String, dynamic>>[
    for (final s in corpus['sentieri'] as List)
      for (final v in (s as Map)['gradini'] as List) v as Map<String, dynamic>,
  ];

  test('sono centosessantacinque, cinquantacinque per sentiero', () {
    expect(voci.length, 165, reason: 'il corpus non ne ha piu 165');
    expect(Sentieri.tuttiITraguardi.length, 165,
        reason: 'il codice ha ${Sentieri.tuttiITraguardi.length} traguardi '
            'invece di 165');
    for (final s in Sentiero.values) {
      expect(Sentieri.di(s).length, 55,
          reason: 'il sentiero ${s.name} ha ${Sentieri.di(s).length} voci');
    }
  });

  test('gli Eos tornano: 2.010 per sentiero e 6.030 in tutto', () {
    var totale = 0;
    for (final s in Sentiero.values) {
      final somma = Sentieri.di(s).fold<int>(0, (a, t) => a + t.eos);
      // ignore: avoid_print
      print('ORDINE AR VOCE 02: ${s.name} somma $somma Eos');
      expect(somma, Sentieri.eosAttesiPerSentiero,
          reason: 'il sentiero ${s.name} somma $somma Eos invece di '
              '${Sentieri.eosAttesiPerSentiero}');
      totale += somma;
    }
    expect(totale, Sentieri.eosAttesiInTutto);
  });

  test('ogni campo scritto e quello del file, verbatim', () {
    // **SETTE CAMPI, non piu' due.** La revisione E permetteva di confrontare
    // il nome e la fascia; qui si confrontano anche la frase, la porta che
    // apre, la sezione, la ragione e gli Eos, cioe' tutto cio' che una
    // persona legge.
    final perId = {
      for (final t in Sentieri.tuttiITraguardi) t.id: t,
    };
    final diversi = <String>[];
    var confrontati = 0;
    for (final v in voci) {
      final mio = perId[v['id']];
      if (mio == null) {
        diversi.add('${v['id']} non esiste in app');
        continue;
      }
      final campi = <String, List<Object?>>{
        'nome': [mio.nome, v['nome']],
        'fascia': [mio.fascia, v['fascia']],
        'frase': [mio.frase, v['frase']],
        'cosaApre': [mio.cosaApre, v['cosaApre']],
        'sezione': [mio.sezioneDelCammino, v['sezione']],
        'ragione': [mio.ragione, v['ragione']],
        'eos': [mio.eos, v['eos']],
        'posizione': [mio.posizione, v['posizione']],
        'eGrande': [mio.eGrande, v['eGrande']],
      };
      for (final campo in campi.entries) {
        confrontati++;
        if (campo.value[0] != campo.value[1]) {
          diversi.add('${v['id']} ${campo.key} "${campo.value[0]}" invece di '
              '"${campo.value[1]}"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 05: campi confrontati col corpus $confrontati, '
        'scostamenti ${diversi.length}');
    expect(confrontati, 165 * 9,
        reason: 'la prova non ha confrontato tutti i campi: gira a vuoto');
    expect(diversi, isEmpty,
        reason: 'il codice e il corpus dicono cose diverse:\n'
            '${diversi.take(10).join("\n")}');
  });

  test('ogni CONDIZIONE e quella del file, campo per campo', () {
    // **LA PRETESA CHE NON POTEVA ESISTERE PRIMA.** Ordine CP voce 05: fino
    // alla revisione E la condizione nel corpus era una frase in italiano, e
    // il generatore la deduceva. Adesso e' un dato, e qui si verifica che il
    // Dart dica esattamente quel dato: **la fessura fra la condizione scritta
    // e quella misurata non e' piu' stretta, e' chiusa.**
    final perId = {
      for (final t in Sentieri.tuttiITraguardi) t.id: t,
    };
    var confrontate = 0;
    final diverse = <String>[];
    for (final v in voci) {
      final mio = perId[v['id']]!;
      final c = v['condizione'] as Map<String, dynamic>;
      confrontate++;
      final atteso = switch (c['tipo'] as String) {
        'GestiCompiuti' => 'gesti:${c['gesto']}:${c['quanti']}:'
            '${c['inGiorniDiversi'] == true}',
        'GiorniDentroUnArco' =>
          'arco:${c['rito']}:${c['quanti']}:${c['arco']}',
        'StessaOraPerGiorni' => 'orafedele:${c['gesto']}:${c['quantiGiorni']}',
        'GestoNellOraGiusta' =>
          'ora:${c['gesto']}:${c['ora']}:${c['quanteVolte']}',
        'FinestraDelCielo' => 'cielo:${c['evento']}:${c['conGesto']}',
        'GiornateInsieme' =>
          'giornate:${(c['gesti'] as List).join("+")}:${c['quantiGiorni']}',
        'PezzoDellIdentita' => 'identita:${c['pezzo']}',
        _ => 'specie senza firma attesa: ${c['tipo']}',
      };
      if (mio.condizione.firma != atteso) {
        diverse.add('${v['id']}: in app "${mio.condizione.firma}", dal corpus '
            '"$atteso"');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 05: condizioni confrontate col corpus $confrontate, '
        'diverse ${diverse.length}');
    expect(confrontate, 165);
    expect(diverse, isEmpty, reason: diverse.take(10).join('\n'));
  });

  test('il costo in giorni del Dart e quello che il corpus ha calcolato', () {
    // **DUE CONTI INDIPENDENTI DELLA STESSA GRANDEZZA, e devono coincidere.**
    // Il generatore calcola il costo in Python per ordinare i gradini; il
    // Dart lo calcola come proprieta' della condizione. Sono due porte sulla
    // stessa cosa, ed e' voluto: **una porta sola non si puo' controllare.**
    // Se un giorno divergessero, la scala dei traguardi sarebbe ordinata
    // secondo un numero e misurata secondo un altro.
    final perId = {
      for (final t in Sentieri.tuttiITraguardi) t.id: t,
    };
    var confrontati = 0;
    final diversi = <String>[];
    for (final v in voci) {
      confrontati++;
      final mio = perId[v['id']]!.condizione.costoInGiorni;
      if (mio != v['costoInGiorni']) {
        diversi.add('${v['id']}: il Dart dice $mio giorni, il corpus '
            '${v['costoInGiorni']}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CP VOCE 05: costi confrontati $confrontati, diversi '
        '${diversi.length}');
    expect(confrontati, 165);
    expect(diversi, isEmpty, reason: diversi.join('\n'));
  });

  test('le posizioni non hanno buchi, da 1 a 55', () {
    for (final s in Sentiero.values) {
      final posizioni = Sentieri.di(s).map((t) => t.posizione).toList()..sort();
      expect(posizioni, [for (var i = 1; i <= 55; i++) i],
          reason: 'le posizioni di ${s.name} hanno un buco o una ripetizione');
    }
  });

  test('i quindici grandi sono quindici, cinque per sentiero', () {
    for (final s in Sentiero.values) {
      expect(Sentieri.grandiDi(s).length, 5,
          reason: '${s.name} ha ${Sentieri.grandiDi(s).length} grandi');
    }
  });

  test('nessun traguardo e la riformulazione di un altro', () {
    // Due condizioni con la stessa firma sono lo stesso traguardo detto in
    // due modi: la persona lo vedrebbe accendersi due volte per un gesto solo.
    final firme = <String, String>{};
    final doppi = <String>[];
    for (final t in Sentieri.tuttiITraguardi) {
      if (t.dormiente) continue;
      final gia = firme[t.condizione.firma];
      if (gia != null) {
        doppi.add('${t.id} dice come $gia: ${t.condizione.firma}');
      } else {
        firme[t.condizione.firma] = t.id;
      }
    }
    // ignore: avoid_print
    print('ORDINE AR VOCE 02: condizioni ripetute ${doppi.length}');
    expect(doppi, isEmpty,
        reason: 'questi traguardi sono lo stesso traguardo detto due volte: '
            '${doppi.take(6).join("; ")}');
  });

  test('i file dei sentieri sono generati, non scritti a mano', () {
    for (final nome in const [
      'sentiero_costellazione',
      'sentiero_albero',
      'sentiero_loto',
      // **DUE FILE IN PIU', ordine CP voce 05.** La tavola dell'attesa del
      // cielo e la mappa del Maestro di un gesto nascono dallo stesso dato:
      // scritte a mano sarebbero due copie della stessa verita'.
      'attesa_del_cielo',
      'maestro_del_gesto',
    ]) {
      final sorgente = File('lib/core/sigilli/$nome.dart').readAsStringSync();
      expect(sorgente.contains('GENERATO DA tool/genera_corpus_f.py'), isTrue,
          reason: '$nome non dichiara piu di essere generato: qualcuno lo ha '
              'scritto a mano, e il corpus ha smesso di comandare');
    }
    for (final strumento in const [
      'tool/genera_corpus_f.py',
      'tool/corpus_traguardi.py',
      'tool/corpus_traguardi_dati.py',
    ]) {
      expect(File(strumento).existsSync(), isTrue,
          reason: '$strumento non esiste piu: il corpus non si potrebbe piu '
              'rigenerare');
    }
  });

  group('Ordine CP voce 05, la forma del cammino', () {
    test('La porta che apre esiste per ogni voce, e non e una formula', () {
      // **NON PUO' PIU' DIVERGERE DAL CORPUS**, perche' viene di li' verbatim
      // e la prova di sopra lo verifica campo per campo. Qui si guarda che
      // sia una porta VERA: non vuota, non una frase di comodo ripetuta su
      // mezzo cammino.
      final quante = <String, int>{};
      for (final t in Sentieri.tuttiITraguardi) {
        expect(t.cosaApre.trim().length, greaterThan(20),
            reason: '${t.id} non dice cosa apre: "${t.cosaApre}"');
        quante[t.cosaApre] = (quante[t.cosaApre] ?? 0) + 1;
      }
      final ripetute = quante.entries.where((e) => e.value > 3).toList();
      // ignore: avoid_print
      print('ORDINE CP VOCE 05: porte distinte ${quante.length} su '
          '${Sentieri.tuttiITraguardi.length}');
      expect(quante.length, greaterThan(140),
          reason: 'le porte distinte sono solo ${quante.length}: il cammino '
              'sta promettendo la stessa cosa a chi lo percorre');
      expect(ripetute, isEmpty,
          reason: 'queste porte si ripetono piu di tre volte: '
              '${ripetute.map((e) => "${e.key} (${e.value})").join(" | ")}');
    });

    test('I dormienti del corpus e quelli in app sono lo stesso insieme', () {
      // **ZERO DA TUTTE E DUE LE PARTI, ordine CP voce 06.** La revisione E ne
      // aveva cinquantuno; la F e' costruita solo sui gesti che una schermata
      // manda e sugli eventi che il motore calcola, quindi non ne ha.
      final dalCorpus = voci.where((v) => v['famiglia'] == 'dormiente').length;
      final inApp = Sentieri.tuttiITraguardi.where((t) => t.dormiente).toList();
      // ignore: avoid_print
      print('ORDINE CP VOCE 06: dormienti dichiarati dal corpus $dalCorpus, '
          'dormienti in app ${inApp.length}');
      expect(inApp.length, dalCorpus,
          reason: 'il corpus dichiara $dalCorpus dormienti e in app ne '
              'dormono ${inApp.length}: uno dei due mente');
      expect(inApp, isEmpty,
          reason: 'la revisione F non ammette dormienti, e ne ha '
              '${inApp.length}: ${inApp.map((t) => t.id).join(", ")}');
    });

    test('Le perle non si accendono nell\'ordine di un ramo solo', () {
      // **L'ACCENSIONE NON SEGUE UN RAMO SOLO**, e il modo di misurarlo e'
      // guardare da dove vengono le condizioni: se ogni perla dipendesse dal
      // gradino precedente dello stesso sentiero, il cammino sarebbe una
      // scala unica.
      //
      // **SETTE SPECIE E NON OTTO, ordine CP voce 05, e il numero segue il
      // dato.** La revisione E ne usava undici, ma quattro di quelle vivevano
      // solo dentro gradini dormienti: contavano come varieta' del disegno
      // senza esserlo, perche' nessuna si accendeva. Le sette della revisione
      // F si accendono tutte, e **nessuna di loro e' il conto dei gradini
      // alle spalle**, che era la specie da cui nasceva il rischio della
      // scala unica: adesso e' zero invece che quindici.
      var perGradini = 0;
      final tipi = <String>{};
      for (final t in Sentieri.tuttiITraguardi) {
        final tipo = t.condizione.runtimeType.toString();
        tipi.add(tipo);
        if (tipo == 'GradiniAlleSpalle') perGradini++;
      }
      // ignore: avoid_print
      print('ORDINE CP VOCE 05: specie di condizione distinte '
          '${tipi.length} (${(tipi.toList()..sort()).join(", ")}), e le voci '
          'legate al solo conto dei gradini sono $perGradini su '
          '${Sentieri.tuttiITraguardi.length}');
      expect(tipi.length, greaterThanOrEqualTo(7),
          reason: 'il cammino usa solo ${tipi.length} specie di condizione: '
              'con cosi poche l\'accensione finisce per seguire un ramo solo');
      expect(perGradini, 0,
          reason: 'ci sono $perGradini voci che dipendono solo dai gradini '
              'alle spalle: il cammino sta diventando una scala unica');
    });
  });
}
