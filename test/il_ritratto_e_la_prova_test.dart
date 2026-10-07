// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/cerchio/il_ritratto.dart';
import 'package:esoteric_circle/core/cerchio/la_prova.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL RITRATTO E LA PROVA, i modelli. Ordine FF voci 02 e 05.
void main() {
  group('FF.02 il Ritratto', () {
    test('b) otto proposte dalla carta, deterministiche, mai libere', () {
      final a = IlRitratto.proposteDallaCarta(
          sole: Zodiac.leo,
          luna: Zodiac.cancer,
          ascendente: Zodiac.gemini,
          giornoDiNascita: 20);
      final ancora = IlRitratto.proposteDallaCarta(
          sole: Zodiac.leo,
          luna: Zodiac.cancer,
          ascendente: Zodiac.gemini,
          giornoDiNascita: 20);
      print('ORDINE FF VOCE 02: Leone, Luna Cancro, Ascendente Gemelli, nato '
          'il 20: $a');
      expect(a, ancora);
      expect(a, hasLength(8));
      expect(a.toSet(), hasLength(8));
      final elementi = [for (final n in a) IlRitratto.tratto(n)!.elemento];
      expect(elementi, [
        ElementoDelTratto.fuoco,
        ElementoDelTratto.fuoco,
        ElementoDelTratto.fuoco,
        ElementoDelTratto.acqua,
        ElementoDelTratto.acqua,
        ElementoDelTratto.aria,
        ElementoDelTratto.aria,
        ElementoDelTratto.fuoco,
      ]);
      expect(elementi, isNot(contains(ElementoDelTratto.libera)));
    });

    test('b) due carte diverse danno proposte diverse', () {
      final leone = IlRitratto.proposteDallaCarta(
          sole: Zodiac.leo, luna: Zodiac.cancer, giornoDiNascita: 20);
      final toro = IlRitratto.proposteDallaCarta(
          sole: Zodiac.taurus, luna: Zodiac.cancer, giornoDiNascita: 20);
      final altroGiorno = IlRitratto.proposteDallaCarta(
          sole: Zodiac.leo, luna: Zodiac.cancer, giornoDiNascita: 3);
      expect(leone, isNot(toro));
      expect(leone, isNot(altroGiorno),
          reason: 'stesso segno, giorni diversi: il corpus vuole proposte '
              'diverse');
    });

    test('senza Ascendente dalla Luna, senza Luna tutte dal Sole', () {
      final senzaAsc = IlRitratto.proposteDallaCarta(
          sole: Zodiac.leo, luna: Zodiac.cancer, giornoDiNascita: 20);
      expect([
        for (final n in senzaAsc) IlRitratto.tratto(n)!.elemento
      ], [
        for (var i = 0; i < 3; i++) ElementoDelTratto.fuoco,
        for (var i = 0; i < 4; i++) ElementoDelTratto.acqua,
        ElementoDelTratto.fuoco,
      ]);
      final soloSole =
          IlRitratto.proposteDallaCarta(sole: Zodiac.leo, giornoDiNascita: 20);
      expect(
          soloSole.every(
              (n) => IlRitratto.tratto(n)!.elemento == ElementoDelTratto.fuoco),
          isTrue);
      expect(soloSole.toSet(), hasLength(8));
    });

    test('c) il Ritratto non si chiude con meno di venti caratteristiche', () {
      final venti = [for (var i = 1; i <= 20; i++) i];
      expect(IlRitratto.siChiude(venti), isTrue);
      expect(IlRitratto.siChiude(venti.take(19)), isFalse);
      expect(IlRitratto.siChiude([...venti.take(19), 1]), isFalse);
      expect(IlRitratto.siChiude([...venti.take(19), 121]), isFalse);
      expect(IlRitratto.tutti, hasLength(120));
    });
  });

  group('FF.05 la Prova', () {
    test(
        'a) la Prova e\' la stessa per tutta la settimana e cambia il lunedi\'',
        () {
      final lunedi = DateTime(2026, 10, 12);
      final domenica = DateTime(2026, 10, 18, 23, 59);
      expect(LaProva.temaDi(lunedi).numero, LaProva.temaDi(domenica).numero);
      expect([for (final d in LaProva.domandeDi(lunedi)) d.numero],
          [for (final d in LaProva.domandeDi(domenica)) d.numero]);
      expect(LaProva.domandeDi(lunedi), hasLength(10));
      // Il lunedi' dopo, la settimana nuova: Mercurio retrogrado dal 24.
      expect(LaProva.temaDi(DateTime(2026, 10, 19)).numero, 1);
      expect(LaProva.temaDi(domenica).numero, 6);
    });

    test('b) il tema segue il cielo: quattro settimane, quattro Prove', () {
      final settimane = {
        // Mercurio retrogrado dal 26 febbraio 2026.
        DateTime(2026, 2, 23): 1,
        // Venere cambia segno.
        DateTime(2026, 1, 12): 2,
        // La Luna piena del 26 ottobre... ma Mercurio e' retrogrado: vince
        // lui. La Luna piena del 31 maggio 2026.
        DateTime(2026, 5, 25): 4,
        // La Luna nuova del 10 ottobre 2026.
        DateTime(2026, 10, 5): 5,
      };
      settimane.forEach((lunedi, tema) {
        print('ORDINE FF VOCE 05: settimana del $lunedi, criterio '
            '${LaProva.criterio(lunedi).name}, tema "${LaProva.temaDi(lunedi).nome}"');
        expect(LaProva.temaDi(lunedi).numero, tema);
      });
      expect(settimane.values.toSet(), hasLength(4));
    });

    test('c) il punteggio e\' deterministico e la fascia lo segue', () {
      expect(LaProva.punteggio(List.filled(10, 3)), 100);
      expect(LaProva.punteggio(List.filled(10, 0)), 0);
      expect(LaProva.punteggio([3, 2, 1, 0, 3, 2, 1, 0, 3, 2]), 57);
      expect(LaProva.punteggio([3, 2, 1, 0, 3, 2, 1, 0, 3, 2]), 57);
      final tema = LaProva.temi.first;
      expect(LaProva.fascia(tema, 25).figura, 'Il Pozzo');
      expect(LaProva.fascia(tema, 26).figura, 'La Soglia');
      expect(LaProva.fascia(tema, 100).figura, 'Il Vento');
    });
  });
}
