// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **IL CATALOGO DEI LUOGHI SI CARICA ANCHE A MANI VUOTE.** Ordine EE voce
/// 11, 23 settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"ho provato a fare il viaggio dello
/// sciamano, ma non avendo dati di nascita memorizzati, si e' aperta una
/// finestra schermata per inserire data, ora, luogo di nascita e luogo dove
/// vivo. il luogo non funziona ovvero non mi vengono suggeriti i luoghi e
/// anche forzando l'invio, non funziona. invece se vado nel menu' utente, nel
/// menu' dati di nascita qui funziona tutto bene"*.
///
/// **La causa, ed e' una riga.** Il Viaggio dello Sciamano non ha un modulo
/// suo: apre **la stessa** `DatiDiNascitaScreen` del menu' utente
/// (`art_navigation.dart`, che ci manda quando manca il segno solare, cioe'
/// quando l'identita' e' d'esempio). In quella schermata
/// `CityCatalog.ensureLoaded()` stava **dopo** il `return` sui dati
/// d'esempio: quindi il catalogo **non si caricava esattamente e soltanto nel
/// caso in cui la schermata serviva a raccogliere i dati**. Restavano le
/// sessantacinque citta' del seme compilato al posto delle circa 40.846
/// dell'asset. Dal menu' utente il `return` non scatta, e infatti funzionava.
///
/// **PERCHE' UNA PROVA NUOVA, e non una gia' esistente.** Le due guardie che
/// coprivano la zona, `la_citta_si_cerca_uguale_dalle_due_porte` e
/// `dati_nascita_sbloccano`, sono state viste **verdi col catalogo spento**:
/// misurano che le due porte chiamino la stessa ricerca, non che la ricerca
/// abbia qualcosa su cui cercare. **Padre del difetto: PROVENIENZA IGNOTA**,
/// il `return` anticipato nasce col file e nessun ordine risulta averlo messo
/// in relazione con la porta del Viaggio.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// **Citta' che stanno nell'asset ma NON nel seme compilato.** Sono la
  /// misura: col seme la ricerca tace, col catalogo risponde. Se un giorno
  /// entrassero nel seme questa prova direbbe di si' a vuoto, ed e' il motivo
  /// del controllo qui sotto.
  const fuoriDalSeme = <String>['Piacenza', 'Grosseto', 'Lecco'];

  test('le citta\' della misura non stanno nel seme compilato', () {
    // **La prova della prova.** Senza questa, il giorno che una di queste
    // entrasse nel seme la misura resterebbe verde senza piu' misurare
    // niente: direbbe che il catalogo e' carico quando invece risponde il
    // seme.
    final sorgente =
        File('lib/core/astro/city_catalog.dart').readAsStringSync();
    final dentro =
        fuoriDalSeme.where((c) => sorgente.contains("'$c'")).toList();
    print('ORDINE EE VOCE 11: citta\' della misura ${fuoriDalSeme.length}, '
        'gia\' nel seme ${dentro.length}');
    expect(dentro, isEmpty,
        reason: 'queste citta\' sono entrate nel seme compilato, quindi non '
            'distinguono piu\' il catalogo dal seme: $dentro');
  });

  test('col solo seme la ricerca non le trova, e col catalogo si\'', () {
    // Prima: senza `ensureLoaded`, cioe' com'era la schermata aperta dal
    // Viaggio dello Sciamano.
    final muteColSeme = <String>[
      for (final c in fuoriDalSeme)
        if (CityCatalog.search(c).isEmpty) c,
    ];
    print('ORDINE EE VOCE 11, col solo seme: mute '
        '${muteColSeme.length} su ${fuoriDalSeme.length}');
    expect(muteColSeme, hasLength(fuoriDalSeme.length),
        reason: 'il seme compilato risponde gia\' a queste citta\': la prova '
            'non distinguerebbe piu\' il caso rotto da quello sano');

    // Dopo: col catalogo dell'asset, quello che `ensureLoaded` legge.
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
    final muteColCatalogo = <String>[
      for (final c in fuoriDalSeme)
        if (CityCatalog.search(c).isEmpty) c,
    ];
    print('ORDINE EE VOCE 11, col catalogo: mute '
        '${muteColCatalogo.length} su ${fuoriDalSeme.length}');
    expect(muteColCatalogo, isEmpty,
        reason:
            'il catalogo dell\'asset non trova queste citta\': $muteColCatalogo');
  });

  test('e la schermata dei dati di nascita lo carica PRIMA del return', () {
    // **La meta' che prende il difetto vero.** Le due prove qui sopra dicono
    // che il catalogo serve; questa dice che la schermata lo carica anche
    // quando la persona non ha dato ancora niente, che e' il solo caso in cui
    // il Viaggio dello Sciamano la apre.
    final sorgente = senzaCommenti(
        File('lib/features/account/dati_di_nascita_screen.dart')
            .readAsStringSync());
    final dove = sorgente.indexOf('CityCatalog.ensureLoaded');
    final ritorno = sorgente.indexOf('if (identita.isExample) return;');
    print('ORDINE EE VOCE 11: ensureLoaded a $dove, '
        'return sui dati d\'esempio a $ritorno');
    expect(dove, greaterThan(-1),
        reason: 'la schermata non carica piu\' il catalogo: chi arriva dal '
            'Viaggio dello Sciamano trova le sessantacinque citta\' del seme');
    expect(ritorno, greaterThan(-1),
        reason: 'il return sui dati d\'esempio non c\'e\' piu\': questa prova '
            'misurerebbe un ordine fra due righe di cui una non esiste');
    expect(dove, lessThan(ritorno),
        reason: 'CityCatalog.ensureLoaded sta DOPO il return sui dati '
            'd\'esempio, quindi non si carica proprio nel caso in cui la '
            'schermata serve a raccogliere i dati: e\' il difetto della voce '
            'EE.11, e si vede solo dal Viaggio dello Sciamano');
  });
}
