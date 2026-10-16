import 'package:esoteric_circle/core/astro/solar_time.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'ora del tramonto NOAA, offline: invarianti fisiche verificate.
void main() {
  // Minuti dalla mezzanotte locale del tramonto, per confronti comodi.
  int? minuti(DateTime giorno, {required double lat, required double lon}) {
    final t =
        SunsetTime.perData(giorno, lat: lat, lon: lon, offset: Duration.zero);
    return t == null ? null : t.hour * 60 + t.minute;
  }

  test('A 45 gradi nord il tramonto di giugno e\' piu\' tardi di dicembre', () {
    final giugno = minuti(DateTime(2026, 6, 21), lat: 45, lon: 0)!;
    final dicembre = minuti(DateTime(2026, 12, 21), lat: 45, lon: 0)!;
    expect(giugno, greaterThan(dicembre));
    // Divario ampio, come si conviene a mezza estate contro mezzo inverno.
    expect(giugno - dicembre, greaterThan(120));
  });

  test('Nell\'emisfero sud il verso e\' rovesciato', () {
    final giugno = minuti(DateTime(2026, 6, 21), lat: -45, lon: 0)!;
    final dicembre = minuti(DateTime(2026, 12, 21), lat: -45, lon: 0)!;
    expect(dicembre, greaterThan(giugno));
  });

  test('Ai due equinozi il tramonto e\' vicino alle diciotto', () {
    // Nei due equinozi del 2026, di primavera e d'autunno, il giorno e la notte
    // si equivalgono: a longitudine e fuso zero il tramonto cade presso le 18.
    final primavera = minuti(DateTime(2026, 3, 20), lat: 45, lon: 0)!;
    final autunno = minuti(DateTime(2026, 9, 23), lat: 45, lon: 0)!;
    expect(primavera, inInclusiveRange(17 * 60, 18 * 60 + 30));
    expect(autunno, inInclusiveRange(17 * 60, 18 * 60 + 30));
    // I due valori restano vicini fra loro, a meno dell'equazione del tempo.
    expect((primavera - autunno).abs(), lessThan(30));
  });

  test('Il tramonto cade sempre dentro le ventiquattro ore', () {
    for (var mese = 1; mese <= 12; mese++) {
      for (final lat in const [-60.0, -30.0, 0.0, 30.0, 45.0, 60.0]) {
        final t = SunsetTime.perData(DateTime(2026, mese, 15),
            lat: lat, lon: 12, offset: const Duration(hours: 1));
        if (t == null) continue;
        expect(t.hour, inInclusiveRange(0, 23), reason: '$mese $lat');
        expect(t.minute, inInclusiveRange(0, 59));
      }
    }
  });

  test('Ai poli non tramonta ne sorge: null, mai un\'eccezione', () {
    // Giugno a 89 nord: giorno polare, il Sole non tramonta.
    expect(
        SunsetTime.perData(DateTime(2026, 6, 21),
            lat: 89, lon: 0, offset: Duration.zero),
        isNull);
    // Dicembre a 89 nord: notte polare, il Sole non sorge.
    expect(
        SunsetTime.perData(DateTime(2026, 12, 21),
            lat: 89, lon: 0, offset: Duration.zero),
        isNull);
    // E l'ora media c'e' sempre come ripiego.
    expect(SunsetTime.oraMedia(DateTime(2026, 6, 21)).hour, 18);
  });

  test('La longitudine stimata dal fuso e\' quindici gradi per ora', () {
    expect(SunsetTime.longitudineDaFuso(const Duration(hours: 2)), 30.0);
    expect(SunsetTime.longitudineDaFuso(const Duration(hours: -5)), -75.0);
  });

  test('Il fuso sposta l\'ora ma non la data del calcolo', () {
    // Roma d'estate, circa 15 gradi est, fuso piu' due.
    final t = SunsetTime.perData(DateTime(2026, 6, 21),
        lat: 41.9, lon: 12.5, offset: const Duration(hours: 2));
    expect(t, isNotNull);
    // Il tramonto di mezza estate a Roma cade la sera, dopo le venti.
    expect(t!.hour, inInclusiveRange(20, 21));
  });

  test('A fuso piu\' dodici il tramonto cade nella data locale attesa', () {
    // Estremo est, circa 180 gradi, fuso piu' dodici: il tramonto del giorno
    // locale deve cadere in quel giorno, non scivolare al precedente o al dopo.
    final giorno = DateTime(2026, 6, 21);
    final t = SunsetTime.perData(giorno,
        lat: 45, lon: 179, offset: const Duration(hours: 12));
    expect(t, isNotNull);
    expect(t!.year, giorno.year);
    expect(t.month, giorno.month);
    expect(t.day, giorno.day);
    // Ed e' una sera vera, non un'ora impossibile.
    expect(t.hour, inInclusiveRange(18, 22));
  });

  test('A fuso meno undici il tramonto cade nella data locale attesa', () {
    // Estremo ovest, circa 165 gradi ovest, fuso meno undici.
    final giorno = DateTime(2026, 12, 21);
    final t = SunsetTime.perData(giorno,
        lat: 45, lon: -165, offset: const Duration(hours: -11));
    expect(t, isNotNull);
    expect(t!.year, giorno.year);
    expect(t.month, giorno.month);
    expect(t.day, giorno.day);
    // Inverno boreale: sera d'inverno, tramonto presto ma comunque di pomeriggio.
    expect(t.hour, inInclusiveRange(15, 18));
  });
}
