import '../../core/cammino/cammino_da_custodire.dart';
import 'dart:math' as math;

import 'package:cloud_functions/cloud_functions.dart';

/// LO STATO DEL CERCHIO COME LO DICE IL SERVER.
///
/// Il giorno e' una stringa OPACA: il client non la ricalcola e non la
/// interpreta, la conserva e la confronta. E' cosi' che spostare l'orologio
/// del telefono smette di avere effetto sui contatori.
class StatoDelCerchio {
  const StatoDelCerchio({
    required this.giorno,
    required this.piano,
    required this.spesi,
    required this.saldoEos,
    this.cammino,
    this.listinoDellaCondivisione = const {},
  });

  final String giorno;
  final String piano;

  /// Quanto e' stato speso oggi, budget per budget, come lo conta il server.
  final Map<String, int> spesi;

  final int saldoEos;

  /// IL CAMMINO CUSTODITO, gia' fuso dal server. Nullo quando il server e'
  /// piu' vecchio dell'app e non lo conosce ancora: in quel caso il telefono
  /// tiene il suo e riprova alla prossima apertura, senza cancellare niente.
  final CamminoDaCustodire? cammino;

  /// **QUANTI EOS VALE OGNI MODO DI CONDIVIDERE.** Ordine BB voce 04.
  ///
  /// **E' un'informazione, non un'autorizzazione**: serve a scrivere sul
  /// pulsante quanto si guadagna, e il conto lo fa sempre il server, che dal
  /// motivo sa quanto vale. Un listino che arriva al telefono non e' un
  /// permesso di pagare.
  ///
  /// **Vuoto quando il server e' piu' vecchio dell'app**: allora il pulsante
  /// dice quando arriva il premio senza dire quanto, che e' cio' che diceva
  /// prima. **Mai un numero inventato dal client**: se il listino cambiasse
  /// sul server e il telefono continuasse a promettere il vecchio, la frase
  /// sarebbe una bugia scritta bene.
  final Map<String, int> listinoDellaCondivisione;

  static StatoDelCerchio? daMappa(Object? risposta) {
    if (risposta is! Map) return null;
    final giorno = risposta['giorno'];
    if (giorno is! String || giorno.isEmpty) return null;
    final spesi = <String, int>{};
    final grezzi = risposta['spesi'];
    if (grezzi is Map) {
      for (final voce in grezzi.entries) {
        final valore = voce.value;
        if (valore is num) spesi['${voce.key}'] = valore.toInt();
      }
    }
    final saldo = risposta['saldoEos'];
    final listino = <String, int>{};
    final grezzoListino = risposta['listinoDellaCondivisione'];
    if (grezzoListino is Map) {
      for (final voce in grezzoListino.entries) {
        final valore = voce.value;
        if (valore is num) listino['${voce.key}'] = valore.toInt();
      }
    }
    return StatoDelCerchio(
      giorno: giorno,
      piano: risposta['piano'] is String ? risposta['piano'] as String : 'free',
      spesi: spesi,
      saldoEos: saldo is num ? saldo.toInt() : 0,
      cammino: CamminoDaCustodire.daMappa(risposta['cammino']),
      listinoDellaCondivisione: listino,
    );
  }
}

/// L'esito di un consumo, come lo decide il server.
class EsitoDelConsumo {
  const EsitoDelConsumo({
    required this.concesso,
    this.resta,
    this.giorno,
    this.motivo,
  });

  final bool concesso;

  /// Quanto resta dopo, oppure nullo se quel budget non ha limite.
  final int? resta;
  final String? giorno;
  final String? motivo;
}

/// LA PORTA UNICA VERSO IL SERVER DEL CERCHIO, ordine N.
///
/// **Perche' una porta sola.** I contatori del giorno, il saldo Eos e la
/// memoria si scrivono in un posto solo, che e' il server: se le chiamate
/// nascessero sparse nelle schermate, prima o poi una scriverebbe dritto su
/// Firestore e il limite tornerebbe a essere decorativo. Qui c'e' l'unico
/// punto che conosce i nomi delle callable.
///
/// **E' astratta perche' le prove non devono toccare la rete**, e perche'
/// senza rete l'app deve restare intera: la porta spenta risponde "non lo so"
/// e chi la usa sa gia' cosa fare, invece di sollevare.
abstract class PortaDelCerchio {
  const PortaDelCerchio();

  /// Vero se questa porta puo' davvero parlare col server.
  bool get viva;

  /// Lo stato del giorno, oppure nullo se il server non risponde.
  /// Chiede lo stato intero del Cerchio, e gli porta il cammino del telefono.
  ///
  /// **Il cammino viaggia con lo stato, ordine AP voce 01**: il telefono
  /// manda cio' che ha, il server fonde col custodito e risponde con cio' che
  /// vale. Nessuna callable nuova, perche' `statoDelCerchio` e' gia' cio' che
  /// si chiede a ogni apertura, e un secondo canale sullo stesso momento
  /// sarebbe la seconda porta sullo stesso dato.
  /// **L'AZZERAMENTO VIAGGIA CON LA STESSA PORTA, ordine AR voce 06.** Il
  /// telefono non scrive su Firestore (premessa P4 dell'ordine AP), quindi
  /// dimenticare il cammino sul server e' una cosa che solo il server puo'
  /// fare: gli si dice qui, dentro la richiesta che gia' parte a ogni
  /// apertura, invece di aprire una seconda porta per una cosa sola.
  Future<StatoDelCerchio?> stato(
      {CamminoDaCustodire? cammino, bool azzeraIlCammino = false});

