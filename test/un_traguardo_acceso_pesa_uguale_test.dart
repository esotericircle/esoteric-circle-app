import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// UN TRAGUARDO ACCESO DEVE PESARE UGUALE SUI TRE SENTIERI. Ordine AB voce 02.
///
/// **Il difetto, visto da un occhio prima che da una misura.** A dodici traguardi
/// accesi l'Albero e il Loto mostrano il progresso a colpo d'occhio, la
/// Costellazione no: guardando la sua anteprima non si riesce a dire quali dodici
/// siano accesi. La ragione non e' l'arte e non e' un errore: e' che l'ampiezza
/// dell'alone era la stessa per tutti e tre mentre l'elemento sotto varia di
/// dieci volte.
///
/// **Cosa misura, e perche' la macchia e non l'elemento.** Fra due traguardi
/// accesi e dodici cambiano solo i dieci elementi accesi in mezzo, con le loro
/// luci. Le componenti connesse di quei pixel sono le MACCHIE, cioe' quello che
/// una persona vede davvero: non l'area della forma nel dato, ma quanta luce
/// nuova compare sullo schermo.
///
/// **LA GRANDEZZA MISURATA E' FRAGILE, ed e' la prima cosa da rifare quando
/// questa voce si apre.** Il 16 agosto 2026, alleggerendo il pittore, il rapporto
/// e' passato da 10,4 a 21,9 con un disegno che a pixel non si muove piu' di
/// venti punti su duecentocinquantacinque: sul Loto due macchie che si sfioravano
/// hanno cominciato a toccarsi e il conteggio e' sceso da tre a due. **Una
/// mediana su TRE campioni non e' una mediana, e' il campione di mezzo**, e basta
/// che due si fondano perche' il numero raddoppi.
///
/// **Vale la regola di casa al contrario: non si abbassa la soglia, si cambia la
/// grandezza.** Quando si aprira' la voce, la prima cosa non e' correggere il
/// disegno: e' rifare la misura su un campione che regga, per esempio l'area
/// mediana per ELEMENTO acceso invece che per macchia, che non dipende da quante
/// se ne fondono. Il 21,9 resta scritto qui in chiaro: un numero peggiorato che
/// si spiega si scrive, non si nasconde.
///
/// **DUE VINCOLI INSIEME, e uno solo non basterebbe.** Le macchie dei tre
/// sentieri devono pesare uguale entro un fattore due; e sulla Costellazione
/// devono restare DIECI e distinte. Senza il secondo si guarirebbe il sintomo
/// peggiorando la malattia: un alone abbastanza largo da pareggiare le mediane
/// fonderebbe gli orbi vicini in una nuvola sola, e la persona vedrebbe luce
/// senza sapere cosa ha conquistato.
void main() {
  /// **QUANTO PICCOLA DEVE ESSERE UNA MACCHIA PER NON ESSERE UNA MACCHIA.** Sotto
  /// duecento pixel su una tela da un milione e centocinquantamila si sta
  /// guardando il bordo di una linea, non un elemento acceso.
  const macchiaMinima = 200;

  /// **UN FATTORE DUE, e da dove viene.** Non dalla misura di oggi, che sarebbe
  /// una tautologia: viene da cosa deve essere vero perche' la cosa funzioni. Un
  /// traguardo vale quanto un altro, quindi due traguardi accesi su sentieri
  /// diversi devono pesare a occhio lo stesso; il doppio e' il punto oltre il
  /// quale due aree non si leggono piu' come la stessa cosa, perche' e' un
  /// raddoppio, non una sfumatura.
  const fattoreAmmesso = 2.0;

  /// A dodici accesi ne sono comparsi dieci, perche' due erano gia' accesi.
  const macchieAtteseSullaCostellazione = 10;

  Future<(int, int, List<int>)> apri(String file) async {
    final byte = await File(file).readAsBytes();
    final codice = await ui.instantiateImageCodec(byte);
    final immagine = (await codice.getNextFrame()).image;
    final dati = (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    return (immagine.width, immagine.height, dati);
  }

  testWidgets('un traguardo acceso pesa uguale sui tre sentieri',
      (tester) async {
    // **LA CATTURA STA DENTRO runAsync**, altrimenti il codec resta una promessa
    // che il tempo finto della prova non osserva mai.
    await tester.runAsync(() async {
      final mediane = <String, int>{};
      final quante = <String, int>{};
      var osservati = 0;
      for (final sentiero in Sentieri.tutti) {
        final due = 'docs/preview/journal_${sentiero.name}_due.png';
        final dodici = 'docs/preview/journal_${sentiero.name}_dodici.png';
        if (!File(due).existsSync() || !File(dodici).existsSync()) continue;
        osservati++;
        final (larghezza, altezza, a) = await apri(due);
        final (_, _, b) = await apri(dodici);
        final cambiati = List<bool>.filled(larghezza * altezza, false);
        for (var p = 0; p < larghezza * altezza; p++) {
          final i = p * 4;
          final d = (a[i] - b[i]).abs() +
              (a[i + 1] - b[i + 1]).abs() +
              (a[i + 2] - b[i + 2]).abs();
          if (d > 30) cambiati[p] = true;
        }
        final visto = List<bool>.filled(larghezza * altezza, false);
        final aree = <int>[];
        for (var p = 0; p < larghezza * altezza; p++) {
          if (!cambiati[p] || visto[p]) continue;
          visto[p] = true;
          final pila = <int>[p];
          var area = 0;
          while (pila.isNotEmpty) {
            final k = pila.removeLast();
            area++;
            final x = k % larghezza, y = k ~/ larghezza;
            for (final d in const [
              [1, 0],
              [-1, 0],
              [0, 1],
              [0, -1]
            ]) {
              final nx = x + d[0], ny = y + d[1];
              if (nx < 0 || ny < 0 || nx >= larghezza || ny >= altezza) continue;
              final kk = ny * larghezza + nx;
              if (!cambiati[kk] || visto[kk]) continue;
              visto[kk] = true;
              pila.add(kk);
            }
          }
          if (area > macchiaMinima) aree.add(area);
        }
        aree.sort();
        if (aree.isEmpty) continue;
        mediane[sentiero.name] = aree[aree.length ~/ 2];
        quante[sentiero.name] = aree.length;
        // ignore: avoid_print
        print('ORDINE AB VOCE 02: ${sentiero.name}, macchie ${aree.length}, '
            'mediana ${aree[aree.length ~/ 2]}, minima ${aree.first}, '
            'massima ${aree.last}');
      }

      // **QUANTI SENTIERI GUARDATI, e cade se sono zero.**
      // ignore: avoid_print
      print('ORDINE AB VOCE 02: sentieri osservati $osservati, con macchie '
          '${mediane.length}');
      expect(osservati, Sentieri.tutti.length,
          reason: 'manca l\'anteprima a dodici di qualche sentiero: la prova '
              'girerebbe su una parte e direbbe di aver guardato tutto');
      expect(mediane.length, Sentieri.tutti.length,
          reason: 'un sentiero non ha prodotto nessuna macchia sopra i '
              '$macchiaMinima pixel: accendere dodici traguardi non si vede');

      final valori = mediane.values.toList()..sort();
      final rapporto = valori.last / valori.first;
      // ignore: avoid_print
      print('ORDINE AB VOCE 02: rapporto fra la mediana piu\' grande e la piu\' '
          'piccola ${rapporto.toStringAsFixed(1)}');
      expect(rapporto, lessThanOrEqualTo(fattoreAmmesso),
          reason: 'un traguardo acceso pesa ${rapporto.toStringAsFixed(1)} '
              'volte piu\' su un sentiero che su un altro: '
              '${mediane.entries.map((e) => "${e.key} ${e.value}").join(", ")}. '
              'L\'ampiezza dell\'alone deve derivare dalla misura della forma '
              'che illumina, non essere la stessa per tutti');

      expect(quante['costellazione'], macchieAtteseSullaCostellazione,
          reason: 'sulla Costellazione le macchie devono restare '
              '$macchieAtteseSullaCostellazione e distinte: se l\'alone cresce '
              'tanto da fondere gli orbi vicini in una nuvola sola, la persona '
              'vede luce e non sa cosa ha conquistato');
    });
  });
}
