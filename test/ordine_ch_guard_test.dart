import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CH.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le dodici voci non hanno uno stato terminale.
///
/// **E sorveglia le cose che quest'ordine ha messo in piedi**, perche' un
/// ordine che si chiude senza guardie lascia in eredita' delle abitudini, e
/// un'abitudine si perde. Le tre che contano: la scelta dell'architettura
/// vive nel progetto e non nel comando, la consegna guarda dentro l'archivio
/// prima di caricarlo, e il registro dei rossi accettati non sopravvive alla
/// sua ragione.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CH_MANIFESTO.md');

  const quante = 12;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome, e senza marcatori '
            'nessuno puo\' leggerlo a macchina');
    return int.parse(trovato!.group(1)!);
  }

  const stati = <String, String>{
    'FERMATA SU PREMESSA FALSA': 'VOCI_FERMATE_SU_PREMESSA_FALSA',
    'FERMATA IN ATTESA DI DECISIONE': 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE',
    'FERMATA SU DECISIONE DEL FONDATORE':
        'VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE',
    'CHIUSA': 'VOCI_CHIUSE',
    'APERTA': 'VOCI_APERTE',
  };

  test('il manifesto esiste e nomina tutte e dodici le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'docs/ordini/ORDINE_CH_MANIFESTO.md non esiste');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 0; i < quante; i++) {
      final voce = 'CH.${(i + 1).toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty,
        reason: 'il manifesto non nomina queste voci: $mancanti');
  });

  test('ogni voce ha uno stato ammesso e i sei marcatori dicono il vero', () {
    final testo = manifesto.readAsStringSync();
    final righe = testo
        .split('\n')
        .where((r) => RegExp(r'^- \*\*CH\.\d\d\*\*').hasMatch(r))
        .toList();
    expect(righe.length, quante,
        reason: 'le righe di voce sono ${righe.length} invece di $quante');

    final conti = <String, int>{for (final v in stati.values) v: 0};
    final senzaStato = <String>[];
    for (final r in righe) {
      final quale = stati.keys.firstWhere(
          (s) => r.contains('**$s.**') || r.contains('**$s**'),
          orElse: () => '');
      if (quale.isEmpty) {
        senzaStato.add(r.substring(0, r.length < 40 ? r.length : 40));
        continue;
      }
      conti[stati[quale]!] = conti[stati[quale]!]! + 1;
    }
    expect(senzaStato, isEmpty,
        reason: 'queste voci non dichiarano nessuno dei cinque stati '
            'ammessi: $senzaStato');

    expect(marcatore(testo, 'VOCI_TOTALI'), quante);
    for (final voce in conti.entries) {
      expect(marcatore(testo, voce.key), voce.value,
          reason: 'il marcatore ${voce.key} dice un numero diverso da quello '
              'che si conta sulle righe, cioe\' ${voce.value}');
    }
    final riassunto = conti.entries.map((e) => '${e.key} ${e.value}').join(', ');
    // ignore: avoid_print
    print('ORDINE CH: voci $quante, $riassunto');
  });

  test('le premesse hanno la loro riga, con un esito dichiarato', () {
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= 17; i++) {
      final p = 'P${i.toString().padLeft(2, '0')}';
      if (!testo.contains('| $p |')) mancanti.add(p);
    }
    expect(mancanti, isEmpty,
        reason: 'queste premesse non hanno una riga nella tavola: $mancanti. '
            'Una premessa senza esito e\' una premessa non verificata.');
  });

  // --- CIO' CHE QUEST'ORDINE HA MESSO IN PIEDI, E CHE NON DEVE TORNARE ---

  test('CH.06: il progetto dichiara UNA architettura, e la scelta sta li\'',
      () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final m = RegExp(r'abiFilters\s*\+=\s*listOf\(([^)]*)\)').firstMatch(gradle);
    expect(m, isNotNull,
        reason: 'in build.gradle.kts non c\'e\' nessun abiFilters: la scelta '
            'dell\'architettura e\' tornata a dipendere dal comando, ed e\' '
            'esattamente il difetto della 2216');
    final dichiarati = RegExp('"([^"]+)"')
        .allMatches(m!.group(1)!)
        .map((x) => x.group(1)!)
        .toList();
    expect(dichiarati, ['arm64-v8a'],
        reason: 'il progetto dichiara $dichiarati invece della sola '
            'arm64-v8a. La decisione del fondatore del 31 agosto 2026, messo '
            'davanti alle due strade, e\' stata "B": i 32 bit escono sul '
            'serio. Se cambia, la cambia lui.');

    // **LA SECONDA SERRATURA.** Il file stesso dichiara che abiFilters
    // governa cio' che si COMPILA e non cio' che si COPIA: le librerie dei
    // plugin arrivano gia' compilate dentro gli AAR, ed e' per questo che
    // nella 2216 armeabi-v7a e' rimasta con cinque librerie dentro.
    expect(gradle.contains('"lib/armeabi-v7a/**"'), isTrue,
        reason: 'manca l\'esclusione di lib/armeabi-v7a dal confezionamento: '
            'con la sola abiFilters le librerie dei plugin a 32 bit tornano '
            'nell\'archivio, ed e\' misurato, e\' successo su x86_64');
  });

  test('CH.07: la consegna guarda DENTRO l\'archivio prima di caricare', () {
    expect(File('tool/ispeziona_archivio.py').existsSync(), isTrue,
        reason: 'l\'ispezione dell\'archivio non esiste piu\'');
    final righe = File('tool/consegna.py').readAsLinesSync();
    final iIspezione =
        righe.indexWhere((r) => r.contains('ispeziona_archivio.ispeziona('));
    final iCarico = righe.indexWhere((r) => r.contains("print('carico...')"));
    expect(iIspezione, greaterThan(-1),
        reason: 'tool/consegna.py non chiama piu\' l\'ispezione: un archivio '
            'monco tornerebbe a partire senza che nessuno lo apra');
    expect(iCarico, greaterThan(-1),
        reason: 'la riga che annuncia il caricamento non c\'e\' piu\': questa '
            'prova starebbe misurando un file che non esiste');
    expect(iIspezione, lessThan(iCarico),
        reason: 'l\'ispezione sta DOPO il caricamento, quindi guarda un '
            'archivio gia\' partito: il difetto della 2216 e\' stato trovato '
            'dopo che era sui telefoni, ed e\' esattamente cio\' che non deve '
            'ripetersi');
  });

  test('CH.08 e CH.09: il peso e il comando li scrive la consegna', () {
    final testo = File('tool/consegna.py').readAsStringSync();
    expect(testo.contains('if False'), isFalse,
        reason: 'il codice morto nella forma "if False" e\' tornato in '
            'tool/consegna.py');

    final righe = testo.split('\n');
    final iPeso =
        righe.indexWhere((r) => r.contains('peso = os.path.getsize('));
    final iScritto =
        righe.indexWhere((r) => r.contains("reg['peso_archivio_byte'] = peso"));
    final iComando =
        righe.indexWhere((r) => r.contains("reg['comando_di_build'] ="));
    expect(iPeso, greaterThan(-1), reason: 'il peso non si calcola piu\'');
    expect(iScritto, greaterThan(-1),
        reason: 'il registro non riceve piu\' il peso dalla consegna, e '
            'tornerebbe a essere giusto solo quando qualcuno se lo ricorda: '
            'ha portato lo stesso numero per cinque consegne di fila');
    expect(iComando, greaterThan(-1),
        reason: 'il registro non riceve piu\' il comando di build, e una '
            'build costruita in modo diverso tornerebbe a uscire senza che '
            'nessuno se ne accorga');

    // **LA VARIABILE DEVE ESSERE ANCORA VIVA.** Se fra il calcolo e la
    // scrittura si aprisse una funzione nuova, `peso` non sarebbe piu' in
    // portata e il registro riceverebbe un numero preso da un'altra parte.
    final inMezzo = righe
        .sublist(iPeso + 1, iScritto)
        .where((r) => r.startsWith('def '))
        .toList();
    expect(inMezzo, isEmpty,
        reason: 'fra il calcolo del peso e la sua scrittura si e\' aperta '
            'una funzione: $inMezzo');
  });

  test('CH.04: lo sbarramento FERMA sulle righe di troppo, non avvisa', () {
    final sbarramento = File('tool/sbarramento.sh').readAsStringSync();
    expect(sbarramento.contains('RIGHE DI TROPPO'), isTrue,
        reason: 'lo sbarramento non nomina piu\' le righe di troppo del '
            'registro dei rossi accettati');
    expect(sbarramento.contains('AVVISO: nel registro'), isFalse,
        reason: 'il controllo e\' tornato a essere un avviso, e un avviso non '
            'ferma niente: quel registro e\' l\'unico posto in cui un difetto '
            'puo\' essere messo a tacere legalmente');

    // E il controllo sta PRIMA del bivio, cioe' gira anche a suite verde: era
    // il buco vero, perche' nel ramo verde non veniva eseguito affatto.
    final righe = sbarramento.split('\n');
    final iControllo = righe.indexWhere((r) => r.contains('if [ -n "\$DI_TROPPO" ]'));
    final iVerde =
        righe.indexWhere((r) => r.contains('if [ "\$ESITO" -eq 0 ]'));
    expect(iControllo, greaterThan(-1));
    expect(iVerde, greaterThan(-1));
    expect(iControllo, lessThan(iVerde),
        reason: 'il controllo delle righe di troppo sta dopo il bivio del '
            'verde, quindi con la suite tutta verde non gira: e\' il caso in '
            'cui una riga vecchia si riconosce meglio');
  });

  test('CH.05: la regola del ramo unico sta dove Code la legge', () {
    const regola = 'claude/esoteric-circle-master-order-e798aj';
    for (final f in ['CLAUDE.md', 'docs/ordini/RIPRESA.md']) {
      final testo = File(f).readAsStringSync();
      expect(testo.contains(regola), isTrue,
          reason: '$f non nomina il ramo canonico: una regola che vive solo '
              'negli ordini e\' una regola che una sessione puo\' non aprire '
              'mai');
      expect(testo.contains('nessun altro ramo si crea'), isTrue,
          reason: '$f nomina il ramo ma non dice che gli altri non si creano, '
              'che e\' la meta\' che serve');
    }
  });

  test('CH.12: un foglio solo per le distribuzioni che aspettano il PC', () {
    final foglio = File('docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md');
    expect(foglio.existsSync(), isTrue,
        reason: 'il foglio unico delle distribuzioni non esiste');
    expect(File('docs/ordini/ISTRUZIONI_CG_15_LAPIDI.md').existsSync(), isFalse,
        reason: 'il foglio vecchio delle lapidi e\' ancora accanto al nuovo: '
            'due fogli per lo stesso PC sono due verita\' su cosa manca');
    final testo = foglio.readAsStringSync();
    // **CIO' CHE IL FOGLIO DEVE SAPER FARE**, cioe' i quattro punti che
    // l'ordine chiede: portare la cartella alla testa nuova, le funzioni una
    // per una, cosa smette di essere finto, e cosa fare se un comando muore.
    for (final pezzo in [
      'git pull --ff-only',
      'firebase deploy --only functions:',
      'Cosa smette di essere finto',
      'SE UN COMANDO MUORE',
    ]) {
      expect(testo.contains(pezzo), isTrue,
          reason: 'il foglio non porta "$pezzo", che e\' uno dei quattro '
              'punti che l\'ordine chiede');
    }
  });

  test('l\'ordine CH non e\' finito finche\' una voce resta aperta', () {
    final testo = manifesto.readAsStringSync();
    final aperte = marcatore(testo, 'VOCI_APERTE');
    // ignore: avoid_print
    print('ORDINE CH: voci ancora aperte $aperte');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: **questa prova e\' rossa per '
            'legge di consegna** finche\' tutte e dodici non hanno uno stato '
            'terminale');
  });
}
