import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/natal_chart_reveal.dart';
import 'package:esoteric_circle/services/free_astro_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// DATO MANCANTE E CALCOLO FALLITO NON SONO LA STESSA COSA.
///
/// Ordine 2169, voce 3. L'app diceva "mi serve il tuo luogo di nascita" e da
/// quell'avviso non partiva nessuna strada per darglielo: le si dichiarava che
/// mancava un dato senza offrirle il modo di completarlo. Peggio, offriva
/// "Riprova", che senza il luogo restituisce lo stesso ripiego all'infinito.
///
/// **La causa esisteva gia' nel controller e arrivava a meta' strada.**
/// `_mancaIlLuogo` sceglieva quale FRASE mostrare, ma la schermata riceveva
/// due frasi e un gesto solo: la differenza moriva dentro il testo. Adesso e'
/// un fatto leggibile (`mancaIlLuogo`), e a due casi diversi corrispondono due
/// gesti diversi.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  // Il catalogo vero, non il seme: la regola del nome unico si misura su
  // undicimila citta', dove gli omonimi esistono davvero.
  setUpAll(() {
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
  });

  /// Nascita CON luogo: se il calcolo fallisce, la colpa non e' della persona.
  final conLuogo = BirthDetails(
    date: DateTime(1975, 7, 6),
    time: const TimeOfDay(hour: 9, minute: 30),
    place: const BirthPlace(
      latitude: 41.9,
      longitude: 12.5,
      timezone: 'Europe/Rome',
      label: 'Roma',
    ),
  );

  /// Nascita SENZA luogo: e' il caso della fondatrice, e lo risolve lei in
  /// trenta secondi se le diciamo come.
  final senzaLuogo = BirthDetails(
    date: DateTime(1975, 7, 6),
    time: const TimeOfDay(hour: 9, minute: 30),
  );

  Future<void> apri(WidgetTester tester, BirthDetails dettagli) async {
    final carta = NatalChartController(client: _ClienteMuto());
    final identita = BirthIdentityController()..setBirth(dettagli, null);
    final profilo = ProfileController();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<ProfileController>.value(value: profilo),
        ChangeNotifierProvider<NatalChartController>.value(value: carta),
        ChangeNotifierProvider<BirthIdentityController>.value(value: identita),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: Scaffold(body: NatalChartReveal(onContinue: () {})),
        ),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  testWidgets('SENZA il luogo, l\'avviso offre di darlo e non di riprovare',
      (tester) async {
    await apri(tester, senzaLuogo);

    expect(find.byKey(const Key('carta_natale_nota')), findsOneWidget,
        reason: 'senza luogo la carta e\' un ripiego e la nota deve dirlo');
    expect(find.byKey(const Key('carta_natale_completa_luogo')), findsOneWidget,
        reason: 'l\'avviso dichiara che manca il luogo e non offre nessuna '
            'strada per darlo: e\' un vicolo cieco cortese, ed e\' il motivo '
            'per cui una persona puo\' restare senza luogo per mesi');
    expect(find.byKey(const Key('carta_natale_riprova')), findsNothing,
        reason: 'si offre di riprovare a chi non ha niente da riprovare: '
            'senza il luogo il calcolo dara\' lo stesso ripiego ogni volta');
  });

  testWidgets('CON il luogo, se il calcolo fallisce si offre di riprovare',
      (tester) async {
    await apri(tester, conLuogo);

    expect(find.byKey(const Key('carta_natale_nota')), findsOneWidget);
    expect(find.byKey(const Key('carta_natale_riprova')), findsOneWidget,
        reason: 'il calcolo e\' fallito per una causa che non dipende dalla '
            'persona: qui riprovare e\' esattamente il gesto giusto');
    expect(find.byKey(const Key('carta_natale_completa_luogo')), findsNothing,
        reason: 'si chiede un luogo che la persona ha gia\' dato');
  });

  testWidgets('il gesto porta dove il luogo si da\' davvero', (tester) async {
    await apri(tester, senzaLuogo);

    await tester.tap(find.byKey(const Key('carta_natale_completa_luogo')));
    // **NIENTE pumpAndSettle**: la schermata dei dati di nascita ha un campo
    // col fuoco, e un cursore che lampeggia e' un'animazione che non finisce
    // mai.
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    // **E' LA SCHERMATA CHE ESISTE GIA', non un foglio nuovo.** La prima
    // stesura di questo ordine apriva un proprio foglio con la propria
    // ricerca delle citta': una seconda porta per lo stesso dato, che la
    // prova enumerante `dati_nascita_sbloccano_test` ha preso in pieno,
    // vedendo le porte diventare tre. Qui si pretende che il gesto porti dove
    // i dati di nascita si correggono da sempre.
    expect(find.byKey(const Key('nascita_luogo_field')), findsOneWidget,
        reason: 'il gesto non porta alla schermata dei dati di nascita: se '
            'apre un posto suo, il luogo si da\' in due modi diversi, '
            'ed e\' la forma di difetto che questo progetto ha gia\' '
            'pagato undici volte');
  });

  test('la causa risolvibile e\' un fatto, non una sfumatura di testo', () {
    // **IL PRESIDIO.** Se domani qualcuno togliesse `mancaIlLuogo` e tornasse
    // a distinguere i due casi guardando dentro la frase, questa prova
    // cadrebbe. Distinguere due stati leggendo il testo che li descrive vuol
    // dire che cambiare una parola cambia il comportamento.
    final c = NatalChartController(client: _ClienteMuto());
    expect(c.mancaIlLuogo, isFalse,
        reason: 'appena nato non c\'e\' nessun ripiego dichiarato');
  });
}

/// Un cliente che non risponde mai: e' la rete assente, o la chiave scaduta.
class _ClienteMuto extends FreeAstroClient {
  @override
  Future<Map<String, dynamic>> fetchRawNatalChart(BirthDetails details) async =>
      throw const AstroApiException('Il cielo non risponde in questo momento.');
}
