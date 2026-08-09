import 'dart:math';

import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/core/rituals/sunset_rune_corpus.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE RUNE SIMMETRICHE NON PROMETTONO UN ROVESCIO CHE NON HANNO.
///
/// Ordine 2171, voce 4. **Segnalazione della fondatrice Dora su Gebo**,
/// verificata sulle fonti. Otto rune dell'Elder Futhark sono identiche se le
/// giri: il loro segno non ha un sopra e un sotto.
///
/// **Il difetto non era il contenuto, era la promessa.** L'app invitava a
/// girare la pietra dicendo "mostra il suo rovescio", e due righe sotto
/// dichiarava "segno simmetrico, non ha rovescio". Chi legge si fida della
/// prima riga e resta con l'impressione che qualcosa non abbia funzionato.
///
/// Il gesto resta, perche' girare la pietra e' parte del rito e il retro
/// inciso esiste comunque: cambia cio' che si promette, si spiega perche' e si
/// dice come si legge invece.
void main() {
  /// Le otto adottate dal Cerchio. **Alcune scuole aggiungono Nauthiz**, che
  /// nella forma piu' diffusa e' un tratto verticale con una barra obliqua e
  /// girandola cambia il lato della barra: il Cerchio la considera
  /// asimmetrica, e questa scelta e' scritta qui perche' non si perda.
  const otto = {
    'Gebo',
    'Hagalaz',
    'Isa',
    'Jera',
    'Eihwaz',
    'Sowilo',
    'Ingwaz',
    'Dagaz',
  };

  test('l\'insieme delle simmetriche vive in UN punto solo, e sono otto', () {
    expect(kRuneSimmetriche, otto,
        reason: 'l\'insieme delle rune simmetriche non e\' piu\' quello '
            'adottato dal Cerchio: se qualcuno ha aggiunto Nauthiz o tolto '
            'una delle otto, va scritto perche\', non fatto di passaggio');
    expect(kRuneSimmetriche.contains('Nauthiz'), isFalse,
        reason: 'Nauthiz e\' entrata fra le simmetriche: e\' una scelta che '
            'alcune scuole fanno e il Cerchio no, e cambiarla cambia quante '
            'rune possono uscire in merkstave');
    // E sono nomi veri: un refuso qui toglierebbe in silenzio una runa
    // dall'insieme, senza che niente cada.
    final nomi = kElderFuthark.map((r) => r.name).toSet();
    for (final s in kRuneSimmetriche) {
      expect(nomi.contains(s), isTrue,
          reason: '$s non e\' il nome di nessuna runa del Futhark: un refuso '
              'la toglie dall\'insieme senza far cadere niente');
    }
  });

  test('per le OTTO l\'invito non promette il rovescio', () {
    // Le due forme dell'invito, quella col giroscopio e quella senza.
    for (final invito in [
      SunsetRuneCorpus.invitoSimmetrica,
      SunsetRuneCorpus.invitoSimmetricaConInclinazione,
    ]) {
      expect(invito.toLowerCase().contains('rovescio'), isFalse,
          reason: 'l\'invito per una runa simmetrica promette ancora il '
              'rovescio: "$invito". E\' la promessa che la scheda smentisce '
              'due righe sotto.');
      // Ma il GESTO resta: il retro della pietra si vede lo stesso.
      expect(invito.toLowerCase().contains('retro'), isTrue,
          reason: 'l\'invito non nomina piu\' il retro: il gesto deve restare, '
              'perche\' girare la pietra e\' parte del rito');
      expect(invito.toLowerCase().contains('tocca due volte'), isTrue,
          reason: 'l\'invito non dice piu\' come si gira la pietra');
    }
  });

  test('per le altre SEDICI il rovescio si promette ancora', () {
    // Il presidio contro la correzione troppo larga: togliere la promessa a
    // tutte sarebbe stato piu' comodo e avrebbe tolto il verso d'ombra a
    // sedici rune che ce l'hanno.
    final asimmetriche =
        kElderFuthark.where((r) => !kRuneSimmetriche.contains(r.name)).toList();
    expect(asimmetriche, hasLength(16),
        reason: 'le rune con un verso d\'ombra sono ${asimmetriche.length} '
            'invece di sedici');
    for (final r in asimmetriche) {
      expect(r.shadow.trim(), isNotEmpty,
          reason: '${r.name} non ha piu\' una riga d\'ombra, ma non e\' fra le '
              'simmetriche: o e\' simmetrica e va dichiarata, o la riga manca');
    }
  });

  test('la scheda spiega PERCHE\' non si rovescia, e come si legge invece',
      () {
    for (final nome in kRuneSimmetriche) {
      final riga = SunsetRuneCorpus.perche(nome);
      expect(riga.contains(nome), isTrue,
          reason: 'la spiegazione non nomina $nome');
      expect(riga.toLowerCase().contains('contesto'), isTrue,
          reason: 'per $nome non si dice COME si legge invece: dire "non ha '
              'rovescio" e basta lascia la persona con un\'informazione che '
              'sembra mancare');
      expect(riga.toLowerCase().contains('posizione'), isTrue,
          reason: 'per $nome non si nomina la posizione nella stesa, che e\' '
              'l\'altra cosa da cui si legge');
    }
  });

  test('il disclaimer dichiara che il rovescio e\' pratica moderna', () {
    final t = SunsetRuneCorpus.rovescioEPraticaModerna.toLowerCase();
    expect(t.contains('moderna'), isTrue,
        reason: 'non si dichiara piu\' che il verso d\'ombra e\' pratica '
            'moderna: farlo passare per antico e\' esattamente cio\' che il '
            'disclaimer esiste per impedire');
    expect(t.contains('font'), isTrue,
        reason: 'non si nominano le fonti storiche, che sono il metro di '
            'cio\' che e\' attestato e cio\' che non lo e\'');
  });

  test('le simmetriche non escono MAI in merkstave', () {
    // La regola a monte, che regge tutto il resto: se una simmetrica potesse
    // uscire capovolta, l'invito onesto sarebbe una bugia al contrario.
    for (var seme = 0; seme < 40; seme++) {
      final esito = RuneCast.getta(gettataNorne, random: Random(seme));
      for (final r in esito.rune) {
        if (kRuneSimmetriche.contains(r.rune.name)) {
          expect(r.inOmbra, isFalse,
              reason: '${r.rune.name} e\' uscita in merkstave col seme $seme, '
                  'ma e\' simmetrica: girandola resta identica');
        }
      }
    }
  });
}
