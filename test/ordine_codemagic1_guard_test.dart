// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE CODEMAGIC1.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le quattro voci non hanno uno stato terminale.
///
/// **E sorveglia la cosa che l'ordine chiede di non far tornare**: che il
/// cancello gratuito e il cancello a pagamento facciano la **stessa domanda**.
/// La build 2264 e' caduta al passo dodici su un rosso che il cancello
/// gratuito non guardava: `verde.yml` girava `flutter test`, `codemagic.yaml`
/// girava `bash tool/sbarramento.sh`. Se qualcuno li fa divergere di nuovo,
/// questa prova cade prima che se ne accorga una macchina a pagamento.
void main() {
  final manifesto = File('docs/ordini/ORDINE_CODEMAGIC1_MANIFESTO.md');
  final verde = File('.github/workflows/verde.yml');
  final codemagic = File('codemagic.yaml');

  const quante = 6;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  List<String> vociDi(String testo) {
    final voci = <String>[];
    final buffer = StringBuffer();
    for (final r in testo.split('\n')) {
      if (RegExp(r'^- \*\*CODEMAGIC1\.\d\d\*\*').hasMatch(r)) {
        if (buffer.isNotEmpty) voci.add(buffer.toString());
        buffer.clear();
        buffer.writeln(r);
      } else if (buffer.isNotEmpty) {
        if (r.startsWith('  ')) {
          buffer.writeln(r);
        } else {
          voci.add(buffer.toString());
          buffer.clear();
        }
      }
    }
    if (buffer.isNotEmpty) voci.add(buffer.toString());
    return voci;
  }

  test('il manifesto esiste e porta tutte e quattro le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'CODEMAGIC1.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('i marcatori dicono il vero, contati sulle voci', () {
    final testo = manifesto.readAsStringSync();
    final voci = vociDi(testo);
    expect(voci, hasLength(quante));
    var aperte = 0, attesa = 0, premessa = 0, chiuse = 0;
    for (final v in voci) {
      if (v.contains('APERTA')) {
        aperte++;
      } else if (v.contains('FERMATA IN ATTESA DI DECISIONE')) {
        attesa++;
      } else if (v.contains('FERMATA SU PREMESSA FALSA')) {
        premessa++;
      } else if (v.contains('CHIUSA')) {
        chiuse++;
      }
    }
    print('ORDINE CODEMAGIC1: voci osservate ${voci.length}, chiuse $chiuse');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(aperte + attesa + premessa + chiuse, quante);
  });

  /// Le righe che non sono commenti. **Riscritta con l'ordine CODEMAGIC2**:
  /// dopo che lo sbarramento e' uscito da `codemagic.yaml`, questa guardia
  /// restava verde perche' trovava il comando nel commento che racconta
  /// perche' e' uscito.
  String codiceDi(File f) => f
      .readAsLinesSync()
      .where((r) => !r.trimLeft().startsWith('#'))
      .join('\n');

  test('IL CANCELLO GRATIS E QUELLO A PAGAMENTO FANNO LA STESSA DOMANDA', () {
    // **La grandezza misurata e' il comando**, non il nome del passo: due
    // cancelli sono lo stesso cancello solo se eseguono lo stesso comando.
    //
    // **E DALL'ORDINE CODEMAGIC2 LA DOMANDA SI FA UNA VOLTA SOLA.** La build
    // iOS del 17 settembre 2026 e' morta al tetto dei sessanta minuti dopo
    // 46 minuti di sbarramento rifatto sul Mac. Adesso lo sbarramento gira
    // soltanto su GitHub, e Codemagic ne legge il verdetto su quel commit:
    // la domanda resta la stessa perche' e' letteralmente la stessa risposta.
    expect(verde.existsSync(), isTrue);
    expect(codemagic.existsSync(), isTrue);
    final g = codiceDi(verde);
    final c = codiceDi(codemagic);
    const comando = 'bash tool/sbarramento.sh';
    expect(c.contains('bash tool/il_cancello_ha_detto_verde.sh'), isTrue,
        reason: 'codemagic.yaml non legge piu il verdetto del cancello '
            'gratuito: costruirebbe senza sapere se il commit e verde');
    expect(g.contains(comando), isTrue,
        reason: 'il cancello gratuito non esegue lo sbarramento. E il buco da '
            'cui e passata la caduta della build 2264: un rosso che li non si '
            'vede si paga mezz ora di mac mini per scoprirlo');
    // **E NON SI TORNA A `flutter test` DA SOLO**: il comando piu' debole non
    // deve restare come passo a se', perche' un verde su di lui e' un verde
    // che non dice quello che sembra dire.
    final righeDeboli = [
      for (final r in g.split('\n'))
        if (RegExp(r'^\s*run:\s*flutter test\s*$').hasMatch(r)) r,
    ];
    expect(righeDeboli, isEmpty,
        reason: 'il cancello gratuito esegue ancora `flutter test` come passo '
            'a se: $righeDeboli');
  });

  test('IL CANCELLO INSTALLA LE DIPENDENZE DEL SERVER', () {
    // Ordine CODEMAGIC1 voce 03: senza `functions/node_modules` lo
    // sbarramento salta la seconda suite e lo dice, e in ogni build fino alla
    // 2264 l'ha saltata. **Dall'ordine CODEMAGIC2 lo sbarramento gira solo
    // su GitHub**, e le dipendenze servono solo li'.
    final g = codiceDi(verde);
    expect(g.contains('npm ci'), isTrue,
        reason: 'il cancello gratuito non installa le dipendenze del server');
    expect(File('functions/package-lock.json').existsSync(), isTrue,
        reason: 'npm ci pretende il lock: senza, le due macchine possono '
            'installare versioni diverse');
  });

  test('IL VERDETTO DEL CANCELLO SI LEGGE SENZA CREDENZIALI', () {
    // Ordine CODEMAGIC1 voce 05. **La grandezza misurata e' la catena
    // intera**, non la sola presenza dello script: un verdetto pubblicato
    // serve solo se il registro arriva fino a li' e se il passo gira proprio
    // quando il cancello cade.
    final verdetto = File('tool/il_verdetto_del_cancello.sh');
    expect(verdetto.existsSync(), isTrue,
        reason: 'manca lo strumento che porta il verdetto nelle annotazioni');
    expect(verdetto.readAsStringSync(), contains('::error'),
        reason: 'lo strumento non scrive nessuna annotazione, e un verdetto '
            'che resta nel registro non si legge senza credenziali');
    final g = verde.readAsStringSync();
    expect(g, contains('tool/il_verdetto_del_cancello.sh'),
        reason: 'il cancello gratuito non pubblica il suo verdetto: i '
            'registri delle azioni vogliono un accesso, le annotazioni no');
    expect(g, contains('if: failure()'),
        reason: 'il verdetto si pubblica quando il cancello cade, e quel '
            'passo senza condizione non girerebbe mai dopo un rosso');
    // **E IL REGISTRO DEVE ARRIVARCI.** Senza `pipefail` il `tee` darebbe il
    // proprio zero al posto dell'esito del cancello, e un rosso passerebbe
    // per verde: e' il guasto peggiore dei due, perche' non si vede.
    expect(g, contains('set -o pipefail'),
        reason: 'lo sbarramento finisce in una pipe senza pipefail: l esito '
            'letto sarebbe quello di tee, non quello del cancello');
  });

  test('NESSUNA MACCHINA SCEGLIE DA SE\' COME IL CANCELLO LEGGE', () {
    // Ordine CODEMAGIC1 voce 06. **Il fatto, misurato accendendo
    // GITHUB_ACTIONS=true su questa macchina**: `flutter test` cambia rapporto
    // da solo, e su GitHub stampa le prove in un'altra forma. Lo sbarramento
    // legge le righe "00:03 +10 -1: nome [E]", quindi con l'altro rapporto
    // **non leggeva nessun nome**: il corredo risultava aver montato zero
    // schermate e nessuna caduta arrivava al confronto coi rossi accettati.
    //
    // **La grandezza misurata e' che nessuna chiamata resti senza rapporto**,
    // non che ci sia scritta una certa parola: e' l'invariante che tiene, ed
    // e' quella che si rompe se qualcuno domani aggiunge una terza suite.
    final cancello = File('tool/sbarramento.sh');
    expect(cancello.existsSync(), isTrue);
    final righe = cancello
        .readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('#'))
        .where((r) => RegExp(r'(^|[;&|]|\s)flutter test\b').hasMatch(r))
        .toList();
    // Il cardinale minimo: due chiamate, la suite intera e il corredo. Senza
    // questa riga, su un file che non ne avesse nessuna la prova sarebbe
    // verde senza aver guardato niente.
    expect(righe.length, greaterThanOrEqualTo(2),
        reason: 'lo sbarramento non chiama flutter test: righe $righe');
    final senzaRapporto = [
      for (final r in righe)
        if (!RegExp(r'(-r|--reporter)[= ]').hasMatch(r)) r,
    ];
    expect(senzaRapporto, isEmpty,
        reason: 'queste chiamate lasciano scegliere il rapporto alla '
            'macchina, e su GitHub il cancello legge un altra lingua e non '
            'vede nessun nome: $senzaRapporto');
  });

  test('l\'ordine CODEMAGIC1 non e\' finito finche\' una voce resta aperta',
      () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e rossa apposta: '
            'torna verde quando le quattro voci hanno uno stato terminale');
  });
}
