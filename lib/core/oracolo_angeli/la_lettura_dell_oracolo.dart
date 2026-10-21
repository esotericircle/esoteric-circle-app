import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../services/ai/l_etichetta_della_funzione.dart';
import '../angels/angel_catalog.dart';
import '../chat/il_blocco_di_cortesia.dart';
import '../chat/user_profile.dart';
import '../responsi/confine_del_responso.dart';
import '../responsi/i_riti_propiziatori.dart';
import '../responsi/la_forma_del_responso.dart';
import '../../services/ai/maestro_persona.dart';
import '../config/la_regione_dei_dati.dart';
import '../viaggio/la_domanda_capita.dart';
import 'i_ruoli_e_l_estrazione.dart';
import 'l_ora_degli_angeli.dart';
import 'la_risposta_dai_doni.dart';

/// La firma di una chiamata al modello, la stessa della Stesa
/// (`ChiamataDellaStesa`): l'istruzione, la richiesta, i campi. Le prove ne
/// passano una finta.
typedef ChiamataDellOracolo = Future<String?> Function(
    String istruzione, String richiesta, Map<String, Schema> campi);

/// **LA RISPOSTA DELL'ORACOLO.** Ordine FU voci FU.04 e FU.06, nella forma
/// dell'ordine GA voci GA.03, GA.04 e GA.05 (20 ottobre 2026).
///
/// Il responso principale della consultazione e' un [ResponsoInterpretato]
/// dell'Oracolo: il titolo, la risposta, il riquadro "Cosa fare adesso" e,
/// nella Lunga, l'approfondimento e il riquadro "Il salmo propiziatorio"; in
/// fondo il "Da dove viene". Col modello titolo, risposta, cosa fare e
/// approfondimento li scrive Medora per la domanda e le tre carte; il salmo
/// viene sempre dalla raccolta dei riti (`IRitiPropiziatori.salmiMartini`),
/// mai dal modello (GA.04: "nessuna formula inventata"). Senza modello il
/// responso lo compone `LaRispostaDaiDoni` sulla domanda e sui doni degli
/// angeli usciti (ordine GA voce GA.06; prima era la carta del Custode).
///
/// **LAPIDE, ordine GA voce GA.03.** Prima la risposta erano tre paragrafi,
/// uno per carta, col secondo scritto dal modello nel riquadro e i due
/// approfondimenti della Lunga dentro lo stesso riquadro (ordine FY voce
/// FY.19, `paragrafi` e `approfondimento`). Il fondatore, 19 ottobre 2026:
/// "Per le risposte brevi 2 paragrafi di cui il secondo messo in evidenza in
/// un riquadro [...] Per le risposte lunghe aggiungi 2 paragrafi sempre con
/// il primo in riquadro".
class RispostaDellOracolo {
  const RispostaDellOracolo({
    required this.responso,
    required this.dalModello,
  });

  /// Il responso principale, nella forma di GA.03.
  final ResponsoInterpretato responso;

  /// Falso se la risposta e' quella del solo corpus: la schermata lo dice.
  final bool dalModello;

  String get titolo => responso.titolo;
}

abstract final class LaLetturaDellOracolo {
  /// **IL MODELLO LEGGERO**, non quello dei Maestri: Gemini 2.5 Flash-Lite,
  /// gia' verificato nella regione dei dati (`LaRegioneDeiDati`), lo stesso
  /// della risposta Breve. Il fondatore: *"Per la B dobbiamo cercare di
  /// minimizzare il costo, come fatto per i tarocchi"*.
  static const String modello = 'gemini-2.5-flash-lite';

  /// Quanto si aspetta il modello prima di dare la risposta del corpus.
  static const Duration pazienza = Duration(seconds: 8);

  /// Il tetto del titolo in caratteri: il titolo e' una frase sola.
  static const int tettoDelTitolo = 80;

