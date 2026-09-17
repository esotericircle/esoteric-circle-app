import '../rituals/arcano_del_giorno.dart';

/// **LA CARTA DEL GIORNO, DETTA IN CHAT.** Ordine DS voce 08, 17 settembre
/// 2026.
///
/// Sulle catture di un fondatore, *"Carta del giorno"* chiesta due volte a
/// Medora: due risposte sul cielo, Saturno e la Luna, e **nessuna carta**. La
/// domanda arrivava nuda al modello, e il modello non ha una carta da dare:
/// ne avrebbe inventata una diversa a ogni domanda.
///
/// **La carta non la sceglie il modello.** E' l'Arcano del Giorno, che nasce
/// dal giorno e dalla nascita ed e' la stessa carta che il Dono mostra: chi la
/// chiede in chat e poi apre il Dono trova la stessa lama. La frase la compone
/// il codice col nome e col sommario che il corpus dei tarocchi ha gia'
/// scritto, e il pulsante sotto apre la carta per intero.
class LaCartaDelGiornoInChat {
  const LaCartaDelGiornoInChat._();

  static String invito(DateTime giorno, {DateTime? nascita}) {
    final carta = ArcanoDelGiorno.di(giorno, nascita: nascita);
    return 'La tua carta di oggi è ${carta.name}: '
        '${_minuscola(carta.uprightSummary)} '
        'Resta la stessa fino a domani. Aprila e guardala per intero.';
  }

  static String _minuscola(String frase) =>
      frase.isEmpty ? frase : frase[0].toLowerCase() + frase.substring(1);
}
