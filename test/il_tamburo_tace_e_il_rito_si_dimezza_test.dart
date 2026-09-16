// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_tamburo_che_nutre.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL TAMBURO TACE NELLA DISCESA, E IL RITO DURA LA META'.**
/// Ordine DR voci 08 e 09, 16 settembre 2026.
///
/// **Le parole del fondatore**, due decisioni in due frasi: *"i tamburi
/// durante la discesa vanno eliminati, fanno schifo, e la musica di
/// sottofondo in verita' e' molto piu' adatta"*; *"la fase di nutrimento e'
/// troppo lunga, e' solo un zoom ed annoia, bisogna dimezzarla"*.
void main() {
  test('DR.09: IL RITO DEL TAMBURO DURA VENTI SECONDI, ed erano quaranta', () {
    print('ORDINE DR VOCE 09: il rito dura '
        '${IlTamburoCheNutre.quantoDura.inSeconds} secondi');
    expect(IlTamburoCheNutre.quantoDura, const Duration(seconds: 20),
        reason: 'la meta esatta di quaranta e venti: il numero e quello, e se '
            'cambia lo deve dire un ordine');
    // **E NIENT'ALTRO SI E MOSSO**: il colpo che tiene vivo il battito e il
    // passo dell'orologio non c'entrano con la durata, e restano dov'erano.
    expect(IlTamburoCheNutre.unColpoTieneVivo,
        const Duration(milliseconds: 1200));
  });

  test('DR.08: LA DISCESA NON CHIAMA PIU IL TAMBURO', () {
    // **LA GRANDEZZA MISURATA E LA CHIAMATA, non il file.** Il file
    // `tamburo_discesa` resta nel pacchetto apposta, perche' il colpo del
    // tamburo serve altrove: quello che non deve piu' succedere e' che la
    // discesa faccia partire il battito continuo.
    final discesa = File(
        'lib/features/maestri/caligo/viaggio/la_discesa_in_video.dart');
    expect(discesa.existsSync(), isTrue);
    final testo = discesa.readAsLinesSync();
    final vive = [
      for (final r in testo)
        if (!r.trimLeft().startsWith('//') && r.contains('PaletteSensoriale.tamburo')) r,
    ];
    print('ORDINE DR VOCE 08: righe vive che accendono il tamburo nella '
        'discesa ${vive.length}');
    expect(vive, isEmpty,
        reason: 'la discesa fa ancora partire il battito del tamburo: $vive');
    // **E LA MUSICA NON SI ABBASSA PIU' PER LUI.** Era `tamburo` a chiamare
    // `RegiaDellaMusica.scendiFinoA`: senza quella chiamata la musica di
    // sottofondo resta al suo volume per tutta la discesa, che e' cio' che il
    // fondatore ha chiesto.
    final regia = [
      for (final r in testo)
        if (!r.trimLeft().startsWith('//') && r.contains('scendiFinoA')) r,
    ];
    expect(regia, isEmpty,
        reason: 'qualcosa abbassa ancora la musica durante la discesa: $regia');
  });

  test('DR.08: il file del tamburo resta nel pacchetto', () {
    // L'ordine lo chiede per nome: i file audio non si cancellano, e se uno
    // resta senza chiamanti si dice nel manifesto invece di toglierlo.
    final file = File('assets/audio/mondo_di_sotto/tamburo_discesa.mp3');
    expect(file.existsSync(), isTrue,
        reason: 'il file del tamburo e stato tolto dal pacchetto, e l ordine '
            'DR voce 08 dice di lasciarlo dov e');
    print('ORDINE DR VOCE 08: tamburo_discesa.mp3 pesa '
        '${file.lengthSync()} byte e resta nel pacchetto');
  });
}