  /// **I CARATTERI DI UNA PAROLA, DALLA MISURA** (ordine GA voce GA.07: i
  /// tetti "si rimisurano sui testi nuovi e si scrivono dalla misura"). Sui
  /// 1.296 paragrafi del corpus nella misura nuova (648 messaggi e 648
  /// consigli, da 40 a 50 parole) il rapporto fra caratteri e parole sta
  /// sotto 7; il tetto ne tiene 8, e la prova
  /// `l_oracolo_ha_la_forma_nuova_test.dart` cade se il corpus lo supera.
  static const int caratteriPerParola = 8;

  /// Il tetto di un paragrafo in caratteri: cinquanta parole da otto.
  static int get tettoDelParagrafo =>
      LaFormaDelResponso.massimo * caratteriPerParola;

  /// **IL TETTO DEI TOKEN DI USCITA**: i caratteri dei campi diviso tre
  /// (l'italiano sta sopra i tre caratteri per token), con un minimo. Breve:
  /// titolo e due paragrafi, 880 caratteri, 294 token, il minimo 300; Lunga:
  /// titolo e tre paragrafi (il salmo non lo scrive il modello), 1.280
  /// caratteri, 427 token, il minimo 600.
  static int tettoDeiGettoni({required bool profonda}) {
    final caratteri = tettoDelTitolo + (profonda ? 3 : 2) * tettoDelParagrafo;
    final scalato = (caratteri / 3).ceil();
    final minimo = profonda ? 600 : 300;
    return scalato > minimo ? scalato : minimo;
  }

  /// **L'ISTRUZIONE**, uguale per ogni consultazione della stessa
  /// profondita': e' la parte che il modello puo' tenere in cache. Porta la
  /// voce di Medora e la politica di pubblicazione degli angeli (R8
  /// dell'ordine FU), poi i punti che valgono per tutte le arti, letti da
  /// dove vivono: **la forma del responso e la risposta diretta**
  /// (`LaFormaDelResponso.perIlModello`, ordine GA voci GA.03 e GA.06, una
  /// volta sola), il confine del responso (`ConfineDelResponso.perIlModello`)
  /// e la regola del tema delicato delle chat dei Maestri
  /// (`MaestroPersona.temaDelicato`). In coda il blocco di cortesia con la
  /// forma scelta dalla persona (`IlBloccoDiCortesia`, la porta unica del
  /// genere): cosi' la parte comune resta in testa e la cache la riusa.
  static String istruzione([CourtesyForm? forma, bool lunga = false]) =>
      '$_istruzioneFissa'
      '${LaFormaDelResponso.perIlModello(arte: ArteInterpretata.oracolo, lunga: lunga)}\n'
      '${ConfineDelResponso.perIlModello}\n'
      '- ${MaestroPersona.temaDelicato}\n'
      '${IlBloccoDiCortesia.perForma(forma)}';

