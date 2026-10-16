import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/meeus/il_cielo_di_meeus.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/synastry/cielo_del_giorno_sulla_coppia.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL CIELO DEL GIORNO E' UNA PORTA SOLA, E LA VIP NON SE NE ACCORGE.**
/// Ordine FT voci FT.09 e FT.10, 14 ottobre 2026.
///
/// Il calcolo di quanto i transiti accendono i contatti di una coppia stava
/// dentro `MoltiplicatoreCeleste.per`, legato ai tipi della Sinastria VIP.
/// L'ordine FT chiede di usarlo per "Oggi fra voi" senza far nascere una
/// seconda porta, e la regola R9 chiede che nessun file della VIP cambi
/// comportamento. Il nucleo e' uscito in `MoltiplicatoreCeleste.accensione`;
/// qui sotto **l'algoritmo di prima, copiato alla lettera dal commit
/// ce7906e5**, fa da riferimento: su trecento coppie e giorni a caso (seme
/// fisso) il moltiplicatore, il transito e l'aspetto acceso devono essere
/// identici al bit.
({double valore, CorpoCeleste? transito, AspettoDiSinastria? acceso})
    _comePrima(List<AspettoDiSinastria> aspetti, CieloDiSinastria tuo,
        CieloDiSinastria suo, DateTime giorno) {
  if (aspetti.isEmpty) {
    return (valore: MoltiplicatoreCeleste.neutro, transito: null, acceso: null);
  }
  final jd = Celestial.julianDay(
      DateTime.utc(giorno.year, giorno.month, giorno.day, 12));
  final transiti = IlCieloDiMeeus.tutte(jd);
  var somma = 0.0;
  CorpoCeleste? migliore;
  AspettoDiSinastria? acceso;
  var forzaMigliore = 0.0;
  for (final a in aspetti) {
    final peso = a.forzaCon(AspettiDiSinastria.orbo[a.tipo]!);
    if (peso <= 0) continue;
    final gradi = <double>[
      if (tuo.longitudini[a.tuo] != null) tuo.longitudini[a.tuo]!,
      if (suo.longitudini[a.suo] != null) suo.longitudini[a.suo]!,
    ];
    for (final voce in transiti.entries) {
      for (final grado in gradi) {
        for (final tipo in AspectType.values) {
          final candidato = ChartAspect(
              aLongitude: voce.value, bLongitude: grado, type: tipo);
          final ammesso = MoltiplicatoreCeleste.orboPer(voce.key, tipo);
          if (candidato.orbe > ammesso) continue;
          final acceso1 = (1 - candidato.orbe / ammesso).clamp(0.0, 1.0);
          final forza = acceso1 * peso;
          somma += forza;
          if (forza > forzaMigliore) {
            forzaMigliore = forza;
            migliore = voce.key;
            acceso = a;
          }
          break;
        }
      }
    }
  }
  const riferimento = 1.6;
  final quota = somma / (somma + riferimento);
  return (
    valore: MoltiplicatoreCeleste.minimo +
        quota * (MoltiplicatoreCeleste.massimo - MoltiplicatoreCeleste.minimo),
    transito: migliore,
    acceso: acceso,
  );
}

void main() {
  test('il moltiplicatore della VIP e\' identico a prima, al bit', () {
    final caso = math.Random(20261014);
    DateTime unGiorno(int daAnno, int anni) => DateTime.utc(daAnno)
        .add(Duration(days: caso.nextInt(365 * anni), hours: caso.nextInt(24)));
    var accesi = 0;
    for (var i = 0; i < 300; i++) {
      final tuo = CieloDiSinastria.perNascita(
          momentoUtc: unGiorno(1950, 60),
          latitudine: 45,
          longitudineDelLuogo: 9,
          oraNota: caso.nextBool());
      final suo = CieloDiSinastria.perNascita(
          momentoUtc: unGiorno(1950, 60),
          latitudine: null,
          longitudineDelLuogo: null);
      final aspetti = AspettiDiSinastria.fra(tuo, suo);
      final giorno = unGiorno(2026, 2);
      final prima = _comePrima(aspetti, tuo, suo, giorno);
      final adesso = MoltiplicatoreCeleste.per(
          aspetti: aspetti, tuo: tuo, suo: suo, giorno: giorno);
      expect(adesso.valore, prima.valore, reason: 'coppia $i, valore');
      expect(adesso.transito, prima.transito, reason: 'coppia $i, transito');
      expect(identical(adesso.aspettoAcceso, prima.acceso), isTrue,
          reason: 'coppia $i, aspetto acceso');
      if (prima.transito != null) accesi++;
    }
    // La prova guarda davvero: la maggior parte delle coppie ha un transito.
    expect(accesi, greaterThan(150));
  });

  test('i filtri della porta restringono e basta', () {
    final contatti = [
      (peso: 1.0, gradi: <double>[0.0, 120.0]),
    ];
    final giorno = DateTime.utc(2026, 10, 14);
    final tutti =
        MoltiplicatoreCeleste.accensione(contatti: contatti, giorno: giorno);
    final soloLaLuna = MoltiplicatoreCeleste.accensione(
        contatti: contatti, giorno: giorno, transiti: {CorpoCeleste.luna});
    expect(soloLaLuna.somma, lessThanOrEqualTo(tutti.somma));
    expect(
        soloLaLuna.transito == null || soloLaLuna.transito == CorpoCeleste.luna,
        isTrue);
  });
}
