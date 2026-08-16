import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/sigilli/journal_dall_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL JOURNAL DALL'ARTE ARRIVA IN FONDO A CINQUANTACINQUE ACCESI. Ordine AC
/// voce 01.
///
/// **Perche' questa misura esiste.** Nel file del Journal convivevano due
/// dichiarazioni opposte: il commento sopra l'interruttore diceva che a
/// cinquantacinque accesi il disegno non arriva in fondo, perche' chiede un
/// tracciato di qualche migliaio di rettangoli; il commento dentro il pittore
/// diceva che le forme si uniscono in due tracciati e che restano al massimo
/// cinquantacinque riquadri. **Una sola delle due puo' essere vera oggi**, e
/// nessuna prova la sorvegliava: l'interruttore stava spento su una causa
/// scritta a parole.
///
/// **La soglia si dichiara PRIMA di misurare, e viene dal fotogramma.** A
/// sessanta fotogrammi al secondo un fotogramma dura 16,7 millesimi di secondo.
/// Questo pittore si ridisegna a ogni fotogramma, perche' il respiro del
/// bagliore e' un'animazione, e **divide il fotogramma con tutto il resto della
/// schermata**: l'immagine dell'arte, l'elenco dei traguardi, la barra. Quindi
/// puo' prendersi al massimo **meta' fotogramma, 8 millesimi**. Non e' il numero
/// che ho misurato: e' il numero sotto il quale la schermata resta fluida.
///
/// **Cosa misura davvero, e cosa no.** Misura la composizione piu' la
/// rasterizzazione su questa macchina dentro `flutter test`, che non e' un
/// telefono: e' un indicatore, non la misura del dispositivo di Mauro. Vale come
/// prova perche' il difetto che si teme e' di ordine di grandezza, non di
/// decimi: la prima anteprima a cinquantacinque accesi girava dieci minuti e poi
/// scadeva.
void main() {
  /// Meta' fotogramma a sessanta al secondo. Vedi sopra da dove viene.
  const soglia = Duration(microseconds: 8333);

  testWidgets('il disegno a cinquantacinque accesi sta dentro mezzo fotogramma',
      (tester) async {
    // **DENTRO runAsync**, perche' `toImage` la completa il motore sul tempo
    // vero mentre dentro `testWidgets` il tempo e' finto: fuori di qui la
    // promessa non viene mai osservata e la prova resta appesa fino al tetto.
    await tester.runAsync(() async {
      const larghezza = 360.0, altezza = 580.0;
      var osservati = 0;
      final lenti = <String>[];
      for (final sentiero in Sentieri.tutti) {
        final traguardi = Sentieri.di(sentiero).map((t) => t.id).toSet();
        expect(traguardi, hasLength(55),
            reason: 'questo sentiero non ha cinquantacinque traguardi, quindi '
                'la misura non sarebbe quella dichiarata');
        osservati++;
        final pittore = PittoreDelleLuci(
          sentiero: sentiero,
          accesi: traguardi,
          evidenziato: null,
          oro: ColorTokens.gold,
          oroTenue: ColorTokens.goldLight,
          respiro: 1.0,
          effettiPieni: true,
        );
        // Un giro a vuoto prima di cronometrare: il primo paga la preparazione
        // del motore e non e' il costo di un fotogramma.
        final scaldata = ui.PictureRecorder();
        pittore.paint(Canvas(scaldata), const Size(larghezza, altezza));
        await scaldata
            .endRecording()
            .toImage(larghezza.round(), altezza.round());

        final cronometro = Stopwatch()..start();
        final registratore = ui.PictureRecorder();
        pittore.paint(Canvas(registratore), const Size(larghezza, altezza));
        final composizione = cronometro.elapsedMicroseconds;
        final immagine = await registratore
            .endRecording()
            .toImage(larghezza.round(), altezza.round());
        cronometro.stop();
        final totale = cronometro.elapsedMicroseconds;
        // Che l'immagine sia davvero uscita, altrimenti si sta cronometrando il
        // nulla: e' il modo piu' facile di misurare zero e chiamarlo veloce.
        expect(immagine.width, larghezza.round());
        // ignore: avoid_print
        print('ORDINE AC VOCE 01: ${sentiero.name} a cinquantacinque accesi, '
            'composizione ${(composizione / 1000).toStringAsFixed(2)} ms, '
            'con la rasterizzazione ${(totale / 1000).toStringAsFixed(2)} ms');
        if (totale > soglia.inMicroseconds) {
          lenti.add('${sentiero.name}: ${(totale / 1000).toStringAsFixed(2)} ms '
              'contro un tetto di ${(soglia.inMicroseconds / 1000)
                  .toStringAsFixed(2)}');
        }
      }
      // **QUANTI SENTIERI GUARDATI, e cade se sono zero.**
      // ignore: avoid_print
      print('ORDINE AC VOCE 01: sentieri osservati $osservati');
      expect(osservati, Sentieri.tutti.length);
      // **LA GUARDIA SORVEGLIA LA DECISIONE, non si lamenta di un fatto.**
      // Oggi l'interruttore e' spento e questi numeri dicono perche': una prova
      // rossa in eterno direbbe soltanto cio' che il commento gia' dice. Questa
      // riga invece cade nel momento in cui qualcuno accende l'interruttore
      // senza che il disegno ci stia dentro, che e' l'unico modo in cui il
      // difetto potrebbe arrivare a una persona.
      // ignore: avoid_print
      print('ORDINE AC VOCE 01: interruttore ${ArteDelSentiero.acceso ? "acceso"
          : "spento"}, sentieri fuori tetto ${lenti.length}');
      expect(!ArteDelSentiero.acceso || lenti.isEmpty, isTrue,
          reason: 'l\'interruttore del Journal dall\'arte e\' acceso ma il '
              'disegno non sta dentro mezzo fotogramma: ${lenti.join(" | ")}. '
              'Una schermata che si pianta col cammino finito e\' peggio di un '
              'Journal procedurale che funziona: o si accelera il disegno, o '
              'l\'interruttore torna spento. **La soglia non si alza.**');
    });
  });
}