  // **LAPIDE, ordine FV aggiunta voce FVA.01, 15 ottobre 2026.** Qui stava
  // la riga delle domande delicate dell'ordine FU voce FU.04 ("Se la domanda
  // parla di farsi del male, [...] non leggere le carte", col numero da chiamare e l'invito
  // a parlarne con una persona di fiducia). Il fondatore: "elimina tutta la
  // parte e ciò che riguarda alle domande sensibili, non lo abbiamo fatto per
  // le altre funzionalità". Adesso vale la regola dei Maestri, letta qui sotto.
  //
  // **LAPIDE, ordine GA voce GA.03, 20 ottobre 2026.** Qui l'istruzione
  // chiedeva due cose, "titolo (al massimo 80 caratteri)" e "riquadro (2 o 3
  // frasi, al massimo 400 caratteri)", e nella Lunga due approfondimenti.
  // Adesso i campi sono quelli della forma, e la misura e la regola della
  // risposta diretta stanno in `LaFormaDelResponso.perIlModello`.
  static const String _istruzioneFissa = '''
Sei Medora, Maestra del Cerchio: voce calda, colta, concreta. Dai del tu a chi ti consulta, in italiano, con gli accenti veri.
Ricevi una domanda e tre carte dell'Oracolo degli Angeli, una per ruolo: Angelo Custode (cosa fare), Angelo del Cuore (cosa sentire), Angelo dell'Intelletto (cosa capire). Ogni carta porta il suo messaggio già scritto.
Scrivi i campi titolo, risposta, cosaFare e, quando lo schema lo chiede, approfondimento. La risposta lega la domanda alle tre carte uscite; cosaFare parte dalla carta del Custode.
Regole che non si rompono:
- Niente salute, malattia, guarigione, fertilità, gravidanza, medicine o cure del corpo.
- Nessuna promessa di esito: niente vittorie, ricchezze, successi garantiti, ritorni sicuri, protezioni.
- Nessun futuro detto come certezza: parla di tendenze, possibilità, scelte.
- Nessuna affermazione sulla vita privata, sui sentimenti o sulle intenzioni di altre persone.
- Niente angeli contrari, demoni, goetia, nomi alternativi degli angeli.
- Le chiavi di lettura sono tue, mai "la tradizione dice".
- Mai il trattino lungo. Mai la virgola prima di "e" o di "ed".
''';

  /// La richiesta di una consultazione: la domanda, i tre angeli estratti
  /// coi loro messaggi del corpus e i tre ruoli. Non la carta natale intera.
  static String richiesta({
    required String domanda,
    required List<CartaDellOracolo> carte,
    required Map<String, List<String>> corpus,
    required int variante,
  }) {
    final righe = <String>['DOMANDA: ${domanda.trim()}', ''];
    for (final c in carte) {
      // La carta coperta non va al modello: non c'e' un angelo da leggere.
      if (c.coperta) continue;
      final messaggio = messaggioDellaCarta(corpus, c, variante);
      righe.add('${c.ruolo.nome.toUpperCase()} (${c.ruolo.posizione}): '
          '${c.angelo.name}. Messaggio: $messaggio');
    }
    return righe.join('\n');
  }

  static String _misura() =>
      'da ${LaFormaDelResponso.minimo} a ${LaFormaDelResponso.massimo} parole';

  static Map<String, Schema> campi({required bool profonda}) => {
        'titolo': Schema.string(
            description: 'La risposta alla domanda in una frase sola.'),
        'risposta': Schema.string(
            description: 'Il primo paragrafo, ${_misura()}: la prima frase '
                'risponde alla domanda.'),
        'cosaFare': Schema.string(
            description: 'Il paragrafo del riquadro '
                '"${LaFormaDelResponso.titoloDelConsiglio}", ${_misura()}: '
                'che cosa fare o non fare adesso.'),
        if (profonda)
          'approfondimento': Schema.string(
              description: 'Il paragrafo che approfondisce la risposta, '
                  '${_misura()}.'),
      };

  /// **LA CARTA COPERTA**: senza l'ora di nascita l'Angelo dell'Intelletto
  /// non si conosce (P3 dell'ordine), e la terza carta resta coperta con
  /// l'invito a inserire l'ora (FU.03). Il suo paragrafo lo dice.
  static const String testoDellaCartaCoperta =
      'La terza carta resta coperta: l\'Angelo dell\'Intelletto si rivela '
      'quando conosco la tua ora di nascita. Aggiungila e la carta si girerà.';

  /// **IL MESSAGGIO DI UNA CARTA** dal corpus di Medora, nella variante
  /// della consultazione. Ordine FY voce FY.18: e' anche cio' che la carta
  /// porta nella sua bolla, accanto a chi e' l'angelo.
  static String messaggioDellaCarta(
      Map<String, List<String>> corpus, CartaDellOracolo c, int variante) {
    if (c.coperta) return testoDellaCartaCoperta;
    final v = corpus[LOraDegliAngeli.chiave(c.ruolo, c.angelo)];
    if (v == null || v.isEmpty) {
      return '${c.angelo.name} accompagna ${c.ruolo.posizione.toLowerCase()}.';
    }
    return v[variante % v.length];
  }

