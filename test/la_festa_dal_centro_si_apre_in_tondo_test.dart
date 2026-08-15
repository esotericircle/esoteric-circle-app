import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/sigilli/direzione_della_festa.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA DIREZIONE DICHIARATA DEVE LEGGERSI SUI PIXEL. Ordine X voce 02.
///
/// **Cosa sorveglia, e perche' non basta una festa sola.** Ogni Maestro dichiara
/// da dove si apre la sua festa: Medora dal centro verso fuori, Caligo dall'alto
/// come una cascata, Aura dal basso come una salita. Una prova che chiedesse
/// soltanto "Medora e' equilibrata" passerebbe anche il giorno in cui tutte e
/// tre diventassero equilibrate, cioe' il giorno in cui la direzione smette di
/// esistere. **Quindi la prova chiede due cose opposte insieme**: che la festa
/// dal centro sia equilibrata nei quattro quadranti, e che le altre due NON lo
/// siano, perche' una cascata e una salita sono sbilanciate per definizione.
///
/// **Il testo si toglie, e la regola per toglierlo e' che il testo non si
/// muove.** Il titolo e la riga degli Eos sono dorati come le particelle e
/// starebbero nel conto falsandolo. Un pixel acceso che vale lo stesso in tutti
/// e tre i fotogrammi appartiene a cio' che sta fermo, cioe' alla scritta: una
/// particella si sposta, quindi non puo' restare identica. Misurato, la regola
/// isola 13.219 pixel per Medora, 13.048 per Caligo e 13.181 per Aura, e per
/// tutti e tre cadono nelle stesse righe, dalla 1109 alla 1284, che sono le due
/// righe di scritta. Nessuna stella ci finisce dentro.
///
/// **Si guarda il fotogramma di meta' corsa e non quello d'inizio.** A 0,18 sono
/// vive 35 particelle su 90, perche' il ritardo di nascita e' distribuito fra 0
/// e 0,45: con 35 punti un addensamento e' rumore di campionamento e non una
/// direzione. A 0,5 sono vive tutte e novanta, ed e' li' che la forma del
/// movimento si puo' leggere.
void main() {
  /// **QUANTO UNO SCARTO PUO' ESSERE FIGLIO DEL CASO, e da dove viene il
  /// numero.** L'angolo di ogni particella e' estratto uniformemente sul giro
  /// intero, quindi i quattro quadranti sono un'estrazione multinomiale con
  /// probabilita' un quarto ciascuno. Con le novanta particelle della festa dal
  /// centro lo scarto tipo della quota di un quadrante vale la radice di
  /// 0,25 per 0,75 diviso 90, cioe' il 4,56 per cento del totale, che e' il 18,3
  /// per cento della quota giusta. **Tre scarti tipo fanno il 55 per cento, ed
  /// e' questa la tolleranza.**
  ///
  /// **Non e' un numero scelto perche' fa passare la misura**: e' il punto sotto
  /// il quale pretendere di piu' vorrebbe dire pretendere che il caso si comporti
  /// meglio del caso. La misura vera sta molto piu' dentro, al 10,0 per cento,
  /// cioe' cinque volte e mezzo dentro il limite: la prova ha spazio da vendere e
  /// prenderebbe un'anisotropia vera molto prima di arrivare qui.
  ///
  /// **E' un pavimento, non una stima esatta.** Il conto e' fatto sul numero di
  /// particelle, mentre la misura pesa i PIXEL, e una particella lontana e' piu'
  /// grande di una vicina: il rumore vero e' quindi maggiore di questo, mai
  /// minore. Le due feste con una direzione lo superano comunque di larga misura,
  /// all'88,8 e al 115,1 per cento.
  const tolleranza = 0.55;

  /// Quanto due pixel possono differire e valere ancora "fermo". Non zero,
  /// perche' due PNG compressi non danno mai lo stesso identico byte.
  const fermo = 20;

  /// Lo scarto dal fondo oltre il quale un pixel e' acceso. E' la stessa soglia
  /// con cui e' misurata la copertura delle tre feste, quindi non e' una
  /// grandezza nuova introdotta qui.
  const acceso = 30;

  Future<(int, int, List<int>)> apri(String file) async {
    final byte = await File(file).readAsBytes();
    final codice = await ui.instantiateImageCodec(byte);
    final immagine = (await codice.getNextFrame()).image;
    final dati = (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    return (immagine.width, immagine.height, dati);
  }

  testWidgets('la festa dal centro si apre in tondo, le altre due no',
      (tester) async {
    // **LA CATTURA STA DENTRO runAsync.** Fuori, il codec e `toByteData` sono
    // promesse che il tempo finto della prova non osserva mai, e la prova resta
    // appesa fino al tetto.
    await tester.runAsync(() async {
      var osservati = 0;
      final sbagliati = <String>[];
      for (final maestro in Maestro.values) {
        final tre = ['inizio', 'meta', 'fine']
            .map((q) => 'docs/preview/festa_${maestro.id}_$q.png')
            .toList();
        if (tre.any((f) => !File(f).existsSync())) continue;
        final (larghezza, altezza, inizio) = await apri(tre[0]);
        final (_, _, meta) = await apri(tre[1]);
        final (_, _, fine) = await apri(tre[2]);
        osservati++;

        // Il fondo si legge in un angolo, dove non arriva mai niente.
        final angolo = (5 * larghezza + 5) * 4;
        final fondo = [meta[angolo], meta[angolo + 1], meta[angolo + 2]];
        final cx = larghezza / 2, cy = altezza / 2;
        final quadranti = <int>[0, 0, 0, 0];
        var quanti = 0, fermiTolti = 0;
        for (var p = 0; p < larghezza * altezza; p++) {
          final i = p * 4;
          final daFondo = (meta[i] - fondo[0]).abs() +
              (meta[i + 1] - fondo[1]).abs() +
              (meta[i + 2] - fondo[2]).abs();
          if (daFondo <= acceso) continue;
          final daInizio = (meta[i] - inizio[i]).abs() +
              (meta[i + 1] - inizio[i + 1]).abs() +
              (meta[i + 2] - inizio[i + 2]).abs();
          final daFine = (meta[i] - fine[i]).abs() +
              (meta[i + 1] - fine[i + 1]).abs() +
              (meta[i + 2] - fine[i + 2]).abs();
          if (daInizio <= fermo && daFine <= fermo) {
            fermiTolti++;
            continue;
          }
          final dx = p % larghezza - cx, dy = p ~/ larghezza - cy;
          quadranti[(dx >= 0 ? 0 : 1) + (dy >= 0 ? 0 : 2)]++;
          quanti++;
        }

        // **UNA FESTA SENZA PARTICELLE NON SI GIUDICA, SI DENUNCIA.** Se la
        // scritta si mangiasse tutto, i quattro quadranti sarebbero zero e uno
        // zero diviso zero passerebbe per equilibrio perfetto.
        if (quanti == 0) {
          sbagliati.add('${maestro.id}: nessuna particella da misurare, tolti '
              '$fermiTolti pixel fermi');
          continue;
        }
        final giusta = quanti / 4;
        final scarto = quadranti
            .map((q) => (q - giusta).abs() / giusta)
            .reduce((a, b) => a > b ? a : b);
        final direzione = FesteDeiMaestri.di(maestro).direzione;
        // ignore: avoid_print
        print('ORDINE X VOCE 02: ${maestro.id} ${direzione.name}, '
            'particelle $quanti pixel, quadranti $quadranti, scarto massimo '
            '${(scarto * 100).toStringAsFixed(1)} per cento, scritta tolta '
            '$fermiTolti pixel');

        final dalCentro = direzione == DirezioneDellaFesta.dalCentro;
        if (dalCentro && scarto > tolleranza) {
          sbagliati.add('${maestro.id} si apre dal centro ma i quadranti sono '
              'sbilanciati del ${(scarto * 100).toStringAsFixed(1)} per cento, '
              'oltre il ${(tolleranza * 100).toStringAsFixed(0)} ammesso: '
              'un\'esplosione che ha una direzione non e\' un\'esplosione');
        }
        if (!dalCentro && scarto <= tolleranza) {
          sbagliati.add('${maestro.id} dichiara ${direzione.name} ma i quadranti '
              'sono equilibrati entro il ${(scarto * 100).toStringAsFixed(1)} '
              'per cento: una cascata e una salita sono sbilanciate per '
              'definizione, e questa non lo e\' piu\'');
        }
      }

      // **QUANTE OSSERVAZIONI, e cade se sono zero.**
      // ignore: avoid_print
      print('ORDINE X VOCE 02: feste osservate $osservati su '
          '${Maestro.values.length}');
      expect(osservati, Maestro.values.length,
          reason: 'mancano le anteprime di meta\' corsa di qualche Maestro: la '
              'prova girerebbe su una parte e direbbe di aver guardato tutto');
      expect(sbagliati, isEmpty, reason: sbagliati.join(' | '));
    });
  });
}
