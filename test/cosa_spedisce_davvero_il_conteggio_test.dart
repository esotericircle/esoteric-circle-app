// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/misura/misura_del_ritorno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **COSA SPEDISCE DAVVERO IL CONTEGGIO.** Ordine EI voce 07, 23 settembre
/// 2026, che riapre la voce EE.12.
///
/// ## LO SCARTO SULLA SIGLA, DICHIARATO
///
/// L'ordine la chiama EE.12; **il codice che ha tolto l'interruttore dichiara
/// ordine EA voce 12**, in `privacy_e_permessi_screen.dart:127` e in
/// `consensi_della_registrazione.dart:44`. La cosa da provare e' la stessa, il
/// padre no.
///
/// ## COSA MANCAVA, VISTO CHE LE GUARDIE C'ERANO
///
/// `la_misura_del_ritorno` gia' prova che la frase e l'interruttore non vivano
/// piu' in `lib` e che il conteggio parta senza chiedere niente. **Quello che
/// non c'era era il file apribile**: l'elenco, in una pagina sola, di **cosa
/// esce davvero dal telefono**, accanto a cosa la schermata promette che esca.
///
/// E' la differenza che conta per una promessa sulla privacy: la schermata
/// dice *"cinque gesti in numeri per giorno [...] senza nessun identificativo
/// del telefono o tuo"*, e questa prova mette quella frase accanto agli eventi
/// veri che il codice sa spedire.
void main() {
  test('gli eventi che il conteggio sa spedire sono cinque, e sono quelli', () {
    final eventi = EventoDelRitorno.values;
    print('ORDINE EI VOCE 07: eventi del conteggio ${eventi.length}');
    // **Il cardinale, e qui e' il numero esatto**: la schermata promette
    // *cinque* gesti, e se un domani ne nascesse un sesto senza che nessuno
    // aggiorni quella frase, la promessa diventerebbe falsa.
    expect(eventi.length, 5,
        reason: 'il conteggio sa spedire ${eventi.length} eventi e la '
            'schermata ne promette cinque: la promessa sulla privacy non '
            'corrisponde piu\' a cio\' che esce dal telefono');
  });

  test('nessun evento porta con se\' un identificativo', () {
    // **La promessa piu' pesante della schermata.** Un evento che portasse un
    // identificativo del telefono, dell'installazione o della persona
    // renderebbe falsa la frase *"senza nessun identificativo"*, che e'
    // scritta a video e nella policy.
    const vietate = [
      'deviceId',
      'device_id',
      'installationId',
      'installation_id',
      'userId',
      'user_id',
      'uid',
      'androidId',
      'idfa',
      'advertisingId',
      'email',
    ];
    // **I COMMENTI NON SI GUARDANO, ed e' una correzione mia.** La prima
    // stesura leggeva il sorgente intero e cadeva su `uid`, che compare due
    // volte in `misura_del_ritorno.dart`: **dentro due commenti che
    // dichiarano che quel legame e' stato tolto**. Una prova che accusa il
    // codice per aver spiegato cosa non fa piu' insegna a cancellare le
    // spiegazioni, che e' il contrario di quello che serve.
    var codice = '';
    for (final p in const [
      'lib/core/misura/misura_del_ritorno.dart',
      'lib/core/misura/registro_del_ritorno.dart',
    ]) {
      for (final r in File(p).readAsLinesSync()) {
        final t = r.trim();
        if (t.startsWith('//') || t.startsWith('*')) continue;
        codice += '$r\n';
      }
    }
    final trovate = [
      for (final v in vietate)
        if (RegExp('\\b$v\\b').hasMatch(codice)) v
    ];
    expect(trovate, isEmpty,
        reason: 'il conteggio nomina questi identificativi: $trovate, e la '
            'schermata promette che non ne esca nessuno');
  });

  test('la frase e l\'interruttore non vivono piu\' in nessun file di lib', () {
    // **La stessa pretesa di `la_misura_del_ritorno`, tenuta qui apposta.**
    // Questa e' la voce che il fondatore ha riaperto: la prova che la chiude
    // deve poter cadere da sola, senza dipendere da un'altra prova che un
    // giorno potrebbe cambiare mestiere.
    final file = sorgentiDiLib();
    var guardati = 0;
    final colpe = <String>[];
    for (final f in file) {
      guardati++;
      final testo = f.readAsStringSync();
      // Si cerca nelle STRINGHE e nei nomi, non nei commenti: i due commenti
      // che dichiarano la rimozione nominano la frase apposta, ed e' giusto
      // che restino.
      final righe = testo.split('\n');
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i].trim();
        if (r.startsWith('//') || r.startsWith('///') || r.startsWith('*')) {
          continue;
        }
        if (r.contains('Conta i gesti, non') ||
            r.contains('InterruttoreDellaMisura')) {
          colpe.add('${f.path}:${i + 1}');
        }
      }
    }
    print('ORDINE EI VOCE 07: file di lib guardati $guardati');
    expect(guardati, greaterThan(100),
        reason: 'questa prova ha guardato solo $guardati file di lib: o si '
            'sono spostati, o la porta comune non li trova piu\'');
    expect(colpe, isEmpty,
        reason: 'la frase o l\'interruttore vivono ancora qui: $colpe');
  });

  test('la prova della voce EI.07 resta scritta su disco', () {
    final schermata =
        File('lib/features/settings/privacy_e_permessi_screen.dart')
            .readAsStringSync();
    final b = StringBuffer()
      ..writeln('IL CONTEGGIO ANONIMO: COSA PROMETTE E COSA SPEDISCE')
      ..writeln('Ordine EI voce 07, che riapre la voce EE.12.')
      ..writeln()
      ..writeln('SCARTO DICHIARATO: l\'ordine la chiama EE.12, il codice che '
          'ha tolto l\'interruttore dichiara ORDINE EA VOCE 12.')
      ..writeln()
      ..writeln('--- CIO\' CHE IL CONTEGGIO SA SPEDIRE, dal codice:')
      ..writeln();
    for (final e in EventoDelRitorno.values) {
      b.writeln('    ${e.name}');
    }
    b
      ..writeln()
      ..writeln('    In tutto: ${EventoDelRitorno.values.length} eventi, '
          'numeri per giorno, nessun identificativo.')
      ..writeln()
      ..writeln('--- CIO\' CHE LA SCHERMATA PROMETTE ALLA PERSONA:')
      ..writeln();
    final promessa = RegExp(
            r"key: const Key\('cosa_contiamo'\),\s*\n\s*'(.*?)',\s*\n\s*style:",
            dotAll: true)
        .firstMatch(schermata)
        ?.group(1);
    b
      ..writeln(
          '    ${promessa?.replaceAll(RegExp(r"'\s*\n\s*'"), '') ?? "(la frase non si e' potuta leggere dal sorgente)"}')
      ..writeln()
      ..writeln('--- E NON C\'E\' NESSUN SELETTORE:')
      ..writeln('    la frase "Conta i gesti, non me" e il suo interruttore '
          'non vivono in nessun file di lib fuori dai due commenti che ne '
          'dichiarano la rimozione.');

    final cartella = Directory('docs/collaudo/EI')..createSync(recursive: true);
    final f = File('${cartella.path}/cosa_spedisce_il_conteggio.txt')
      ..writeAsStringSync(b.toString());
    expect(f.lengthSync(), greaterThan(500));
  });
}
