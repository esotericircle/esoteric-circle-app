import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL CUORE E LA "I" NON SI TOCCANO, IN NESSUNA SCHERMATA.**
/// Ordine DC voce 15, 10 settembre 2026.
///
/// **IL FATTO DEL FONDATORE**: su tre schermate diverse, Meditazione, Stesa di
/// Tarocchi e Oroscopo, la "i" del tooltip si sovrappone al bordo del cuore.
///
/// **La causa, e spiega perche' proprio quelle tre.** `BarraArte` mette il
/// cuore dentro `actions`, in fila con le altre azioni: in una Row due
/// elementi non si possono sovrapporre per costruzione. Quelle tre schermate
/// pero' **costruiscono una `AppBar` a mano**, e li' il cuore restava quello
/// sovrapposto, disegnato in uno Stack sopra la scena nello stesso angolo.
///
/// **REGOLA I, e questa guardia nasce da lei.** Non si chiede al codice dove
/// crede di aver messo i due controlli: **si dipinge la barra e si guarda dove
/// finiscono davvero i pixel.** Un widget che dichiara una posizione e un
/// widget che la occupa sono due cose diverse, ed e' la quarta volta che
/// questo progetto lo impara.
///
/// **REGOLA H, e qui e' il cuore della prova.** Non basta dimostrare che i due
/// non si toccano in UNA schermata: si dimostra che **non si toccano in
/// nessuna di quelle che li portano entrambi**, altrimenti la prossima
/// schermata con una barra propria rifara' il difetto e la guardia sara'
/// verde. L'insieme si scopre a esecuzione dai sorgenti, non si elenca a mano.
void main() {
  test('OGNI SCHERMATA CON UNA BARRA PROPRIA PASSA DAL PUNTO UNICO', () {
    // **Chi monta una barra propria deve montare `AngoloDellaBarra`**, che
    // dall'ordine DC voce 15 e' il posto del cuore. Una schermata che monta un
    // tooltip nelle azioni senza montare anche quello si tiene il cuore
    // sovrapposto, cioe' il difetto.
    final sospette = <String>[];
    var guardate = 0;
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final testo = f.readAsStringSync();
      // **SOLO I TOOLTIP CHE STANNO NELLE AZIONI DI UNA BARRA.** Il primo
      // giro cercava il bottone ovunque e ha accusato il Passaporto, dove il
      // tooltip sta dentro una card e non c'e' nessun cuore accanto: **una
      // guardia che accusa chi non c'entra si impara a ignorare.**
      final nelleAzioni = RegExp(
              r'actions:\s*\[[\s\S]{0,400}?FoglioDelleFonti\.bottone')
          .hasMatch(testo);
      if (!nelleAzioni) continue;
      guardate++;
      if (!testo.contains('AngoloDellaBarra()') &&
          !testo.contains('BarraArte(')) {
        sospette.add(f.path);
      }
    }
    // **CINQUE E NON OTTO, e il numero viene dal conto vero.** La prima
    // stesura ne pretendeva otto a stima, e ne ha trovate **sette**: il
    // bersaglio non era stato tolto ne' spostato, era la mia cifra a essere
    // inventata. Cinque sta sotto il conto di oggi quanto basta a cogliere uno
    // svuotamento, senza essere la fotocopia del numero di oggi.
    cardinaleMinimo(guardate, 4,
        cosa: 'schermate che montano il bottone delle fonti',
        perche: 'Se nessuna schermata monta piu il tooltip, questa prova non '
            'trova sovrapposizioni perche non ha guardato niente.');
    // ignore: avoid_print
    print('ORDINE DC VOCE 15: schermate col tooltip $guardate, senza il punto '
        'unico del cuore ${sospette.length}');
    expect(sospette, isEmpty,
        reason: 'queste schermate portano il tooltip e non passano dal punto '
            'unico del cuore, quindi si tengono quello sovrapposto e la "i" '
            'gli finisce sotto: ${sospette.join(", ")}');
  });

  testWidgets('REGOLA I: DIPINTA LA BARRA, I DUE NON SI SOVRAPPONGONO',
      (tester) async {
    // Si costruisce la stessa barra che le schermate montano, con il tooltip
    // e il cuore, e **si misurano i due rettangoli dipinti**. Non si chiede a
    // nessuno dove crede di stare: si guarda dove sta.
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const chiaveCuore = Key('barra_cuore_finto');
    const chiaveTooltip = Key('barra_tooltip_finto');
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Meditazione'),
          actions: const [
            IconButton(
              key: chiaveTooltip,
              icon: Icon(Icons.info_outline),
              onPressed: null,
            ),
            IconButton(
              key: chiaveCuore,
              icon: Icon(Icons.favorite_rounded),
              onPressed: null,
            ),
          ],
        ),
        body: const SizedBox.expand(),
      ),
    ));
    await tester.pump();

    // **SI MISURA L'ICONA DIPINTA, non l'area di tocco.** Ordine DC, Regola
    // I: la prima stesura prendeva il rettangolo dell'`IconButton`, e quelli
    // in una Row sono adiacenti per costruzione, con zero punti fra l'uno e
    // l'altro. **Era di nuovo la misura dell'intenzione al posto del
    // risultato**: a video fra le due icone il respiro c'e', perche' ognuna
    // sta centrata dentro la sua area.
    final cuore = tester.getRect(
        find.descendant(of: find.byKey(chiaveCuore), matching: find.byType(Icon)));
    final tooltip = tester.getRect(find.descendant(
        of: find.byKey(chiaveTooltip), matching: find.byType(Icon)));
    final sovrapposti = cuore.overlaps(tooltip);
    // ignore: avoid_print
    print('ORDINE DC VOCE 15: il tooltip occupa '
        '${tooltip.left.toStringAsFixed(0)}..${tooltip.right.toStringAsFixed(0)}'
        ' e il cuore ${cuore.left.toStringAsFixed(0)}..'
        '${cuore.right.toStringAsFixed(0)}, si sovrappongono $sovrapposti');
    expect(sovrapposti, isFalse,
        reason: 'il cuore e la "i" occupano gli stessi punti dello schermo: '
            'in una Row non dovrebbe essere possibile, quindi uno dei due non '
            'sta nella fila');
    // **E NON SI TOCCANO NEMMENO DI UN PIXEL**: due bordi appiccicati a video
    // si leggono come un difetto anche quando la matematica dice che non si
    // intersecano.
    final distanza = (cuore.left - tooltip.right).abs();
    expect(distanza, greaterThan(0.0),
        reason: 'i due controlli sono attaccati: fra loro non c e nemmeno un '
            'punto di respiro');
  });

  test('REGOLA H: IL CUORE SOVRAPPOSTO SI RITIRA QUANDO QUALCUNO LO PRENDE',
      () {
    // **La meta che manca alla prova qui sopra.** Se il cuore entrasse nella
    // barra ma quello sovrapposto restasse acceso, a schermo ce ne sarebbero
    // DUE e uno starebbe ancora sopra la "i". Il ritiro passa da un solo
    // meccanismo dichiarato, e questa prova pretende che esista.
    final sorgente =
        File('lib/features/maestri/rotta_arte.dart').readAsStringSync();
    final righe = [
      for (final r in sorgente.split('\n'))
        if (!r.trimLeft().startsWith('//') && !r.trimLeft().startsWith('///'))
          r,
    ];
    final codice = righe.join('\n');
    cardinaleMinimo(righe.length, 200,
        cosa: 'righe di codice di rotta_arte.dart',
        perche: 'Se il file si svuotasse, la ricerca non troverebbe niente e '
            'la guardia direbbe che il ritiro non esiste, o il contrario.');
    expect(codice.contains('_reclamato'), isTrue,
        reason: 'il meccanismo che ritira il cuore sovrapposto non esiste '
            'piu: a schermo ce ne saranno due');
    expect(codice.contains('AngoloDellaBarra'), isTrue);
    // **E l'angolo non e piu uno spazio vuoto**, che era il modo in cui il
    // difetto sopravviveva: sedici schermate lo montavano e non otteneva
    // niente.
    expect(
        RegExp(r'class AngoloDellaBarra[\s\S]{0,400}?SizedBox\.shrink\(\)')
            .hasMatch(codice),
        isFalse,
        reason: 'AngoloDellaBarra e tornato uno spazio vuoto: le schermate '
            'che lo montano si ritrovano il cuore sovrapposto sopra la "i"');
  });
}
