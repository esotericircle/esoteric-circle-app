import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/natal_chart_reveal.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/services/free_astro_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA CARTA NATALE ARRIVA, oppure arriva un errore. Mai il cerchio per sempre.
///
/// **La segnalazione.** Dal Passport si apriva la Carta natale e restava sul
/// cerchio con "Traccio il tuo cielo..." indefinitamente. Il fondatore ha
/// aspettato oltre un minuto.
///
/// **Non era la rete: la chiamata non partiva mai.** Il calcolo era invocato in
/// UN SOLO punto di tutto il progetto, alla fine del Risveglio. Il Passport
/// spingeva la schermata e non chiedeva niente a nessuno, quindi lo stato
/// restava quello iniziale e la guardia in cima al build restituiva il
/// caricamento per sempre. Il timeout di venti secondi sulla chiamata esisteva
/// ed era corretto: era inutile, perche' non c'era nessuna chiamata da far
/// scadere.
///
/// **E si ripeteva a ogni riavvio** anche per chi il Risveglio l'aveva
/// completato, perche' il controller vive solo in memoria. Funzionava soltanto
/// nella stessa sessione del Risveglio, ed e' probabilmente cosi' che era stato
/// verificato a suo tempo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final dettagli = BirthDetails(
    date: DateTime(1975, 7, 6),
    time: const TimeOfDay(hour: 9, minute: 30),
    place: const BirthPlace(
      latitude: 41.9,
      longitude: 12.5,
      timezone: 'Europe/Rome',
      label: 'Roma',
    ),
  );

  /// Monta la Carta natale come la apre il Passport: in una sessione dove il
  /// Risveglio NON e' stato fatto, quindi nessuno ha mai calcolato niente.
  Future<void> apriDalPassport(
    WidgetTester tester, {
    required NatalChartController carta,
  }) async {
    final identita = BirthIdentityController()..setBirth(dettagli, null);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<NatalChartController>.value(value: carta),
        ChangeNotifierProvider<BirthIdentityController>.value(value: identita),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: Scaffold(
            body: NatalChartReveal(onContinue: () {}),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('Aperta senza Risveglio, entro tre secondi c\'e\' una carta',
      (tester) async {
    // Il cliente qui fallisce sempre, come una rete assente: il ripiego locale
    // deve comunque produrre una carta. Se resta il cerchio, non e' la rete a
    // mancare, e' la chiamata a non essere mai partita.
    final carta = NatalChartController(client: _ClienteMuto());

    await apriDalPassport(tester, carta: carta);

    // Il tempo dichiarato: tre secondi. Oltre, per chi guarda, e' rotto.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    expect(find.text('Traccio il tuo cielo...'), findsNothing,
        reason: 'dopo tre secondi la Carta natale gira ancora sul cerchio: la '
            'chiamata non e\' mai partita, e nessun timeout puo\' salvarti '
            'perche\' non c\'e\' niente da far scadere');
    expect(carta.status, ChartStatus.ready,
        reason: 'la schermata non ha garantito il proprio dato');
  });

  testWidgets('Se il cielo ripiega, la nota si vede e si puo\' riprovare',
      (tester) async {
    final carta = NatalChartController(client: _ClienteMuto());
    await apriDalPassport(tester, carta: carta);
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    // La nota era valorizzata nel controller e non la mostrava nessuno: chi
    // riceveva il cielo essenziale non sapeva ne che fosse essenziale ne
    // perche', e non aveva modo di riprovare quando la rete tornava.
    expect(find.byKey(const Key('carta_natale_nota')), findsOneWidget,
        reason: 'il cielo e\' quello essenziale e la persona non lo sa: il '
            'messaggio che lo spiega non lo legge nessuno');
    expect(find.byKey(const Key('carta_natale_riprova')), findsOneWidget,
        reason: 'non c\'e\' modo di riprovare: un ripiego senza uscita e\' un '
            'vicolo cieco travestito da risposta');
  });

  testWidgets('Senza dati di nascita si dice, non si gira per sempre',
      (tester) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(
            create: (_) => NatalChartController(client: _ClienteMuto())),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: Scaffold(body: NatalChartReveal(onContinue: () {})),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('carta_natale_senza_dati')), findsOneWidget,
        reason: 'senza data di nascita il cerchio gira promettendo una carta '
            'che nessuno sta calcolando');
  });

  test('La carta si conserva fra un avvio e l\'altro', () async {
    // Primo avvio: il cielo risponde, e la risposta si conserva.
    final primo = NatalChartController(client: _ClienteCheRisponde());
    await primo.compute(dettagli);
    expect(primo.chart, isNotNull);

    // Secondo avvio: un cliente che NON risponde. Se la carta arriva completa
    // lo stesso, viene dalla memoria, e rivedere un cielo gia' visto non
    // dipende dalla rete.
    final secondo = NatalChartController(client: _ClienteMuto());
    await secondo.compute(dettagli);
    expect(secondo.ripiego, isFalse,
        reason: 'al secondo avvio la carta viene ricalcolata da capo e senza '
            'rete finisce sul ripiego: non si conserva niente, quindi il caso '
            'si ripete a ogni riavvio');
  });

  test('Cambiando la data di nascita, la carta conservata non si riusa',
      () async {
    final primo = NatalChartController(client: _ClienteCheRisponde());
    await primo.compute(dettagli);

    // Un'altra data: la carta conservata NON deve essere ritrovata, altrimenti
    // la persona guarda il cielo di un altro. Una carta conservata sotto una
    // chiave fissa e' peggio del non conservarla.
    final altra = BirthDetails(
      date: DateTime(1980, 2, 2),
      time: const TimeOfDay(hour: 9, minute: 30),
      place: const BirthPlace(
        latitude: 41.9,
        longitude: 12.5,
        timezone: 'Europe/Rome',
      label: 'Roma',
      ),
    );
    final secondo = NatalChartController(client: _ClienteMuto());
    await secondo.compute(altra);
    expect(secondo.ripiego, isTrue,
        reason: 'con una data diversa viene ritrovata la carta della data '
            'vecchia: la memoria e\' sotto una chiave che non dipende dai dati '
            'di nascita');
  });

  test('Le porte che aprono la Carta natale sono enumerate', () {
    // La garanzia sta nella SCHERMATA, non nelle porte, e questa prova esiste
    // per accorgersi quando ne nasce una nuova: se domani se ne aggiunge una
    // terza, chi la scrive vede questa prova cadere e legge il motivo, invece
    // di scoprire il caricamento eterno da uno screenshot del fondatore.
    final porte = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p.endsWith('natal_chart_reveal.dart')) continue;
      if (f.readAsStringSync().contains('NatalChartReveal(')) porte.add(p);
    }
    expect(porte.length, 2,
        reason: 'le porte che aprono la Carta natale sono ${porte.length} '
            '($porte): se ne e\' nata una nuova, verifica che non debba '
            'chiamare il calcolo da fuori, perche\' la schermata se lo '
            'garantisce da sola');
  });
}

