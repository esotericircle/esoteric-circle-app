import '../tarot/domanda_della_persona.dart';

/// **I TEMI E LE DOMANDE PROPOSTE DELL'ORACOLO.** Ordine FU voce FU.03, 15
/// ottobre 2026. Il fondatore: *"credo sia indispensabile far fare una
/// domanda libera all'utente oltre a quelle proposte da noi"*.
///
/// La persona scrive la sua domanda oppure ne sceglie una di queste, scritte
/// da Code per temi nel formato di `DomandaDellaPersona` della Stesa: un
/// dato dichiarato, temi con le loro parole. Il tema riconosciuto sul
/// telefono serve anche al titolo di ripiego quando il modello non risponde
/// (FU.04): mai un vicolo cieco.
enum TemaDellOracolo {
  amore(
    nome: 'Amore',
    parole: [
      'amore',
      'amare',
      'innamor',
      'coppia',
      'relazion',
      'partner',
      'fidanzat',
      'marito',
      'moglie',
      'sentiment',
      'cuore',
      'ex',
    ],
    domande: [
      'Che cosa mi chiede questo amore adesso?',
      'Come posso aprire il cuore senza paura?',
      'Che cosa devo lasciare andare in questa relazione?',
      'Quale ferita porto ancora nel mio modo di amare?',
      'Come riconosco un amore che mi fa crescere?',
      'Che cosa posso portare di nuovo nella nostra coppia?',
      'Come parlo al mio partner di ciò che mi manca?',
      'Che cosa mi insegna la fine della mia ultima storia d\'amore?',
      'Come tengo vivo il mio spazio dentro la coppia?',
      'Che cosa mi dice la gelosia che sento nel cuore?',
    ],
    titoloDiRipiego: 'Il tuo cuore sa già da dove ricominciare',
  ),
  lavoro(
    nome: 'Lavoro',
    parole: [
      'lavor',
      'carriera',
      'ufficio',
      'progett',
      'colleg',
      'capo',
      'studi',
      'esame',
      'scuola',
      'impres',
      'professio',
    ],
    domande: [
      'Quale passo devo fare nel mio lavoro?',
      'Come trovo la mia strada professionale?',
      'Che cosa mi frena in questo progetto?',
      'Come porto più valore nel lavoro che faccio ogni giorno?',
      'Che cosa mi chiede questo periodo di studio?',
      'Come affronto con calma l\'esame che mi aspetta?',
      'Come miglioro il rapporto con un collega difficile?',
      'Che cosa devo dire al mio capo e non ho ancora detto?',
      'È il momento di avviare un\'impresa tutta mia?',
      'Quale talento posso mettere meglio a frutto nella mia carriera?',
    ],
    titoloDiRipiego: 'Il passo giusto è quello che puoi fare oggi',
  ),
  famiglia(
    nome: 'Famiglia',
    parole: [
      'famigli',
      'madre',
      'padre',
      'mamma',
      'papà',
      'papa',
      'figli',
      'fratell',
      'sorell',
      'genitor',
      'nonn',
      'casa',
    ],
    domande: [
      'Come posso portare pace nella mia famiglia?',
      'Che cosa devo capire dei miei genitori adesso?',
      'Come sto accanto a chi amo in casa?',
      'Come accompagno i miei figli in questo passaggio?',
      'Che cosa posso ricucire con mio fratello o mia sorella?',
      'Come onoro ciò che mi hanno lasciato i nonni?',
      'Che cosa mi chiede adesso il rapporto con mia madre?',
      'Che cosa ho ereditato da mio padre e voglio tenere?',
      'Come rendo la casa un luogo dove tutti respirano?',
      'Come affronto una decisione che divide la famiglia?',
    ],
    titoloDiRipiego: 'La pace in casa comincia da un tuo gesto',
  ),
  amicizia(
    nome: 'Amicizia',
    parole: ['amic', 'compagn', 'gruppo', 'fiducia', 'tradiment'],
    domande: [
      'Su quali amicizie posso contare davvero?',
      'Come curo un\'amicizia che si è raffreddata?',
      'Che cosa porto io ai miei amici?',
      'Come ritrovo fiducia dopo una delusione?',
      'Come lascio andare un\'amicizia che non mi fa più bene?',
      'Come trovo il mio posto in un gruppo nuovo?',
      'Che cosa mi insegna un tradimento che ancora brucia?',
      'Come stringo amicizie nuove in questa fase della vita?',
      'Come sostengo un amico che sta passando un momento duro?',
      'Quale compagnia mi fa bene e quale mi svuota?',
    ],
    titoloDiRipiego: 'Le persone giuste si riconoscono dai gesti',
  ),
  scelta(
    nome: 'Una scelta',
    parole: [
      'scelt',
      'sceglier',
      'decid',
      'decision',
      'dubbio',
      'strada',
      'cambiare',
      'cambiament',
      'trasferi',
      'lasciare',
      'restare',
    ],
    domande: [
      'Che cosa mi aiuta a scegliere?',
      'Sono sulla strada giusta?',
      'Che cosa non sto vedendo di questa decisione?',
      'Come distinguo il dubbio vero dalla paura?',
      'Che cosa mi chiede di più: restare o cambiare?',
      'Quale cambiamento sto rimandando da troppo tempo?',
      'Come mi preparo a trasferirmi in un posto nuovo?',
      'Come decido quando ogni via ha un prezzo?',
      'Che cosa devo lasciare per andare avanti?',
      'Quale scelta onora di più chi sono?',
    ],
    titoloDiRipiego: 'La scelta si chiarisce mentre cammini',
  ),
  crescita(
    nome: 'Il mio cammino',
    parole: [
      'cammino',
      'crescere',
      'crescita',
      'anima',
      'scopo',
      'senso',
      'missione',
      'talent',
      'paura',
      'coraggio',
      'spirit',
    ],
    domande: [
      'Qual è il mio prossimo passo nel cammino?',
      'Che cosa mi tocca imparare adesso per crescere?',
      'Quale talento sto lasciando in disparte?',
      'Dove trovo il coraggio che mi manca?',
      'Qual è lo scopo di questo periodo della mia vita?',
      'Che cosa dà senso alle mie giornate?',
      'Quale paura mi blocca di più?',
      'Come ascolto la voce della mia anima?',
      'Qual è la mia missione in questa fase?',
      'Come nutro la mia vita spirituale ogni giorno?',
    ],
    titoloDiRipiego: 'Il tuo cammino ha già la sua direzione',
  ),
  serenita(
    nome: 'Serenità',
    parole: [
      'serenit',
      'pace',
      'ansia',
      'stress',
      'calma',
      'stanc',
      'tranquill',
      'preoccupa',
      'pensier',
      'sonno',
    ],
    domande: [
      'Come ritrovo la calma in questi giorni?',
      'Che cosa mi toglie serenità?',
      'Dove trovo un po\' di pace oggi?',
      'Come sciolgo l\'ansia che sento la sera?',
      'Che cosa mi stanca più di quanto penso?',
      'Come lascio andare un pensiero che torna sempre?',
      'Come ritrovo un sonno tranquillo?',
      'Che cosa mi preoccupa davvero sotto la superficie?',
      'Come reggo lo stress di questo periodo?',
      'Quale piccolo rito mi riporta in pace?',
    ],
    titoloDiRipiego: 'La quiete è più vicina di quanto pensi',
  );

