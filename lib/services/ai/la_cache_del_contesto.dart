import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;

import '../../core/chat/chat_message.dart';
import '../../core/maestro/il_seguito_nascosto.dart';
import '../../core/maestro/maestro.dart';
import 'maestro_persona.dart';

/// **LA CACHE DEL CONTESTO, VISTA DAL TELEFONO.** Ordine EX Aggiunta 4, voce
/// EX.05, 2 ottobre 2026.
///
/// Il fondatore: *"una cache garantita che si accende sopra la soglia e si
/// spegne sotto, senza costi fissi quando non serve"*. La accende e la spegne
/// la funzione del server `laCacheDelContesto`
/// (`functions/src/la_cache_del_contesto.ts`), che ogni dieci minuti conta le
/// richieste dell'ultima ora: sopra la soglia crea su Vertex una cache per
/// ogni variante (la parte comune dell'istruzione,
/// [MaestroPersona.parteComune]) e scrive i loro nomi in
/// `configurazione/cache`; sotto la soglia le lascia scadere.
///
/// Il telefono legge quel documento e, quando la cache della sua variante
/// c'e' ed e' viva, chiede la risposta dal template di Firebase AI Logic
/// [template], che porta il nome della cache: l'istruzione comune la mette
/// la cache, e la richiesta porta solo la parte della persona, la
/// conversazione e la domanda ([richiesta]). **I template non portano ne' la
/// conversazione ne' le funzioni** (documentazione di Firebase AI Logic,
/// *"Server prompt templates do not yet support function calling (or
/// chat)"*): la conversazione entra come testo, il cielo di oggi e dei
/// giorni nominati entra gia' calcolato, e una domanda che chiede il cielo di
/// un periodo resta sulla via di sempre. Se qualcosa non va, la via di sempre
/// risponde: la cache non e' mai la sola strada.
abstract final class LaCacheDelContesto {
  /// Il documento scritto dalla funzione e letto dal telefono.
  static const String documento = 'configurazione/cache';

  /// Il template di Firebase AI Logic che il fondatore crea nella console:
  /// `{{cachedContent name=cache}}`, poi `{{role "user"}}` e `{{richiesta}}`.
  static const String template = 'maestro-con-la-cache';

  /// Il modello della cache: la risposta della chat a ogni livello.
  static const String modello = 'gemini-2.5-flash';

  /// **L'INTERRUTTORE DELL'APP, SPENTO.** Ordine EX Aggiunta 4, voce EX.05:
  /// alla lettura alla cieca la via della cache sbagliava il cielo (7 su 10
  /// contro 10 su 10) e scriveva un seguito piu' generico, e per la regola
  /// NESSUNA RISPOSTA PEGGIORA non si accende. Spento, il telefono non legge
  /// nemmeno `configurazione/cache` (che le regole di Firestore oggi non
  /// lasciano leggere): nessuna attesa in piu' sulla risposta. Si accende
  /// insieme alla funzione del server, quando la via della cache regge.
  static const bool accesaNellApp = false;

  /// **NEL BANCO**, la richiesta della cache va a Vertex senza cache, per
  /// misurarne il merito (vedi `FirebaseMaestroAiProvider`).
  static bool simulataNelBanco = false;

  /// Le risposte arrivate dalla cache, da quando l'app e' aperta.
  static int risposteDallaCache = 0;

  /// Il nome della variante: il Maestro, e la chat col seguito o senza.
  static String variante(Maestro maestro, {required bool conSeguito}) =>
      '${maestro.id}_${conSeguito ? 'chat_seguito' : 'chat'}';

  /// La parte comune di ogni variante: e' cio' che la funzione mette in
  /// cache, dal file `functions/src/la_cache_prefissi.json` scritto da
  /// `tool/i_prefissi_della_cache.dart`.
  static Map<String, String> prefissi() => {
        for (final m in Maestro.values)
          for (final conSeguito in const [false, true])
            variante(m, conSeguito: conSeguito):
                MaestroPersona.parteComune(maestro: m, conSeguito: conSeguito),
      };

