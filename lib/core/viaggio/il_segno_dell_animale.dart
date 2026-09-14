import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../rituals/animal_catalog.dart';
import 'il_tetto_delle_chiamate.dart';
import 'la_domanda_capita.dart';
import '../chat/il_blocco_di_cortesia.dart';
import '../chat/user_profile.dart';
import '../chat/le_forme_del_genere.dart';

/// **I GESTI CON CUI L'ANIMALE RISPONDE, e nessuno di piu'.**
/// Ordine DI voce 14, 12 settembre 2026; ridotti a tre dall'ordine DJ voce 08,
/// 13 settembre 2026.
///
/// **Le parole dell'ordine DI:** *"l'animale non parla. La persona scrive una
/// domanda in una riga. L'animale risponde con un gesto, non con un discorso.
/// Il repertorio dei gesti e' chiuso e disegnato da noi, come il vocabolario
/// della scena. Il modello sceglie il gesto e scrive la riga, non inventa
/// gesti nuovi."*
///
/// **DA SEI A TRE, ordine DJ voce 08.** Sei gesti per dodici animali erano
/// settantadue disegni da commissionare, e tre di quei sei, *si siede*,
/// *porta qualcosa* e *guarda lontano*, si distinguevano male a colpo
/// d'occhio. **Restano i tre che coprono il ventaglio dal si' al no al non
/// ancora, e si leggono senza spiegazioni**: si avvicina, si volta, si
/// allontana. Trentasei disegni. Gli altri tre si valutano dopo la Demo.
enum GestoDelSegno {
  siAvvicina,
  siVolta,
  siAllontana;

  /// **IL NOME NEI FILE DEI DISEGNI**: `si_avvicina`, `si_volta`,
  /// `si_allontana`, come li nomina l'ordine.
  String get nelFile => switch (this) {
        GestoDelSegno.siAvvicina => 'si_avvicina',
        GestoDelSegno.siVolta => 'si_volta',
        GestoDelSegno.siAllontana => 'si_allontana',
      };

  /// **CHE COSA VUOL DIRE**, con le parole dell'ordine DJ voce 08. Entra
  /// nell'istruzione al modello, perche' il gesto e la riga dicano la stessa
  /// cosa.
  String get significato => switch (this) {
        GestoDelSegno.siAvvicina => 'la risposta è sì, oppure vai avanti',
        GestoDelSegno.siVolta => 'guarda meglio, non hai visto tutto',
        GestoDelSegno.siAllontana => 'la risposta è no, oppure non adesso',
      };

  /// **COSA FA, detto per quell'animale**: un uccello si allontana in volo,
  /// il Serpente strisciando.
  String descrizione(GuideAnimal animale) {
    final uccello = GestiDelSegno.uccelli.contains(animale.name);
    switch (this) {
      case GestoDelSegno.siAvvicina:
        return 'ti si avvicina';
      case GestoDelSegno.siVolta:
        return 'si volta a guardare dietro di sé';
      case GestoDelSegno.siAllontana:
        if (uccello) return 'si allontana in volo';
        if (animale.name == 'Serpente') return 'si allontana strisciando';
        return 'si allontana di qualche passo';
    }
  }
}

/// **IL SEGNO CHE L'ANIMALE HA DATO**: il gesto e la riga.
class UnSegno {
  const UnSegno({
    required this.gesto,
    required this.riga,
    this.dalModello = false,
  });

  final GestoDelSegno gesto;

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

  /// **IL MODELLO E LA REGIONE SONO QUELLI DELLA DOMANDA CAPITA**: Gemini 2.5
  /// Flash Lite in `europe-west1`, scelta del fondatore con l'ordine DJ voce
  /// 03. Si cambia in un posto solo, `LaDomandaCapita`.
  static String get modello => LaDomandaCapita.modello;
  static String get regione => LaDomandaCapita.regione;

  /// **QUANTO SI ASPETTA IL MODELLO.** Tre secondi: la persona sta guardando
  /// l'animale e aspetta la sua risposta, e un gesto che arriva dopo cinque
  /// secondi non sembra piu' una risposta.
  static const Duration pazienza = Duration(seconds: 3);

  /// **QUANTO PUO' ESSERE LUNGA LA RIGA**, in caratteri. Una riga sola, ma di
  /// senso compiuto: una frase breve per il gesto e una per cio' che vuol dire.
  static const int rigaAlMassimo = 180;

