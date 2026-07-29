import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Le tessere del Passaporto Cosmico che stanno ancora dietro il velo.
///
/// Ce n'erano tre. Due di esse pero' descrivevano fatti **gia' vivi** nell'app:
///
/// - **Carta natale**: la carta si calcola davvero, si vede nel Risveglio e ha
///   la sua schermata. Restava spenta in una tessera che diceva "in arrivo".
/// - **Angelo custode**: nel passaporto, poche righe sopra, c'e' gia' la tessera
///   VIVA "I tuoi Angeli", che apre la triade calcolata. Erano due tessere per
///   la stessa cosa, una accesa e una spenta.
///
/// Promettere come futuro qualcosa che l'app fa gia' e' peggio di non
/// prometterlo: chi legge conclude che non ce l'ha.
///
/// L'Archetipo resta dietro il velo, perche' il fatto identitario "il tuo
/// archetipo" non e' ancora calcolato e conservato nel profilo. Il Test
/// Archetipo di Aura e' un'arte che si puo' fare, non un dato del passaporto.
void main() {
  final sorgente =
      File('lib/features/passport/cosmic_passport_screen.dart').readAsStringSync();

  /// Il blocco delle voci ancora velate.
  final daVelate = sorgente.indexOf('_passportEntries = [');
  final velate =
      sorgente.substring(daVelate, sorgente.indexOf('];', daVelate));

  test('La Carta natale non e\' piu\' dietro il velo', () {
    expect(velate.contains("title: 'Carta natale'"), isFalse,
        reason: 'la carta natale si calcola davvero e ha la sua schermata, ma '
            'il passaporto la promette ancora come cosa futura');
  });

  test('L\'Angelo custode non e\' piu\' dietro il velo', () {
    expect(velate.contains("title: 'Angelo custode'"), isFalse,
        reason: 'gli Angeli sono gia\' vivi nella tessera qui sopra: due '
            'tessere per la stessa cosa, una accesa e una spenta');
  });

  test('La Carta natale ha una tessera viva e apribile', () {
    expect(sorgente.contains("Key('passport_natal_chart')"), isTrue,
        reason: 'non e\' nata nessuna tessera viva per la carta natale');
  });

  test('L\'Archetipo resta dietro il velo, e resta uno solo', () {
    expect(velate.contains("title: 'Archetipo'"), isTrue,
        reason: 'l\'Archetipo non e\' un dato del passaporto: deve restare '
            'dichiarato come in arrivo, invece di sparire in silenzio');
    expect('title:'.allMatches(velate).length, 1,
        reason: 'le voci velate non sono una sola');
  });

  test('I titoli delle tessere velate non si spezzano a meta\' parola', () {
    // "Archetipo" in Cinzel maiuscolo andava a capo dentro la parola. Il
    // rimedio e' lo stesso gia' usato per "Meditazione" nella striscia: il
    // titolo si rimpicciolisce invece di rompersi.
    final da = sorgente.indexOf('class _PassportEntryCard');
    final corpo = sorgente.substring(da, sorgente.indexOf('\n}', da));
    expect(corpo.contains('FittedBox'), isTrue,
        reason: 'il titolo della tessera velata puo\' ancora spezzarsi a meta\' '
            'parola');
    expect(corpo.contains('maxLines: 1'), isTrue,
        reason: 'il titolo puo\' ancora andare a capo');
  });
}
