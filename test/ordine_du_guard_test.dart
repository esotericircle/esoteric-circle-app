// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE DU, l'Arcano dell'Alba che diventa una scena.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le quattordici voci non hanno uno stato terminale.
///
/// **E sorveglia le due cose che quest'ordine non vuole far tornare**: una
/// scena senza scena, cioe' la schermata che monta le carte senza il fondo
/// stellato e senza Medora; e una seconda porta per il ventaglio, cioe' un
/// arco di dorsi scritto daccapo mentre quello della Stesa esiste, gira ed e'
/// gia' parametrico nel numero delle carte.
void main() {
  final manifesto = File('docs/ordini/ORDINE_DU_MANIFESTO.md');
  final schermata = File('lib/features/rituals/arcano_dell_alba_screen.dart');

  const quante = 14;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta tutte e quattordici le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'DU.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('**$voce**')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  test('i marcatori dicono il vero, contati sulle voci', () {
    final testo = manifesto.readAsStringSync().replaceAll('\r\n', '\n');
    final voci = <String>[];
    final buffer = StringBuffer();
    for (final r in testo.split('\n')) {
      if (RegExp(r'^- \*\*DU\.\d\d\*\*').hasMatch(r)) {
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

    expect(voci, hasLength(quante));
    var aperte = 0, attesa = 0, chiuse = 0;
    for (final v in voci) {
      if (v.contains('**APERTA**')) {
        aperte++;
      } else if (v.contains('**FERMATA IN ATTESA DI DECISIONE.**')) {
        attesa++;
      } else if (v.contains('**CHIUSA.**')) {
        chiuse++;
      }
    }
    print('ORDINE DU: voci osservate ${voci.length}, chiuse $chiuse, '
        'aperte $aperte, in attesa $attesa');
    expect(marcatore(testo, 'VOCI_TOTALI'), voci.length);
    expect(marcatore(testo, 'VOCI_APERTE'), aperte);
    expect(marcatore(testo, 'VOCI_CHIUSE'), chiuse);
    expect(marcatore(testo, 'VOCI_FERMATE_IN_ATTESA_DI_DECISIONE'), attesa);
    expect(aperte + attesa + chiuse, quante,
        reason: 'una voce senza uno stato ammesso non si conta');
  });

  test('LA SCENA E\' UNA SCENA: fondo stellato, Medora e il ventaglio', () {
    // DU.01, DU.04, DU.05. **La grandezza misurata e' che la schermata monti
    // le tre cose**, non che siano belle: la bellezza la guarda Mauro, la
    // presenza la guarda questa riga. Il fondo nero del compitino era proprio
    // l'assenza di `CosmosBackground`.
    expect(schermata.existsSync(), isTrue);
    final codice = schermata
        .readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    for (final pezzo in ['CosmosBackground', 'MedoraStage', 'StesaFan']) {
      expect(codice.contains(pezzo), isTrue,
          reason: 'l\'Arcano dell\'Alba non monta piu\' $pezzo: la scena '
              'torna il compitino su fondo nero dell\'ordine DT');
    }
  });

  test('NESSUNA SECONDA PORTA PER IL VENTAGLIO', () {
    // Il ventaglio e' uno solo, quello della Stesa, e l'Alba lo usa con
    // ventidue carte. Un arco scritto daccapo qui sarebbe la famiglia di
    // difetti che questo progetto paga di piu'.
    final fan = File('lib/features/tarot/stesa_fan.dart');
    expect(fan.existsSync(), isTrue);
    final usano = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (f.path.endsWith('stesa_fan.dart')) continue;
      if (f.readAsStringSync().contains('StesaFan(')) {
        usano.add(f.path.split(RegExp(r'[\\/]')).last);
      }
    }
    usano.sort();
    print('ORDINE DU: chi monta il ventaglio $usano');
    expect(usano, contains('arcano_dell_alba_screen.dart'));
    expect(usano, contains('stesa_tre_carte_screen.dart'));
  });

  test('l\'ordine DU non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e\' rossa apposta: '
            'torna verde quando le quattordici voci hanno uno stato '
            'terminale');
  });
}
