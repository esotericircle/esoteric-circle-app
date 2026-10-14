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
      'Che cosa devo capire di chi mi ha cresciuto?',
      'Come sto accanto a chi amo in casa?',
    ],
    titoloDiRipiego: 'La pace in casa comincia da un tuo gesto',
  ),
  amicizia(
    nome: 'Amicizia',
    parole: ['amic', 'compagn', 'gruppo', 'fiducia', 'tradiment'],
    domande: [
      'Di chi posso fidarmi davvero?',
      'Come curo un\'amicizia che si è raffreddata?',
      'Che cosa porto io alle persone che ho accanto?',
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
      'Che cosa mi tocca imparare adesso?',
      'Quale talento sto lasciando in disparte?',
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
      'Dove trovo un po\' di quiete oggi?',
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

  /// Le domande proposte del tema, tre per tema.
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
