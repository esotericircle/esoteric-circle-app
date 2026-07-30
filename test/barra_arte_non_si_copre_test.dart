import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:provider/provider.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA BARRA IN ALTO: le azioni non si coprono, per costruzione.
///
/// **La segnalazione, con tre screenshot del fondatore.** Test Archetipo,
/// Estrazione Rune e Costellazione del Viso: il cuore dorato pieno era disegnato
/// SOPRA il cerchietto della "i", di cui restava visibile solo la meta' destra.
///
/// **Non dipendeva dalla larghezza.** I due elementi occupavano lo stesso posto,
/// quindi si sovrapponevano a qualunque misura: il cuore stava in uno Stack
/// ancorato in alto a destra, le azioni della barra pure. Il cuore dei preferiti
/// era stato montato dove c'era gia' qualcosa.
///
/// **Perche' la correzione non e' nelle tre schermate.** Il difetto non era in
/// nessuna delle tre: era che non esisteva un posto solo dove le azioni della
/// barra si dichiarano, quindi due autori diversi hanno messo due cose nello
/// stesso angolo senza potersi accorgere l'uno dell'altro. Adesso le azioni
/// stanno in una riga, e due elementi di una riga non si sovrappongono.
void main() {
  /// Le schermate d'arte che hanno una barra con azioni proprie.
  ///
  /// Enumerate leggendo i sorgenti e non elencate a mano: una lista scritta a
  /// mano invecchia in silenzio, e la quarta schermata che nasce non ci finisce
  /// dentro.
  List<String> schermateConBarraEAzioni() {
    final trovate = <String>[];
    for (final f in Directory('lib/features').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final testo = f.readAsStringSync();
      if (!testo.contains('SogliaArte(')) continue;
      if (!testo.contains('actions:')) continue;
      trovate.add(f.path.replaceAll(Platform.pathSeparator, '/'));
    }
    return trovate;
  }

  test('Le schermate d\'arte con azioni passano tutte dalla barra unica', () {
    final fuori = <String>[];
    for (final p in schermateConBarraEAzioni()) {
      final testo = File(p).readAsStringSync();
      // Una AppBar montata a mano e' il modo in cui il difetto e' nato: le
      // azioni le dichiara qualcuno che non sa cosa ci sia gia' in quell'angolo.
      if (testo.contains('appBar: AppBar(')) fuori.add(p);
    }
    expect(fuori, isEmpty,
        reason: 'queste schermate d\'arte montano una barra tutta loro invece '
            'di passare da BarraArte: le azioni finiscono nello stesso angolo '
            'del cuore dei preferiti e si coprono a vicenda. $fuori');
  });

  testWidgets('Il cuore e il tasto informazioni non si sovrappongono',
      (tester) async {
    // La misura e' sui RETTANGOLI e non sul conteggio dei widget: due icone
    // possono esistere entrambe ed essere una sopra l'altra, ed e' esattamente
    // cio' che succedeva.
    await tester.pumpWidget(_arteDiProva());
    await tester.pump();

    final cuore = tester.getRect(find.byKey(const Key('cuore_prova')));
    final info = tester.getRect(find.byKey(const Key('prova_info')));

    expect(cuore.overlaps(info), isFalse,
        reason: 'il cuore dei preferiti e il tasto informazioni occupano lo '
            'stesso posto: il cuore, disegnato sopra, copre la "i" e ne lascia '
            'visibile solo la meta destra');
  });

  testWidgets('Con la barra, il cuore non viene disegnato due volte',
      (tester) async {
    // Il cuore sovrapposto si toglie quando la barra se ne prende carico. Se
    // restassero tutti e due, il secondo tornerebbe a coprire la "i".
    await tester.pumpWidget(_arteDiProva());
    await tester.pump();
    expect(find.byKey(const Key('cuore_prova')), findsOneWidget,
        reason: 'il cuore compare piu\' di una volta: quello sovrapposto non si '
            'e\' tolto di mezzo');
  });
}

/// Un'arte finta con la barra unica e un'azione propria.
Widget _arteDiProva() => ChangeNotifierProvider(
      // Senza il controller delle preferite il cuore non si disegna affatto, e
      // la prova misurerebbe l'assenza invece della posizione.
      create: (_) => ArtiPreferiteController(),
      child: MaterialApp(
      home: SogliaArte(
        id: 'prova',
        maestro: Maestro.aura,
        child: Scaffold(
          appBar: BarraArte(
            titolo: const Text('Arte di prova'),
            azioni: [
              IconButton(
                key: const Key('prova_info'),
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () {},
              ),
            ],
          ),
          body: const SizedBox.expand(),
        ),
      ),
      ),
    );
