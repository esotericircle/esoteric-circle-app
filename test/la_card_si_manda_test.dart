import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/components/card_da_mandare.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LA CARD SI MANDA.** Ordine CQ voce 6.26, 4 settembre 2026.
///
/// **La domanda del fondatore**: *"ogni responso deve diventare virale e
/// l'utente deve essere spinto emotivamente a condividere, quindi secondo te:
/// perche' l'utente dovrebbe condividere il contenuto? e a proposito della
/// card, cosa dovrebbe esserci d'impatto?"*
///
/// **La risposta, e questa guardia la tiene ferma.** Le persone non
/// condividono informazioni: condividono identita'. Da qui tre vincoli, e sono
/// tre cose misurabili.
///
/// **UNA FRASE SOLA.** Nessuno manda tre paragrafi. Se la frase e' lunga
/// quanto un paragrafo, la card e' un documento e non un'immagine.
///
/// **IL SIMBOLO E' SUO.** Una card con un marchio al centro pubblicizza l'app;
/// una con la sua runa parla di lui, e fa nascere nell'amico l'unica domanda
/// che porta dentro qualcuno.
///
/// **UNA CARD SOLA PER SETTE ARTI.** Sette card scritte a mano sono sette
/// identita' visive che divergono alla prima modifica.
void main() {
  MaestroPalette palette() =>
      MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));

  testWidgets('la card porta la frase e il simbolo, e poco altro',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: CardDaMandare(
            palette: palette(),
            arte: 'Estrazione Rune',
            frase: 'Oggi tieni senza stringere.',
            parola: 'custodire',
            simbolo: const SizedBox(width: 190, height: 190),
          ),
        ),
      ),
    ));
    await tester.pump();

    // I blocchi di testo della card, contati: ogni riga in piu' toglie forza
    // alla frase e al simbolo, che sono le uniche due cose che si guardano.
    final testi = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('card_da_mandare')),
            matching: find.byType(Text)))
        .toList();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.26: blocchi di testo nella card ${testi.length}: '
        '${testi.map((t) => t.data).join(" | ")}');
    cardinaleMinimo(testi.length, 3,
        cosa: 'blocchi di testo trovati nella card',
        perche: 'Con meno di tre blocchi la card non ha ne la frase ne il '
            'marchio, e la prova direbbe che e pulita per non aver trovato '
            'niente.');
    expect(testi.length, lessThanOrEqualTo(5),
        reason: 'la card porta ${testi.length} blocchi di testo: ogni riga in '
            'piu toglie forza alla frase e al simbolo, e una card che si '
            'legge tutta non si manda');
    expect(find.byKey(const Key('card_frase')), findsOneWidget,
        reason: 'la card non porta nessuna frase');
  });

  testWidgets('e la frase sta al centro, sopra il marchio', (tester) async {
    await tester.binding.setSurfaceSize(const Size(500, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: CardDaMandare(
            palette: palette(),
            arte: 'Estrazione Rune',
            frase: 'Oggi tieni senza stringere.',
            simbolo: const SizedBox(width: 120, height: 120),
          ),
        ),
      ),
    ));
    await tester.pump();

    final frase = tester.getRect(find.byKey(const Key('card_frase')));
    final marchio = tester.getRect(find.byKey(const Key('card_marchio')));
    final arte = tester.getRect(find.byKey(const Key('card_arte')));
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.26: l arte sta a ${arte.center.dy.round()}, la '
        'frase a ${frase.center.dy.round()}, il marchio a '
        '${marchio.center.dy.round()}');
    expect(frase.center.dy, greaterThan(arte.center.dy),
        reason: 'la frase sta sopra il nome dell arte: il nome dell arte e '
            'testo di servizio e non deve prendere il centro');
    expect(frase.center.dy, lessThan(marchio.center.dy),
        reason: 'la frase sta sotto il marchio: il marchio pubblicizza l app, '
            'la frase parla di chi la manda, e chi la manda viene prima');
    // **LA FRASE E PIU GRANDE DI TUTTO IL RESTO**, che e' cio' che la fa
    // leggere scorrendo una storia.
    final stileFrase = tester.widget<Text>(find.byKey(const Key('card_frase')));
    final stileMarchio =
        tester.widget<Text>(find.byKey(const Key('card_marchio')));
    expect(stileFrase.style!.fontSize!,
        greaterThan(stileMarchio.style!.fontSize! * 1.8),
        reason: 'la frase non e abbastanza piu grande del testo di servizio: '
            'in una storia si legge quella o non si legge niente');
  });

  test('e la card e una sola per tutte le arti', () {
    // **SETTE CARD SCRITTE A MANO SONO SETTE IDENTITA' CHE DIVERGONO.**
    // Questa prova non pretende che tutte siano gia' passate dalla porta,
    // perche' non lo sono: pretende che chi ci passa non se ne apra una
    // propria accanto.
    final componente =
        File('lib/design_system/components/card_da_mandare.dart');
    expect(componente.existsSync(), isTrue,
        reason: 'il componente della card non esiste piu');

    var quante = 0;
    final passano = <String>[];
    for (final file in sorgentiDiLib()) {
      final testo = file.readAsStringSync();
      if (!testo.contains('ShareCard')) continue;
      quante++;
      if (testo.contains('CardDaMandare(')) {
        passano.add(file.path.split(RegExp(r'[\\/]')).last);
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.26: card da condividere censite $quante, gia '
        'passate dalla porta comune ${passano.length}: ${passano.join(", ")}');
    cardinaleMinimo(quante, 5,
        cosa: 'card da condividere trovate nei sorgenti',
        perche: 'Con poche card la prova direbbe che sono tutte a posto per '
            'non averne trovate abbastanza.');
    expect(passano, isNotEmpty,
        reason: 'nessuna card passa dalla porta comune: il componente esiste '
            'e nessuno lo usa, che e la forma piu silenziosa di difetto');
  });
}
