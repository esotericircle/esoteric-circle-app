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
  final manifesto =
      File('docs/ordini/ORDINE_CODEMAGIC1_MANIFESTO.md');
  final verde = File('.github/workflows/verde.yml');
  final codemagic = File('codemagic.yaml');

  const quante = 4;

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

  test('IL CANCELLO GRATIS E QUELLO A PAGAMENTO FANNO LA STESSA DOMANDA', () {
    // **La grandezza misurata e' il comando**, non il nome del passo: due
    // cancelli sono lo stesso cancello solo se eseguono lo stesso comando.
    expect(verde.existsSync(), isTrue);
    expect(codemagic.existsSync(), isTrue);
    final g = verde.readAsStringSync();
    final c = codemagic.readAsStringSync();
    const comando = 'bash tool/sbarramento.sh';
    expect(c.contains(comando), isTrue,
        reason: 'codemagic.yaml non esegue piu lo sbarramento: se il cancello '
            'a pagamento cambia, questa guardia va riscritta con lui');
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

  test('LE DUE MACCHINE INSTALLANO LE DIPENDENZE DEL SERVER', () {
    // Ordine CODEMAGIC1 voce 03: senza `functions/node_modules` lo
    // sbarramento salta la seconda suite e lo dice, e in ogni build fino alla
    // 2264 l'ha saltata.
    final g = verde.readAsStringSync();
    final c = codemagic.readAsStringSync();
    expect(g.contains('npm ci'), isTrue,
        reason: 'il cancello gratuito non installa le dipendenze del server');
    expect(c.contains('npm ci'), isTrue,
        reason: 'Codemagic non installa le dipendenze del server, e la '
            'seconda suite resta non guardata');
    expect(File('functions/package-lock.json').existsSync(), isTrue,
        reason: 'npm ci pretende il lock: senza, le due macchine possono '
            'installare versioni diverse');
  });

  test('l\'ordine CODEMAGIC1 non e\' finito finche\' una voce resta aperta',
      () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e rossa apposta: '
            'torna verde quando le quattro voci hanno uno stato terminale');
  });
}
