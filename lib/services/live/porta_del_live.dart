import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart';

import '../../core/maestro/maestro.dart';
import '../ai/registro_dei_guasti.dart';

/// **LA PORTA DEL LIVE.** Ordine EG voci 01, 04 e 06.
///
/// **Qui non c'e' nessuna chiave, ed e' il punto.** Il telefono non conosce
/// ne' la chiave di Protoface ne' il segreto di LiveKit: chiede al server di
/// aprire una sessione, e il server gli restituisce **un gettone che vale per
/// una stanza sola**. Chi avesse il segreto potrebbe entrare in qualunque
/// stanza di chiunque, e per questo non scende mai quaggiu'.
///
/// **E il diritto lo decide il server, non lo schermo.** Il pulsante LIVE puo'
/// essere nascosto, disabilitato o rotto: se qualcuno chiamasse questa porta
/// lo stesso, `apriUnaSessioneLive` guarda l'abbonamento, l'interruttore dei
/// fondatori e i minuti rimasti, e risponde di no. Lo schermo e' una
/// cortesia, il cancello sta di la'.
class SessioneLive {
  const SessioneLive({
    required this.url,
    required this.gettone,
    required this.stanza,
    required this.sessione,
    required this.avatar,
    this.lavoratore = 'protoface-worker',
    required this.minutiRimasti,
    required this.durataMassimaSecondi,
    this.eFondatore = false,
  });

  /// **Il selettore delle voci si mostra solo ai fondatori.** Ordine EJ voce
  /// 02: lo dice il server, che conosce l'elenco; il telefono non decide.
  final bool eFondatore;

  /// L'indirizzo del server LiveKit a cui il telefono si collega.
  final String url;

  /// **Il gettone della persona, buono per questa stanza e basta.**
  final String gettone;

  /// La stanza, che porta il nome della sessione.
  final String stanza;

  /// L'identificativo della sessione di Protoface, per chiederne lo stato.
  final String sessione;

  /// L'avatar che parlera', cioe' il volto del Maestro.
  final String avatar;

  /// **A chi si manda la voce del Maestro.** L'identita' con cui il volto di
  /// Protoface sta nella stanza: la dichiara il server, che firma il suo
  /// gettone, e il telefono la usa come destinatario del flusso audio.
  final String lavoratore;

  /// Quanti minuti restano alla persona in questo mese.
  final int minutiRimasti;

  /// Quanto puo' durare al massimo questa sessione, in secondi.
  final int durataMassimaSecondi;

  static SessioneLive daMappa(Map<Object?, Object?> m) => SessioneLive(
        url: '${m['url'] ?? ''}',
        gettone: '${m['gettone'] ?? ''}',
        stanza: '${m['stanza'] ?? ''}',
        sessione: '${m['sessione'] ?? ''}',
        avatar: '${m['avatar'] ?? ''}',
        lavoratore: '${m['lavoratore'] ?? 'protoface-worker'}',
        minutiRimasti: (m['minutiRimasti'] as num?)?.toInt() ?? 0,
        durataMassimaSecondi:
            (m['durataMassimaSecondi'] as num?)?.toInt() ?? 20 * 60,
        eFondatore: m['eFondatore'] == true,
      );
}

/// Lo stato di una sessione, e cio' che e' costata davvero.
class StatoDelLive {
  const StatoDelLive({
    required this.stato,
    required this.secondiFatturati,
  });

  /// `queued` finche' il volto non e' arrivato, poi `running`.
  final String stato;

  /// **I secondi presi dai consumi, non stimati.** La voce 08 lo pretende.
  final int secondiFatturati;

  /// Vero quando il volto e' arrivato e la sessione e' viva.
  bool get ilVoltoEArrivato => stato == 'running' || stato == 'active';

  static StatoDelLive daMappa(Map<Object?, Object?> m) => StatoDelLive(
        stato: '${m['stato'] ?? 'queued'}',
        // **Il nome e' quello del server**, `secondiFatturabili`. La prima
        // stesura leggeva `secondiFatturati`, che il server non manda: il
        // consumo vero sarebbe arrivato sempre a zero.
        secondiFatturati: (m['secondiFatturabili'] as num?)?.toInt() ?? 0,
      );
}

/// Quando il LIVE non si apre, e **la ragione conta piu' del fatto**.
///
/// Le tre ragioni vogliono tre risposte diverse a video: chi non ha il diritto
/// va invitato, chi ha finito i minuti va salutato dal Maestro, e chi trova un
/// guasto va rimandato alla chat scritta senza perdere niente. Un errore solo
/// per tutte e tre porterebbe a un vicolo cieco, che `CLAUDE.md` vieta.
enum PerchePerILiveNonSiApre {
  /// L'account non ha diritto al LIVE, o non e' ancora aperto per lui.
  nonEPerTe,