  /// **L'IMPRONTA DEI PREFISSI**: la funzione la scrive accanto ai nomi, e
  /// il telefono usa la cache solo se e' uguale alla sua. Un'app di un'altra
  /// versione, con un'istruzione diversa, resta sulla via di sempre. FNV-1a a
  /// 64 bit sul JSON dei prefissi, in esadecimale.
  static String impronta() {
    final byte = utf8.encode(jsonEncode(prefissi()));
    var h = BigInt.parse('cbf29ce484222325', radix: 16);
    final primo = BigInt.parse('100000001b3', radix: 16);
    final maschera = (BigInt.one << 64) - BigInt.one;
    for (final b in byte) {
      h = ((h ^ BigInt.from(b)) * primo) & maschera;
    }
    return h.toRadixString(16).padLeft(16, '0');
  }

  static String? _improntaCalcolata;
  static String get _laMiaImpronta => _improntaCalcolata ??= impronta();

  /// Lo stato letto dal documento, al massimo ogni cinque minuti.
  static ({DateTime letto, Map<String, Object?> dati})? _ultimo;

  /// Solo per le prove: lo stato al posto del documento.
  @visibleForTesting
  static Map<String, Object?>? statoDiProva;

  @visibleForTesting
  static void dimentica() => _ultimo = null;

  /// Il nome della cache viva per [variante], o null: spenta, scaduta fra
  /// meno di un minuto, d'un'altra impronta, o documento che non si legge.
  static Future<String?> nomePer(String variante, {DateTime? adesso}) async {
    if (statoDiProva == null && !accesaNellApp) return null;
    final ora = adesso ?? DateTime.now();
    Map<String, Object?> dati;
    try {
      dati = statoDiProva ??
          (_ultimo != null &&
                  ora.difference(_ultimo!.letto) < const Duration(minutes: 5)
              ? _ultimo!.dati
              : await _leggi(ora));
    } catch (errore) {
      debugPrint('Cache del contesto: stato non letto, via di sempre: '
          '$errore');
      return null;
    }
    if (dati['accesa'] != true) return null;
    if (dati['impronta'] != _laMiaImpronta) return null;
    final scade = DateTime.tryParse('${dati['scade']}');
    if (scade == null ||
        scade.isBefore(ora.toUtc().add(const Duration(minutes: 1)))) {
      return null;
    }
    final cache = dati['cache'];
    if (cache is! Map) return null;
    final nome = cache[variante];
    return nome is String && nome.isNotEmpty ? nome : null;
  }

  static Future<Map<String, Object?>> _leggi(DateTime ora) async {
    final d = await FirebaseFirestore.instance.doc(documento).get();
    final dati = d.data() ?? const <String, Object?>{};
    _ultimo = (letto: ora, dati: dati);
    return dati;
  }

  /// **LA RICHIESTA CHE ACCOMPAGNA LA CACHE**: la parte dell'istruzione che
  /// e' della persona e del turno, il cielo di oggi, la conversazione fino a
  /// qui come testo, e la domanda.
  static String richiesta({
    required String parteDellaPersona,
    required String cieloDiOggi,
    required List<ChatMessage> storia,
    required String domanda,
  }) {
    // **IL SEGUITO PER ULTIMO, COME NELLA VIA DI SEMPRE.** Ordine EX
    // Aggiunta 4, voce EX.05: alla lettura alla cieca del giro ex05a il
    // seguito scritto per la via della cache era piu' generico (12 e 14 su
    // 24 contro 15 e 18): l'istruzione del seguito, che nella via di sempre
    // e' l'ultima cosa che il modello legge, qui stava prima della
    // conversazione e della domanda. Va dopo la domanda.
    var persona = parteDellaPersona.trim();
    final seguito = persona.endsWith(IlSeguitoNascosto.istruzione)
        ? IlSeguitoNascosto.istruzione
        : null;
    if (seguito != null) {
      persona =
          persona.substring(0, persona.length - seguito.length).trimRight();
    }
    final righe = <String>[
      persona,
      if (cieloDiOggi.trim().isNotEmpty) ...['', cieloDiOggi.trim()],
      if (storia.isNotEmpty) ...[
        '',
        'LA CONVERSAZIONE FINO A QUI, dal più vecchio:',
        for (final m in storia)
          '${m.isUser ? 'La persona' : 'Tu'}: ${m.text.trim()}',
      ],
      '',
      'LA PERSONA TI SCRIVE ADESSO:',
      domanda.trim(),
      if (seguito != null) ...['', seguito],
    ];
    return righe.join('\n');
  }
}
