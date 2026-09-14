import '../chat/le_forme_del_genere.dart';
import '../chat/user_profile.dart';

/// **LE GUARDIE DEI TESTI CHE SCRIVE IL MODELLO.** Ordine DL voci 07 e 13,
/// 14 settembre 2026.
///
/// **Da dove nasce.** Il fondatore ha scritto una domanda personale in tutte e
/// quattro le discese della prova della build 2250, e non ha mai ricevuto una
/// risposta a quella domanda, a partire dal titolo. Il titolo si sceglieva fra
/// ventiquattro costanti per tema, la risposta fra dodici e il gesto fra
/// venti: testi scritti a tavolino possono rispondere alla CATEGORIA in cui la
/// domanda e' stata infilata, mai alla domanda. Adesso li scrive il modello, e
/// questo file decide quali delle sue righe arrivano alla persona.
///
/// **Le guardie non si negoziano**, e ogni riga si giudica per conto suo: se
/// la guardia scarta il gesto, il titolo e la risposta del modello restano, e
/// al posto del gesto torna quello di casa. **La riserva non si tocca**, ed e'
/// la voce di sempre: i centoquarantaquattro titoli, le settantadue risposte e
/// i venti gesti.

/// **PERCHE' UNA RIGA SI SCARTA**, per nome: la misura li conta uno per uno.
enum MotivoDelloScarto {
  vuota,
  troppoLunga,
  eUnaDomanda,
  dueDuePunti,
  duePuntiNelTitolo,
  trattinoLungo,
  virgolaEe,
  primaPersona,
  previsioneCerta,
  promessa,
  diagnosi,
  nomeProprio,
  genereContrario,
  nonNominaLaDomanda,
  anticipaLaScena,
  consiglioDiVita,
  senzaTempo,
  toccaUnTerzo,
  saluteDenaroLegge,
  titoloRipetuto,
  // Ordine DN, 14 settembre 2026.
  fuoco,
  statoDiUnTerzo,
  decisioneGrave,
  gergo,
  titoloAnticipaLaScena,
}

/// Una riga scartata: quale pezzo, perche', e il testo.
class RigaScartata {
  const RigaScartata(this.pezzo, this.motivo, this.testo);

  /// `titolo`, `risposta` o `azione`.
  final String pezzo;
  final MotivoDelloScarto motivo;
  final String testo;

  @override
  String toString() => '$pezzo scartato per ${motivo.name}: "$testo"';
}

/// **I TRE TESTI DEL MODELLO**, gia' passati dalle guardie: ognuno c'e' solo
/// se ha retto. Gli scarti restano, per il registro e per la misura.
class TestiDelModello {
  const TestiDelModello({
    this.titolo,
    this.risposta,
    this.azione,
    this.scarti = const [],
  });

  final String? titolo;
  final String? risposta;
  final String? azione;
  final List<RigaScartata> scarti;

  bool get vuoti => titolo == null && risposta == null && azione == null;

  static const TestiDelModello nessuno = TestiDelModello();
}

abstract final class LeGuardieDelResponso {
  /// Quante parole al massimo ha un titolo: sei, dall'ordine.
  static const int paroleDelTitolo = 6;

  /// Quante frasi al massimo ha una risposta: **tre**, ordine DN voce 05.
  /// L'ordine DL ne voleva due, e trentanove risposte buone su 1.100 discese
  /// cadevano per una terza frase corta, *"Non e' una fine. E' un
  /// passaggio."*: una regola scritta da noi non vale una risposta buona. Il
  /// tetto delle quarantacinque parole resta.
  static const int frasiDellaRisposta = 3;

  /// Quante frasi al massimo ha un gesto: **tre**, con la stessa ragione.
  /// Alla misura a cento discese dell'ordine DN era il primo motivo per cui
  /// si leggeva il gesto di casa: *"Domani mattina cerca un piccolo sasso.
  /// Tienilo in mano per qualche minuto. Poi gettalo in un corso d'acqua."*
  /// e' una cosa sola in tre frasi. Il tetto delle trenta parole resta.
  static const int frasiDelGesto = 3;

  static const String _l = 'a-zàèéìòù';

  static RegExp _parole(String alternative) =>
      RegExp('(?<![$_l])($alternative)(?![$_l])', caseSensitive: false);

