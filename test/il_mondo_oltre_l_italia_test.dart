import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/features/onboarding/mappa_della_nazione.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL MONDO OLTRE L'ITALIA. Ordine BD voce 03.
///
/// La decisione del fondatore in BB.12 valeva per tutto il mondo: "cosa
/// succede se un utente e' straniero?". L'Italia si disegna dalle sue 8.438
/// citta'; per gli altri 241 paesi la finestra si stringe sulla REGIONE del
/// mondo attorno alle loro citta': le coste dai poligoni grossolani del
/// planisfero, tenui, e sopra le citta' vere del catalogo.
///
/// **Il buco dei 116 paesi con una sola citta' resta dichiarato**, e con
/// questa strada diventa visibile: la loro regione porta un punto di citta'
/// solo, col suo pezzo di costa attorno. Non si sana qui: si sana solo
/// infittendo il catalogo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<MappaDellaNazione?> nazioneDi(
      WidgetTester tester, String citta) async {
    await tester.runAsync(() => CityCatalog.ensureLoaded());
    final luogo = CityCatalog.luoghi.firstWhere((c) => c.name == citta);
    return MappaDellaNazione.perIlLuogo(
        luogo.latitude, luogo.longitude, CityCatalog.luoghi);
  }

  testWidgets('BD.03: un paese grande ha la sua regione, con le coste',
      (tester) async {
    final cina = await nazioneDi(tester, 'Shanghai');
    // ignore: avoid_print
    print('ORDINE BD VOCE 03: la Cina porta ${cina?.punti.length} citta\' e '
        '${cina?.sfondo.length} punti di costa nella finestra '
        '${cina?.ovest.toStringAsFixed(0)}..${cina?.est.toStringAsFixed(0)}');
    expect(cina, isNotNull,
        reason: 'chi nasce a Shanghai vede di nuovo il planisfero intero, '
            'dove il suo paese e\' grande come un\'unghia');
    expect(cina!.eRegione, isTrue,
        reason: 'la Cina non supera la densita\' e deve essere una regione, '
            'non un disegno di citta\'');
    expect(cina.sfondo, isNotEmpty,
        reason: 'la regione non porta nessuna costa: sarebbe una spruzzata '
            'di citta\' nel vuoto');
    expect(cina.est - cina.ovest, lessThan(120),
        reason: 'la finestra della Cina e\' larga quanto mezzo mondo: non si '
            'e\' stretta sulla regione');
  });

  testWidgets('BD.03: un paese con una citta\' sola ha comunque la sua regione',
      (tester) async {
    final liberia = await nazioneDi(tester, 'Monrovia');
    // ignore: avoid_print
    print('ORDINE BD VOCE 03: la Liberia porta ${liberia?.punti.length} '
        'citta\' e ${liberia?.sfondo.length} punti di costa, finestra alta '
        '${(liberia!.nord - liberia.sud).toStringAsFixed(1)} gradi');
    expect(liberia.eRegione, isTrue);
    expect(liberia.punti, hasLength(1),
        reason: 'il buco del catalogo e\' dichiarato: la Liberia ha una '
            'citta\' sola, e se questo numero sale il buco si sta chiudendo');
    expect(liberia.nord - liberia.sud,
        greaterThanOrEqualTo(MappaDellaNazione.latoMinimoDellaRegione),
        reason: 'la finestra di un paese con una citta\' sola deve allargarsi '
            'al lato minimo, se no il quadro e\' vuoto');
    expect(liberia.sfondo, isNotEmpty,
        reason: 'nemmeno un punto di costa attorno a Monrovia: il quadro '
            'sarebbe una stella nel nulla');
  });

  testWidgets('BD.03: l\'Italia resta disegnata dalle sue citta\'',
      (tester) async {
    final italia = await nazioneDi(tester, 'Roma');
    // ignore: avoid_print
    print('ORDINE BD VOCE 03: l\'Italia porta ${italia?.punti.length} '
        'citta\' e regione=${italia?.eRegione}');
    expect(italia!.eRegione, isFalse,
        reason: 'l\'Italia e\' passata alla regione: lo stivale delle sue '
            'ottomila citta\' e\' sparito');
    expect(italia.punti.length, greaterThan(8000));
  });

  testWidgets('BD.03: la stella cade dentro la finestra della regione',
      (tester) async {
    // **La stella e la mappa condividono la proiezione**: se il luogo scelto
    // uscisse dalla finestra, la stella finirebbe fuori quadro.
    final cina = await nazioneDi(tester, 'Shanghai');
    final luogo = CityCatalog.luoghi.firstWhere((c) => c.name == 'Shanghai');
    final q = cina!.proietta(luogo.latitude, luogo.longitude);
    // ignore: avoid_print
    print('ORDINE BD VOCE 03: Shanghai si proietta a '
        '(${q.x.toStringAsFixed(2)}, ${q.y.toStringAsFixed(2)})');
    expect(q.x, inInclusiveRange(0, 1));
    expect(q.y, inInclusiveRange(0, 1));
  });
}
