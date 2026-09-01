import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart' as astro;
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/transiti_del_giorno.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/core/horoscope/riflessione_del_cielo.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/tempo/confine_del_giorno.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL RESPONSO E' LO STESSO FINO A MEZZANOTTE. Ordine BK voce 06.
///
/// Parole del fondatore: "controlla che il risultato sia uguale fino a
/// mezzanotte. mi sembra che era questa la regola".
///
/// **Questa voce non costruisce la regola: la BLOCCA.** La regola esiste gia'
/// nel codice, e da prima di quest'ordine: il seme e' su segno, giorno
/// dell'anno, anno e dominio, e l'istante dei transiti e' fissato alle 12 UTC
/// del giorno civile deciso da `ConfineDelGiorno`. L'ora del giorno non entra
/// da nessuna delle due parti. Ma nessuna prova la sorvegliava, e una regola
/// che nessuno sorveglia e' una regola che il prossimo rifacimento puo'
/// rompere in silenzio: basterebbe un `DateTime.now()` infilato dentro un
/// calcolo per far cambiare il responso a ogni apertura, e nessuno se ne
/// accorgerebbe fino a quando qualcuno non lo nota sul telefono.
void main() {
  final carta = NatalChart(
    sunSign: Zodiac.leo,
    planets: const [
      PlanetPosition(
          id: 'sun',
          name: 'Sole',
          glyph: '☉',
          longitude: 128.4,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'moon',
          name: 'Luna',
          glyph: '☽',
          longitude: 12.7,
          sign: Zodiac.leo),
      PlanetPosition(
          id: 'mars',
          name: 'Marte',
          glyph: '♂',
          longitude: 61.9,
          sign: Zodiac.leo),
    ],
    ascendantLongitude: 205.0,
    midheavenLongitude: 115.0,
    houses: [
      for (var n = 1; n <= 12; n++)
        HouseCusp(number: n, longitude: (205.0 + (n - 1) * 30.0) % 360.0),
    ],
    hasTime: true,
  );

  /// Il responso intero per un istante: i quattro testi, l'apertura, il numero
  /// fortunato e il colore del giorno, in una stringa sola da confrontare
  /// carattere per carattere.
  String responsoIntero(DateTime istante) {
    final cielo = CieloDiOggi.perIlGiorno(adesso: istante, carta: carta);
    final pezzi = <String>[
      Horoscope.openingFor(
        sign: Zodiac.leo,
        dayOfYear: Horoscope.dayOfYear(istante),
        year: istante.year,
        vocative: 'Cara Sofia',
      ),
    ];
    for (final d in HoroscopeDomain.values) {
      final c = Horoscope.cardFor(
        sign: Zodiac.leo,
        dayOfYear: Horoscope.dayOfYear(istante),
        year: istante.year,
        domain: d,
        cielo: cielo,
        profonda: false,
      );
      pezzi.add('${d.name}|${c.text}|${c.synthesis}|${c.indicator}|'
          '${c.luckyNumber}|${c.dayColor}');
    }
    return pezzi.join('\n');
  }

  group('dentro lo stesso giorno civile il responso non cambia mai', () {
    test('a otto istanti sparsi nella giornata, il responso e\' IDENTICO', () {
      // Dalla notte fonda all'ultimo minuto prima di mezzanotte.
      final istanti = [
        DateTime(2026, 8, 5, 0, 0),
        DateTime(2026, 8, 5, 0, 1),
        DateTime(2026, 8, 5, 6, 30),
        DateTime(2026, 8, 5, 11, 59),
        DateTime(2026, 8, 5, 12, 0),
        DateTime(2026, 8, 5, 12, 1),
        DateTime(2026, 8, 5, 18, 45),
        DateTime(2026, 8, 5, 23, 59),
      ];
      final primo = responsoIntero(istanti.first);
      for (final i in istanti.skip(1)) {
        expect(responsoIntero(i), primo,
            reason: 'il responso delle ${i.hour}:${i.minute} non e\' identico '
                'a quello di mezzanotte e un minuto: qualcosa nel calcolo '
                'guarda l\'ora, e il fondatore leggerebbe due oroscopi diversi '
                'nello stesso giorno');
      }
    });

    test('anche l\'istante dei transiti e\' lo stesso in tutta la giornata',
        () {
      final mattina = TransitiDelGiorno.istanteDi(DateTime(2026, 8, 5, 6));
      final sera = TransitiDelGiorno.istanteDi(DateTime(2026, 8, 5, 23, 59));
      expect(sera, mattina,
          reason: 'l\'istante dei transiti si sposta durante il giorno: e\' la '
              'seconda strada per cui il responso cambierebbe');
      expect(mattina.hour, TransitiDelGiorno.oraDelloScatto);
    });
  });

  group('attraversando il confine il responso cambia', () {
    test('il giorno dopo il responso e\' DIVERSO', () {
      final oggi = responsoIntero(DateTime(2026, 8, 5, 23, 59));
      final domani = responsoIntero(DateTime(2026, 8, 6, 0, 0));
      expect(domani, isNot(oggi),
          reason: 'passata la mezzanotte il responso deve cambiare, o non '
              'sarebbe l\'oroscopo DEL GIORNO');
    });

    test('il confine e\' quello di ConfineDelGiorno, non un altro', () {
      expect(ConfineDelGiorno.chiaveDi(DateTime(2026, 8, 5, 23, 59)),
          ConfineDelGiorno.chiaveDi(DateTime(2026, 8, 5, 0, 0)));
      expect(ConfineDelGiorno.chiaveDi(DateTime(2026, 8, 6, 0, 0)),
          isNot(ConfineDelGiorno.chiaveDi(DateTime(2026, 8, 5, 23, 59))));
    });
  });

  group('il giorno dell\'anno non cambia dentro il giorno', () {
    // **IL DIFETTO CHE QUESTA PROVA HA TROVATO, e che ha abbattuto una
    // premessa dell'ordine.** BK.06 dava per esistente la regola del responso
    // stabile. Falso per sette mesi l'anno: `dayOfYear` sottraeva due date e
    // `inDays` misura una DURATA, non giorni di calendario. Fra il primo
    // gennaio e agosto, in Italia, c'e' il passaggio all'ora legale, quindi
    // alle 00:00 del 5 agosto 2026 la formula dava 215 e dalle 01:00 dava 216:
    // il responso cambiava alle una di notte, e nella prima ora del giorno
    // l'Oroscopo era ancora quello di ieri. In UTC non si vedeva, ed e' per
    // questo che nessuna prova lo prendeva.
    test('a ogni ora dello stesso giorno il numero e\' lo stesso', () {
      for (final giorno in [
        DateTime(2026, 8, 5), // ora legale
        DateTime(2026, 1, 5), // ora solare
        DateTime(2026, 3, 29), // il giorno del cambio, in avanti
        DateTime(2026, 10, 25), // il giorno del cambio, indietro
        DateTime(2028, 2, 29), // bisestile
      ]) {
        final atteso = Horoscope.dayOfYear(giorno);
        for (var ora = 0; ora < 24; ora++) {
          final istante =
              DateTime(giorno.year, giorno.month, giorno.day, ora, 30);
          expect(Horoscope.dayOfYear(istante), atteso,
              reason: 'il ${giorno.day}/${giorno.month} alle $ora:30 il giorno '
                  'dell\'anno vale ${Horoscope.dayOfYear(istante)} invece di '
                  '$atteso: l\'indice cambia DENTRO il giorno, quindi il '
                  'responso cambia con lui');
        }
      }
    });

    test('e i giorni consecutivi sono consecutivi', () {
      // Non basta che sia stabile: deve anche essere giusto. Attraversando il
      // cambio dell'ora il numero deve salire di uno e non di zero ne' di due.
      for (final primo in [
        DateTime(2026, 3, 28),
        DateTime(2026, 10, 24),
        DateTime(2026, 12, 30),
      ]) {
        final dopo = DateTime(primo.year, primo.month, primo.day + 1);
        expect(Horoscope.dayOfYear(dopo), Horoscope.dayOfYear(primo) + 1,
            reason: 'fra il ${primo.day}/${primo.month} e il giorno dopo '
                'l\'indice non sale esattamente di uno');
      }
    });

    test('la formula vecchia non torna in nessuno dei cinque file', () {
      // **LA GRANDEZZA STRUTTURALE, perche' la misura sopra e' cieca in UTC.**
      // Dove l'ora legale non esiste il difetto non si manifesta: una prova
      // che si affidasse solo ai numeri sarebbe verde su questa macchina e
      // rossa sul telefono del fondatore. Questa riga invece cade ovunque.
      final sorvegliati = [
        'lib/core/horoscope/horoscope.dart',
        'lib/core/horoscope/corrente_del_cielo.dart',
        'lib/core/horoscope/cielo_di_oggi.dart',
        'lib/core/astro/transiti_del_giorno.dart',
        'lib/core/tempo/confine_del_giorno.dart',
      ];
      final colpevoli = <String>[];
      for (final percorso in sorvegliati) {
        final righe = File(percorso).readAsLinesSync();
        for (var i = 0; i < righe.length; i++) {
          final r = righe[i];
          if (r.trimLeft().startsWith('//') || r.trimLeft().startsWith('///')) {
            continue;
          }
          if (RegExp(r'difference\(DateTime\(').hasMatch(r)) {
            colpevoli.add('$percorso:${i + 1}');
          }
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'questi punti contano i giorni sottraendo due date locali, '
              'che con l\'ora legale non fa giorni interi: usa '
              'ConfineDelGiorno.giornoDellAnno. ${colpevoli.join(', ')}');
    });
  });

  test('nessuno dei calcoli del responso guarda l\'orologio di sistema', () {
    // **PERCHE' QUESTA PROVA ESISTE, ed e' una lezione della prova del rosso.**
    // L'ordine chiede di dimostrare che la guardia cade "facendo dipendere il
    // seme dall'ora". Provato: mettendo `DateTime.now().hour` dentro
    // `baseSeed`, le prove qui sopra restavano VERDI, perche' in prova
    // l'orologio di sistema e' fermo e tutti i responsi cambiavano allo stesso
    // modo. Una guardia cieca al difetto che porta il nome non e' una guardia,
    // e la regola di casa dice di cambiare la grandezza misurata, mai la
    // soglia. La grandezza giusta e' questa: nei file che compongono il
    // responso l'orologio di sistema non si legge affatto. Il giorno arriva
    // dall'alto, come parametro, e chi lo passa e' la schermata.
    final sorvegliati = [
      'lib/core/horoscope/horoscope.dart',
      'lib/core/horoscope/corrente_del_cielo.dart',
      'lib/core/horoscope/cielo_di_oggi.dart',
      'lib/core/astro/transiti_del_giorno.dart',
      'lib/core/tempo/confine_del_giorno.dart',
    ];
    final colpevoli = <String>[];
    for (final percorso in sorvegliati) {
      final file = File(percorso);
      expect(file.existsSync(), isTrue, reason: '$percorso non esiste piu\'');
      final righe = file.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        if (r.trimLeft().startsWith('//') || r.trimLeft().startsWith('///')) {
          continue;
        }
        if (r.contains('DateTime.now()')) colpevoli.add('$percorso:${i + 1}');
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'questi punti leggono l\'orologio di sistema mentre compongono '
            'il responso, quindi il risultato puo\' cambiare dentro lo stesso '
            'giorno: ${colpevoli.join(', ')}');
  });

  // ------------------------------------------------------------------
  // L'IPOTESI DA MISURARE, che l'ordine chiede di non saltare.
  // ------------------------------------------------------------------
  testWidgets('LA SCHERMATA GIA\' VIVA A CAVALLO DELLA MEZZANOTTE: cosa mostra',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(360, 797) * 3.0;
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final nascita = BirthIdentityController();
    nascita.setBirth(
      BirthDetails(
        date: DateTime(1990, 8, 10),
        time: const TimeOfDay(hour: 12, minute: 0),
        place: const astro.BirthPlace(
            label: 'Roma',
            latitude: 41.9,
            longitude: 12.5,
            timezone: 'Europe/Rome'),
      ),
      carta,
    );
    // La schermata nasce un minuto PRIMA della mezzanotte.
    final primaDiMezzanotte = DateTime(2026, 8, 5, 23, 59);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<BirthIdentityController>.value(value: nascita),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: OroscopoScreen(userSign: Zodiac.leo, now: primaDiMezzanotte),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // La data mostrata e' quella di nascita della schermata.
    expect(find.text(italianLongDate(primaDiMezzanotte)), findsOneWidget);

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await tester.pump(RiflessioneDelCielo.finoAllUltimaScheda(
        HoroscopeDomain.values.length,
        piena: true));
    await tester.pump(const Duration(milliseconds: 200));

    // **DUE MINUTI DOPO, LA MEZZANOTTE E' PASSATA.** Il tempo scorre nella
    // prova, ma la schermata ha letto il suo giorno UNA VOLTA SOLA quando e'
    // nata: `_date = widget.now ?? DateTime.now()`, campo `late final`.
    await tester.pump(const Duration(minutes: 2));

    // **IL FATTO MISURATO, dichiarato e non curato in quest'ordine.** La
    // schermata gia' viva continua a mostrare il giorno vecchio: la data in
    // testa resta quella di ieri, e i testi restano quelli di ieri. Non e' un
    // difetto che nasce da BK: e' come si comporta da sempre, e l'ordine
    // chiede di misurarlo senza applicare la cura.
    expect(find.text(italianLongDate(primaDiMezzanotte)), findsOneWidget,
        reason: 'MISURA BK.06: passata la mezzanotte, la schermata GIA\' VIVA '
            'mostra ancora il giorno in cui e\' stata aperta. Se un giorno '
            'questa riga cadesse, vorrebbe dire che qualcuno ha messo la cura: '
            'allora si aggiorni questa prova, non la si cancelli');
    expect(find.text(italianLongDate(DateTime(2026, 8, 6, 0, 1))), findsNothing,
        reason: 'la schermata gia\' viva NON passa da sola al giorno nuovo');

    await tester.pump(const Duration(seconds: 8));
  });
}
