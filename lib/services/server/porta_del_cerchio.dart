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
    this.listinoDelRiscatto = const {},
    this.premioDellaRegistrazione,
    this.cerchioNuovo,
    this.accreditati = const [],
    this.invitiAccolti = 0,
    this.invitiPerMaestro = const {},
    this.correzioniDeiVip = const {},
    this.premioDellInvitoAccolto,
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

  /// **COSA E' STATO ACCREDITATO IN QUESTA CHIAMATA**, col motivo del
  /// server. Ordine BF voce 01: il fondatore ha letto la dote di nascita
  /// (250 di benvenuto piu' 20 del giorno) come il borsellino vecchio che
  /// tornava dopo la cancellazione, perche' il saldo non raccontava da dove
  /// veniva. Il Custode scrive queste voci nel registro dei movimenti con
  /// parole di persona, e il borsellino mostra la storia. Vuoto quando il
  /// server non ha accreditato niente, o e' piu' vecchio dell'app.
  final List<AccreditoDellaDote> accreditati;

  /// **QUANTI INVITI SONO STATI ACCOLTI. Ordine BX voce 02.**
  ///
  /// Tre voci del cammino chiedono che qualcuno accetti il tuo invito ed entri
  /// nel Cerchio, e il telefono non lo puo' sapere: lo sa solo il server,
  /// quando la persona invitata riscatta il codice. **Zero quando il server e'
  /// piu' vecchio dell'app**, che e' esattamente cio' che era vero prima.
  final int invitiAccolti;

  /// **DA QUALE PORTA SONO ENTRATI.** Ordine BX voce 02: il corpus ha tre
  /// voci, una per Maestro, e senza la porta misurerebbero lo stesso fatto.
  final Map<String, int> invitiPerMaestro;

  /// **QUANTO VALE UN INVITO ACCOLTO, dal listino del server.** Ordine BX:
  /// da quando il premio non si paga piu' alla condivisione (voce BX.02) il
  /// numero non stava piu' nel listino della condivisione, e la riga sotto il
  /// pulsante restava senza cifra. Nullo con un server piu' vecchio dell'app,
  /// e allora la riga dice quando arriva senza dire quanto.
  final int? premioDellInvitoAccolto;

  /// **LO STATO IN VITA CORRETTO DAL SERVER. Ordine BX voce 09.**
  ///
  /// Il catalogo dei VIP e' una costante compilata dentro l'app: senza questo
  /// canale, il giorno che una persona famosa muore l'app continua a
  /// proporre la possibilita' di incontrarla finche' non esce una versione
  /// nuova sugli store. Vuota quasi sempre, e vuota anche con un server piu'
  /// vecchio dell'app: allora vale il catalogo compilato, che e' cio' che era
  /// vero prima.
  final Map<String, String> correzioniDeiVip;

  /// **QUANTO COSTA RISCATTARE UN USO DI UN BUDGET FINITO.** Ordine BG voce
  /// 05: il prezzo lo decide il server, il client lo mostra sul pulsante e
  /// non lo detta mai. Vuoto se il server e' piu' vecchio dell'app.
  final Map<String, int> listinoDelRiscatto;

  /// Il premio della prima registrazione (ordine BH voce 01), dal listino
  /// del server: il client lo scrive negli inviti senza cablarlo. Nullo se
  /// il server non ha parlato.
  final int? premioDellaRegistrazione;

  /// Vero se il borsellino non esisteva prima di questa chiamata: il
  /// segnale di nascita robusto (BH.01), che non dipende dal benvenuto
  /// perche' la lapide antifrode puo' fermarlo su un Cerchio nuovo.
  /// Nullo con un server che non lo dichiara.
  final bool? cerchioNuovo;

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
    final riscatto = <String, int>{};
    final grezzoRiscatto = risposta['listinoDelRiscatto'];
    if (grezzoRiscatto is Map) {
      for (final voce in grezzoRiscatto.entries) {
        final valore = voce.value;
        if (valore is num) riscatto['${voce.key}'] = valore.toInt();
      }
    }
    int? premioRegistrazione;
    final grezzaRegistrazione = risposta['listinoDellaRegistrazione'];
    if (grezzaRegistrazione is Map) {
      final valore = grezzaRegistrazione['benvenuto'];
      if (valore is num) premioRegistrazione = valore.toInt();
    }
    final accreditati = <AccreditoDellaDote>[];
    final grezzoAccrediti = risposta['accreditati'];
    if (grezzoAccrediti is List) {
      for (final voce in grezzoAccrediti) {
        final letto = AccreditoDellaDote.daMappa(voce);
        if (letto != null) accreditati.add(letto);
      }
    }
    return StatoDelCerchio(
      giorno: giorno,
      piano: risposta['piano'] is String ? risposta['piano'] as String : 'free',
      spesi: spesi,
      saldoEos: saldo is num ? saldo.toInt() : 0,
      cammino: CamminoDaCustodire.daMappa(risposta['cammino']),
      listinoDellaCondivisione: listino,
      listinoDelRiscatto: riscatto,
      premioDellaRegistrazione: premioRegistrazione,
      cerchioNuovo:
          risposta['cerchioNuovo'] is bool ? risposta['cerchioNuovo'] as bool : null,
      accreditati: accreditati,
      invitiAccolti: risposta['invitiAccolti'] is num
          ? (risposta['invitiAccolti'] as num).toInt()
          : 0,
      invitiPerMaestro: {
        if (risposta['invitiPerMaestro'] is Map)
          for (final voce
              in (risposta['invitiPerMaestro'] as Map).entries)
            if (voce.value is num) '${voce.key}': (voce.value as num).toInt(),
      },
      premioDellInvitoAccolto: risposta['premioDellInvitoAccolto'] is num
          ? (risposta['premioDellInvitoAccolto'] as num).toInt()
          : null,
      correzioniDeiVip: {
        if (risposta['correzioniDeiVip'] is Map)
          for (final voce in (risposta['correzioniDeiVip'] as Map).entries)
            if (voce.value is String) '${voce.key}': voce.value as String,
      },
    );
  }
}

