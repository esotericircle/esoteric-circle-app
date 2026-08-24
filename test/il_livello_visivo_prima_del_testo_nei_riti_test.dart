import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL LIVELLO VISIVO PRIMA DEL TESTO, IN TUTTI I RITI. Ordine S voce 11.
///
/// **Il fatto, visto sulla 2177.** Nel Rito del Tramonto le tre righe "Cosa fai",
/// "Perche'" e "Cosa ti resta" stavano SOPRA la pietra, dentro lo stesso
/// scorrimento, e la spingevano in basso: la schermata si leggeva come un foglio
/// di istruzioni con una runa in mezzo.
///
/// **L'ordine chiede di piu' della singola schermata:** vale come principio
/// generale per tutti i riti, e se in un altro rito la stessa cosa e' successa si
/// corregge li' e lo si dichiara. Percio' questa prova ENUMERA i riti che montano
/// le tre righe: visitarne uno non direbbe niente degli altri.
///
/// **E DEI QUATTRO, TRE NON AVEVANO IL DIFETTO, verificato guardando le
/// anteprime.** Alba e Soffio mostrano il dono in una SCHEDA che poggia sopra la
/// scena: il sole sollevato occupa i due terzi alti e la scheda arriva sotto,
/// quindi le tre righe in cima alla scheda vengono comunque dopo il livello
/// visivo. Lo stesso vale per il saluto della notte nel Sigillo del Sogno, che
/// arriva dopo il cielo, e per l'Oracolo, dove il disco sta sopra la lettura. Il
/// Tramonto era l'unico a tenerle nella stessa colonna della pietra, e li' la
/// misura si fa a schermo, nella prova dedicata
/// `test/l_invito_sta_subito_sotto_la_pietra_test.dart` piu' quella qui sotto.
void main() {
  /// I RITI CHE MONTANO LE TRE RIGHE, e dove sta il loro livello visivo.
  ///
  /// `dentroLaColonna` e' vero quando il pezzo visivo vive nella STESSA colonna
  /// delle tre righe: solo in quel caso l'ordine di dichiarazione decide chi si
  /// vede prima, e solo in quel caso si puo' sorvegliare leggendo il sorgente.
  const riti = <String, ({String visivo, bool dentroLaColonna})>{
    'lib/features/rituals/sunset_rune_screen.dart': (
      visivo: 'sunset_pietra_lettura',
      dentroLaColonna: true,
    ),
    'lib/features/rituals/dream_rite_screen.dart': (
      // Il cielo delle stelle e' la scena; il saluto arriva dopo, in un'altra
      // parte della schermata.
      visivo: 'lo sfondo della schermata, sopra il saluto',
      dentroLaColonna: false,
    ),
    'lib/features/rituals/ritual_gift_card.dart': (
      // La scheda del dono poggia SOPRA la scena del rito: il sole sollevato
      // occupa i due terzi alti e la scheda comincia sotto.
      visivo: 'la scena del rito, dietro e sopra la scheda',
      dentroLaColonna: false,
    ),
    'lib/features/rituals/ritual_view.dart': (
      visivo: 'il disco dell\'Oracolo, sopra la lettura',
      dentroLaColonna: false,
    ),
  };

  test('dove il visivo sta nella stessa colonna, il testo viene dopo', () {
    final colpevoli = <String>[];
    for (final voce in riti.entries) {
      if (!voce.value.dentroLaColonna) continue;
      final sorgente = File(voce.key).readAsStringSync();
      final righe = sorgente.indexOf('LeTreRigheDelRito(');
      if (righe < 0) continue;
      final visivo = sorgente.indexOf(voce.value.visivo);
      if (visivo < 0) {
        colpevoli.add('${voce.key}: il livello visivo «${voce.value.visivo}» non '
            'c\'e\' piu\', e questa prova non sa piu\' cosa guardare');
        continue;
      }
      if (righe < visivo) {
        colpevoli.add('${voce.key}: le tre righe sono dichiarate prima di '
            '«${voce.value.visivo}», nella stessa colonna, quindi spingono in '
            'basso il pezzo che deve vedersi per primo');
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'il livello visivo viene prima del testo, in ogni rito:\n'
            '${colpevoli.join("\n")}');
  });

  test('l\'elenco dei riti e\' completo, e la prova se ne accorge', () {
    // **IL PRESIDIO CONTRO IL RITO NUOVO.** Se un file monta le tre righe e non
    // e' nell'elenco, questa cade col suo nome: e' il solo modo in cui
    // un'enumerazione resta vera invece di invecchiare in silenzio.
    final fuori = <String>[];
    for (final voce in Directory('lib/features').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll('\\', '/');
      if (!voce.readAsStringSync().contains('LeTreRigheDelRito(')) continue;
      if (riti.containsKey(percorso)) continue;
      fuori.add(percorso);
    }
    expect(fuori, isEmpty,
        reason: 'questi riti montano le tre righe e non sono nell\'elenco: '
            'dichiara dove sta il loro livello visivo, altrimenti nessuno si '
            'accorge se il testo torna davanti:\n${fuori.join("\n")}');
  });

  test('ogni rito dichiara il suo livello visivo con una ragione', () {
    // Un'esenzione senza ragione e' un buco, non una decisione: chi dice che il
    // visivo NON sta nella colonna deve dire dove sta, in parole.
    final vaghi = <String>[];
    for (final voce in riti.entries) {
      if (voce.value.dentroLaColonna) continue;
      if (voce.value.visivo.length < 20) vaghi.add(voce.key);
    }
    expect(vaghi, isEmpty,
        reason: 'questi riti sono esentati senza dire dove sta il loro livello '
            'visivo: $vaghi');
  });
}
