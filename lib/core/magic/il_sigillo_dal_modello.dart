import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../chat/il_blocco_di_cortesia.dart';
import '../chat/le_forme_del_genere.dart';
import '../chat/user_profile.dart';
import '../config/la_regione_dei_dati.dart';
import '../viaggio/la_domanda_capita.dart';
import '../viaggio/le_guardie_del_responso.dart';
import 'intention_sigil.dart';
import 'la_voce_del_sigillo.dart';

/// La firma di una chiamata al modello: l'istruzione e la richiesta, la
/// risposta come testo JSON. Le prove ne passano una finta.
typedef ChiamataDelSigillo = Future<String?> Function(
    String istruzione, String richiesta, Map<String, Schema> campi);

/// **IL TITOLO E IL RESPONSO**, con da dove vengono.
typedef TestiDelSigillo = ({
  String titolo,
  String responso,
  bool titoloDalModello,
  bool responsoDalModello,
  List<RigaScartata> scarti,
});

/// **I TESTI DEL SIGILLO SCRITTI SULL'INTENZIONE VERA.** Ordine DO voci 09 e
/// 10, 15 settembre 2026.
///
/// Il titolo e il responso li scrive il modello **sull'intenzione che la
/// persona ha scritto, non sulla categoria**; lo stesso vale per il testo del
/// compimento. **Valgono tutte le guardie gia' scritte per il Viaggio**,
/// senza riscriverle: niente previsione certa, niente promessa, niente
/// diagnosi, niente prima persona, niente nome inventato, niente fuoco da
/// accendere, nessuno stato attribuito a un terzo, niente gergo. **E vale la
/// riserva**: i testi di casa valgono quando il modello non risponde in
/// tempo, quando la rete manca e quando una guardia scarta la riga.
///
/// **Il modello e la regione** sono quelli di ogni altra chiamata dell'app,
/// Gemini 2.5 su europe-west1, e ricevono il blocco di cortesia della voce
/// DL.04.
abstract final class IlSigilloDalModello {
  static const String modello = 'gemini-2.5-flash';

  /// Quanto si aspetta: il tempo del tracciamento, che la persona sta gia'
  /// guardando, piu' un margine.
  static const Duration pazienza = Duration(seconds: 8);

  /// **IL TETTO DELLE RIFORMULAZIONI**, voce DO.09: tre per sigillo; oltre,
  /// la persona tiene la sua frase come l'ha scritta.
  static const int riformulazioniPerSigillo = 3;

  static String _cortesia(CourtesyForm forma) =>
      '${IlBloccoDiCortesia.intestazione}\n${IlBloccoDiCortesia.riga(forma)}';

  /// L'istruzione del titolo e del responso.
  static String istruzioneDeiTesti(CourtesyForm forma) => '''
Sei Caligo, il Maestro delle rune e della magia di Esoteric Circle. Una persona ha scritto un'intenzione e ne ha tracciato il sigillo col metodo di Austin Osman Spare. Scrivi due testi in italiano, rivolti a lei col tu.

TITOLO: al massimo sei parole, senza punto finale, senza due punti. Nomina la cosa dell'intenzione, non la categoria, e non ripete l'intenzione parola per parola. Nessuna parola di tempo.
RESPONSO: due o tre frasi, al massimo quaranta parole. Nomina la cosa che la persona ha scritto, voltata alla seconda persona e senza virgolette: le sue parole, non una categoria. Dice cosa il segno custodisce, mai cosa accadrà: nessun futuro certo, nessuna promessa su salute, denaro, morte, gravidanza o cause legali, nessuna diagnosi. Mai la prima persona. Mai un nome proprio che la persona non ha scritto, e non nominare la via: la persona la conosce già. Nessun fuoco da accendere o bruciare. Di un'altra persona non dire niente di ciò che prova, pensa o vuole. Niente gergo: niente "il tuo vero io", "ascolta il tuo cuore", "è tempo di", "apriti a", "lascia andare", "abbraccia il cambiamento", "energia", "vibrazione", "manifestare", "la tua verità". Scrivi un italiano semplice: mai "esso", mai "il tuo" seguito da un verbo.

${_cortesia(forma)}
Rispondi solo con un oggetto JSON con i campi "titolo" e "responso".''';

