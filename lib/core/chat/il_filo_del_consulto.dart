import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../maestro/consiglio_finale.dart';
import '../maestro/maestro.dart';
import 'i_responsi_di_oggi.dart';

/// Un parere gia' dato nel consulto: da quale Maestro, e il suo nucleo.
class ParereDelConsulto {
  const ParereDelConsulto(
      {required this.maestro, required this.parere, required this.quando});

  final Maestro maestro;

  /// Il nucleo della risposta, scritto dal codice: la riga con la stella del
  /// consiglio finale se c'e', altrimenti la prima frase. Mai riscritto dal
  /// modello.
  final String parere;
  final DateTime quando;

  Map<String, Object?> toJson() =>
      {'m': maestro.name, 'p': parere, 'q': quando.toIso8601String()};

  static ParereDelConsulto? fromJson(Object? j) {
    if (j is! Map) return null;
    final m = Maestro.values.where((x) => x.name == j['m']).firstOrNull;
    final q = DateTime.tryParse('${j['q']}');
    if (m == null || q == null || j['p'] is! String) return null;
    return ParereDelConsulto(maestro: m, parere: j['p'] as String, quando: q);
  }
}

/// **LA SCHEDA DEI PUNTI FERMI. Ordine FE voce 09.** Compilata dal codice e
/// mai dal modello: il tema della domanda iniziale, il dato estratto da cui
/// il consulto parte (la carta, la runa, il segno, il transito del responso
/// aperto), i pareri gia' dati e i Maestri che li hanno dati.
class SchedaDeiPuntiFermi {
  const SchedaDeiPuntiFermi({
    required this.tema,
    required this.daMaestro,
    this.dato,
    this.pareri = const [],
    required this.aggiornata,
  });

  /// La domanda con cui il consulto e' cominciato.
  final String tema;

  /// Il Maestro a cui la domanda e' stata posta per prima.
  final Maestro daMaestro;

  /// Il dato estratto, se il consulto parte da un responso: "la stesa: Il
  /// Matto, la Torre, la Stella".
  final String? dato;
  final List<ParereDelConsulto> pareri;
  final DateTime aggiornata;

  /// I Maestri gia' consultati, nell'ordine.
  List<Maestro> get maestri => [
        for (final p in pareri)
          if (!pareri
              .takeWhile((x) => x != p)
              .any((x) => x.maestro == p.maestro))
            p.maestro,
      ];

  SchedaDeiPuntiFermi con(ParereDelConsulto p) => SchedaDeiPuntiFermi(
        tema: tema,
        daMaestro: daMaestro,
        dato: dato,
        // Del parere di un Maestro conta l'ultimo: il punto fermo e' cio'
        // che ha detto da ultimo, non ogni frase del consulto.
        pareri: [
          for (final x in pareri)
            if (x.maestro != p.maestro) x,
          p,
        ],
        aggiornata: p.quando,
      );

  Map<String, Object?> toJson() => {
        't': tema,
        'm': daMaestro.name,
        'd': dato,
        'p': [for (final p in pareri) p.toJson()],
        'a': aggiornata.toIso8601String(),
      };

  static SchedaDeiPuntiFermi? fromJson(Object? j) {
    if (j is! Map) return null;
    final m = Maestro.values.where((x) => x.name == j['m']).firstOrNull;
    final a = DateTime.tryParse('${j['a']}');
    if (m == null || a == null || j['t'] is! String) return null;
    return SchedaDeiPuntiFermi(
      tema: j['t'] as String,
      daMaestro: m,
      dato: j['d'] is String ? j['d'] as String : null,
      pareri: [
        for (final p in (j['p'] as List? ?? const []))
          if (ParereDelConsulto.fromJson(p) case final x?) x,
      ],
      aggiornata: a,
    );
  }
}

/// **IL FILO DEL CONSULTO: UNA MEMORIA SOLA. Ordine FE voci 08-14 e 22.**
///
/// Prima di quest'ordine la storia arrivava al modello solo dentro la
/// conversazione aperta (otto messaggi), il Consiglio dei Maestri riceveva il
/// solo tema, e un Maestro aperto dopo un altro non sapeva cosa gli altri
/// avevano detto: il tester ha visto pareri nuovi e scollegati a ogni
/// domanda. Qui vive la scheda dei punti fermi del consulto in corso, una e
/// una sola per tutto l'app: la chat, il LIVE, il seguito, il Consiglio e
/// "Continua con" la leggono dallo stesso posto, e la scheda in cima alla
/// chat (FE.22) mostra alla persona esattamente cio' che il Maestro riceve.
///
/// **Vive un'ora** (FE.12): oltre, il consulto e' nuovo e il Maestro non
/// finge di ricordare.
abstract final class IlFiloDelConsulto {
  static const Duration vita = Duration(hours: 1);
  static const String _chiave = 'consulto.filo';

