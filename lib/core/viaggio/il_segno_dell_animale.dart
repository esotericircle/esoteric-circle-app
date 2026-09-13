import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../rituals/animal_catalog.dart';
import 'il_tetto_delle_chiamate.dart';
import 'la_domanda_capita.dart';
import 'vocabolario_del_viaggio.dart';

/// **I GESTI CON CUI L'ANIMALE RISPONDE, e nessuno di piu'.**
/// Ordine DI voce 14, 12 settembre 2026.
///
/// **Le parole dell'ordine:** *"l'animale non parla. La persona scrive una
/// domanda in una riga. L'animale risponde con un gesto, non con un discorso:
/// si volta, si avvicina, si siede, porta qualcosa in bocca, si allontana,
/// guarda in una direzione. Il repertorio dei gesti e' chiuso e disegnato da
/// noi, come il vocabolario della scena. Il modello sceglie il gesto e scrive
/// la riga, non inventa gesti nuovi."*
///
/// **Sei gesti, quelli dell'ordine, e ognuno sa dirsi per ogni animale**: un
/// uccello porta qualcosa *nel becco* e non *in bocca*, si *posa* e non si
/// siede; il Serpente si *raccoglie*.
enum GestoDelSegno {
  siVolta,
  siAvvicina,
  siSiede,
  portaQualcosa,
  siAllontana,
  guardaLontano;

  /// **COSA FA, detto per quell'animale.** [cosa] serve solo a
  /// [portaQualcosa], ed e' una figura del vocabolario chiuso della scena.
  String descrizione(GuideAnimal animale, {PezzoDellaScena? cosa}) {
    final uccello = GestiDelSegno.uccelli.contains(animale.name);
    switch (this) {
      case GestoDelSegno.siVolta:
        return 'si volta verso di te';
      case GestoDelSegno.siAvvicina:
        return 'ti si avvicina';
      case GestoDelSegno.siSiede:
        if (uccello) return 'si posa davanti a te';
        if (animale.name == 'Serpente') return 'si raccoglie davanti a te';
        return 'si siede davanti a te';
      case GestoDelSegno.portaQualcosa:
        final che = cosa?.nome ?? 'qualcosa';
        return uccello ? 'ti porta nel becco $che' : 'ti porta in bocca $che';
      case GestoDelSegno.siAllontana:
        if (uccello) return 'si allontana in volo';
        if (animale.name == 'Serpente') return 'si allontana strisciando';
        return 'si allontana di qualche passo';
      case GestoDelSegno.guardaLontano:
        return 'guarda lontano, oltre te';
    }
  }
}

/// **IL SEGNO CHE L'ANIMALE HA DATO**: il gesto, la cosa se c'e', la riga.
class UnSegno {
  const UnSegno({
    required this.gesto,
    required this.riga,
    this.cosa,
    this.dalModello = false,
  });

  final GestoDelSegno gesto;
  final PezzoDellaScena? cosa;

  /// **LA RIGA SOLA**: cosa ha fatto l'animale e cosa vuol dire per la
  /// domanda.
  final String riga;

  /// Se l'ha scelto il modello o la via di riserva. **Mai detto alla persona.**
  final bool dalModello;
}

/// La firma di una chiamata al modello per il segno, iniettabile nelle prove.
typedef ChiamataDelSegno = Future<String?> Function(
    String istruzione, String richiesta);

/// **IL SEGNO DELL'ANIMALE: il modello sceglie, la riserva risponde sempre.**
/// Ordine DI voce 14.
abstract final class GestiDelSegno {
  /// Gli uccelli, che non hanno bocca e non si siedono.
  static const Set<String> uccelli = {'Aquila', 'Corvo', 'Falco', 'Gufo'};

  /// **IL MODELLO E LA REGIONE SONO QUELLI DELLA DOMANDA CAPITA**, per scelta:
  /// l'ordine nomina Gemini 3.5 Flash Lite per tutte e due, e la scelta fra il
  /// modello dell'ordine su `global` e quello gia' in uso su `europe-west1` e'
  /// del fondatore. Si cambia in un posto solo, `LaDomandaCapita`.
  static String get modello => LaDomandaCapita.modello;
  static String get regione => LaDomandaCapita.regione;

  /// **QUANTO SI ASPETTA IL MODELLO.** Tre secondi: la persona sta guardando
  /// l'animale e aspetta la sua risposta, e un gesto che arriva dopo cinque
  /// secondi non sembra piu' una risposta.
  static const Duration pazienza = Duration(seconds: 3);

