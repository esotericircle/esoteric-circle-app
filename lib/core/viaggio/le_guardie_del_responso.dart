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

  /// Quante frasi al massimo ha una risposta: due, dall'ordine.
  static const int frasiDellaRisposta = 2;

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
  static final RegExp _terzi =
      _parole('confronta[a-zàèéìòù]*|accusa[a-zàèéìòù]*|pretend[a-zàèéìòù]*|'
          'rompi|rompere|chiudi con|chiudere con|mollal[oa]|'
          // **"LASCIALO" SOLO QUANDO E' UNA PERSONA**, ordine DL voce 13:
          // la prova a cento discese scartava *"Lascialo sul comodino"*,
          // che parla di un foglio. Resta quando chiude la frase, *"Poi
          // lascialo."*, o quando va con perdere, andare, stare.
          'lascia(lo|la)(?= *[.!;]| *(?!.))|lascia(lo|la) (perdere|andare|stare)|'
          'affronta[a-zàèéìòù]*|smaschera[a-zàèéìòù]*|rivela[a-zàèéìòù]*|'
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
    return null;
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

  /// **LA RISPOSTA**: due frasi al massimo, nomina la cosa di cui si e'
  /// chiesto, e non anticipa la scena.
  static MotivoDelloScarto? dellaRisposta(
    String r, {
    required String domanda,
    required CourtesyForm forma,
    String? oggetto,
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
    final della = _radici('$domanda ${oggetto ?? ''}');
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
    if (frasi > 2 || a.split(RegExp(r'\s+')).length > 30) {
      return MotivoDelloScarto.troppoLunga;
    }
    if (a.contains('?')) return MotivoDelloScarto.eUnaDomanda;
    final comune =
        _comuni(a, domanda: domanda, forma: forma, nomiAmmessi: nomiAmmessi);
    if (comune != null) return comune;
    if (_riflessione.hasMatch(a.trim())) {
      return MotivoDelloScarto.consiglioDiVita;
    }
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
