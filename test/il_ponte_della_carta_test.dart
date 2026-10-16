import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/ponte_della_carta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CHI IL RISVEGLIO L'HA GIA' FATTO NON RESTA SENZA CARTA.
///
/// **Perche' questa prova esiste, e cosa dice della correzione di ieri.**
/// L'ordine 2166 ha insegnato alla carta natale a conservarsi e a tornare
/// all'avvio. Ma la carta si conserva quando qualcuno la CONSEGNA alla porta
/// di lettura, e a consegnarla era solo la fine del Risveglio: chi
/// l'onboarding l'aveva gia' fatto non aveva niente sul disco, nessuno gli
/// ricalcolava la carta, e l'Oroscopo continuava a dirgli che non aveva dato
/// ora e luogo. La correzione era mezza, e mezza e' peggio di niente perche'
/// sembra fatta.
///
/// Il ponte chiude il giro. Questa prova monta i due controller INSIEME,
/// come stanno nell'app, perche' il sospetto e' un difetto di CABLAGGIO: un
/// widget montato da solo non lo coglierebbe mai.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  BirthDetails dettagliCompleti() => BirthIdentity.fromParts(
        birthDate: DateTime(1972, 8, 15),
        birthHour: 10,
        birthMinute: 30,
        birthPlace: const BirthPlace(
            city: 'Roma',
            latitude: 41.9,
            longitude: 12.5,
            timeZoneId: 'Europe/Rome',
            utcOffsetMinutes: 120),
      ).toBirthDetails();

  /// Un motore che NON tocca la rete: torna la carta che gli si dice, come
  /// farebbe l'archivio del dispositivo per chi la carta l'ha gia' calcolata
  /// una volta.
  Widget attorno({
    required BirthIdentityController identita,
    required NatalChartController motore,
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BirthIdentityController>.value(
              value: identita),
          ChangeNotifierProvider<NatalChartController>.value(value: motore),
        ],
        child: const PonteDellaCarta(
          child: MaterialApp(home: SizedBox.expand()),
        ),
      );

  testWidgets('con i dati di nascita e senza carta, il ponte la fa arrivare',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final identita = BirthIdentityController();
    // Chi ha gia' fatto il Risveglio: i dati ci sono, la carta no. E' lo
    // stato in cui si trova chiunque abbia usato l'app prima di oggi.
    identita.setBirth(dettagliCompleti(), null);
    expect(identita.chart, isNull);

    final motore = _MotoreCheHaGiaLaCarta();
    await tester.pumpWidget(attorno(identita: identita, motore: motore));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(motore.assicurato, 1,
        reason: 'Il ponte non ha chiesto al motore di assicurare la carta: '
            'chi ha gia\' fatto il Risveglio resta senza per sempre.');
    expect(identita.chart, isNotNull,
        reason: 'La carta e\' stata calcolata ma non e\' arrivata alla porta '
            'che la legge: l\'Oroscopo continuerebbe a dire il falso.');
    expect(identita.chart!.hasTime, isTrue);
  });

  testWidgets('i dati arrivano DOPO il mount, e il ponte si riarma',
      (tester) async {
    // **LA CORSA CHE IL PONTE PERDEVA.** Le altre prove preparano lo stato
    // PRIMA di montare, e cosi' il ponte trova tutto pronto al suo unico
    // tentativo di fine fotogramma. Nell'app vera non va cosi': il profilo
    // si carica dal DISCO in modo asincrono, e se il disco arriva dopo quel
    // fotogramma il ponte trovava i dati nulli, usciva e non riprovava piu'.
    // La correzione viveva o moriva a seconda di chi arrivava prima, e
    // nessuna delle prove esistenti lo coglieva.
    SharedPreferences.setMockInitialValues({});
    final identita = BirthIdentityController();
    final motore = _MotoreCheHaGiaLaCarta();

    // Si monta col controller VUOTO, come all'avvio vero.
    await tester.pumpWidget(attorno(identita: identita, motore: motore));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(motore.assicurato, 0,
        reason: 'Senza dati non si chiede niente, ed e\' giusto.');

    // E ADESSO arriva il disco, come fa il profilo a caricamento finito.
    identita.setBirth(dettagliCompleti(), null);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(motore.assicurato, greaterThanOrEqualTo(1),
        reason: 'I dati di nascita sono arrivati dopo il primo fotogramma e '
            'il ponte non si e\' riarmato: chi carica il profilo un istante '
            'piu\' tardi resta senza carta per tutta la sessione.');
    expect(identita.chart, isNotNull,
        reason: 'La carta non e\' arrivata alla porta che la legge.');
  });

  testWidgets('se la carta c\'e\' gia\', il ponte non chiede niente',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final identita = BirthIdentityController();
    identita.setBirth(dettagliCompleti(), _cartaVera());
    final motore = _MotoreCheHaGiaLaCarta();
    await tester.pumpWidget(attorno(identita: identita, motore: motore));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(motore.assicurato, 0,
        reason: 'Il ponte ha chiesto la carta pur avendola gia\': a ogni '
            'ricostruzione partirebbe una chiamata.');
  });

  testWidgets('senza dati di nascita non si chiede niente a nessuno',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final identita = BirthIdentityController();
    final motore = _MotoreCheHaGiaLaCarta();
    await tester.pumpWidget(attorno(identita: identita, motore: motore));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(motore.assicurato, 0,
        reason: 'Senza data di nascita non c\'e\' niente da calcolare, e '
            'chiederlo sarebbe una chiamata sprecata: per chi non li ha dati '
            'l\'app ha gia\' il suo ripiego dichiarato.');
    expect(identita.chart, isNull);
  });
}

NatalChart _cartaVera() => const NatalChart(
      sunSign: Zodiac.leo,
      ascendant: Zodiac.scorpio,
      ascendantLongitude: 215.4,
      hasTime: true,
      planets: [
        PlanetPosition(
            id: 'sun',
            name: 'Sole',
            glyph: '☉',
            longitude: 142.0,
            sign: Zodiac.leo),
      ],
    );

/// Il motore che la carta ce l'ha gia' nel suo archivio: e' il caso vero di
/// chi ha calcolato la carta una volta e poi ha solo riaperto l'app.
class _MotoreCheHaGiaLaCarta extends NatalChartController {
  int assicurato = 0;

  @override
  Future<void> assicura(BirthDetails details) async {
    assicurato++;
    chart = _cartaVera();
    status = ChartStatus.ready;
    notifyListeners();
  }
}