  static SchedaDeiPuntiFermi? _scheda;
  static bool _caricata = false;

  /// L'orologio, sostituibile nelle prove.
  static DateTime Function() adesso = DateTime.now;

  /// La scheda del consulto in corso, o `null` se non c'e' o e' scaduta.
  static SchedaDeiPuntiFermi? get scheda {
    final s = _scheda;
    if (s == null) return null;
    if (adesso().difference(s.aggiornata) > vita) return null;
    return s;
  }

  /// Legge la scheda salvata, una volta.
  static Future<void> carica() async {
    if (_caricata) return;
    _caricata = true;
    try {
      final p = await SharedPreferences.getInstance();
      final grezzo = p.getString(_chiave);
      if (grezzo != null) {
        _scheda = SchedaDeiPuntiFermi.fromJson(jsonDecode(grezzo));
      }
    } catch (_) {
      // Una scheda illeggibile vale come nessuna scheda.
    }
  }

  static Future<void> _salva() async {
    try {
      final p = await SharedPreferences.getInstance();
      final s = _scheda;
      if (s == null) {
        await p.remove(_chiave);
      } else {
        await p.setString(_chiave, jsonEncode(s.toJson()));
      }
    } catch (_) {}
  }

  /// Il nucleo di una risposta: la riga del consiglio con la stella, o la
  /// prima frase. Corto: il filo non e' la risposta intera.
  static String nucleoDi(String risposta) {
    final riga = ConsiglioFinale.sintesiDa(risposta);
    var t = (riga ?? ConsiglioFinale.corpoDa(risposta)).trim();
    if (riga == null) {
      final fine = RegExp(r'[.!?](\s|$)').firstMatch(t);
      if (fine != null) t = t.substring(0, fine.start + 1);
    }
    t = t.replaceAll(ConsiglioFinale.stella, '').trim();
    return t.length > 220 ? '${t.substring(0, 217).trimRight()}...' : t;
  }

  /// Annota un turno concluso: se non c'e' un consulto in corso lo apre con
  /// questa domanda come tema, poi scrive il parere di [maestro].
  static void annota({
    required Maestro maestro,
    required String domanda,
    required String risposta,
  }) {
    final ora = adesso();
    var s = scheda;
    if (s == null) {
      final partenza = IResponsiDiOggi.partenza(ora);
      s = SchedaDeiPuntiFermi(
        tema: domanda.trim().length > 200
            ? '${domanda.trim().substring(0, 197).trimRight()}...'
            : domanda.trim(),
        daMaestro: maestro,
        dato: partenza == null ? null : '${partenza.arte}: ${partenza.titolo}',
        aggiornata: ora,
      );
    }
    _scheda = s.con(ParereDelConsulto(
        maestro: maestro, parere: nucleoDi(risposta), quando: ora));
    _salva();
  }

  /// Chiude il consulto: la prossima domanda ne apre uno nuovo.
  static void chiudi() {
    _scheda = null;
    _salva();
  }

  /// Le prove ripartono da vuoto.
  static void dimentica() {
    _scheda = null;
    _caricata = true;
    adesso = DateTime.now;
  }

  /// **IL BLOCCO PER IL MODELLO**, per [maestro]: la scheda, la legge della
  /// coerenza e, se altri Maestri hanno gia' parlato, la regola del secondo
  /// Maestro. Vuoto senza un consulto in corso: l'istruzione di base resta
  /// quella su cui e' misurata l'attribuzione cieca.
  static String bloccoPer(Maestro maestro, {String? fraseRipresa}) {
    final s = scheda;
    if (s == null && fraseRipresa == null) return '';
    final righe = <String>[];
    if (s != null) {
      righe.add('IL FILO DEL CONSULTO, punti fermi scritti dall’app (non '
          'li inventi, non li contraddici):');
      righe.add('- La domanda iniziale, fatta a ${s.daMaestro.displayName}: '
          '«${s.tema}»');
      if (s.dato != null) righe.add('- Il dato da cui parte: ${s.dato}');
      for (final p in s.pareri) {
        final chi = p.maestro == maestro ? 'Tu' : p.maestro.displayName;
        righe.add('- $chi ha detto: «${p.parere}»');
      }
      righe.add('');
      righe.add(LaLeggeDellaCoerenza.testo);
      final altri = [
        for (final p in s.pareri)
          if (p.maestro != maestro) p.maestro.displayName
      ];
      if (altri.isNotEmpty) {
        righe.add('');
        righe.add(LaLeggeDellaCoerenza.ilSecondoMaestro(altri));
      }
    }
    if (fraseRipresa != null) {
      righe.add('');
      righe.add(LaLeggeDellaCoerenza.laFraseRipresa(fraseRipresa));
    }
    return righe.join('\n');
  }
}

