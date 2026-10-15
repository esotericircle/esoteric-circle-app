import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../services/ai/l_etichetta_della_funzione.dart';
import '../config/la_regione_dei_dati.dart';
import '../viaggio/la_domanda_capita.dart';
import 'i_ruoli_e_l_estrazione.dart';
import 'l_ora_degli_angeli.dart';
import 'le_domande_dell_oracolo.dart';

/// La firma di una chiamata al modello, la stessa della Stesa
/// (`ChiamataDellaStesa`): l'istruzione, la richiesta, i campi. Le prove ne
/// passano una finta.
typedef ChiamataDellOracolo = Future<String?> Function(
    String istruzione, String richiesta, Map<String, Schema> campi);

/// **LA RISPOSTA DELL'ORACOLO.** Ordine FU voci FU.04 e FU.06.
///
/// Tre paragrafi, uno per carta nell'ordine Custode, Cuore, Intelletto, col
/// secondo nel riquadro. Il primo e il terzo vengono dal corpus dei messaggi
/// di Medora (FU.05), gratis. Il secondo, il riquadro, e il titolo li scrive
/// il modello: sono cio' che lega la domanda alle tre carte, e il riquadro
/// parte dall'Angelo del Cuore. Senza modello il riquadro e' il messaggio del
/// Cuore dal corpus e il titolo viene dal tema riconosciuto sul telefono.
class RispostaDellOracolo {
  const RispostaDellOracolo({
    required this.titolo,
    required this.paragrafi,
    required this.dalModello,
    this.approfondimento = const [],
  });

  final String titolo;

  /// Tre paragrafi, uno per carta; il secondo va nel riquadro.
  final List<String> paragrafi;

  /// I due paragrafi in piu' della profondita' Lunga (dall'Adepto, FU.10),
  /// nel loro riquadro dopo i tre. Vuoti nella Breve.
  final List<String> approfondimento;

  /// Falso se la risposta e' quella del solo corpus: la schermata lo dice.
  final bool dalModello;
}

abstract final class LaLetturaDellOracolo {
  /// **IL MODELLO LEGGERO**, non quello dei Maestri: Gemini 2.5 Flash-Lite,
  /// gia' verificato nella regione dei dati (`LaRegioneDeiDati`), lo stesso
  /// della risposta Breve. Il fondatore: *"Per la B dobbiamo cercare di
  /// minimizzare il costo, come fatto per i tarocchi"*.
  static const String modello = 'gemini-2.5-flash-lite';

  /// Quanto si aspetta il modello prima di dare la risposta del corpus.
  static const Duration pazienza = Duration(seconds: 8);

  /// I tetti dei campi in caratteri: la guardia della risposta li fa
  /// rispettare e il tetto dei token ne discende.
  static const int tettoDelTitolo = 80;
  static const int tettoDelRiquadro = 420;
  static const int tettoDellApprofondimento = 420;

  /// **IL TETTO DEI TOKEN DI USCITA**: i caratteri dei campi diviso tre
  /// (l'italiano sta sopra i tre caratteri per token), con un minimo. Breve:
  /// 300 token; Lunga: 600.
  static int tettoDeiGettoni({required bool profonda}) {
    final caratteri = tettoDelTitolo +
        tettoDelRiquadro +
        (profonda ? 2 * tettoDellApprofondimento : 0);
    final scalato = (caratteri / 3).ceil();
    final minimo = profonda ? 600 : 300;
    return scalato > minimo ? scalato : minimo;
  }

