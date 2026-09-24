import 'package:esoteric_circle/features/maestri/live/il_silenzio_vero.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL MICROFONO DEL LIVE NON TRONCA.** Ordine EJ voce 01, 24 settembre 2026.
///
/// Il fondatore: *"mi lascia circa un secondo per parlare [...] subito dopo
/// il microfono si disattiva e mi tronca la mia domanda"*. Qui la regola del
/// silenzio riceve livelli di microfono a pezzi di cinquanta millisecondi,
/// come li da' il telefono, e si prova su quattro situazioni vere.
void main() {
  const pezzo = Duration(milliseconds: 50);
  const stanza = -60.0; // una stanza silenziosa, in dBFS
  const voce = -25.0; // una persona a trenta centimetri

  /// Fa sentire [decibel] per [ms] millisecondi; torna vero se in quel tempo
  /// la frase si e' chiusa.
  bool senti(IlSilenzioVero s, double decibel, int ms) {
    for (var t = 0; t < ms; t += 50) {
      s.senti(decibel, pezzo);
    }
    return s.fraseChiusa;
  }

  test('DIECI SECONDI DI SILENZIO PRIMA DI PARLARE NON CHIUDONO NIENTE', () {
    final s = IlSilenzioVero();
    expect(senti(s, stanza, 10000), isFalse);
    expect(s.haParlato, isFalse);
    // E dopo quel silenzio la persona parla ancora, e viene sentita.
    senti(s, voce, 1500);
    expect(s.haParlato, isTrue);
  });

  test('UNA PAUSA DI PENSIERO A META FRASE NON LA TRONCA', () {
    final s = IlSilenzioVero();
    senti(s, stanza, 500);
    senti(s, voce, 3000);
    expect(senti(s, stanza, 1500), isFalse,
        reason: 'un secondo e mezzo per pensare ha chiuso la frase');
    senti(s, voce, 2000);
    expect(senti(s, stanza, 1900), isFalse);
    expect(senti(s, stanza, 200), isTrue,
        reason: 'due secondi di silenzio dopo aver parlato chiudono');
  });

  test('UNA FRASE DI DODICI SECONDI RESTA INTERA', () {
    final s = IlSilenzioVero();
    senti(s, stanza, 500);
    // La voce vera ha piccole pause fra le parole, che in una stanza col
    // riverbero restano vicine alla voce. Le prime due stesure le mettevano
    // a -60 e poi a -40: tutte e due riportavano giu' il fondo, l'innesto del
    // fondo che risale sulla voce restava verde, e la prova non guardava.
    for (var i = 0; i < 40; i++) {
      expect(senti(s, voce, 250), isFalse);
      expect(senti(s, -30, 50), isFalse,
          reason: 'la frase si e\' chiusa a ${(i + 1) * 300} millisecondi');
    }
    expect(senti(s, stanza, 2100), isTrue);
  });

  test('LE CODE DELLA VOCE, SOTTO LA SOGLIA D\'INIZIO, NON SONO SILENZIO', () {
    // Misurato sul Realme il 24 settembre 2026: silenzio vero fra -85 e -91
    // dB, voce che attacca a -42 e code e attacchi deboli fra -58 e -75. Con
    // una soglia sola la coda di una parola diventava silenzio, e una pausa
    // di un secondo e mezzo chiudeva la frase. Qui la stanza e' a -60, la
    // voce a -25, e le code stanno sei decibel sopra la stanza.
    final s = IlSilenzioVero();
    senti(s, stanza, 500);
    senti(s, voce, 1500);
    expect(senti(s, stanza + 6, 2500), isFalse,
        reason: 'la coda della voce e\' stata presa per silenzio');
    expect(senti(s, stanza, 2100), isTrue,
        reason: 'il silenzio vero dopo la coda deve chiudere');
    // E per cominciare la stessa coda non basta: un rumore basso non apre
    // una frase.
    final t = IlSilenzioVero();
    senti(t, stanza, 500);
    senti(t, stanza + 6, 3000);
    expect(t.haParlato, isFalse,
        reason: 'un rumore sei decibel sopra la stanza ha aperto una frase');
  });

  test('I PRIMI PEZZI MUTI DEL MICROFONO NON INCHIODANO IL FONDO', () {
    // Il registratore apre spesso con qualche pezzo di zeri esatti, cioe'
    // -100 dB. Se il fondo si imparasse li', la stanza a -60 sarebbe gia'
    // voce, e la frase non si chiuderebbe mai piu'.
    final s = IlSilenzioVero();
    senti(s, -100, 200);
    expect(senti(s, stanza, 3000), isFalse);
    expect(s.haParlato, isFalse, reason: 'la stanza e\' stata presa per voce');
    senti(s, voce, 2000);
    expect(senti(s, stanza, 2100), isTrue,
        reason: 'dopo aver parlato, il silenzio della stanza deve chiudere');
  });

  test('UN COLPO ISOLATO NON E\' PARLARE', () {
    final s = IlSilenzioVero();
    senti(s, stanza, 500);
    senti(s, -15, 100);
    expect(senti(s, stanza, 3000), isFalse);
    expect(s.haParlato, isFalse);
  });
}
