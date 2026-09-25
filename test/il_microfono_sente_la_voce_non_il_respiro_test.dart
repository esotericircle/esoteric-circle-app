// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:esoteric_circle/features/maestri/live/il_silenzio_vero.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL MICROFONO SENTE LA VOCE, NON IL RESPIRO NE' LA TELEVISIONE.** Ordine
/// EM voci 04, 05 e 11, 25 settembre 2026.
///
/// Il fondatore: *"il microfono è troppo sensibile, rileva anche solo il
/// respiro, è molto grave perché fin quando il microfono rileva il minimo
/// rumore, la risposta non parte"*, e *"Io uso "Ok Google" giornalmente con
/// TV accesa e gemini riconosce la mia voce Senza problemi. Ho bisogno dello
/// stesso livello di accuratezza e tolleranza"*.
///
/// Qui la regola del silenzio riceve pezzi di cinquanta millesimi col loro
/// livello e con **quanto sono voce**, come li misura `LaMisuraDellaVoce`; e
/// la misura della voce si prova su una voce vera, `test/fixtures/em`, e su
/// un respiro e un fruscio fatti qui. **La prova del respiro vero resta del
/// fondatore**, sul suo telefono: e' la sua scelta, *"Sintetico, poi il
/// mio"*.
void main() {
  const pezzo = Duration(milliseconds: 50);
  const stanza = -60.0;
  const voceVicina = -25.0;
  const voce = 0.9; // una voce vera, misurata al banco: mediana 0,93
  const fruscio = 0.2; // un respiro, un ventilatore: mediana 0,14-0,24

  bool senti(IlSilenzioVero s, double decibel, int ms, double quantaVoce) {
    for (var t = 0; t < ms; t += 50) {
      s.senti(decibel, pezzo, voce: quantaVoce);
    }
    return s.fraseChiusa;
  }

  /// Una televisione: parole a due livelli che si alternano, voce vera.
  bool televisione(IlSilenzioVero s, int ms) {
    for (var t = 0; t < ms; t += 50) {
      s.senti((t ~/ 50).isEven ? -38 : -46, pezzo, voce: 0.8);
    }
    return s.fraseChiusa;
  }

  test('IL RESPIRO, ANCHE FORTE, NON APRE UNA FRASE', () {
    final s = IlSilenzioVero();
    senti(s, stanza, 500, fruscio);
    // Un respiro vicino al microfono: trenta decibel sopra la stanza.
    senti(s, -30, 5000, fruscio);
    expect(s.haParlato, isFalse,
        reason: 'il respiro e\' stato preso per una persona che parla');
  });

  test('IL RESPIRO DOPO LA DOMANDA NON LA TIENE APERTA', () {
    final s = IlSilenzioVero();
    senti(s, stanza, 500, fruscio);
    senti(s, voceVicina, 2000, voce);
    expect(s.haParlato, isTrue);
    // Dopo la domanda la persona respira forte vicino al telefono. La coda
    // della voce resta viva 400 millesimi, poi il respiro e' silenzio: a
    // 2.400 millesimi la frase e' chiusa, e la risposta parte.
    expect(senti(s, -30, 2300, fruscio), isFalse);
    expect(senti(s, -30, 200, fruscio), isTrue,
        reason: 'il respiro ha tenuto aperta la domanda: la risposta non '
            'parte');
  });

  test('LA TELEVISIONE NON E\' CHI PARLA AL TELEFONO', () {
    final s = IlSilenzioVero();
    // Sei secondi di televisione accesa: voce vera, ma lontana.
    expect(televisione(s, 6000), isFalse);
    expect(s.haParlato, isFalse,
        reason: 'la televisione ha aperto una frase: il Maestro risponderebbe '
            'alla televisione');
    // La persona parla vicino al telefono, e viene sentita.
    senti(s, -22, 2000, voce);
    expect(s.haParlato, isTrue,
        reason: 'con la televisione accesa la persona '
            'che parla al telefono non viene sentita');
    // Smette di parlare: la televisione continua, e la frase si chiude.
    expect(televisione(s, 1900), isFalse);
    expect(televisione(s, 200), isTrue,
        reason: 'la televisione ha tenuto aperta la domanda');
  });

  test('CON LA TELEVISIONE ACCESA UNA PAUSA DI PENSIERO NON TRONCA', () {
    // Il vincolo dell'ordine EJ voce 01, con la televisione sotto.
    final s = IlSilenzioVero();
    televisione(s, 4000);
    senti(s, -22, 2000, voce);
    expect(televisione(s, 1500), isFalse,
        reason: 'un secondo e mezzo per pensare, con la televisione accesa, '
            'ha chiuso la frase');
    senti(s, -22, 1500, voce);
    expect(televisione(s, 1900), isFalse);
    expect(televisione(s, 200), isTrue);
  });

  test('LA STANZA SI RICORDA LA TELEVISIONE DA UNA FRASE ALL\'ALTRA', () {
    final laStanza = LaStanza();
    final prima = IlSilenzioVero(stanza: laStanza);
    televisione(prima, 5000);
    expect(laStanza.sottofondo, -38.0);
    // La frase dopo parte gia' sapendo che la televisione e' accesa.
    final dopo = IlSilenzioVero(stanza: laStanza);
    televisione(dopo, 3000);
    expect(dopo.haParlato, isFalse);
  });

  test('LA FRASE VA IN PAUSA PRIMA DI CHIUDERSI', () {
    // Ordine EM voce 11: a 700 millesimi di silenzio la frase e' in pausa, e
    // la schermata comincia a trascriverla; se la persona riprende, la pausa
    // finisce e ne comincia un'altra.
    final s = IlSilenzioVero();
    senti(s, stanza, 500, fruscio);
    senti(s, voceVicina, 1000, voce);
    senti(s, stanza, 650, fruscio);
    expect(s.inPausa, isFalse);
    senti(s, stanza, 50, fruscio);
    expect(s.inPausa, isTrue);
    expect(s.pause, 1);
    expect(s.fraseChiusa, isFalse);
    senti(s, voceVicina, 300, voce);
    expect(s.inPausa, isFalse, reason: 'la persona ha ripreso a parlare');
    senti(s, stanza, 700, fruscio);
    expect(s.pause, 2);
    expect(senti(s, stanza, 1300, fruscio), isTrue);
  });

  group('LA MISURA DELLA VOCE', () {
    /// Quanti pezzi di 32 millesimi sopra -40 dB sono voce, da zero a uno.
    double quantiSonoVoce(List<double> x) {
      var forti = 0, voci = 0;
      for (var i = 0; i + 512 <= x.length; i += 256) {
        final f = x.sublist(i, i + 512);
        final rms = math.sqrt(f.fold<double>(0, (a, v) => a + v * v) / 512);
        if (20 * math.log(rms + 1e-12) / math.ln10 <= -40) continue;
        forti++;
        if (LaMisuraDellaVoce.quantaVoce(f) >= 0.55) voci++;
      }
      return forti == 0 ? 0 : voci / forti;
    }

    test('UNA VOCE VERA E\' VOCE', () {
      final byte = File('test/fixtures/em/voce_vera_16k.wav').readAsBytesSync();
      final dati = ByteData.sublistView(byte, 44);
      final x = [
        for (var i = 0; i + 1 < dati.lengthInBytes; i += 2)
          dati.getInt16(i, Endian.little) / 32768.0,
      ];
      final quota = quantiSonoVoce(x);
      print(
          'ORDINE EM VOCE 04: voce vera, pezzi di voce ${(quota * 100).round()} per cento');
      expect(quota, greaterThan(0.8));
    });

    test('UN RESPIRO E UN FRUSCIO NON SONO VOCE', () {
      final caso = math.Random(7);
      double gauss() {
        final u = 1 - caso.nextDouble(), v = caso.nextDouble();
        return math.sqrt(-2 * math.log(u)) * math.cos(2 * math.pi * v);
      }

      final fruscioBianco = [for (var i = 0; i < 48000; i++) 0.05 * gauss()];
      // Il respiro: un fruscio passato basso, che sale e scende come un
      // inspiro e un espiro.
      final respiro = <double>[];
      var y = 0.0;
      for (var i = 0; i < 48000; i++) {
        y = 0.9 * y + 0.1 * gauss();
        final t = i / 48000;
        final inviluppo = t < 0.33 ? t / 0.33 : (1 - t) / 0.67;
        respiro.add(y * inviluppo * 1.5);
      }
      final bianco = quantiSonoVoce(fruscioBianco);
      final resp = quantiSonoVoce(respiro);
      print('ORDINE EM VOCE 04: fruscio ${(bianco * 100).round()} per cento, '
          'respiro ${(resp * 100).round()} per cento di pezzi presi per voce');
      expect(bianco, lessThan(0.05));
      expect(resp, lessThan(0.05));
    });

    test('LA MISURA DI UN PEZZO ALLA VOLTA TIENE LA SUA FINESTRA', () {
      final misura = LaMisuraDellaVoce();
      // Una vocale a 150 cicli al secondo, a pezzi di 20 millesimi.
      double ultima = 0;
      for (var p = 0; p < 10; p++) {
        final b = BytesBuilder();
        for (var i = 0; i < 320; i++) {
          final n = p * 320 + i;
          var v = 0.0;
          for (var k = 1; k <= 6; k++) {
            v += math.pow(0.6, k) * math.sin(2 * math.pi * 150 * k * n / 16000);
          }
          final c = (v * 8000).round();
          b.add([c & 0xff, (c >> 8) & 0xff]);
        }
        ultima = misura.aggiungi(b.toBytes());
      }
      expect(ultima, greaterThan(0.9));
    });
  });
}
