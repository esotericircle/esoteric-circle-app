import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LE MINIATURE NON TAGLIANO MAI L'IMMAGINE.
///
/// **La segnalazione, ripetuta.** Nel Passport il lupo era tagliato dal cerchio
/// che lo conteneva, con zampe e coda fuori, e l'angelo era ritagliato in un
/// riquadro che non rispettava la proporzione della carta.
///
/// **Il componente giusto esisteva gia'**, con `BoxFit.contain` e la proporzione
/// da carta, ed era una classe PRIVATA di un file solo: gli altri punti che
/// mostrano le stesse immagini usavano `cover` e le tagliavano. Un componente
/// che risolve il difetto in un file solo non e' un componente, e' una
/// correzione locale.
///
/// **Questa prova non guarda il Passport: enumera la CLASSE.** Legge i sorgenti
/// e cade se un punto che mostra angeli, animali o carte adatta al riempimento.
/// E' lo stesso metodo che ha fatto trovare la quarta schermata col cuore sopra
/// la "i".
void main() {
  /// I file che mostrano miniature di angelo, animale o carta.
  List<String> puntiConMiniature() {
    final trovati = <String>[];
    for (final f in Directory('lib/features').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final t = f.readAsStringSync();
      final mostra = t.contains('AssetFamily.angeli') ||
          t.contains('AssetFamily.animali') ||
          t.contains('thumbPath') ||
          t.contains('AssetFamily.tarocchi');
      if (mostra) trovati.add(f.path.replaceAll(Platform.pathSeparator, '/'));
    }
    return trovati;
  }

  test('Nessun punto che mostra queste immagini le adatta al riempimento', () {
    // La carta condivisa e la cartolina fanno eccezione dichiarata: sono
    // immagini di sfondo composte apposta per riempire, non miniature di un
    // soggetto che si possa mutilare.
    const eccezioni = {
      'sinastria_share_card.dart',
      'archetype_share_card.dart',
      'face_share_card.dart',
      'guide_animal_share_card.dart',
      'sky_postcard.dart',
      'ritual_gift_card.dart',
      // Lo sfondo del tramonto NON e' una miniatura di un soggetto: e'
      // un'immagine ambientale composta apposta per riempire, e contenerla
      // lascerebbe due bande vuote ai lati.
      'sunset_rune_screen.dart',
    };
    final colpevoli = <String>[];
    for (final p in puntiConMiniature()) {
      if (eccezioni.any(p.endsWith)) continue;
      final righe = File(p).readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        if (righe[i].trimLeft().startsWith('//')) continue;
        if (righe[i].contains('BoxFit.cover')) {
          colpevoli.add('$p riga ${i + 1}');
        }
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'questi punti mostrano angeli, animali o carte adattandole al '
            'riempimento, quindi le tagliano: $colpevoli');
  });

  test('Il componente condiviso esiste e dichiara la proporzione da carta', () {
    final c =
        File('lib/design_system/components/miniatura_intera.dart');
    expect(c.existsSync(), isTrue,
        reason: 'il componente condiviso delle miniature non esiste, quindi '
            'ogni schermata risolve il taglio per conto suo');
    final t = c.readAsStringSync();
    expect(t, contains('BoxFit.contain'),
        reason: 'il componente adatta al riempimento, cioe fa il difetto');
    expect(t, contains('proporzioneCarta'),
        reason: 'il componente non dichiara la proporzione da carta, e gli '
            'angeli sono carte: in un quadrato si mutilano per costruzione');
  });

  test('I punti che mostrano queste immagini sono enumerati', () {
    // Il numero e' un promemoria che si muove: se ne nasce uno nuovo, chi lo
    // scrive vede questa prova cadere e legge il motivo, invece di scoprire il
    // taglio da uno screenshot.
    // DIECI DALL'ORDINE BO voce 05: il cielo dei volti mostra i cinquanta
    // ritratti VIP sospesi su tre profondita', e passa dalla stessa miniatura
    // che la griglia usava, con la stessa proporzione da carta.
    // DODICI DALL'ORDINE BO voci 10 e 13: la rivelazione del gemello mostra i
    // volti che sfilano, e la collezione mostra i due volti di ogni coppia
    // scoperta. Tutti e due passano dalla miniatura, come gli altri.
    final punti = puntiConMiniature();
    // **UNDICI E NON DODICI, e il numero segue il dato.** Il dodicesimo era
    // `cielo_dei_volti.dart`, la sezione "VIP in evidenza": il fondatore l'ha
    // fatta togliere il 28 agosto 2026 ("elimina la sezione Vip in evidenza
    // che non serve a nulla"), e con lei se n'e' andato un punto che mostrava
    // miniature. Cio' che questa riga sorveglia non e' il numero in se': e'
    // che nessun punto nuovo nasca senza passare da qui.
    // **TREDICI DALL\'ORDINE CF VOCE 14**, e i due nuovi sono la schermata
    // del Gemello e il suo podio. Passano tutti e due dal componente
    // condiviso, `VipFramedPortrait`, che e' proprio cio' che questa riga
    // sorveglia: il numero segue il dato, e cio' che conta e' che nessun
    // punto nuovo nasca fuori dalla porta comune.
    expect(punti.length, 13,
        reason: 'i punti che mostrano angeli, animali o carte sono '
            '${punti.length} ($punti): verifica che il nuovo passi dal '
            'componente condiviso');
  });
}
