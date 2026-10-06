/// LE CONVERSAZIONI PASSATE, COL LORO TITOLO. Ordine DZ voci 03 e 04.
///
/// **Il fatto, dal fondatore**: *"sarebbe meglio che nel menu' a tendina
/// comparissero le ultime 5 conversazioni con il loro titolo. questo
/// significa che ad ogni nuova conversazione, il sistema deve creare un
/// titolo indicativo, esattamente come una chatbot"*.
///
/// **Le conversazioni non si inventano qui: ci sono gia'.** Dall'ordine CI
/// voce 06 ogni messaggio porta la sua conversazione, e si salva sul server
/// con lei. Questo file tiene la forma che il menu' mostra, il titolo
/// accorciato, il giorno e le conversazioni cancellate.
///
/// **L'ELENCO E IL TITOLO VENGONO DAL DIARIO COSMICO, dall'ordine FE voce
/// 22.** Il menu' e il Diario leggono la stessa porta
/// (`RegistroDeiRicordi.conversazioniDi`, FE.22.16), e il titolo e' quello
/// del Diario: il tema del consulto, cioe' la domanda con cui comincia
/// (FE.22.14), accorciato qui per stare nel menu'. Fino all'ordine FE
/// l'elenco si raccoglieva dai messaggi recenti e il titolo lo scriveva
/// Gemini (ordine DZ voce 04, decisione del 18 settembre 2026); la voce
/// 22.14 ha deciso diversamente. Le chiavi `chat.titoli.` dei telefoni di
/// prima restano conosciute dalla cancellazione e dallo scarico dei dati.
library;

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

abstract final class LeConversazioniPassate {
  /// Quante ne mostra il menu', come chiesto dal fondatore.
  static const int quante = 5;

  /// Quanti messaggi si leggono per trovarle. Cinque conversazioni di
  /// qualche turno stanno comodamente in centocinquanta messaggi; di piu'
  /// sarebbe pagare letture per conversazioni che il menu' non mostra.
  static const int messaggiDaLeggere = 150;

  /// La chiave di una conversazione nell'archivio dei titoli.
  static String chiave(String? id) => id ?? 'prima';

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