  /// **UNA PREVISIONE CERTA SU UN FATTO FUTURO**, nella famiglia della guardia
  /// del segno: *"tua sorella avra' un bambino"* si scarta, *"non tocca a te
  /// saperlo prima di lei"* va bene.
  ///
  /// **E LE DUE FORME CHE IL FUTURO NON HANNO**, trovate dalla sonda col
  /// modello vero, ordine DL voce 07: *"La casa è già venduta"*, *"ha già
  /// trovato un nuovo proprietario"*, cioe' il fatto dato per accaduto; e
  /// *"non è il momento giusto per vederlo fiorire"* al figlio che cerca
  /// lavoro, cioe' un no travestito. Sono previsioni quanto un futuro.
  static final RegExp _certezza =
      _parole('avrà|avrai|avranno|sarà|sarai|saranno|tornerà|tornerai|arriverà|'
          'arriverai|succederà|riuscirai|riuscirà|ce la farai|farcela|vincerai|'
          'vincerà|otterrai|otterrà|troverai|troverà|cambierà|finirà|nascerà|'
          'guarirà|guarirai|sicuramente|certamente|di sicuro|senza dubbio|'
          'è certo|garantit[oaie]|'
          '(è|ha|hanno|sono) già [a-zàèéìòù]+(at|ut|it)[oaie]|'
          'non è (ancora )?(il )?(suo |tuo |questo )?(momento|tempo)');

  /// **UNA PROMESSA** su salute, denaro, morte, gravidanza, cause legali o
  /// eventi garantiti: in un responso del Viaggio queste parole non stanno.
  static final RegExp _promessa =
      _parole('guari[a-zàèéìòù]*|malatti[a-zàèéìòù]*|cancro|tumor[a-zàèéìòù]*|'
          'morir[a-zàèéìòù]*|morte|morrà|morto|morta|gravidanz[a-zàèéìòù]*|'
          'incinta|partori[a-zàèéìòù]*|soldi|denaro|ricchezz[a-zàèéìòù]*|'
          'lotteria|eredità|tribunale|sentenza|avvocat[a-zàèéìòù]*|'
          'causa legale');

  /// **QUALCOSA CHE SOMIGLI A UNA DIAGNOSI** o a un consiglio medico.
  static final RegExp _diagnosi = _parole(
      'diagnos[a-zàèéìòù]*|terapi[a-zàèéìòù]*|farmac[a-zàèéìòù]*|'
      'medicin[a-zàèéìòù]*|medic[oi]|sintom[a-zàèéìòù]*|patolog[a-zàèéìòù]*|'
      'disturbo|depression[ei]|psicolog[a-zàèéìòù]*|psichiatr[a-zàèéìòù]*');

  /// **LA PRIMA PERSONA**: il responso non e' la voce di qualcuno che dice io.
  static final RegExp _primaPersona =
      _parole('io|mi|me|mio|mia|miei|mie|noi|nostro|nostra|nostri|nostre');

  /// **UN CONSIGLIO DI VITA, UNA MASSIMA, UN INVITO A RIFLETTERE**: il gesto
  /// e' una cosa che si fa, e di cui si capisce se e' stata fatta.
  static final RegExp _riflessione = RegExp(
      '^(rifletti|pensa|pensaci|chiediti|domandati|ascolta|ascoltati|medita|'
      'accetta|ricorda|fidati|credi|ama|sii|abbi|perdona|perdonati|immagina|'
      'visualizza)(?![$_l])|(?<![$_l])(riflettere|rifletti|meditare)(?![$_l])',
      caseSensitive: false);

