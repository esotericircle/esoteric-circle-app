import 'package:esoteric_circle/core/l10n/la_lingua_del_cerchio.dart';
import 'package:esoteric_circle/core/l10n/numero_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL NUMERO SEGUE LA LINGUA. Ordine DM voce 03.
///
/// **Due domande, e la seconda e' quella che poteva fare danno.**
///
/// La prima e' facile: in italiano il separatore decimale e' la virgola, e
/// `toStringAsFixed` mette sempre il punto. In tre punti visibili a una
/// persona si leggeva *"152.3 gradi"*.
///
/// **La seconda e' il raggruppamento delle migliaia.** Passare da
/// `toStringAsFixed` a un formattatore che conosce le lingue vuol dire anche
/// che dai mille in su compare il separatore delle migliaia: *"1.234,5"*
/// invece di *"1234.5"*. **Sarebbe un comportamento visibile cambiato oltre
/// ai due difetti che l'ordine permette di curare.** Qui si misura che cosa
/// fa davvero, e si dichiara che nessuno dei sette punti dell'app ci arriva:
/// gradi fino a 360, altezze fino a 90, percentuali fino a 100.
void main() {
  tearDown(LaLinguaDelCerchio.dimentica);

  test('IN ITALIANO LA VIRGOLA, in inglese il punto', () {
    expect(NumeroDelCerchio.conCifre(152.34, 1), '152,3');
    expect(NumeroDelCerchio.gradi(152.34), '152,3 gradi');
    expect(NumeroDelCerchio.percento(84.3), '84,3%');

    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    expect(NumeroDelCerchio.conCifre(152.34, 1), '152.3');
    expect(NumeroDelCerchio.percento(84.3), '84.3%');
  });

  test('E DOVE LA VIRGOLA C\'ERA GIA\', il testo non cambia di un carattere',
      () {
    // **I quattro punti che avevano gia' la virgola messa a mano.** Il loro
    // testo deve restare identico, o l'ordine avrebbe cambiato qualcosa che
    // non doveva cambiare. Si confronta con la vecchia forma, scritta qui
    // per esteso.
    for (final valore in [0.0, 0.1, 9.95, 42.0, 84.3, 99.9, 100.0, 359.9]) {
      final vecchia = valore.toStringAsFixed(1).replaceAll('.', ',');
      expect(NumeroDelCerchio.conCifre(valore, 1), vecchia,
          reason: 'su $valore la porta nuova scrive '
              '${NumeroDelCerchio.conCifre(valore, 1)} e la vecchia forma '
              'scriveva $vecchia');
    }
  });

  test('I NEGATIVI E LO ZERO non cambiano forma', () {
    expect(NumeroDelCerchio.conCifre(0, 1), '0,0');
    expect(NumeroDelCerchio.gradi(-12.5), '-12,5 gradi');
    expect(NumeroDelCerchio.conCifre(-0.04, 1), '-0,0',
        reason: 'lo zero negativo si scriveva cosi anche prima');
  });

  test('SENZA DECIMALI non c\'e\' nessun separatore da scegliere', () {
    expect(NumeroDelCerchio.conCifre(87.6, 0), '88');
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    expect(NumeroDelCerchio.conCifre(87.6, 0), '88');
  });

  test('IL RAGGRUPPAMENTO DELLE MIGLIAIA, misurato e dichiarato', () {
    // **Questo e' il numero che l'app non produce mai.** Lo si misura lo
    // stesso: il giorno che qualcuno passasse da questa porta un valore
    // grande, saprebbe che cosa esce, invece di scoprirlo a video.
    final mille = NumeroDelCerchio.conCifre(1234.5, 1);
    // ignore: avoid_print
    print('ORDINE DM VOCE 03: milleduecentotrentaquattro virgola cinque '
        'si scrive "$mille" in italiano');
    expect(mille, '1.234,5',
        reason: 'il formattatore non raggruppa piu le migliaia: la nota nel '
            'rapporto non e piu vera');

    // **E NESSUNO DEI SETTE PUNTI DELL'APP CI ARRIVA.** I valori che
    // passano di qui sono gradi (fino a 360), altezze sopra il suolo (fino
    // a 90) e percentuali (fino a 100): sotto il mille il raggruppamento non
    // esiste, e il testo e' identico a quello di prima.
    for (final valore in [359.9, 90.0, 100.0, 0.5]) {
      expect(NumeroDelCerchio.conCifre(valore, 1), isNot(contains('.')),
          reason: 'su $valore compare un separatore delle migliaia, e questo '
              'valore l app lo produce davvero');
    }
  });
}
