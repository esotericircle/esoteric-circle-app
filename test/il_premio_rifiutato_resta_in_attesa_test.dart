import 'dart:io';

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/sigilli/bonus_della_condivisione.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/libro_degli_accrediti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// IL PREMIO RIFIUTATO RESTA IN ATTESA, E IL SALDO NON RESTA INDIETRO.
/// Ordine AS voce 03.
///
/// **L'ENUMERAZIONE, cioe' dove si puo' fermare un accredito.** Sono quattro
/// punti, e si guardano uno per uno:
///   1. la PORTA e' spenta (nessun server): non si chiama nessuno;
///   2. il server NON RISPONDE: `muoviGliEos` torna nullo;
///   3. il server RIFIUTA, e oggi e' il caso sospettato: il motivo che il
///      telefono manda, `traguardo_gradino_<posizione>`, e' nato nell'ordine AR
///      e sul server vive solo dopo `firebase deploy --only functions`, che
///      Mauro non ha ancora eseguito. Un motivo che il listino non conosce e'
///      un errore, non un accredito;
///   4. l'accredito RIESCE ma il saldo non si applica.
///
/// **La regola che vale in tutti e quattro i casi**: il Sigillo resta acceso,
/// il premio NON si segna come arrivato, e alla prossima apertura si riprova.
/// Un premio segnato come arrivato quando non lo e' sarebbe perso per sempre,
/// perche' nessuno lo cercherebbe piu'.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Una porta che RIFIUTA gli accrediti come farebbe un server con un listino
  /// vecchio, e che sa comunque dire il saldo.
  ///
  /// Non e' una porta spenta: risponde, e risponde di no. E' la differenza fra
  /// "non c'e' campo" e "quel motivo non lo conosco".
  const porta = _PortaCheRifiutaIPremi();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('un accredito rifiutato non finisce nel libro dei premi arrivati',
      () async {
    final traguardo = Sentieri.tuttiITraguardi.first;
    final saldo = await PremioDelTraguardo.accredita(porta, traguardo);
    // ignore: avoid_print
    print('ORDINE AS VOCE 03: la porta che rifiuta risponde $saldo');
    expect(saldo, isNull,
        reason: 'un rifiuto deve arrivare come nulla: se tornasse un numero, '
            'il telefono lo scriverebbe in barra come se fosse arrivato');
    final arrivati = await LibroDegliAccrediti.accreditati();
    expect(arrivati, isEmpty,
        reason: 'il premio rifiutato risulta arrivato: nessuno lo cerchera '
            'piu, ed e perso per sempre');
  });

  test('il traguardo acceso senza premio resta fra quelli da riprendere',
      () async {
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final traguardo = Sentieri.tuttiITraguardi.first;
    await diario.accendi(traguardo.id);
    final gia = await LibroDegliAccrediti.accreditati();
    final persi = [
      for (final t in Sentieri.tuttiITraguardi)
        if (diario.eAcceso(t.id) && !gia.contains(t.id)) t,
    ];
    // ignore: avoid_print
    print('ORDINE AS VOCE 03: Sigilli accesi senza premio ${persi.length}');
    expect(persi.map((t) => t.id), contains(traguardo.id),
        reason:
            'un Sigillo acceso il cui premio non e mai arrivato non compare '
            'fra quelli da riprendere: la sincronia non lo cerchera');
  });

  test('il saldo del server vince su quello scritto sul disco', () async {
    // **LA SECONDA META' DELLA CURA.** Anche quando NESSUN premio si riprende,
    // il saldo mostrato non deve restare indietro rispetto a cio' che il
    // server sa: il benvenuto, l'accredito del giorno o una sessione su un
    // altro telefono possono averlo alzato.
    SharedPreferences.setMockInitialValues(const {'allowance.saldoEos': 40});
    final borsa = QuestionAllowance();
    await borsa.load();
    expect(borsa.saldoEos, 40);
    final stato = await porta.stato();
    expect(stato, isNotNull,
        reason: 'la porta che rifiuta i premi sa comunque dire il saldo: se '
            'non lo dicesse, questa prova girerebbe a vuoto');
    await borsa.applicaSaldo(stato!.saldoEos);
    // ignore: avoid_print
    print('ORDINE AS VOCE 03: saldo sul disco 40, saldo del server '
        '${stato.saldoEos}, saldo dopo ${borsa.saldoEos}');
    expect(borsa.saldoEos, stato.saldoEos,
        reason: 'il saldo mostrato non ha seguito quello del server');
  });

  test('la sincronia chiede il saldo anche quando non riprende niente', () {
    // **LA RIGA CHE MANCAVA, sorvegliata dove vive.** Qui c'era
    // `if (ripresi == 0) return;` PRIMA di chiedere lo stato: col server che
    // rifiuta tutti gli accrediti la sincronia usciva senza nemmeno domandare
    // quanto sapesse il server, e il numero in barra restava quello del disco.
    //
    // Si guarda il sorgente perche' il difetto e' un ORDINE di due istruzioni,
    // e un ordine sbagliato non si vede da fuori: si vedrebbe solo il giorno
    // in cui un saldo resta indietro, che e' esattamente com'e' andata.
    final sorgente = _sorgente('lib/features/sigilli/regia_del_cammino.dart');
    final doveStato =
        sorgente.indexOf('final statoNuovo = await porta.stato()');
    // **SI CERCA LA GRAFFA, non la sola condizione**: il commento che spiega
    // la cura CITA la riga vecchia `if (ripresi == 0) return;`, e cercando
    // solo la condizione si trovava il commento invece del codice. Una misura
    // che legge un commento e crede di leggere il codice e la stessa trappola
    // in cui questo repo e gia caduto con la saturazione degli Scaffold.
    final doveUscita = sorgente.indexOf('if (ripresi == 0) {');
    expect(doveStato, greaterThan(0));
    expect(doveUscita, greaterThan(0));
    expect(doveStato, lessThan(doveUscita),
        reason: 'la sincronia esce prima di chiedere il saldo al server: '
            'quando nessun premio si riprende, il numero in barra resta '
            'quello del disco e puo restare indietro per sempre');
  });
}

String _sorgente(String percorso) => File(percorso).readAsStringSync();

/// UNA PORTA CHE RISPONDE, E RISPONDE DI NO.
///
/// Non e' la porta spenta: quella non parla con nessuno. Questa e' il server
/// che c'e', sa dire il saldo, e RIFIUTA l'accredito perche' il motivo non e'
/// nel suo listino. E' il caso che l'ordine AS voce 03 sospetta per oggi, col
/// deploy delle funzioni ancora da fare.
class _PortaCheRifiutaIPremi extends PortaDelCerchio {
  const _PortaCheRifiutaIPremi();

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      const StatoDelCerchio(
        giorno: '2026-08-20',
        piano: 'free',
        spesi: {},
        saldoEos: 250,
      );

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
      // Il listino del server non conosce questo motivo: e' un errore, e un
      // errore torna come nulla, mai come un numero.
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
