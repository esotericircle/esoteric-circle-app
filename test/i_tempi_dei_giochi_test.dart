// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/cerchio/i_tempi_dei_giochi.dart';
import 'package:flutter_test/flutter_test.dart';

/// I TEMPI DEI GIOCHI. Ordine FF voce 07: ogni gioco aperto ha una
/// scadenza, e un gioco scaduto si chiude da solo.
void main() {
  test('la Prova cambia il lunedi\' ed e\' la stessa settimana per tutti', () {
    // Mercoledi' 7 ottobre 2026: la settimana comincia lunedi' 5.
    final mercoledi = DateTime(2026, 10, 7, 15, 30);
    expect(ITempiDeiGiochi.settimanaDi(mercoledi), '2026-10-05');
    expect(ITempiDeiGiochi.settimanaDi(DateTime(2026, 10, 11, 23, 59)),
        '2026-10-05');
    expect(ITempiDeiGiochi.settimanaDi(DateTime(2026, 10, 12)), '2026-10-12');
    expect(ITempiDeiGiochi.scadenza(GiocoDelCerchio.prova, mercoledi),
        DateTime(2026, 10, 12));
  });

  test('la sfida a due dura ventiquattro ore, l\'indovinello non scade', () {
    final inizio = DateTime(2026, 10, 7, 21);
    final fine = ITempiDeiGiochi.scadenza(GiocoDelCerchio.sfidaADue, inizio)!;
    expect(fine, DateTime(2026, 10, 8, 21));
    expect(
        ITempiDeiGiochi.scaduto(fine, DateTime(2026, 10, 8, 20, 59)), isFalse);
    expect(ITempiDeiGiochi.scaduto(fine, DateTime(2026, 10, 8, 21)), isTrue);
    expect(ITempiDeiGiochi.resta(fine, DateTime(2026, 10, 9)), Duration.zero);
    expect(
        ITempiDeiGiochi.scadenza(GiocoDelCerchio.indovinello, inizio), isNull);
  });

  test('il Pellegrinaggio finisce con la luna piena della porta del cielo', () {
    // La luna piena di ottobre 2026 e' il 26 mattina, ora italiana: misurata
    // sulla porta, l'elongazione della Luna e' 177,1 gradi alla mezzanotte
    // del 26 e 183,8 a mezzogiorno. L'evento "luna piena" dei Doni comincia
    // invece il 24, con la luce oltre il 96 per cento: la prima stesura
    // chiudeva il Pellegrinaggio li', due giorni prima.
    final luna = ITempiDeiGiochi.prossimaLunaPiena(DateTime(2026, 10, 7))!;
    print('ORDINE FF VOCE 07: prossima luna piena dal 7 ottobre 2026: $luna');
    expect(luna.year, 2026);
    expect(luna.month, 10);
    expect(luna.day, 26);
    final fine = ITempiDeiGiochi.scadenza(
        GiocoDelCerchio.pellegrinaggio, DateTime(2026, 10, 20))!;
    expect(fine, DateTime(luna.year, luna.month, luna.day + 1));
    expect(ITempiDeiGiochi.eIlTempoDelPellegrinaggio(DateTime(2026, 10, 7)),
        isFalse);
    expect(ITempiDeiGiochi.eIlTempoDelPellegrinaggio(DateTime(2026, 10, 22)),
        isTrue);
  });
}
