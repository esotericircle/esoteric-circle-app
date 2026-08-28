import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/astro/solar_time.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Una posizione finta, sempre disponibile, per il conto alla rovescia.
class _LuogoFinto extends SkyLocation {
  const _LuogoFinto(this._luogo);
  final SkyPlace _luogo;
  @override
  bool get available => true;
  @override
  Future<SkyPlace?> resolve() async => _luogo;
  @override
  Future<SkyPlace?> resolveSeConcesso() async => _luogo;
}

/// Una sorgente che registra se qualcuno ha CHIESTO il permesso: `resolve` e' la
/// via che apre il dialogo di sistema, `resolveSeConcesso` no. Con permesso non
/// concesso, la seconda torna null.
class _LuogoSpia extends SkyLocation {
  _LuogoSpia();

  int chiesto = 0;
  int guardato = 0;

  @override
  bool get available => true;

  @override
  Future<SkyPlace?> resolve() async {
    chiesto++;
    return null; // permesso negato
  }

  @override
  Future<SkyPlace?> resolveSeConcesso() async {
    guardato++;
    return null; // permesso non concesso: nessuna posizione, nessun dialogo
  }
}

Widget _host(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        // Il cosmo condiviso del Sigillo del Sogno chiede parallasse e zodiaco.
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(home: Scaffold(body: child)),
    );

