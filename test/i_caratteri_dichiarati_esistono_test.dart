import 'dart:io';

import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// I CARATTERI CHE IL CODICE CHIEDE DEVONO ESISTERE NEL PACCHETTO. Ordine BM.
///
/// **Il difetto che l'ha fatta nascere.** `natal_wheel.dart` e
/// `natal_chart_reveal.dart` disegnavano i glifi dei pianeti e dei segni con
/// la famiglia `NotoSansSymbols`, che nel `pubspec.yaml` non era dichiarata e
/// in `assets/fonts` non esisteva. Flutter, davanti a una famiglia che non
/// conosce, non fallisce: ripiega in silenzio sul carattere di sistema. Su
/// Android quei simboli di solito ci sono; su iOS non era mai stato provato, e
/// il rischio era il rettangolo vuoto al posto del pianeta nella schermata
/// identitaria dell'app.
///
/// **I glifi si prendono DAL CODICE, non da una lista copiata qui.** I segni
/// vengono da `Zodiac.values`, i corpi da `CorpoCeleste.values`, e i tre punti
/// che l'API delle effemeridi puo' restituire in piu' (Nodo Nord, Chirone,
/// Lilith) si leggono dal sorgente del client. Cosi' un glifo aggiunto domani
/// entra da solo in questa prova, invece di restare fuori finche' qualcuno non
/// si ricorda di aggiornarla.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const famigliaDeiSimboli = 'NotoSansSymbols';

  /// Il glifo del Sole non e' in quella famiglia, e non e' un taglio nostro:
  /// non c'e' nemmeno nel font intero, verificato sul file scaricato. Per
  /// questo i due punti che lo mostrano lo DISEGNANO a mano, e questa prova
  /// non lo pretende dal carattere.
  const sole = '☉';

  /// I tre punti in piu' che `FreeAstroClient` puo' restituire, letti dal suo
  /// sorgente: sono glifi veri che finiscono nella ruota natale, e nessun
  /// censimento a memoria li avrebbe trovati.
  Set<String> glifiDelClient() {
    final s = File('lib/services/free_astro_client.dart').readAsStringSync();
    final blocco = RegExp(r'_planetIt = \{(.*?)\};', dotAll: true).firstMatch(s);
    expect(blocco, isNotNull,
        reason: 'la tabella _planetIt non si trova piu\' nel client: se ha '
            'cambiato forma, questa prova va aggiornata invece di restare '
            'verde su un elenco vuoto');
    final trovati = RegExp(r"\('[^']+', '([^']+)'\)")
        .allMatches(blocco!.group(1)!)
        .map((m) => m.group(1)!)
        .toSet();
    expect(trovati.length, greaterThanOrEqualTo(10),
        reason: 'dal client sono usciti solo ${trovati.length} glifi: la '
            'lettura del sorgente non sta funzionando');
    return trovati;
  }

  /// TUTTI i glifi che l'app puo' passare alla famiglia dei simboli.
  Set<String> glifiDaRendere() => {
        for (final z in Zodiac.values) z.symbol,
        for (final c in CorpoCeleste.values) c.glifo,
        ...glifiDelClient(),
      }..remove(sole);

  test('ogni famiglia citata in lib e\' dichiarata nel pubspec', () {
    // **BM.03, LA GUARDIA CHE IMPEDISCE IL PROSSIMO CARATTERE FANTASMA.**
    // Strutturale apposta: cade in qualunque ambiente e non dipende dal
    // dispositivo, come la guardia del tempo civile dell'ordine BL. Un
    // carattere che manca non fa rumore da nessuna parte, si vede soltanto,
    // e solo su certi telefoni.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final dichiarate = RegExp(r'^\s*- family:\s*(\S+)', multiLine: true)
        .allMatches(pubspec)
        .map((m) => m.group(1)!)
        .toSet();
    expect(dichiarate, isNotEmpty);

    final citate = <String, String>{};
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll(r'\', '/');
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final nudo = righe[i].trimLeft();
        if (nudo.startsWith('//')) continue;
        for (final m in RegExp(r"(?:fontFamily|family):\s*'([^']+)'")
            .allMatches(righe[i])) {
          citate['${m.group(1)}'] = '$percorso:${i + 1}';
        }
      }
      // **LE FAMIGLIE PASSATE PER POSIZIONE, e questo buco l'ha trovato la
      // prova del rosso.** La prima stesura guardava solo `fontFamily:` e
      // `family:` scritti per nome: iniettando un carattere inventato in
      // `sky_postcard.dart`, che passa la famiglia come argomento
      // POSIZIONALE a un suo aiutante, la guardia restava VERDE. Una guardia
      // cieca proprio dove il progetto scrive davvero non e' una guardia, e
      // la regola di casa dice di cambiare la grandezza misurata, mai la
      // soglia.
      //
      // Si cercano le funzioni che dichiarano un parametro `String family` e
      // si guardano i letterali delle loro chiamate. Si tengono solo quelli
      // che SOMIGLIANO a un nome di carattere, cioe' senza spazi e con
      // l'iniziale maiuscola: un titolo o una frase passata alla stessa
      // funzione non e' una famiglia e non deve diventare un falso allarme.
      final testo = righe.join('\n');
      for (final firma
          in RegExp(r'(\w+)\([^)]*String\s+family').allMatches(testo)) {
        final nome = firma.group(1)!;
        for (final chiamata
            in RegExp('$nome\\(([^;]{0,400}?)\\)').allMatches(testo)) {
          for (final lett
              in RegExp(r"'([A-Z][A-Za-z0-9]{3,})'").allMatches(chiamata.group(1)!)) {
            citate[lett.group(1)!] = '$percorso (per posizione a $nome)';
          }
        }
      }
    }
    expect(citate, isNotEmpty,
        reason: 'nessuna famiglia trovata in lib: la lettura non funziona e '
            'questa prova sarebbe verde per il motivo sbagliato');

    // **L'ECCEZIONE E' STATA TOLTA, NON AGGIORNATA. Ordine BT voce 01.**
    // `CormorantGaramond` era chiesta dal Sigillo d'Intenzione e non era nel
    // pacchetto: la deroga stava qui, scritta con la sua ragione e la sua
    // scadenza, in attesa che il fondatore guardasse le tre anteprime
    // dell'ordine BM voce 02. Il 27 agosto 2026, sulla build 2207, ha detto
    // "ok per la (b), chiudiamo BM.02", e la ruota adesso scrive in
    // EBGaramond, che il pacchetto dichiara.
    //
    // **Una deroga che sopravvive alla propria ragione e' il modo con cui i
    // caratteri fantasma tornano**: la ragione non c'e' piu', e la deroga se
    // ne va con lei.
    const inAttesaDiDecisione = <String, String>{};
    // ignore: avoid_print
    print('ORDINE BT VOCE 01: eccezioni dichiarate '
        '${inAttesaDiDecisione.length}, famiglie citate dal codice '
        '${citate.length}');
    expect(inAttesaDiDecisione, isEmpty,
        reason: 'e\' tornata una deroga: ${inAttesaDiDecisione.keys.toList()}. '
            'Ogni eccezione qui dentro e\' un carattere che sul telefono di '
            'qualcuno diventa un altro carattere, e va chiusa invece che '
            'rinnovata');
    final fantasmi = <String>[];
    citate.forEach((famiglia, dove) {
      if (dichiarate.contains(famiglia)) return;
      if (inAttesaDiDecisione.containsKey(famiglia)) return;
      fantasmi.add('$famiglia ($dove)');
    });
    expect(fantasmi, isEmpty,
        reason: 'queste famiglie sono chieste dal codice e non esistono nel '
            'pacchetto: Flutter non fallisce, ripiega in silenzio sul '
            'carattere di sistema, e il difetto si vede solo sul telefono di '
            'chi non ce l\'ha.\n${fantasmi.join('\n')}');
  });

  test('il file del carattere dei simboli esiste ed e\' quello dichiarato',
      () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final blocco = RegExp(
            '- family:\\s*$famigliaDeiSimboli\\s*\\n\\s*fonts:\\s*\\n\\s*- asset:\\s*(\\S+)')
        .firstMatch(pubspec);
    expect(blocco, isNotNull,
        reason: 'il pubspec non dichiara piu\' la famiglia '
            '$famigliaDeiSimboli: i glifi tornerebbero al carattere di '
            'sistema');
    final file = File(blocco!.group(1)!);
    expect(file.existsSync(), isTrue,
        reason: 'il pubspec dichiara ${file.path}, che non esiste');
    expect(file.lengthSync(), greaterThan(1000),
        reason: 'il file del carattere e\' troppo piccolo per contenere dei '
            'glifi veri');
  });

  testWidgets('ogni glifo dei simboli si rende, e nessuno e\' un rettangolo',
      (tester) async {
    // Il carattere si carica dal file DICHIARATO NEL PUBSPEC, non da un
    // percorso battuto qui: se domani il file cambia nome, la prova segue.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final percorso = RegExp(
            '- family:\\s*$famigliaDeiSimboli\\s*\\n\\s*fonts:\\s*\\n\\s*- asset:\\s*(\\S+)')
        .firstMatch(pubspec)!
        .group(1)!;
    final bytes = File(percorso).readAsBytesSync();
    final loader = FontLoader(famigliaDeiSimboli)
      ..addFont(Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)));
    await loader.load();

    double larghezzaDi(String glifo, {String? famiglia}) {
      final tp = TextPainter(
        text: TextSpan(
            text: glifo,
            style: TextStyle(fontFamily: famiglia, fontSize: 40)),
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.width;
    }

    final glifi = glifiDaRendere();
    expect(glifi.length, greaterThanOrEqualTo(24),
        reason: 'i glifi censiti sono solo ${glifi.length}: il censimento non '
            'sta leggendo le fonti vere');

    final muti = <String>[];
    final ugualiAlRipiego = <String>[];
    for (final g in glifi) {
      final conFont = larghezzaDi(g, famiglia: famigliaDeiSimboli);
      final ripiego = larghezzaDi(g);
      if (conFont <= 0) muti.add('$g U+${g.runes.first.toRadixString(16)}');
      if (conFont == ripiego) {
        ugualiAlRipiego.add('$g U+${g.runes.first.toRadixString(16)}');
      }
    }
    // ignore: avoid_print
    print('BM.01 MISURA: ${glifi.length} glifi passati alla famiglia '
        '$famigliaDeiSimboli, muti ${muti.length}, uguali al ripiego '
        '${ugualiAlRipiego.length}');
    expect(muti, isEmpty,
        reason: 'questi glifi non hanno larghezza: sono resi come niente o '
            'come rettangolo vuoto.\n${muti.join('\n')}');
    expect(ugualiAlRipiego, isEmpty,
        reason: 'questi glifi hanno la stessa larghezza del ripiego, cioe\' il '
            'carattere dichiarato non li sta rendendo lui.\n'
            '${ugualiAlRipiego.join('\n')}');
  });

  test('il Sole NON si pretende dal carattere, perche\' li\' non c\'e\'', () {
    // Non e' un'eccezione comoda: e' un fatto misurato sul font intero, e i
    // due punti che mostrano il Sole lo disegnano a mano da prima di
    // quest'ordine. Se domani qualcuno togliesse il disegno e lo passasse al
    // carattere, questa riga direbbe dove guardare.
    // La grandezza misurata e' che ognuno dei due punti abbia un ramo
    // DEDICATO al Sole prima di passare il glifo al carattere. Cercare il
    // solo carattere '☉' non basterebbe: la ruota lo riconosce dall'id.
    const rami = {
      'lib/design_system/components/natal_wheel.dart': "p.id == 'sun'",
      'lib/features/onboarding/natal_chart_reveal.dart': "glyph == '☉'",
    };
    rami.forEach((percorso, ramo) {
      final s = File(percorso).readAsStringSync();
      expect(s.contains(ramo), isTrue,
          reason: '$percorso non ha piu\' il ramo "$ramo": se ha smesso di '
              'disegnare il Sole a mano, adesso lo sta chiedendo a un '
              'carattere che non ce l\'ha, e uscirebbe un rettangolo vuoto');
    });
    expect(sole, '☉');
  });
}
