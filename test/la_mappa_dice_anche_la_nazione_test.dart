import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/features/synastry/mappa_della_distanza.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA MAPPA DICE ANCHE LA NAZIONE. Ordine CD voce 02a.
///
/// **Le parole del fondatore, verbatim:** "quando sono vicini, non si capisce
/// visivamente dove si trovano, **nemmeno la nazione** e magari inserisci i
/// nomi delle capitali o capoluoghi o citta' piu' grandi come riferimento, ma
/// anche le citta' dove vivono."
///
/// L'ordine CC voce 06a aveva fatto le citta' di riferimento e le due citta'
/// dove vivono. **La nazione no**, e le citta' di riferimento rispondono solo a
/// meta': a chi conosce Torino e Bologna dicono l'Italia, a chiunque altro no,
/// e su una mappa di due punti stranieri non dicono niente.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Il catalogo vero, letto dal file come lo legge l'app.
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
  });

  test('da un punto qualunque esce il suo paese', () {
    const prove = <String, ({double lat, double lon})>{
      'Italia': (lat: 41.9028, lon: 12.4964),
      'Francia': (lat: 48.8566, lon: 2.3522),
      'Stati Uniti': (lat: 34.0522, lon: -118.2437),
      'Giappone': (lat: 35.6895, lon: 139.6917),
      'Brasile': (lat: -23.5505, lon: -46.6333),
    };
    final sbagliate = <String>[];
    prove.forEach((atteso, punto) {
      final trovata = NazioneDelPunto.di(punto);
      if (trovata != atteso) sbagliate.add('$punto: $trovata invece di $atteso');
    });
    // ignore: avoid_print
    print('ORDINE CD VOCE 02a: punti provati ${prove.length}, '
        'nazioni sbagliate ${sbagliate.length}');
    expect(sbagliate, isEmpty, reason: 'la mappa direbbe il paese sbagliato: '
        '$sbagliate');
  });

  test('in mezzo all\'oceano non si dichiara nessun paese', () {
    // **Meglio tacere che scrivere il paese sbagliato.** Un punto a meta'
    // dell'Atlantico prenderebbe la costa piu' vicina, e un nome sbagliato
    // sulla mappa e' peggio di nessun nome.
    const oceano = (lat: 30.0, lon: -40.0);
    // ignore: avoid_print
    print('ORDINE CD VOCE 02a: in mezzo all\'oceano la mappa dice '
        '${NazioneDelPunto.di(oceano)}');
    expect(NazioneDelPunto.di(oceano), isNull);
  });

  test('la nazione finisce davvero sulla tela', () {
    final mappa =
        File('lib/features/synastry/mappa_della_distanza.dart').readAsStringSync();
    // **Non basta saperla, bisogna scriverla.** Questa riga cade se qualcuno
    // toglie la scrittura dal pittore lasciando in piedi il calcolo, che e'
    // esattamente il modo in cui un rilievo del fondatore torna in silenzio.
    expect(mappa.contains('_scrivi(canvas, tuaNazione!'), isTrue,
        reason: 'la mappa calcola la nazione e non la disegna piu\'');
    expect(mappa.contains('_scrivi(canvas, suaNazione!'), isTrue,
        reason: 'la mappa non scrive piu\' la nazione dell\'altro punto');
    // E il paese non si ripete quando i due punti stanno nello stesso.
    expect(mappa.contains('suaNazione != tuaNazione'), isTrue,
        reason: 'la mappa scriverebbe due volte lo stesso paese');
  });
}
