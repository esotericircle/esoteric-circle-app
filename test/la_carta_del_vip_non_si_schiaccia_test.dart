import 'dart:io';

import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CARTA DEL VIP NON SI SCHIACCIA. Ordine CF voce 12.
///
/// **Rilievo del fondatore, verbatim**: "nella sinastria vip se ingrandisco la
/// Carta del vip, questa e' schiacciata verticalmente, ma i cartigli almeno
/// riportano i dati correttamente."
///
/// **La causa, misurata prima di curarla.** Il riquadro imponeva
/// `height: larga / 0.78`, lo `Stack` dentro usava `StackFit.expand`, che
/// passa ai figli vincoli STRETTI, e sotto vincoli stretti l'`AspectRatio` a
/// 2 su 3 di `VipFrame` non puo' cambiare misura: il suo rapporto veniva
/// ignorato. L'immagine era poi dipinta con `BoxFit.fill`, che non conserva
/// niente. L'altezza giusta per il 2 su 3 e' 1,5 volte la larghezza, quella
/// reale era 1,282: **compressione verticale del 14,53 per cento**.
///
/// **La prova misura il RAPPORTO e non la presenza del numero.** Una prova
/// che cercasse `VipFrame.aspect` nel sorgente sarebbe verde anche con un
/// riquadro sbagliato accanto: qui si calcola lo scostamento vero fra il
/// rapporto del riquadro e quello dell'artwork.
void main() {
  /// I tre punti che disegnano un ritratto di VIP, col nome della grandezza
  /// che ne fissa la larghezza.
  const punti = <String, String>{
    'lib/features/synastry/ritratto_ingrandito.dart': 'larga',
    'lib/features/synastry/chiamata_del_vip.dart': 'lato',
    'lib/features/synastry/rivelazione_del_gemello.dart': '120',
  };

  /// Quanto puo' scostarsi il rapporto del riquadro da quello dell'artwork.
  ///
  /// **Zero virgola zero uno, e la soglia e' dichiarata qui.** Un rapporto e'
  /// un numero puro: o e' quello dell'arte o l'immagine si deforma. Il
  /// margine serve solo agli arrotondamenti di chi scrive `2 / 3` in un modo
  /// diverso, non a lasciar passare una forma sbagliata.
  const tolleranza = 0.01;

  test('i tre riquadri hanno il rapporto dell\'artwork', () {
    final storti = <String>[];
    for (final voce in punti.entries) {
      final sorgente = File(voce.key).readAsStringSync();
      final trovato = RegExp('height: ${voce.value} / ([A-Za-z0-9_.]+),')
          .firstMatch(sorgente);
      expect(trovato, isNotNull,
          reason: 'in ${voce.key} non c\'e\' piu\' un riquadro alto '
              '"${voce.value} / qualcosa": questa prova insegue una forma che '
              'non c\'e\'');
      final divisore = trovato!.group(1)!;
      final rapporto = divisore == 'VipFrame.aspect'
          ? VipFrame.aspect
          : double.tryParse(divisore);
      // ignore: avoid_print
      print('ORDINE CF VOCE 12: ${voce.key.split("/").last} divide per '
          '$divisore, cioe\' ${rapporto?.toStringAsFixed(4)}, e l\'artwork '
          'vale ${VipFrame.aspect.toStringAsFixed(4)}');
      if (rapporto == null || (rapporto - VipFrame.aspect).abs() > tolleranza) {
        final scarto = rapporto == null
            ? 'illeggibile'
            : '${((1 - VipFrame.aspect / rapporto) * 100).toStringAsFixed(2)} '
                'per cento';
        storti.add('${voce.key}: divide per $divisore invece del rapporto '
            'dell\'artwork, e l\'immagine si comprime del $scarto');
      }
    }
    expect(storti, isEmpty, reason: 'riquadri della forma sbagliata: $storti');
  });

  test('il rapporto dell\'artwork ha una casa sola', () {
    // **SENZA QUESTA PROVA la prima si potrebbe far passare scrivendo 0.667
    // a mano in tre posti**, e il giorno che l'arte cambiasse forma
    // resterebbero tre numeri da ricordare invece di uno.
    var scritti = 0;
    for (final percorso in punti.keys) {
      final sorgente = File(percorso)
          .readAsStringSync()
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (!sorgente.contains('VipFrame.aspect')) scritti++;
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 12: punti che leggono il rapporto da VipFrame '
        '${punti.length - scritti} su ${punti.length}');
    expect(scritti, 0,
        reason: '$scritti punti scrivono il rapporto a mano invece di '
            'leggerlo da VipFrame, che e\' l\'unico posto dove la forma '
            'dell\'artwork e\' dichiarata');
  });
}
