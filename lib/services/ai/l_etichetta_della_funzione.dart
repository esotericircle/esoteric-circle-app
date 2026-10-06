import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// **L'ETICHETTA DELLA FUNZIONE SU OGNI CHIAMATA AL MODELLO.** Ordine EW,
/// voce EW.03, 2 ottobre 2026.
///
/// La stima dei costi dei 30 giorni non ha potuto dividere il costo di
/// Gemini fra le funzioni dell'app: le metriche di Vertex dicono il modello,
/// non chi lo chiama. Vertex AI accetta nel corpo di ogni richiesta un campo
/// `labels`, che il report Fatturazione e l'esportazione dei costi mostrano
/// accanto al costo; il passaggio di Firebase AI Logic lo accetta (provato
/// il 2 ottobre 2026, `docs/collaudo/EW/etichette.txt`).
///
/// La libreria `firebase_ai` non ha un parametro per le etichette, ma lascia
/// passare un client HTTP suo (`generativeModel(httpClient: ...)`): questo
/// client aggiunge `labels: {funzione: ...}` al corpo JSON di ogni richiesta
/// e non cambia nient'altro. Una richiesta che non e' JSON passa com'era.
class ClientConEtichetta extends http.BaseClient {
  ClientConEtichetta(this.funzione, {http.Client? interno})
      : assert(valida(funzione), 'etichetta non valida: $funzione'),
        _interno = interno ?? internoDeiBanchi ?? http.Client();

  /// **Solo per i banchi del costo** (`tool/il_banco_del_costo_*.dart`):
  /// il client che sta sotto ogni etichetta, per far girare sul PC le
  /// chiamate vere dell'app verso Vertex. Nell'app resta nullo.
  @visibleForTesting
  static http.Client? internoDeiBanchi;

  /// Il nome della funzione dell'app, uno di [LeFunzioniDelModello].
  final String funzione;
  final http.Client _interno;

  /// Le regole delle etichette di Google Cloud: lettere minuscole, cifre,
  /// trattino basso e trattino, al massimo 63 caratteri, prima una lettera.
  static bool valida(String e) =>
      RegExp(r'^[a-z][a-z0-9_-]{0,62}$').hasMatch(e);

  /// Il corpo con l'etichetta, o il corpo com'era se non e' un oggetto JSON.
  static String conEtichetta(String corpo, String funzione) {
    try {
      final j = jsonDecode(corpo);
      if (j is! Map<String, dynamic>) return corpo;
      final etichette = <String, dynamic>{
        if (j['labels'] is Map) ...(j['labels'] as Map).cast<String, dynamic>(),
        'funzione': funzione,
      };
      return jsonEncode({...j, 'labels': etichette});
    } on FormatException catch (errore) {
      // Un corpo che non e' JSON passa com'era: l'etichetta serve alla
      // fattura, mai a fermare una chiamata al modello.
      debugPrint('Etichetta non messa, corpo non JSON: $errore');
      return corpo;
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    if (request is! http.Request || request.method != 'POST') {
      return _interno.send(request);
    }
    final nuova = http.Request(request.method, request.url)
      ..headers.addAll(request.headers)
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection
      ..body = conEtichetta(request.body, funzione);
    return _interno.send(nuova);
  }

  @override
  void close() => _interno.close();
}

/// **I NOMI DELLE FUNZIONI**, uno per ogni chiamata al modello dell'elenco
/// della voce EW.01 (`docs/costi/le_chiamate_al_modello.md`). Sono i valori
/// che il report Fatturazione mostra sotto l'etichetta `funzione`.
abstract final class LeFunzioniDelModello {
  static const String chatRisposta = 'chat_risposta';
  static const String chatSeguito = 'chat_seguito';
  static const String chatLive = 'chat_live';

  /// La correzione corta di una risposta scartata da una rete, ordine EX
  /// voce 07.
  static const String chatCorrezione = 'chat_correzione';

  /// Il controllo della coerenza di una risposta coi punti fermi del
  /// consulto, ordine FE voci 10 e 17 (`LaReteDellaCoerenza`).
  static const String chatCoerenza = 'chat_coerenza';
  static const String interrogaBreve = 'interroga_breve';
  static const String interrogaProfonda = 'interroga_profonda';
  static const String interrogaSintesi = 'interroga_sintesi';
  static const String distillatoMemoria = 'distillato_memoria';
  static const String letturaRune = 'lettura_rune';
  static const String letturaTarocchi = 'lettura_tarocchi';
  static const String sigillo = 'sigillo';
  static const String viaggioScena = 'viaggio_scena';
  static const String viaggioDomanda = 'viaggio_domanda';
  static const String viaggioSegno = 'viaggio_segno';
  static const String titoliConversazioni = 'titoli_conversazioni';
  static const String ricordiDelMese = 'ricordi_del_mese';
  static const String ascoltoLive = 'ascolto_live';

  static const List<String> tutte = [
    chatRisposta,
    chatSeguito,
    chatLive,
    chatCorrezione,
    chatCoerenza,
    interrogaBreve,
    interrogaProfonda,
    interrogaSintesi,
    distillatoMemoria,
    letturaRune,
    letturaTarocchi,
    sigillo,
    viaggioScena,
    viaggioDomanda,
    viaggioSegno,
    titoliConversazioni,
    ricordiDelMese,
    ascoltoLive,
  ];
}