  /// L'istruzione del testo del compimento.
  static String istruzioneDelCompimento(CourtesyForm forma) => '''
Sei Caligo, il Maestro delle rune e della magia di Esoteric Circle. Una persona dichiara che l'intenzione del suo sigillo si è compiuta. Scrivi una sola riga in italiano, rivolta a lei col tu, al massimo trenta parole, al passato prossimo: di' cosa è accaduto con le parole che aveva scritto, voltate alla seconda persona e senza virgolette. Per esempio, a "Trovo il coraggio di dire quello che sento": "Hai trovato il coraggio di dire quello che senti.". Non una congratulazione generica. Mai "il tuo" seguito da un verbo. È accaduto a chi legge: non dire che il sigillo lo ha fatto, previsto o manifestato. Le persone restano quelle che ha scritto, nel numero e nel genere in cui le ha scritte. Mai la prima persona. Nessun futuro, nessuna promessa. Di un'altra persona non dire niente di ciò che prova, pensa o vuole. Niente gergo: niente "energia", "manifestare", "universo".

${_cortesia(forma)}
Rispondi solo con un oggetto JSON con il campo "testo".''';

  /// L'istruzione della riformulazione.
  static String istruzioneDellaRiformulazione(CourtesyForm forma) => '''
Sei Caligo, il Maestro delle rune e della magia di Esoteric Circle. Una persona ha scritto un'intenzione per un sigillo. Riscrivila come si scrive un'intenzione nel metodo di Austin Osman Spare: una frase sola, al presente, in prima persona, detta come se fosse già vera, al massimo quindici parole. Tieni le parole della persona e il loro senso: non aggiungere niente che non abbia scritto, niente colori, erbe, natura, protezione o chiarezza se non ci sono nella sua frase. Non cominciare con "Io". Un sigillo agisce su chi lo traccia: se l'intenzione chiede di cambiare la volontà di un'altra persona, riportala su chi scrive. Niente fuoco, niente gergo motivazionale, nessuna promessa su salute, denaro, morte, gravidanza o cause legali.

${_cortesia(forma)}
Rispondi solo con un oggetto JSON con il campo "riformulata".''';

  static String richiesta(String intenzione, ViaMagica via) =>
      'Intenzione: ${intenzione.trim()}\nVia: ${via.nome}, ${via.dominio}';

  /// **QUANTE VOLTE SI CHIEDE IL TITOLO E IL RESPONSO**: due. Alla sonda del
  /// 15 settembre 2026 le guardie scartavano due responsi su tre, quasi
  /// sempre per una parola sola, e chi traccia leggeva la voce di casa. Una
  /// seconda chiamata costa un ventesimo di centesimo e si fa solo per il
  /// pezzo scartato; se la rete manca non si ritenta.
  static const int tentativiDeiTesti = 2;

  /// **IL TITOLO E IL RESPONSO**, ognuno dal modello solo se regge alle
  /// guardie; altrimenti la voce di casa.
  static Future<TestiDelSigillo> scrivi({
    required String intenzione,
    required ViaMagica via,
    required CourtesyForm forma,
    ChiamataDelSigillo? chiamata,
  }) async {
    final scarti = <RigaScartata>[];
    String? titolo;
    String? responso;
    for (var tentativo = 0;
        tentativo < tentativiDeiTesti && (titolo == null || responso == null);
        tentativo++) {
      Map<String, Object?>? j;
      try {
        final testo = await (chiamata ?? _chiamataVera)(
          istruzioneDeiTesti(forma),
          richiesta(intenzione, via),
          {'titolo': Schema.string(), 'responso': Schema.string()},
        ).timeout(pazienza);
        j = _json(testo);
      } catch (errore) {
        // Rete assente, tempo scaduto, servizio spento: parla la voce di
        // casa, e non si ritenta.
        break;
      }
      var t = (j?['titolo'] as String?)?.trim();
      if (titolo == null && t != null) {
        t = t.replaceAll(RegExp(r'[.]+$'), '');
        final m = LeGuardieDelResponso.delTitolo(t,
                domanda: intenzione, forma: forma) ??
            (ripeteLIntenzione(t, intenzione)
                ? MotivoDelloScarto.primaPersona
                : null) ??
            scartoDelSigillo(t, intenzione);
        if (m == null) {
          titolo = t;
        } else {
          scarti.add(RigaScartata('titolo', m, t));
        }
      }
      var r = (j?['responso'] as String?)?.trim();
      if (responso == null && r != null) {
        // **"ESSO" IN APERTURA DIVENTA "IL SEGNO"**: il referente e' sempre
        // il sigillo, e alla sonda il modello lo scriveva in un responso su
        // tre anche con l'istruzione che lo vieta.
        r = r.replaceAllMapped(
            RegExp(r'(^|[.!?] )Esso '), (x) => '${x.group(1)}Il segno ');
        final m = LeGuardieDelResponso.dellaRisposta(r,
                domanda: intenzione, forma: forma) ??
            scartoDelSigillo(r, intenzione);
        if (m == null) {
          responso = r;
        } else {
          scarti.add(RigaScartata('risposta', m, r));
        }
      }
    }
    return (
      titolo: titolo ?? LaVoceDelSigillo.titoloDiCasa(via, intenzione),
      responso: responso ?? LaVoceDelSigillo.responsoDiCasa(via, intenzione),
      titoloDalModello: titolo != null,
      responsoDalModello: responso != null,
      scarti: scarti,
    );
  }