  /// **QUANTO PUO' ESSERE LUNGA LA RIGA**, in caratteri. Una riga sola, ma di
  /// senso compiuto: una frase breve per il gesto e una per cio' che vuol dire.
  static const int rigaAlMassimo = 180;

  /// Le cose che l'animale puo' portare: le figure del vocabolario chiuso.
  static List<PezzoDellaScena> get cose => VocabolarioDelViaggio.cose;

  /// **L'ISTRUZIONE AL MODELLO.** Costruita dall'enumerazione, cosi' il
  /// repertorio non si ricopia a mano.
  static String istruzione(GuideAnimal animale) {
    final chi = '${animale.articolo}${animale.name}';
    final b = StringBuffer(
        'Sei la voce muta dell\'animale guida di una persona: $chi. L\'animale '
        'non parla, risponde con un gesto. Ricevi la domanda della persona. '
        'Scegli UN gesto da questo elenco chiuso e non inventarne altri:\n');
    for (final g in GestoDelSegno.values) {
      b.writeln('- ${g.name}: $chi ${g.descrizione(animale)}');
    }
    b.write('Se scegli portaQualcosa, scegli anche la cosa dall\'elenco delle '
        'cose. Poi scrivi UNA riga in italiano, al massimo 25 parole, in '
        'seconda persona singolare: dice cosa ha fatto $chi e cosa vuol dire '
        'per la domanda. Non usare aggettivi o participi che dicano se la '
        'persona è un uomo o una donna. Niente due punti. Niente previsioni '
        'certe, niente consigli medici, legali o economici.');
    return b.toString();
  }

  /// **CHIEDE IL SEGNO.** Il modello se puo', la riserva sempre.
  ///
  /// La riserva risponde quando il tetto tecnico e' raggiunto, quando il
  /// modello non risponde entro [pazienza], quando sceglie un gesto o una
  /// cosa fuori dall'elenco, o quando la riga non passa la lettura di
  /// [rigaAccettabile]. Il guasto va a [seGuasto], mai alla persona.
  static Future<UnSegno> chiedi({
    required GuideAnimal animale,
    required String domanda,
    required DateTime giorno,
    ChiamataDelSegno? chiamata,
    Future<bool> Function() prendiUnaChiamata =
        IlTettoDelleChiamate.prendiUnaChiamata,
    void Function(Object errore)? seGuasto,
  }) async {
    final testo = domanda.trim();
    if (testo.isNotEmpty && await prendiUnaChiamata()) {
      try {
        final risposta = await (chiamata ?? _chiamataVera)(
                istruzione(animale), testo)
            .timeout(pazienza);
        final segno = leggi(risposta, animale);
        if (segno != null) return segno;
        seGuasto?.call(SegnoFuoriDalRepertorio(risposta));
      } catch (errore) {
        seGuasto?.call(errore);
      }
    }
    return diRiserva(animale: animale, domanda: testo, giorno: giorno);
  }

  /// **LEGGE LA RISPOSTA DEL MODELLO**, e la scarta se esce dal repertorio.
  static UnSegno? leggi(String? risposta, GuideAnimal animale) {
    if (risposta == null) return null;
    final Object? j;
    try {
      j = jsonDecode(risposta);
    } catch (_) {
      return null;
    }
    final dati = j is Map ? j : null;
    if (dati == null) return null;
    final gesto = GestoDelSegno.values
        .where((g) => g.name == dati['gesto'])
        .firstOrNull;
    if (gesto == null) return null;
    PezzoDellaScena? cosa;
    if (gesto == GestoDelSegno.portaQualcosa) {
      cosa = cose.where((c) => c.id == dati['cosa']).firstOrNull;
      if (cosa == null) return null;
    }
    final riga = (dati['riga'] as Object?)?.toString().trim() ?? '';
    if (!rigaAccettabile(riga)) return null;
    return UnSegno(gesto: gesto, cosa: cosa, riga: riga, dalModello: true);
  }