/// Un cielo che non risponde mai, come una rete assente.
///
/// `hasKey` risponde per davvero e non lancia: il ripiego lo interroga DENTRO
/// il blocco che gestisce l'errore, quindi un finto che lancia anche li'
/// farebbe esplodere il ripiego stesso e la prova misurerebbe un guasto suo.
class _ClienteMuto extends FreeAstroClient {
  @override
  Future<Map<String, dynamic>> fetchRawNatalChart(BirthDetails details) async =>
      throw const AstroApiException('Il cielo non risponde in questo momento.');

  // Sa interpretare, ma non sa CHIEDERE: cosi' una risposta gia' conservata
  // resta leggibile mentre la rete non c'e', che e' esattamente il caso di chi
  // riapre il Passport in aereo.
  @override
  NatalChart parseResponse(Map<String, dynamic> json, BirthDetails details) =>
      NatalChart.essential(
          sunSign: Zodiac.fromDate(details.date), hasTime: true);
}

/// Un cielo che risponde con una carta minima ma completa.
class _ClienteCheRisponde extends FreeAstroClient {
  @override
  Future<Map<String, dynamic>> fetchRawNatalChart(BirthDetails details) async =>
      _rispostaMinima;

  @override
  NatalChart parseResponse(Map<String, dynamic> json, BirthDetails details) =>
      NatalChart.essential(sunSign: Zodiac.fromDate(details.date), hasTime: true);
}

const _rispostaMinima = <String, dynamic>{'planets': <dynamic>[]};