  /// **IL CONSIGLIO DI UNA CARTA**, ordine GA voce GA.05: il riquadro "Cosa
  /// fare adesso" della carta singola, dal corpus di Medora, nella stessa
  /// variante del messaggio che accompagna. Nullo per la carta coperta.
  static String? consiglioDellaCarta(
      Map<String, List<String>> corpus, CartaDellOracolo c, int variante) {
    if (c.coperta) return null;
    final v = corpus[LOraDegliAngeli.chiaveDelConsiglio(c.ruolo, c.angelo)];
    if (v == null || v.isEmpty) return null;
    return v[variante % v.length];
  }

  /// **LA CARTA SINGOLA NELLA FORMA NUOVA**, ordine GA voce GA.05: sempre
  /// breve, il nome dell'angelo per titolo, il messaggio e il consiglio, e
  /// nessun "Da dove viene" (chiude la consultazione una volta sola). Nullo
  /// per la carta coperta.
  static ResponsoInterpretato? responsoDellaCarta(
      Map<String, List<String>> corpus, CartaDellOracolo c, int variante) {
    final consiglio = consiglioDellaCarta(corpus, c, variante);
    if (consiglio == null) return null;
    return ResponsoInterpretato(
      arte: ArteInterpretata.oracolo,
      titolo: c.angelo.name,
      risposta: messaggioDellaCarta(corpus, c, variante),
      cosaFare: consiglio,
    );
  }

  /// **IL SALMO PROPIZIATORIO** di un angelo, ordine GA voce GA.04: il
  /// versetto che Lenain gli lega, nella Bibbia di Martini, dentro un rito
  /// da 40 a 50 parole, dalla raccolta dei riti e mai dal modello.
  static String? salmoDellAngelo(Angel a) => IRitiPropiziatori.rito(
      IRitiPropiziatori.salmiMartini, ['${a.number}', a.name]);

  /// La fonte del salmo di un angelo: il salmo nella Vulgata, Lenain e
  /// Martini, per il "Da dove viene".
  static String? fonteDelSalmo(Angel a) => IRitiPropiziatori.fonte(
      IRitiPropiziatori.salmiMartini, ['${a.number}', a.name]);

  /// **L'ANGELO DEL SALMO**: quello della carta del Custode, la posizione
  /// di cio' che si fa, dove sta anche il riquadro "Cosa fare adesso". Scelta
  /// di Code, ordine GA, scritta nel rapporto.
  static CartaDellOracolo cartaDelCustode(List<CartaDellOracolo> carte) =>
      carte.firstWhere((c) => c.ruolo == RuoloDellAngelo.custode,
          orElse: () => carte.first);

  /// **DA DOVE VIENE**, una volta sola in fondo alla consultazione: i nomi e
  /// i salmi, i tre angeli della persona, chi scrive la risposta e, nella
  /// Lunga, la fonte del salmo propiziatorio (Lenain e Martini).
  static String daDoveViene({required bool dalModello, String? delSalmo}) {
    // Ordine GA voce GA.06: senza modello la risposta non e' piu' la carta
    // del Custode copiata, la compone Medora dai doni degli angeli usciti.
    final chi = dalModello
        ? 'La risposta alla tua domanda la scrive Medora sulle tre carte '
            'uscite.'
        : 'La risposta la compone Medora dal dono e dalla via di ogni angelo '
            'uscito; i messaggi e i consigli delle carte li ha scritti lei '
            'per ogni angelo.';
    return 'I 72 nomi vengono dal versetto triplice dell\'Esodo, 14, 19-21; '
        'i loro cori e i loro salmi da Lenain, La Science cabalistique, 1823. '
        // Ordine GA voce GA.06: con la carta dell'Intelletto coperta l'ora
        // manca, e il secondo lettore cieco l'ha notato.
        'I tuoi angeli vengono dal grado del Sole e dal giorno della tua '
        'nascita; l\'Angelo dell\'Intelletto, quando la conosci, dalla sua '
        'ora. $chi'
        '${delSalmo == null ? '' : ' Il salmo propiziatorio: $delSalmo'}';
  }

