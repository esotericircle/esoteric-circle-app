import 'listino_degli_eos.dart';

/// LE STRADE PER SBLOCCARE UNA FUNZIONE, dichiarate in un punto solo.
/// Ordine AN voce 06.
enum StradaDelloSblocco {
  /// Si compra adesso con gli Eos: e' un'esperienza singola e conclusa.
  eos,

  /// Solo l'abbonamento la porta: gli Eos non la comprano mai, perche' e'
  /// accesso continuativo o memoria.
  abbonamento,

  /// Non c'e' niente da sbloccare: la funzione non esiste ancora.
  comingSoon,
}

/// COME SI SBLOCCA CIO' CHE E' BLOCCATO, in un punto solo.
///
/// **La regola, dai briefing.** Gli Eos comprano esperienze SINGOLE e
/// CONCLUSE (una stesa, una sinastria in piu', una domanda in piu'), mai
/// accesso continuativo o memoria, che restano dell'abbonamento. Da qui
/// discende cosa mostrare davanti a un lucchetto, e non e' una scelta
/// grafica: una funzione di relazione continuativa offerta a Eos sarebbe una
/// promessa che il piano non mantiene, e una funzione a consumo che mostra
/// solo l'abbonamento nasconde la strada piu' breve.
///
/// **Mai un lucchetto muto.** Ogni funzione bloccata dice come si sblocca:
/// col costo in Eos, con l'invito ai Piani, oppure con tutte e due le strade
/// quando esistono entrambe. Il Coming soon resta un'altra cosa e non si
/// mescola col Premium: li' non c'e' niente da comprare, c'e' da aspettare.
class StradeDelloSblocco {
  const StradeDelloSblocco._();

  /// CIO' CHE GLI EOS NON COMPRANO MAI, enumerato.
  ///
  /// Sono le funzioni di relazione continuativa: la memoria dei Maestri, la
  /// voce, la profondita' delle risposte, la compatibilita' a tre livelli.
  /// L'elenco sta qui e non dentro le schermate, cosi' una funzione nuova
  /// deve dichiararsi invece di ereditare per caso la strada sbagliata.
  static const Set<String> soloAbbonamento = {
    'maestro_memory',
    'maestro_voice',
    'answer_depth',
    'synastry_three_levels',
    'natal_transits_live',
    'mood_transits',
    'cosmic_journal_full',
  };

  /// Le strade di una funzione, nell'ordine in cui si mostrano.
  ///
  /// Una funzione a consumo che il tier INCLUDE porta tutte e due le
  /// strade: chi ha gli Eos la prende adesso, chi vuole smettere di pagarla
  /// ogni volta sale di piano. Mostrarne una sola nasconderebbe una scelta
  /// che esiste.
  static List<StradaDelloSblocco> per(String idFunzione,
      {bool inArrivo = false}) {
    if (inArrivo) return const [StradaDelloSblocco.comingSoon];
    if (soloAbbonamento.contains(idFunzione)) {
      return const [StradaDelloSblocco.abbonamento];
    }
    final voce = ListinoDegliEos.perArte(idFunzione);
    if (voce == null) return const [StradaDelloSblocco.abbonamento];
    // A consumo: gli Eos adesso, e l'abbonamento che la include.
    return const [StradaDelloSblocco.eos, StradaDelloSblocco.abbonamento];
  }

  /// La riga che accompagna ciascuna strada, in lingua del Cerchio.
  static String rigaDi(StradaDelloSblocco strada, {VoceDelListino? voce}) {
    switch (strada) {
      case StradaDelloSblocco.eos:
        final costo = voce == null
            ? ''
            : ' per ${ListinoDegliEos.prezzo(voce.costo)}';
        return 'Prendila adesso$costo con i tuoi Eos.';
      case StradaDelloSblocco.abbonamento:
        return 'Con un piano del Cerchio è inclusa, senza spendere Eos.';
      case StradaDelloSblocco.comingSoon:
        return 'Sta per aprirsi nel Cerchio: non si compra, arriva.';
    }
  }
}
