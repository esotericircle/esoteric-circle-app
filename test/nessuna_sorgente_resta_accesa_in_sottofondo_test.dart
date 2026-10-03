import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/core/sensi/motore_audio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// NESSUNA SORGENTE RESTA ACCESA IN SOTTOFONDO. Ordine CT, voce 07.
///
/// **Il fatto.** Parole del fondatore del 4 settembre 2026: *"quando l'app va
/// in background, la musica non si ferma"*.
///
/// **Perche' la rete non l'aveva visto.** `il_suono_si_ferma_test.dart`
/// sorveglia il ciclo di vita con un motore FINTO: prova che la Guardia del
/// Suono chiama `fermaTutto`, e quella parte funzionava. Nessuna prova
/// guardava **dentro** `fermaTutto`, dove stava il difetto: tre sorgenti
/// fermate in catena, una `await` dopo l'altra, con la musica seconda. Di
/// `audioplayers` questo progetto sa gia' che una chiamata puo' non tornare
/// mai senza sollevare niente, e un'attesa che non torna sulla prima sorgente
/// impedisce di arrivare alla seconda.
///
/// **Cio' che si misura qui e' l'ordine, non l'esito.** Una prova che
/// controllasse solo che le sorgenti vengono fermate sarebbe verde anche in
/// catena, perche' con sorgenti che rispondono la catena arriva in fondo. Il
/// difetto compare solo quando una non risponde, ed e' esattamente il caso che
/// queste prove costruiscono.
void main() {
  test('Una sorgente che non risponde non trattiene le altre', () async {
    final chiamate = <String>[];
    // La prima non torna mai, come il lettore dei toni sul telefono del
    // fondatore: non solleva, non finisce, resta li'.
    final muta = Completer<void>();
    addTearDown(() {
      if (!muta.isCompleted) muta.complete();
    });

    final finito = MotoreAudio.fermaOgnuna(
      [
        () {
          chiamate.add('toni');
          return muta.future;
        },
        () {
          chiamate.add('musica');
          return Future<void>.value();
        },
        () {
          chiamate.add('effetti');
          return Future<void>.value();
        },
      ],
      entro: const Duration(milliseconds: 50),
    );

    expect(chiamate, ['toni', 'musica', 'effetti'],
        reason: 'la sorgente che non risponde ha fermato la fila: le altre '
            'non sono mai state chiamate, e questo e\' esattamente il modo in '
            'cui la musica restava accesa. Chiamate arrivate: $chiamate');

    // E il metodo torna comunque: lo chiama il ciclo di vita, e un ciclo di
    // vita che si appende e' peggio di un suono che resta acceso.
    await expectLater(finito.timeout(const Duration(seconds: 3)), completes,
        reason: 'fermaOgnuna non torna quando una sorgente non risponde, '
            'quindi il ciclo di vita resta appeso');
  });

  test('Una sorgente che solleva non impedisce le altre', () async {
    final chiamate = <String>[];
    await MotoreAudio.fermaOgnuna([
      () {
        chiamate.add('toni');
        throw StateError('nessun lettore');
      },
      () {
        chiamate.add('musica');
        return Future<void>.error(StateError('gia\' ferma'));
      },
      () {
        chiamate.add('effetti');
        return Future<void>.value();
      },
    ]);
    expect(chiamate, ['toni', 'musica', 'effetti'],
        reason: 'una sorgente che solleva ferma la fila: chiamate $chiamate');
  });

  test('Le sorgenti assenti non fanno saltare niente', () async {
    var chiamate = 0;
    await MotoreAudio.fermaOgnuna([
      () {
        chiamate++;
        return null;
      },
      () {
        chiamate++;
        return null;
      },
    ]);
    expect(chiamate, 2,
        reason: 'con tutte le sorgenti assenti la fila non arriva in fondo');
  });

  test('Ogni sorgente di suono di lib e\' governata dal ciclo di vita', () {
    // **L'ENUMERAZIONE, non la fiducia.** Ordine CT voce 07, che chiede per
    // nome di verificare che valga per tutte le musiche montate e per il
    // lettore dei toni, non per la sola musica della home.
    //
    // Chi puo' emettere suono in questa app costruisce un `AudioPlayer` o un
    // `VideoPlayerController`. Ognuno di quei file deve o passare dal motore
    // condiviso, che la Guardia del Suono spegne, oppure osservare il ciclo di
    // vita per conto suo, come fanno l'intro e il velo della rivelazione.
    //
    // Una sorgente nuova che non faccia ne' l'una ne' l'altra suonerebbe con
    // l'app in sottofondo **e nessuno se ne accorgerebbe**, che e' esattamente
    // com'e' andata questa volta.
    final sorgenti = <String>[];
    final scoperte = <String>[];
    for (final f in sorgentiDiLib()) {
      final testo = f.readAsStringSync();
      final costruisce = testo.contains('AudioPlayer(') ||
          testo.contains('VideoPlayerController.');
      if (!costruisce) continue;
      final percorso = f.path.replaceAll(Platform.pathSeparator, '/');
      sorgenti.add(percorso);
      final governata = percorso.endsWith('core/sensi/motore_audio.dart') ||
          testo.contains('didChangeAppLifecycleState') ||
          testo.contains('AppLifecycleListener');
      if (!governata) scoperte.add(percorso);
    }

    cardinaleMinimo(sorgenti.length, 2,
        cosa: 'file di lib che costruiscono una sorgente di suono',
        perche: 'Se nessun file costruisce piu\' un lettore, questa prova non '
            'trova sorgenti scoperte perche\' non ha guardato niente.');
    expect(scoperte, isEmpty,
        reason: 'QUESTE SORGENTI DI SUONO NON SANNO QUANDO L\'APP SE NE VA, e '
            'sono ${scoperte.length} su ${sorgenti.length}:\n'
            '${scoperte.join("\n")}\n'
            'Una sorgente che non passa dal motore condiviso e non osserva il '
            'ciclo di vita continua a suonare con l\'app in sottofondo.');
  });

  test('Fermare tutto non CREA nessun lettore', () async {
    final motore = MotoreAudio.condiviso;
    final prima = motore.lettoriVivi;
    await motore.fermaTutto();
    expect(motore.lettoriVivi, prima,
        reason: 'fermare ha costruito i lettori ${motore.lettoriVivi.difference(prima)}: '
            'un lettore nato per essere zittito tocca la piattaforma senza '
            'motivo, ed e\' quello che teneva ferma la catena');
  });

  test('Fermare tutto torna sempre, anche a motore mai acceso', () async {
    await expectLater(
        MotoreAudio.condiviso.fermaTutto().timeout(const Duration(seconds: 3)),
        completes,
        reason: 'fermaTutto non torna: il ciclo di vita che la chiama resta '
            'appeso');
  });
}
