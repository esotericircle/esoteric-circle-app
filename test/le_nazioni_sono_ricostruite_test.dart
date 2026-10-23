import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/features/onboarding/mappa_della_nazione.dart';
import 'package:esoteric_circle/features/onboarding/nazioni_del_mondo.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE NAZIONI SONO RICOSTRUITE. Ordine BE voce 03.
///
/// **Parole del fondatore sulla 2199, maiuscole sue**: "la selezione della
/// citta' straniera FA SCHIFO, NON SI CAPISCE E NON SI INDIVIDUA NIENTE
/// PERCHE' LA NAZIONE NON E' RICOSTRUITA E TUTTO E' SEMITRASPARENTE".
///
/// La fonte e' Natural Earth 1:110m, pubblico dominio, agganciata al
/// catalogo COL VOTO DELLE CITTA' e non coi nomi. 184 paesi hanno il
/// contorno vero; i 57 rimasti sono isole che quella scala non disegna, e
/// tengono la regione con le coste, dichiarato.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MappaDellaNazione?> nazioneDi(
      WidgetTester tester, String citta) async {
    await tester.runAsync(() async {
      await CityCatalog.ensureLoaded();
      await NazioniDelMondo.ensureLoaded();
    });
    final luogo = CityCatalog.luoghi.firstWhere((c) => c.name == citta);
    return MappaDellaNazione.perIlLuogo(
        luogo.latitude, luogo.longitude, CityCatalog.luoghi);
  }

  testWidgets('BE.03: le tre citta\' del fondatore hanno la nazione piena',
      (tester) async {
    for (final citta in const ['Parigi', 'Seul', 'New York']) {
      final nazione = await nazioneDi(tester, citta);
      // ignore: avoid_print
      print('ORDINE BE VOCE 03: $citta -> ${nazione?.paese}, corpo di '
          '${nazione?.sfondo.length} punti');
      expect(nazione?.nazionePiena, isTrue,
          reason: '$citta non ha piu\' la nazione ricostruita: e\' lo '
              'screenshot bocciato della 2199');
      expect(nazione!.sfondo.length, greaterThan(800),
          reason: 'il corpo di ${nazione.paese} porta solo '
              '${nazione.sfondo.length} punti: una spruzzata, non una '
              'sagoma');
    }
  });

  testWidgets(
      'BE.03: la Francia e\' quella metropolitana, non l\'Atlantico intero',
      (tester) async {
    // Misurato: il contorno di Natural Earth porta anche la Guyana, e il
    // riquadro attraversava l\'oceano lasciando 127 punti su settemila. Gli
    // anelli si scelgono dove vivono le citta\'.
    final francia = await nazioneDi(tester, 'Parigi');
    expect(francia!.est - francia.ovest, lessThan(25),
        reason: 'la finestra della Francia e\' larga '
            '${(francia.est - francia.ovest).toStringAsFixed(0)} gradi: '
            'dentro c\'e\' di nuovo la Guyana e la sagoma sparisce');
  });

  testWidgets('BE.03: un\'isola fuori scala tiene la regione, dichiarato',
      (tester) async {
    final malta = await nazioneDi(tester, 'La Valletta');
    // ignore: avoid_print
    print('ORDINE BE VOCE 03: Malta -> piena ${malta?.nazionePiena}, '
        'coste ${malta?.sfondo.length}');
    expect(malta!.nazionePiena, isFalse,
        reason: 'Malta non sta nell\'1:110m: se risulta piena, l\'asset '
            'dice una cosa che la fonte non porta');
    expect(malta.eRegione, isTrue,
        reason: 'Malta ha perso anche la regione con le coste: il quadro '
            'sarebbe vuoto');
  });

  test('BE.03: l\'indicatore della citta\' e\' arancione, per tutti i paesi',
      () {
    final sorgente =
        File('lib/features/onboarding/planisfero.dart').readAsStringSync();
    expect(sorgente.contains('const richiamo = Color(0xFFFF7A45)'), isTrue,
        reason: 'l\'indicatore animato non e\' piu\' arancione: il fondatore '
            'lo ha chiesto arancione/rosso per tutti i paesi');
    expect(sorgente.contains('..color = richiamo.withValues'), isTrue,
        reason: 'le onde dell\'indicatore non usano piu\' il richiamo');
  });
}