  /// **UN GESTO CHE TOCCA UN TERZO** in un modo che puo' ferirlo o mettere in
  /// imbarazzo chi legge: confrontare, accusare, pretendere, rompere un
  /// rapporto, rivelare qualcosa a qualcuno.
  static final RegExp _terzi = _parole(
      'confronta[a-zàèéìòù]*|accusa[a-zàèéìòù]*|pretend[a-zàèéìòù]*|'
      'rompi|rompere|chiudi con|chiudere con|mollal[oa]|'
      // **"LASCIALO" SOLO QUANDO E' UNA PERSONA**, ordine DL voce 13:
      // la prova a cento discese scartava *"Lascialo sul comodino"*,
      // che parla di un foglio. Resta quando chiude la frase, *"Poi
      // lascialo."*, o quando va con perdere, andare, stare.
      'lascia(lo|la)(?= *[.!;]| *(?!.))|lascia(lo|la) (perdere|andare|stare)|'
      // **RIVELARE SOLO COME ORDINE**: *"le crepe che rivelano"* parla di
      // una pietra, e la misura dell'ordine DN la scartava.
      'affronta[a-zàèéìòù]*|smaschera[a-zàèéìòù]*|rivela(?:gli|le|lo|la|re)?|'
      'confessa[a-zàèéìòù]*|denuncia[a-zàèéìòù]*|minaccia[a-zàèéìòù]*|'
      'ultimatum|vendica[a-zàèéìòù]*|dille che|digli che|dì loro che');

  /// **UN GESTO SU SALUTE, FARMACI, DENARO O ATTI LEGALI.**
  static final RegExp _saluteDenaroLegge = _parole(
      'farmac[a-zàèéìòù]*|medic[a-zàèéìòù]*|dottor[a-zàèéìòù]*|'
      'terapi[a-zàèéìòù]*|dieta|digiun[a-zàèéìòù]*|alcol|soldi|denaro|'
      'investi[a-zàèéìòù]*|spendi|spendere|compra[a-zàèéìòù]*|'
      'acquista[a-zàèéìòù]*|prestit[a-zàèéìòù]*|avvocat[a-zàèéìòù]*|'
      'denunc[a-zàèéìòù]*|querel[a-zàèéìòù]*|contratt[a-zàèéìòù]*|firma|'
      'firmare|dimett[a-zàèéìòù]*|dimission[a-zàèéìòù]*|licenzi[a-zàèéìòù]*');

  /// **IL FUOCO NEL GESTO.** Ordine DN voce 01. Il gesto e' una cosa che una
  /// persona vera compie da sola, in casa, e fra quelle persone ci sono
  /// ragazzi: il gesto non accende niente. Il fuoco resta nella scena, dove e'
  /// simbolico: il pezzo `fuoco_acceso` del vocabolario non si tocca.
  static final RegExp _fuocoNelGesto =
      _parole('bruci[a-zàèéìòù]*|brucerai|bruciato|accend[a-zàèéìòù]*|'
          'dare fuoco|dai fuoco|dà fuoco|dagli fuoco|dalle fuoco|'
          'incendi[a-zàèéìòù]*|fiamm[a-zàèéìòù]*|cerin[oi]|'
          'candel[ae] accese?|brace|braci|bracier[ei]|ceneri|rogo|falò');

  /// **E IL FUOCO NEGLI ALTRI DUE TESTI**, quando e' un invito: il verbo del
  /// bruciare e dell'accendere. Il fuoco nominato come immagine resta.
  static final RegExp _fuocoComeInvito =
      _parole('brucia|bruciala|bruciali|bruciale|bruciarlo|bruciarla|bruciare|'
          'accendi|accendila|accendilo|accendere|dai fuoco|dare fuoco|'
          'incendia|incendiare');

  /// **UN TERZO, COME SOGGETTO**, ordine DN voce 02: per parentela o
  /// relazione col possessivo, per pronome, o per un nome che la persona ha
  /// scritto. I nomi propri si aggiungono a ogni lettura.
  // **CON L'ARTICOLO DAVANTI**, ordine DN voce 08: *"Il tuo compagno ti pone
  // davanti a una decisione"*, alla prova a video della build 2252, passava.
  static const String _terzoPerRelazione =
      '(?:(?:il|la|lo|i|gli|le) )?(?:tua|tuo|tuoi|tue|sua|suo|suoi|sue) '
      '(?:$_parenti)|lui|lei|loro|'
      'egli|ella|costui|costei|questa persona|quella persona|l.altra persona';

  static const String _parenti =
      'sorella|sorelle|fratello|fratelli|madre|mamma|padre|papà|figlio|'
      'figlia|figli|figlie|marito|moglie|compagno|compagna|partner|'
      'fidanzato|fidanzata|ragazzo|ragazza|amico|amica|amici|amiche|nonno|'
      'nonna|zio|zia|cugino|cugina|suocero|suocera|cognato|cognata|socio|'
      'socia|capo|collega|colleghi|ex|genitori';

