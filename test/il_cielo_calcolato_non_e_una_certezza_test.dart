import 'package:esoteric_circle/core/chat/le_certezze_del_maestro.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL CIELO CALCOLATO NON E' UNA PREVISIONE.** Ordine EX Aggiunta 4, voce
/// EX.07. Al banco della qualita' (giro ex07b) la rete delle certezze ha
/// scartato *"Il primo gennaio 2028 Giove sarà a 27 gradi in Vergine."*: e'
/// il cielo che l'app ha calcolato dalle effemeridi per quel giorno, non
/// cio' che nessuno puo' sapere, e la correzione costava una chiamata.
/// Padre: ordine ET voce 01, la rete nata prima delle funzioni del cielo
/// (ordine EV voce 03). Il futuro che riguarda la persona resta una
/// certezza anche accanto a un pianeta.
void main() {
  test('il futuro di un pianeta in un segno non e\' una certezza', () {
    const delCielo = [
      'Il primo gennaio 2028 Giove sarà a 27 gradi in Vergine.',
      'Il 15 novembre la Luna sarà in Acquario.',
      'Domani Mercurio entrerà in Scorpione.',
      'A dicembre Saturno sarà retrogrado in Ariete.',
      // Dal giro ex07c del banco: il plurale e il segno detto per esteso.
      'Domani Mercurio e Venere si troveranno entrambi in Scorpione.',
      'Giove il primo gennaio del duemilaventotto sarà nel segno della '
          'Vergine.',
      // Dal giro ex07e: la luce e il moto di un corpo del cielo non sono
      // l'animo di un'altra persona.
      'Il 20 luglio 1969 la Luna era crescente. La sua luce stava aumentando.',
    ];
    for (final f in delCielo) {
      expect(LeCertezzeDelMaestro.inQuesteFrasi(f), isEmpty, reason: f);
    }
    cardinaleMinimo(delCielo.length, 7, cosa: 'frasi del cielo');
  });

  test('il futuro della persona accanto a un pianeta resta una certezza', () {
    const certe = [
      'Venere sarà in Bilancia e ti porterà l\'amore che aspetti.',
      'Giove in Leone ti darà il lavoro nuovo.',
      'Con la Luna in Toro il colloquio andrà bene.',
      'La sua luce ti dice che lui ti ama ancora.',
    ];
    for (final f in certe) {
      expect(LeCertezzeDelMaestro.inQuesteFrasi(f), isNotEmpty, reason: f);
    }
  });
}
