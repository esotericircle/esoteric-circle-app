import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'lettore_dei_manifesti.dart';

/// **I MANIFESTI SONO SIGILLATI, E IL SIGILLO DICE IL VERO.**
/// Ordine CQ voci 4.01 e 4.04, 4 settembre 2026.
///
/// **Il fatto, dal Collaudatore degli Ordini.** Il suo passo zero prende solo i
/// manifesti terminali e sigillati coi marcatori a macchina. CM, CN, CO e CP
/// non li avevano, quindi il Collaudatore li saltava e andava a ritroso:
/// **stava collaudando ordini di settimane fa mentre i quattro piu' recenti non
/// passavano da nessun controllo indipendente.** Le due regressioni viste dal
/// fondatore la sera del 3 settembre nascono nell'ordine CO e sarebbero state
/// intercettate.
///
/// **REGOLA F, nuova e valida da ora in poi.** Un ordine non e' finito finche'
/// il suo manifesto non e' sigillato coi marcatori terminali. Vale come la
/// REGOLA D: senza manifesto sigillato la consegna non si dichiara conclusa,
/// qualunque sia il numero di voci chiuse.
///
/// **Perche' una guardia sola e non cinque copie.** Le cinque sorelle
/// `ordine_XX_guard_test.dart` sorvegliano ognuna il CONTENUTO del suo ordine,
/// che e' diverso per ognuna. Qui si sorveglia la FORMA del sigillo, che e' la
/// stessa per tutte: scritta cinque volte diventerebbe cinque forme diverse
/// della stessa cosa, ed e' la famiglia di difetti piu' numerosa di questo
/// progetto.
void main() {
  /// I manifesti sigillati, col numero di voci che ciascuno dichiara.
  ///
  /// **Il numero sta qui e non si legge dal file**, altrimenti la guardia
  /// leggerebbe il conto dal documento che deve controllare: se qualcuno
  /// cancellasse meta' delle righe e aggiustasse il marcatore, i due
  /// coinciderebbero e nessuno se ne accorgerebbe.
  const sigillati = <String, int>{
    'CG': 16,
    'CM': 11,
    'CN': 16,
    'CO': 20,
    'CP': 10,
    'CQ': 61,
  };

  const stati = <String, String>{
    'FERMATA SU PREMESSA FALSA': 'VOCI_FERMATE_SU_PREMESSA_FALSA',
    'FERMATA IN ATTESA DI DECISIONE': 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE',
    'FERMATA SU DECISIONE DEL FONDATORE':
        'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE',
    'CHIUSA': 'VOCI_CHIUSE',
    'APERTA': 'VOCI_APERTE',
  };

  int marcatore(String testo, String nome, String ordine) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto di $ordine non porta il marcatore $nome: senza '
            'marcatori il Collaudatore non lo legge, e lo salta');
    return int.parse(trovato!.group(1)!);
  }

  test('ogni manifesto porta i sei marcatori, e dicono il vero', () {
    var guardati = 0;
    final storti = <String>[];
    final riepilogo = <String, String>{};
    for (final voce in sigillati.entries) {
      final ordine = voce.key;
      final file = File('docs/ordini/ORDINE_${ordine}_MANIFESTO.md');
      if (!file.existsSync()) {
        storti.add('$ordine: il manifesto non esiste');
        continue;
      }
      guardati++;
      final testo = file.readAsStringSync();
      final righe = testo
          .split(String.fromCharCode(10))
          .where((r) => RegExp('^- \\*\\*$ordine\\.\\d\\d\\*\\*').hasMatch(r))
          .toList();
      if (righe.length != voce.value) {
        storti.add('$ordine: righe di voce ${righe.length} invece di '
            '${voce.value}');
        continue;
      }
      final conti = <String, int>{for (final m in stati.values) m: 0};
      final senzaStato = <String>[];
      for (final r in righe) {
        final trovato = stati.keys.firstWhere(
            (stato) => r.contains('**$stato.**') || r.contains('**$stato**'),
            orElse: () => '');
        if (trovato.isEmpty) {
          senzaStato.add(r.substring(0, r.length < 34 ? r.length : 34));
          continue;
        }
        conti[stati[trovato]!] = conti[stati[trovato]]! + 1;
      }
      if (senzaStato.isNotEmpty) {
        storti.add('$ordine: righe senza uno stato ammesso $senzaStato');
        continue;
      }
      if (marcatore(testo, 'VOCI_TOTALI', ordine) != righe.length) {
        storti.add('$ordine: VOCI_TOTALI non e la somma delle righe vere');
      }
      var somma = 0;
      for (final stato in conti.entries) {
        if (marcatore(testo, stato.key, ordine) != stato.value) {
          storti.add('$ordine: il marcatore ${stato.key} dice '
              '${marcatore(testo, stato.key, ordine)} e le righe vere sono '
              '${stato.value}');
        }
        somma += stato.value;
      }
      if (somma != voce.value) {
        storti.add('$ordine: i cinque stati sommano $somma invece di '
            '${voce.value}');
      }
      riepilogo[ordine] = conti.entries
          .where((e) => e.value > 0)
          .map((e) => '${e.key.replaceFirst("VOCI_", "")} ${e.value}')
          .join(', ');
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 4.01: manifesti sigillati guardati $guardati'
        '${riepilogo.entries.map((e) => "${String.fromCharCode(10)}  "
            "${e.key}: ${e.value}").join()}');
    cardinaleMinimo(guardati, sigillati.length,
        cosa: 'manifesti sigillati trovati sul disco',
        perche: 'Se un manifesto sparisse, questa prova non lo guarderebbe e '
            'resterebbe verde: e il modo in cui un ordine smette di essere '
            'collaudabile senza che nessuno lo dica.');
    expect(storti, isEmpty,
        reason: 'questi sigilli non dicono il vero:'
            '${String.fromCharCode(10)}${storti.join(String.fromCharCode(10))}');
  });

  test('REGOLA F: nessun ordine sigillato lascia una voce aperta', () {
    final conVociAperte = <String>[];
    var guardati = 0;
    for (final ordine in sigillati.keys) {
      final file = File('docs/ordini/ORDINE_${ordine}_MANIFESTO.md');
      if (!file.existsSync()) continue;
      guardati++;
      final aperte = marcatore(file.readAsStringSync(), 'VOCI_APERTE', ordine);
      if (aperte > 0) conVociAperte.add('$ordine con $aperte');
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 4.04: ordini con voci ancora aperte '
        '${conVociAperte.isEmpty ? "nessuno" : conVociAperte.join(", ")}');
    cardinaleMinimo(guardati, sigillati.length,
        cosa: 'manifesti interrogati sulle voci aperte',
        perche: 'Con un insieme vuoto la regola F sarebbe soddisfatta per '
            'assenza.');
    expect(conVociAperte, isEmpty,
        reason: 'questi ordini hanno ancora voci aperte, e per la REGOLA F '
            'non sono finiti: ${conVociAperte.join(", ")}');
  });

  // ===========================================================================
  // **IL SIGILLO DI TUTTI I MANIFESTI. Ordine DS voci 01 e 02, 17 settembre
  // 2026.**
  //
  // **Il fatto.** La mappa qui sopra guarda sei manifesti, da CG a CQ, e
  // nient'altro: ogni ordine venuto dopo CQ non era ne' guardato ne'
  // sigillato. E anche se ci fosse entrato, la prova contava le voci nella
  // sola forma `- **XX.NN**`, e i manifesti da DI in poi le scrivono come
  // intestazioni.
  //
  // **Cosa si prova adesso, per OGNI manifesto del repository**, scoperto a
  // esecuzione e non elencato a mano:
  //
  // 1. le voci lette nei suoi formati sono quelle scritte qui, cosi' un
  //    manifesto chiuso che perde una voce fa cadere la prova;
  // 2. `VOCI_TOTALI` dice il numero delle voci lette;
  // 3. i marcatori di stato sommano al totale.
  //
  // **Il numero sta qui e non si legge dal file**, per la ragione gia' scritta
  // sopra dall'ordine CQ: se qualcuno cancellasse una voce e aggiustasse il
  // marcatore, i due coinciderebbero.
  //
  // **DS.02, IL DEBITO NON SI RIFORMA.** Un manifesto nuovo che non sta in
  // questa tavola, o che non ha la sua guardia, fa cadere questa prova **al
  // primo giro della suite**. E la suite gira nello sbarramento, prima di ogni
  // consegna, e sul cancello gratuito di GitHub a ogni spinta: non si arriva a
  // una build senza passarci. **Finora nessuna strada reggeva perche' il
  // controllo era un elenco scritto a mano**, e un elenco scritto a mano non
  // vede cio' che non contiene: adesso l'elenco lo fa il filesystem.
  // ===========================================================================

  /// Le voci di ogni manifesto, misurate il 17 settembre 2026 col lettore dei
  /// formati. **Il 61 di CQ, scritto a mano dall'ordine CQ, e' stato misurato
  /// qui: 61 voci vere.**
  const vociMisurate = <String, int>{
    'AC': 12,
    'AD': 5,
    'AE': 5,
    'AF': 5,
    'AG': 4,
    'AH': 2,
    'AI': 4,
    'AJ': 5,
    'AK': 5,
    'AL': 9,
    'AM': 5,
    'AN': 9,
    'AO': 8,
    'AP': 9,
    'AQ': 6,
    'AR': 11,
    'AS': 12,
    'AT': 11,
    'AU': 14,
    'AV': 5,
    'AW': 2,
    'AX': 16,
    'AZ': 16,
    'BA': 3,
    'BB': 14,
    'BC': 7,
    'BD': 9,
    'BE': 10,
    'BF': 7,
    'BG': 8,
    'BH': 9,
    'BI': 6,
    'BJ': 3,
    'BK': 7,
    'BL': 3,
    'BM': 5,
    'BN': 10,
    'BO': 14,
    'BP': 6,
    'BQ': 6,
    'BR': 3,
    'BS': 4,
    'BT': 3,
    'BU': 5,
    'BV': 6,
    'BX': 11,
    'BY': 5,
    'BZ': 9,
    'CA': 7,
    'CB': 5,
    'CC': 9,
    'CD': 2,
    'CE': 17,
    'CF': 18,
    'CG': 16,
    'CH': 12,
    'CI': 8,
    'CL': 9,
    'CM': 11,
    'CN': 16,
    'CODEMAGIC1': 6,
    'CODEMAGIC2': 8,
    'CO': 20,
    'CP': 10,
    'CQ': 61,
    'CW': 10,
    'CY': 5,
    'CZ': 16,
    'DA': 6,
    'DB': 13,
    'DC': 21,
    'DD': 15,
    'DE': 16,
    'DF': 0,
    'DG': 9,
    'DI': 17,
    'DJ': 11,
    'DK': 8,
    'DL': 15,
    'DM': 7,
    'DN': 11,
    'DO': 15,
    'DP': 6,
    'DQ': 16,
    'DR': 11,
    'DS': 9,
    'DT': 27,
    'DU': 14,
    'DV': 12,
    'DW': 8,
    'DX': 6,
    'DY': 3,
    'DZ': 4,
    'EA': 22,
    'EB': 8,
    'P': 40,
    'S': 29,
    'T': 2,
    'U': 3,
  };

  /// **I MANIFESTI CHE DICHIARANO IL FALSO, elencati e NON corretti.**
  ///
  /// L'ordine DS voce 01: *"se una guardia nuova scopre che un manifesto
  /// dichiara il falso, cioe' che i suoi marcatori non corrispondono alle sue
  /// voci, FERMATI e riportalo. E' una decisione del fondatore, non una riga da
  /// correggere."* Qui non si accetta il falso: si pretende che **resti
  /// esattamente quello riportato**. Se il fondatore decide e il manifesto
  /// cambia, questa prova cade e la riga si toglie; se il falso si allarga,
  /// cade lo stesso.
  const falsiInAttesaDelFondatore = <String, ({int lette, int dichiarate})>{
    // Voci nominate DD.01...DD.17: quindici hanno una sezione, DD.14 e DD.15
    // stanno solo nel marcatore QUALI_RESTANO. VOCI_TOTALI dice 16.
    'DD': (lette: 15, dichiarate: 16),
    // Undici intestazioni DN.00...DN.10, tutte CHIUSA, e VOCI_TOTALI dice 10.
    // DN.00 e' scritta come DL.00, che il manifesto DL conta.
    'DN': (lette: 11, dichiarate: 10),
  };

  /// **I MANIFESTI CHE NON ENUMERANO LE VOCI**: il conto non si puo' rifare
  /// dal file, e non e' un falso. Si pretende che restino cosi'.
  const nonEnumerati = <String, int>{'DF': 7};

  /// **I MANIFESTI CON LE CHIUSE IMPLICITE**: portano il totale e le aperte,
  /// non le chiuse. Il formato di quei giorni, e si impara: le chiuse sono il
  /// resto, e non possono essere meno di zero.
  const chiuseImplicite = {'DE', 'DF'};

  /// **I FILE CHE PORTANO I MARCATORI SENZA ESSERE UN MANIFESTO**, ciascuno col
  /// suo perche'. Un manifesto nuovo con un nome diverso non passa di qui: il
  /// suo nome non e' dichiarato.
  const testiDOrdineConIMarcatori = <String, String>{
    'ORDINE_DB_MEDITAZIONE.md':
        'e il testo dell ordine DB archiviato, e il suo VOCI_TOTALI viene '
            'dall ordine; il manifesto di DB e ORDINE_DB_MANIFESTO.md',
  };

  test('DS.01: OGNI MANIFESTO E COPERTO DAL SIGILLO, e il sigillo dice il vero',
      () {
    final manifesti = manifestiDelRepository();
    cardinaleMinimo(manifesti.length, 90,
        cosa: 'manifesti in docs/ordini',
        perche: 'Se la cartella non si legge, il sigillo sarebbe verde su '
            'niente.');
    final storti = <String>[];
    final scoperti = <String>[];
    final visti = <String>{};
    for (final f in manifesti) {
      final m = leggiManifesto(nomeDi(f), f.readAsStringSync());
      visti.add(m.sigla);
      final attese = vociMisurate[m.sigla];
      if (attese == null) {
        scoperti.add(m.sigla);
        continue;
      }
      final falso = falsiInAttesaDelFondatore[m.sigla];
      final senzaVoci = nonEnumerati[m.sigla];
      if (m.voci.length != attese) {
        storti.add('${m.sigla}: voci lette ${m.voci.length}, misurate '
            '$attese');
      }
      if (m.totali == null) {
        storti.add('${m.sigla}: non porta VOCI_TOTALI');
        continue;
      }
      if (falso != null) {
        if (m.voci.length != falso.lette || m.totali != falso.dichiarate) {
          storti.add('${m.sigla}: il falso riportato al fondatore e cambiato, '
              'lette ${m.voci.length} e dichiarate ${m.totali}: se e stato '
              'deciso, togli la riga');
        }
      } else if (senzaVoci != null) {
        if (m.voci.isNotEmpty || m.totali != senzaVoci) {
          storti.add('${m.sigla}: il manifesto non enumerato e cambiato');
        }
      } else if (m.totali != m.voci.length) {
        storti.add('${m.sigla}: VOCI_TOTALI ${m.totali}, voci lette '
            '${m.voci.length}');
      }
      final somma = m.stati.values.fold<int>(0, (a, b) => a + b);
      if (chiuseImplicite.contains(m.sigla)) {
        if (m.marcatori.containsKey('VOCI_CHIUSE') || somma > m.totali!) {
          storti.add('${m.sigla}: le chiuse implicite non tornano');
        }
      } else if (somma != m.totali) {
        storti.add('${m.sigla}: i marcatori di stato sommano $somma, il '
            'totale e ${m.totali}');
      }
    }
    final spariti = vociMisurate.keys.where((k) => !visti.contains(k));
    // ignore: avoid_print
    print('ORDINE DS VOCE 01: manifesti ${manifesti.length}, nel sigillo '
        '${manifesti.length - scoperti.length}, scoperti ${scoperti.length}, '
        'CQ con ${vociMisurate['CQ']} voci vere, falsi riportati '
        '${falsiInAttesaDelFondatore.keys.join(" e ")}');
    expect(scoperti, isEmpty,
        reason: 'questi manifesti non sono nel sigillo: aggiungili a '
            'vociMisurate col numero misurato, non letto dal file: $scoperti');
    expect(spariti, isEmpty,
        reason: 'questi manifesti sono nel sigillo e non esistono piu: '
            '${spariti.toList()}');
    expect(storti, isEmpty, reason: storti.join('\n'));
  });

  test('DS.01: OGNI MANIFESTO HA LA SUA GUARDIA', () {
    final senza = <String>[];
    var guardati = 0;
    for (final f in manifestiDelRepository()) {
      final sigla = siglaDi(nomeDi(f));
      guardati++;
      final guardia =
          File('test/ordine_${sigla.toLowerCase()}_guard_test.dart');
      if (!guardia.existsSync()) {
        senza.add(sigla);
      } else if (!guardia.readAsStringSync().contains(nomeDi(f))) {
        senza.add('$sigla (la guardia non nomina ${nomeDi(f)})');
      }
    }
    // ignore: avoid_print
    print('ORDINE DS VOCE 01: manifesti con la guardia '
        '${guardati - senza.length} su $guardati');
    cardinaleMinimo(guardati, 90,
        cosa: 'manifesti a cui chiedere la guardia',
        perche: 'Su una cartella vuota nessuna guardia mancherebbe.');
    expect(senza, isEmpty,
        reason: 'questi manifesti non hanno la guardia propria in '
            'test/ordine_<sigla>_guard_test.dart: $senza');
  });

  test('DS.02: NESSUN FILE PORTA I MARCATORI SENZA DIRE CHE COSA E', () {
    // Un manifesto con un nome diverso da ORDINE_XX_MANIFESTO.md sfuggirebbe
    // alle due prove sopra. Qui lo si prende dal marcatore.
    final ignoti = <String>[];
    for (final f in Directory('docs/ordini').listSync().whereType<File>()) {
      final nome = nomeDi(f);
      if (!nome.endsWith('.md') || nome.endsWith('_MANIFESTO.md')) continue;
      if (!RegExp(r'^VOCI_TOTALI:', multiLine: true)
          .hasMatch(f.readAsStringSync())) {
        continue;
      }
      if (!testiDOrdineConIMarcatori.containsKey(nome)) ignoti.add(nome);
    }
    expect(ignoti, isEmpty,
        reason: 'questi file portano VOCI_TOTALI e non si chiamano '
            'ORDINE_XX_MANIFESTO.md: se sono manifesti vanno rinominati, se '
            'sono testi d ordine vanno dichiarati: $ignoti');
  });

  test('DS.01: IL LETTORE LEGGE TUTTI E DUE I FORMATI', () {
    // La prova sul formato che l'ordine chiede: un manifesto scritto con le
    // intestazioni e uno scritto con l'elenco, montati qui.
    final colleIntestazioni = leggiManifesto(
        'ORDINE_XA_MANIFESTO.md',
        '# ORDINE XA\n\nVOCI_TOTALI: 4\nVOCI_CHIUSE: 4\n\n'
            '## XA.01, LA PRIMA. CHIUSA\n\ntesto che cita la XA.07\n\n'
            '## XA.02, XA.03 e XA.04, TRE INSIEME. CHIUSA\n');
    final collElenco = leggiManifesto(
        'ORDINE_XB_MANIFESTO.md',
        '# ORDINE XB\n\nVOCI_TOTALI: 3\nVOCI_APERTE: 1\nVOCI_CHIUSE: 2\n\n'
            '- **XB.01** la prima. **CHIUSA.**\n'
            '- **XB.02** la seconda, che parla della XB.09. **CHIUSA.**\n'
            '- **XB.03** la terza. **APERTA.**\n');
    expect(colleIntestazioni.voci, {'01', '02', '03', '04'},
        reason: 'il formato "## XX.NN" non si legge: o conta zero, o conta '
            'la citazione nella prosa');
    expect(collElenco.voci, {'01', '02', '03'},
        reason: 'il formato "- **XX.NN**" non si legge');
    expect(colleIntestazioni.totali, 4);
    expect(collElenco.stati.values.fold<int>(0, (a, b) => a + b), 3);
  });
}
