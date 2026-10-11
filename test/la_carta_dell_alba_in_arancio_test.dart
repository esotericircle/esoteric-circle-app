import 'package:esoteric_circle/core/rituals/arcano_dell_alba/letture_dell_alba_dati.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/responso_dell_alba.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/rituals/arcano_dell_alba_screen.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// LA CARTA DELL'ALBA IN ARANCIO. Ordine FK, richiesta del fondatore dell'11
/// ottobre 2026: *"vorrei che il nome della carta sia evidenziato in altro
/// colore, magari arancione, e anche il testo "rovesciata" o "dritta" in
/// arancione. Cosi', a colpo d'occhio, l'utente vede il nome della carta e il
/// suo verso."*
///
/// Per ogni lettura del corpus dell'Alba, nei due versi: nella frase della
/// carta c'e' un pezzo solo in arancio, ed e' il nome col verso.
void main() {
  test('in ogni lettura il nome della carta e il verso sono in arancio', () {
    final guasti = <String>[];
    var dritte = 0, rovesciate = 0;
    for (final l in lettureDellAlba) {
      final r = ResponsoDellAlba.componi(l, apertura: 0, clausola: 0);
      final span = TreMovimentiDellAlba.conLaCartaInArancio(r);
      final arancio = [
        for (final s in span.children ?? const <InlineSpan>[])
          if (s is TextSpan && s.style?.color == ColorTokens.arancioDellaCarta)
            s.text ?? '',
      ];
      final atteso = ResponsoDellAlba.cartaColVerso(l.stato);
      if (arancio.length != 1 || arancio.single != atteso) {
        guasti.add('${l.carta} ${l.rovescio}: in arancio $arancio');
      }
      if (span.toPlainText() != r.primo) {
        guasti.add('${l.carta}: la frase non e\' piu\' quella');
      }
      final verso = l.rovescio ? 'rovesciat' : 'dritt';
      if (!atteso.contains(verso)) guasti.add('${l.carta}: manca "$verso"');
      l.rovescio ? rovesciate++ : dritte++;
    }
    cardinaleMinimo(dritte, 100, cosa: 'letture dritte dell\'Alba');
    cardinaleMinimo(rovesciate, 100, cosa: 'letture rovesciate dell\'Alba');
    // ignore: avoid_print
    print('ORDINE FK, ALBA IN ARANCIO: letture $dritte dritte e $rovesciate '
        'rovesciate, guaste ${guasti.length}');
    expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
  });
}
