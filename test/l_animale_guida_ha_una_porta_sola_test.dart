/// **L'ANIMALE GUIDA HA UNA PORTA SOLA.** Ordine DG voce 01,
/// 11 settembre 2026.
///
/// **IL DIFETTO CHE LA FA NASCERE, con le parole del fondatore.** *"alla fine
/// mi viene assegnato un animale diverso dal mio in Passport. (il mio e'
/// sempre stato il lupo, ogni volta che ho inserito i miei dati corretti
/// personali)"*.
///
/// Nell'app esistevano **due** animali guida per la stessa persona:
///
/// - `GuideAnimalDerivation.forSign`, dal segno solare, deterministico, letto
///   dal Passaporto e dall'onboarding;
/// - `IQuattroViaggi.seguitoDaLeQuattroScelte`, che contava quale ombra era
///   stata seguita piu' volte nelle quattro discese.
///
/// Il Passaporto li leggeva **tutti e due, a dieci righe di distanza**.
///
/// **Chi sopravvive lo dice il Master Briefing.** Linee Guida UX Trasversali,
/// sezione 5, elenca fra i dati identitari e fissi, deterministici e
/// immutabili, *"carta natale, Angelo Custode, archetipo, **Animale Guida**"*.
/// Le arti a esito variabile stanno in un altro elenco.
///
/// **PROVENIENZA: ordine DC voce 04, 10 settembre 2026**, che aveva fatto
/// nascere l'animale da *"il cielo restringe"* piu' *"le scelte decidono"*.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/rituals/guide_animal_derivation.dart';
import 'package:esoteric_circle/core/viaggio/i_quattro_viaggi.dart';

import 'sorgenti_di_lib.dart';

void main() {
  test('MILLE ESECUZIONI, a parita di nascita, danno sempre lo stesso animale',
      () {
    // Un giorno per ogni segno, e mille giri su ognuno.
    final nascite = <DateTime>[
      DateTime(1980, 1, 15),
      DateTime(1980, 2, 15),
      DateTime(1980, 3, 25),
      DateTime(1980, 4, 20),
      DateTime(1980, 5, 15),
      DateTime(1980, 6, 15),
      DateTime(1980, 7, 10),
      DateTime(1980, 8, 15),
      DateTime(1980, 9, 15),
      DateTime(1980, 10, 15),
      DateTime(1980, 11, 15),
      DateTime(1980, 12, 15),
    ];
    var giri = 0;
    for (final nascita in nascite) {
      final primo =
          GuideAnimalDerivation.forSign(NightSky.sunSign(nascita)).name;
      for (var i = 0; i < 1000; i++) {
        expect(GuideAnimalDerivation.forSign(NightSky.sunSign(nascita)).name,
            primo,
            reason: 'la stessa nascita ha dato due animali diversi');
        giri++;
      }
    }
    // ignore: avoid_print
    print('ORDINE DG VOCE 01: $giri esecuzioni su ${nascite.length} nascite, '
        'sempre lo stesso animale');
    expect(giri, 12000);
  });

  test('IL CASO DEL FONDATORE: chi nasce sotto il Cancro ha il Lupo', () {
    // **IL DATO E' NOMINATO E NON DEDOTTO.** Il fondatore: *"il mio e' sempre
    // stato il lupo"*. Nella tabella di curatela il Lupo sta sul Cancro, e
    // questa prova tiene ferma quella riga: se qualcuno rimescolasse la
    // tabella, il suo animale cambierebbe senza che nessuno se ne accorga.
    final nascita = DateTime(1980, 7, 10);
    expect(NightSky.sunSign(nascita), Zodiac.cancer);
    expect(GuideAnimalDerivation.forSign(Zodiac.cancer).name, 'Lupo');
  });

  test('IL NOME CHE IL VIAGGIO CONSEGNA E QUELLO DELLA NASCITA, e non un '
      'altro', () {
    for (final a in AnimalCatalog.animals) {
      // Prima delle quattro discese non si dice niente.
      for (var d = 0; d < IQuattroViaggi.quanteDiscese; d++) {
        expect(IQuattroViaggi.nomeDopoLeQuattroDiscese(d, a.name), isNull,
            reason: 'alla discesa $d il nome non si deve poter dire');
      }
      // Alla quarta, e da li' in poi, esce **il suo** e nessun altro.
      for (var d = IQuattroViaggi.quanteDiscese; d < 8; d++) {
        expect(IQuattroViaggi.nomeDopoLeQuattroDiscese(d, a.name), a.name);
      }
    }
  });

  test('NESSUN FILE DI lib APRE UNA SECONDA PORTA', () {
    // **LA GRANDEZZA MISURATA E' L'ASSENZA**, ed e' il motivo per cui questa
    // e' una guardia e non una prova: se qualcuno rimettesse una funzione che
    // sceglie l'animale dalle ombre seguite, il resto della suite resterebbe
    // verde.
    const vietate = [
      'seguitoDaLeQuattroScelte',
      'treOmbre',
      'PittoreDellAnimale',
    ];
    final colpevoli = <String>[];
    var guardati = 0;
    for (final f in sorgentiDiLib()) {
      guardati++;
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        // I commenti possono nominarle: e' li' che sta scritto perche' non ci
        // sono piu'.
        final st = r.trimLeft();
        if (st.startsWith('//') || st.startsWith('///')) continue;
        for (final v in vietate) {
          if (r.contains(v)) colpevoli.add('$p riga ${i + 1}: $v');
        }
      }
    }
    // **IL CARDINALE MINIMO.**
    expect(guardati, greaterThan(500),
        reason: 'i file di lib trovati sono troppo pochi');
    // ignore: avoid_print
    print('ORDINE DG VOCE 01: guardati $guardati file di lib, seconde porte '
        'trovate ${colpevoli.length}');
    expect(colpevoli, isEmpty,
        reason: 'queste righe aprono una seconda porta dell animale guida:\n'
            '${colpevoli.join('\n')}');
  });
}
