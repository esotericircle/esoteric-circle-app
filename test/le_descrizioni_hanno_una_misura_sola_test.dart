import 'dart:io';

import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE DESCRIZIONI HANNO UNA MISURA SOLA. Ordine CC voce 05.
///
/// **Rilievo del fondatore, 29 agosto 2026, verbatim:** "volgio un censimento
/// globale per la dimensione dei caratteri delle descrizioni di tutto tranne
/// della home [...] prendi come base le dimensioni dei caratteri del responso
/// dei tarocchi. non posso avere un app dove ogni funzionalita' ha font con
/// dimensioni diverse, dove alcuni responsi sono piccoli e poco leggibili ed
/// altri ok."
///
/// **LA MISURA DI RIFERIMENTO NON SI SCEGLIE, SI PRENDE.** E' quella del
/// responso dei Tarocchi, cioe' `TypographyTokens.lettura()`: diciotto punti,
/// interlinea 1,55. Questa prova la legge dal token invece di scriverne il
/// numero, cosi' il giorno che il responso dei Tarocchi cambia misura cambiano
/// anche tutte le altre.
///
/// **QUESTA PROVA ENUMERA, non visita.** Guarda ogni arte dell'app, una per
/// una, e cade il giorno che una di loro mostra il proprio responso a una
/// misura diversa. La home resta fuori: lo dice il fondatore.
void main() {
  /// Le arti dell'app, con la schermata che la persona apre. La home e il
  /// Santuario non ci sono, per ordine del fondatore.
  const arti = <String, String>{
    'Oroscopo': 'lib/features/horoscope/oroscopo_screen.dart',
    'Stesa a tre carte': 'lib/features/tarot/stesa_tre_carte_screen.dart',
    'Carta ingrandita': 'lib/features/tarot/carta_ingrandita.dart',
    'Arcano del giorno': 'lib/features/rituals/day_oracle_screen.dart',
    'Rito dell\'alba': 'lib/features/rituals/dawn_rite_screen.dart',
    'Soffio': 'lib/features/rituals/breath_destiny_screen.dart',
    'Rito del sogno': 'lib/features/rituals/dream_rite_screen.dart',
    'Runa del tramonto': 'lib/features/rituals/sunset_rune_screen.dart',
    'Gettata di rune': 'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
    'Animale guida':
        'lib/features/maestri/caligo/animal/guide_animal_screen.dart',
    'Sigillo di intenzione':
        'lib/features/maestri/caligo/sigillo/sigillo_intenzione_screen.dart',
    'Angeli custodi': 'lib/features/angels/angels_screen.dart',
    'Test Archetipo':
        'lib/features/maestri/aura/archetype/archetype_test_screen.dart',
    'Costellazione del viso':
        'lib/features/maestri/aura/face/face_constellation_screen.dart',
    'Meditazione':
        'lib/features/maestri/aura/meditation/meditation_screen.dart',
    'Sinastria VIP': 'lib/features/synastry/sinastria_vip_screen.dart',
    'Ritratto ingrandito': 'lib/features/synastry/ritratto_ingrandito.dart',
    'Gemello astrale': 'lib/features/synastry/rivelazione_del_gemello.dart',
    'Carta natale': 'lib/features/passport/cosmic_passport_screen.dart',
    'Chat coi Maestri': 'lib/features/maestri/chat/widgets/chat_bubble.dart',
    'Calendario del cielo':
        'lib/features/calendario/calendario_degli_eventi_screen.dart',
    'Consiglio dei Maestri': 'lib/features/maestri/ask/ask_maestri_screen.dart',
  };

  test('la misura di riferimento e\' quella del responso dei Tarocchi', () {
    final riferimento = TypographyTokens.lettura();
    final stesa = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();
    expect(stesa.contains('TypographyTokens.lettura()'), isTrue,
        reason: 'il responso dei Tarocchi non usa piu\' la misura che tutta '
            'l\'app prende come base');
    // ignore: avoid_print
    print('ORDINE CC VOCE 05: la misura di riferimento e\' '
        '${riferimento.fontSize} punti, interlinea ${riferimento.height}');
    expect(riferimento.fontSize, 18);
  });

  test('ogni arte mostra il proprio responso a quella misura', () {
    final senza = <String>[];
    var quante = 0;
    for (final arte in arti.entries) {
      final f = File(arte.value);
      expect(f.existsSync(), isTrue,
          reason: '${arte.key}: la schermata ${arte.value} non esiste piu\'');
      quante++;
      if (!f.readAsStringSync().contains('TypographyTokens.lettura()')) {
        senza.add(arte.key);
      }
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 05: arti censite $quante, senza la misura del '
        'responso ${senza.length}');
    expect(senza, isEmpty,
        reason: 'queste arti mostrano il proprio responso a una misura piu\' '
            'piccola di quella dei Tarocchi: $senza');
  });

  test('il testo che si legge per intero passa sempre dalla stessa porta', () {
    // `ParagrafiDiLettura` e' il componente dei testi che si leggono per
    // intero, e prende lo stile da chi lo monta: e' li' che due funzionalita'
    // possono divergere senza che nessuno se ne accorga.
    final fuori = <String>[];
    var quanti = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final p = f.path.replaceAll(r'\', '/');
      if (p.endsWith('paragrafi_di_lettura.dart')) continue;
      final righe = f.readAsStringSync().split('\n');
      for (var i = 0; i < righe.length; i++) {
        if (!righe[i].contains('ParagrafiDiLettura(')) continue;
        quanti++;
        // La finestra e' larga: un `testo:` con dentro un ternario di tre
        // rami spinge lo `stile:` piu' in basso di quattordici righe, e
        // una finestra corta lo dichiarava senza stile.
        final finestra = righe.sublist(i, (i + 24).clamp(0, righe.length));
        final stile = RegExp(r'stile:\s*TypographyTokens\.(\w+)\(')
            .firstMatch(finestra.join('\n'));
        if (stile == null || stile.group(1) != 'lettura') {
          fuori.add('$p riga ${i + 1}: ${stile?.group(1) ?? "senza stile"}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 05: testi da leggere per intero $quanti, fuori '
        'misura ${fuori.length}');
    expect(fuori, isEmpty,
        reason: 'questi testi da leggere per intero non hanno la misura del '
            'responso: $fuori');
  });

  test('i titoli gialli hanno anche loro una misura sola', () {
    // Il fondatore: "la grandezza dei titoli gialli vanno bene in generale, ma
    // controllali". I titoli non si toccano, si CONTANO: se domani qualcuno ne
    // scrive uno con una misura a mano, questa riga lo dice.
    final aMano = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final p = f.path.replaceAll(r'\', '/');
      if (p.contains('typography')) continue;
      for (final m in RegExp(r'TypographyTokens\.display\(size:\s*(\d+)')
          .allMatches(f.readAsStringSync())) {
        aMano.add('$p: display(size: ${m.group(1)})');
      }
    }
    // ignore: avoid_print
    print('ORDINE CC VOCE 05: titoli con la misura scritta a mano '
        '${aMano.length}');
    // **NON E' UN ROSSO, E' UN CONTO CHE NON DEVE CRESCERE.** I titoli con la
    // misura a mano esistono da prima di quest'ordine e il fondatore li ha
    // dichiarati buoni: la riga serve perche' non se ne aggiungano altri.
    // **CENTODICIANNOVE, contati.** Il fondatore li ha guardati e ha detto
    // che "vanno bene in generale": non si toccano in questa voce, e il conto
    // resta qui perche' non cresca. Ogni titolo che nasce con la misura
    // scritta a mano e' un ruolo che sfugge alla scala, e questa riga lo dice
    // il giorno stesso.
    expect(aMano.length, lessThanOrEqualTo(119),
        reason: 'i titoli con la misura scritta a mano sono ${aMano.length}: '
            'erano centodiciannove, e ogni nuovo sfugge alla scala');
  });
}
