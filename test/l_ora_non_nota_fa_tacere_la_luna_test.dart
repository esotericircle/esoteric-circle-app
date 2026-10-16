import 'package:esoteric_circle/core/synastry_evolutiva/cielo_evolutivo.dart';
import 'package:esoteric_circle/core/synastry_evolutiva/il_composito_e_keplero.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ORA NON NOTA FA TACERE LA LUNA.** Ordine FT voce FT.03: "L'ora di
/// nascita sconosciuta si dichiara a video: i punti che ne dipendono tacciono
/// invece di essere indovinati". La Luna fa circa tredici gradi al giorno:
/// dal mezzogiorno convenzionale puo' stare fino a sei gradi e mezzo dal
/// vero, oltre l'orbo del sestile. Gli altri dieci punti restano.
void main() {
  final conOra = CieloEvolutivo.perNascita(
      momentoUtc: DateTime.utc(1992, 9, 3, 12), nome: 'Giulia');
  final senzaOra = CieloEvolutivo.perNascita(
      momentoUtc: DateTime.utc(1992, 9, 3, 12), oraNota: false, nome: 'Giulia');
  final tuo = CieloEvolutivo.perNascita(
      momentoUtc: DateTime.utc(1990, 5, 12, 14, 30), nome: 'Tu');

  test('senza ora la Luna non c\'e\', gli altri dieci punti si', () {
    expect(conOra.longitudini.containsKey(PuntoDelCieloEvolutivo.luna), isTrue);
    expect(
        senzaOra.longitudini.containsKey(PuntoDelCieloEvolutivo.luna), isFalse,
        reason: 'la Luna di un cielo senza ora e\' indovinata, non calcolata');
    expect(senzaOra.longitudini.length, 10);
  });

  test('nessun aspetto, nessun punto medio e nessuna corda nominano la Luna',
      () {
    final aspetti = AspettiEvolutivi.fra(tuo, senzaOra);
    expect(aspetti.where((a) => a.suo == PuntoDelCieloEvolutivo.luna), isEmpty);
    final composito = IlComposito.fra(tuo, senzaOra);
    expect(composito.punti.containsKey(PuntoDelCieloEvolutivo.luna), isFalse);
    expect(composito.aspetto?.a, isNot(PuntoDelCieloEvolutivo.luna));
    expect(composito.aspetto?.b, isNot(PuntoDelCieloEvolutivo.luna));
    final corde = IntervalliDiKeplero.fra(tuo, senzaOra);
    expect(corde.where((c) => c.suo == PuntoDelCieloEvolutivo.luna), isEmpty);
    // Con l'ora nota le due Lune ci sono, e la corda si suona.
    expect(
        IntervalliDiKeplero.fra(tuo, conOra)
            .where((c) => c.suo == PuntoDelCieloEvolutivo.luna),
        isNotEmpty);
  });
}
