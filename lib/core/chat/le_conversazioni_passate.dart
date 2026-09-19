/// LE CONVERSAZIONI PASSATE, COL LORO TITOLO. Ordine DZ voci 03 e 04.
///
/// **Il fatto, dal fondatore**: *"sarebbe meglio che nel menu' a tendina
/// comparissero le ultime 5 conversazioni con il loro titolo. questo
/// significa che ad ogni nuova conversazione, il sistema deve creare un
/// titolo indicativo, esattamente come una chatbot"*.
///
/// **Le conversazioni non si inventano qui: ci sono gia'.** Dall'ordine CI
/// voce 06 ogni messaggio porta la sua conversazione, e si salva sul server
/// con lei. Questo file le raccoglie dai messaggi, le mette in ordine
/// dall'ultima parola detta, e da' a ognuna il suo titolo.
///
/// **Il titolo lo scrive Gemini** (decisione del fondatore del 18 settembre
/// 2026) e si tiene sul telefono, un archivio per Maestro. Finche' non c'e',
/// o se il modello non risponde, il titolo e' la prima domanda accorciata:
/// una conversazione senza nome nel menu' sarebbe una riga vuota.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../astro/data_italiana.dart';
import '../maestro/maestro.dart';
import 'chat_message.dart';

/// Una conversazione passata, come la mostra il menu'.
@immutable
class ConversazionePassata {
  const ConversazionePassata({
    required this.id,
    required this.titolo,
    required this.ultimoMomento,
    required this.primaDomanda,
  });

  /// La marcatura dei messaggi. Nulla e' la prima conversazione, quella
  /// dei messaggi scritti prima dell'ordine CI.
  final String? id;
  final String titolo;
  final DateTime? ultimoMomento;
  final String primaDomanda;
}

/// Chi scrive il titolo di una conversazione. In app e' Gemini; nelle prove
/// e' spento, e allora vale il titolo di ripiego.
abstract class ScrittoreDeiTitoli {
  const ScrittoreDeiTitoli();

  /// Un titolo di poche parole, o nullo se non e' riuscito.
  Future<String?> scrivi({
    required Maestro maestro,
    required String domanda,
    required String risposta,
  });
}

class ScrittoreDeiTitoliSpento extends ScrittoreDeiTitoli {
  const ScrittoreDeiTitoliSpento();

  @override
  Future<String?> scrivi({
    required Maestro maestro,
    required String domanda,
    required String risposta,
  }) async =>
      null;
}

abstract final class LeConversazioniPassate {
  /// Quante ne mostra il menu', come chiesto dal fondatore.
  static const int quante = 5;

  /// Quanti messaggi si leggono per trovarle. Cinque conversazioni di
  /// qualche turno stanno comodamente in centocinquanta messaggi; di piu'
  /// sarebbe pagare letture per conversazioni che il menu' non mostra.
  static const int messaggiDaLeggere = 150;

  /// La chiave di una conversazione nell'archivio dei titoli.
  static String chiave(String? id) => id ?? 'prima';

  static String _chiaveDellArchivio(Maestro maestro) =>
      'chat.titoli.${maestro.id}';

  /// **LE CONVERSAZIONI CANCELLATE DAL MENU'. Ordine EA voce 07.** Il
  /// telefono le ricorda finche' il server non le ha tolte davvero: senza,
  /// una conversazione cancellata tornerebbe alla prossima apertura.
  static String _chiaveDelleNascoste(Maestro maestro) =>
      'chat.cancellate.${maestro.id}';

  static Future<Set<String>> nascoste(Maestro maestro) async {
    try {
      final p = await SharedPreferences.getInstance();
      return {...?p.getStringList(_chiaveDelleNascoste(maestro))};
    } catch (errore) {
      debugPrint('Conversazioni: le cancellate non si leggono. $errore');
      return {};
    }
  }

  static Future<void> nascondi(Maestro maestro, String? id) async {
    try {
      final p = await SharedPreferences.getInstance();
      final tutte = await nascoste(maestro)
        ..add(chiave(id));
      await p.setStringList(_chiaveDelleNascoste(maestro), tutte.toList());
    } catch (errore) {
      debugPrint('Conversazioni: la cancellata non si ricorda. $errore');
    }
  }