  /// **CIO' CHE CHI LEGGE PUO' O NON PUO' FARE**: il predicato che rende
  /// ammessa una frase che nomina un terzo. *"La porta di tua sorella non e'
  /// tua da aprire"* dice una cosa su chi legge.
  static final RegExp _predicatoDiChiLegge =
      _parole('puoi|devi|sai|hai|sei|fai|vuoi|riesci|scegli|decidi|stai|vedi|'
          'senti|cerchi|aspetti|trovi|lasci|tieni|porti|chiedi|guardi|'
          'tocca a te|spetta a te|dipende da te|a te|da te|per te|'
          '(?:tua|tuo|tuoi|tue) da [a-zàèéìòù]+|'
          // *"La maternita' di tua sorella non e' una decisione tua"*: dice
          // cio' che chi legge non puo' fare. Dalla misura dell'ordine DN.
          '(?:tua|tuo) (?:decisione|scelta|compito|responsabilità)|'
          '(?:decisione|scelta|compito|responsabilità) (?:tua|tuo)');

  /// **UN ORDINE SU UNA DECISIONE GRAVE E IRREVERSIBILE**, ordine DN voce
  /// 04: lasciare il lavoro o una persona, separarsi, tagliare i rapporti,
  /// trasferirsi, vendere casa. Il responso puo' dire cosa guardare, mai
  /// cosa fare. **Prendere una parte si puo'**: si scarta l'ordine, non la
  /// posizione. *"Lascia il posto vuoto per ora"*, titolo di casa, non e'
  /// il posto di lavoro: la parola *posto* da sola non basta.
  static final RegExp _decisioneGrave = _parole(
      'lascia (?:il |la |lo |l.|i |gli |le )?(?:tuo |tua |tuoi |tue )?'
      '(?:lavoro|posto di lavoro|impiego|banca|ufficio|azienda|casa|città|'
      'paese|compagno|compagna|marito|moglie|fidanzato|fidanzata|partner|'
      'relazione|rapporto|famiglia)|'
      'licenziati|licenziarti|dimettiti|dimetterti|separati|separarti|'
      'divorzia|divorziare|trasferisciti|trasferirti|vattene|andartene|'
      'cambia (?:lavoro|città|casa|paese)|vendi (?:la )?casa|'
      'vendere (?:la )?casa|taglia i (?:ponti|rapporti)|'
      'tagliare i (?:ponti|rapporti)|chiudi (?:il|la) (?:rapporto|relazione)|'
      'devi (?:lasciare|licenziarti|dimetterti|separarti|trasferirti|'
      'vendere|andartene|chiudere)');

  /// **IL GERGO DA CORSO MOTIVAZIONALE**, ordine DN voce 04: *"E' tempo di
  /// vederla in te"* non prende posizione, fa finta. Si scarta perche' e'
  /// vuoto, non perche' sia audace. E *"un processo che si sta
  /// sviluppando"*, lingua da consulente, voce DN.02.
  static final RegExp _gergo = _parole(
      'il tuo vero io|il tuo vero sé|ascolta il tuo cuore|ascolta il cuore|'
      'devi solo|lascia andare|lasciar andare|lasciare andare|'
      // E col pronome: *"per lasciarla andare"*, dalla rassegna DN.06.
      'lascia(?:r)?(?:lo|la|li|le) andare|'
      'abbraccia il cambiamento|'
      'è tempo di|è il tempo di|il tuo percorso|la tua essenza|'
      'energia positiva|energie positive|apriti a|aprirti a|'
      'un processo|il processo|questo processo');

  /// **UN'INDICAZIONE DI TEMPO**, che il gesto del modello porta dentro di
  /// se': ordine DL voce 13. E' la stessa famiglia dei tempi di casa.
  static final RegExp indicazioneDiTempo =
      _parole('oggi|stasera|stanotte|stamattina|domani|domattina|dopodomani|'
          'settimana|weekend|fine settimana|entro|prima di|nei prossimi|'
          'tre giorni|due giorni|un giorno|fra un mese|tra un mese|fra una|'
          'tra una|questa sera|questo pomeriggio|lunedì|martedì|mercoledì|'
          'giovedì|venerdì|sabato|domenica|adesso|subito|alla prima occasione|'
          'una notte|entro sera|in giornata|ora');

