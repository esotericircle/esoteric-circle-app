import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/il_nome_si_puo_dire.dart';
import 'package:esoteric_circle/core/viaggio/l_animale_di_potere.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **NESSUNA SCHERMATA MOSTRA UN ANIMALE A CHI NON L'HA RICONOSCIUTO, E DUE
/// SCHERMATE NON NE MOSTRANO DUE DIVERSI.** Ordine DG voce 02,
/// 12 settembre 2026. Riscritta per intero dall'ordine FZ voce 02,
/// 17 ottobre 2026, che chiede esplicitamente questa guardia (voce FZ.02,
/// punto 10 dell'elenco di sviluppo).
///
/// **PERCHE' LA VECCHIA FORMA NON BASTA PIU'.** Fino a FZ ogni persona aveva
/// un solo animale possibile (quello del segno): sapere "quante discese"
/// bastava a sapere se dirlo. Con le tre ombre di FZ.01 questo non regge
/// piu': prima di FZ.02 la domanda giusta non era piu' "si puo' dire il
/// nome?" ma "QUESTO e' davvero il nome?", e un punto che derivasse ancora
/// un animale dal segno e gli chiedesse soltanto "si puo' dire" avrebbe
/// risposto sempre no, anche a riconoscimento fatto (il nome indovinato dal
/// segno non e' quasi mai quello vero): esattamente il difetto trovato e
/// riparato in `simbolo_dellattesa.dart`, `bosco_del_cerchio.dart`,
/// `il_ritratto_screen.dart` e `birth_companions.dart` da questo stesso
/// ordine.
///
/// **VISTA ROSSA DAVVERO**: eseguita prima di scrivere `AnimaleDiPotere`,
/// questa stessa idea di guardia (con la vecchia API) cadeva nei punti
/// elencati sopra, perche' quei file chiedevano "si puo' dire IL NOME DEL
/// SEGNO" invece di "chi e' stato davvero riconosciuto".
void main() {
  group('la cache sincrona e l\'archivio non si contraddicono mai', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      IlNomeSiPuoDire.quanteDisceseNote = 0;
      IlNomeSiPuoDire.animaleRiconosciutoNoto = null;
    });

    test(
        'prima del riconoscimento: la porta che aspetta e la porta che non '
        'aspetta dicono tutte e due "non ancora"', () async {
      final diario = DiarioDeiViaggi();
      await diario.carica();
      expect(AnimaleDiPotere.riconosciutoDa(diario), isNull,
          reason: 'la porta che puo\' aspettare vede un animale prima del '
              'riconoscimento');
      expect(AnimaleDiPotere.dalCioCheSiSaGia(), isNull,
          reason: 'la cache sincrona vede un animale prima che il Diario '
              'abbia mai risposto');
    });

    test('dopo il riconoscimento: le due porte concordano sullo stesso nome',
        () async {
      final diario = DiarioDeiViaggi();
      await diario.carica();
      for (var i = 0; i < 4; i++) {
        await diario.segna(UnViaggio(
          quando: DateTime(2026, 10, 17 + i),
          domanda: '',
          temaDellaDomanda: '',
          pezzi: const [],
          animaleSeguito: 'Lupo',
          nitidezza: 1,
        ));
      }
      final dallArchivio = AnimaleDiPotere.riconosciutoDa(diario);
      final dallaCache = AnimaleDiPotere.dalCioCheSiSaGia();
      expect(dallArchivio?.name, 'Lupo');
      expect(dallaCache?.name, 'Lupo');
      expect(dallArchivio?.name, dallaCache?.name,
          reason: 'la porta che aspetta e la cache sincrona, lette nello '
              'stesso istante, dicono due animali diversi');
    });

    test(
        'DUE LETTURE INDIPENDENTI DELLO STESSO ARCHIVIO danno sempre lo '
        'stesso animale, come due schermate diverse', () async {
      // **QUESTO E' IL CASO VERO DI DUE SCHERMATE**: ognuna dei dodici
      // punti dell'app che mostrano l'animale costruisce il suo proprio
      // `DiarioDeiViaggi()` e lo carica per conto suo (vedi
      // `cosmic_passport_screen.dart`, `birth_companions.dart`,
      // `bosco_del_cerchio.dart`, eccetera): se due letture indipendenti
      // dello stesso telefono dessero due risposte diverse, due schermate
      // mostrerebbero due animali diversi alla stessa persona.
      final primo = DiarioDeiViaggi();
      await primo.carica();
      for (var i = 0; i < 4; i++) {
        await primo.segna(UnViaggio(
          quando: DateTime(2026, 10, 17 + i),
          domanda: '',
          temaDellaDomanda: '',
          pezzi: const [],
          animaleSeguito: 'Orso',
          nitidezza: 1,
        ));
      }
      final schermataA = DiarioDeiViaggi();
      await schermataA.carica();
      final schermataB = DiarioDeiViaggi();
      await schermataB.carica();
      final animaleA = AnimaleDiPotere.riconosciutoDa(schermataA);
      final animaleB = AnimaleDiPotere.riconosciutoDa(schermataB);
      expect(animaleA?.name, 'Orso');
      expect(animaleB?.name, 'Orso');
      expect(animaleA?.name, animaleB?.name,
          reason: 'due schermate che leggono lo stesso telefono mostrano '
              'due animali diversi per la stessa persona');
    });
  });

  test(
      'NESSUN FILE DI lib CHIEDE "SI PUO\' DIRE" A UN NOME INDOVINATO DAL '
      'SEGNO', () {
    // **IL DIFETTO CHE QUESTA RIGA PRENDE.** Il vecchio schema era: derivare
    // un animale dal segno, poi chiedere a `IlNomeSiPuoDire` se quel nome si
    // puo' dire. Con la derivazione dal segno abolita, quello schema
    // risponderebbe sempre no: la riga `GuideAnimalDerivation.forSign(...)`
    // seguita a distanza da `IlNomeSiPuoDire` o `dalCioCheSiSaGia` nello
    // stesso file (fuori dalla migrazione) e' il segno che qualcuno ha
    // rimesso lo schema vecchio.
    const dovLaMigrazioneVive = 'lib/core/viaggio/l_animale_di_potere.dart';
    final colpevoli = <String>[];
    for (final f in sorgentiDiLib()) {
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (p == dovLaMigrazioneVive) continue;
      final righe = f.readAsLinesSync();
      var derivaDalSegno = false;
      for (final r in righe) {
        final st = r.trimLeft();
        if (st.startsWith('//') || st.startsWith('///')) continue;
        if (r.contains('GuideAnimalDerivation.forSign')) derivaDalSegno = true;
      }
      if (derivaDalSegno) colpevoli.add(p);
    }
    expect(colpevoli, isEmpty,
        reason: 'questi file derivano ancora l\'animale dal segno (lo '
            'misura la guardia gemella, "una porta sola"), e se lo fanno '
            'per poi chiedere "si puo\' dire" rispondono sempre no:\n'
            '${colpevoli.join('\n')}');
  });

  test(
      'CHI HA BISOGNO DI UN PLACEHOLDER SINCRONO PASSA DA '
      'AnimaleDiPotere.sagomaNonRivelata, non da una sagoma sua', () {
    // **IL CARDINALE MINIMO.** Se nessuno chiedesse piu' la sagoma neutra,
    // vorrebbe dire che la porta unica non e' piu' quella che tutti
    // chiamano, e questa guardia starebbe sorvegliando un passaggio vuoto.
    var quanti = 0;
    for (final f in sorgentiDiLib()) {
      final codice = f.readAsStringSync();
      if (codice.contains('AnimaleDiPotere.sagomaNonRivelata') ||
          codice.contains('AnimaleDiPotere.animalePlaceholder') ||
          codice.contains('AnimaleDiPotere.nonAncoraRivelato')) {
        quanti++;
      }
    }
    cardinaleMinimo(quanti, 3,
        cosa: 'file che chiedono la sagoma neutra a AnimaleDiPotere',
        perche: 'Se nessuno la chiede piu\', o la porta unica e\' stata '
            'spostata, o qualcuno e\' tornato a disegnarsi una sagoma per '
            'conto suo.');
    // ignore: avoid_print
    print('ORDINE FZ VOCE 02: $quanti file passano dalla sagoma neutra '
        'comune');
  });

  /// **L'ESENZIONE SI PAGA.** Il trionfo dell'animale e' esente dalla
  /// domanda **perche' non rivela mai**: qui si verifica che sia ancora
  /// vero.
  ///
  /// **VISTA ROSSA** scrivendo `Text(widget.animale.name)` dentro il trionfo:
  /// la prova ha nominato il file e la riga.
  test('il trionfo dell\'animale non scrive mai il suo nome', () {
    final f = File('lib/features/onboarding/trionfi_screen.dart');
    expect(f.existsSync(), isTrue,
        reason: 'IL TRIONFO DELL\'ANIMALE E\' STATO SPOSTATO, e con lui '
            'l\'esenzione che questa guardia concede al Risveglio.');
    final codice = f.readAsLinesSync();
    final accusate = [
      for (var i = 0; i < codice.length; i++)
        if (codice[i].contains('animale.name') ||
            codice[i].contains('animal.name'))
          '  riga ${i + 1}: ${codice[i].trim()}',
    ];
    expect(
      accusate,
      isEmpty,
      reason: 'IL TRIONFO DELL\'ANIMALE SCRIVE IL NOME DELL\'ANIMALE.\n'
          '${accusate.join('\n')}\n\n'
          'Quella scheda e\' esente dalla porta unica proprio perche\' non '
          'rivela mai: mostra l\'ombra e promette che il nome arrivera\' '
          'scendendo. Se adesso lo scrive, l\'esenzione non vale piu\', e o '
          'si toglie il nome o si aggiunge la domanda.',
    );
  });
}
