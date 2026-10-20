import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LA CODA DEI CONSUMI NON SI AVVELENA.** Ordine GA voce 11, 20 ottobre
/// 2026, difetto 1 della ricognizione.
///
/// Sul telefono del fondatore e su tre iPhone dei tester, dalla build 2312:
/// una consultazione dell'Oracolo degli Angeli o una Sinastria evolutiva
/// mettevano in coda un consumo che il server pubblicato non conosce
/// (`consumaDelGiorno` risponde `invalid-argument` "Budget sconosciuto.").
/// La porta rilancia quel rifiuto, la coda restava ferma sulla sua prima
/// voce per sempre (e' salvata, sopravvive ai riavvii), e `sincronizza()`
/// cominciava svuotando la coda: lanciava prima di leggere lo stato, quindi
/// il telefono non sentiva piu' dal server il piano, i residui, il saldo Eos,
/// gli inviti accolti e il cammino. Le misure: 183 risposte 400 di
/// `consumaDelGiorno` in Cloud Logging dalla consegna della 2314 e dieci
/// eventi fatali "Budget sconosciuto." in Crashlytics sulla 2314 del
/// fondatore.
///
/// Padre (Regola C): ordine FT voce FT.13 e ordine FU voce FU.10, che hanno
/// aggiunto i budget `sinastrieEvolutive` e `oracoliAngeli` senza
/// pubblicare `consumaDelGiorno`; e il disegno della coda, che trattava un
/// rifiuto definitivo come un'assenza di rete (ordine N voce 2c).
class _ServerCheNonConosceUnBudget extends PortaDelCerchio {
  _ServerCheNonConosceUnBudget({this.codiceDelRifiuto = 'invalid-argument'});

  /// Il codice col quale il server rifiuta il budget che non conosce.
  final String codiceDelRifiuto;

  final Map<String, int> spesi = {};
  final List<String> rifiutati = [];
  final Set<String> visti = {};
  var statiChiesti = 0;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async {
    statiChiesti++;
    return StatoDelCerchio(
      giorno: '2026-10-19',
      piano: 'tier2',
      spesi: Map<String, int>.from(spesi),
      saldoEos: 77,
      invitiAccolti: 3,
      // Lo stato pubblicato conosce gia' il prezzo del riscatto degli
      // oracoli, quindi il telefono li conta e li accoda; `consumaDelGiorno`
      // pubblicato no. E' la combinazione vista in campo.
      listinoDelRiscatto: const {QuestionAllowance.kOracoliAngeli: 10},
    );
  }

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async {
    if (budget == QuestionAllowance.kOracoliAngeli ||
        budget == QuestionAllowance.kSinastrieEvolutive) {
      rifiutati.add(budget);
      // Cio' che fa la porta vera (`porta_del_cerchio.dart`, `_chiama`) col
      // rifiuto del server: lo rilancia col suo codice.
      throw FirebaseFunctionsException(
          code: codiceDelRifiuto, message: 'Budget sconosciuto.');
    }
    if (visti.add(idMovimento)) {
      spesi[budget] = (spesi[budget] ?? 0) + 1;
    }
    return const EsitoDelConsumo(concesso: true, resta: 5);
  }

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      77;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      true;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}

/// La coda come la trova al riavvio il telefono di un tester: in testa il
/// consumo che il server rifiuta, dietro due domande buone.
String _codaAvvelenata() => jsonEncode([
      {'budget': QuestionAllowance.kOracoliAngeli, 'id': 'oracolo-1'},
      {'budget': 'domande', 'id': 'domanda-1'},
      {'budget': 'domande', 'id': 'domanda-2'},
    ]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'una voce rifiutata con invalid-argument esce dalla coda, le buone '
      'arrivano al server e sincronizza legge lo stato', () async {
    SharedPreferences.setMockInitialValues(
        {'allowance.coda': _codaAvvelenata()});
    final server = _ServerCheNonConosceUnBudget();
    String? pianoDetto;
    final borsa = QuestionAllowance(
      porta: server,
      quandoIlServerDiceIlPiano: (piano) => pianoDetto = piano,
    );
    await borsa.load();
    expect(borsa.gestiInAttesa, 3);

    Object? caduta;
    try {
      await borsa.sincronizza();
    } catch (errore) {
      caduta = errore;
    }

    expect(caduta, isNull,
        reason: 'sincronizza() e\' caduta col rifiuto di una voce della coda: '
            '$caduta. Il telefono non sente piu\' il server');
    expect(server.statiChiesti, 1,
        reason: 'lo stato del Cerchio non e\' stato chiesto: la coda ha '
            'fermato la sincronia');
    expect(pianoDetto, 'tier2', reason: 'il piano del server non e\' arrivato');
    expect(borsa.saldoEos, 77,
        reason: 'il saldo Eos del server non e\' arrivato');
    expect(borsa.invitiAccolti, 3,
        reason: 'gli inviti accolti del server non sono arrivati');
    expect(server.spesi['domande'], 2,
        reason: 'le due domande dietro la voce rifiutata non sono arrivate '
            'al server: la coda e\' ferma sulla sua prima voce');
    expect(borsa.gestiInAttesa, 0,
        reason: 'la coda non si e\' svuotata: la voce rifiutata in modo '
            'definitivo e\' ancora li\' e si ripresentera\' a ogni apertura');

    // E la coda salvata e' vuota: al riavvio non torna il veleno.
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('allowance.coda') ?? '[]'), isEmpty);
  });

  test('un consumo nuovo rifiutato non diventa un errore senza padrone',
      () async {
    // Il gesto vivo: si consulta l'Oracolo, poi si fa una domanda. Il
    // consumo parte senza che nessuno lo aspetti (`_chiediAlServer`): prima
    // della cura il rifiuto diventava un errore asincrono non raccolto, che
    // e' cio' che Crashlytics contava come evento fatale sulla 2314.
    SharedPreferences.setMockInitialValues({});
    final server = _ServerCheNonConosceUnBudget();
    final borsa = QuestionAllowance(porta: server);
    await borsa.load();
    await borsa.sincronizza();
    expect(borsa.limiteOracoli(Tier.free), isNotNull,
        reason: 'la prova non accoderebbe nessun oracolo');

    borsa.registraOracolo(Tier.free);
    borsa.record(Tier.free);
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
    await borsa.sincronizza();

    expect(server.rifiutati, [QuestionAllowance.kOracoliAngeli]);
    expect(server.spesi['domande'], 1,
        reason: 'la domanda fatta dopo l\'Oracolo non e\' arrivata al server');
    expect(borsa.gestiInAttesa, 0);
  });

  test(
      'un rifiuto che riguarda l\'identita\' tiene la voce in coda ma non '
      'ferma la sincronia', () async {
    // `unauthenticated` e `permission-denied` non dicono che il consumo e'
    // sbagliato: dicono che in questo momento il telefono non e' riconosciuto
    // (il token di App Check, l'accesso che sta tornando). Il consumo resta
    // da mandare, ma lo stato si legge lo stesso.
    SharedPreferences.setMockInitialValues(
        {'allowance.coda': _codaAvvelenata()});
    final server =
        _ServerCheNonConosceUnBudget(codiceDelRifiuto: 'unauthenticated');
    final borsa = QuestionAllowance(porta: server);
    await borsa.load();

    await borsa.sincronizza();

    expect(server.statiChiesti, 1);
    expect(borsa.saldoEos, 77);
    expect(borsa.gestiInAttesa, 3,
        reason: 'un rifiuto d\'identita\' ha buttato dei consumi: il server '
            'non li contera\' mai');
  });
}
