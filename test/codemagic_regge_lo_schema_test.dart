import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

/// IL FILE DELLA BUILD IOS REGGE LO SCHEMA DI CODEMAGIC.
///
/// **Perche' questa prova esiste, e quanto e' costata la sua assenza.** Il 6
/// agosto 2026 `codemagic.yaml` e' stato scritto senza poterlo validare, ed e'
/// stato rifiutato con due errori: `integrations` messa dentro `environment`,
/// dove non e' ammessa, e `auth: integration` che pretende un `integrations`
/// che non c'era. Per saperlo e' servito un giro fra Mauro e il sito, con
/// degli screenshot. Il prossimo errore deve costare dieci secondi.
///
/// **Lo schema e' quello ufficiale**, scaricato da codemagic.io e versionato in
/// `test/schemi/`: la provenienza e i limiti stanno accanto, in PROVENIENZA.md.
/// Non si scarica dalla rete durante la prova, perche' una prova che dipende
/// dalla linea non dice piu' se il difetto e' nel file o nel collegamento.
///
/// **Cosa questa prova NON dice.** Non e' un validatore JSON Schema completo:
/// implementa il sottoinsieme che serve a prendere la classe di errori che ci
/// e' costata il giro, cioe' le chiavi non ammesse, i valori fuori
/// dall'elenco, i tipi sbagliati e le chiavi obbligatorie mancanti. Non valuta
/// `pattern`, `minLength` ne' le condizioni. E soprattutto: **il verde qui dice
/// che la struttura e' giusta, non che la build riuscira'.**
void main() {
  final schemaFile = File('test/schemi/codemagic-schema.json');
  final yamlFile = File('codemagic.yaml');

  late Map<String, dynamic> schema;

  setUpAll(() {
    schema = jsonDecode(schemaFile.readAsStringSync()) as Map<String, dynamic>;
  });

  /// Converte il YAML in strutture Dart semplici, che e' cio' che il
  /// confronto con lo schema sa leggere.
  dynamic semplifica(dynamic n) {
    if (n is YamlMap) {
      return {for (final e in n.entries) e.key.toString(): semplifica(e.value)};
    }
    if (n is YamlList) return n.map(semplifica).toList();
    return n;
  }

  /// Scioglie un `$ref` interno allo schema.
  Map<String, dynamic> risolvi(Map<String, dynamic> nodo) {
    var d = nodo;
    var giri = 0;
    while (d.containsKey(r'$ref') && giri++ < 20) {
      final rif = d[r'$ref'] as String;
      final pezzi = rif.replaceFirst('#/', '').split('/');
      dynamic corrente = schema;
      for (final p in pezzi) {
        corrente = (corrente as Map<String, dynamic>)[p];
      }
      d = corrente as Map<String, dynamic>;
    }
    return d;
  }

  /// I guasti trovati confrontando [valore] con [nodo], col percorso per
  /// dire DOVE stanno: un errore senza percorso, in un file di duecento
  /// righe, e' quasi inutile quanto nessun errore.
  List<String> guasti(dynamic valore, Map<String, dynamic> nodo, String dove) {
    final d = risolvi(nodo);
    final trovati = <String>[];

    // **`allOf` DEVE VALERE TUTTO INSIEME, e non gestirlo mi ha reso cieco.**
    // Lo schema di Codemagic avvolge quasi ogni sezione importante in
    // `allOf: [{$ref: ...}]`: `environment`, `publishing` e altre. Saltandolo,
    // la validazione non entrava mai in quelle sezioni, e il difetto vero,
    // l'integrazione messa dentro `environment`, passava indisturbato.
    final tutti = d['allOf'] as List<dynamic>?;
    if (tutti != null) {
      final trovati = <String>[];
      for (final r in tutti) {
        trovati.addAll(guasti(valore, r as Map<String, dynamic>, dove));
      }
      return trovati;
    }

    // Un ramo alternativo basta che passi: si prova ciascuno e si tiene il
    // verdetto piu' clemente, altrimenti ogni `anyOf` darebbe un falso rosso.
    for (final chiave in ['anyOf', 'oneOf']) {
      final rami = d[chiave] as List<dynamic>?;
      if (rami == null) continue;
      final esiti = rami
          .map((r) => guasti(valore, r as Map<String, dynamic>, dove))
          .toList();
      if (esiti.any((e) => e.isEmpty)) return const [];
      return ['$dove: nessuna delle forme ammesse combacia'];
    }

    final elenco = d['enum'] as List<dynamic>?;
    if (elenco != null && !elenco.contains(valore)) {
      return ['$dove: "$valore" non e\' fra i valori ammessi $elenco'];
    }

    // **`pattern` VA VALUTATO, o i rami permissivi assorbono tutto.** Lo
    // schema descrive molte chiavi come "o una variabile tipo $NOME, oppure il
    // valore vero": il primo ramo e' una stringa con un pattern che pretende il
    // dollaro iniziale. Ignorando il pattern, quel ramo accettava qualunque
    // testo e `instance_type: mac_mini_m9` passava.
    if (valore is String) {
      final schemaPattern = d['pattern'] as String?;
      if (schemaPattern != null && !RegExp(schemaPattern).hasMatch(valore)) {
        return ['$dove: "$valore" non ha la forma richiesta'];
      }
      final minimo = d['minLength'] as int?;
      if (minimo != null && valore.length < minimo) {
        return ['$dove: "$valore" e\' piu\' corto del minimo di $minimo'];
      }
    }

    final tipo = d['type'];
    if (tipo == 'object' || d.containsKey('properties')) {
      if (valore is! Map) {
        return ['$dove: qui ci vuole un blocco di chiavi, non "$valore"'];
      }
      final proprieta = (d['properties'] as Map<String, dynamic>?) ?? const {};
      // **`additionalProperties` HA DUE FACCE, e la seconda mi era sfuggita.**
      //
      // Quando vale `false` significa che una chiave in piu' non e' tollerata:
      // e' cosi' che Codemagic ha risposto "extra fields not permitted".
      //
      // Quando invece e' un BLOCCO, significa il contrario: le chiavi sono
      // libere e ogni valore va misurato su quel blocco. E' il caso di
      // `workflows`, dove il nome del workflow lo scegliamo noi e il valore e'
      // un Workflow. Trattando solo il caso booleano, la validazione non
      // scendeva mai dentro il workflow: quattro rossi su sei non scattavano, e
      // la prova sarebbe stata verde per cecita' proprio sul difetto vero.
      final extra = d['additionalProperties'];
      if (extra == false) {
        for (final k in valore.keys) {
          if (!proprieta.containsKey(k)) {
            trovati.add('$dove/$k: chiave non ammessa qui. Ammesse: '
                '${proprieta.keys.toList()}');
          }
        }
      } else if (extra is Map<String, dynamic>) {
        valore.forEach((k, v) {
          if (!proprieta.containsKey(k)) {
            trovati.addAll(guasti(v, extra, '$dove/$k'));
          }
        });
      }
      for (final r in (d['required'] as List<dynamic>? ?? const [])) {
        if (!valore.containsKey(r)) {
          trovati.add('$dove/$r: chiave obbligatoria mancante');
        }
      }
      valore.forEach((k, v) {
        final sotto = proprieta[k];
        if (sotto is Map<String, dynamic>) {
          trovati.addAll(guasti(v, sotto, '$dove/$k'));
        }
      });
      return trovati;
    }

    if (tipo == 'array') {
      if (valore is! List) {
        return ['$dove: qui ci vuole un elenco, non "$valore"'];
      }
      final voci = d['items'];
      if (voci is Map<String, dynamic>) {
        for (var i = 0; i < valore.length; i++) {
          trovati.addAll(guasti(valore[i], voci, '$dove[$i]'));
        }
      }
      return trovati;
    }

    if (tipo == 'string' && valore is! String) {
      trovati.add('$dove: qui ci vuole del testo, non "$valore"');
    }
    if (tipo == 'integer' && valore is! int) {
      trovati.add('$dove: qui ci vuole un numero intero, non "$valore"');
    }
    return trovati;
  }

  List<String> validaIlFile() {
    final doc = semplifica(loadYaml(yamlFile.readAsStringSync()));
    return guasti(doc, schema, 'codemagic.yaml');
  }

  test('lo schema e la sua provenienza stanno nel repository', () {
    expect(schemaFile.existsSync(), isTrue);
    expect(File('test/schemi/PROVENIENZA.md').existsSync(), isTrue,
        reason: 'Uno schema senza la sua provenienza e\' un file che nessuno '
            'sa piu\' da dove viene ne\' quando aggiornare.');
  });

  test('codemagic.yaml regge lo schema, per intero', () {
    final trovati = validaIlFile();
    expect(trovati, isEmpty,
        reason: 'Il file non passerebbe la validazione di Codemagic:\n'
            '${trovati.join('\n')}');
  });

  group('la prova sa dire di no, e si verifica ogni volta che gira', () {
    // **QUESTI SONO I ROSSI, ESEGUITI A OGNI GIRO.** Un validatore scritto in
    // casa puo' essere verde perche' non guarda: qui si guastano apposta delle
    // copie in memoria e si pretende che ciascuna venga rifiutata. Il primo
    // caso e' il difetto vero che Codemagic ha segnalato il 6 agosto 2026.
    Map<String, dynamic> copia() => jsonDecode(
            jsonEncode(semplifica(loadYaml(yamlFile.readAsStringSync()))))
        as Map<String, dynamic>;

    Map<String, dynamic> ilWorkflow(Map<String, dynamic> d) =>
        (d['workflows'] as Map<String, dynamic>).values.first
            as Map<String, dynamic>;

    void cadeSu(String nome, void Function(Map<String, dynamic>) guasta) {
      final d = copia();
      guasta(d);
      final trovati = guasti(d, schema, 'codemagic.yaml');
      expect(trovati, isNotEmpty,
          reason: 'Guastando "$nome" la validazione resta verde: questa prova '
              'e\' cieca su quel difetto, e non protegge niente.');
    }

    test('l\'integrazione rimessa dentro environment', () {
      // E' l'errore vero: "extra fields not permitted".
      cadeSu('integrations dentro environment', (d) {
        final w = ilWorkflow(d);
        w.remove('integrations');
        (w['environment'] as Map<String, dynamic>)['app_store_connect'] =
            'esoteric_asc';
      });
    });

    test('una chiave inventata nel workflow', () {
      cadeSu('chiave inventata', (d) => ilWorkflow(d)['inventata'] = 1);
    });

    test('una macchina che non esiste', () {
      cadeSu('instance_type',
          (d) => ilWorkflow(d)['instance_type'] = 'mac_mini_m9');
    });

    test('un metodo di autenticazione fuori dall\'elenco', () {
      cadeSu('auth', (d) {
        final p = ilWorkflow(d)['publishing'] as Map<String, dynamic>;
        (p['app_store_connect'] as Map<String, dynamic>)['auth'] = 'chiave';
      });
    });

    test('una chiave inventata dentro uno script', () {
      cadeSu('script', (d) {
        final s = (ilWorkflow(d)['scripts'] as List<dynamic>).first
            as Map<String, dynamic>;
        s['inventata'] = 1;
      });
    });

    test('una sezione di pubblicazione che non esiste', () {
      cadeSu('publishing', (d) {
        (ilWorkflow(d)['publishing'] as Map<String, dynamic>)['telegram'] = {};
      });
    });
  });

  group('le cose che lo schema NON puo\' sapere', () {
    // Lo schema valida la forma, non i nostri dati: qui si tiene fermo cio'
    // che e' stato verificato a mano su Codemagic e su App Store Connect, e
    // che una struttura giusta con dentro un nome sbagliato non tradirebbe.
    late Map<String, dynamic> w;

    setUp(() {
      final doc = semplifica(loadYaml(yamlFile.readAsStringSync()))
          as Map<String, dynamic>;
      w = (doc['workflows'] as Map<String, dynamic>)['ios-testflight']
          as Map<String, dynamic>;
    });

    test('l\'integrazione si chiama come su Codemagic', () {
      expect((w['integrations'] as Map)['app_store_connect'], 'esoteric_asc',
          reason: 'Il nome dell\'integrazione e\' stato verificato su '
              'Codemagic: se qui cambia, la firma non trova la chiave.');
    });

    test('il pacchetto e l\'app sono quelli veri', () {
      final vars = (w['environment'] as Map)['vars'] as Map;
      expect(vars['BUNDLE_ID'], 'com.esotericircle.esotericCircle');
      expect(vars['APP_STORE_APPLE_ID'], 6798775360);
    });

    test('la firma non torna a chiedere file che nessuno ha caricato', () {
      // **QUESTA E' LA PRIMA BUILD FALLITA, TENUTA FERMA.** Il file era
      // formalmente corretto e la prova sullo schema era verde, ma la firma
      // era chiesta con `ios_signing`, che per documentazione SCARICA i file
      // di firma gia' caricati e non li crea. Nel portale di Apple non c'era
      // niente, quindi:
      //   No matching profiles found for bundle identifier ... "app_store"
      // Se qualcuno rimette quella sezione, la firma torna a cercare invece
      // di creare, e questa prova lo dice prima della build.
      expect((w['environment'] as Map).containsKey('ios_signing'), isFalse,
          reason: 'Torna `ios_signing`: quella sezione scarica i file di firma '
              'gia\' caricati, e nel Developer Portal non ce ne sono. La '
              'creazione si chiede con `fetch-signing-files --create`.');
    });

    test('i quattro passi della firma ci sono, e in quest\'ordine', () {
      // L'ordine non e' estetico: senza portachiavi non si aggiunge il
      // certificato, senza certificato non si applicano i profili.
      final passi = (w['scripts'] as List)
          .map((s) => (s as Map)['script'].toString())
          .toList();
      int dove(String frammento) =>
          passi.indexWhere((s) => s.contains(frammento));

      final portachiavi = dove('keychain initialize');
      final creazione = dove('fetch-signing-files');
      final certificato = dove('keychain add-certificates');
      final profili = dove('xcode-project use-profiles');

      for (final p in {
        'keychain initialize': portachiavi,
        'app-store-connect fetch-signing-files': creazione,
        'keychain add-certificates': certificato,
        'xcode-project use-profiles': profili,
      }.entries) {
        expect(p.value, greaterThanOrEqualTo(0),
            reason: 'Manca il passo `${p.key}`: senza, la firma non si '
                'completa e la build muore prima di compilare.');
      }
      expect(portachiavi < creazione, isTrue,
          reason: 'Il portachiavi va inizializzato prima di chiedere i file.');
      expect(creazione < certificato, isTrue,
          reason: 'Il certificato si aggiunge dopo averlo ottenuto.');
      expect(certificato < profili, isTrue,
          reason: 'I profili si applicano dopo che il certificato e\' nel '
              'portachiavi.');
    });

    test('la creazione e\' chiesta, e per il tipo giusto', () {
      final passi = (w['scripts'] as List)
          .map((s) => (s as Map)['script'].toString())
          .join('\n');
      expect(RegExp(r'--create\b').hasMatch(passi), isTrue,
          reason: 'Manca `--create`: il comando cercherebbe soltanto, e in un '
              'portale vuoto non trova niente.');
      expect(passi.contains('--type IOS_APP_STORE'), isTrue,
          reason: 'Il tipo di profilo non e\' IOS_APP_STORE: un profilo di '
              'sviluppo non carica su TestFlight.');
    });

    test('la firma viene dopo i pod, non prima', () {
      // Lo script dei pod puo' lanciare `flutter build ios --config-only` per
      // generare il Podfile mancante, e quella riscrittura del progetto Xcode
      // cancellerebbe le impostazioni di firma appena scritte.
      final passi = (w['scripts'] as List)
          .map((s) => (s as Map)['script'].toString())
          .toList();
      final pod = passi.indexWhere((s) => s.contains('pod install'));
      final firma = passi.indexWhere((s) => s.contains('keychain initialize'));
      expect(pod, greaterThanOrEqualTo(0));
      expect(pod < firma, isTrue,
          reason: 'La firma precede i pod: se i pod rigenerano il progetto '
              'Xcode, le impostazioni di firma vengono cancellate.');
    });

    test('il gruppo della chiave privata e\' dichiarato', () {
      // Un gruppo non importato non arriva al workflow: la chiave sarebbe
      // vuota e il comando si fermerebbe con "Cannot save Signing Certificates
      // without certificate private key".
      final gruppi = (w['environment'] as Map)['groups'] as List;
      expect(gruppi.contains('code-signing'), isTrue,
          reason: 'Manca il gruppo `code-signing`: CERTIFICATE_PRIVATE_KEY non '
              'arriverebbe, e senza quella chiave il certificato non si crea '
              'ne\' si riusa.');
    });

    test('la build non alza il numero da sola', () {
      // Il contatore e' condiviso con Android e si alza in `pubspec.yaml`: se
      // la macchina lo alzasse per conto suo, la prossima consegna Android
      // partirebbe da un numero gia' bruciato.
      final passi = (w['scripts'] as List)
          .map((s) => (s as Map)['script'].toString())
          .join('\n');
      expect(passi.contains('get-latest-app-store-build-number'), isFalse,
          reason: 'Il workflow calcola il numero di build da solo: quel '
              'contatore e\' condiviso con Android e si alza in pubspec.yaml.');
    });

    test('la cache tiene l\'SDK, cosi\' non si riscarica ogni volta', () {
      // **Ordine BZ voce 02, rettifica del 28 agosto 2026.** Il passo che
      // installa gli strumenti scaricava OGNI VOLTA i 2.211.439.713 byte
      // dell\'archivio di Flutter, con un tetto interno di 300 secondi: su
      // tre costruzioni osservate dal fondatore ha impiegato 49 secondi, 51
      // secondi e un\'ora e venti. Senza cache la costruzione dipende dal
      // riuscire a scaricare due giga a ogni giro.
      final cache = w['cache'] as Map<String, dynamic>?;
      expect(cache, isNotNull,
          reason: 'il workflow non dichiara nessuna cache: gli strumenti si '
              'riscaricano a ogni costruzione');
      final percorsi = (cache!['cache_paths'] as List).cast<String>();
      // ignore: avoid_print
      print('ORDINE BZ VOCE 2: percorsi in cache $percorsi');
      expect(percorsi, contains(r'$FLUTTER_ROOT'),
          reason: 'l\'SDK di Flutter non e\' in cache, ed e\' lui i due giga');
      expect(percorsi.length, greaterThanOrEqualTo(2),
          reason: 'in cache c\'e\' solo l\'SDK: anche i pacchetti Dart e i pod '
              'si riscaricano ogni volta');
    });
    test('nessuna credenziale dentro il file', () {
      // **SI GUARDA IL CONTENUTO, NON I COMMENTI.** La prima stesura cercava
      // le parole vietate in tutto il testo e cadeva su ".p8", che nel file
      // compare in una riga di commento la quale dice, appunto, che il .p8 non
      // ci va: bocciare un file perche' spiega la propria regola e' una misura
      // che guarda la cosa sbagliata.
      final righe = yamlFile
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('#'))
          .join('\n');
      for (final vietato in [
        'BEGIN PRIVATE KEY',
        // La chiave privata del certificato di distribuzione: sta in una
        // variabile cifrata su Codemagic, e nel file non deve comparire mai.
        'BEGIN RSA PRIVATE KEY',
        '.p8',
        'issuer_id:',
        'key_id:',
        'api_key:',
      ]) {
        expect(righe.contains(vietato), isFalse,
            reason: 'Nel file compare "$vietato" fuori dai commenti: le '
                'credenziali stanno nell\'integrazione di Codemagic, non qui.');
      }
    });
  });
}