  /// **I DISEGNI DEI GESTI**, ordine DJ voce 08: trentasei, uno per gesto e
  /// per animale, in `assets/img/mondo_di_sotto/gesti/`. Il nome e' quello
  /// dell'animale nelle sue illustrazioni, `lupo` da `ani_lupo_v1`, poi il
  /// gesto: `lupo_si_avvicina_v1.webp`. **Finche' un file manca il segno
  /// mostra l'illustrazione intera dell'animale e la riga**: la funzione non
  /// si spegne e non mostra un riquadro vuoto.
  ///
  /// La cartella e' spezzata in pezzi senza barre, come quella delle ombre.
  static String disegnoDi(GuideAnimal animale, GestoDelSegno gesto) {
    final nome = animale.stem.substring(4, animale.stem.length - 3);
    return '$_cartellaDeiDisegni/${nome}_${gesto.nelFile}$_versione';
  }

  /// **I TRENTASEI DISEGNI ATTESI**, col nome esatto con cui vanno
  /// consegnati. Chi li produce legge questo elenco e non il codice.
  static List<String> get disegniAttesi => [
        for (final a in AnimalCatalog.animals)
          for (final g in GestoDelSegno.values) disegnoDi(a, g),
      ];

  static const String _dentro = 'assets';
  static const String _quali = 'img';
  static const String _dove = 'mondo_di_sotto';
  static const String _gesti = 'gesti';
  static const String _cartellaDeiDisegni = '$_dentro/$_quali/$_dove/$_gesti';
  static const String _versione = '_v1.webp';