  /// **LA RISPOSTA DEL SOLO CORPUS**, gratis e sempre disponibile:
  /// l'assaggio del Viandante e il ripiego quando il modello manca. Il
  /// responso principale lo compone `LaRispostaDaiDoni` sulla domanda e sui
  /// doni degli angeli usciti, nella forma breve (ordine GA voce GA.06).
  /// [soloIlCustode] e' vero nell'assaggio: il Cuore e l'Intelletto restano
  /// col lucchetto e il responso non li nomina.
  ///
  /// **LAPIDE, ordine GA voce GA.06, 20 ottobre 2026.** Qui il responso era la
  /// carta del Custode copiata, col titolo dal tema riconosciuto
  /// (`TemaDellOracolo.titoloDiRipiego`, sei titoli fissi): il lettore cieco
  /// l'ha trovata uguale alla carta singola 40 volte su 40, con la prima
  /// frase che rispondeva alla domanda 6 volte su 40 (difetti D1, D2, D3).
  /// [variante] resta nella firma: serve alle carte singole, non al
  /// responso principale.
  static RispostaDellOracolo delCorpus({
    required String domanda,
    required List<CartaDellOracolo> carte,
    required Map<String, List<String>> corpus,
    required int variante,
    bool soloIlCustode = false,
  }) {
    final r = LaRispostaDaiDoni.componi(
        domanda: domanda,
        carte: carte,
        corpus: corpus,
        soloIlCustode: soloIlCustode);
    return RispostaDellOracolo(
      responso: ResponsoInterpretato(
        arte: ArteInterpretata.oracolo,
        titolo: r.titolo,
        risposta: r.risposta,
        cosaFare: r.cosaFare,
        daDoveViene: daDoveViene(dalModello: false),
      ),
      dalModello: false,
    );
  }

  /// Le parole che la politica di pubblicazione vieta anche al modello: se
  /// una arriva, la risposta del modello si scarta e parla il corpus.
  static final RegExp _vietate = RegExp(
      r'salute|malatt|guari|fertil|gravidan|medicin|farmac|terapi|'
      r'vittori|ricchezz|demon|goet|angel[oi] contrari|'
      r'sicuramente|accadrà|succederà|otterrai|vincerai',
      caseSensitive: false);

  /// **LA LETTURA.** Una chiamata sola per consultazione. Se la rete manca,
  /// il modello non risponde entro [pazienza], o la risposta non regge
  /// (vuota, un paragrafo fuori dalla misura di GA.03, una parola vietata,
  /// il trattino lungo), parla il corpus: mai un vicolo cieco, mai una
  /// risposta finta spacciata per letta. **Un paragrafo fuori misura non si
  /// tronca** (ordine S voce 18, ordine GA voce GA.07): si scarta.
  static Future<RispostaDellOracolo> leggi({
    required String domanda,
    required List<CartaDellOracolo> carte,
    required Map<String, List<String>> corpus,
    required int variante,
    bool profonda = false,
    CourtesyForm? forma,
    ChiamataDellOracolo? chiamata,
    Duration? entro,
  }) async {
    final corpusSolo = delCorpus(
        domanda: domanda, carte: carte, corpus: corpus, variante: variante);
    final chiama = chiamata ?? _chiamataVera;
    String? testo;
    try {
      testo = await chiama(
              istruzione(forma, profonda),
              richiesta(
                  domanda: domanda,
                  carte: carte,
                  corpus: corpus,
                  variante: variante),
              campi(profonda: profonda))
          .timeout(entro ?? pazienza);
    } catch (errore) {
      debugPrint('Oracolo degli Angeli: il modello non risponde, parla il '
          'corpus ($errore)');
      return corpusSolo;
    }
    final letta = leggiIlJson(testo, profonda: profonda);
    if (letta == null) return corpusSolo;
    final custode = cartaDelCustode(carte).angelo;
    final salmo = profonda ? salmoDellAngelo(custode) : null;
    // Senza il salmo la Lunga resterebbe a meta': si da' la Breve intera.
    final lunga = profonda && salmo != null;
    return RispostaDellOracolo(
      responso: ResponsoInterpretato(
        arte: ArteInterpretata.oracolo,
        titolo: letta.titolo,
        risposta: letta.risposta,
        cosaFare: letta.cosaFare,
        approfondimento: lunga ? letta.approfondimento : null,
        rito: lunga ? salmo : null,
        daDoveViene: daDoveViene(
            dalModello: true, delSalmo: lunga ? fonteDelSalmo(custode) : null),
      ),
      dalModello: true,
    );
  }