  /// I minuti del mese sono finiti.
  minutiFiniti,

  /// Qualcosa non ha risposto: rete, Protoface, LiveKit.
  guasto,
}

class IlLiveNonSiApre implements Exception {
  const IlLiveNonSiApre(this.perche, [this.dettaglio]);
  final PerchePerILiveNonSiApre perche;
  final String? dettaglio;

  @override
  String toString() => 'IlLiveNonSiApre(${perche.name}, $dettaglio)';
}

/// **LA TRADUZIONE STA QUI, FUORI DAL `catch`, PER POTERLA MISURARE.**
///
/// Dentro il `catch` avrebbe voluto un `FirebaseFunctionsException` vero per
/// essere provata, e al banco non c'e' nessun progetto Firebase a cui
/// chiederlo: la prova avrebbe finito per misurare una finzione che passa
/// sempre dal ramo del guasto, cioe' avrebbe detto sempre di si' senza
/// guardare niente. Qui e' una funzione pura, e la prova le da' i codici veri
/// che il server sceglie.
PerchePerILiveNonSiApre perchePerIlCodice(String codice) => switch (codice) {
      'permission-denied' => PerchePerILiveNonSiApre.nonEPerTe,
      'resource-exhausted' => PerchePerILiveNonSiApre.minutiFiniti,
      _ => PerchePerILiveNonSiApre.guasto,
    };

abstract final class PortaDelLive {
  /// **Sostituibile nelle prove**, perche' il banco non ha ne' un account
  /// Firebase ne' un server LiveKit, e una prova che chiama la rete non prova
  /// niente di ripetibile.
  static Future<Map<Object?, Object?>> Function(
    String porta,
    Map<String, Object?> dati,
  ) chiama = _dallaCallable;

