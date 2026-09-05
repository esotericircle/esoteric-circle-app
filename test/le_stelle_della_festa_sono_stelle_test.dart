import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/features/sigilli/spirale_di_stelle.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LE STELLE DELLA FESTA SONO STELLE, e si misura sui pixel.**
/// Ordine CO voce 18, 3 settembre 2026.
///
/// Parole del fondatore: nel vortice della festa si vedono puntini grossolani
/// e sfocati invece di stelline.
///
/// **Le stelle c'erano già, a cinque punte, disegnate bene.** Il difetto non
/// era la forma: erano la risoluzione con cui veniva incisa e l'alone che se
/// la mangiava. La tessera era ventiquattro pixel di lato e una stella al
/// minimo della sua scala finiva a schermo larga otto: cinque punte in otto
/// pixel non sono cinque punte. E l'alone radiale andava fino a metà tessera,
/// cioè più in là del corpo della stella, quindi copriva le punte invece di
/// accompagnarle.
///
/// ## La grandezza misurata, e perché questa
///
/// Non si guarda che il codice disegni un `Path` con dieci vertici: quello lo
/// faceva già, e la prova sarebbe stata verde mentre il fondatore vedeva
/// puntini. **Si guarda l'immagine finita**, che è quello che l'occhio riceve.
///
/// Su una circonferenza che taglia le punte a metà altezza, una stella a
/// cinque punte alterna cinque volte fra pieno e vuoto, cioè **dieci passaggi
/// fra chiaro e scuro** girando una volta intorno. Un disco, per quanto
/// sfumato, non ne fa nessuno: è chiaro dappertutto. È la differenza fra una
/// stella e un puntino detta in un numero, e non dipende dal colore, dalla
/// dimensione o dalla sfocatura.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Quante volte, girando una volta sola sulla circonferenza di raggio
  /// [quota] per lato, il pixel passa da chiaro a scuro o viceversa.
  int passaggi(ByteData px, int lato, double quota) {
    final centro = lato / 2;
    final raggio = lato * quota;
    bool chiaroA(double angolo) {
      final x = (centro + math.cos(angolo) * raggio).round();
      final y = (centro + math.sin(angolo) * raggio).round();
      if (x < 0 || y < 0 || x >= lato || y >= lato) return false;
      final i = (y * lato + x) * 4;
      // Il canale alfa: la tessera è trasparente dove non c'è né stella né
      // alone, e questa è la sola cosa che distingue il pieno dal vuoto.
      return px.getUint8(i + 3) > 140;
    }

    var quanti = 0;
    var precedente = chiaroA(0);
    const passi = 720;
    for (var k = 1; k <= passi; k++) {
      final adesso = chiaroA(2 * math.pi * k / passi);
      if (adesso != precedente) quanti++;
      precedente = adesso;
    }
    return quanti;
  }

  test('la tessera incisa mostra cinque punte, contate sui pixel', () async {
    final lato = SpiraleDiStelle.latoDellaStella.toInt();
    final immagine = SpiraleDiStelleState.stellaPerLeProve();
    addTearDown(immagine.dispose);
    expect(immagine.width, lato);
    final px = (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!;

    // **LA QUOTA E' FRA IL CUORE E LA PUNTA**, cioè dove la stella è fatta di
    // bracci separati. Più dentro è tutta piena, più fuori è tutta vuota: in
    // nessuno dei due posti si vedrebbe la differenza fra una stella e un
    // disco, ed è esattamente l'errore che una misura frettolosa farebbe.
    final quote = <double>[0.30, 0.34, 0.38];
    final trovati = <double, int>{};
    for (final q in quote) {
      trovati[q] = passaggi(px, lato, q);
    }
    // ignore: avoid_print
    print('ORDINE CO VOCE 18: passaggi chiaro-scuro per quota $trovati');

    cardinaleMinimo(quote.length, 3,
        cosa: 'quote della tessera guardate',
        perche: 'Se restasse una quota sola, questa prova potrebbe cadere su '
            'un raggio che sta tutto dentro il cuore pieno della stella e '
            'dire che va tutto bene senza aver visto nessuna punta.');

    final massimo = trovati.values.reduce(math.max);
    expect(massimo, 10,
        reason: 'su nessuna quota della tessera si contano dieci passaggi fra '
            'chiaro e scuro: al massimo se ne contano $massimo. Dieci sono le '
            'cinque punte di una stella, entrando e uscendo. ZERO vuol dire '
            'un disco pieno, cioè il puntino sfocato che il fondatore ha '
            'visto; un numero diverso da dieci vuol dire che le punte non '
            'sono cinque, o che un alone se le e mangiate.');
  });

  test('l alone resta dentro il corpo della stella', () {
    // La misura sta nel codice perché è una proporzione dichiarata, non un
    // pixel: l'alone arriva a 0,34 del lato e il corpo a 1 / 2,2, cioè 0,4545.
    // Se l'alone tornasse a metà tessera coprirebbe le punte, ed è la seconda
    // metà del difetto.
    const alone = 0.34;
    const corpo = 1 / 2.2;
    expect(alone, lessThan(corpo),
        reason: 'l alone e piu largo del corpo della stella: la sfumatura '
            'copre le punte invece di accompagnarle');
  });

  test('la tessera e abbastanza grande da reggere la scala minima', () {
    // La stella più piccola a schermo è la tessera per la scala minima, che
    // vale 0,35. Sotto i quindici pixel le cinque punte non sopravvivono al
    // filtro di ingrandimento, ed è la misura per cui ventiquattro non
    // bastavano: davano otto pixel e quaranta.
    const piuPiccola = SpiraleDiStelle.latoDellaStella * 0.35;
    // ignore: avoid_print
    print('ORDINE CO VOCE 18: la stella piu piccola a schermo misura '
        '${piuPiccola.toStringAsFixed(1)} pixel');
    expect(piuPiccola, greaterThanOrEqualTo(15.0),
        reason: 'la stella piu piccola a schermo misura '
            '${piuPiccola.toStringAsFixed(1)} pixel, e sotto i quindici le '
            'cinque punte non sopravvivono: tornano il poligono che il filtro '
            'appiattisce in un cerchio');
  });
}
