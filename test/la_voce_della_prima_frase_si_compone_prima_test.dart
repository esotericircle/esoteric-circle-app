import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/features/maestri/live/la_voce_anticipata.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA VOCE DELLA PRIMA FRASE SI COMPONE PRIMA.** Ordine EQ voce 03, dopo la
/// risposta del fondatore del 27 settembre 2026: *"L'attesa deve diminuire,
/// non aumentare."*
///
/// Sul Realme la voce della prima frase si chiedeva solo a risposta intera:
/// dalla risposta al primo audio al volto passavano circa 0,7 secondi, ogni
/// turno (`docs/collaudo/EQ/realme/eq03_live_*/logcat.txt`). Adesso si
/// comincia a comporre appena la prima frase e' chiusa nel testo che arriva,
/// e il flusso verso il volto si apre appena c'e' il suo primo pezzo. **Ma al
/// volto non arriva niente prima delle reti**: e' la decisione del fondatore
/// dell'ordine EM, e l'ultima prova la guarda nel sorgente.
void main() {
  group('La prima frase chiusa', () {
    test('si conosce solo quando la seconda e\' cominciata', () {
      expect(LaVoceAnticipata.primaFraseChiusa('Scrivi stasera'), isNull);
      expect(
          LaVoceAnticipata.primaFraseChiusa('Scrivi stasera a Marta.'), isNull,
          reason: 'il punto puo\' essere un numero o un\'abbreviazione: la '
              'frase e\' chiusa quando ne comincia un\'altra');
      expect(
          LaVoceAnticipata.primaFraseChiusa(
              'Scrivi stasera a Marta. Poi aspetta'),
          'Scrivi stasera a Marta.');
    });

    test('e\' la stessa che la voce dira\' per prima', () {
      expect(
          LaVoceAnticipata.primaFraseChiusa(
              'Calìgo ti dice: **scegli**. Il resto viene.\n✦ Scrivi.'),
          'Calìgo ti dice: scegli.');
    });
  });

  group('La voce anticipata', () {
    test('riascolta i pezzi gia\' arrivati e poi quelli che arrivano',
        () async {
      final sorgente = StreamController<int>();
      final voce = LaVoceAnticipata<int>('Una frase.', sorgente.stream);
      sorgente
        ..add(1)
        ..add(2);
      await Future<void>.delayed(Duration.zero);
      final sentiti = <int>[];
      final fine = voce.riascolta().forEach(sentiti.add);
      sorgente.add(3);
      await sorgente.close();
      await fine;
      expect(sentiti, [1, 2, 3]);
      expect(await voce.primoPezzo, 1);
    });

    test('se non nasce, si sa e si chiede di nuovo', () async {
      final sorgente = StreamController<int>();
      final voce = LaVoceAnticipata<int>('Una frase.', sorgente.stream);
      sorgente.addError(StateError('la voce non risponde'));
      await Future<void>.delayed(Duration.zero);
      expect(voce.fallitaSenzaVoce, isTrue);
      expect(await voce.primoPezzo, isNull);
    });

    test('lasciata, non tiene nessuno in attesa', () async {
      final sorgente = StreamController<int>();
      final voce = LaVoceAnticipata<int>('Una frase.', sorgente.stream);
      final fine = voce.riascolta().toList();
      voce.lascia();
      expect(await fine.timeout(const Duration(seconds: 1)), isEmpty);
      expect(await voce.primoPezzo, isNull);
    });
  });

  test('nella schermata la voce al volto parte solo dalla risposta intera', () {
    final sorgente = File('lib/features/maestri/live/schermata_live.dart')
        .readAsStringSync();
    final turno = sorgente.substring(
        sorgente.indexOf('Future<void> _turno(String testo)'),
        sorgente.indexOf('/// **LA VOCE DEL MAESTRO, VERSO IL VOLTO.**'));
    final mentre = turno.substring(turno.indexOf('void mentreArriva()'),
        turno.indexOf('chat.testoInArrivo.value ='));
    expect(mentre, contains('LaVoceAnticipata('),
        reason: 'la voce della prima frase non si compone mentre il testo '
            'arriva');
    for (final vietato in ['_dillo(', '.write(', '_scriviAPezzi(']) {
      expect(mentre, isNot(contains(vietato)),
          reason: 'mentre il testo arriva qualcosa va al volto prima delle '
              'reti: $vietato');
    }
    expect(turno.indexOf('await chat.send(testo)'),
        lessThan(turno.indexOf('_dillo(risposta.text, conAttesa: true)')),
        reason: 'la voce parte prima che la risposta abbia passato le reti');
    // **LAPIDE, ordine FE voce 07 (commit ba5812cf):** `_dillo` dice adesso
    // se la voce e' uscita, e la firma cercata qui era `Future<void>`.
    final dillo = sorgente.substring(sorgente.indexOf('Future<bool> _dillo('),
        sorgente.indexOf('/// La voce composta in anticipo'));
    expect(dillo, contains('anticipata.testo == pezzo'),
        reason: 'la voce anticipata si usa senza guardare che sia la frase '
            'della risposta passata dalle reti');
  });
}
