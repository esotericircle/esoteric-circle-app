import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// OGNI DECIMALE CHE UNA PERSONA LEGGE PASSA DALLA LINGUA.
/// Ordine DM voce 03, completata dopo la domanda del fondatore sugli Eos.
///
/// **Perche' questa prova esiste, ed e' una lezione su come avevo lavorato.**
/// La prima passata della voce 03 aveva convertito **un punto per file** e si
/// era fermata li': nella stessa schermata ce n'erano altri, e nessuno se ne
/// sarebbe accorto finche' qualcuno non avesse letto *"0.12"* in italiano. Il
/// fondatore ha chiesto degli Eos, e cercando quelli e' venuta fuori una
/// famiglia intera: tre copie del separatore delle migliaia scritte a mano e
/// cinque decimali visibili rimasti indietro.
///
/// **La grandezza misurata**: ogni `toStringAsFixed` con almeno un decimale
/// che sopravvive in `lib`. Non si pretende che siano zero, perche' alcuni
/// sono giusti: si pretende che **siano esattamente quelli dichiarati qui
/// sotto, ognuno con la sua ragione**. Un decimale nuovo che compare senza
/// ragione fa cadere questa prova, ed e' il punto.
void main() {
  /// **I DECIMALI CHE RESTANO COL PUNTO, e il perche' di ognuno.**
  ///
  /// La chiave e' il file; il valore e' la ragione. Chi aggiunge una riga qui
  /// sta dichiarando che quel numero **non lo legge una persona**, oppure che
  /// il punto e' la forma giusta anche in italiano.
  const dichiarati = <String, String>{
    'lib/core/maestro/ritmo_della_voce.dart':
        'e la riga di diagnosi stampata accanto alla matrice di confusione, '
            'per chi sviluppa: un referto tecnico non e un testo a video',
    'lib/core/sigilli/lettura_degli_ancoraggi.dart':
        'e il referto della lettura degli ancoraggi, numeri per chi sviluppa',
    'lib/core/viaggio/diario_dei_viaggi.dart':
        'NON e un testo: e la SERIALIZZAZIONE di un punto nel diario, e '
            'localizzarla romperebbe la rilettura di cio che e gia scritto '
            'sui telefoni',
    'lib/design_system/components/cosmos_background.dart':
        'e l etichetta di debug della misura della scena',
    'lib/features/maestri/aura/face/face_constellation_screen.dart':
        'e il rapporto tecnico della costellazione, con il ripiego "nullo"',
    'lib/features/santuario/sky_overview_screen.dart':
        'sono LATITUDINE e LONGITUDINE a quattro decimali. Il punto e la '
            'forma internazionale delle coordinate, e scriverle con la '
            'virgola le renderebbe piu difficili da copiare altrove. E una '
            'scelta dichiarata, non una dimenticanza',
  };

  test('OGNI DECIMALE A VIDEO PASSA DALLA LINGUA, o e\' dichiarato', () {
    final conDecimali = <String, List<String>>{};
    var guardati = 0;
    // `toStringAsFixed(0)` non ha nessun separatore da scegliere: la sua
    // resa e' la stessa in ogni lingua, e non entra in questo conto.
    final colDecimale = RegExp(r'toStringAsFixed\(\s*[1-9]');
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      guardati++;
      for (final riga in f.readAsLinesSync()) {
        final pulita = riga.trim();
        if (pulita.startsWith('//')) continue;
        if (colDecimale.hasMatch(pulita)) {
          conDecimali.putIfAbsent(percorso, () => <String>[]).add(pulita);
        }
      }
    }
    expect(guardati, greaterThanOrEqualTo(500),
        reason: 'guardati solo $guardati file: questa prova stava per dire '
            'il vero su niente');

    final nonDichiarati = <String>[];
    for (final voce in conDecimali.entries) {
      if (dichiarati.containsKey(voce.key)) continue;
      for (final riga in voce.value) {
        nonDichiarati.add('${voce.key}: $riga');
      }
    }
    expect(nonDichiarati, isEmpty,
        reason: 'qui un numero con la virgola si scrive senza passare dalla '
            'lingua, e in italiano una persona leggera il punto. O lo si '
            'porta su NumeroDelCerchio, o lo si dichiara in questa prova '
            'con la sua ragione: ${nonDichiarati.join(" | ")}');

    // **E LE RAGIONI NON INVECCHIANO IN SILENZIO.** Un file dichiarato che
    // non ha piu' nessun decimale ha una ragione che parla di niente: si
    // toglie, come si toglie una riga dal registro dei rossi accettati.
    final diTroppo = [
      for (final f in dichiarati.keys)
        if (!conDecimali.containsKey(f)) f,
    ];
    expect(diTroppo, isEmpty,
        reason: 'questi file sono dichiarati ma non hanno piu nessun '
            'decimale: la dichiarazione va tolta: ${diTroppo.join(" | ")}');
  });
}
