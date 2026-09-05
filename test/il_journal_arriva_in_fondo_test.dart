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
/// **LA SOGLIA E' CAMBIATA IL 16 AGOSTO 2026, e la prima era sbagliata.** Diceva
/// mezzo fotogramma, perche' davo per scontato che il pittore si ridisegnasse a
/// ogni fotogramma. **Misurato, non e' cosi'**: `LuciDelSentiero` viene montato
/// senza passare `respiro`, nessuna animazione lo tocca, e `shouldRepaint` non
/// scatta se non cambia niente. Contate le passate vere: **una all'apertura, e
/// zero scorrendo l'elenco fino in fondo o toccando tre traguardi**, su tutti e
/// tre i sentieri.
///
/// **Quindi la grandezza giusta non e' il fotogramma: e' l'apertura.** La soglia
/// e' **cento millesimi di secondo**, che e' il limite oltre il quale una
/// risposta smette di sembrare istantanea. Non viene dalle misure: viene da cosa
/// dev'essere vero perche' aprire un sentiero non sembri lento. **Ed e' un tetto
/// generoso**, perche' alla stessa apertura si paga anche la decodifica
/// dell'immagine dell'arte, che qui dentro non c'e': cio' che sfora questo tetto
/// sfora di sicuro.
///
/// **Cosa misura davvero, e cosa no.** Misura la composizione piu' la
/// rasterizzazione su questa macchina dentro `flutter test`, che non e' un
/// telefono: e' un indicatore, non la misura del dispositivo di Mauro. Vale come
/// prova perche' il difetto che si teme e' di ordine di grandezza, non di
/// decimi: la prima anteprima a cinquantacinque accesi girava dieci minuti e poi
/// scadeva.
void main() {
  /// Cento millesimi, il limite dell'immediatezza. Vedi sopra da dove viene.
  const soglia = Duration(milliseconds: 100);

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
        // **IL GIRO A VUOTO SI FA SU UN'ALTRA MISURA DI TELA, e la ragione e'
        // che adesso i tracciati si tengono**: scaldando il motore sulla stessa
        // misura si scalderebbe anche la memoria dei tracciati, e la prima
        // passata cronometrata non sarebbe piu' la prima. Qui si paga la
        // preparazione del motore senza regalare il lavoro che si vuole
        // misurare.
        final scaldata = ui.PictureRecorder();
        pittore.paint(Canvas(scaldata), const Size(larghezza + 7, altezza + 7));
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
        // **LA SECONDA PASSATA, che e' quella che paga chi resta.** La prima
        // compone i tracciati, la seconda li ritrova gia' fatti: le due misure
        // insieme dicono quanto pesava la composizione e quanto pesa il solo
        // disegno.
        final secondo = Stopwatch()..start();
        final ancora = ui.PictureRecorder();
        pittore.paint(Canvas(ancora), const Size(larghezza, altezza));
        await ancora.endRecording().toImage(larghezza.round(), altezza.round());
        secondo.stop();
        // ignore: avoid_print
        print('ORDINE AC VOCE 01: ${sentiero.name} a cinquantacinque accesi, '
            'PRIMA passata ${(totale / 1000).toStringAsFixed(2)} ms '
            '(composizione ${(composizione / 1000).toStringAsFixed(2)}), '
            'SECONDA ${(secondo.elapsedMicroseconds / 1000).toStringAsFixed(2)} ms');
        if (totale > soglia.inMicroseconds) {
          lenti.add(
              '${sentiero.name}: ${(totale / 1000).toStringAsFixed(2)} ms '
              'contro un tetto di ${(soglia.inMicroseconds / 1000).toStringAsFixed(2)}');
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
      print(
          'ORDINE AC VOCE 01: interruttore ${ArteDelSentiero.acceso ? "acceso" : "spento"}, sentieri fuori tetto ${lenti.length}');
      expect(!ArteDelSentiero.acceso || lenti.isEmpty, isTrue,
          reason: 'l\'interruttore del Journal dall\'arte e\' acceso ma il '
              'disegno non sta dentro mezzo fotogramma: ${lenti.join(" | ")}. '
              'Una schermata che si pianta col cammino finito e\' peggio di un '
              'Journal procedurale che funziona: o si accelera il disegno, o '
              'l\'interruttore torna spento. **La soglia non si alza.**');
    });
  });
}
