import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// I gesti puri della Runa del Tramonto: il flip a due facce e l'integratore
/// dell'inclinazione, testati senza montare la scena.
void main() {
  group('Il flip a due facce non specchia il contenuto', () {
    test('A fine giro la scala orizzontale del contenuto e\' positiva', () {
      // Determinante positivo sull'asse X: la faccia B e' controruotata, quindi
      // a giro compiuto il contenuto e' diritto, non specchiato.
      expect(sunsetFlipContentXScale(1.0), greaterThan(0));
    });

    test('Non e\' mai negativa lungo tutto il giro', () {
      for (var i = 0; i <= 20; i++) {
        final t = i / 20.0;
        expect(sunsetFlipContentXScale(t), greaterThanOrEqualTo(-1e-9),
            reason: 't=$t');
      }
    });

    test('All\'inizio vale uno, la faccia A e\' piena', () {
      expect(sunsetFlipContentXScale(0.0), closeTo(1.0, 1e-9));
    });
  });

  group('L\'integratore dell\'inclinazione', () {
    test('Una rotazione costante oltre la soglia fa scattare il giro', () {
      final g = GiroInclinazione();
      var scattato = false;
      // 2 rad/s per venti passi da 40 ms = 1.6 rad, oltre la soglia di 1.2.
      for (var i = 0; i < 20 && !scattato; i++) {
        scattato = g.passo(2.0, 0.04);
      }
      expect(scattato, isTrue);
      expect(g.accumulo, 0, reason: 'l\'accumulo si azzera dopo lo scatto');
    });

    test('Un moto che inverte prima della soglia non scatta', () {
      final g = GiroInclinazione();
      var scattato = false;
      // Sale un poco, poi inverte deciso: l'accumulo riparte e non arriva mai.
      for (var i = 0; i < 5; i++) {
        scattato = g.passo(1.5, 0.04) || scattato;
      }
      for (var i = 0; i < 5; i++) {
        scattato = g.passo(-1.5, 0.04) || scattato;
      }
      expect(scattato, isFalse);
    });

    test('Un moto lento sotto soglia non scatta mai', () {
      final g = GiroInclinazione();
      var scattato = false;
      for (var i = 0; i < 3; i++) {
        scattato = g.passo(0.1, 0.04) || scattato;
      }
      expect(scattato, isFalse);
    });
  });
}