  /// Chiede di consumare un budget. Nullo se il server non risponde: chi
  /// chiama accoda e riprova, non inventa una risposta.
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  });

  /// Muove gli Eos. Torna il saldo nuovo, oppure nullo se non si e' potuto.
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  });

  /// Scrive un pezzo di memoria. Torna vero se il server ha scritto.
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  });

  /// Il diritto all'oblio: cancella dati e account. Vero se i dati non ci
  /// sono piu'.
  Future<bool> cancellaIlCerchio();

  /// UN IDENTIFICATIVO PER OGNI GESTO, e serve davvero.
  ///
  /// Senza rete il gesto si accoda e si rimanda dopo: se la risposta si
  /// perdesse e il client ritentasse, senza questo la persona pagherebbe due
  /// volte lo stesso gesto. Il server tiene il segno di ogni identificativo
  /// gia' visto e ripete la risposta di allora.
  static String nuovoIdentificativo(String cosa) {
    final quando = DateTime.now().microsecondsSinceEpoch;
    final caso = math.Random().nextInt(1 << 32);
    return '$cosa-$quando-$caso';
  }
}

/// La porta vera, sopra le callable in `europe-west1`.
class PortaVeraDelCerchio extends PortaDelCerchio {
  PortaVeraDelCerchio({FirebaseFunctions? funzioni})
      : _funzioni =
            funzioni ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _funzioni;

  @override
  bool get viva => true;

  Future<Object?> _chiama(String nome, Map<String, Object?> corpo) async {
    try {
      final esito = await _funzioni.httpsCallable(nome).call<Object?>(corpo);
      return esito.data;
    } on FirebaseFunctionsException catch (errore) {
      // SI DISTINGUE IL NO DAL NON LO SO, e non e' pignoleria: un rifiuto del
      // server e' una risposta e va rispettata, una rete assente non lo e'.
      // Chi chiama vede nullo in tutti e due i casi, ma il motivo del rifiuto
      // arriva col suo codice a chi lo vuole guardare.
      if (errore.code == 'unauthenticated' ||
          errore.code == 'permission-denied' ||
          errore.code == 'invalid-argument' ||
          errore.code == 'failed-precondition') {
        rethrow;
      }
      return null;
    } catch (errore) {
      // Si ignora, e il nulla che si torna E' la risposta: rete giu',
      // funzione non ancora distribuita, tempo scaduto. Chi chiama accoda e
      // riprova, e non deve distinguere fra questi casi perche' la condotta
      // e' la stessa.
      return null;
    }
  }

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa(await _chiama('statoDelCerchio', {
        // **L'AZZERAMENTO PARTE PRIMA DEL CAMMINO, e l'ordine dei due campi
        // non conta qui ma conta sul server**: e' il server a dimenticare
        // prima e a fondere poi, dentro la stessa transazione.
        if (azzeraIlCammino) 'azzeraIlCammino': true,
        if (cammino != null && !cammino.eVuoto) 'cammino': cammino.aMappa(),
      }));

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async {
    final risposta = await _chiama('consumaDelGiorno', {
      'budget': budget,
      'idMovimento': idMovimento,
    });
    if (risposta is! Map) return null;
    final resta = risposta['resta'];
    return EsitoDelConsumo(
      concesso: risposta['concesso'] == true,
      resta: resta is num ? resta.toInt() : null,
      giorno: risposta['giorno'] is String ? risposta['giorno'] as String : null,
      motivo: risposta['motivo'] is String ? risposta['motivo'] as String : null,
    );
  }

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    final risposta = await _chiama('muoviGliEos', {
      'causale': causale,
      'motivo': motivo,
      'idMovimento': idMovimento,
      if (quanti != null) 'quanti': quanti,
    });
    if (risposta is! Map) return null;
    final saldo = risposta['saldo'];
    return saldo is num ? saldo.toInt() : null;
  }

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async {
    final risposta = await _chiama('scriviLaMemoria', {
      'operazione': operazione,
      if (maestro != null) 'maestro': maestro,
      'campi': campi,
    });
    return risposta is Map && risposta['scritto'] == true;
  }

  @override
  Future<bool> cancellaIlCerchio() async {
    final risposta = await _chiama('cancellaIlCerchio', const {});
    return risposta is Map && risposta['datiCancellati'] == true;
  }
}

/// La porta spenta: non chiama niente e non fallisce mai.
///
/// E' il valore di difetto ovunque, cosi' nessuna prova tocca la rete per
/// sbaglio, ed e' anche cio' che l'app usa quando Firebase non e' partito:
/// senza server il Cerchio resta usabile, con le regole dichiarate accanto a
/// `QuestionAllowance`.
class PortaSpentaDelCerchio extends PortaDelCerchio {
  const PortaSpentaDelCerchio();

  @override
  bool get viva => false;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      null;

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async =>
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