  /// Le parole che si possono scrivere con la maiuscola senza essere un nome
  /// proprio della persona.
  static const Set<String> _nomiDiCasa = {
    'mondo',
    'sotto',
    'cerchio',
    'medora',
    'aura',
    'caligo',
    'sole',
    'luna',
    'esoteric',
    'circle',
  };

  static const Set<String> _paroleVuote = {
    'devo',
    'dovrei',
    'posso',
    'potrei',
    'voglio',
    'vorrei',
    'sono',
    'essere',
    'questa',
    'questo',
    'quella',
    'quello',
    'quando',
    'come',
    'cosa',
    'perché',
    'perche',
    'anche',
    'ancora',
    'sempre',
    'molto',
    'tutto',
    'tutti',
    'dopo',
    'prima',
    'oppure',
    'senza',
    'fare',
    'faccio',
    'sapere',
    'capire',
    'dove',
    'mesi',
    'anni',
    'giorni',
    'adesso',
    'davvero',
    'nella',
    'nello',
    'della',
    'dello',
    'delle',
    'degli',
    'alla',
    'allo',
    'alle',
    'agli',
    'sulla',
    'sullo',
    'dalla',
    'dallo',
    'nelle',
    'negli',
    'loro',
    'altro',
    'altra',
    'altri',
    'niente',
    'nulla',
    'qualcosa',
    'quale',
    'quali',
    'quanto',
    'quanta',
  };

  /// Le parole piene di un testo, da quattro lettere in su, per radice.
  static Set<String> _radici(String s) => {
        for (final m in RegExp('[$_l]{4,}').allMatches(s.toLowerCase()))
          if (!_paroleVuote.contains(m.group(0)))
            m.group(0)!.length > 5 ? m.group(0)!.substring(0, 5) : m.group(0)!,
      };

  /// **LE GUARDIE COMUNI AI TRE TESTI.**
  static MotivoDelloScarto? _comuni(
    String t, {
    required String domanda,
    required CourtesyForm forma,
    Set<String> nomiAmmessi = const {},
  }) {
    if (t.contains('\u2014') || t.contains('\u2013')) {
      return MotivoDelloScarto.trattinoLungo;
    }
    if (RegExp(r',\s+e[d]?\s', caseSensitive: false).hasMatch(t)) {
      return MotivoDelloScarto.virgolaEe;
    }
    for (final frase in t.split(RegExp(r'[.!?]'))) {
      if (':'.allMatches(frase).length > 1) {
        return MotivoDelloScarto.dueDuePunti;
      }
    }
    if (_primaPersona.hasMatch(t)) return MotivoDelloScarto.primaPersona;
    if (_certezza.hasMatch(t)) return MotivoDelloScarto.previsioneCerta;
    if (_diagnosi.hasMatch(t)) return MotivoDelloScarto.diagnosi;
    if (_promessa.hasMatch(t)) return MotivoDelloScarto.promessa;
    if (_nomeProprioInventato(t, domanda, nomiAmmessi)) {
      return MotivoDelloScarto.nomeProprio;
    }
    if (formeContrarieAllaForma(t, forma).isNotEmpty) {
      return MotivoDelloScarto.genereContrario;
    }
    if (_gergo.hasMatch(t)) return MotivoDelloScarto.gergo;
    if (_decisioneGrave.hasMatch(t)) return MotivoDelloScarto.decisioneGrave;
    if (_fuocoComeInvito.hasMatch(t)) return MotivoDelloScarto.fuoco;
    if (statoDiUnTerzo(t, domanda)) return MotivoDelloScarto.statoDiUnTerzo;
    return null;
  }

  /// **IL FUOCO, IL GERGO E LA DECISIONE GRAVE IN UN TESTO QUALSIASI**, per
  /// la prova che la voce di casa ne sia pulita: ordine DN voce 08.
  static MotivoDelloScarto? fuocoGergoDecisione(String t) {
    if (_gergo.hasMatch(t)) return MotivoDelloScarto.gergo;
    if (_decisioneGrave.hasMatch(t)) return MotivoDelloScarto.decisioneGrave;
    if (_fuocoNelGesto.hasMatch(t)) return MotivoDelloScarto.fuoco;
    return null;
  }

