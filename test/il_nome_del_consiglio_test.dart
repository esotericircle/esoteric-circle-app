import 'dart:io';

import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL NOME DEL CONSIGLIO VIVE IN UN PUNTO SOLO.
///
/// **Si chiama Il Consiglio dei Maestri dal 6 agosto 2026**, per decisione di
/// Mauro. Si chiamava Il Consiglio del Cerchio, e il Cerchio e' gia' il nome
/// della home: due cose diverse con la stessa parola in mezzo si confondono.
///
/// Questa prova non confronta due costanti fra loro, che direbbero sempre la
/// stessa cosa: **enumera i sorgenti** e cade se qualcuno scrive il nome a mano
/// dentro una schermata invece di leggerlo da `titoloDelConsiglio`. E' l'unico
/// modo perche' il nome resti uno il giorno in cui cambiera' di nuovo.
void main() {
  /// Il file in cui il nome e' DEFINITO: e' l'unico che puo' contenerlo scritto
  /// per esteso.
  const laPorta = 'lib/features/maestri/ask/ask_maestri_screen.dart';

  Iterable<File> sorgenti(String cartella) => Directory(cartella)
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  String relativo(File f) {
    final p = f.path.replaceAll(r'\', '/');
    final i = p.indexOf('lib/');
    return i >= 0 ? p.substring(i) : p.substring(p.indexOf('test/'));
  }

  test('il nome nuovo e\' quello deciso', () {
    expect(titoloDelConsiglio, 'Il Consiglio dei Maestri');
  });

  test('nessuno scrive il nome a mano fuori dal punto unico', () {
    final colpevoli = <String>[];
    for (final f in sorgenti('lib')) {
      final dove = relativo(f);
      if (dove == laPorta) continue;
      if (f.readAsStringSync().contains(titoloDelConsiglio)) {
        colpevoli.add(dove);
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'Questi file scrivono il nome del Consiglio a mano: '
            '$colpevoli. Il nome vive in `titoloDelConsiglio` e si legge da '
            'li\': due copie divergono al primo cambio, ed e\' appena '
            'cambiato.');
  });

  test('il nome vecchio non compare piu\' in nessun sorgente', () {
    // Tranne nella nota che racconta il cambio, dove serve a dire da cosa si
    // e' venuti: un documento che non nomina il nome vecchio non aiuta chi
    // trova quel nome in un vecchio appunto.
    const vecchio = 'Il Consiglio del Cerchio';
    final residui = <String>[];
    for (final f in [...sorgenti('lib'), ...sorgenti('test')]) {
      final dove = relativo(f);
      final testo = f.readAsStringSync();
      if (!testo.contains(vecchio)) continue;
      if (dove == laPorta && testo.contains('Si chiamava $vecchio')) continue;
      // Questa prova nomina il nome vecchio per forza: e' cio' che cerca.
      if (dove.endsWith('il_nome_del_consiglio_test.dart')) continue;
      residui.add(dove);
    }
    expect(residui, isEmpty,
        reason: 'Il nome vecchio e\' rimasto in: $residui.');
  });

  test('la schermata mostra il nome, e lo legge da li\'', () {
    // Il file della schermata deve USARE la costante nel punto in cui dipinge
    // il titolo: se la costante ci fosse ma nessuno la leggesse, il nome a
    // video potrebbe essere un altro senza che nulla lo dica.
    final sorgente = File(laPorta).readAsStringSync();
    // **LA GRANDEZZA MISURATA E' CAMBIATA CON L'ORDINE S VOCE 05.** Qui si
    // cercava `Text(titoloDelConsiglio`, cioe' il nome del WIDGET oltre al dato:
    // il titolo della barra e' passato a `TitoloCheNonSiRompe`, che va a capo fra
    // le parole invece di troncare, e la prova cadeva pur essendo il nome ancora
    // letto dalla costante. Cio' che va sorvegliato e' che il titolo NASCA DALLA
    // COSTANTE, non quale widget lo dipinge.
    final loLegge = sorgente.contains('testo: titoloDelConsiglio') ||
        sorgente.contains('Text(titoloDelConsiglio');
    expect(loLegge, isTrue,
        reason: 'La schermata del confronto non dipinge piu\' il titolo '
            'leggendolo da `titoloDelConsiglio`.');
  });
}
