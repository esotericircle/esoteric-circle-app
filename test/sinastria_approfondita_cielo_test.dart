import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/synastry_approfondita/cielo_approfondito.dart';
import 'package:flutter_test/flutter_test.dart';

/// FT.05: IL CALCOLO DELLA SINASTRIA APPROFONDITA. Ordine FT, 14 ottobre
/// 2026.
void main() {
  final lui = CieloApprofondito.perNascita(
    momentoUtc: DateTime.utc(1990, 5, 12, 14, 30),
    nome: 'Marco',
  );
  final lei = CieloApprofondito.perNascita(
    momentoUtc: DateTime.utc(1992, 9, 3, 8, 15),
    nome: 'Giulia',
  );

  test('undici punti, compreso il Nodo Nord', () {
    expect(lui.longitudini.length, 11);
    expect(
        lui.longitudini.containsKey(PuntoDelCieloApprofondito.nodoNord), true);
    for (final p in PuntoDelCieloApprofondito.values) {
      expect(lui.longitudini[p], isNotNull, reason: '${p.nome} deve esserci');
      expect(lui.longitudini[p]! >= 0 && lui.longitudini[p]! < 360, true);
    }
  });

  test('il calcolo e deterministico: stesso istante, stessa longitudine',
      () {
    final rifatto = CieloApprofondito.perNascita(
      momentoUtc: DateTime.utc(1990, 5, 12, 14, 30),
    );
    for (final p in PuntoDelCieloApprofondito.values) {
      expect(rifatto.longitudini[p], lui.longitudini[p]);
    }
  });

  test('nessuna chiamata di rete: il cielo nasce dal solo istante', () {
    // Lo stesso calcolo rifatto una seconda volta non deve cambiare: non
    // c'e' nessuna sorgente esterna o casuale dentro.
    final a = CieloApprofondito.perNascita(momentoUtc: DateTime.utc(2000, 1, 1));
    final b = CieloApprofondito.perNascita(momentoUtc: DateTime.utc(2000, 1, 1));
    expect(a.longitudini, b.longitudini);
  });

  test('gli aspetti sono ordinati dal piu stretto al piu largo', () {
    final aspetti = AspettiApprofonditi.fra(lui, lei);
    for (var i = 1; i < aspetti.length; i++) {
      expect(aspetti[i - 1].orbo <= aspetti[i].orbo, true);
    }
  });

  test('ogni aspetto trovato sta dentro il suo orbo dichiarato', () {
    final aspetti = AspettiApprofonditi.fra(lui, lei);
    expect(aspetti, isNotEmpty);
    for (final a in aspetti) {
      expect(a.orbo, lessThanOrEqualTo(AspettiApprofonditi.orbo[a.tipo]!));
    }
  });

  test('il Nodo Nord puo comparire fra i punti in aspetto', () {
    // Non e' garantito per OGNI coppia di nascite, ma con undici punti per
    // lato e sei gradi di orbo sui maggiori capita quasi sempre: lo
    // verifichiamo su piu' coppie, cosi' la prova non dipende da un caso
    // isolato.
    var trovato = false;
    for (var giorno = 1; giorno <= 28 && !trovato; giorno++) {
      final altro = CieloApprofondito.perNascita(
          momentoUtc: DateTime.utc(1990, 5, giorno, 12, 0));
      final aspetti = AspettiApprofonditi.fra(lui, altro);
      trovato = aspetti.any((a) =>
          a.tuo == PuntoDelCieloApprofondito.nodoNord ||
          a.suo == PuntoDelCieloApprofondito.nodoNord);
    }
    expect(trovato, true,
        reason: 'il Nodo Nord deve poter entrare negli aspetti calcolati');
  });

  test('la carta si presta alla ruota comune (NatalChart)', () {
    final carta = lui.comeCarta;
    expect(carta.planets.length, 11);
    expect(carta.hasTime, false);
    expect(carta.planets.any((p) => p.id == 'north_node'), true);
  });

  test('il tipo di aspetto resta dei cinque tolemaici', () {
    final aspetti = AspettiApprofonditi.fra(lui, lei);
    for (final a in aspetti) {
      expect(AspectType.values.contains(a.tipo), true);
    }
  });
}
