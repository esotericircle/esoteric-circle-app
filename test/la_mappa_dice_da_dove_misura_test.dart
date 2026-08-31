import 'dart:io';

import 'package:esoteric_circle/core/synastry/possibilita_di_incontro.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA MAPPA DICE DA DOVE MISURA. Ordine CF voce 13.
///
/// **Rilievo del fondatore, verbatim**: "nelle mappe della sinastria vip, dove
/// calcola la distanza tra me e il vip, il calcolo viene fatto sulla citta'
/// natale, ma se adesso vivessi in altro luogo? il calcolo va fatto sul luogo
/// in cui mi trovo adesso."
///
/// **Misurato prima di curare, e il fatto era peggiore di come sembrava.** La
/// mappa un luogo attuale lo leggeva davvero, `LuogoAttuale` sotto la chiave
/// `luogo.attuale`, e ripiegava sul luogo di NASCITA quando quella chiave era
/// vuota. Ma quella chiave era scritta **da un punto solo in tutta l'app**,
/// dentro il Rito dell'Alba, dove viene chiesta per sapere a che ora sorge il
/// sole e non per sapere dove la persona vive. E nel profilo non esisteva
/// nessun campo per dirlo: chi quel rito non lo aveva mai compiuto **non aveva
/// nessun modo di dire dove vive**, e la mappa gli misurava la distanza dalla
/// citta' di nascita senza dirglielo.
///
/// **Le prove guardano tre cose, e la terza e' quella che il fondatore
/// vedra'**: che il campo esista dove stanno gli altri suoi dati, che il
/// ripiego si dichiari tale, e che la mappa scriva a video da quale dei due
/// luoghi sta misurando.
void main() {
  test('il ripiego sulla nascita si dichiara, il luogo detto no', () {
    const detto = DoveSei(citta: 'Milano', latitudine: 45.4, longitudine: 9.2);
    const ripiego = DoveSei(
        citta: 'Roma',
        latitudine: 41.9,
        longitudine: 12.5,
        dichiarato: false);
    // ignore: avoid_print
    print('ORDINE CF VOCE 13: luogo detto dichiarato ${detto.dichiarato}, '
        'ripiego dichiarato ${ripiego.dichiarato}');
    expect(detto.dichiarato, isTrue,
        reason: 'un luogo che la persona ha detto risulta un ripiego');
    expect(ripiego.dichiarato, isFalse,
        reason: 'il ripiego sulla citta\' di nascita si spaccia per un luogo '
            'dichiarato: e\' esattamente il silenzio che il fondatore ha '
            'trovato');
  });

  test('il campo per dire dove vivi sta coi dati della persona', () {
    // **E NON DENTRO UN RITO**, che e' il vincolo dell'ordine: il luogo dove
    // si vive e' un dato della persona e va dove stanno gli altri suoi dati.
    final schermata =
        File('lib/features/account/dati_di_nascita_screen.dart')
            .readAsStringSync();
    expect(schermata.contains("Key('dove_vivi_field')"), isTrue,
        reason: 'nella schermata dei dati non c\'e\' nessun campo per dire '
            'dove si vive adesso');
    expect(schermata.contains('DoveSonoAdesso.scrivi('), isTrue,
        reason: 'il campo non scrive il luogo attuale: resterebbe una casella '
            'che non ricorda niente');
    expect(schermata.contains('DoveSonoAdesso.letto('), isTrue,
        reason: 'il campo non rilegge il luogo gia\' dichiarato, quindi lo '
            'richiede ogni volta');
  });

  test('la mappa scrive a video da quale luogo misura', () {
    final mappa = File('lib/features/synastry/mappa_della_distanza.dart')
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    expect(mappa.contains("Key('sinastria_mappa_da_dove')"), isTrue,
        reason: 'la mappa non dichiara da dove misura: un numero che non dice '
            'da dove nasce e\' la stessa bugia di un titolo senza testo');
    expect(mappa.contains('doveSei.dichiarato'), isTrue,
        reason: 'la mappa non distingue il luogo detto dal ripiego, quindi la '
            'riga che scrive vale per tutti e due e non dice niente');
  });

  test('il ripiego della Sinastria si dichiara tale', () {
    final schermo = File('lib/features/synastry/sinastria_vip_screen.dart')
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    expect(schermo.contains('dichiarato: false'), isTrue,
        reason: 'la Sinastria costruisce il ripiego sulla citta\' di nascita '
            'senza marcarlo, e la mappa non ha modo di saperlo');
  });
}
