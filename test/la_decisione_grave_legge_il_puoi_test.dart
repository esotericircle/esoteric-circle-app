import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA GUARDIA DELLA DECISIONE GRAVE LEGGE "PUOI" COME UN ORDINE.** Ordine
/// ER, aggiunta 2, punto 1, 28 settembre 2026.
///
/// **IL FATTO**, nel banco del Viaggio del giro 7
/// (`docs/collaudo/ER/viaggio/giro7_esecuzione1.txt` e
/// `giro7_esecuzione2.txt`): alla domanda *"Mi trasferisco a Berlino per
/// lavoro?"* quattro risposte del modello sono state scartate come decisione
/// grave. Due dicevano *"Puoi trasferirti a Berlino per lavoro"*: la guardia
/// scattava sulla parola *trasferirti*, anche dentro *"Puoi trasferirti"*.
/// La regola della voce DN.04 resta com'e': *"Il responso puo' dire cosa
/// guardare, mai cosa fare. Prendere una parte si puo': si scarta l'ordine,
/// non la posizione."* **"Puoi trasferirti" prende una parte, non ordina.**
///
/// Le altre due dicevano *"Non lasciare nulla al caso, ma segui quello che
/// senti."*: su una domanda grave dicono come scegliere, come *"Scegli
/// quella che ti fa sentire piu' leggero"* della build 2259, e restano
/// scartate. Le quattro frasi qui sotto sono quelle vere del banco, copiate.
void main() {
  const berlino = 'Mi trasferisco a Berlino per lavoro?';
  const neutra = CourtesyForm.neutral;
  MotivoDelloScarto? risposta(String t, {String domanda = berlino}) =>
      LeGuardieDelResponso.dellaRisposta(t, domanda: domanda, forma: neutra);

  const conIlPuoi = [
    'I segni del viaggio dicono di sì. Puoi trasferirti a Berlino per '
        'lavoro, ma prima devi chiarire alcuni aspetti importanti. La '
        'decisione è nelle tue mani.',
    'I segni del viaggio dicono di sì. Puoi trasferirti a Berlino per '
        'lavoro, ma ti è chiesto di guardare con molta attenzione ciò che '
        'dovrai affrontare.',
  ];
  const comeScegliere = [
    'I segni del viaggio dicono di sì, se hai un piano concreto per '
        'l\'alloggio e le spese iniziali. Prepara i dettagli della tua '
        'partenza con attenzione. Non lasciare nulla al caso, ma segui quello '
        'che senti.',
    'I segni del viaggio indicano una risposta affermativa, se prepari il '
        'terreno per il trasferimento con attenzione. Pensa a ogni dettaglio '
        'pratico prima di partire. Non lasciare nulla al caso, ma segui quello '
        'che senti.',
  ];

  test('"puoi" con una decisione grave e\' una posizione, e passa', () {
    final scartate = [
      for (final t in conIlPuoi)
        if (risposta(t) == MotivoDelloScarto.decisioneGrave) t,
    ];
    // ignore: avoid_print
    print('ORDINE ER, AGGIUNTA 2, PUNTO 1: frasi del giro 7 col "puoi" '
        'scartate come decisione grave ${scartate.length} su '
        '${conIlPuoi.length}');
    expect(scartate, isEmpty,
        reason: 'la guardia legge "puoi" come un ordine: $scartate');
  });

  test('il come scegliere su una domanda grave resta scartato', () {
    for (final t in comeScegliere) {
      expect(risposta(t), MotivoDelloScarto.decisioneGrave, reason: t);
    }
  });

  test('gli ordini su una decisione grave restano scartati', () {
    // Le forme che la guardia ha sempre fermato, con "puoi" o senza.
    const ordini = {
      'Trasferisciti a Berlino entro l\'estate.': berlino,
      'Devi trasferirti a Berlino per lavoro.': berlino,
      'Non puoi restare: trasferisciti a Berlino.': berlino,
      'Lascia il lavoro in banca e apri la bottega.':
          'Lascio il lavoro in banca per una bottega?',
      'Devi separarti da lui.': 'Mi separo da mio marito?',
      'Vendi casa entro l\'inverno.': 'Vendo la casa dei nonni?',
      'Fatti operare al ginocchio.': 'Devo operarmi al ginocchio?',
    };
    final passati = [
      for (final e in ordini.entries)
        if (risposta(e.key, domanda: e.value) !=
            MotivoDelloScarto.decisioneGrave)
          e.key,
    ];
    // ignore: avoid_print
    print('ORDINE ER, AGGIUNTA 2, PUNTO 1: ordini su una decisione grave che '
        'passano la guardia ${passati.length} su ${ordini.length}');
    expect(passati, isEmpty,
        reason: 'ordini su una decisione grave passati: $passati');
  });

  test('"puoi" con le altre decisioni gravi della guardia passa', () {
    const posizioni = {
      'Puoi separarti, se è ciò che senti da mesi.': 'Mi separo da mio marito?',
      'Puoi licenziarti: i segni lo reggono.': 'Mi licenzio dalla banca?',
      'Puoi vendere la casa, ma non prima dell\'estate.':
          'Vendo la casa dei nonni?',
      'Puoi andartene da quella città.': 'Me ne vado da Torino?',
    };
    final scartate = [
      for (final e in posizioni.entries)
        if (risposta(e.key, domanda: e.value) ==
            MotivoDelloScarto.decisioneGrave)
          e.key,
    ];
    expect(scartate, isEmpty,
        reason: 'la guardia legge "puoi" come un ordine: $scartate');
  });
}