  /// **NESSUNO STATO ATTRIBUITO A UN TERZO.** Ordine DN voce 02.
  ///
  /// L'app non sa niente della sorella di chi scrive: dire cosa succede
  /// dentro un'altra persona e' una bugia detta con la faccia seria. Si
  /// guarda ogni frase che ha per soggetto un terzo, per nome o per
  /// pronome, o una cosa sua (*"il desiderio di tua sorella"*): e' ammessa
  /// solo se il suo predicato dice cio' che chi legge puo' o non puo' fare.
  ///
  ///     "La porta di tua sorella non e' tua da aprire."      ammessa
  ///     "Il desiderio di tua sorella e' un processo..."      scartata
  static bool statoDiUnTerzo(String t, String domanda) {
    final nomi = [
      for (final m in RegExp('(?<=[a-zàèéìòù,;] )([A-ZÀ-Ý][a-zà-ÿ]+)')
          .allMatches(domanda))
        m.group(1)!,
    ];
    final terzo = [
      _terzoPerRelazione,
      for (final n in nomi) RegExp.escape(n),
    ].join('|');
    // **E IL POSSESSIVO DEL TERZO COME SOGGETTO**: *"La sua rabbia non e'
    // la tua"*, alla domanda *"Mia madre e' arrabbiata con me?"*, da' per
    // certo che la madre sia arrabbiata. Dalla sonda dell'ordine DN. **Conta
    // solo se la domanda ha un terzo**: alla domanda *"Ho una scelta
    // davanti"* la frase *"Il suo senso apparira' dopo"* parla della scelta,
    // e la misura dell'ordine DN la scartava.
    final domandaConUnTerzo = nomi.isNotEmpty ||
        RegExp('(?<![$_l])(?:$_parenti|persona|persone|lui|lei)(?![$_l])',
                caseSensitive: false)
            .hasMatch(domanda);
    final delPossessivo = domandaConUnTerzo
        ? '|^(?:il|la|lo|i|gli|le|l.)\\s?(?:suo|sua|suoi|sue) [$_l]+'
        : '';
    final soggetto = RegExp(
        '^(?:(?:non|ma|e|anche|ora|oggi) )?(?:$terzo)(?![$_l])|'
        '^(?:il|la|lo|i|gli|le|l.)\\s?[$_l]+ (?:di|del|della|dello|dei|delle) '
        '(?:$terzo)(?![$_l])$delPossessivo',
        caseSensitive: false);
    final terzoOvunque =
        RegExp('(?<![$_l])(?:$terzo)(?![$_l])', caseSensitive: false);
    // **E LA COSA DEL TERZO RIPRESA COL DIMOSTRATIVO**, ordine DN voce 08:
    // *"Quella rabbia non parla di te ma di lei"*, alla domanda *"Mia madre
    // e' arrabbiata con me"*, alla prova a video della build 2252. Il
    // soggetto e' la rabbia della madre, detta prima col suo nome.
    final delTerzo = RegExp(
        '(?<![$_l])(?:di|del|della|dello|dei|delle) (?:$terzo)(?![$_l])|'
        '(?<![$_l])(?:sua|suo|suoi|sue)(?![$_l])',
        caseSensitive: false);
    final dimostrativo = RegExp(
        '^(?:quella|quel|quello|quell.|questa|questo|quest.|quelle|quei|'
        'quegli|queste|questi) ',
        caseSensitive: false);
    for (final grezza in t.split(RegExp(r'[.!?;]'))) {
      final frase = grezza.trim();
      if (frase.isEmpty) continue;
      // Solo la cosa DEL terzo, *"di lei"*, *"sua"*: *"Quella notizia spetta
      // a tua sorella"* dice a chi tocca darla, e passa.
      final dellaCosaDelTerzo = domandaConUnTerzo &&
          dimostrativo.hasMatch(frase) &&
          delTerzo.hasMatch(frase);
      if (!soggetto.hasMatch(frase) && !dellaCosaDelTerzo) continue;
      final predicato = frase.replaceAll(terzoOvunque, ' ');
      if (!_predicatoDiChiLegge.hasMatch(predicato)) return true;
    }
    return false;
  }

