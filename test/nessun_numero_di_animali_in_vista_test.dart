import 'dart:io';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/le_ombre_che_ritornano.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/la_girandola_degli_animali.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **NESSUN NUMERO DI ANIMALI IN VISTA.** Ordine FZA voce 03, 19 ottobre
/// 2026.
///
/// **Il fondatore, 19 ottobre 2026, 20:11**: *"un domani, ne potrei
/// aggiungere altri, visto che da nessuna parte viene indicato il numero
/// degli animali."*
///
/// **DOMANDA**: in nessuna schermata, testo, pannello "Fonti e metodo" o
/// card compare quanti sono gli animali, ne' in cifre ne' in lettere; il
/// codice del Viaggio legge il catalogo, senza un dodici fisso.
///
/// **PROVA**: scansione di tutto `lib/` (la porta comune,
/// `sorgentiDiLib()`) per stringhe letterali (i commenti possono nominare
/// il numero, sono documentazione per chi legge il codice, non testo che
/// l'utente vede) che dicono "dodici animal..." o "12 animal..."; e un
/// tredicesimo animale finto aggiunto al catalogo in prova, per misurare
/// che `LeOmbreCheRitornano.ombreProposte` e `GirandolaDegliAnimali`
/// rispondano al catalogo vero, non a un dodici scritto a mano.
void main() {
  test(
      'NESSUN TESTO VISIBILE DICE QUANTI SONO GLI ANIMALI GUIDA, ne\' in '
      'cifre ne\' in lettere', () {
    // **IL PATTERN E\' MIRATO**, non "dodici" da solo: "dodici" compare
    // altrove per segni zodiacali, case, mesi, guardiani cinesi, respiri,
    // ed e\' legittimo li\'. Qui si cerca solo "dodici" o "12" a ridosso
    // della parola "animal", nelle stringhe vere, mai nei commenti.
    final pattern = RegExp(r'(dodici|12)\s+animal', caseSensitive: false);
    // **SOLO IL PERIMETRO DELL'ANIMALE GUIDA**, non ogni file che parla di
    // animali: lo zodiaco cinese dichiara legittimamente "dodici animali,
    // Topo, Bue, Tigre..." nelle sue note di tradizione, e quello non e'
    // il catalogo che FZA.03 vuole senza numero.
    bool nelPerimetro(String p) =>
        p.contains('/viaggio/') ||
        p.contains('animal') ||
        p == 'lib/core/sigilli/sentiero_albero.dart';
    final colpevoli = <String>[];
    var guardati = 0;
    for (final f in sorgentiDiLib()) {
      final p = f.path.replaceAll(Platform.pathSeparator, '/');
      if (!nelPerimetro(p)) continue;
      guardati++;
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        final st = r.trimLeft();
        if (st.startsWith('//') || st.startsWith('///')) continue;
        if (pattern.hasMatch(r)) colpevoli.add('$p riga ${i + 1}: $r');
      }
    }
    expect(guardati, greaterThan(10),
        reason: 'il perimetro dell\'Animale Guida trovato e\' troppo '
            'piccolo: la porta comune potrebbe non star scoprendo i file');
    // ignore: avoid_print
    print('ORDINE FZA VOCE 03: guardati $guardati file nel perimetro '
        'dell\'Animale Guida, righe che ne nominano il numero trovate '
        '${colpevoli.length}');
    expect(colpevoli, isEmpty,
        reason: 'questi file dicono quanti sono gli Animali Guida, in un '
            'testo che l\'utente puo\' leggere:\n${colpevoli.join('\n')}');
  });

  test(
      'IL TREDICESIMO ANIMALE FINTO: ombreProposte non resta bloccata a '
      'dodici', () {
    final estesoA13 = [
      ...AnimalCatalog.animals,
      const GuideAnimal(
          name: 'AnimaleFinto',
          summary: 'Prova',
          meaning: 'Prova di FZA.03',
          stem: 'ani_finto_v1'),
    ];
    expect(estesoA13.length, 13);
    // Chiedendo piu' ombre di quante il catalogo vero ne ha mai avute
    // (dodici), il tetto deve fermarsi al catalogo esteso (tredici), non a
    // dodici: la prova che il codice legge `catalogo.length`, non un
    // numero scritto a mano.
    final proposte = LeOmbreCheRitornano.ombreProposte(
      scelteInOrdine: const [],
      identita: 'prova_fza03',
      catalogo: estesoA13,
      quante: 20,
    );
    expect(proposte.length, 13,
        reason: 'con un catalogo di tredici animali e un tetto di venti, '
            'le proposte devono essere tredici (tutto il catalogo), non '
            'dodici: il codice avrebbe un dodici fisso al posto della '
            'lunghezza vera');
    expect(proposte, contains('AnimaleFinto'),
        reason: 'il tredicesimo animale finto non entra mai fra le '
            'proposte: qualcosa nel codice lo esclude per nome o per '
            'posizione invece che leggerlo dal catalogo');
  });

  testWidgets(
      'IL TREDICESIMO ANIMALE FINTO: la girandola mostra tredici totem, '
      'non dodici', (tester) async {
    final estesoA13 = [
      ...AnimalCatalog.animals,
      const GuideAnimal(
          name: 'AnimaleFinto',
          summary: 'Prova',
          meaning: 'Prova di FZA.03',
          stem: 'ani_finto_v1'),
    ];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GirandolaDegliAnimali(
          altezza: 80,
          senzaMoto: true,
          animali: estesoA13,
        ),
      ),
    ));
    await tester.pump();
    // **DUE VOLTE LA FILA**, come il widget stesso dichiara: con tredici
    // animali, ventisei immagini, non ventiquattro.
    expect(find.byType(Image), findsNWidgets(26),
        reason: 'con tredici animali nel catalogo la girandola deve '
            'disegnare ventisei immagini (due file da tredici), non '
            'ventiquattro: il dodici e\' ancora scritto a mano da qualche '
            'parte');
  });
}