  /// **IL TESTO DEL COMPIMENTO**, dal modello se regge alle guardie.
  static Future<({String testo, bool dalModello})> compimento({
    required String intenzione,
    required CourtesyForm forma,
    ChiamataDelSigillo? chiamata,
  }) async {
    try {
      final r = await (chiamata ?? _chiamataVera)(
        istruzioneDelCompimento(forma),
        'Intenzione: ${intenzione.trim()}',
        {'testo': Schema.string()},
      ).timeout(pazienza);
      final testo = (_json(r)?['testo'] as String?)?.trim();
      if (testo != null &&
          testo.isNotEmpty &&
          scartoDelCompimento(testo, intenzione: intenzione, forma: forma) ==
              null) {
        return (testo: testo, dalModello: true);
      }
    } catch (errore) {
      // La riserva nomina l'intenzione lo stesso.
    }
    return (testo: LaVoceDelSigillo.compimento(intenzione), dalModello: false);
  }

  /// **LA RIFORMULAZIONE DI CALIGO**, voce DO.09. Nulla se il modello non
  /// risponde o se la riga non regge: allora la persona tiene la sua frase.
  ///
  /// Le guardie del responso qui non valgono tutte: l'intenzione riformulata
  /// e' in prima persona per costruzione, come vuole il metodo. Valgono
  /// quelle di sostanza: niente fuoco, niente gergo, nessuna decisione grave,
  /// nessuna previsione certa, e **nessuna richiesta sulla volonta' di un
  /// altro**, che e' il filtro di `LettoreIntenzione`.
  static Future<String?> riformula({
    required String intenzione,
    required ViaMagica via,
    required CourtesyForm forma,
    ChiamataDelSigillo? chiamata,
  }) async {
    // **SUI TEMI DELICATI CALIGO NON RISCRIVE**, e non chiama nemmeno.
    if (temaDelicato(intenzione)) return null;
    try {
      // **LA VIA NON ENTRA NELLA RICHIESTA**: alla sonda il modello la
      // metteva dentro la frase, *"con le erbe e la natura"*.
      final r = await (chiamata ?? _chiamataVera)(
        istruzioneDellaRiformulazione(forma),
        'Intenzione: ${intenzione.trim()}',
        {'riformulata': Schema.string()},
      ).timeout(pazienza);
      final grezza = (_json(r)?['riformulata'] as String?)
          ?.trim()
          .replaceAll(RegExp(r'^"|"$'), '');
      if (grezza == null || grezza.isEmpty) return null;
      // **"IO" IN APERTURA SI TOGLIE**: in italiano il soggetto sta nel
      // verbo, e alla sonda ventidue riformulazioni su trenta cominciavano
      // cosi'. Togliere una parola non cambia il senso.
      final testo = grezza.replaceFirstMapped(
          RegExp(r'^Io\s+(?!e\s)(\S)'), (m) => m.group(1)!.toUpperCase());
      if (testo.split(RegExp(r'\s+')).length > 18) return null;
      if (IntentionSigil.cammino(testo).length < 2) return null;
      if (LettoreIntenzione.leggi(testo).eStataRiformulata) return null;
      if (LeGuardieDelResponso.diSostanza(testo) != null) return null;
      if (gergoDelSigillo(testo) != null) return null;
      // **UN TERZO NON E' IL SOGGETTO DEL SIGILLO**: alla seconda sonda
      // *"Voglio che Marco torni da me"* e' diventato *"Marco torna da me"*,
      // cioe' proprio la volonta' di un altro che la riformulazione deve
      // riportare su chi scrive.
      if (LeGuardieDelResponso.statoDiUnTerzo(testo, intenzione)) return null;
      // **E NESSUN "IO" RIMASTO**: *"Con mia sorella in pace io sono"*, alla
      // stessa sonda. In italiano il soggetto sta nel verbo, e un "io" in
      // mezzo o in fondo segna una frase rovesciata.
      if (RegExp(r'(?<![a-zàèéìòù])io(?![a-zàèéìòù])', caseSensitive: false)
          .hasMatch(testo)) {
        return null;
      }
      if (_laViaNellaFrase.hasMatch(testo) &&
          !_laViaNellaFrase.hasMatch(intenzione)) {
        return null;
      }
      if (!generePermesso(genereDellaPrimaPersona(testo), forma)) return null;
      return testo;
    } catch (errore) {
      // Rete assente o risposta illeggibile: la persona tiene la sua frase,
      // che e' esattamente la riserva che la voce DO.09 chiede.
      return null;
    }
  }

