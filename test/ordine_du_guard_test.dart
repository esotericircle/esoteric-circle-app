// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE DU, l'Arcano dell'Alba che diventa una scena.
///
/// **Non e' una promessa, e' una prova che non passa.** Legge il manifesto e
/// resta rossa finche' le quattordici voci non hanno uno stato terminale.
///
/// **E sorveglia le tre cose che quest'ordine non vuole far tornare**: una
/// scena senza scena, cioe' la schermata che monta le carte senza il fondo
/// stellato; il ventaglio della Stesa e l'avatar di Medora dentro l'Alba, che
/// il fondatore ha tolti il 17 settembre 2026 dopo averli visti; e un ventaglio
/// riscritto daccapo dentro la scena nuova, mentre quello della Stesa esiste e
/// resta della Stesa.
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

  /// Il codice della schermata, senza le righe di commento: una guardia che
  /// legge anche i commenti si conferma da sola con le parole che ho appena
  /// scritto io.
  String codiceDella(File f) => f
      .readAsLinesSync()
      .where((r) => !r.trimLeft().startsWith('//'))
      .join('\n');

  test('LA SCENA E\' UNA SCENA: fondo stellato e il tavolo dei ventidue', () {
    // DU.01 e DU.05. **La grandezza misurata e' che la schermata monti le due
    // cose**, non che siano belle: la bellezza la guarda Mauro, la presenza la
    // guarda questa riga. Il fondo nero del compitino era proprio l'assenza di
    // `CosmosBackground`.
    expect(schermata.existsSync(), isTrue);
    final codice = codiceDella(schermata);
    for (final pezzo in ['CosmosBackground', 'TavoloDeiVentidue']) {
      expect(codice.contains(pezzo), isTrue,
          reason: 'l\'Arcano dell\'Alba non monta piu\' $pezzo: la scena '
              'torna il compitino su fondo nero dell\'ordine DT');
    }
  });

  test('NESSUN AVATAR E NESSUN VENTAGLIO NELL\'ALBA', () {
    // **DU.04 e DU.05 dopo la correzione di rotta del 17 settembre 2026.**
    // Mauro ha tolto l'avatar di Medora e ha respinto il ventaglio, che era
    // identico a quello della Stesa. Questa riga tiene fuori le due cose che
    // tornerebbero da sole: la prima stesura di quest'ordine le montava
    // entrambe, e senza una guardia il ripensamento durerebbe un ordine.
    final codice = codiceDella(schermata);
    for (final pezzo in ['MedoraStage', 'StesaFan', 'Protoface']) {
      expect(codice.contains(pezzo), isFalse,
          reason: 'l\'Arcano dell\'Alba monta $pezzo, che il fondatore ha '
              'tolto dalla scena');
    }
  });

  test('IL VENTAGLIO DELLA STESA RESTA DELLA STESA', () {
    // Il ventaglio e' uno solo e ha un solo padrone. Prima della correzione
    // questa riga pretendeva che l'Alba lo montasse: adesso pretende che non
    // lo monti nessun altro, cosi' ne' l'Alba ne' una terza schermata se lo
    // riprendono senza che si veda.
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
    expect(usano, ['stesa_tre_carte_screen.dart']);
  });

  test('IL TAVOLO NON E\' UNA SECONDA PORTA PER IL VENTAGLIO', () {
    // Il tavolo e' una scena nuova, chiesta da Mauro, e nasce con l'obbligo
    // di non rifare quello che esiste: non deve importare ne' ridisegnare il
    // ventaglio della Stesa.
    final tavolo = File('lib/features/rituals/tavolo_dei_ventidue.dart');
    expect(tavolo.existsSync(), isTrue,
        reason: 'la scena nuova dell\'Alba non esiste');
    final codice = codiceDella(tavolo);
    expect(codice.contains('stesa_fan.dart'), isFalse);
    expect(codice.contains('StesaFan'), isFalse);
  });

  test('l\'ordine DU non e\' finito finche\' una voce resta aperta', () {
    final aperte = marcatore(manifesto.readAsStringSync(), 'VOCI_APERTE');
    expect(aperte, 0,
        reason: 'restano $aperte voci APERTE. Questa riga e\' rossa apposta: '
            'torna verde quando le quattordici voci hanno uno stato '
            'terminale');
  });
}
