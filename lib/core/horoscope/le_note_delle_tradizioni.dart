import 'astro_tradition.dart';

/// **LA NOTA DI OGNI TRADIZIONE, ordine ES voce 10.**
///
/// Il fondatore: *"a fianco dell'emblema dell'oroscopo cinese serve un
/// tooltip che spieghi all'utente dincosa si tratta , tradizione, cenni
/// storici, fonti, ecc."*. Sette note, una per tradizione, in quattro parti:
/// che cos'e', un po' di storia, come si calcola il segno, le fonti.
///
/// **Ogni frase ha la sua fonte**, numerata in `docs/collaudo/ES/tooltip.txt`
/// con la parafrasi che la sostiene e il suo grado di solidita'. Dove la
/// verita' lo chiede, la nota la dice: il calendario degli alberi e' di
/// Robert Graves (1948), il Dreamspell non e' lo Tzolk'in, il segno cinese
/// dipende dal Capodanno lunare, quello vedico e' della Luna. Le note non
/// promettono niente che l'app non calcoli.
class NotaDellaTradizione {
  const NotaDellaTradizione({
    required this.cheCose,
    required this.storia,
    required this.calcolo,
    required this.fonti,
  });

  final String cheCose;
  final String storia;
  final String calcolo;
  final List<String> fonti;
}