/// **LA LEGGE DELLA COERENZA, IN UN PUNTO SOLO. Ordine FE voci 10, 11 e 14.**
/// Tutte le strade che portano una domanda a un Maestro la ricevono da qui,
/// attraverso [IlFiloDelConsulto.bloccoPer].
abstract final class LaLeggeDellaCoerenza {
  static const String testo = 'LA LEGGE DELLA COERENZA. Dentro questo '
      'consulto non contraddici quello che è già stato detto. Se la '
      'domanda tocca uno dei punti fermi, parti da quel punto e portalo '
      'avanti. Se cambi parere, dillo apertamente e spiega perché è '
      'cambiato: non dare un parere nuovo come se il primo non fosse '
      'esistito.';

  /// La regola per chi parla dopo [altri] (i nomi a video). I nomi stanno
  /// nella regola: senza, al banco dell'ordine FE il secondo Maestro nominava
  /// il primo in 3-12 risposte su 20.
  static String ilSecondoMaestro(List<String> altri) {
    final chi = altri.length == 1
        ? altri.single
        : '${altri.sublist(0, altri.length - 1).join(', ')} e ${altri.last}';
    final riga = altri.length == 1
        ? 'una riga che comincia con il nome di ${altri.single}'
        : 'una riga per ognuno, che comincia con il suo nome';
    return 'PRIMA DI TE HA GIÀ PARLATO $chi. Se la domanda riguarda ancora '
        'la domanda iniziale del consulto, apri con la tua lettura, nella '
        'tua voce e con la tua lente: chi legge deve riconoscerti dalla '
        'prima frase. Poi scrivi $riga: riporta il suo consiglio con parole '
        'tue, cioè il gesto o il tempo che ha indicato e non le parole della '
        'sua arte, e di’ se la tua lettura concorda o diverge. Quella riga non '
        'si salta. Non ripetere la sua risposta con parole diverse: se la '
        'tua lente dice la stessa cosa, dillo in quella riga e aggiungi '
        'quello che vedi solo tu.';
  }

  static String laFraseRipresa(String frase) => 'LA PERSONA RIPRENDE UNA '
      'TUA FRASE: «$frase». Non è una domanda nuova: è la continuazione '
      'di quel punto. Approfondisci quel punto e non aprirne un altro.';
}

/// **LA FRASE RIPRESA. Ordine FE voce 11.** Il tester: se riprendeva una
/// frase che il Maestro gli aveva appena suggerito, il Maestro rispondeva
/// un'altra cosa. Qui si riconosce quando la domanda della persona riprende
/// una frase dell'ultima risposta del Maestro: almeno meta' delle radici
/// della frase ritornano nella domanda, e almeno sei su dieci della domanda
/// sono fatte di quelle. La frase va al modello come continuazione
/// ([LaLeggeDellaCoerenza.laFraseRipresa]).
abstract final class LaFraseRipresa {
  /// Le radici delle parole piene: le prime cinque lettere delle parole di
  /// almeno quattro, cosi' "prepara" e "preparo" sono la stessa parola.
  static Set<String> _parole(String t) => {
        for (final p in t.toLowerCase().split(RegExp(r'[^a-zàèéìòù]+')))
          if (p.length > 3) p.length > 5 ? p.substring(0, 5) : p,
      };

  static String? trova(String domanda, String? ultimaRisposta) {
    if (ultimaRisposta == null || ultimaRisposta.trim().isEmpty) return null;
    final dw = _parole(domanda);
    if (dw.length < 3) return null;
    final testo = ultimaRisposta.replaceAll(ConsiglioFinale.stella, '. ');
    String? migliore;
    var meglio = 0.0;
    for (final frase in testo.split(RegExp(r'(?<=[.!?])\s+|\n+'))) {
      final f = frase.trim();
      final fw = _parole(f);
      if (fw.length < 4) continue;
      final comuni = fw.intersection(dw).length;
      final dellaFrase = comuni / fw.length;
      final dellaDomanda = comuni / dw.length;
      if (dellaFrase >= 0.5 && dellaDomanda >= 0.6 && dellaFrase > meglio) {
        meglio = dellaFrase;
        migliore = f;
      }
    }
    return migliore;
  }
}
