import '../tempo/confine_del_giorno.dart';
import '../maestro/maestro.dart';

/// I contenuti deterministici dei rituali del giorno.
///
/// Tutto nasce dalla data, senza rete: lo stesso giorno dà sempre lo stesso
/// responso, e a mezzanotte cambia. Le voci restano quelle dei Maestri.
class DailyRituals {
  const DailyRituals._();

  /// **ORDINE BL, ed e' il punto che pesa di piu'.** Da questo numero
  /// esce il Maestro del Rito dell'Alba, cioe' il primo gesto della
  /// giornata e il piu' ripetuto dell'app. Con la sottrazione fra istanti
  /// locali il numero cambiava alle una di notte: per i sette mesi
  /// dell'ora legale, chi apriva l'app fra mezzanotte e l'una riceveva il
  /// dono di ieri, con la voce del Maestro di ieri.
  static int _dayOfYear(DateTime date) => ConfineDelGiorno.giornoDellAnno(date);

  /// Il Maestro del Rito dell'Alba di oggi, a rotazione di giorno in giorno.
  static Maestro dawnMaestro(DateTime date) =>
      Maestro.fixedOrder[_dayOfYear(date) % Maestro.fixedOrder.length];

  /// Il messaggio dell'alba, nella voce del Maestro di turno.
  static String dawnMessage(DateTime date) {
    final maestro = dawnMaestro(date);
    final pool = _dawnPools[maestro]!;
    return pool[(_dayOfYear(date) ~/ 3) % pool.length];
  }

  /// Il Maestro del Rito della Buonanotte di oggi. Ruota come il Rito dell'Alba,
  /// quindi lo stesso giorno condivide lo stesso Maestro di turno.
  static Maestro nightMaestro(DateTime date) => dawnMaestro(date);

  /// Il messaggio della buonanotte, nella voce del Maestro di turno: una parola
  /// calmante per lasciare andare il giorno.
  static String nightMessage(DateTime date) {
    final maestro = nightMaestro(date);
    final pool = _nightPools[maestro]!;
    return pool[(_dayOfYear(date) ~/ 3) % pool.length];
  }

  /// Il frammento del Soffio del Destino, nella voce di Aura.
  static String destinyFragment(DateTime date) =>
      _destiny[_dayOfYear(date) % _destiny.length];

  /// L'Oracolo del Giorno, nella voce di Medora.
  static String dayOracle(DateTime date) =>
      _oracle[_dayOfYear(date) % _oracle.length];

  // La Runa del Tramonto ha ora il suo motore, `SunsetRune.estrai`: non e' piu'
  // ciclica ne uguale per tutti, nasce dal giorno rituale incrociato con la
  // carta di nascita e il segno. Il vecchio riempitivo dayOfYear e' stato tolto.

  static const Map<Maestro, List<String>> _dawnPools = {
    Maestro.medora: [
      'Il cielo si schiarisce: oggi una piccola scelta conta più di mille pensieri.',
      'La luce nasce a est: porta con te una sola intenzione, chiara.',
      'Le stelle si ritirano, il giorno è tuo: scrivi la prima riga con calma.',
      'Un nuovo transito comincia: accogli il giorno come una carta appena girata.',
    ],
    Maestro.aura: [
      'Apri gli occhi, apri il respiro: il primo respiro del giorno è già un dono.',
      'Prima di alzarti, senti il corpo che si sveglia: ringrazialo con un respiro.',
      'La mattina chiede dolcezza: un sorso d\'acqua, tre respiri, poi il mondo.',
      'Posa una mano sul cuore: oggi vai al tuo ritmo, non a quello della fretta.',
    ],
    Maestro.caligo: [
      'L\'alba spezza la notte: alzati come chi varca una soglia, con fermezza.',
      'Il fuoco del mattino chiede un gesto: scegli una cosa da onorare oggi.',
      'La nebbia si dirada: cammina deciso, la giornata riconosce chi ha una meta.',
      'Accendi dentro una brace piccola e salda: basta quella a reggere il giorno.',
    ],
  };

  static const Map<Maestro, List<String>> _nightPools = {
    Maestro.medora: [
      'Il cielo si chiude piano: lascia al domani una sola cosa, il resto posala.',
      'Le stelle vegliano al posto tuo: chiudi gli occhi, la volta ti tiene.',
      'La notte archivia il giorno: una gratitudine breve, poi il respiro lento.',
      'Un transito si acquieta: sciogli la presa, il sonno riordina da sé.',
    ],
    Maestro.aura: [
      'Allunga l\'espirazione più dell\'inspiro: il corpo capisce che è ora.',
      'Sciogli le spalle, ammorbidisci la mascella: lascia andare, un respiro.',
      'Posa una mano sul petto: sei al sicuro, il giorno può finire qui.',
      'Tre respiri lenti e profondi: a ogni uscita, un peso in meno.',
    ],
    Maestro.caligo: [
      'Spegni la brace con calma: hai fatto abbastanza, la notte custodisce.',
      'Chiudi il cerchio del giorno: un gesto, un respiro, poi il silenzio.',
      'Lascia il giorno alla soglia: dentro la notte non ti serve portarlo.',
      'La runa della sera si posa: quieta la mente, domani si riaccende.',
    ],
  };

  static const List<String> _destiny = [
    'Il tuo soffio dice: lascia andare un peso vecchio, fai spazio al nuovo.',
    'Nel respiro trovi la risposta: rallenta, la strada si mostra da sola.',
    'Un\'energia sopita si risveglia: dà fiato a un desiderio che rimandi.',
    'Oggi il vento è dalla tua parte: un piccolo coraggio verrà premiato.',
    'Qualcosa si scioglie dentro: perdona te stesso per una cosa sola.',
    'Il destino sussurra pazienza: ciò che matura in silenzio è quasi pronto.',
    'Il tuo respiro apre una porta: di\' sì a un invito che ti fa un po\' paura.',
  ];

  static const List<String> _oracle = [
    'La Luna illumina un legame: una parola sincera oggi vale un tesoro.',
    'Il cielo consiglia misura: non forzare una porta che si apre da sola domani.',
    'Un pianeta lento ti sostiene: fidati del lavoro fatto, i frutti arrivano.',
    'Le carte parlano di soglia: un piccolo passo conta più di un grande piano.',
    'Venere ti guarda con favore: coltiva la bellezza in un gesto minimo.',
    'Mercurio chiede chiarezza: metti in ordine un pensiero, poi parla.',
    'Il Sole scalda un progetto: dagli luce oggi, senza pretendere tutto subito.',
  ];
}
