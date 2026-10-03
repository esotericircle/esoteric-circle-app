/// IL CANCELLO DELLE PUSH E IL MESE DI PROVA. Ordine CG voce 16.
///
/// **Parole del fondatore, 31 agosto 2026**: "vorrei che le notifiche push
/// siano un'esperienza premium solo per abbonati, ma disponibile trial per un
/// mese anche ai free a partire dalla loro prima installazione." E, alla
/// domanda su quale dei due momenti: "prima installazione o prima
/// registrazione? fai decidere a code."
///
/// **LA DECISIONE PRESA PER DELEGA: DALLA PRIMA REGISTRAZIONE**, e sono tre
/// ragioni.
///
/// 1. **Una prova legata all'installazione non si conta una volta sola.**
///    Reinstallare l'app azzera tutto cio' che vive sul telefono, quindi il
///    mese ripartirebbe a ogni reinstallazione: chi conosce il trucco non
///    finirebbe mai la prova, e il fondatore stesso reinstalla continuamente
///    per collaudare. L'ordine chiede "una sola volta nella vita del
///    Cerchio", e l'installazione quella vita non la sa contare.
/// 2. **La registrazione e' il primo momento in cui il Cerchio ha
///    un'identita' stabile**, ed e' la stessa su cui la lapide del benvenuto
///    gia' fa valere un regalo una volta sola. Due modi di dire "questa
///    persona l'abbiamo gia' vista" sarebbero due conti diversi della stessa
///    cosa, che e' la famiglia di difetti piu' numerosa di questo progetto.
/// 3. **Chi non si e' ancora registrato non resta senza niente**: le chiamate
///    locali restano accese e gratuite per tutti, e sono esattamente quelle
///    che riceve oggi. La prova non toglie, aggiunge.
library;

import '../entitlement/tier.dart';

/// Chi ha diritto alle push, e perche'.
enum DirittoAllePush {
  /// Ha un piano a pagamento.
  abbonato,

  /// Non paga, ma e' dentro il mese di prova.
  inProva,

  /// Non paga e la prova e' finita, oppure non si e' mai registrato.
  ///
  /// **Non resta senza niente**: le chiamate locali sono accese e gratuite
  /// per tutti, e sono quelle che riceve oggi.
  soloChiamateLocali,
}

class ProvaDellePush {
  const ProvaDellePush._();

  /// **QUANTO DURA LA PROVA**, in giorni.
  ///
  /// Trenta, cioe' il mese che il fondatore ha chiesto. Trenta e non
  /// "un mese di calendario" perche' un mese di calendario dura fra ventotto
  /// e trentun giorni, e chi si registra il primo febbraio avrebbe due giorni
  /// meno di chi si registra il primo marzo.
  static const int giorniDiProva = 30;

  /// **IL PIANO MINIMO PER LE PUSH SENZA PROVA.**
  ///
  /// Il primo piano a pagamento, cioe' l'Iniziato. "Premium, dal primo piano
  /// a pagamento in su" sono parole dell'ordine.
  static const Tier pianoMinimo = Tier.tier1;

  /// Che diritto ha questa persona, adesso.
  ///
  /// [registratoIl] e' il momento della PRIMA registrazione, cioe' quando il
  /// Cerchio ha smesso di essere anonimo. Nullo per chi non si e' mai
  /// registrato, e in quel caso la prova non e' nemmeno cominciata.
  static DirittoAllePush diritto({
    required Tier tier,
    required DateTime? registratoIl,
    required DateTime adesso,
  }) {
    if (tier.level >= pianoMinimo.level) return DirittoAllePush.abbonato;
    if (registratoIl == null) return DirittoAllePush.soloChiamateLocali;
    final finiti = adesso.difference(registratoIl).inDays;
    // **Il confine e' il giorno trenta compreso**: chi si registra il primo
    // del mese ha le push fino al trentesimo giorno incluso, e le perde il
    // trentunesimo. Un confine scritto con `>` invece che `>=` regalerebbe un
    // giorno in piu' a tutti, ed e' l'errore che la prova del rosso cerca.
    if (finiti < giorniDiProva) return DirittoAllePush.inProva;
    return DirittoAllePush.soloChiamateLocali;
  }

  /// Vero se le push devono partire per questa persona.
  static bool riceveLePush({
    required Tier tier,
    required DateTime? registratoIl,
    required DateTime adesso,
  }) =>
      diritto(tier: tier, registratoIl: registratoIl, adesso: adesso) !=
      DirittoAllePush.soloChiamateLocali;

  /// Quanti giorni di prova restano. Zero quando non ce ne sono.
  static int giorniRimasti({
    required DateTime? registratoIl,
    required DateTime adesso,
  }) {
    if (registratoIl == null) return 0;
    final restano = giorniDiProva - adesso.difference(registratoIl).inDays;
    return restano < 0 ? 0 : restano;
  }

  /// **COSA SI DICE A CHI E' IN PROVA.**
  ///
  /// **Testo provvisorio**: le parole che la persona legge le approva il
  /// fondatore.
  static String rigaDellaProva(int giorni) => giorni == 1
      ? 'Ultimo giorno di prova delle notifiche del Cerchio.'
      : 'Le notifiche del Cerchio sono in prova per altri $giorni giorni.';

  /// **COSA SI DICE A CHI LA PROVA L'HA FINITA.**
  ///
  /// Non un lucchetto e non un vicolo cieco: dice cosa resta e cosa si
  /// otterrebbe, che e' la regola di casa sugli inviti.
  ///
  /// **Testo provvisorio.**
  static const String invitoDopoLaProva =
      'Le notifiche che ti arrivano anche a Cerchio chiuso sono '
      'dell\'Iniziato. Gli avvisi che il telefono tiene per te restano, '
      'sempre.';
}