  /// **L'ISTRUZIONE AL MODELLO.** Costruita dall'enumerazione, cosi' il
  /// repertorio non si ricopia a mano.
  static String istruzione(GuideAnimal animale, {CourtesyForm? forma}) {
    final chi = '${animale.articolo}${animale.name}';
    final b = StringBuffer(
        'Sei la voce muta dell\'animale guida di una persona: $chi. L\'animale '
        'non parla, risponde con un gesto. Ricevi la domanda della persona. '
        'Scegli UN gesto da questo elenco chiuso e non inventarne altri:\n');
    for (final g in GestoDelSegno.values) {
      b.writeln('- ${g.name}: $chi ${g.descrizione(animale)}. Significato: '
          '${g.significato}.');
    }
    final chiMaiuscolo = '${chi[0].toUpperCase()}${chi.substring(1)}';
    // **LA FORMA DELLA RIGA E' DETTA**, ordine DJ voce 08: la prima prova col
    // modello vero ha avuto l'animale che parlava in prima persona, *"Mi sono
    // allontanato"*, previsioni certe, *"la persona tornera'"*, e frasi senza
    // punteggiatura. Due frasi, la prima col nome.
    b.write('Scegli il gesto il cui significato risponde alla domanda. Poi '
        'scrivi UNA riga in italiano, al massimo 25 parole, fatta di due '
        'frasi. La prima comincia con "$chiMaiuscolo" e dice il gesto. La '
        'seconda dice cosa vuol dire per QUESTA domanda, col significato del '
        'gesto ma con parole tue, in seconda persona singolare: non ripetere '
        'il significato alla lettera. L\'animale non parla: niente prima persona, '
        'niente "ti dice". Il gesto indica una direzione, non una certezza: '
        'niente previsioni sul futuro come "tornerà" o "ce la farai". '
        'Niente due punti. Niente consigli medici, legali o economici.');
    // **LA FORMA E' QUELLA SCELTA DALLA PERSONA**, ordine DL voce 04: qui
    // si chiedeva il neutro a tutti, e chi aveva scelto il maschile o il
    // femminile nell'onboarding si trovava un'altra voce.
    b
      ..writeln()
      ..writeln()
      ..write(IlBloccoDiCortesia.perForma(forma));
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
        IlTettoDelleChiamate.prendiUnSegno,
    void Function(Object errore)? seGuasto,
  }) async {
    final testo = domanda.trim();
    if (testo.isNotEmpty && await prendiUnaChiamata()) {
      try {
        final risposta =
            await (chiamata ?? _chiamataVera)(istruzione(animale), testo)
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
    } catch (errore) {
      // **UNA RISPOSTA CHE NON E' JSON E' UNA RISPOSTA DA SCARTARE**, e chi
      // chiama cade sul segno di riserva e registra il guasto: qui non c'e'
      // niente da dire alla persona.
      return null;
    }
    final dati = j is Map ? j : null;
    if (dati == null) return null;
    final gesto =
        GestoDelSegno.values.where((g) => g.name == dati['gesto']).firstOrNull;
    if (gesto == null) return null;
    final riga =
        conIlNome((dati['riga'] as Object?)?.toString().trim() ?? '', animale);
    if (!rigaAccettabile(riga, animale: animale)) return null;
    return UnSegno(gesto: gesto, riga: riga, dalModello: true);
  }

  /// **IL NOME DELL'ANIMALE SI SCRIVE COME SI SCRIVE NELL'APP**, con la
  /// maiuscola: il modello scriveva *"il gufo"* e *"il corvo"*. Si raddrizza
  /// invece di scartare, perche' la riga per il resto era buona.
  static String conIlNome(String riga, GuideAnimal animale) => riga.replaceAll(
      RegExp('\\b${animale.name}\\b', caseSensitive: false), animale.name);

  /// **LA RIGA SI LEGGE PRIMA DI MOSTRARLA.** Una riga sola, non vuota, non
  /// piu' lunga del tetto, senza due punti annidati, e senza i participi che
  /// dicono a una donna che e' un uomo: le stesse regole della voce del Mondo
  /// di Sotto, ordine DI voce 05.
  ///
  /// **E, dall'ordine DJ voce 08, come la legge la persona.** La prima prova
  /// col modello vero su dodici domande ha avuto righe che questa lettura
  /// accettava: l'animale che parlava, *"Mi sono allontanato per indicarti"*
  /// e *"ti dice che la risposta e' no"*; previsioni certe, *"la persona
  /// tornera'"*; e frasi senza un segno di punteggiatura, *"Il Cervo si
  /// avvicina a te questo indica"*. Con [animale] la riga deve anche nominarlo.
  static bool rigaAccettabile(String riga,
      {GuideAnimal? animale, CourtesyForm? forma}) {
    if (riga.length < 12 || riga.length > rigaAlMassimo) return false;
    if (riga.contains('\n')) return false;
    if (':'.allMatches(riga).length > 1) return false;
    // **LA FORMA E' QUELLA SCELTA DALLA PERSONA**, ordine DL voce 04: qui si
    // scartava ogni participio maschile, per tutti. Adesso il modello riceve
    // la forma, e si scarta la riga che la contraddice.
    if (formeContrarieAllaForma(riga, forma ?? LaMarcaDelGenere.formaCorrente)
        .isNotEmpty) {
      return false;
    }
    // **L'ANIMALE NON PARLA**: niente prima persona, niente discorso.
    if (RegExp(r'\b(io|mi|me|mio|mia|miei|mie|dico|dice|dicendo|parla)\b',
            caseSensitive: false)
        .hasMatch(riga)) {
      return false;
    }
    // **UNA DIREZIONE, NON UNA CERTEZZA.**
    if (RegExp(
            // Il confine di parola di RegExp non vede le lettere accentate:
            // dopo *tornera'* non c'e' confine, e la parola passava. I confini
            // sono scritti a mano, con le lettere italiane.
            r'(?<![a-zàèéìòù])(tornerà|arriverà|succederà|riuscirai|ce la farai|farcela|'
            r'sicuramente|certamente|di sicuro|senza dubbio)(?![a-zàèéìòù])',
            caseSensitive: false)
        .hasMatch(riga)) {
      return false;
    }
    // **DUE FRASI**, il gesto e cio' che vuol dire: dentro la riga c'e'
    // almeno un segno che le separa.
    final corpo = riga.replaceFirst(RegExp(r'[.!?]\s*$'), '');
    if (!RegExp(r'[.,;!?]').hasMatch(corpo)) return false;
    if (animale != null && !riga.contains(animale.name)) return false;
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
    final significati = _significati[gesto]!;
    final chi = '${animale.articolo}${animale.name}';
    final riga = '${chi[0].toUpperCase()}${chi.substring(1)} '
        '${gesto.descrizione(animale)}. '
        '${significati[(seme ~/ 31) % significati.length]}';
    return UnSegno(gesto: gesto, riga: riga);
  }

  /// **COSA VUOL DIRE OGNI GESTO**, per la via di riserva: tre letture per
  /// gesto, col significato dell'ordine DJ voce 08, e nessuna dice se chi
  /// legge e' un uomo o una donna.
  static const Map<GestoDelSegno, List<String>> _significati = {
    GestoDelSegno.siAvvicina: [
      'Vuol dire sì. Puoi andare avanti.',
      'Vuol dire che la strada è aperta davanti a te.',
      'Vuol dire che quello che chiedi ha il suo sì.',
    ],
    GestoDelSegno.siVolta: [
      'Vuol dire che non hai ancora visto tutto. Guarda meglio.',
      'Vuol dire che nella domanda c\'è una parte che ti sfugge.',
      'Vuol dire di guardarla di nuovo, con più calma.',
    ],
    GestoDelSegno.siAllontana: [
      'Vuol dire no, almeno per ora.',
      'Vuol dire non adesso. Il momento non è questo.',
      'Vuol dire che oggi questa strada va lasciata.',
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
          'riga': Schema.string(),
        }),
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
