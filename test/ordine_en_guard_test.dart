// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'le_voci_aperte_dicono_cosa_aspettano.dart';

/// LA GUARDIA DELL'ORDINE EN, il LIVE piu' svelto, i Maestri che si
/// conoscono e due decisioni sul catalogo.
///
/// **Nasce rossa per costruzione**, come le guardie degli ordini EI, EJ, EK
/// ed EM: l'ordine apre con dodici voci aperte su dodici, la prova che
/// pretende zero voci aperte cade subito e resta rossa finche' il lavoro non
/// e' fatto e guardato. Le voci chiuse le sorveglia
/// `ogni_voce_chiusa_porta_la_sua_prova_test.dart`, che pretende sotto
/// ciascuna la domanda del fondatore, la prova e la misura.
void main() {
  final manifesto = File('docs/ordini/ORDINE_EN_MANIFESTO.md');

  const quante = 12;

  test('il manifesto esiste e porta tutte e dodici le voci', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'il manifesto nasce prima del codice');
    final testo = manifesto.readAsStringSync();
    final mancanti = <String>[];
    for (var i = 1; i <= quante; i++) {
      final voce = 'EN.${i.toString().padLeft(2, '0')}';
      if (!testo.contains('## VOCE $voce,')) mancanti.add(voce);
    }
    expect(mancanti, isEmpty, reason: 'voci non nominate: $mancanti');
  });

  // **LAPIDE, ordine FC voce 11.** Qui c'era "ogni voce dichiara uno stato
  // terminale, e i conti tornano", che pretendeva zero voci aperte ed era
  // rossa per costruzione: le voci aperte aspettano gesti del fondatore che
  // sul ramo non esistono. Il fondatore, il 5 ottobre 2026, ha scelto la
  // cura (3) della FC.11: la prova gira sul ramo e pretende che ogni voce
  // aperta dica quale gesto aspetta. Il perche' per esteso sta in
  // `le_voci_aperte_dicono_cosa_aspettano.dart`.
  test(
      'ogni voce ha uno stato, i conti tornano, e ogni voce aperta dice '
      'quale gesto aspetta', () {
    leVociAperteDiconoCosaAspettano('EN', quante);
  });

  test('le parole del fondatore stanno nel manifesto', () {
    // Sono le misure delle voci: l'attesa, le cinque righe, la cornice, la
    // memoria e le due decisioni sul catalogo. Senza queste frasi chi legge
    // il manifesto misurerebbe la cosa sbagliata.
    final testo = manifesto.readAsStringSync();
    const pretese = <String>[
      'bisogna ridurre questa pausa',
      'ok per il tuo consiglio',
      'possiamo arrivare almeno a 5',
      'vorrei qualcosa di elegante Senza esagerare e sempre dorato',
      'accedano alle memorie dell',
      'Mappa del Viso senza',
      'Respiro della Luna e Affinità Lunare',
      'Finisci tutto Senza',
    ];
    final mancanti = [
      for (final p in pretese)
        if (!testo.contains(p)) p
    ];
    expect(pretese.length, 8);
    expect(mancanti, isEmpty, reason: 'il manifesto non porta: $mancanti');
  });
}
