// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA GUARDIA DELL'ORDINE EL, l'Arcano dell'Alba che si apre alzando il sole.
///
/// **Nasce rossa per costruzione**, come le guardie degli ordini EJ ed EK:
/// l'ordine apre con la sua voce aperta, la prova che pretende zero voci
/// aperte cade subito e resta rossa finche' il lavoro non e' fatto e
/// provato sul Realme. Le voci chiuse le sorveglia
/// `ogni_voce_chiusa_porta_la_sua_prova_test.dart`, che pretende sotto
/// ciascuna la domanda del fondatore, la prova e la misura.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EL_MANIFESTO.md');

  // **Due voci**: la seconda, il Taglia che ricompone il mazzo, l'ha
  // aggiunta il fondatore in chat la sera del 24 settembre 2026.
  const quante = 2;

  int marcatore(String testo, String nome) {
    final trovato =
        RegExp('^$nome:\\s*(\\d+)\\s*\$', multiLine: true).firstMatch(testo);
    expect(trovato, isNotNull,
        reason: 'il manifesto non porta il marcatore $nome');
    return int.parse(trovato!.group(1)!);
  }

  test('il manifesto esiste e porta la sua voce', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    expect(testo.contains('## VOCE EL.01,'), isTrue,
        reason: 'la voce EL.01 non e\' nominata');
    expect(testo.contains('## VOCE EL.02,'), isTrue,
        reason: 'la voce EL.02, il Taglia, non e\' nominata');
  });

  test('ogni voce dichiara uno stato terminale, e i conti tornano', () {
    final testo = manifesto.readAsStringSync();
    final chiuse = marcatore(testo, 'VOCI_CHIUSE');
    final aperte = marcatore(testo, 'VOCI_APERTE');
    final dichiarate = marcatore(testo, 'VOCI_TOTALI');
    print('ORDINE EL: voci $dichiarate, chiuse $chiuse, aperte $aperte');
    expect(dichiarate, quante,
        reason: 'il manifesto dichiara $dichiarate voci e sono $quante');
    expect(chiuse + aperte, quante,
        reason: 'chiuse piu\' aperte fanno ${chiuse + aperte} e le voci sono '
            '$quante: un conto che non torna nasconde una voce senza stato');
    expect(aperte, 0,
        reason: 'restano $aperte voci aperte: l\'ordine non e\' chiuso');
  });

  test(
      'il vecchio ingresso, chi l\'ha tolto e la richiesta mancante sono '
      'dichiarati col commit, il file e la riga', () {
    // L'ordine lo pretende: "dichiara il commit, il file e la riga in cui
    // viveva", "dichiara nel rapporto perche' non e' stato fatto, con il
    // padre", e dove trovi una smentita "riporti lo scarto col file e la
    // riga".
    final testo = manifesto.readAsStringSync();
    const pretese = <String, String>{
      'il commit in cui il gesto era ancora vivo': '`8a19e6b8`',
      'il file in cui viveva': 'lib/features/rituals/dawn_rite_screen.dart',
      'le righe del trascinamento': '252-269',
      'le righe del pittore': '804-946',
      'il commit che l\'ha tolto, il padre': '`47b3c2be`',
      'le voci dell\'ordine DT col file e la riga':
          'ORDINE_DT_MANIFESTO.md`, righe 44-52',
      'la richiesta che sul ramo non si trova': 'non e\' scritta sul ramo',
    };
    final mancanti = [
      for (final p in pretese.entries)
        if (!testo.contains(p.value)) '${p.key} (${p.value})'
    ];
    // Il cardinale, su un elenco scritto a mano.
    expect(pretese.length, 7);
    expect(mancanti, isEmpty, reason: 'il manifesto non dichiara: $mancanti');
  });

  test(
      'la voce del Taglia porta le parole del fondatore, la sua guardia, la '
      'cecita\' trovata e la differenza col Mischia', () {
    // Ordine EL voce 02. La correzione del fondatore sta accanto alla sua
    // prima frase: senza, chi legge crederebbe che si sia rifatto il Mischia.
    final testo = manifesto.readAsStringSync();
    const pretese = <String, String>{
      'la richiesta del fondatore': 'il mazzo viene tagliato e poi dal mazzo '
          'le carte si ristendono',
      'la sua correzione': 'Scusa non Mischia. Ma "taglia"',
      'la guardia nuova': 'il_taglia_ricompone_il_mazzo_test.dart',
      'la cecita\' della prova del tavolo, col suo tempo': '1.550',
      'il padre della cecita\'': 'ordine EE voce 01',
      'il Taglia che si vede anche col movimento ridotto':
          'AnimationBehavior.preserve',
      'il Mischia lasciato com\'era, detto': 'Mischia resta com\'era',
    };
    final mancanti = [
      for (final p in pretese.entries)
        if (!testo.contains(p.value)) '${p.key} (${p.value})'
    ];
    expect(pretese.length, 7);
    expect(mancanti, isEmpty, reason: 'il manifesto non dichiara: $mancanti');
  });
}