abstract final class LeNoteDelleTradizioni {
  static const Map<AstroTradition, NotaDellaTradizione> note = {
    AstroTradition.occidentale: NotaDellaTradizione(
      cheCose:
          'Divide l\'eclittica, il cammino apparente del Sole, in dodici segni di 30 gradi. Usa lo zodiaco tropicale: l\'Ariete comincia all\'equinozio di primavera.',
      storia:
          'I Babilonesi divisero lo zodiaco in dodici segni uguali verso il 500 a.C. Nell\'Egitto ellenistico nacque l\'oroscopo di nascita. Nel II secolo d.C. Tolomeo, nel Tetrabiblos, fece partire i segni dagli equinozi e dai solstizi.',
      calcolo:
          'È il segno in cui si trovava il Sole al momento della tua nascita.',
      fonti: [
        'Tolomeo, Tetrabiblos, trad. F. E. Robbins, 1940.',
        'D. E. Pingree, R. A. Gilbert, «Astrology», Encyclopaedia Britannica, online 2026.',
        'Redazione Britannica, «Zodiac», Encyclopaedia Britannica, online 2026.',
      ],
    ),
    AstroTradition.cinese: NotaDellaTradizione(
      cheCose:
          'Assegna ogni anno a uno di dodici animali: Topo, Bue, Tigre, Coniglio, Drago, Serpente, Cavallo, Capra, Scimmia, Gallo, Cane, Maiale. Dopo dodici anni il ciclo ricomincia.',
      storia:
          'Il ciclo nasce dai dodici rami terrestri, con cui in Cina si contavano gli anni e le ore. Gli animali vi furono legati più tardi. Sotto la dinastia Han il sistema era già consolidato.',
      calcolo:
          'Conta l\'anno di nascita secondo il calendario lunisolare cinese. L\'anno comincia col Capodanno lunare, fra il 21 gennaio e il 20 febbraio, non il 1° gennaio. Chi nasce prima del Capodanno ha l\'animale dell\'anno precedente.',
      fonti: [
        'F. Comstock, «Chinese zodiac», Encyclopaedia Britannica, online 2026.',
        'Chao Lin, «Chinese calendar», Encyclopaedia Britannica, online 2026.',
        'Royal Museums Greenwich, «Lunar New Year dates and animals of the zodiac», 2026.',
      ],
    ),
    AstroTradition.vedica: NotaDellaTradizione(
      cheCose:
          'La Jyotisha è l\'astrologia tradizionale dell\'India. Usa lo zodiaco siderale: i dodici segni, i rashi, sono ancorati alle stelle fisse e non all\'equinozio.',
      storia:
          'Nel II e III secolo d.C. l\'astrologia greca arrivò in India con traduzioni in sanscrito. I dodici segni si unirono ai nakshatra, le dimore lunari dei testi vedici. Nel 1955 il Comitato indiano per la riforma del calendario scelse l\'ayanamsa di Lahiri, ancorato alla stella Spica.',
      calcolo:
          'Si prende la posizione della Luna alla tua nascita. Le si toglie l\'ayanamsa, oggi circa 24 gradi. Ne risulta il tuo Chandra rashi, il segno lunare. La Luna cambia segno ogni due giorni e un quarto circa: l\'ora di nascita conta.',
      fonti: [
        'D. E. Pingree, R. A. Gilbert, «Astrology», Encyclopaedia Britannica, online 2026.',
        'D. Koch, A. Treindl, Swiss Ephemeris, documentazione, Astrodienst, 2022.',
      ],
    ),
    AstroTradition.maya: NotaDellaTradizione(
      cheCose:
          'Lo Tzolkʼin è il calendario rituale maya di 260 giorni. Unisce 13 numeri a 20 nomi di giorno: nasce così ogni data, come 4 Ajaw. Ogni giorno aveva un suo carattere, usato nella divinazione.',
      storia:
          'La più antica data maya finora nota, «7 Cervo», è dipinta a San Bartolo in Guatemala. Risale al 300 a.C. circa. Alcune comunità maya del Guatemala usano ancora questo calendario.',
      calcolo:
          'La tua data di nascita diventa un giorno dello Tzolkʼin con la correlazione GMT (584283), la più accettata dagli studiosi. Forse conosci il Dreamspell, creato da José Argüelles nel 1987. È un\'opera moderna con un suo conteggio. Non coincide con quello maya.',
      fonti: [
        'Redazione Britannica, «Maya calendar», Encyclopaedia Britannica, online 2026.',
        'D. Stuart et al., «An early Maya calendar record from San Bartolo», Science Advances, 2022.',
        'D. J. Kennett et al., «Correlating the ancient Maya and modern European calendars», Scientific Reports, 2013.',
      ],
    ),
    AstroTradition.celtica: NotaDellaTradizione(
      cheCose:
          'Il calendario degli alberi divide l\'anno in tredici mesi di 28 giorni. Ogni mese porta il nome di un albero legato a una lettera dell\'alfabeto ogamico irlandese: la Betulla, il Sorbo, la Quercia.',
      storia:
          'Non è un calendario dei Celti antichi. Lo ha costruito il poeta Robert Graves nel libro The White Goddess, del 1948. Il calendario celtico meglio documentato è quello di Coligny, inciso in Gallia nel II secolo d.C. È lunisolare. I suoi mesi non portano nomi di alberi.',
      calcolo:
          'Si cerca il mese di Graves in cui cade il giorno della tua nascita. La Betulla, per esempio, va dal 24 dicembre al 20 gennaio.',
      fonti: [
        'R. Graves, The White Goddess, 1948.',
        'P. Berresford Ellis, «The Fabrication of "Celtic" Astrology», The Astrological Journal, 1997.',
      ],
    ),
    AstroTradition.egizia: NotaDellaTradizione(
      cheCose:
          'I decani sono 36 gruppi di stelle dell\'antico Egitto. Il loro sorgere scandiva le ore della notte. Ogni dieci giorni circa un nuovo decano tornava visibile prima dell\'alba.',
      storia:
          'Compaiono dipinti dentro i coperchi dei sarcofagi, circa quattromila anni fa. Più tardi ornano le volte delle tombe reali di Tebe. Gli astrologi ellenistici assegnarono poi a ogni decano 10 gradi dello zodiaco: tre decani per ogni segno.',
      calcolo:
          'Si prende la posizione del Sole alla tua nascita. Il tuo decano è il tratto di 10 gradi in cui cade. È la regola ellenistica, non l\'orologio stellare dei faraoni.',
      fonti: [
        'O. Gingerich, «Astronomical map», Encyclopaedia Britannica, online 2026.',
        'D. E. Pingree, R. A. Gilbert, «Astrology», Encyclopaedia Britannica, online 2026.',
        'Ancient Egyptian Astronomy Database, McMaster University, online 2026.',
      ],
    ),
    AstroTradition.araba: NotaDellaTradizione(
      cheCose:
          'Le manazil al-qamar sono 28 dimore lunari: stelle e gruppi di stelle lungo lo zodiaco. La Luna fa il giro del cielo in poco più di 27 giorni. Attraversa così circa una dimora al giorno.',
      storia:
          'Gli antichi Arabi seguivano stelle chiamate anwaʼ per orientarsi nel deserto e prevedere le piogge. In un\'epoca incerta ricevettero dall\'India il sistema delle 28 dimore. Ogni dimora prese il nome di una loro stella.',
      calcolo:
          'Si prende la posizione della Luna alla tua nascita. Il cerchio si divide in 28 dimore uguali di circa 13 gradi, dall\'inizio dell\'Ariete, come nel Picatrix medievale. Serve l\'ora di nascita: in un giorno la Luna cambia dimora.',
      fonti: [
        'P. Kunitzsch, «Lunar Mansions in Islam», in H. Selin (a cura di), Encyclopaedia of the History of Science, Technology, and Medicine in Non-Western Cultures, 2016.',
        'O. Gingerich, «Astronomical map», Encyclopaedia Britannica, online 2026.',
      ],
    ),
  };

  static NotaDellaTradizione di(AstroTradition t) => note[t]!;
}