  /// **L'ISTRUZIONE FISSA**, uguale per ogni consultazione: e' la parte che
  /// il modello puo' tenere in cache. Porta la voce di Medora, la politica di
  /// pubblicazione degli angeli (R8 dell'ordine), la regola di casa sul
  /// futuro e sulla vita privata dei terzi, e le domande delicate.
  static const String istruzione = '''
Sei Medora, Maestra del Cerchio: voce calda, colta, concreta. Parli a chi ti consulta dandogli del tu, in italiano, con gli accenti veri.
Ricevi una domanda e tre carte dell'Oracolo degli Angeli, una per ruolo: Angelo Custode (cosa fare), Angelo del Cuore (cosa sentire), Angelo dell'Intelletto (cosa capire). Ogni carta porta il suo messaggio gia' scritto.
Scrivi solo due cose:
- titolo: la risposta alla domanda in una frase sola, al massimo 80 caratteri, senza punto finale.
- riquadro: un paragrafo di 2 o 3 frasi, al massimo 400 caratteri, che parte da cosa sentire con l'Angelo del Cuore e lega la domanda alle tre carte. Chiude con un gesto concreto.
Regole che non si rompono:
- Niente salute, malattia, guarigione, fertilita, gravidanza, medicine o cure del corpo.
- Nessuna promessa di esito: niente vittorie, ricchezze, successi garantiti, ritorni sicuri, protezioni.
- Nessun futuro detto come certezza: parla di tendenze, possibilita, scelte.
- Nessuna affermazione sulla vita privata, sui sentimenti o sulle intenzioni di altre persone.
- Niente angeli contrari, demoni, goetia, nomi alternativi degli angeli.
- Le chiavi di lettura sono tue, mai "la tradizione dice".
- Mai il trattino lungo. Mai la virgola prima di "e" o di "ed".
- Non concordare aggettivi o participi col genere di chi legge: usa frasi neutre.
Se la domanda parla di farsi del male, di una crisi o di un pericolo per qualcuno, non leggere le carte: titolo "Adesso conta avere qualcuno accanto" e nel riquadro invita a chiamare subito il 112 e a parlarne con una persona di fiducia.
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
      final messaggio = _messaggio(corpus, c, variante);
      righe.add('${c.ruolo.nome.toUpperCase()} (${c.ruolo.posizione}): '
          '${c.angelo.name}. Messaggio: $messaggio');
    }
    return righe.join('\n');
  }

  static Map<String, Schema> campi({required bool profonda}) => {
        'titolo': Schema.string(description: 'La risposta in una frase.'),
        'riquadro':
            Schema.string(description: 'Il paragrafo che lega le tre carte.'),
        if (profonda) ...{
          'approfondimento1': Schema.string(
              description: 'Primo paragrafo di approfondimento, 2 o 3 '
                  'frasi, al massimo 400 caratteri.'),
          'approfondimento2': Schema.string(
              description: 'Secondo paragrafo di approfondimento, 2 o 3 '
                  'frasi, al massimo 400 caratteri, con un gesto.'),
        },
      };

  /// **LA CARTA COPERTA**: senza l'ora di nascita l'Angelo dell'Intelletto
  /// non si conosce (P3 dell'ordine), e la terza carta resta coperta con
  /// l'invito a inserire l'ora (FU.03). Il suo paragrafo lo dice.
  static const String testoDellaCartaCoperta =
      'La terza carta resta coperta: l\'Angelo dell\'Intelletto si rivela '
      'quando conosco la tua ora di nascita. Aggiungila e la carta si girerà.';

  static String _messaggio(
      Map<String, List<String>> corpus, CartaDellOracolo c, int variante) {
    if (c.coperta) return testoDellaCartaCoperta;
    final v = corpus[LOraDegliAngeli.chiave(c.ruolo, c.angelo)];
    if (v == null || v.isEmpty) {
      return '${c.angelo.name} accompagna ${c.ruolo.posizione.toLowerCase()}.';
    }
    return v[variante % v.length];
  }

  /// **LA RISPOSTA DEL SOLO CORPUS**, gratis e sempre disponibile: i tre
  /// messaggi delle carte, col titolo dal tema riconosciuto sul telefono.
  static RispostaDellOracolo delCorpus({
    required String domanda,
    required List<CartaDellOracolo> carte,
    required Map<String, List<String>> corpus,
    required int variante,
  }) {
    final tema = TemaDellOracolo.di(domanda);
    return RispostaDellOracolo(
      titolo: tema?.titoloDiRipiego ?? TemaDellOracolo.titoloSenzaTema,
      paragrafi: [for (final c in carte) _messaggio(corpus, c, variante)],
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
  /// (vuota, troppo lunga, una parola vietata, il trattino lungo), parla il
  /// corpus: mai un vicolo cieco, mai una risposta finta spacciata per letta.
  static Future<RispostaDellOracolo> leggi({
    required String domanda,
    required List<CartaDellOracolo> carte,
    required Map<String, List<String>> corpus,
    required int variante,
    bool profonda = false,
    ChiamataDellOracolo? chiamata,
    Duration? entro,
  }) async {
    final corpusSolo = delCorpus(
        domanda: domanda, carte: carte, corpus: corpus, variante: variante);
    final chiama = chiamata ?? _chiamataVera;
    String? testo;
    try {
      testo = await chiama(
              istruzione,
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
    final letta = _leggiIlJson(testo, profonda: profonda);
    if (letta == null) return corpusSolo;
    return RispostaDellOracolo(
      titolo: letta.titolo,
      paragrafi: [
        corpusSolo.paragrafi[0],
        letta.riquadro,
        corpusSolo.paragrafi[2],
      ],
      approfondimento: letta.approfondimento,
      dalModello: true,
    );
  }

  static ({String titolo, String riquadro, List<String> approfondimento})?
      _leggiIlJson(String? testo, {required bool profonda}) {
    if (testo == null) return null;
    Object? dati;
    try {
      dati = jsonDecode(testo);
    } catch (errore) {
      debugPrint('Oracolo degli Angeli: risposta non leggibile ($errore)');
      return null;
    }
    if (dati is! Map) return null;
    final titolo = '${dati['titolo'] ?? ''}'.trim();
    final riquadro = '${dati['riquadro'] ?? ''}'.trim();
    final approfondimento = profonda
        ? [
            '${dati['approfondimento1'] ?? ''}'.trim(),
            '${dati['approfondimento2'] ?? ''}'.trim(),
          ]
        : const <String>[];
    bool regge(String t, int tetto) =>
        t.isNotEmpty &&
        t.length <= tetto &&
        !t.contains(String.fromCharCode(0x2014)) &&
        !t.contains(String.fromCharCode(0x2013)) &&
        !_vietate.hasMatch(t);
    if (!regge(titolo, tettoDelTitolo) ||
        !regge(riquadro, tettoDelRiquadro) ||
        approfondimento.any((a) => !regge(a, tettoDellApprofondimento))) {
      return null;
    }
    return (
      titolo: titolo,
      riquadro: riquadro,
      approfondimento: approfondimento
    );
  }

  static Future<String?> _chiamataVera(
      String istruzione, String richiesta, Map<String, Schema> campi) async {
    final profonda = campi.containsKey('approfondimento1');
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