  /// **LA RISPOSTA DEL MODELLO, LETTA E MISURATA.** Nulla se non regge:
  /// ogni paragrafo sta fra 40 e 50 parole (`LaFormaDelResponso.aMisura`),
  /// il titolo entro [tettoDelTitolo], niente trattino lungo, niente parole
  /// vietate; nella Lunga l'approfondimento c'e'.
  @visibleForTesting
  static ({
    String titolo,
    String risposta,
    String cosaFare,
    String? approfondimento
  })? leggiIlJson(String? testo, {required bool profonda}) {
    if (testo == null) return null;
    Object? dati;
    try {
      dati = jsonDecode(testo);
    } catch (errore) {
      debugPrint('Oracolo degli Angeli: risposta non leggibile ($errore)');
      return null;
    }
    if (dati is! Map) return null;
    String campo(String k) => '${dati is Map ? dati[k] ?? '' : ''}'.trim();
    final titolo = campo('titolo');
    final risposta = campo('risposta');
    final cosaFare = campo('cosaFare');
    final approfondimento = profonda ? campo('approfondimento') : null;
    bool pulito(String t) =>
        t.isNotEmpty &&
        !t.contains(String.fromCharCode(0x2014)) &&
        !t.contains(String.fromCharCode(0x2013)) &&
        !_vietate.hasMatch(t);
    bool paragrafo(String t) => pulito(t) && LaFormaDelResponso.aMisura(t);
    if (!pulito(titolo) || titolo.length > tettoDelTitolo) return null;
    if (!paragrafo(risposta) || !paragrafo(cosaFare)) {
      debugPrint('Oracolo degli Angeli: la risposta del modello esce dalla '
          'forma (${LaFormaDelResponso.parole(risposta)} e '
          '${LaFormaDelResponso.parole(cosaFare)} parole), parla il corpus');
      return null;
    }
    if (approfondimento != null && !paragrafo(approfondimento)) return null;
    return (
      titolo: titolo,
      risposta: risposta,
      cosaFare: cosaFare,
      approfondimento: approfondimento,
    );
  }

  static Future<String?> _chiamataVera(
      String istruzione, String richiesta, Map<String, Schema> campi) async {
    final profonda = campi.containsKey('approfondimento');
    final m =
        FirebaseAI.vertexAI(location: LaRegioneDeiDati.regione).generativeModel(
      model: modello,
      httpClient: ClientConEtichetta(LeFunzioniDelModello.oracoloAngeli),
      systemInstruction: Content.system(istruzione),
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: tettoDeiGettoni(profonda: profonda),
        thinkingConfig: LaDomandaCapita.ragionamentoPer(modello),
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
            properties: campi, propertyOrdering: campi.keys.toList()),
      ),
    );
    final r = await m.generateContent([Content.text(richiesta)]);
    return r.text;
  }
}
