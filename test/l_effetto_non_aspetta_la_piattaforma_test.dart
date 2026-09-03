import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **L'EFFETTO NON ASPETTA LA PIATTAFORMA, E NON CHIEDE IL FUOCO ESCLUSIVO.**
/// Ordine CQ voce 1.04, 3 settembre 2026.
///
/// **Il fatto, parole del fondatore:** *"il suono della carta non si sente."*
///
/// **La provenienza e' la coda dell'ordine CN**, 2 settembre 2026, quella che
/// spiega perche' la build 2218 era muta. Li' era stato misurato che `play` di
/// audioplayers **non e' una chiamata che finisce**: dentro attende un evento
/// `prepared` dalla piattaforma e, se non arriva, resta appesa per sempre
/// senza sollevare niente, quindi nessun `catch` scatta e nessun log esce.
/// Nella stessa coda era stato misurato che il lettore chiede di partenza il
/// **fuoco audio esclusivo**, e resta muto quando qualcun altro ce l'ha.
///
/// **Tutte e due le cure erano state applicate alla musica e a nessun altro.**
/// Il lettore degli effetti e' rimasto con l'attesa dentro e senza contesto
/// audio: una carta che si gira mentre il tappeto suona chiedeva un fuoco che
/// nessuno le dava, e taceva. **Un difetto capito e curato in un posto solo
/// torna dall'altro**, ed e' esattamente cio' che e' successo qui.
void main() {
  final motore =
      File('lib/core/sensi/motore_audio.dart').readAsStringSync();

  test('nessun play di audioplayers si attende', () {
    // **LA GRANDEZZA E' L'ATTESA, non il nome del metodo.** Un `await` davanti
    // a `play` e' la firma del difetto, e si cerca in tutte le sorgenti, non
    // solo in quella dove oggi vive il lettore.
    //
    // **SOLO I LETTORI DI audioplayers, e la prima stesura sbagliava qui.**
    // Cercava un `await` davanti a qualunque `play`, e prendeva anche
    // `VideoPlayerController.play`, che invece finisce e va attesa. Una
    // grandezza troppo larga fa cadere la guardia su cose sane, e chi la
    // legge impara a non fidarsene. **I lettori di audioplayers vivono in un
    // file solo**, ed e' una legge gia' sorvegliata altrove.
    final attese = <String>[];
    var guardati = 0;
    for (final file in sorgentiDiLib()) {
      final testo = file.readAsStringSync();
      if (!testo.contains('package:audioplayers')) continue;
      guardati++;
      for (final riga in testo.split(String.fromCharCode(10))) {
        if (RegExp(r'await\s+[\w\._]*\.play\(').hasMatch(riga)) {
          attese.add('${file.path}: ${riga.trim()}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.04: sorgenti che chiamano play $guardati, '
        'attese trovate ${attese.length} $attese');
    cardinaleMinimo(guardati, 1,
        cosa: 'sorgenti che chiamano play su un lettore',
        perche: 'Se nessuna sorgente chiamasse piu play, questa prova sarebbe '
            'verde senza aver guardato una sola riga.');
    expect(attese, isEmpty,
        reason: 'un play si attende: e la chiamata che non finisce, quella che '
            'ha reso muta la build 2218. Righe: ${attese.join(" | ")}');
  });

  test('il lettore degli effetti dichiara il suo contesto audio', () {
    expect(motore, contains('_preparaGliEffetti()'),
        reason: 'il lettore degli effetti non prepara nessun contesto: chiede '
            'il fuoco audio esclusivo di partenza, e resta muto quando la '
            'musica o un video ce l hanno');
    final prepara = motore.substring(motore.indexOf('_preparaGliEffetti() async'));
    final corpo = prepara.substring(0, prepara.indexOf('audioFocus') + 60);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.04: il fuoco chiesto dagli effetti e '
        '${RegExp(r'audioFocus: (\w+\.\w+)').firstMatch(corpo)?.group(1)}');
    expect(corpo, contains('AndroidAudioFocus.none'),
        reason: 'gli effetti chiedono ancora un fuoco audio: un effetto breve '
            'non ha bisogno di essere l unica sorgente, e chiedendolo perde');
    expect(motore, contains('await _preparaGliEffetti();'),
        reason: 'il contesto non si imposta prima di suonare: il primo suono '
            'esce col comportamento di partenza, che e quello sbagliato');
  });
}
