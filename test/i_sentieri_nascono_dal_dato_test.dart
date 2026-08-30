import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

import 'gli_accenti_del_corpus.dart';

/// I TRE SENTIERI NASCONO DAL DATO. Ordine AR voce 02.
///
/// **Il corpus comanda, il codice e' la conseguenza.** I tre file dei sentieri
/// non si scrivono a mano: li genera `tool/genera_sentieri_dal_corpus.py` da
/// `docs/corpus/Traguardi_165_Revisione_E.json`, che dall ordine AU voce 03 e
/// il corpus vivo. Queste prove confrontano il
/// codice col file, voce per voce: se qualcuno tocca un nome nel Dart senza
/// toccare il corpus, cadono.
///
/// **Perche' si genera invece di trascrivere.** Centosessantacinque voci
/// copiate a mano introducono errori silenziosi, e un errore silenzioso in un
/// traguardo si scopre solo il giorno in cui non si accende.
void main() {
  final corpus = jsonDecode(
      File('docs/corpus/Traguardi_165_Revisione_E.json')
          .readAsStringSync()) as Map<String, dynamic>;
  final voci = <Map<String, dynamic>>[
    for (final s in corpus['sentieri'] as List)
      for (final v in (s as Map)['voci'] as List) v as Map<String, dynamic>,
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

  test('ogni nome e ogni fascia sono quelli del file, verbatim', () {
    final perId = {
      for (final t in Sentieri.tuttiITraguardi) t.id: t,
    };
    final diversi = <String>[];
    for (final v in voci) {
      final mio = perId[v['id'] as String];
      if (mio == null) {
        diversi.add('${v['id']} manca nel codice');
        continue;
      }
      // **VERBATIM VUOL DIRE LE STESSE PAROLE, non gli stessi byte**: vedi
      // gli_accenti_del_corpus.dart. Il corpus scrive "e'", l'app mostra "è".
      if (mio.nome != conGliAccenti(v['nome'] as String)) {
        diversi.add('${v['id']} nome "${mio.nome}" invece di "${v['nome']}"');
      }
      if (mio.fascia != conGliAccenti(v['fascia'] as String)) {
        diversi.add('${v['id']} fascia "${mio.fascia}"');
      }
      if (mio.eos != v['eos']) {
        diversi.add('${v['id']} eos ${mio.eos} invece di ${v['eos']}');
      }
      if (mio.eGrande != (v['grande'] as bool)) {
        diversi.add('${v['id']} grande ${mio.eGrande}');
      }
    }
    // ignore: avoid_print
    print('ORDINE AR VOCE 02: scostamenti dal corpus ${diversi.length}');
    expect(diversi, isEmpty,
        reason: 'il codice si e scostato dal corpus: '
            '${diversi.take(5).join("; ")}');
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
    ]) {
      final sorgente =
          File('lib/core/sigilli/$nome.dart').readAsStringSync();
      expect(sorgente.contains('GENERATO DA tool/genera_sentieri_dal_corpus'),
          isTrue,
          reason: '$nome non dichiara piu di essere generato: qualcuno lo ha '
              'scritto a mano, e il corpus ha smesso di comandare');
    }
    expect(File('tool/genera_sentieri_dal_corpus.py').existsSync(), isTrue,
        reason: 'il generatore non esiste piu: il corpus nuovo non si potrebbe '
            'piu applicare');
  });

  group('Ordine BW voce 01, il cammino rispecchia la revisione E', () {
    test('La porta che apre arriva in app per ogni voce, verbatim', () {
      // **LA PORTA E' IL PEZZO CHE DICE A COSA SERVE UN GRADINO**, e il
      // corpus la porta per tutte e centosessantacinque le voci. In app vive
      // nel campo `cosaApre`: se una si perdesse per strada, quel gradino
      // diventerebbe un premio senza destinazione.
      final mancanti = <String>[];
      final diverse = <String>[];
      var trasformate = 0;
      for (final v in voci) {
        final t = Sentieri.tuttiITraguardi
            .where((x) => x.id == v['id'])
            .firstOrNull;
        if (t == null) {
          mancanti.add('${v['id']} non esiste in app');
          continue;
        }
        final attesa = (v['porta_che_apre'] as String).trim();
        if (attesa.isEmpty) {
          mancanti.add('${v['id']} non ha porta nel corpus');
          continue;
        }
        // **DUE TRASFORMAZIONI DICHIARATE, e non sono riscritture.** Il
        // generatore porta gli accenti veri al posto dell'apostrofo, che e'
        // ortografia e non scrittura, e traduce i nomi dei doni rinominati
        // dopo che il corpus era stato scritto. Qui si applicano le stesse
        // due regole prima di confrontare: senza, la prova chiamerebbe
        // differenza cio' che e' una regola di casa.
        final normalizzata = conGliAccenti(coiNomiNuovi(attesa));
        if (t.cosaApre.trim() != normalizzata) {
          diverse.add('${v['id']}: in app "${t.cosaApre}", dal corpus '
              '"$normalizzata"');
        } else if (t.cosaApre.trim() != attesa) {
          trasformate++;
        }
      }
      // ignore: avoid_print
      print('ORDINE BW VOCE 1: porte lette dal corpus ${voci.length}, '
          'mancanti ${mancanti.length}, trasformate dalle due regole di casa '
          '$trasformate, diverse ${diverse.length}'
          '${diverse.isEmpty ? "" : ": ${diverse.join(" | ")}"}');
      expect(mancanti, isEmpty, reason: 'queste voci non hanno porta: '
          '$mancanti');
      expect(diverse, isEmpty,
          reason: 'la porta in app non e\' quella del corpus: $diverse');
    });

    test('I dormienti del corpus dormono tutti in app', () {
      // **I CINQUANTUNO CHE IL CORPUS DICHIARA.** Nessuno di loro puo\' essere
      // sveglio in app: sarebbero gradini che promettono qualcosa che non
      // esiste ancora.
      final svegliPerErrore = <String>[];
      var dichiarati = 0;
      for (final v in voci) {
        if (v['dormiente'] != true) continue;
        dichiarati++;
        final t = Sentieri.tuttiITraguardi
            .where((x) => x.id == v['id'])
            .firstOrNull;
        if (t != null && !t.dormiente) svegliPerErrore.add('${v['id']}');
      }
      // ignore: avoid_print
      print('ORDINE BW VOCE 1: dormienti dichiarati dal corpus $dichiarati, '
          'di cui svegli in app ${svegliPerErrore.length}');
      expect(dichiarati, 51,
          reason: 'il corpus dichiara $dichiarati dormienti invece di 51: se '
              'il file e\' cambiato il numero segue il dato, ma va detto');
      // **TRE DI QUEI CINQUANTUNO ADESSO SONO SVEGLI, ED E\' GIUSTO COSI\'.**
      // Ordine CE voce 16: il corpus li dichiara dormienti scrivendo
      // perche\', "il motore delle eclissi non esiste", e quella nota era
      // vera il giorno in cui e\' stata scritta. Il motore adesso esiste, e il
      // generatore ha un elenco di ragioni risolte che scavalca il flag del
      // corpus. **Il corpus non si tocca**: e\' la fonte, e riscriverlo
      // sarebbe cancellare la storia.
      //
      // La riga qui sotto pretende ESATTAMENTE quei tre e nessun altro: un
      // quarto gradino che si svegliasse senza una ragione risolta la fa
      // cadere, che e\' precisamente il guasto da cui questa guardia nasce.
      const svegliatiDaUnaRagioneRisolta = ['med_50', 'aur_49', 'cal_50'];
      svegliPerErrore.removeWhere(svegliatiDaUnaRagioneRisolta.contains);
      expect(svegliPerErrore, isEmpty,
          reason: 'questi dormienti del corpus sono svegli in app: '
              '$svegliPerErrore');
    });

    test('In app dormono soltanto i cinquantuno del corpus', () {
      // **IL NUMERO CHE IL FONDATORE DEVE VEDERE.** In app dormono
      // SETTANTOTTO voci, non cinquantuno: le altre ventisette il corpus le
      // vuole vive, ma l'app non sa misurarne la condizione, e un gradino che
      // non si puo\' misurare non si accendera\' mai. Il generatore le
      // addormenta col loro perche\', e questa prova pretende che ognuna lo
      // porti scritto: un dormiente senza ragione sarebbe un gradino perso in
      // silenzio.
      final inApp = Sentieri.tuttiITraguardi.where((t) => t.dormiente).toList();
      final dalCorpus = {
        for (final v in voci)
          if (v['dormiente'] == true) v['id'] as String,
      };
      // **I TRE CHE DORMONO PERCHE' IL FONDATORE HA TOLTO IL QUADERNO.**
      // Ordine CB voce 01. Non e' l'app che non sa misurarli: e' che il
      // gesto non esiste piu', perche' il diario dei sogni e' stato
      // eliminato per ordine del fondatore. Dichiararli qui col nome e' la
      // strada di questo progetto, e allungare invece la lista dei permessi
      // in silenzio sarebbe l'opposto.
      const tolti = <String, String>{
        'cal_17': 'Il sogno riletto, chiedeva di tornare su un sogno annotato',
        'cal_31': 'Il sogno che si ripete, chiedeva due sogni annotati',
        'cal_32': 'Il tuo Animale nel sogno, chiedeva un sogno annotato',
      };
      final inPiu = inApp
          .where((t) => !dalCorpus.contains(t.id) && !tolti.containsKey(t.id))
          .toList();
      // ignore: avoid_print
      print('ORDINE CB VOCE 01: dormono per il quaderno tolto '
          '${tolti.keys.join(", ")}, ottanta Eos che oggi nessuno raggiunge');
      final senzaRagione = inPiu.where((t) {
        final c = t.condizione;
        return c is! Dormiente || c.perche.trim().isEmpty;
      }).toList();
      // ignore: avoid_print
      print('ORDINE BW VOCE 1: in app dormono ${inApp.length} voci, '
          '${dalCorpus.length} dichiarate dal corpus e ${inPiu.length} '
          'addormentate dal generatore perche\' l\'app non sa misurarle; '
          'senza ragione scritta ${senzaRagione.length}');
      // ignore: avoid_print
      print('ORDINE BW VOCE 1: quelle ancora addormentate dal generatore sono '
          '${inPiu.map((t) => t.id).join(", ")}');
      // **CI SIAMO ARRIVATI.** Erano 78 all'inizio dell'ordine BW voce 07,
      // sono 51 alla fine dell'ordine BX voce 10: esattamente quelle che il
      // corpus dichiara dormienti, cioe' il Coming soon voluto dal fondatore.
      // **Nessuna voce resta spenta perche' l'app non sa misurarla**, ed e'
      // questa la riga che lo dice: `inPiu` deve restare vuota.
      expect(inPiu.map((t) => t.id), isEmpty,
          reason: 'queste voci dormono perche\' l\'app non sa misurarle, '
              'e non perche\' il corpus le voglia dormienti: '
              '${inPiu.map((t) => t.id).toList()}');
      // **E I RISVEGLIATI SI SOTTRAGGONO, ordine CE voce 16.** Tre voci che
      // il corpus dichiara dormienti non dormono piu\' in app, perche\' la
      // ragione scritta nel corpus e\' stata risolta da un ordine: il motore
      // delle eclissi adesso esiste. Il conto le toglie invece di
      // pretenderle, e la riga di sopra ha gia\' preteso che siano
      // esattamente quelle tre.
      final risvegliati = dalCorpus
          .where((id) =>
              Sentieri.tuttiITraguardi
                  .where((t) => t.id == id && t.dormiente)
                  .isEmpty)
          .length;
      expect(inApp.length, dalCorpus.length + tolti.length - risvegliati,
          reason: 'in app dormono ${inApp.length} voci invece di '
              '${dalCorpus.length + tolti.length - risvegliati}: il numero '
              'segue il dato, ma un cambiamento va detto al fondatore');
      // **CINQUANTUNO DALL\'ORDINE CE VOCE 16**, e il numero segue il dato:
      // erano cinquantaquattro, e i tre gradini delle eclissi si sono
      // svegliati perche\' il loro motore adesso esiste.
      expect(inApp.length, 51,
          reason: 'erano 51 fino all\'ordine CB, e i tre in piu\' sono quelli '
              'del quaderno dei sogni tolto: ${tolti.keys}');
      expect(senzaRagione.map((t) => t.id), isEmpty,
          reason: 'questi dormono senza dire perche\': '
              '${senzaRagione.map((t) => t.id)}');
    });

    test('Le ventisette voci sociali ci sono, e otto sono gia\' vive', () {
      // **LE VOCI CHE CHIEDONO UN'ALTRA PERSONA.** Il corpus ne porta
      // ventisette e le marca da se\', nel campo `note`. Otto sono gia\'
      // vive, e sono quelle della condivisione, che nell'app esiste; le
      // altre aspettano il gesto dell'invito, che alla regia non arriva.
      // Il numero si stampa perche\' dice quanto del Cerchio sociale sia
      // gia\' in piedi.
      // Il corpus le marca da se', nel campo `note`: non si indovinano
      // leggendo i nomi.
      final sociali = voci
          .where((v) => '${v['note']}'.toUpperCase().contains('SOCIALE'))
          .toList();
      final sveglie = <String>[];
      for (final v in sociali) {
        final t = Sentieri.tuttiITraguardi
            .where((x) => x.id == v['id'])
            .firstOrNull;
        if (t != null && !t.dormiente) sveglie.add('${v['id']} ${v['nome']}');
      }
      // ignore: avoid_print
      print('ORDINE BW VOCE 1: voci sociali nel corpus ${sociali.length}, '
          'di cui sveglie in app ${sveglie.length}'
          '${sveglie.isEmpty ? "" : " ($sveglie)"}');
      expect(sociali.length, 27,
          reason: 'le voci sociali sono ${sociali.length} invece di 27');
    });

    test('Le perle non si accendono nell\'ordine di un ramo solo', () {
      // **L'ACCENSIONE NON SEGUE UN RAMO SOLO**, e il modo di misurarlo e\'
      // guardare da dove vengono le condizioni: se ogni perla dipendesse dal
      // gradino precedente dello stesso sentiero, il cammino sarebbe una
      // scala unica. Qui si contano le voci la cui condizione NON e\' il
      // conto dei gradini alle spalle, cioe\' quelle che si accendono per un
      // fatto proprio, e le famiglie di condizione distinte che il cammino
      // usa davvero.
      var perGradini = 0;
      final tipi = <String>{};
      for (final t in Sentieri.tuttiITraguardi) {
        final tipo = t.condizione.runtimeType.toString();
        tipi.add(tipo);
        if (tipo == 'GradiniAlleSpalle') perGradini++;
      }
      // ignore: avoid_print
      print('ORDINE BW VOCE 1: famiglie di condizione distinte '
          '${tipi.length} (${(tipi.toList()..sort()).join(", ")}), e le voci '
          'legate al solo conto dei gradini sono $perGradini su '
          '${Sentieri.tuttiITraguardi.length}');
      expect(tipi.length, greaterThanOrEqualTo(8),
          reason: 'il cammino usa solo ${tipi.length} famiglie di condizione: '
              'con cosi\' poche l\'accensione finisce per seguire un ramo solo');
      expect(perGradini, lessThan(Sentieri.tuttiITraguardi.length ~/ 3),
          reason: 'ci sono $perGradini voci che dipendono solo dai gradini '
              'alle spalle: il cammino sta diventando una scala unica');
    });
  });
}

/// I doni rinominati dopo la scrittura del corpus, lo stesso elenco.
String coiNomiNuovi(String testo) => testo
    .replaceAll('Oracolo del Giorno', 'Arcano del Giorno')
    .replaceAll('Rito del Sogno', 'Sigillo del Sogno');
