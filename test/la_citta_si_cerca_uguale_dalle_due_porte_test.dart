import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:esoteric_circle/core/astro/ricerca_del_luogo.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA CITTA' SI CERCA UGUALE DALLE DUE PORTE. Ordine CF voce 08.
///
/// **Il fatto del fondatore, verbatim**: "in questa schermata non funzionava
/// l'inserimento della citta', ovvero potevo inserirla, ma non trovava nulla
/// nel suo elenco. quindi ho dovuto reinserire i dati dal menu' utente e qui
/// tutto ok, l'inserimento della citta' con suggerimento ha funzionato."
///
/// **Il fatto isola la causa da solo: la stessa ricerca da una porta funziona
/// e dall'altra no.** Misurato prima di curare: il rito dell'accoglienza
/// chiamava `CityCatalog.unicaEsatta` e, quando il nome scritto per intero
/// combaciava con un solo luogo, **svuotava l'elenco** e usciva; la schermata
/// dei dati di nascita chiamava il solo `search` e l'elenco lo mostrava
/// sempre. Chi scriveva "Roma" nel rito si trovava davanti a uno schermo che
/// sembrava dire "non l'ho trovata".
///
/// **La prova guarda la REGOLA e non le due schermate, ed e' voluto.** La cura
/// della classe "due porte" e' togliere la porta: adesso la regola e' una
/// sola, `RicercaDelLuogo`, e le due schermate la chiamano. Una prova che
/// montasse i due schermi misurerebbe due impaginazioni; questa misura la cosa
/// che era diversa. Che le schermate chiamino davvero lei lo pretende la terza
/// prova, sul sorgente.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    CityCatalog.adotta(
        CityCatalog.parse(File('assets/data/luoghi.csv').readAsStringSync()));
  });

  /// Nomi scritti per intero, che e' il caso in cui le due porte divergevano.
  const perIntero = <String>['Roma', 'Torino', 'Palermo', 'Bologna'];

  test('un nome scritto per intero sceglie il luogo E resta in elenco', () {
    final muti = <String>[];
    for (final nome in perIntero) {
      final r = RicercaDelLuogo.per(nome);
      // ignore: avoid_print
      print('ORDINE CF VOCE 08: "$nome" sceglie ${r.scelta?.name ?? "nulla"} '
          'e mostra ${r.risultati.length} suggerimenti');
      if (r.risultati.isEmpty) muti.add(nome);
    }
    expect(muti, isEmpty,
        reason: 'scrivendo per intero $muti la ricerca non mostra nessun '
            'suggerimento: a video sembra che il Cerchio non conosca quella '
            'citta', skip: false);
  });

  test('la regola non perde la scelta automatica', () {
    // **LA DECISIONE PRECEDENTE NON SI ROVESCIA.** "Un solo candidato non e'
    // una scelta, e' gia' la risposta": chi scrive per intero il nome della
    // propria citta' non deve confermare cio' che ha appena scritto. Questa
    // prova esiste perche' la cura di CF.08 non la cancelli per distrazione.
    var scelte = 0;
    for (final nome in perIntero) {
      if (RicercaDelLuogo.per(nome).scelta != null) scelte++;
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 08: nomi per intero che si scelgono da soli '
        '$scelte su ${perIntero.length}');
    expect(scelte, greaterThan(0),
        reason: 'nessun nome scritto per intero si sceglie piu\' da solo: la '
            'cura ha cancellato una decisione del fondatore');
  });

  test('un nome ambiguo non sceglie, e mostra le omonime', () {
    // Londra dell'Ontario e Londra d'Inghilterra stanno tutte e due in
    // catalogo: qui la scelta e' della persona, e l'elenco deve esserci.
    final r = RicercaDelLuogo.per('London');
    // ignore: avoid_print
    print('ORDINE CF VOCE 08: "London" sceglie ${r.scelta?.name ?? "nulla"} '
        'e mostra ${r.risultati.length} suggerimenti');
    expect(r.risultati, isNotEmpty,
        reason: 'un nome ambiguo non mostra nemmeno le omonime: la persona '
            'non ha modo di dire quale sia la sua');
  });

  test('le due porte chiamano la stessa regola, e nessuna se ne fa una sua',
      () {
    // **LA PROVA SUL SORGENTE, e senza di lei le prime tre sarebbero una
    // promessa.** Misurano la regola; questa pretende che le schermate la
    // usino davvero invece di tenersi la loro copia.
    const porte = <String>[
      'lib/features/onboarding/onboarding_screen.dart',
      'lib/features/account/dati_di_nascita_screen.dart',
    ];
    final colpe = <String>[];
    for (final percorso in porte) {
      final sorgente = File(percorso)
          .readAsStringSync()
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      if (!sorgente.contains('RicercaDelLuogo.per(')) {
        colpe.add('$percorso non chiama RicercaDelLuogo');
      }
      if (sorgente.contains('CityCatalog.unicaEsatta(')) {
        colpe.add('$percorso si e\' rifatto la scelta automatica per conto '
            'suo invece di passare dalla regola');
      }
      if (sorgente.contains('CityCatalog.search(')) {
        colpe.add('$percorso cerca ancora per conto suo: e\' esattamente la '
            'seconda porta che questa voce ha tolto');
      }
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 08: porte controllate ${porte.length}, '
        'divergenze ${colpe.length}');
    expect(colpe, isEmpty, reason: 'le due porte tornano a divergere: $colpe');
  });
}
