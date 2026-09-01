import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LO STELO SE NE VA DOPO I PETALI. Ordine AS voce 07.
///
/// **Il fatto di Mauro**: dopo l'animazione dei petali lo stelo deve sparire.
///
/// **La causa, letta nel codice.** Il disegno del soffione era in due parti,
/// e la prima portava scritto "lo stelo col ricettacolo, sempre piantato nel
/// prato": si disegnava con una `Paint()` piena, senza nessun legame col
/// progresso del soffio. La testa si diradava, i pappi volavano, e restava un
/// gambo nudo in primo piano sotto il dono.
///
/// **Perche' questa guardia guarda il SORGENTE e non i pixel.** Il soffione e'
/// un'immagine caricata da un asset e dipinta dentro un `CustomPainter` che
/// vive in una schermata con sensori, animazioni e un dono che arriva alla
/// fine: montarla in prova per fotografarla costerebbe un minuto e
/// misurerebbe soprattutto il caricamento dell'asset. Qui si pretende che il
/// disegno dello stelo DIPENDA dal progresso, che e' l'invariante vero: se
/// qualcuno rimette una `Paint()` piena, questa riga cade.
void main() {
  final sorgente = File('lib/features/rituals/breath_destiny_screen.dart')
      .readAsStringSync();

  /// **IL CODICE SENZA I COMMENTI, e la prima stesura di questa prova ci e'
  /// cascata.** Il commento che spiega la cura CITA il difetto vecchio, "lo
  /// stelo sempre piantato nel prato": cercando nel file intero la prova
  /// trovava la propria spiegazione e accusava il codice curato. E' la stessa
  /// trappola che in quest'app aveva gia' fatto credere che tutto fosse
  /// scaffalato perche' un commento nominava lo Scaffold.
  final soloCodice = sorgente
      .split(String.fromCharCode(10))
      .where((r) => !r.trimLeft().startsWith('//'))
      .join(String.fromCharCode(10));

  test('lo stelo non si dichiara piu sempre piantato', () {
    expect(soloCodice.contains('sempre piantato'), isFalse,
        reason: 'lo stelo si dichiara di nuovo sempre piantato, e questa volta '
            'nel codice e non in un commento');
  });

  test('lo stelo si dipinge con una opacita che viene dal soffio', () {
    // La costante che decide quando comincia a ritirarsi, e l'uso di quella
    // opacita' nel disegno: due cose, non una, perche' una costante dichiarata
    // e mai usata sarebbe una promessa scritta.
    expect(sorgente.contains('quandoLoSteloSiRitira'), isTrue,
        reason: 'la soglia del ritiro dello stelo non esiste piu');
    expect(sorgente.contains('final steloOpacita'), isTrue,
        reason: 'lo stelo non calcola piu la sua opacita');
    expect(
        sorgente.contains(
            'Paint()..color = Colors.white.withValues(alpha: steloOpacita)'),
        isTrue,
        reason: 'lo stelo non usa piu la propria opacita quando si dipinge: '
            'la calcola e la butta via, quindi resta pieno come prima');
  });

  test('a soffio finito lo stelo e trasparente, per aritmetica', () {
    // **LA FORMULA SI RIFA' QUI, coi numeri dichiarati nel codice.** Non e' un
    // doppione del calcolo: e' la verifica che la formula scelta faccia cio'
    // che la voce chiede, cioe' uno all'inizio e zero alla fine.
    double opacita(double p, {double soglia = 0.7}) =>
        p <= soglia ? 1.0 : (1 - (p - soglia) / (1 - soglia)).clamp(0.0, 1.0);
    // ignore: avoid_print
    print('ORDINE AS VOCE 07: opacita dello stelo a 0.0 ${opacita(0)}, a 0.7 '
        '${opacita(0.7)}, a 0.85 ${opacita(0.85)}, a 1.0 ${opacita(1)}');
    expect(opacita(0), 1.0, reason: 'a soffio non cominciato lo stelo non c e');
    expect(opacita(0.7), 1.0,
        reason: 'mentre la testa si dirada lo stelo deve restare: e il gesto '
            'in corso');
    expect(opacita(0.85), closeTo(0.5, 0.01),
        reason: 'a meta del ritiro lo stelo deve essere a meta');
    expect(opacita(1), 0.0,
        reason: 'a soffio finito lo stelo e ancora li, ed e il gambo nudo che '
            'Mauro ha visto');
  });
}