  static Future<Map<Object?, Object?>> _dallaCallable(
    String porta,
    Map<String, Object?> dati,
  ) async {
    final p = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable(porta,
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 30),
            ));
    final res = await p.call<Object?>(dati);
    return (res.data as Map?)?.cast<Object?, Object?>() ?? const {};
  }

  /// Apre una sessione LIVE con [maestro], o dice perche' non si puo'.
  static Future<SessioneLive> apri(Maestro maestro) async {
    try {
      final m = await chiama('apriUnaSessioneLive', {'maestro': maestro.name});
      return SessioneLive.daMappa(m);
    } on FirebaseFunctionsException catch (e) {
      // **Il codice lo sceglie il server apposta**, e qui si traduce invece di
      // mostrarlo: `permission-denied` quando il LIVE non e' per quell'account,
      // `resource-exhausted` quando i minuti sono finiti.
      throw IlLiveNonSiApre(perchePerIlCodice(e.code), e.message);
    } catch (e) {
      throw IlLiveNonSiApre(PerchePerILiveNonSiApre.guasto, '$e');
    }
  }

  /// **La stessa porta, a flusso.** Sostituibile nelle prove come [chiama].
  static Stream<Map<Object?, Object?>> Function(
    String porta,
    Map<String, Object?> dati,
  ) aFlusso = _dallaCallableAFlusso;

  static Stream<Map<Object?, Object?>> _dallaCallableAFlusso(
    String porta,
    Map<String, Object?> dati,
  ) async* {
    final p = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable(porta,
            options: HttpsCallableOptions(
              timeout: const Duration(seconds: 60),
            ));
    await for (final r in p.stream<Object?, Object?>(dati)) {
      if (r is Chunk<Object?, Object?>) {
        yield (r.partialData as Map?)?.cast<Object?, Object?>() ?? const {};
      }
    }
  }

  /// **LA VOCE DEL MAESTRO A FLUSSO.** Ordine EG voce 01, dopo la prima prova
  /// del fondatore del 23 settembre 2026: *"la risposta arriva molti secondi
  /// dopo"*.
  ///
  /// [voce] aspettava l'audio intero di una frase, da 4,4 a 11,7 secondi
  /// misurati; qui ogni pezzo arriva appena Gemini-TTS lo compone, il primo
  /// in meno di un secondo, e si puo' mandare al volto subito.
  static Stream<({Uint8List pcm, int tasso, int canali})> voceAFlusso(
    Maestro maestro,
    String testo,
  ) async* {
    await for (final m in aFlusso(
      'laVoceDelMaestro',
      {'maestro': maestro.name, 'testo': testo},
    )) {
      final audio = '${m['audio'] ?? ''}';
      if (audio.isEmpty) continue;
      yield (
        pcm: base64Decode(audio),
        tasso: (m['tasso'] as num?)?.toInt() ?? 24000,
        canali: (m['canali'] as num?)?.toInt() ?? 1,
      );
    }
  }

  /// **LE VOCI DI UN MAESTRO, per il selettore dei fondatori.** Ordine EJ
  /// voce 02: le candidate con la loro descrizione, la frase di prova e la
  /// voce scelta oggi.
  static Future<LeVociDelMaestro> leVoci(Maestro maestro) async {
    final m = await chiama('leVociDelMaestro', {'maestro': maestro.name});
    return LeVociDelMaestro(
      candidate: [
        for (final c in (m['candidate'] as List? ?? const []))
          (
            voce: '${(c as Map)['voce']}',
            descrizione: '${c['descrizione'] ?? ''}',
            // **Il nome e la famiglia**, ordine EM voce 02: una voce Chirp
            // si salva col suo prefisso e si mostra col suo nome. Un server
            // di prima non li manda, e il nome e' la voce stessa.
            nome: '${c['nome'] ?? c['voce']}',
            famiglia: '${c['famiglia'] ?? 'Gemini'}',
          ),
      ],
      scelta: '${m['scelta'] ?? ''}',
      frase: '${m['frase'] ?? ''}',
    );
  }

  /// La frase di prova detta da [voce], per ascoltarla.
  static Future<({Uint8List pcm, int tasso})> ascoltaUnaVoce(
      Maestro maestro, String voce) async {
    final m =
        await chiama('ascoltaUnaVoce', {'maestro': maestro.name, 'voce': voce});
    return (
      pcm: base64Decode('${m['audio'] ?? ''}'),
      tasso: (m['tasso'] as num?)?.toInt() ?? 24000,
    );
  }

  /// [voce] diventa la voce di [maestro], per tutti e senza build nuova.
  static Future<void> scegliLaVoce(Maestro maestro, String voce) =>
      chiama('scegliLaVoce', {'maestro': maestro.name, 'voce': voce});

  /// **LA SESSIONE DI PROTOFACE SI CHIUDE QUANDO SI ESCE.** Guasto trovato
  /// nell'ordine EK il 24 settembre 2026, padre l'ordine EG: uscendo si
  /// lasciava solo la stanza di LiveKit, e Protoface teneva accesa la sessione
  /// fino al silenzio tollerato, sessanta secondi. Sul registro del server 13
  /// secondi a video sono stati fatturati 70, due crediti. La chiusura la
  /// chiede il server, perche' la chiave di Protoface non esce da li'.
  ///
  /// **Non ferma niente se non risponde**: la persona sta gia' uscendo, e il
  /// silenzio tollerato resta la rete sotto. Ma non si tace: un guasto qui
  /// costa minuti, e deve potersi leggere.
  static Future<void> chiudi(String sessione) async {
    try {
      await chiama('chiudiLaSessioneLive', {'sessione': sessione});
    } catch (errore) {
      annotaGuastoInnocuo(
        'la sessione LIVE non si chiude dal telefono, sessione $sessione',
        errore,
      );
    }
  }

  /// Chiede se il volto e' arrivato, e quanto e' costata finora.
  static Future<StatoDelLive> stato(String sessione) async {
    try {
      final m = await chiama('statoDellaSessioneLive', {'sessione': sessione});
      return StatoDelLive.daMappa(m);
    } catch (errore) {
      // **Un guasto nel chiedere lo stato non spegne la sessione.** La
      // sessione vive su LiveKit, non qui: se questa domanda non risponde, si
      // dice soltanto che il volto non e' ancora arrivato.
      //
      // **Ma non si tace, ed e' la guardia dei catch muti ad averlo preteso.**
      // Il primo tentativo scriveva `catch (_)`: se il volto non fosse mai
      // arrivato, nessuno avrebbe potuto sapere se era Protoface a non
      // rispondere o la sessione a non partire, e sono due guasti diversi con
      // due cure diverse.
      annotaGuastoInnocuo(
        'lo stato della sessione LIVE non si legge, sessione $sessione',
        errore,
      );
      return const StatoDelLive(stato: 'queued', secondiFatturati: 0);
    }
  }
}

/// Le voci di un Maestro come le da' il server. Ordine EJ voce 02.
class LeVociDelMaestro {
  const LeVociDelMaestro({
    required this.candidate,
    required this.scelta,
    required this.frase,
  });

  final List<({String voce, String descrizione, String nome, String famiglia})>
      candidate;
  final String scelta;
  final String frase;
}