  /// **I TEMI DELICATI**: salute, figli da avere, cause, denaro, morte. Su
  /// questi la riformulazione del metodo, *"detta come se fosse gia'
  /// vera"*, diventa una promessa: alla sonda del 15 settembre 2026 il
  /// modello ha scritto *"Io vinco la mia causa"*, *"Sono fertile"*, *"Io
  /// sono ora completamente guarita"*. La voce DO.10 vieta le promesse su
  /// quei temi, e l'istruzione da sola non e' bastata: la frase resta quella
  /// della persona.
  static bool temaDelicato(String intenzione) =>
      _temiDelicati.hasMatch(intenzione.toLowerCase());

  static final RegExp _temiDelicati =
      RegExp(r'(?<![a-zàèéìòù])(?:guari[a-zàèéìòù]*|salute|malat[a-zàèéìòù]*|'
          r'cancro|tumor[a-zàèéìòù]*|depression[ei]|fertil[a-zàèéìòù]*|'
          r'gravidanz[ae]|incinta|(?:un|una) (?:figli[oa]|bambin[oa])|'
          r'caus[ae] (?:contro|legal[ei])|la causa|tribunal[ei]|avvocat[oaie]|'
          r'sentenz[ae]|denunc[a-zàèéìòù]*|soldi|denaro|euro|debit[oi]|'
          r'eredità|lotteria|guadagn[a-zàèéìòù]*|morte|morir[a-zàèéìòù]*)'
          r'(?![a-zàèéìòù])');

  /// Le parole della via, che la persona non ha scritto e il modello
  /// aggiungeva.
  static final RegExp _laViaNellaFrase = RegExp(
      r'via (?:rossa|bianca|verde)|erbe|natura|protezione e chiarezza|'
      r'chiarezza e protezione|cuore e desiderio',
      caseSensitive: false);

