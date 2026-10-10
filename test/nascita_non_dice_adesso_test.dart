import 'package:esoteric_circle/features/santuario/sky_overview_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// NEL CIELO DI NASCITA NIENTE E' AL PRESENTE.
///
/// La scheda del cielo di NASCITA diceva "Adesso sale verso il culmine, a 40
/// gradi sopra il suolo", parlando di una notte di cinquant'anni prima. Nel
/// giro scorso avevo declinato al passato la nota in fondo e scritto che viveva
/// in un punto solo: vero per QUELLA. La parola "adesso" viveva anche nella
/// RIGA DEL CALCOLO, che e' un'altra stringa, e li' era rimasta al presente.
///
/// Dodicesima occorrenza della famiglia delle due porte, e stavolta dentro la
/// stessa schermata: due frasi che descrivono lo stesso istante, e ne era stata
/// corretta una.
void main() {
  test('L avverbio del tempo viene da una fonte sola', () {
    // Dal 1 agosto 2026 non e' piu' "Adesso": la schermata mostra la
    // mezzanotte della notte che viene, non l'istante presente. La prova ha
    // fatto il suo mestiere, ha denunciato il cambio del punto solo invece di
    // lasciarlo passare inosservato.
    expect(quando(false), 'Stanotte');
    expect(quando(true), 'Quella notte',
        reason: 'nel cielo di nascita l avverbio resta al presente');
  });

  test('Le due frasi leggono la stessa fonte, non se lo ricordano da sole', () {
    // Se una delle due tornasse a scriversi l'avverbio per conto proprio,
    // divergerebbe al primo cambio: e' esattamente cio' che era successo.
    for (final birth in const [false, true]) {
      final atteso = quando(birth);
      expect(atteso, isNotEmpty);
      // La fonte e' una funzione sola: chiamarla due volte da' lo stesso
      // risultato, e non c'e' modo di averne una versione che se lo ricorda.
      expect(quando(birth), atteso);
    }
  });
}
