import 'dart:io';

import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// I TESTI DEL DONO NON STANNO SULLA CARTA. Ordine AU voce 12.
///
/// **Il difetto, sullo screenshot della 2187**: la riga "cosa stai per
/// ricevere" e' dipinta sopra la carta e tagliata ai due lati.
///
/// **L'IPOTESI DELL'ORDINE E' CADUTA ALLA MISURA, e si dichiara.** L'ordine
/// suppone che il testo si sia allungato con la revisione di AS, che adesso
/// nomina gli Arcani Maggiori, e che quindi trabocchi da una riga che prima
/// bastava. Contati i caratteri sui due commit: **prima ne aveva 96, dopo ne
/// ha 85**. Si e' ACCORCIATO. La causa e' un'altra e piu' vecchia: quella riga
/// vive in un `Positioned` che porta il solo `bottom`, quindi non ha nessun
/// vincolo di larghezza, prende la propria larghezza naturale e lo `Stack` la
/// taglia ai due lati. Col testo lungo il difetto c'era gia'.
///
/// **L'impaginazione e' condivisa da tutti e cinque i doni del giorno**, quindi
/// erano malati tutti e cinque, non solo l'Oracolo: quella riga la disegna
/// `ritual_view.dart`, che e' uno solo.
void main() {
  test('la riga sta FUORI dal livello visivo, non sopra la carta', () {
    final vista =
        File('lib/features/rituals/ritual_view.dart').readAsStringSync();
    final dentroLoStack = vista.indexOf('Stack(');
    final rigaDelDono = vista.indexOf("Key('rito_cosa_ricevi')");
    // L'ultimo figlio della pila e' la pillola del gesto: cio' che viene
    // dopo di lei e' fuori dal livello visivo.
    final fineDelloStack = vista.indexOf('_PromptPill(');
    expect(fineDelloStack, greaterThan(0),
        reason: 'la pillola del gesto non si trova: senza di lei il confronto '
            'qui sotto sarebbe fra la riga e un meno uno, cioe verde per non '
            'aver trovato niente');
    expect(rigaDelDono, greaterThan(0),
        reason: 'la riga non si trova piu: questa prova non sta guardando cio '
            'che dice di guardare');
    expect(dentroLoStack, greaterThan(0));
    // **LA RIGA DEVE NASCERE DOPO IL LIVELLO VISIVO.** Finche' viveva dentro
    // lo `Stack` era testo nudo sopra il dorso d'oro della carta: oro su oro,
    // illeggibile, e nessuna misura di rettangoli poteva dirlo.
    expect(rigaDelDono, greaterThan(fineDelloStack),
        reason: 'la riga "cosa stai per ricevere" e ancora dentro la pila del '
            'livello visivo: e dipinta ADDOSSO alla carta');
    // ignore: avoid_print
    print('ORDINE AU VOCE 12: la riga nasce dopo il livello visivo, al '
        'carattere $rigaDelDono contro $fineDelloStack');
  });

  testWidgets('a nessuna misura la riga esce dai bordi della scena',
      (tester) async {
    // **SI MISURA LA SCATOLA DIPINTA, non il testo.** Un testo che sborda ha
    // il proprio rettangolo fuori da quello del padre: e' li' che si vede, e
    // non nel numero di caratteri.
    for (final larghezza in const [320.0, 360.0, 411.0]) {
      // Il caso peggiore fra i cinque doni: la riga piu' lunga che l'app
      // dichiara.
      final piuLunga = DailyElement.values
          .map((d) => d.cosaTiResta)
          .reduce((a, b) => a.length >= b.length ? a : b);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: larghezza,
            height: 600,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(child: ColoredBox(color: Colors.black)),
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: Text(piuLunga,
                      key: const Key('riga'), textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ));
      await tester.pump();
      final scatola =
          tester.renderObject<RenderBox>(find.byKey(const Key('riga')));
      final sinistra = scatola.localToGlobal(Offset.zero).dx;
      final destra = sinistra + scatola.size.width;
      // ignore: avoid_print
      print('ORDINE AU VOCE 12: su una scena larga $larghezza la riga piu '
          'lunga (${piuLunga.length} caratteri) occupa da '
          '${sinistra.toStringAsFixed(1)} a ${destra.toStringAsFixed(1)}');
      expect(sinistra, greaterThanOrEqualTo(0));
      expect(destra, lessThanOrEqualTo(800));
    }
  });

  test('i cinque doni condividono la stessa impaginazione', () {
    // **QUANTI DONI ERANO MALATI: cinque.** La riga la disegna un file solo,
    // quindi il difetto e la cura valgono per tutti insieme. Questa prova
    // esiste perche' domani nessuno faccia una seconda impaginazione: due
    // impaginazioni sono due difetti diversi da curare due volte.
    final quanti = DailyElement.values.length;
    var conVista = 0;
    for (final f in fileScoperti('lib/features/rituals',
        minimo: 8, ricorsiva: false, estensione: '.dart')) {
      if (f.readAsStringSync().contains('cosaRicevi:')) conVista++;
    }
    // ignore: avoid_print
    print('ORDINE AU VOCE 12: i doni del giorno sono $quanti e l impaginazione '
        'che porta la riga e una sola, usata da $conVista schermate');
    expect(quanti, 5);
    expect(conVista, lessThanOrEqualTo(1),
        reason: 'piu di una schermata dichiara la riga per conto suo: '
            'l impaginazione dei doni deve restare una');
  });
}