/// UN ACCREDITO COMPIUTO DAL SERVER, col suo motivo. Ordine BF voce 01.
///
/// Il motivo e' quello del server ('benvenuto', 'accredito_del_giorno'): la
/// traduzione in parole di persona sta in chi scrive il registro, non qui,
/// perche' questa classe riporta cio' che il Cerchio ha detto e basta.
class AccreditoDellaDote {
  const AccreditoDellaDote({required this.motivo, required this.quanti});

  final String motivo;
  final int quanti;

  static AccreditoDellaDote? daMappa(Object? grezzo) {
    if (grezzo is! Map) return null;
    final motivo = grezzo['motivo'];
    final quanti = grezzo['quanti'];
    if (motivo is! String || motivo.isEmpty || quanti is! num) return null;
    return AccreditoDellaDote(motivo: motivo, quanti: quanti.toInt());
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
  /// **RISCATTA UN INVITO. Ordine BX voce 02.**
  ///
  /// Chi arriva nel Cerchio con un codice lo consegna qui, una volta sola: il
  /// server segna da chi e' arrivato, incrementa il conto degli inviti accolti
  /// di chi ha invitato e gli accredita il premio. **Torna vero solo se
  /// l'invito e' stato accolto davvero**: un codice gia' usato, o il proprio,
  /// tornano falso senza rompere niente.
  Future<bool> riscattaLInvito(String codice) async => false;

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

  /// **AZZERA I DATI TENENDO L'ACCOUNT, sul server.** Ordine BE voce 07,
  /// punto 3: la voce "cancella i tuoi dati" puliva solo il telefono, il
  /// ramo sul server restava e al ritorno dell'identita' rendeva tutto.
  ///
  /// **I trenta giorni non esistono piu'** (decisione del fondatore che
  /// sostituisce BC.02): chiediLOblio e annullaLOblio sono stati RIMOSSI, e
  /// la cancellazione dell'account passa da `cancellaIlCerchio`, immediata.
  ///
  /// Il difetto e' prudente come per le sorelle: falso, cioe' niente
  /// azzerato, e chi chiama lo dice invece di fingere.
  Future<bool> azzeraIDati() async => false;

  /// LE CANCELLAZIONI COL PERCHE', ordine BH voce 06. Il congedo e'
  /// facoltativo e anonimo (il server lo scrive senza uid ne' email, prima
  /// di cancellare): qui i due passaggi con la ragione, con un difetto che
  /// delega alle porte senza perche' cosi' nessuna porta finta si rompe.
  Future<bool> cancellaIlCerchioDicendo(String? perche) =>
      cancellaIlCerchio();

  Future<bool> azzeraIDatiDicendo(String? perche) => azzeraIDati();

  /// LA SONDA DELL'INGRESSO, ordine BI voce 01: il server dice se una email
  /// ha gia' un Cerchio e con quali vie. Nulla quando il server non
  /// risponde: la porta allora offre le vie senza promettere niente.
  Future<EsitoDellaSonda?> esiste(String email) async => null;

  /// IL SECONDO FATTORE, ordine BI voce 04: manda il codice di sei cifre
  /// all'email dell'account, o lo verifica. Nullo quando il server non
  /// risponde; mandato:false col motivo quando il mittente non e'
  /// configurato (il client allora ripiega sul collegamento di Firebase).
  Future<EsitoDelSecondoFattore?> secondoFattore({
    required String operazione,
    String? codice,
  }) async =>
      null;

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
  Future<bool> riscattaLInvito(String codice) async {
    // **IL CODICE VA AL SERVER E BASTA.** Qui non si decide niente: chi ha
    // invitato, se il codice vale, se e' gia' stato usato e quanto vale il
    // premio lo sa solo il ramo di chi ha invitato, che il telefono non puo'
    // nemmeno leggere.
    final risposta = await _chiama('riscattaLInvito', {'codice': codice});
    if (risposta is! Map) return false;
    return risposta['accolto'] == true;
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

  @override
  Future<bool> azzeraIDati() async {
    final risposta = await _chiama('azzeraIDatiDelCerchio', const {});
    return risposta is Map && risposta['datiAzzerati'] == true;
  }

  @override
  Future<EsitoDellaSonda?> esiste(String email) async {
    final risposta = await _chiama('esisteIlCerchio', {'email': email});
    if (risposta is! Map) return null;
    final vie = <String>[];
    final grezze = risposta['vie'];
    if (grezze is List) {
      for (final via in grezze) {
        if (via is String) vie.add(via);
      }
    }
    return EsitoDellaSonda(
      esiste: risposta['esiste'] == true,
      vie: vie,
    );
  }

  @override
  Future<EsitoDelSecondoFattore?> secondoFattore({
    required String operazione,
    String? codice,
  }) async {
    final risposta = await _chiama('secondoFattore', {
      'operazione': operazione,
      if (codice != null) 'codice': codice,
    });
    if (risposta is! Map) return null;
    return EsitoDelSecondoFattore(
      mandato: risposta['mandato'] == true,
      verificato: risposta['verificato'] == true,
      motivo: risposta['motivo'] is String ? risposta['motivo'] as String : null,
    );
  }

  @override
  Future<bool> cancellaIlCerchioDicendo(String? perche) async {
    final risposta = await _chiama('cancellaIlCerchio', {
      if (perche != null && perche.trim().isNotEmpty) 'ragione': perche,
    });
    return risposta is Map && risposta['datiCancellati'] == true;
  }

  @override
  Future<bool> azzeraIDatiDicendo(String? perche) async {
    final risposta = await _chiama('azzeraIDatiDelCerchio', {
      if (perche != null && perche.trim().isNotEmpty) 'ragione': perche,
    });
    return risposta is Map && risposta['datiAzzerati'] == true;
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


/// La risposta della sonda dell'ingresso (BI.01): l'email ha un Cerchio?
/// E con quali vie (google.com, apple.com, password)?
class EsitoDellaSonda {
  const EsitoDellaSonda({required this.esiste, required this.vie});

  final bool esiste;
  final List<String> vie;
}


/// La risposta del secondo fattore (BI.04).
class EsitoDelSecondoFattore {
  const EsitoDelSecondoFattore({
    required this.mandato,
    required this.verificato,
    this.motivo,
  });

  final bool mandato;
  final bool verificato;

  /// Il perche' di un no: mittente_non_configurato, sbagliato, scaduto,
  /// esaurito, assente.
  final String? motivo;
}
