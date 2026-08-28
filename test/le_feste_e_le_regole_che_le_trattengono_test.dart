import 'dart:io';

import 'package:esoteric_circle/core/sigilli/coda_delle_feste.dart';
import 'package:esoteric_circle/core/sigilli/distanza_fra_le_feste.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE FESTE E LE REGOLE CHE LE TRATTENEVANO. Ordine BD voce 08.
///
/// **Parole del fondatore, build 2198**: "LE FESTE NON FUNZIONANO! QUANDO
/// RAGGIUNGO UN OBIETTIVO, NON PARTE L'ANIMAZIONE DI CELEBRAZIONE!".
///
/// **La misura ha detto che le feste FUNZIONAVANO ed erano TRATTENUTE**
/// dalle due regole dell'ordine AU: una festa per apertura dell'app e tre
/// ore fra due feste. Il primo traguardo festeggiava, tutti gli altri
/// entravano in coda IN SILENZIO fino a tre ore dopo: dalla poltrona del
/// fondatore era identico a "non funzionano".
///
/// **La decisione del fondatore, 23 agosto 2026: FESTA SEMPRE, SUBITO.**
/// Una maturazione fresca festeggia nell'istante del gesto; se una festa
/// e' gia' a schermo la prossima entra in coda e riparte appena quella si
/// chiude; la distanza, scesa a novanta secondi, vale solo per il guardiano
/// che riprende la coda a freddo.
///
/// **Le strade sono tante, la porta e' una.** Ogni schermata che registra un
/// gesto passa da `RegiaDelCammino.dopoUnGesto`, e ogni festa passa da
/// `Celebrazione.festeggiaInsieme` chiamata dalla regia o dal guardiano
/// della coda: verificarlo qui vuol dire che la garanzia "festa o coda, mai
/// persa" vale per OGNI strada senza doverle percorrere una a una.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('BD.08: la legge nuova, festa sempre e subito', () async {
    SharedPreferences.setMockInitialValues(const {});
    DistanzaFraLeFeste.nuovaApertura();

    // Il primo traguardo in assoluto passa sempre, come sempre.
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(primoInAssoluto: true),
        isTrue);
    await DistanzaFraLeFeste.segnaFesta();

    // **IL LIMITE PER APERTURA NON ESISTE PIU'**: due minuti dopo, il
    // guardiano puo' gia' ripartire. La distanza e' scesa a novanta secondi
    // e vale solo per lui: la maturazione fresca non la guarda proprio,
    // verificato sul codice qui sotto.
    await DistanzaFraLeFeste.fingiCheSiaPassato(const Duration(minutes: 2));
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(), isTrue,
        reason: 'a due minuti dalla festa precedente il guardiano deve poter '
            'ripartire: le tre ore di AU sono state revocate dal fondatore');

    // Sotto i novanta secondi il guardiano aspetta: e' l'anti raffica.
    await DistanzaFraLeFeste.fingiCheSiaPassato(const Duration(seconds: 30));
    expect(await DistanzaFraLeFeste.siPuoFesteggiare(), isFalse,
        reason: 'a trenta secondi il guardiano a freddo deve aspettare '
            'ancora un minuto: senza, una coda lunga diventa una raffica');
    // ignore: avoid_print
    print('ORDINE BD VOCE 08: prima festa subito, guardiano libero a 90 '
        'secondi, trattenuto sotto. La maturazione fresca non guarda '
        'nessuna distanza.');
  });

  test('BD.08: la maturazione fresca non guarda la distanza, sul codice', () {
    // **LA GARANZIA "SEMPRE, SUBITO" VIVE NELLA REGIA**: fra il ciclo che
    // accende e la chiamata alla festa non deve esserci nessun
    // siPuoFesteggiare. Se qualcuno lo rimette, il fondatore rivedra' i
    // traguardi muti della 2198.
    final regia = File('lib/features/sigilli/regia_del_cammino.dart')
        .readAsStringSync();
    final ciclo = regia.substring(regia.indexOf('guardaCosaSiAccende'),
        regia.indexOf('static Future<void> svuotaLaCoda'));
    expect(ciclo.contains('siPuoFesteggiare'), isFalse,
        reason: 'la maturazione fresca guarda di nuovo la distanza: la festa '
            'al traguardo torna a essere trattenuta (ordine BD voce 08)');
    // **E LA CHIUSURA DI UNA FESTA NON NE APRE UN'ALTRA. Ordine BW voce
    // 02**, e SOSTITUISCE la catena che questa riga sorvegliava: qui si
    // pretendeva che la coda ripartisse alla chiusura, ed e\' proprio quella
    // catena che il fondatore ha visto sulla 2210 come quattro feste
    // consecutive. Chi aspettava non ha perso niente: adesso entra nella
    // stessa scena invece di aprirne una propria.
    expect(ciclo.contains('svuotaLaCoda(context'), isFalse,
        reason: 'la chiusura di una festa riapre la coda: e\' la catena che '
            'fa vedere piu\' feste di seguito (ordine BW voce 02)');
    // La distanza di novanta secondi resta scritta dove il guardiano legge.
    final distanza = File('lib/core/sigilli/distanza_fra_le_feste.dart')
        .readAsStringSync();
    expect(distanza.contains('Duration(seconds: 90)'), isTrue,
        reason: 'la distanza del guardiano non e\' piu\' novanta secondi');
    // ignore: avoid_print
    print('ORDINE BD VOCE 08 con la correzione BW VOCE 02: il ciclo della '
        'regia non guarda la distanza, la chiusura non riapre la coda, il '
        'guardiano tiene i 90 secondi');
  });

  test('BD.08: una festa trattenuta non si perde, entra in coda', () async {
    SharedPreferences.setMockInitialValues(const {});
    final coda = CodaDelleFeste();
    await coda.carica();
    await coda.accoda('med_9');
    expect(coda.vuota, isFalse);
    final prossima = await coda.prendiLaProssima();
    expect(prossima?.id, 'med_9',
        reason: 'la coda non restituisce la festa trattenuta: quella festa '
            'sarebbe persa davvero');
  });

  test('BD.08: le strade sono tante ma la porta e\' una, contate sul codice',
      () {
    // Ogni chiamata di dopoUnGesto in lib converge nella regia, e nessun
    // file celebra per conto suo: cosi' la garanzia vale per ogni strada.
    final strade = <String>[];
    var celebranti = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = f.readAsStringSync();
      if (testo.contains('dopoUnGesto(') &&
          !f.path.contains('regia_del_cammino')) {
        strade.add(f.uri.pathSegments.last);
      }
      if (testo.contains('Celebrazione.festeggiaInsieme(') &&
          !f.path.contains('regia_del_cammino')) {
        celebranti++;
      }
    }
    strade.sort();
    // ignore: avoid_print
    print('ORDINE BD VOCE 08: le strade dei gesti sono ${strade.length}: '
        '$strade');
    expect(strade.length, greaterThanOrEqualTo(16),
        reason: 'le strade dei gesti sono sparite dal censimento');
    expect(celebranti, 0,
        reason: 'qualcuno celebra fuori dalla regia: quella strada non '
            'passerebbe dalle regole ne\' dalla coda, e una festa potrebbe '
            'perdersi davvero');
  });
}
