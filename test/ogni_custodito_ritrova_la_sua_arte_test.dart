import 'dart:io';

import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/ricordi/arti_con_responso.dart';
import 'package:esoteric_circle/core/ricordi/artwork_del_ricordo.dart';
import 'package:esoteric_circle/core/ricordi/ricordo_custodito.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI CUSTODITO RITROVA LA SUA ARTE. Ordine CG voce 07, seconda stesura.
///
/// **Il difetto che questa prova impedisce.** Un custodito conserva i dati per
/// ridisegnare il responso, non l'immagine. Se la schermata che salva scrive
/// una chiave e la porta che ridisegna ne legge un'altra, l'artwork sparisce
/// **in silenzio**: non c'e' nessun errore, nessun riquadro rotto, solo un
/// riquadro di testo dove doveva esserci una carta. Nessuno se ne accorge fino
/// a quando qualcuno non apre i propri custoditi, cioe' mai durante lo
/// sviluppo.
///
/// **E' la famiglia di difetti del riallineamento**: qualcosa si vede a video
/// e la prova non lo dice. Qui la prova lo dice, in tre modi diversi.
void main() {
  /// UN DATO PLAUSIBILE PER OGNI ARTE, preso dai cataloghi VERI.
  ///
  /// Non sono valori inventati: se un catalogo cambiasse i suoi nomi, questa
  /// tabella cambierebbe con lui e la prova continuerebbe a dire il vero. Un
  /// valore scritto a mano qui dentro invecchierebbe in silenzio, che e'
  /// esattamente il difetto che questa prova esiste per prendere.
  final datiVeri = <String, Map<String, String>>{
    'stesa': {
      'carte': TarotDeck.cards.take(3).map((c) => c.name).join(','),
    },
    'oracolo': {'carta': TarotDeck.cards.first.name},
    'gettata': {
      'gettata': 'tre rune',
      'rune': kElderFuthark
          .where((r) => r.hasImage)
          .take(3)
          .map((r) => r.name)
          .join(','),
    },
    'tramonto': {
      'runa': kElderFuthark.firstWhere((r) => r.hasImage).name,
      'verso': 'ombra',
    },
    'animale_guida': {'animale': AnimalCatalog.animals.first.name},
    'sinastria': {
      'vip': VipCatalog.vips.firstWhere((v) => v.thumbPath != null).name,
      'punteggio': '72',
    },
    'archetipo': {'archetipo': Archetype.values.first.name},
    'oroscopo': {'segno': Zodiac.leo.italianName},
  };

  test('le tredici arti sono divise fra chi ha un\'arte e chi no, senza resti',
      () {
    final conArte = ArtworkDelRicordo.chiaviLette.keys.toSet();
    final senza = ArtworkDelRicordo.senzaArtwork.keys.toSet();

    // **NESSUNA ARTE STA DA TUTTE E DUE LE PARTI.** Sarebbe il modo piu'
    // silenzioso di dire due cose diverse sulla stessa arte.
    final doppie = conArte.intersection(senza);
    expect(doppie, isEmpty,
        reason: 'queste arti dichiarano insieme di avere e di non avere '
            'un\'arte: $doppie');

    // **E NESSUNA ARTE VIVA RESTA FUORI DAL CENSIMENTO.**
    final tutte = ArtiConResponso.tutte.map((a) => a.arte).toSet();
    final dimenticate = tutte.difference(conArte).difference(senza);
    expect(dimenticate, isEmpty,
        reason: 'queste arti producono un responso e nessuno ha detto se '
            'quel responso ha un\'arte da rivedere o no: $dimenticate. Una '
            'riga in ArtworkDelRicordo, col motivo scritto.');

    // E NIENTE DI PIU', cioe' nessuna riga rimasta per un\'arte che non c\'e'.
    final fantasmi = conArte.union(senza).difference(tutte);
    expect(fantasmi, isEmpty,
        reason: 'queste righe parlano di arti che non producono piu\' un '
            'responso: $fantasmi');

    // IL NUMERO, dichiarato: tredici arti, otto con l'arte e cinque senza.
    // ignore: avoid_print
    print('ARTI CON UN RESPONSO: ${tutte.length}, '
        'con artwork ${conArte.length}, senza ${senza.length}');
    expect(conArte.length + senza.length, tutte.length);
  });

  test('ogni motivo del no e\' scritto per esteso, non e\' una riga vuota', () {
    final corti = <String>[];
    for (final voce in ArtworkDelRicordo.senzaArtwork.entries) {
      if (voce.value.trim().length < 60) corti.add(voce.key);
    }
    expect(corti, isEmpty,
        reason: 'queste arti dichiarano di non avere un\'arte senza dire '
            'perche\', e un no senza motivo e\' una dimenticanza travestita: '
            '$corti');
  });

  test('ogni arte dichiarata ritrova davvero le sue immagini', () {
    final muti = <String>[];
    for (final arte in ArtworkDelRicordo.chiaviLette.keys) {
      final dati = datiVeri[arte];
      if (dati == null) {
        muti.add('$arte: questa prova non sa che dato passargli');
        continue;
      }
      final immagini = ArtworkDelRicordo.perArte(arte, dati);
      if (immagini.isEmpty) muti.add('$arte con $dati non trova niente');
    }
    expect(muti, isEmpty,
        reason: 'queste arti dichiarano di avere un\'arte e poi non la '
            'ritrovano dai loro stessi dati:\n${muti.join("\n")}');
  });

  test('ogni file dell\'arte esiste davvero nel bundle', () {
    // **NON BASTA CHE IL PERCORSO SI COMPONGA.** Un percorso e' una stringa, e
    // una stringa si compone sempre: nel riquadro si vedrebbe l'icona di
    // ripiego, che a schermo somiglia a un artwork mancante e in una prova non
    // somiglia a niente. Qui si apre il file.
    final mancanti = <String>[];
    var guardati = 0;
    for (final voce in datiVeri.entries) {
      for (final immagine in ArtworkDelRicordo.perArte(voce.key, voce.value)) {
        for (final percorso in [immagine.miniatura, immagine.piena]) {
          guardati++;
          if (!File(percorso).existsSync()) {
            mancanti.add('${voce.key}: $percorso');
          }
        }
      }
    }
    // Senza questa riga, una tabella vuota farebbe passare la prova avendo
    // guardato zero file.
    expect(guardati, greaterThan(20),
        reason: 'questa prova ha guardato solo $guardati file, troppo pochi '
            'per dire qualcosa');
    expect(mancanti, isEmpty,
        reason: 'questi file dell\'arte non ci sono nel bundle, e a schermo '
            'al loro posto comparirebbe l\'icona di ripiego:\n'
            '${mancanti.join("\n")}');
    // ignore: avoid_print
    print('FILE DELL\'ARTE VERIFICATI: $guardati');
  });

  test('le chiavi che la porta legge sono quelle che le schermate scrivono',
      () {
    // **IL PUNTO DOVE I DUE LATI SI TOCCANO.** La schermata del responso
    // scrive `dati: {...}` quando si custodisce, e questa porta le rilegge.
    // Sono due file diversi, scritti in momenti diversi: e' esattamente il
    // posto dove una chiave cambia da una parte sola.
    final scollate = <String>[];
    var controllate = 0;
    for (final voce in ArtworkDelRicordo.chiaviLette.entries) {
      final arte = ArtiConResponso.di(voce.key);
      if (arte == null) {
        scollate.add('${voce.key} non e\' fra le arti con responso');
        continue;
      }
      final file = File(arte.doveViveIlResponso);
      if (!file.existsSync()) {
        scollate.add('${voce.key}: ${arte.doveViveIlResponso} non esiste');
        continue;
      }
      final sorgente = file.readAsStringSync();
      for (final chiave in voce.value) {
        controllate++;
        if (!sorgente.contains("'$chiave':")) {
          scollate.add('${voce.key}: la porta legge "$chiave" ma '
              '${arte.doveViveIlResponso} non la scrive');
        }
      }
    }
    expect(controllate, greaterThan(8),
        reason: 'questa prova ha controllato solo $controllate chiavi');
    expect(scollate, isEmpty,
        reason: 'queste chiavi non combaciano, e l\'artwork sparirebbe senza '
            'nessun errore:\n${scollate.join("\n")}');
  });

  test('un custodito vero ritrova la sua arte passando dal suo modello', () {
    // La prova qui sopra passa dai dati nudi. Questa passa dal custodito
    // intero, cioe' dalla forma che vive davvero sul telefono, andata e
    // ritorno dalla mappa con cui si salva.
    final originale = RicordoCustodito(
      quando: DateTime(2026, 8, 31, 21, 30),
      arte: 'tramonto',
      maestro: 'caligo',
      titolo: 'La tua runa del tramonto',
      testo: 'Il presagio della sera.',
      dati: datiVeri['tramonto']!,
      comeENato: ComeENato.gesto,
    );
    final ripescato = RicordoCustodito.daMappa(originale.aMappa());
    expect(ripescato, isNotNull,
        reason: 'un custodito non si rilegge dalla sua stessa mappa');
    final immagini = ArtworkDelRicordo.di(ripescato!);
    expect(immagini, hasLength(1),
        reason: 'la runa custodita non ritrova la sua pietra dopo il giro '
            'dalla mappa: i dati non sopravvivono al salvataggio');
    expect(immagini.first.rovesciata, isTrue,
        reason: 'la runa era uscita in ombra e si rimostra dritta, cioe\' con '
            'un altro presagio');
  });
}
