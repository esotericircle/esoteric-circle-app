import 'dart:io';

import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/horoscope/i_testi_eu.dart';
import 'package:esoteric_circle/core/horoscope/la_lettura_vedica.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **L'OROSCOPO SI APRE SUBITO.** Ordine GA voce 14. Il fondatore, 20
/// ottobre 2026: *"l'apertura della funzionalita' Oroscopo impiega qualche
/// secondo ad aprirsi, non e' immediata come le altre. La scheda pulsante
/// resta premuto qualche secondo e l'app si congela, poi si apre"*.
///
/// **La causa, misurata prima di curare**: alla prima apertura le schede del
/// Giorno chiedevano la storia delle fasce di ogni giorno dal 1 gennaio 2026
/// (`ITestiEu.indiceDelGiorno`), nel `build` della schermata: 2.217
/// millisecondi sul PC per 292 giorni, e il conto cresce di un giorno ogni
/// giorno. Padre: ordine EU voce 17 (la regola della scelta delle voci,
/// "contando quante volte la stessa fascia e' gia' tornata", calcolata nel
/// filo dell'interfaccia e mai conservata).
///
/// **Cosa misura**: con la preparazione avviata le schede si compongono in
/// meno di trecento millisecondi; a storia pronta i testi sono quelli del
/// calcolo di prima, carattere per carattere; la storia conservata si
/// rilegge senza ricalcolarla; e la schermata avvia la preparazione prima di
/// comporre le schede e fa aspettare il responso.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const carta = NatalChart(
    sunSign: Zodiac.gemini,
    moonSign: Zodiac.pisces,
    ascendant: Zodiac.scorpio,
    ascendantLongitude: 215.4,
    hasTime: true,
    planets: [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '☉',
          longitude: 84.0,
          sign: Zodiac.gemini),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: '☾',
          longitude: 350.0,
          sign: Zodiac.pisces),
      PlanetPosition(
          id: 'mars',
          name: 'Marte',
          glyph: '♂',
          longitude: 200.0,
          sign: Zodiac.libra),
    ],
  );
  final oggi = DateTime(2026, 10, 20, 9);
  const giorno = 292;
  final cielo = CieloDiOggi.perIlGiorno(adesso: oggi, carta: carta);

  List<String> testi() => [
        for (final c in Horoscope.forSign(
            sign: Zodiac.gemini,
            dayOfYear: giorno,
            year: 2026,
            cielo: cielo,
            nascita: DateTime(1990, 6, 15)))
          '${c.title}|${c.text}',
      ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ITestiEu.dimentica();
    // **LA STRADA VERA, L'ISOLATE**: sotto `flutter test` e' spenta per le
    // prove col tempo finto; qui il tempo e' vero e si prova lei.
    ITestiEu.nelFiloSeparato = true;
  });
  tearDown(() => ITestiEu.nelFiloSeparato = false);

  test(
      'CON LA PREPARAZIONE AVVIATA LE SCHEDE SI COMPONGONO SUBITO, E A '
      'STORIA PRONTA I TESTI SONO QUELLI DI PRIMA', () async {
    // Il riferimento: il calcolo di prima, tutto nel filo.
    final vecchi = testi();
    ITestiEu.dimentica();

    final preparazione = Horoscope.preparaLaStoria(
        Zodiac.gemini, carta, DateTime(2026, 1, 1 + giorno));
    final cronometro = Stopwatch()..start();
    testi();
    cronometro.stop();
    expect(cronometro.elapsedMilliseconds, lessThan(300),
        reason: 'con la storia in preparazione le schede la calcolano '
            'ancora nel filo: ${cronometro.elapsedMilliseconds} ms, il tocco '
            'resta premuto');
    await preparazione;
    expect(testi(), vecchi,
        reason: 'la storia preparata fuori dal filo da\' testi diversi dal '
            'calcolo di prima: la regola della scelta e\' cambiata');
  });

  test('ANCHE LA VEDICA COL LUOGO SI COMPONE SUBITO, CON GLI STESSI TESTI',
      () async {
    final nascita =
        NascitaDeiSegni(locale: DateTime(1990, 6, 15, 10, 30), oraNota: true);
    const roma = LuogoDelGiorno(lat: 41.9, lon: 12.5, citta: 'Roma');
    List<String> vediche() => [
          for (final c in LaLetturaVedica.schede(
              adesso: oggi, nascita: nascita, luogo: roma)!)
            '${c.title}|${c.text}',
        ];
    LaLetturaVedica.dimentica();
    final vecchie = vediche();
    LaLetturaVedica.dimentica();
    ITestiEu.dimentica();

    final preparazione =
        LaLetturaVedica.prepara(adesso: oggi, nascita: nascita, luogo: roma);
    final cronometro = Stopwatch()..start();
    vediche();
    cronometro.stop();
    expect(cronometro.elapsedMilliseconds, lessThan(300),
        reason: 'con la vedica in preparazione le schede la calcolano nel '
            'filo: ${cronometro.elapsedMilliseconds} ms');
    await preparazione;
    expect(LaLetturaVedica.pronta(adesso: oggi, nascita: nascita, luogo: roma),
        isTrue);
    expect(vediche(), vecchie,
        reason: 'la vedica preparata fuori dal filo da\' testi diversi');
  });

  test('LA STORIA CONSERVATA SI RILEGGE SENZA RICALCOLARLA', () async {
    final quando = DateTime(2026, 1, 1 + giorno);
    await Horoscope.preparaLaStoria(Zodiac.gemini, carta, quando);
    ITestiEu.dimentica();
    var chiamate = 0;
    await ITestiEu.prepara(
      chiave: Horoscope.chiaveDellaStoria(Zodiac.gemini, carta),
      oggi: quando,
      livelli: (g) {
        chiamate++;
        return Horoscope.livelliDelGiorno(Zodiac.gemini, carta, g);
      },
    );
    expect(chiamate, 0,
        reason: 'la storia conservata non si rilegge: si ricalcola ogni volta');
    expect(
        ITestiEu.pronta(
            Horoscope.chiaveDellaStoria(Zodiac.gemini, carta), quando),
        isTrue);
  });

  test(
      'LA SCHERMATA AVVIA LA PREPARAZIONE PRIMA DELLE SCHEDE E FA ASPETTARE '
      'IL RESPONSO', () {
    final s =
        File('lib/features/horoscope/oroscopo_screen.dart').readAsStringSync();
    final prepara = s.indexOf('Horoscope.preparaLaStoria(');
    final schede = s.indexOf('final cards = schedeAltre ??');
    expect(prepara, greaterThan(0),
        reason: 'la schermata non prepara la storia fuori dal filo');
    expect(prepara, lessThan(schede),
        reason: 'la preparazione parte dopo le schede: le schede la '
            'calcolano nel filo');
    expect(s.contains('ITestiEu.attesaDi('), isTrue,
        reason: 'il responso non aspetta la storia: mostrerebbe un testo '
            'provvisorio');
  });
}
