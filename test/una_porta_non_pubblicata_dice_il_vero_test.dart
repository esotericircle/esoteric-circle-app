import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/il_consenso_della_spesa.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';

/// **UNA PORTA NON PUBBLICATA DICE IL VERO.** Ordine GA voce 11, 20 ottobre
/// 2026, difetto 4 della ricognizione.
///
/// Nella build 2314 la ricucitura di una perla del Respiro della Luna arriva
/// alla conferma della spesa, e poi la porta del server
/// `ricuciUnaPerlaDelRespiro` non c'e' (non pubblicata, ORDINE_FX_MANIFESTO
/// righe 141-143; `gcloud functions list` non la elenca). Il server risponde
/// `not-found` con la parola grezza `NOT_FOUND`, e la persona leggeva "Il
/// Cerchio non risponde adesso: riprova fra poco": falso, perche' riprovare
/// non cambia niente finche' la porta non si pubblica. Lo stesso per le sei
/// porte di Respiriamo insieme e della collana a due.
///
/// Padre (Regola C): ordine FF voce 02, che per la porta non pubblicata del
/// Ritratto ha scelto la riga della rete assente; e ordine FX voci FXA.03,
/// FX.09 e FX.10, che hanno messo nell'app porte non pubblicate.
class _PortaSenzaLaRicucitura extends PortaSpentaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    switch (porta) {
      case 'ricuciUnaPerlaDelRespiro':
        // Cio' che arriva da una callable non pubblicata.
        return const EsitoSociale(
            dati: {}, errore: 'not-found', riga: 'NOT_FOUND');
      case 'rispondiCollanaADue':
        // Un rifiuto vero del server, col codice not-found e una frase.
        return const EsitoSociale(
            dati: {},
            errore: 'not-found',
            riga: 'Questa collana non c\'è più.');
      default:
        // La rete che non c'e'.
        return null;
    }
  }
}

void main() {
  final sociale = IlCerchioSociale(porta: _PortaSenzaLaRicucitura());

  test('la ricucitura senza la sua porta dice che la funzione non e\' aperta',
      () async {
    final esito = await sociale.ricuciUnaPerlaDelRespiro(
      consenso: ConsensoDellaSpesa.perLeProve(25),
      giorno: DateTime(2026, 10, 18),
      inizioCiclo: DateTime(2026, 10, 10),
    );
    expect(esito.ok, isFalse);
    final riga = esito.rigaPerLaPersona;
    expect(riga, isNot(contains('riprova')),
        reason: 'la persona legge di riprovare fra poco una funzione che '
            'nessun nuovo tentativo aprira\': "$riga"');
    expect(riga, contains('non è ancora aperta'),
        reason: 'la riga non dice il vero sulla porta: "$riga"');
    expect(riga, contains('nessun Eos è stato speso'),
        reason: 'dopo la conferma della spesa la persona deve sapere che '
            'non ha pagato: "$riga"');
    expect(riga, isNot(contains('NOT_FOUND')));
  });

  test('un rifiuto vero del server con not-found resta la sua frase', () async {
    final esito = await sociale.rispondiCollanaADue('c1', risposta: 'accetta');
    expect(esito.rigaPerLaPersona, 'Questa collana non c\'è più.');
  });

  test('senza rete resta la riga della rete', () async {
    final esito = await sociale.respiroInsiemeEntra();
    expect(esito.rigaPerLaPersona, EsitoDelGesto.silenzio.riga);
  });
}
