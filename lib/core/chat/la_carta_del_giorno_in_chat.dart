import '../rituals/arcano_dell_alba/responso_dell_alba.dart';

/// **LA CARTA DEL GIORNO, DETTA IN CHAT.** Ordine DS voce 08, 17 settembre
/// 2026, e ordine DT voce 25 dello stesso giorno.
///
/// Sulle catture di un fondatore, *"Carta del giorno"* chiesta due volte a
/// Medora: due risposte sul cielo, Saturno e la Luna, e **nessuna carta**. La
/// domanda arrivava nuda al modello, e il modello non ha una carta da dare:
/// ne avrebbe inventata una diversa a ogni domanda.
///
/// **La carta non la sceglie il modello, e nemmeno questa riga.** E' l'Arcano
/// dell'Alba di oggi per quella persona, col suo verso: la sola estrazione del
/// giorno, letta dal suo archivio. Fino all'ordine DT qui si calcolava una
/// carta per conto proprio, l'Arcano del Giorno, che era la stessa del Dono
/// solo perche' le due formule coincidevano; adesso la porta e' una.
///
/// **Se stamattina la carta non e' stata girata, non se ne estrae una
/// seconda**: la frase lo dice, e il pulsante sotto apre il dono dove la si
/// sceglie.
class LaCartaDelGiornoInChat {
  const LaCartaDelGiornoInChat._();

  static String invito(ResponsoDellAlba? diOggi) {
    if (diOggi == null) {
      return 'La tua carta di oggi è ancora coperta: la scegli tu, fra le '
          'carte dell\'Arcano dell\'Alba. Aprilo e girala.';
    }
    return 'La tua carta di oggi è ${ResponsoDellAlba.cartaColVerso(diOggi.stato)}, '
        '${diOggi.primo.substring(diOggi.primo.lastIndexOf(', ') + 2).replaceFirst(RegExp(r'[.]$'), '')}. '
        'Resta la stessa fino a domani. Aprila e rileggi il suo dono.';
  }
}
