import 'package:esoteric_circle/core/astro/aspetti_di_oggi.dart';
import 'package:esoteric_circle/core/astro/carta_conservata.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/cielo_di_oggi.dart';
import 'package:esoteric_circle/core/horoscope/corrente_del_cielo.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/birth_place.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **L'ORA DI NASCITA NON SI CHIEDE A CHI L'HA DATA.** Ordine GA voce 15. Il
/// fondatore, 20 ottobre 2026: *"attualmente continua a chiedere l'ora di
/// nascita anche se gia' impostata"*.
///
/// **La causa, letta nel codice.** Chi aggiunge l'ora dopo il Risveglio la
/// salva nel profilo, e `BirthIdentityController.riprendiDa` riporta i dati
/// nuovi **tenendo la carta di prima**, calcolata senza ora; il ponte della
/// carta non ricalcola, perche' una carta c'e'; e all'avvio
/// `riprendiLaCarta` riprende dal disco quella stessa carta senza ora. Gli
/// inviti dell'Oroscopo che leggono il livello della carta (`AspettiDiOggi.
/// livello`) continuano a dire "aggiungi l'ora di nascita". Padre: ordine 2166
/// voce 4 (la carta conservata, che non dice da quali dati e' nata) e la voce
/// che ha scritto `riprendiDa` (ordine 2169), che tiene la carta quando i
/// dati cambiano.
///
/// **Cosa misura**: con l'ora appena data la carta senza ora non resta in
/// mano, ne' in memoria ne' ripresa dal disco all'avvio; la carta giusta,
/// quando arriva, resta; e senza ora la carta senza ora resta valida.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const roma = BirthPlace(
      city: 'Roma',
      latitude: 41.9,
      longitude: 12.5,
      timeZoneId: 'Europe/Rome',
      utcOffsetMinutes: 120);

  NatalChart carta({required bool conOra}) => NatalChart(
        sunSign: Zodiac.leo,
        moonSign: Zodiac.pisces,
        ascendant: conOra ? Zodiac.scorpio : null,
        ascendantLongitude: conOra ? 215.4 : null,
        hasTime: conOra,
        planets: const [
          PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: 142.0,
              sign: Zodiac.leo),
          PlanetPosition(
              id: 'moon',
              name: 'Luna',
              glyph: '☾',
              longitude: 350.0,
              sign: Zodiac.pisces),
        ],
      );

  final senzaOra = BirthIdentity.fromParts(
      birthDate: DateTime(1972, 8, 15), birthPlace: roma);
  final conOra = BirthIdentity.fromParts(
      birthDate: DateTime(1972, 8, 15),
      birthHour: 10,
      birthMinute: 30,
      birthPlace: roma);

  test("AGGIUNTA L'ORA, LA CARTA SENZA ORA NON RESTA IN MANO", () async {
    final nascita = BirthIdentityController()..riprendiDa(senzaOra);
    nascita.setBirth(nascita.details!, carta(conOra: false));
    expect(AspettiDiOggi.livello(nascita.cartaCompleta),
        isNot(LivelloPersonalizzazione.cartaCompleta));
    // La persona aggiunge l'ora dal profilo.
    nascita.riprendiDa(conOra);
    expect(nascita.details!.hasTime, isTrue);
    expect(nascita.cartaCompleta?.hasTime ?? false, isFalse,
        reason: 'non deve esserci una carta senza ora');
    expect(nascita.cartaCompleta, isNull,
        reason: "con l'ora appena data resta in mano la carta di prima, "
            "calcolata senza ora: l'Oroscopo continua a chiedere l'ora");
  });

  test("ALL'AVVIO LA CARTA SENZA ORA DEL DISCO NON SI RIPRENDE A CHI HA L'ORA",
      () async {
    await CartaConservata.conserva(carta(conOra: false));
    final nascita = BirthIdentityController()..riprendiDa(conOra);
    await nascita.riprendiLaCarta();
    expect(nascita.cartaCompleta, isNull,
        reason: "all'avvio torna dal disco la carta senza ora, e l'ora data "
            'non conta');
  });

  /// **MENTRE LA CARTA NUOVA ARRIVA NON SI CHIEDE CIO' CHE E' STATO DATO.**
  /// Buttata la carta senza ora, la nuova si calcola in rete: fino ad allora
  /// il livello ricade, e gli inviti dicevano "Completa i dati di nascita" a
  /// chi li aveva appena dati tutti. Linee Guida 11.1: un dato mancante e un
  /// calcolo che non c'e' ancora non sono la stessa cosa.
  test('MENTRE LA CARTA ARRIVA, NESSUN INVITO A RIDARE I DATI', () {
    const nessuno = CieloDiOggi.nessuno;
    expect(CorrenteDelCielo.invitoDelLivello(nessuno), isNotNull,
        reason: 'senza dati l\'invito deve restare');
    expect(
        CorrenteDelCielo.invitoDelLivello(nessuno,
            oraData: true, luogoDato: true),
        isNull,
        reason: 'a chi ha dato ora e luogo si chiede di completare i dati');
    expect(
        CorrenteDelCielo.rigaDellInvito(nessuno,
            oraData: true, luogoDato: true),
        isNull);
    expect(
        CorrenteDelCielo.notaDelLivello(nessuno,
            oraData: true, luogoDato: true),
        CorrenteDelCielo.cartaInArrivo,
        reason: 'la nota deve dire che la carta e\' in arrivo, non che '
            'mancano i dati');
    final senzaOra = CieloDiOggi(
        voci: const [],
        livello: LivelloPersonalizzazione.cartaSenzaOra,
        carta: carta(conOra: false));
    expect(
        CorrenteDelCielo.invitoDelLivello(senzaOra,
            oraData: true, luogoDato: true),
        isNull,
        reason: 'a chi ha dato l\'ora si chiede l\'ora');
    expect(
        CorrenteDelCielo.invitoDelLivello(senzaOra,
            oraData: false, luogoDato: true),
        isNotNull);
  });

  test('LA CARTA GIUSTA RESTA, E SENZA ORA LA CARTA SENZA ORA E\' VALIDA',
      () async {
    await CartaConservata.conserva(carta(conOra: true));
    final a = BirthIdentityController()..riprendiDa(conOra);
    await a.riprendiLaCarta();
    expect(a.cartaCompleta?.hasTime, isTrue);

    await CartaConservata.conserva(carta(conOra: false));
    final b = BirthIdentityController()..riprendiDa(senzaOra);
    await b.riprendiLaCarta();
    expect(b.cartaCompleta, isNotNull,
        reason: 'la cura ha buttato anche la carta di chi l\'ora non l\'ha '
            'data');
  });
}
