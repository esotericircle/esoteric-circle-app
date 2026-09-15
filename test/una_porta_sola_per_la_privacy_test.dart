import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// UNA PORTA SOLA PER LA PRIVACY. Ordine CF voce 16.
///
/// **Richiesta del fondatore, verbatim**: "devi eliminare dal menu'
/// impostazioni 'privacy e permessi' [...] e deve eliminare anche 'cancella i
/// miei dati': questi devono esistere al massimo in un unico posto e cioe' nel
/// menu' utente in un sotto menu'."
///
/// **Il doppione era reale e recentissimo.** Le Impostazioni avevano una
/// sezione "Privacy e dati" con dentro "Privacy e permessi", costruita
/// dall'ordine CE voce 03 il giorno prima, piu' "Cancella i miei dati". Il
/// menu' utente ha gia' una voce "Privacy e dati" col suo sotto menu'. **Le
/// due porte avevano nomi quasi identici e la stessa identica icona.**
///
/// **LE DUE PROVE SONO DUE PERCHE' LA PULIZIA PUO' PERDERE ROBA.** La prima
/// pretende che le due voci non ci siano piu' nelle Impostazioni; la seconda
/// pretende che ognuna delle cose spostate sia raggiungibile dal menu' utente.
/// Senza la seconda, cancellare basterebbe a passare, e due delle cose
/// spostate sono di legge.
void main() {
  const impostazioni = 'lib/features/settings/settings_screen.dart';
  const menuUtente = 'lib/features/account/account_screen.dart';

  String codice(String percorso) => File(percorso)
      .readAsStringSync()
      .split('\n')
      .where((r) =>
          !r.trimLeft().startsWith('//') && !r.trimLeft().startsWith('///'))
      .join('\n');

  test('nelle Impostazioni le due voci non ci sono piu\'', () {
    final s = codice(impostazioni);
    final restate = <String>[];
    for (final segno in const [
      "title: 'Privacy e dati'",
      "Text('Privacy e permessi'",
      "Text('Cancella i miei dati'",
      'PrivacyEPermessiScreen',
    ]) {
      if (s.contains(segno)) restate.add(segno);
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 16: voci ancora nelle Impostazioni '
        '${restate.length}');
    expect(restate, isEmpty,
        reason: 'nelle Impostazioni vive ancora $restate: la porta doppia e\' '
            'tornata, e le due hanno nomi quasi identici');
  });

  test('tutto cio\' che e\' stato spostato si raggiunge dal menu\' utente', () {
    final s = codice(menuUtente);
    // Le cinque voci del sotto menu': le quattro che c'erano piu' quella
    // arrivata dalle Impostazioni.
    const attese = <String, String>{
      'la policy': "title: 'Privacy policy'",
      'lo scarico dei dati': "title: 'Scarica i tuoi dati'",
      'la cancellazione del cammino': "title: 'Cancella i tuoi dati'",
      'la cancellazione dell\'account': "title: 'Cancella il tuo account'",
      'privacy e permessi': "title: 'Privacy e permessi'",
    };
    final perse = <String>[];
    for (final voce in attese.entries) {
      if (!s.contains(voce.value)) perse.add(voce.key);
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 16: voci del sotto menu\' ${attese.length}, perse '
        '${perse.length}');
    expect(perse, isEmpty,
        reason: 'queste cose non si raggiungono piu\' da nessuna parte: '
            '$perse. Cambiare posto e\' cio\' che l\'ordine chiede, sparire '
            'no');
    expect(s.contains('PrivacyEPermessiScreen.route()'), isTrue,
        reason: 'la voce "Privacy e permessi" c\'e\' ma non porta a niente');
  });

  test('i due vincoli di legge restano raggiungibili', () {
    // **NON SI SACRIFICANO ALLA PULIZIA, e l'ordine li nomina.** Primo:
    // l'attribuzione delle fonti e' obbligatoria, perche' il catalogo delle
    // citta' e' sotto licenza CC BY 4.0, che pretende un'attribuzione
    // raggiungibile dall'utente. Secondo: il diritto di revocare il consenso
    // alla misura deve restare raggiungibile, e l'interruttore e' la via.
    final schermata =
        codice('lib/features/settings/privacy_e_permessi_screen.dart');
    expect(schermata.contains('fontiDeiDati'), isTrue,
        reason: 'l\'attribuzione delle fonti non e\' piu\' in questa '
            'schermata, e la licenza CC BY 4.0 la pretende raggiungibile');
    expect(schermata.contains('InterruttoreDellaMisura('), isTrue,
        reason: 'l\'interruttore della misura non e\' piu\' in questa '
            'schermata: senza, il consenso non si revoca piu\'');
  });
}