  const TemaDellOracolo({
    required this.nome,
    required this.parole,
    required this.domande,
    required this.titoloDiRipiego,
  });

  final String nome;

  /// Le radici che riconoscono il tema in una domanda scritta.
  final List<String> parole;

  /// Le domande proposte del tema, dieci per tema, nella voce di Medora
  /// (ordine FY voce FY.13): la persona le affida cosi' come sono.
  final List<String> domande;

  /// Il titolo della risposta del solo corpus, quando il modello non
  /// risponde: e' gia' una risposta, nella voce di Medora.
  final String titoloDiRipiego;

  /// Il titolo di ripiego quando nessun tema si riconosce.
  static const String titoloSenzaTema =
      'Gli angeli rispondono con tre gesti per te';

  /// **IL TEMA DI UNA DOMANDA**, sul telefono: il primo tema che ha una sua
  /// radice fra le parole portanti della domanda (le stesse di
  /// `DomandaDellaPersona.portanti`), nell'ordine dei temi. Nullo se nessuno.
  static TemaDellOracolo? di(String domanda) {
    final portanti = DomandaDellaPersona.portanti(domanda);
    for (final tema in TemaDellOracolo.values) {
      for (final p in portanti) {
        if (tema.parole.any(p.startsWith)) return tema;
      }
    }
    return null;
  }
}