  /// **LA RIGA SI LEGGE PRIMA DI MOSTRARLA.** Una riga sola, non vuota, non
  /// piu' lunga del tetto, senza due punti annidati, e senza i participi che
  /// dicono a una donna che e' un uomo: le stesse regole della voce del Mondo
  /// di Sotto, ordine DI voce 05.
  static bool rigaAccettabile(String riga) {
    if (riga.length < 12 || riga.length > rigaAlMassimo) return false;
    if (riga.contains('\n')) return false;
    if (':'.allMatches(riga).length > 1) return false;
    if (RegExp(r'\b(sei|eri) (sceso|arrivato|andato|tornato|stato|pronto|solo)\b',
            caseSensitive: false)
        .hasMatch(riga)) {
      return false;
    }
    return true;
  }

  /// **LA VIA DI RISERVA**, deterministica: la stessa domanda nello stesso
  /// giorno da' lo stesso segno.
  static UnSegno diRiserva({
    required GuideAnimal animale,
    required String domanda,
    required DateTime giorno,
  }) {
    final seme = _seme('$domanda|${giorno.year}-${giorno.month}-${giorno.day}'
        '|${animale.name}');
    final gesto = GestoDelSegno.values[seme % GestoDelSegno.values.length];
    final cosa = gesto == GestoDelSegno.portaQualcosa
        ? cose[(seme ~/ 7) % cose.length]
        : null;
    final significati = _significati[gesto]!;
    final chi = '${animale.articolo}${animale.name}';
    final riga = '${chi[0].toUpperCase()}${chi.substring(1)} '
        '${gesto.descrizione(animale, cosa: cosa)}. '
        '${significati[(seme ~/ 31) % significati.length]}';
    return UnSegno(gesto: gesto, cosa: cosa, riga: riga);
  }

  /// **COSA VUOL DIRE OGNI GESTO**, per la via di riserva: due letture per
  /// gesto, e nessuna dice se chi legge e' un uomo o una donna.
  static const Map<GestoDelSegno, List<String>> _significati = {
    GestoDelSegno.siVolta: [
      'Vuol dire che la risposta sta in qualcosa che hai già alle spalle.',
      'Vuol dire che prima di andare avanti conviene guardare indietro.',
    ],
    GestoDelSegno.siAvvicina: [
      'Vuol dire che quello che chiedi è più vicino di quanto credi.',
      'Vuol dire che in questa domanda hai compagnia.',
    ],
    GestoDelSegno.siSiede: [
      'Vuol dire che adesso conviene aspettare, senza forzare.',
      'Vuol dire che la risposta arriva restando fermi.',
    ],
    GestoDelSegno.portaQualcosa: [
      'Vuol dire che quello che ti serve ce l\'hai già, anche se non lo usi.',
      'Vuol dire che sta per arrivarti ciò che manca.',
    ],
    GestoDelSegno.siAllontana: [
      'Vuol dire che su questa domanda serve distanza prima di decidere.',
      'Vuol dire che la cosa che chiedi va lasciata andare, almeno per ora.',
    ],
    GestoDelSegno.guardaLontano: [
      'Vuol dire che la risposta è più avanti nel tempo, non oggi.',
      'Vuol dire che conviene guardare oltre il problema di adesso.',
    ],
  };

  static Future<String?> _chiamataVera(
      String istruzione, String richiesta) async {
    final m = FirebaseAI.vertexAI(location: regione).generativeModel(
      model: modello,
      systemInstruction: Content.system(istruzione),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 256,
        thinkingConfig: LaDomandaCapita.ragionamentoPer(modello),
        // **IL REPERTORIO CHIUSO**: il gesto e la cosa sono elenchi, e il
        // modello non puo' scrivere altro. Resta libera solo la riga, che si
        // legge prima di mostrarla.
        responseMimeType: 'application/json',
        responseSchema: Schema.object(properties: {
          'gesto': Schema.enumString(
              enumValues: [for (final g in GestoDelSegno.values) g.name]),
          'cosa': Schema.enumString(enumValues: [for (final c in cose) c.id]),
          'riga': Schema.string(),
        }, optionalProperties: [
          'cosa'
        ]),
      ),
    );
    final r = await m.generateContent([Content.text(richiesta)]);
    return r.text;
  }

  static int _seme(String s) {
    var h = 0x811c9dc5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0x7fffffff;
    }
    return h;
  }
}

/// Il modello ha risposto fuori dal repertorio, o con una riga illeggibile.
class SegnoFuoriDalRepertorio implements Exception {
  const SegnoFuoriDalRepertorio(this.risposta);
  final String? risposta;
  @override
  String toString() => 'il segno del modello non è nel repertorio: "$risposta"';
}