  /// **IL TITOLO DI RIPIEGO**: la prima domanda, fino a sei parole e a
  /// quarantadue caratteri, con i puntini se e' stata tagliata.
  static String titoloDiRipiego(String domanda) {
    final pulita = domanda.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (pulita.isEmpty) return 'Conversazione';
    final parole = pulita.split(' ');
    var titolo = parole.take(6).join(' ');
    if (titolo.length > 42) titolo = titolo.substring(0, 42).trimRight();
    if (titolo.length >= pulita.length) return pulita;
    // Tagliata: via la punteggiatura rimasta in coda, poi i puntini.
    titolo = titolo.replaceAll(RegExp(r'[\s,;:.!?]+$'), '');
    return '$titolo…';
  }

  /// **IL TITOLO SCRITTO DAL MODELLO, ripulito.** Una riga sola, senza
  /// virgolette e senza punto finale, al massimo sessanta caratteri; se non
  /// resta niente, nullo, e vale il ripiego.
  static String? pulisci(String? scritto) {
    if (scritto == null) return null;
    var t = scritto.split('\n').first.trim();
    t = t.replaceAll(RegExp('^["\'«“”*]+|["\'»“”*]+\$'), '').trim();
    t = t.replaceAll(RegExp(r'[.]+$'), '').trim();
    if (t.isEmpty) return null;
    if (t.length > 60) t = '${t.substring(0, 60).trimRight()}…';
    return t;
  }

  static Future<Map<String, String>> titoli(Maestro maestro) async {
    try {
      final p = await SharedPreferences.getInstance();
      final grezzo = p.getString(_chiaveDellArchivio(maestro));
      if (grezzo == null) return {};
      final letto = jsonDecode(grezzo);
      if (letto is! Map) return {};
      return {
        for (final e in letto.entries) e.key.toString(): e.value.toString(),
      };
    } catch (errore) {
      debugPrint('Conversazioni: i titoli non si leggono. $errore');
      return {};
    }
  }

  static Future<void> salvaIlTitolo(
      Maestro maestro, String? id, String titolo) async {
    try {
      final p = await SharedPreferences.getInstance();
      final tutti = await titoli(maestro);
      tutti[chiave(id)] = titolo;
      await p.setString(_chiaveDellArchivio(maestro), jsonEncode(tutti));
    } catch (errore) {
      debugPrint('Conversazioni: il titolo non si salva. $errore');
    }
  }

  /// **LE ULTIME CONVERSAZIONI**, dalla piu' recente, senza quella aperta.
  ///
  /// I messaggi arrivano in ordine di lettura, dal piu' vecchio al piu'
  /// nuovo. Una conversazione senza nessuna domanda della persona non si
  /// mostra: non c'e' niente da riaprire.
  static List<ConversazionePassata> raccogli(
    List<ChatMessage> messaggi, {
    required Map<String, String> titoli,
    required String? corrente,
    Set<String> nascoste = const {},
    int quanteAlPiu = quante,
  }) {
    final prima = <String, String>{};
    final ultimo = <String, DateTime?>{};
    final ordine = <String>[];
    final ids = <String, String?>{};
    for (final m in messaggi) {
      final k = chiave(m.conversazione);
      ids[k] = m.conversazione;
      if (m.isUser && !prima.containsKey(k)) prima[k] = m.text;
      ultimo[k] = m.at ?? ultimo[k];
      ordine
        ..remove(k)
        ..add(k);
    }
    final fuori = <ConversazionePassata>[];
    for (final k in ordine.reversed) {
      if (k == chiave(corrente) || nascoste.contains(k)) continue;
      final domanda = prima[k];
      if (domanda == null) continue;
      fuori.add(ConversazionePassata(
        id: ids[k],
        titolo: titoli[k] ?? titoloDiRipiego(domanda),
        ultimoMomento: ultimo[k],
        primaDomanda: domanda,
      ));
      if (fuori.length >= quanteAlPiu) break;
    }
    return List.unmodifiable(fuori);
  }

  /// I messaggi di una conversazione sola, nell'ordine in cui sono arrivati.
  static List<ChatMessage> di(List<ChatMessage> messaggi, String? id) => [
        for (final m in messaggi)
          if (chiave(m.conversazione) == chiave(id)) m,
      ];

  /// **IL GIORNO, come lo dice il menu'**: oggi, ieri, oppure la data.
  static String quando(DateTime? momento, DateTime adesso) {
    if (momento == null) return '';
    final giorno = DateTime(momento.year, momento.month, momento.day);
    final oggi = DateTime(adesso.year, adesso.month, adesso.day);
    final distanza = oggi.difference(giorno).inDays;
    if (distanza <= 0) return 'Oggi';
    if (distanza == 1) return 'Ieri';
    return '${momento.day} ${mesiInItaliano[momento.month - 1]}';
  }
}