/// La striscia degli appuntamenti quotidiani: i cinque elementi, quello dell'ora
/// attiva in evidenza, l'header, il "?" per etichetta e l'apertura diretta a
/// tocco singolo senza dominio intermedio.
void main() {
  void silenceSensors(TestWidgetsFlutterBinding binding) {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
  }

  testWidgets('Mostra i cinque appuntamenti sotto l\'header', (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    expect(find.byKey(const Key('santuario_daily_strip')), findsOneWidget);
    // La riga sottile che annuncia la striscia.
    expect(find.text('I tuoi doni del giorno'), findsOneWidget);
    expect(DailyElement.values.length, 5);
    for (final e in DailyElement.values) {
      expect(find.byKey(Key('daily_element_${e.name}')), findsOneWidget);
    }
    // Il quinto appuntamento, il Sigillo del Sogno, e' presente.
    expect(find.byKey(const Key('daily_element_night')), findsOneWidget);
    expect(find.text('Notte'), findsOneWidget);
  });

  testWidgets('Nessun orario a vista nella striscia', (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    // Gli orari vivono solo nel popup, non sulla striscia.
    for (final label in const ['7:00', '10:30', '13:00', '18:30', '22:30']) {
      expect(find.text(label), findsNothing);
    }
  });


  /// **COME SI VEDE CHE LA CASELLA DEL TRAMONTO E' ACCESA, ordine AO voce
  /// 03.** Il conto alla rovescia sotto la casella non esiste piu': Mauro lo
  /// ha chiesto via dal collaudo della 2182, insieme allo slot da dodici
  /// punti che occupava sotto ogni casella. Cio' che quelle prove volevano
  /// davvero sapere e' se la striscia ha capito che il tramonto e' passato,
  /// e quello si legge dall'ACCENSIONE: l'etichetta di una casella accesa e'
  /// d'oro, quella di una spenta e' del colore del testo secondario. E' un
  /// segno piu' forte del conto, perche' e' quello che la persona vede.
  bool tramontoAcceso(WidgetTester tester) {
    final etichetta = tester.widget<Text>(find.text('Tramonto'));
    // L'oro della striscia, riletto nel sorgente: Color(0xFFE8C463).
    return etichetta.style?.color == const Color(0xFFE8C463);
  }

  testWidgets('Prima del tramonto la casella del Tramonto e\' spenta',
      (tester) async {
    // Primo pomeriggio: il tramonto e' piu' tardi, quindi la casella e'
    // ancora spenta e nessun conto alla rovescia compare sotto NESSUNA
    // casella, perche' quello slot non esiste piu'.
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    expect(tramontoAcceso(tester), isFalse,
        reason: 'la casella del Tramonto e\' accesa alle 13:00');
    for (final e in DailyElement.values) {
      expect(find.byKey(Key('daily_conto_${e.name}')), findsNothing,
          reason: 'sotto ${e.name} c\'e\' ancora un conto alla rovescia');
    }
  });

  testWidgets('A tramonto passato il conto sparisce, la casella si accende',
      (tester) async {
    // Notte fonda: il tramonto e' gia' avvenuto, nessun conto alla rovescia.
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 23, 0))));
    await tester.pump();
    expect(find.byKey(const Key('daily_conto_rune')), findsNothing);
  });

  testWidgets('Aprire la striscia non chiede mai il permesso di posizione',
      (tester) async {
    // Con permesso non concesso: la striscia guarda, non chiede, e ripiega sul
    // tramonto stimato dal fuso.
    final spia = _LuogoSpia();
    final now = DateTime(2026, 7, 14, 13, 0);
    await tester.pumpWidget(_host(DailyStrip(clock: () => now, location: spia)));
    await tester.pump();
    await tester.pump();

    expect(spia.chiesto, 0, reason: 'nessuna richiesta di permesso all\'apertura');
    expect(spia.guardato, greaterThan(0), reason: 'ha guardato senza chiedere');
    // **IL RIPIEGO SUL TRAMONTO STIMATO DAL FUSO SI VEDE DALL'ACCENSIONE,
    // ordine AO voce 03.** Prima si leggeva dentro il conto alla rovescia,
    // che non esiste piu': si guarda allora se la casella e' spenta prima
    // del tramonto stimato e accesa un'ora dopo. Se il ripiego non
    // funzionasse, la striscia non saprebbe niente del tramonto e le due
    // scene sarebbero identiche.
    final stimato = SunsetTime.perData(SunsetRune.giornoRituale(now),
        lat: SunsetTime.latDiRipiego,
        lon: SunsetTime.longitudineDaFuso(now.timeZoneOffset),
        offset: now.timeZoneOffset)!;
    expect(tramontoAcceso(tester), isFalse,
        reason: 'alle ${now.hour} la casella e\' gia\' accesa, ma il tramonto '
            'stimato e\' alle ${stimato.hour}');
    final dopo = stimato.add(const Duration(hours: 1));
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => dopo, location: spia)));
    await tester.pump();
    await tester.pump();
    expect(tramontoAcceso(tester), isTrue,
        reason: 'un\'ora dopo il tramonto stimato la casella e\' ancora '
            'spenta: il ripiego dal fuso non sta funzionando');
  });

  testWidgets('Il confine di giornata e\' quello rituale, come la schermata',
      (tester) async {
    // Alle 03:00 il giorno rituale e' ancora ieri: la runa di ieri e' quella
    // servita dalla schermata, quindi la striscia non deve annunciare un
    // tramonto lontano diciassette ore, e la casella non e' spenta.
    final notte = DateTime(2026, 7, 14, 3, 0);
    expect(SunsetRune.giornoRituale(notte), DateTime(2026, 7, 13));
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => notte)));
    await tester.pump();
    // Il tramonto del giorno rituale (ieri) e' passato: la casella e' ACCESA.
    // **Ordine AO voce 03**: prima lo si leggeva dall'assenza del conto alla
    // rovescia, che era un segno indiretto, e adesso lo dice l'accensione,
    // cioe' quello che la persona vede davvero.
    expect(tramontoAcceso(tester), isTrue,
        reason: 'alle 3 di notte il tramonto del giorno rituale, cioe\' di '
            'ieri, e\' passato da un pezzo: la casella doveva essere accesa');

    // Alle 13:00 il giorno rituale e' oggi e il tramonto e' ancora davanti.
    final pomeriggio = DateTime(2026, 7, 14, 13, 0);
    expect(SunsetRune.giornoRituale(pomeriggio), DateTime(2026, 7, 14));
    await tester
        .pumpWidget(_host(DailyStrip(clock: () => pomeriggio)));
    await tester.pump();
    expect(tramontoAcceso(tester), isFalse,
        reason: 'alle 13:00 la casella e\' accesa: sta guardando il tramonto '
            'di ieri invece di quello del giorno rituale corrente');
  });

  testWidgets('Il bersaglio del controllo di aiuto e\' almeno 44 per 44',
      (tester) async {
    await tester.pumpWidget(
        _host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    for (final e in DailyElement.values) {
      final t = find.byKey(Key('daily_help_target_${e.name}'));
      expect(t, findsOneWidget, reason: e.name);
      final size = tester.getSize(t);
      expect(size.width, greaterThanOrEqualTo(44), reason: e.name);
      expect(size.height, greaterThanOrEqualTo(44), reason: e.name);
    }
  });

  testWidgets('Un tocco lontano dal cerchio apre comunque l\'aiuto',
      (tester) async {
    await tester.pumpWidget(
        _host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    // Sedici punti sotto il centro del cerchietto: fuori dai 18 disegnati, ma
    // dentro il bersaglio da quarantaquattro.
    final centro =
        tester.getCenter(find.byKey(const Key('daily_help_button_rune')));
    await tester.tapAt(centro + const Offset(0, 16));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('daily_info_close_rune')), findsOneWidget);
  });

  testWidgets('La striscia usa la posizione reale, la stessa fonte della '
      'schermata', (tester) async {
    // **COSA MISURA QUESTA PROVA, e come e' cambiata di grandezza. Ordine AO
    // voce 03.** La domanda resta quella di prima: la striscia usa la
    // POSIZIONE VERA per sapere quando tramonta, o ripiega sulla stima dal
    // fuso anche quando la posizione ce l'ha? La risposta si leggeva nel
    // conto alla rovescia, che Mauro ha tolto dal collaudo della 2182, e
    // adesso si legge nell'ACCENSIONE della casella del Tramonto.
    //
    // **DUE TRAPPOLE, trovate misurando e non ragionando.** La prima: la
    // casella e' accesa anche quando la Runa e' semplicemente l'ELEMENTO
    // CORRENTE, cioe' fra le 18:30 e le 22:30, e in quella finestra
    // l'accensione non dice niente sul tramonto. La seconda: con una
    // posizione italiana il tramonto cade sempre PRIMA delle 22:30, quindi
    // fuori da quella finestra le due fonti concordano comunque. Serve una
    // posizione molto a ovest del suo fuso, dove il sole tramonta dopo la
    // mezzanotte: li' alle 23 l'elemento corrente e' la Notte, la stima dal
    // fuso dice tramontato e la posizione vera dice di no, e la casella
    // dichiara quale delle due sta ascoltando.
    // **LA POSIZIONE SI CALCOLA DAL FUSO DELLA MACCHINA. Ordine BZ voce 02.**
    //
    // Qui c'era la longitudine -30 battuta a mano, scelta perche' sul PC del
    // fondatore, che sta a Roma, cade sessanta gradi a ovest del proprio fuso.
    // Sul Mac di Codemagic, che gira a UTC, quei sessanta gradi diventano
    // trenta e la scena non distingue piu' niente: la prova cadeva sulla sua
    // stessa guardia ("la prova non distingue"). Cio' che conta non e' il
    // numero, e' lo SCARTO dal proprio fuso, e adesso e' quello a essere
    // scritto: sessanta gradi a ovest, ovunque la suite giri.
    final quando = DateTime(2026, 6, 21, 23, 0);
    final lon = SunsetTime.longitudineDaFuso(quando.timeZoneOffset) - 60;
    final luogo = _LuogoFinto(SkyPlace(latitude: 41.9, longitude: lon));
    final veroLaggiu = SunsetTime.perData(SunsetRune.giornoRituale(quando),
        lat: 41.9, lon: lon, offset: quando.timeZoneOffset)!;
    final stimaDalFuso = SunsetTime.perData(SunsetRune.giornoRituale(quando),
        lat: SunsetTime.latDiRipiego,
        lon: SunsetTime.longitudineDaFuso(quando.timeZoneOffset),
        offset: quando.timeZoneOffset)!;
    // ignore: avoid_print
    print('ORDINE AO VOCE 03: alle $quando, fuso ${quando.timeZoneOffset}, '
        'longitudine $lon, tramonto sulla posizione vera $veroLaggiu, stima '
        'dal fuso $stimaDalFuso');
    expect(quando.isAfter(stimaDalFuso), isTrue,
        reason: 'la prova non distingue: a quella ora la stima non e ancora '
            'passata');
    expect(quando.isBefore(veroLaggiu), isTrue,
        reason: 'la prova non distingue: a quella ora anche il tramonto vero '
            'e passato');

    await tester.pumpWidget(
        _host(DailyStrip(clock: () => quando, location: luogo)));
    await tester.pump();
    await tester.pump();
    expect(tramontoAcceso(tester), isFalse,
        reason: 'la casella del Tramonto risulta accesa alle 23 di una '
            'posizione dove il sole tramonta dopo mezzanotte: la striscia sta '
            'usando la stima dal fuso invece della posizione che le e stata '
            'data');
  });

  testWidgets('L\'header e\' centrato orizzontalmente', (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    final headerX =
        tester.getCenter(find.text('I tuoi doni del giorno')).dx;
    final stripX =
        tester.getCenter(find.byKey(const Key('santuario_daily_strip'))).dx;
    expect((headerX - stripX).abs(), lessThan(1.0));
  });

  testWidgets('Le cinque icone sono distinte, il Tramonto non e\' una luna',
      (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();

    // Ogni elemento ha la sua icona dedicata.
    for (final e in DailyElement.values) {
      expect(find.byKey(Key('daily_icon_${e.name}')), findsOneWidget);
    }

    Finder inItem(String name, Finder matching) => find.descendant(
          of: find.byKey(Key('daily_element_$name')),
          matching: matching,
        );

    // Oracolo sole pieno, Notte luna con stella, Soffio vento: icone Material
    // chiaramente diverse.
    expect(inItem('oracle', find.byIcon(Icons.wb_sunny_rounded)), findsOneWidget);
    expect(inItem('night', find.byIcon(Icons.nights_stay_rounded)),
        findsOneWidget);
    expect(inItem('breath', find.byIcon(Icons.air_rounded)), findsOneWidget);

    // Alba e Tramonto sono soli disegnati sull'orizzonte, non icone Material e
    // soprattutto mai lune: nessun'icona nei loro riquadri.
    expect(inItem('dawn', find.byType(Icon)), findsNothing);
    expect(inItem('rune', find.byType(Icon)), findsNothing);
    // E restano due disegni distinti, uno per l'alba e uno per il tramonto.
    expect(find.byKey(const Key('daily_icon_dawn')), findsOneWidget);
    expect(find.byKey(const Key('daily_icon_rune')), findsOneWidget);
  });

  testWidgets('Nessuna etichetta viene troncata, "Tramonto" resta intero',
      (tester) async {
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 13, 0))));
    await tester.pump();
    for (final label in const [
      'Alba',
      'Soffio',
      // **ARCANO E NON PIU ORACOLO**, ordine AS voce 08: il dono ha cambiato
      // natura ed e l estrazione di una carta degli Arcani Maggiori.
      'Arcano',
      'Tramonto',
      'Notte',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });


  testWidgets('Un tocco apre l\'elemento, con l\'elemento giusto', (tester) async {
    DailyElement? opened;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyStrip(
          clock: () => DateTime(2026, 7, 14, 12, 30),
          onOpen: (_, element) => opened = element,
        ),
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_breath')));
    expect(opened, DailyElement.breath);
  });

  testWidgets('Il tocco apre direttamente il rito, senza passare dal dominio',
      (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    silenceSensors(binding);
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 7, 0))));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_dawn')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    // Si apre il Rito dell'Alba, non lo schermo di dominio di un Maestro.
    expect(find.byType(DawnRiteScreen), findsOneWidget);
    expect(find.byType(DomainScreen), findsNothing);
  });

  testWidgets('Ogni elemento apre la sua esperienza', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    silenceSensors(binding);
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 19, 0))));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_rune')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(SunsetRuneScreen), findsOneWidget);
  });

  testWidgets('Il Sigillo del Sogno apre la sua esperienza', (tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    silenceSensors(binding);
    await tester.pumpWidget(_host(DailyStrip(clock: () => DateTime(2026, 7, 14, 23, 0))));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_element_night')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.byType(DreamRiteScreen), findsOneWidget);
    expect(find.byType(DomainScreen), findsNothing);
  });

  testWidgets('Il "?" apre il popup con l\'orario dentro, non l\'esperienza',
      (tester) async {
    DailyElement? opened;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyStrip(
          clock: () => DateTime(2026, 7, 14, 13, 0),
          onOpen: (_, element) => opened = element,
        ),
      ),
    ));
    await tester.pump();

    // Il cerchio "?" dell'Oracolo esiste ed e' separato dall'icona.
    expect(find.byKey(const Key('daily_help_button_oracle')), findsOneWidget);
    await tester.tap(find.byKey(const Key('daily_help_button_oracle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Si apre il popup, l'esperienza resta chiusa.
    expect(find.byKey(const Key('daily_info_oracle')), findsOneWidget);
    expect(opened, isNull);
    // Spiega quale Maestro guida l'elemento e a che ora, che vive solo qui.
    expect(find.textContaining('Medora'), findsOneWidget);
    expect(find.text('Alle 13:00'), findsOneWidget);

    // Si chiude col pulsante, mai un vicolo cieco.
    await tester.tap(find.byKey(const Key('daily_info_close_oracle')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('daily_info_oracle')), findsNothing);
  });

  testWidgets('Il popup del Sigillo del Sogno nomina il Maestro di turno',
      (tester) async {
    final now = DateTime(2026, 7, 14, 23, 0);
    await tester.pumpWidget(_host(DailyStrip(clock: () => now)));
    await tester.pump();

    await tester.tap(find.byKey(const Key('daily_help_button_night')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const Key('daily_info_night')), findsOneWidget);
    expect(find.textContaining('Maestro di turno del giorno'), findsOneWidget);
    expect(find.text('Alle 22:30'), findsOneWidget);
  });
}
