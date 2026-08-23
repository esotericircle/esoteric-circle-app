import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/sigilli/bonus_della_condivisione.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// GLI EOS SI LEGGONO SUL PULSANTE. Ordine BB voce 04.
///
/// **Richiesta del fondatore**: "le card con il tasto condivisione dovrebbero
/// riportare il numero di EOS che si guadagnano se si fa una condivisione
/// pubblica in modo che l'utente sia incentivato, e cosi' anche se invita un
/// amico all'installazione dell'app."
///
/// **Il numero lo dice il server, e non e' scritto nel client.** E' la parte
/// che conta: se domani un invito valesse settanta invece di sessanta, la
/// frase sul pulsante cambierebbe **da sola**. Il listino viaggia dentro lo
/// stato del Cerchio, che il telefono chiede gia' a ogni apertura: **nessuna
/// callable nuova**, per la stessa ragione per cui di li' viaggia gia' il
/// cammino.
///
/// **E' un'informazione, non un'autorizzazione**: il conto lo fa sempre il
/// server, che dal motivo sa quanto vale. Un listino che arriva al telefono
/// non e' un permesso di pagare.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('il listino arriva dal server e il borsellino lo custodisce', () async {
    final borsa = QuestionAllowance(porta: _PortaColListino());
    await borsa.sincronizza();
    final letti = {
      for (final modo in ModoDellaCondivisione.values)
        modo.motivo: borsa.eosPerLaCondivisione(modo.motivo),
    };
    // ignore: avoid_print
    print('ORDINE BB VOCE 04: il borsellino legge $letti');

    // **I TRE NUMERI DEL FONDATORE**, uno per uno: 60 l'invito che porta un
    // download, 30 la condivisione pubblica, 15 quella privata.
    expect(borsa.eosPerLaCondivisione('invito_con_download'), 60);
    expect(borsa.eosPerLaCondivisione('social_pubblico'), 30);
    expect(borsa.eosPerLaCondivisione('condivisione_privata'), 15);
  });

  test('senza listino non si inventa nessun numero', () async {
    // **LA CONTROPROVA, ed e' la piu' importante.** Un server piu' vecchio
    // dell'app non manda il listino: li' il pulsante deve dire QUANDO arriva
    // il premio senza dire quanto. **Un numero di ripiego scritto nel client
    // resterebbe a promettere il vecchio listino per sempre**, e sarebbe una
    // bugia scritta bene.
    final borsa = QuestionAllowance(porta: _PortaSenzaListino());
    await borsa.sincronizza();
    // ignore: avoid_print
    print('ORDINE BB VOCE 04: col server muto, il listino ha '
        '${borsa.listinoDellaCondivisione.length} voci e l invito vale '
        '${borsa.eosPerLaCondivisione('invito_con_download')}');
    expect(borsa.eosPerLaCondivisione('invito_con_download'), isNull,
        reason: 'il client si inventa un numero che il server non ha detto');
  });

  test('un listino gia noto non viene cancellato da un server muto', () async {
    // Prima il server parla, poi tace: cio' che si sa non si dimentica.
    final borsa = QuestionAllowance(porta: _PortaCheParlaEPoiTace());
    await borsa.sincronizza();
    final primo = borsa.eosPerLaCondivisione('social_pubblico');
    await borsa.sincronizza();
    final secondo = borsa.eosPerLaCondivisione('social_pubblico');
    // ignore: avoid_print
    print('ORDINE BB VOCE 04: dopo la prima risposta $primo, dopo il '
        'silenzio $secondo');
    expect(primo, 30);
    expect(secondo, 30,
        reason: 'un server che non manda il listino cancella quello che il '
            'telefono sapeva gia');
  });
}

class _PortaColListino extends PortaDelCerchio {
  const _PortaColListino();

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-08-23',
        'spesi': const {'domande': 0},
        'saldoEos': 100,
        'listinoDellaCondivisione': const {
          'invito_con_download': 60,
          'social_pubblico': 30,
          'condivisione_privata': 15,
        },
      });

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      null;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}

class _PortaSenzaListino extends _PortaColListino {
  const _PortaSenzaListino();

  @override
  Future<StatoDelCerchio?> stato(
          {Object? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-08-23',
        'spesi': const {'domande': 0},
        'saldoEos': 100,
      });
}

class _PortaCheParlaEPoiTace extends _PortaColListino {
  _PortaCheParlaEPoiTace();

  int _volte = 0;

  @override
  Future<StatoDelCerchio?> stato(
      {Object? cammino, bool azzeraIlCammino = false}) async {
    _volte++;
    return StatoDelCerchio.daMappa({
      'giorno': '2026-08-23',
      'spesi': const {'domande': 0},
      'saldoEos': 100,
      if (_volte == 1)
        'listinoDellaCondivisione': const {
          'invito_con_download': 60,
          'social_pubblico': 30,
          'condivisione_privata': 15,
        },
    });
  }
}