  /// **IL TITOLO CHE RIPETE L'INTENZIONE**: *"Ritrovo la salute"* sopra
  /// l'intenzione *"Ritrovo la salute"*, alla sonda. E' la frase di chi
  /// scrive, in prima persona, messa in bocca a Caligo.
  static bool ripeteLIntenzione(String titolo, String intenzione) {
    String n(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zàèéìòù ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final t = n(titolo);
    return t.isNotEmpty && n(intenzione).startsWith(t);
  }

  /// **IL GERGO E IL POTERE DEL SIGILLO**, che la sonda ha trovato nei testi
  /// accettati: *"Che la tua energia fluisca"*, *"come il sigillo aveva
  /// predetto"*, *"si e' manifestata"*, *"Esso racchiude la potenza"*. Il
  /// sigillo e' un esercizio di intenzione: non predice e non fa accadere,
  /// e dirlo a chi ha visto la cosa compiersi sarebbe una bugia gentile.
  static MotivoDelloScarto? gergoDelSigillo(String t) {
    final b = t.toLowerCase();
    if (_gergoDelSigillo.hasMatch(b)) return MotivoDelloScarto.gergo;
    if (_ilPotereDelSigillo.hasMatch(b)) {
      return MotivoDelloScarto.previsioneCerta;
    }
    return null;
  }

  /// **CALIGO NON DICE IO NEMMENO COL VERBO**: *"Sono lieta che la tua
  /// intenzione si sia compiuta"*, compimento accettato alla sesta sonda.
  /// La guardia del Viaggio guarda i pronomi, e qui il pronome non c'era.
  /// Vale per i testi di Caligo, non per la riformulazione, che e' la voce
  /// di chi scrive e sta in prima persona per costruzione.
  static bool caligoDiceIo(String t) =>
      _verboInPrimaPersona.hasMatch(t.toLowerCase());

  static final RegExp _verboInPrimaPersona =
      RegExp(r'(?:^|[.!?] )(?:sono|ho|credo|penso|spero|sento|vedo|so)'
          r'(?![a-zàèéìòù])');

  static final RegExp _gergoDelSigillo = RegExp(
      r'(?<![a-zàèéìòù])(?:energi[ae]|vibra[a-zàèéìòù]*|manifest[a-zàèéìòù]*|'
      r'la tua verità|voce interiore|universo|pergamena|'
      r'potenza del tuo|promessa|tuo percorso|assicur[a-zàèéìòù]*|'
      r'saggezza profonda|forza interiore)'
      r'(?![a-zàèéìòù])|^che |[.!] che |'
      // **"ESSO" COME SOGGETTO**, arcaico: *"Esso racchiude la potenza"*.
      // Dopo una preposizione e' italiano buono, *"in esso risiede"*, e alla
      // terza sonda la regola larga ne scartava sette.
      r'(?:^|[.!?] )ess[oa] ');

  static final RegExp _ilPotereDelSigillo =
      RegExp(r'(?:sigillo|segno) (?:ha|aveva|avrà) (?:predetto|previsto|fatto|'
          r'manifestato|realizzato|assolto|portato|compiuto)|'
          r'come (?:scritto|predetto|previsto)(?![a-zàèéìòù])|'
          r'il suo potere|potere del (?:segno|sigillo)|'
          r'(?:sigillo|segno) potente');

  /// **LE PERSONE RESTANO QUELLE SCRITTE**: *"Proteggo i miei figli"* e'
  /// diventato *"Hai protetto le tue figlie"* a un profilo femminile, alla
  /// sonda. Si guarda la famiglia di parole delle persone vicine.
  static bool cambiaLePersone(String testo, String intenzione) {
    const radici = [
      'figli',
      'fratell',
      'sorell',
      'nipot',
      'cugin',
      'zi',
      'amic',
      'compagn',
      'marit',
      'mogli',
      'nonn',
      'bambin',
      'ragazz',
    ];
    final parole = RegExp(r'[a-zàèéìòù]+');
    final nellIntenzione =
        parole.allMatches(intenzione.toLowerCase()).map((m) => m[0]!).toSet();
    final nelTesto =
        parole.allMatches(testo.toLowerCase()).map((m) => m[0]!).toSet();
    for (final r in radici) {
      final prima = nellIntenzione
          .where((w) => w.startsWith(r) && w.length <= r.length + 2)
          .toSet();
      if (prima.isEmpty) continue;
      final dopo =
          nelTesto.where((w) => w.startsWith(r) && w.length <= r.length + 2);
      if (dopo.any((w) => !prima.contains(w))) return true;
    }
    return false;
  }

  /// **LE GUARDIE DEL SIGILLO SUL TITOLO E SUL RESPONSO**, trovate dalle due
  /// sonde del 15 settembre 2026 nei testi che le guardie del Viaggio
  /// lasciavano passare.
  static MotivoDelloScarto? scartoDelSigillo(String t, String intenzione) {
    final b = t.toLowerCase();
    final i = intenzione.toLowerCase();
    return (caligoDiceIo(t) ? MotivoDelloScarto.primaPersona : null) ??
        gergoDelSigillo(t) ??
        (verboFattoNome(t) ? MotivoDelloScarto.sgrammaticato : null) ??
        // La via dentro il testo, quando la persona non l'ha scritta: *"le
        // erbe e la natura ti sono vicine"* sopra *"Ritrovo la salute"*.
        (_laViaNellaFrase.hasMatch(t) && !_laViaNellaFrase.hasMatch(intenzione)
            ? MotivoDelloScarto.nomeProprio
            : null) ??
        // **SUI TEMI DELICATI NESSUN ESITO**: *"La tua salute ritrovata"*,
        // *"La tua vittoria in causa"*, titoli accettati alla seconda sonda.
        (temaDelicato(intenzione) && _esitoDelicato.hasMatch(b)
            ? MotivoDelloScarto.promessa
            : null) ??
        // **UNA SCELTA APERTA RESTA APERTA**: *"La tua partenza da Roma"*
        // sopra *"Voglio capire se lasciare Roma"* decide per chi scrive.
        (_sceltaAperta.hasMatch(i) && !_parolaDellaScelta.hasMatch(b)
            ? MotivoDelloScarto.decisioneGrave
            : null) ??
        // L'intenzione copiata dentro il testo, in prima persona: *"La tua
        // intenzione, Trovo una casa con un giardino, e' chiara"*.
        (contieneLIntenzione(t, intenzione)
            ? MotivoDelloScarto.primaPersona
            : null);
  }

  static final RegExp _esitoDelicato = RegExp(
      r'(?<![a-zàèéìòù])(?:vittori[a-zàèéìòù]*|vint[oaie]|vincer[a-zàèéìòù]*|'
      r'vinc[io]|guari[a-zàèéìòù]*|guarigion[ei]|ritrovat[oaie]|benessere|'
      r'erbe|rimedi[oi]?|fertil[a-zàèéìòù]*|incinta|ricchezz[a-zàèéìòù]*|'
      r'guadagnat[oaie]|sconfitt[oaie]|salvat[oaie]|salv[oa]|ritrov[a-zàèéìòù]*)'
      r'(?![a-zàèéìòù])');

  static final RegExp _sceltaAperta =
      RegExp(r'(?:capire|decidere|sapere|scegliere|chiedo|chiedermi) se ');

  static final RegExp _parolaDellaScelta = RegExp(
      r'(?<![a-zàèéìòù])(?:se|scelta|scegliere|decisione|decidere|dubbio|'
      r'bivio|chiarezza|chiaro|capire|domanda|strada)(?![a-zàèéìòù])');

  static bool contieneLIntenzione(String testo, String intenzione) {
    String n(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zàèéìòù ]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final i = n(intenzione);
    return i.split(' ').length >= 3 && n(testo).contains(i);
  }

  /// **IL VERBO FATTO NOME**: *"Il tuo liberarti dall'ansia si e'
  /// compiuto"*, *"Il tuo apprendere il pianoforte"*, *"cessare il
  /// rimandare"*, alle due sonde. E' un italiano che nessuno parla. Le
  /// parole in -are, -ere, -ire che sono nomi veri restano.
  static bool verboFattoNome(String testo) {
    for (final m in _infinitoDopoLArticolo.allMatches(testo.toLowerCase())) {
      final w = m.group(1)!;
      if (w.length >= 6 && !_nomiInFinito.contains(w)) return true;
    }
    return false;
  }

  static final RegExp _infinitoDopoLArticolo =
      RegExp(r'(?<![a-zàèéìòù])(?:il|lo) (?:tuo |suo )?(?:aver |essere )?'
          r'([a-zàèéìòù]+(?:are|ere|ire|arti|erti|irti|rsi))(?![a-zàèéìòù])');

  static const Set<String> _nomiInFinito = {
    'carattere',
    'mestiere',
    'piacere',
    'potere',
    'dovere',
    'sapere',
    'volere',
    'cantiere',
    'quartiere',
    'infermiere',
    'cavaliere',
    'cameriere',
    'consigliere',
    'ingegnere',
    'bicchiere',
    'giardiniere',
    'forestiere',
    'destriere',
    'braciere',
    'candeliere',
    'messere',
    'avvenire',
    'divenire',
    'tesoriere',
    'corriere',
    'barbiere',
  };

  /// **LO SCARTO DEL TESTO DEL COMPIMENTO**, con tutte le guardie del
  /// responso e quelle trovate dalla sonda.
  static MotivoDelloScarto? scartoDelCompimento(
    String testo, {
    required String intenzione,
    required CourtesyForm forma,
  }) =>
      LeGuardieDelResponso.dellaRisposta(testo,
          domanda: intenzione, forma: forma) ??
      (caligoDiceIo(testo) ? MotivoDelloScarto.primaPersona : null) ??
      gergoDelSigillo(testo) ??
      (verboFattoNome(testo) ? MotivoDelloScarto.sgrammaticato : null) ??
      (cambiaLePersone(testo, intenzione)
          ? MotivoDelloScarto.nonNominaLaDomanda
          : null);

  /// **IL GENERE DELLA PRIMA PERSONA**, voce DO.12: la frase riformulata e'
  /// detta da chi scrive, *"sono pronta"*, e la guardia del dizionario DL.06
  /// guarda la seconda persona. Questa guarda la prima: `'m'`, `'f'` o nullo
  /// se la frase non dice il genere.
  static String? genereDellaPrimaPersona(String testo) {
    for (final m in _primaPersona.allMatches(testo.toLowerCase())) {
      final w = m.group(1)!;
      if (_nonAggettivi.contains(w)) continue;
      if (_maschili.contains(w) ||
          (w.length > 3 && w.endsWith('o') && !_femminili.contains(w))) {
        return 'm';
      }
      if (_femminili.contains(w) || (w.length > 3 && w.endsWith('a'))) {
        return 'f';
      }
    }
    return null;
  }

  /// Se una frase col [genere] trovato si puo' dare a chi ha la [forma]:
  /// al maschile niente femminile, al femminile niente maschile, e a chi non
  /// ha scelto nessuno dei due.
  static bool generePermesso(String? genere, CourtesyForm forma) =>
      // Il genere atteso lo dice la porta del genere, `agree`, e non uno
      // switch scritto qui: ordine DL voce 01, la parola si decide in un
      // posto solo. Al neutro non si attende nessun genere.
      genere == null ||
      genere == forma.agree(masculine: 'm', feminine: 'f', neutral: '');

  /// Dopo il verbo di chi scrive possono venire avverbi quanti se ne
  /// vogliono: alla sonda *"Io sono ora completamente guarita"* passava,
  /// perche' qui ne era ammesso uno solo e da un elenco.
  static final RegExp _primaPersona = RegExp(
      r'(?<![a-zàèéìòù])(?:sono|mi sento|resto|rimango|divento|mi scopro|'
      r'mi trovo|mi sono|mi rendo|dormo|vivo|torno|rinasco)'
      r'(?:\s+(?:[a-zàèéìòù]+mente|più|già|ancora|ora|adesso|qui|finalmente|'
      r'davvero|sempre|anche|di nuovo))*'
      r'\s+([a-zàèéìòù]+)(?![a-zàèéìòù])');

  /// Le parole in *o* e in *a* che dopo il verbo non sono un aggettivo di
  /// chi scrive.
  static const Set<String> _nonAggettivi = {
    'una',
    'la',
    'lo',
    'ora',
    'ancora',
    'sempre',
    'qua',
    'dentro',
    'fuori',
    'sopra',
    'sotto',
    'molto',
    'tanto',
    'poco',
    'troppo',
    'questa',
    'questo',
    'quella',
    'quello',
    'nella',
    'nello',
    'della',
    'dello',
    'alla',
    'allo',
    'sulla',
    'sullo',
    'dalla',
    'dallo',
    'con',
    'casa',
    'strada',
    'vita',
    'pace',
    'mia',
    'tua',
    'sua',
    'mio',
    'tuo',
    'suo',
    'io',
    'fino',
    'verso',
    'dopo',
    'prima',
    'senza',
    'insieme',
  };

  static final Set<String> _maschili = {
    ...dizionarioDelGenere,
    'sereno',
    'grato',
    'degno',
    'calmo',
    'tranquillo',
    'fiero',
    'aperto',
    'pieno',
    'completo',
    'radicato',
    'centrato',
    'guidato',
    'nutrito',
  };

  static final Set<String> _femminili = {
    for (final p in _maschili)
      if (p.endsWith('o')) '${p.substring(0, p.length - 1)}a',
  };

  static Map<String, Object?>? _json(String? testo) {
    if (testo == null) return null;
    try {
      final j = jsonDecode(testo);
      return j is Map ? j.cast<String, Object?>() : null;
    } catch (errore) {
      // Un JSON rotto vale come nessuna risposta: parla la voce di casa.
      return null;
    }
  }

  static Future<String?> _chiamataVera(
      String istruzione, String richiesta, Map<String, Schema> campi) async {
    final m =
        FirebaseAI.vertexAI(location: LaRegioneDeiDati.regione).generativeModel(
      model: modello,
      systemInstruction: Content.system(istruzione),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 320,
        thinkingConfig: LaDomandaCapita.ragionamentoPer(modello),
        responseMimeType: 'application/json',
        responseSchema: Schema.object(properties: campi),
      ),
    );
    final r = await m.generateContent([Content.text(richiesta)]);
    return r.text;
  }
}
