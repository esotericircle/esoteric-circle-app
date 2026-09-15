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

TITOLO: al massimo sei parole, senza punto finale, senza due punti. Nomina la cosa dell'intenzione, non la categoria. Nessuna parola di tempo.
RESPONSO: due o tre frasi, al massimo quaranta parole. Nomina la cosa che la persona ha scritto, voltata alla seconda persona e senza virgolette: le sue parole, non una categoria. Dice cosa il segno custodisce, mai cosa accadrà: nessun futuro certo, nessuna promessa su salute, denaro, morte, gravidanza o cause legali, nessuna diagnosi. Mai la prima persona. Mai un nome proprio che la persona non ha scritto. Nessun fuoco da accendere o bruciare. Di un'altra persona non dire niente di ciò che prova, pensa o vuole. Niente gergo motivazionale: niente "il tuo vero io", "ascolta il tuo cuore", "è tempo di", "apriti a", "lascia andare", "abbraccia il cambiamento".

${_cortesia(forma)}
Rispondi solo con un oggetto JSON con i campi "titolo" e "responso".''';

  /// L'istruzione del testo del compimento.
  static String istruzioneDelCompimento(CourtesyForm forma) => '''
Sei Caligo, il Maestro delle rune e della magia di Esoteric Circle. Una persona dichiara che l'intenzione del suo sigillo si è compiuta. Scrivi una sola riga in italiano, rivolta a lei col tu, al massimo trenta parole: nomina la cosa che aveva scritto, voltata alla seconda persona e senza virgolette. Non una congratulazione generica. Mai la prima persona. Nessun futuro, nessuna promessa. Di un'altra persona non dire niente di ciò che prova, pensa o vuole. Niente gergo motivazionale.

${_cortesia(forma)}
Rispondi solo con un oggetto JSON con il campo "testo".''';

  /// L'istruzione della riformulazione.
  static String istruzioneDellaRiformulazione(CourtesyForm forma) => '''
Sei Caligo, il Maestro delle rune e della magia di Esoteric Circle. Una persona ha scritto un'intenzione per un sigillo. Riscrivila come si scrive un'intenzione nel metodo di Austin Osman Spare: una frase sola, al presente, in prima persona, detta come se fosse già vera, al massimo quindici parole, con le parole della persona dove si può. Un sigillo agisce su chi lo traccia: se l'intenzione chiede di cambiare la volontà di un'altra persona, riportala su chi scrive. Niente fuoco, niente gergo motivazionale, nessuna promessa su salute, denaro, morte, gravidanza o cause legali.

${_cortesia(forma)}
Rispondi solo con un oggetto JSON con il campo "riformulata".''';

  static String richiesta(String intenzione, ViaMagica via) =>
      'Intenzione: ${intenzione.trim()}\nVia: ${via.nome}, ${via.dominio}';

  /// **IL TITOLO E IL RESPONSO**, ognuno dal modello solo se regge alle
  /// guardie; altrimenti la voce di casa.
  static Future<TestiDelSigillo> scrivi({
    required String intenzione,
    required ViaMagica via,
    required CourtesyForm forma,
    ChiamataDelSigillo? chiamata,
  }) async {
    final scarti = <RigaScartata>[];
    Map<String, Object?>? j;
    try {
      final testo = await (chiamata ?? _chiamataVera)(
        istruzioneDeiTesti(forma),
        richiesta(intenzione, via),
        {'titolo': Schema.string(), 'responso': Schema.string()},
      ).timeout(pazienza);
      j = _json(testo);
    } catch (errore) {
      // Rete assente, tempo scaduto, servizio spento: parla la voce di casa.
    }
    String? titolo = (j?['titolo'] as String?)?.trim();
    String? responso = (j?['responso'] as String?)?.trim();
    if (titolo != null) {
      titolo = titolo.replaceAll(RegExp(r'[.]+$'), '');
      final m = LeGuardieDelResponso.delTitolo(titolo,
          domanda: intenzione, forma: forma);
      if (m != null) {
        scarti.add(RigaScartata('titolo', m, titolo));
        titolo = null;
      }
    }
    if (responso != null) {
      final m = LeGuardieDelResponso.dellaRisposta(responso,
          domanda: intenzione, forma: forma);
      if (m != null) {
        scarti.add(RigaScartata('risposta', m, responso));
        responso = null;
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
          LeGuardieDelResponso.dellaRisposta(testo,
                  domanda: intenzione, forma: forma) ==
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
    try {
      final r = await (chiamata ?? _chiamataVera)(
        istruzioneDellaRiformulazione(forma),
        richiesta(intenzione, via),
        {'riformulata': Schema.string()},
      ).timeout(pazienza);
      final testo = (_json(r)?['riformulata'] as String?)
          ?.trim()
          .replaceAll(RegExp(r'^"|"$'), '');
      if (testo == null || testo.isEmpty) return null;
      if (testo.split(RegExp(r'\s+')).length > 18) return null;
      if (IntentionSigil.cammino(testo).length < 2) return null;
      if (LettoreIntenzione.leggi(testo).eStataRiformulata) return null;
      if (LeGuardieDelResponso.fuocoGergoDecisione(testo) != null) return null;
      if (!generePermesso(genereDellaPrimaPersona(testo), forma)) return null;
      return testo;
    } catch (errore) {
      // Rete assente o risposta illeggibile: la persona tiene la sua frase,
      // che e' esattamente la riserva che la voce DO.09 chiede.
      return null;
    }
  }

  /// **IL GENERE DELLA PRIMA PERSONA**, voce DO.12: la frase riformulata e'
  /// detta da chi scrive, *"sono pronta"*, e la guardia del dizionario DL.06
  /// guarda la seconda persona. Questa guarda la prima: `'m'`, `'f'` o nullo
  /// se la frase non dice il genere.
  static String? genereDellaPrimaPersona(String testo) {
    for (final m in _primaPersona.allMatches(testo.toLowerCase())) {
      final w = m.group(1)!;
      if (_maschili.contains(w) || RegExp(r'(at|ut|it)o$').hasMatch(w)) {
        return 'm';
      }
      if (_femminili.contains(w) || RegExp(r'(at|ut|it)a$').hasMatch(w)) {
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

  static final RegExp _primaPersona = RegExp(
      r'\b(?:sono|mi sento|resto|rimango|divento|mi scopro|mi trovo|mi sono|'
      r'mi rendo)\s+(?:(?:più|già|ancora|finalmente|davvero|sempre|anche)\s+)?'
      r'([a-zàèéìòù]+)(?![a-zàèéìòù])');

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