  /// **IL TITOLO NON CONTIENE UN PEZZO DELLA SCENA.** Ordine DN voce 03. Si
  /// confronta per radici: *"la porta socchiusa"* nella scena e *"la
  /// porta"* nel titolo sono lo stesso pezzo. Le immagini comuni restano
  /// libere quando non sono il pezzo di oggi.
  static bool titoloToccaLaScena(String titolo, List<String> nomiDeiPezzi) {
    final delTitolo = _radici(titolo);
    for (final n in nomiDeiPezzi) {
      if (_radici(n).intersection(delTitolo).isNotEmpty) return true;
    }
    return false;
  }

  /// **UN NOME PROPRIO CHE LA PERSONA NON HA SCRITTO**: una parola con la
  /// maiuscola dentro una frase, che non viene dalla domanda.
  static bool _nomeProprioInventato(
      String t, String domanda, Set<String> nomiAmmessi) {
    final nellaDomanda = {
      for (final m in RegExp('[A-Za-zÀ-ÿ]+').allMatches(domanda))
        m.group(0)!.toLowerCase(),
    };
    for (final m
        in RegExp(r'(?<=[a-zàèéìòù,;] )([A-ZÀ-Ý][a-zà-ÿ]+)').allMatches(t)) {
      final w = m.group(1)!.toLowerCase();
      if (nellaDomanda.contains(w)) continue;
      if (_nomiDiCasa.contains(w)) continue;
      if (nomiAmmessi.contains(w)) continue;
      return true;
    }
    return false;
  }

  /// **IL TITOLO**: al massimo sei parole, gia' una risposta, non una domanda,
  /// senza i due punti dell'ordine DK voce 01.
  static MotivoDelloScarto? delTitolo(
    String t, {
    required String domanda,
    required CourtesyForm forma,
    Set<String> nomiAmmessi = const {},
  }) {
    if (t.trim().isEmpty) return MotivoDelloScarto.vuota;
    if (t.contains('?')) return MotivoDelloScarto.eUnaDomanda;
    if (t.contains(':')) return MotivoDelloScarto.duePuntiNelTitolo;
    final parole = t.trim().split(RegExp(r'\s+')).length;
    if (parole > paroleDelTitolo) return MotivoDelloScarto.troppoLunga;
    return _comuni(t, domanda: domanda, forma: forma, nomiAmmessi: nomiAmmessi);
  }

  /// **LA RISPOSTA**: tre frasi al massimo, nomina la cosa di cui si e'
  /// chiesto, e non anticipa la scena.
  static MotivoDelloScarto? dellaRisposta(
    String r, {
    required String domanda,
    required CourtesyForm forma,
    String? oggetto,
    String? tema,
    List<String> nomiDellaScena = const [],
    Set<String> nomiAmmessi = const {},
  }) {
    if (r.trim().isEmpty) return MotivoDelloScarto.vuota;
    final frasi = RegExp(r'[.!?]+(\s|$)').allMatches(r.trim()).length;
    if (frasi > frasiDellaRisposta || r.split(RegExp(r'\s+')).length > 45) {
      return MotivoDelloScarto.troppoLunga;
    }
    final comune =
        _comuni(r, domanda: domanda, forma: forma, nomiAmmessi: nomiAmmessi);
    if (comune != null) return comune;
    // **NOMINA LA COSA**: almeno una parola piena della domanda, o
    // dell'oggetto che il classificatore ne ha tratto.
    // **E DEL TEMA**, ordine DN voce 05: *"Quel qualcosa che ti blocca"*
    // al tema del blocco nomina la domanda, e cadeva perche' la domanda
    // scritta dice *"non riesco a superare"*.
    final della = _radici('$domanda ${oggetto ?? ''} ${tema ?? ''}');
    if (della.isNotEmpty && _radici(r).intersection(della).isEmpty) {
      return MotivoDelloScarto.nonNominaLaDomanda;
    }
    final basso = r.toLowerCase();
    for (final n in nomiDellaScena) {
      if (n.length > 3 && basso.contains(n.toLowerCase())) {
        return MotivoDelloScarto.anticipaLaScena;
      }
    }
    return null;
  }

