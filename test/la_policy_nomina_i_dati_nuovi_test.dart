/// LA POLICY NOMINA OGNI DATO NUOVO. Ordine CG voce 12.
///
/// **Parole del fondatore**: "si, sono d'accordo con l'aggiornamento della
/// privacy policy."
///
/// **La guardia esistente lega i TEMPI, questa lega i DATI.**
/// `la_policy_dice_il_vero_test` pretende che ogni scadenza del listino sia
/// scritta nella pagina, ed e' una guardia sui numeri. Un dato NUOVO pero'
/// puo' nascere senza cambiare nessuna scadenza, e allora quella guardia non
/// se ne accorge: e' il caso dell'indice dei Ricordi, dello scrigno dei
/// custoditi e del token dell'apparecchio.
///
/// **Questa NON e' una dichiarazione nell'interfaccia.** La voce CG.09 dice
/// che nell'interfaccia non compare niente sulla sfocatura. Qui si parla del
/// documento legale, che e' un'altra cosa.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/legal/privacy_policy.dart';

/// I DATI NUOVI CHE QUESTO ORDINE INTRODUCE, e come la policy li deve
/// nominare.
///
/// **Ogni riga e' un dato, non una parola.** La chiave e' il nome del dato per
/// chi sviluppa; il valore e' cio' che la persona deve poter leggere nella
/// pagina. Un dato che nascesse domani senza una riga qui non farebbe cadere
/// niente, ed e' per questo che la riga si aggiunge INSIEME al dato.
const Map<String, List<String>> datiNuoviDaNominare = {
  'indice dei Ricordi del Cerchio': ['Ricordi del Cerchio'],
  'i responsi custoditi': ['custodire', 'non scadono'],
  'le sintesi settimanali': ['riassunto per Maestro', 'fatti'],
  'il gettone dell\'apparecchio': [
    'gettone del tuo apparecchio',
    'fuso orario',
  ],
};

void main() {
  test('CG.12: la policy nomina ogni dato nuovo di questo ordine', () {
    final tutto =
        sezioniDellaPolicy.map((s) => '${s.titolo} ${s.corpo}').join(' ');

    final mute = <String>[];
    for (final dato in datiNuoviDaNominare.entries) {
      for (final parola in dato.value) {
        if (!tutto.contains(parola)) {
          mute.add('${dato.key} (manca "$parola")');
        }
      }
    }

    // ignore: avoid_print
    print('ORDINE CG VOCE 12: dati nuovi da nominare '
        '${datiNuoviDaNominare.length}, non nominati ${mute.length}');

    expect(mute, isEmpty,
        reason: 'questi dati nuovi non sono nominati nella policy: $mute. IL '
            'ROSSO SI DIMOSTRA introducendo un dato nuovo senza nominarlo, e '
            'la guardia deve cadere dicendo quale');
  });

  test('CG.12: la policy dichiara che i custoditi NON scadono', () {
    // **E' l'affermazione piu' delicata di questa voce**, perche' e'
    // l'unica cosa del Cerchio che non ha una scadenza: se la pagina non lo
    // dicesse, il tempo di conservazione di quel dato sarebbe indichiarato.
    final tutto =
        sezioniDellaPolicy.map((s) => '${s.titolo} ${s.corpo}').join(' ');
    expect(tutto.contains('non scadono'), isTrue,
        reason: 'la policy non dice che i responsi custoditi restano');
    expect(tutto.contains('finché vive il tuo account'), isTrue,
        reason: 'e non dice fino a quando restano');
  });

  test('CG.12: la sfocatura e\' nel documento e NON nell\'interfaccia', () {
    // La voce CG.09 vieta la dichiarazione a video; la voce CG.12 la pretende
    // nel documento legale. Sono due cose diverse e vanno tutte e due.
    final tutto =
        sezioniDellaPolicy.map((s) => '${s.titolo} ${s.corpo}').join(' ');
    expect(tutto.contains('dopo due settimane'), isTrue,
        reason: 'il documento legale deve dire che il testo delle '
            'conversazioni diventa un riassunto dopo la finestra');
  });
}
