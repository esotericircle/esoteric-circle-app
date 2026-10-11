/// LA REGOLA DEL TITOLO, IN UN PUNTO SOLO. Ordine FK, aggiunta voce A1, 11
/// ottobre 2026.
///
/// **LE PAROLE DEL FONDATORE, per intero**, perche' sono la regola e non un
/// suo riassunto:
///
/// 3 settembre 2026: *"le risposte devono partire con un titolo diretto che
/// riassume tutto, un titolo che a colpo d'occhio e' gia' una risposta diretta
/// e poi sotto la risposta vera. [...] quindi ogni risposta deve avere una
/// gerarchia a partire dal titolo."*
///
/// 11 settembre 2026: *"titolo accattivante che riassume la risposta, poi la
/// risposta descrittiva diretta e immediata, chiara e non criptica, divisa in
/// paragrafi."*
///
/// 11 ottobre 2026: *"non si parla di righe ma di paragrafi... ti avevo anche
/// indicato che ogni risposta doveva partire da un titolo."*
///
/// **PERCHE' QUESTO FILE ESISTE.** Fino all'ordine FK la regola era applicata
/// una funzione per volta: otto arti su dodici avevano un titolo, ognuna col
/// suo `Text` scritto a mano e in tre stili diversi; quattro non lo avevano
/// (archetipo, gettata delle rune, animale guida, Arcano dell'Alba). E' la
/// famiglia delle due porte: chi aggiunge un'arte nuova non trova la regola da
/// nessuna parte e se ne scrive una sua, oppure se ne dimentica.
///
/// **DOVE VIVE.** Il titolo di ogni responso si disegna con
/// `TitoloDelResponso` (`lib/design_system/components/titolo_del_responso.dart`),
/// direttamente o attraverso una delle [porte]. La guardia
/// `ogni_responso_parte_dal_titolo_test.dart` enumera
/// `ArtiConResponso.tutte` e cade col nome dell'arte che non passa da li'.
/// Il formato che segue il titolo (i paragrafi, il riquadro, il "da dove
/// viene") sta in `docs/responsi/il_titolo_e_il_formato.md`.
library;

class IlTitoloDelResponso {
  const IlTitoloDelResponso._();

  /// Le parole del fondatore, con la loro data: la guardia pretende che il
  /// documento in `docs/responsi` le porti uguali.
  static const Map<String, String> paroleDelFondatore = {
    '3 settembre 2026': 'le risposte devono partire con un titolo diretto che '
        'riassume tutto, un titolo che a colpo d\'occhio è già una risposta '
        'diretta e poi sotto la risposta vera.',
    '11 settembre 2026': 'titolo accattivante che riassume la risposta, poi la '
        'risposta descrittiva diretta e immediata, chiara e non criptica, '
        'divisa in paragrafi.',
    '11 ottobre 2026': 'ti avevo anche indicato che ogni risposta doveva '
        'partire da un titolo.',
  };

  /// Il nome del widget che disegna il titolo di ogni responso.
  static const String widget = 'TitoloDelResponso';

  /// **LE PORTE**: i componenti che disegnano un responso intero e che
  /// passano gia' dal titolo comune. Un'arte che usa una porta passa dal
  /// titolo attraverso di lei: la guardia pretende che ogni porta usi
  /// davvero [widget].
  static const Map<String, String> porte = {
    // L'Oroscopo: le schede del giorno vanno a capo fra le parole (ordine ER).
    'TitoloDellaSchedaDelGiorno':
        'lib/features/horoscope/titolo_della_scheda_del_giorno.dart',
    // Il Soffio del Destino: la carta del dono con la sua gerarchia.
    'RitualGiftCard': 'lib/features/rituals/ritual_gift_card.dart',
  };
}