  /// **IL GESTO**: una cosa sola, concreta, col suo tempo dentro; non un
  /// consiglio di vita; niente che tocchi un terzo o la salute, i soldi, la
  /// legge. Ordine DL voce 13.
  static MotivoDelloScarto? dellAzione(
    String a, {
    required String domanda,
    required CourtesyForm forma,
    Set<String> nomiAmmessi = const {},
  }) {
    if (a.trim().isEmpty) return MotivoDelloScarto.vuota;
    final frasi = RegExp(r'[.!?]+(\s|$)').allMatches(a.trim()).length;
    if (frasi > frasiDelGesto || a.split(RegExp(r'\s+')).length > 30) {
      return MotivoDelloScarto.troppoLunga;
    }
    if (a.contains('?')) return MotivoDelloScarto.eUnaDomanda;
    final comune =
        _comuni(a, domanda: domanda, forma: forma, nomiAmmessi: nomiAmmessi);
    if (comune != null) return comune;
    if (_riflessione.hasMatch(a.trim())) {
      return MotivoDelloScarto.consiglioDiVita;
    }
    if (_fuocoNelGesto.hasMatch(a)) return MotivoDelloScarto.fuoco;
    if (_terzi.hasMatch(a)) return MotivoDelloScarto.toccaUnTerzo;
    if (_saluteDenaroLegge.hasMatch(a)) {
      return MotivoDelloScarto.saluteDenaroLegge;
    }
    if (!indicazioneDiTempo.hasMatch(a)) return MotivoDelloScarto.senzaTempo;
    return null;
  }

  /// **LEGGE I TRE TESTI** della risposta del modello e li fa passare dalle
  /// guardie, uno per uno. Senza domanda non si leggono: la discesa soltanto
  /// per incontrarlo ha la sua voce, quella di casa.
  static TestiDelModello leggi(
    Map<dynamic, dynamic> dati, {
    required String domanda,
    required CourtesyForm forma,
    String? oggetto,
    String? tema,
    List<String> nomiDellaScena = const [],
    Set<String> nomiAmmessi = const {},
    List<String> titoliGiaDati = const [],
  }) {
    if (domanda.trim().isEmpty) return TestiDelModello.nessuno;
    // **IL TITOLO NON SI RIPETE**, ordine DL voce 07, misura F: si
    // confronta senza maiuscole e senza punteggiatura.
    String piano(String t) =>
        t.toLowerCase().replaceAll(RegExp(r'[^a-zàèéìòù ]'), '').trim();
    final gia = {for (final t in titoliGiaDati) piano(t)};
    final scarti = <RigaScartata>[];
    String? prendi(String pezzo, MotivoDelloScarto? Function(String) guardia) {
      final grezzo = dati[pezzo];
      if (grezzo is! String || grezzo.trim().isEmpty) return null;
      var t = grezzo.trim().replaceAll(RegExp(r'\s+'), ' ');
      if (pezzo == 'titolo') {
        t = t.replaceAll(RegExp(r'[.!]+$'), '').trim();
        t = t.replaceAll(RegExp('^[«"“]|[»"”]\$'), '');
      }
      final motivo = guardia(t);
      if (motivo != null) {
        scarti.add(RigaScartata(pezzo, motivo, t));
        return null;
      }
      return t;
    }

    return TestiDelModello(
      titolo: prendi(
          'titolo',
          (t) =>
              delTitolo(t,
                  domanda: domanda, forma: forma, nomiAmmessi: nomiAmmessi) ??
              (gia.contains(piano(t))
                  ? MotivoDelloScarto.titoloRipetuto
                  : null)),
      risposta: prendi(
          'risposta',
          (r) => dellaRisposta(r,
              domanda: domanda,
              forma: forma,
              oggetto: oggetto,
              tema: tema,
              nomiDellaScena: nomiDellaScena,
              nomiAmmessi: nomiAmmessi)),
      azione: prendi(
          'azione',
          (a) => dellAzione(a,
              domanda: domanda, forma: forma, nomiAmmessi: nomiAmmessi)),
      scarti: scarti,
    );
  }
}
