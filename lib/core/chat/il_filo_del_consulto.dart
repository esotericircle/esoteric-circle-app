import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../maestro/consiglio_finale.dart';
import '../maestro/maestro.dart';
import '../../services/ai/registro_dei_guasti.dart';
import 'chat_message.dart';
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

  /// **DEL PARERE DI UN MAESTRO CONTA IL PRIMO, sul tema.** Lapide
  /// dell'ordine FE voce 17, 6 ottobre 2026: la prima stesura teneva
  /// l'ultimo, e al banco del percorso D (una domanda, una digressione sul
  /// cristallo per dormire, il ritorno al tema) il punto fermo del Maestro
  /// era diventato il cristallo: tornando al tema, il Maestro ha legato il
  /// rito del sonno alla relazione. Il parere sul tema e' il punto fermo; i
  /// passi successivi stanno nella storia della conversazione. Il turno
  /// nuovo tiene viva la scheda.
  SchedaDeiPuntiFermi con(ParereDelConsulto p) => SchedaDeiPuntiFermi(
        tema: tema,
        daMaestro: daMaestro,
        dato: dato,
        pareri:
            pareri.any((x) => x.maestro == p.maestro) ? pareri : [...pareri, p],
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
    } catch (errore) {
      // Ignorato di proposito: una scheda illeggibile vale come nessuna
      // scheda, e il consulto riparte pulito invece di fermare la chat.
      annotaGuastoInnocuo('la scheda del consulto non si legge', errore);
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
    } catch (errore) {
      // Ignorato di proposito: la scheda vive comunque in memoria per
      // l'ora del consulto; se non si salva, si perde solo alla riapertura.
      annotaGuastoInnocuo('la scheda del consulto non si salva', errore);
    }
  }

  /// Il nucleo di una risposta: la prima frase, che e' la risposta col suo
  /// tempo, e la riga del consiglio con la stella. Corto: il filo non e' la
  /// risposta intera.
  ///
  /// **La prima frase c'e' dall'ordine FE voce 17.** Prima il nucleo era la
  /// sola riga del consiglio, e al banco del percorso B Medora aveva detto
  /// "non affrettare, presenta quando il Sole entra in Sagittario" mentre la
  /// scheda portava a Calìgo solo "prepara un dossier": Calìgo ha detto di
  /// farlo oggi, senza sapere di contraddirla. Il tempo e la risposta stanno
  /// nella prima frase (la risposta in tre parti, ordine EZ).
  static String nucleoDi(String risposta) {
    final riga = ConsiglioFinale.sintesiDa(risposta)
        ?.replaceAll(ConsiglioFinale.stella, '')
        .trim();
    var prima = ConsiglioFinale.corpoDa(risposta).trim();
    final fine = RegExp(r'[.!?](\s|$)').firstMatch(prima);
    if (fine != null) prima = prima.substring(0, fine.start + 1);
    prima = prima.replaceAll(ConsiglioFinale.stella, '').trim();
    String corto(String t, int n) =>
        t.length > n ? '${t.substring(0, n - 3).trimRight()}...' : t;
    if (riga == null || riga.isEmpty) return corto(prima, 220);
    if (prima.isEmpty || prima == riga) return corto(riga, 220);
    return '${corto(prima, 160)} ${corto(riga, 160)}';
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
  ///
  /// **[storia] e' la storia che il modello riceve davvero** (la finestra).
  /// Ordine FE voce 20, il costo: quando il consulto e' tutto di [maestro] e
  /// la sua domanda iniziale sta ancora nella storia, le righe della scheda
  /// ripeterebbero cio' che il modello legge gia', e non partono; resta la
  /// legge della coerenza.
  static String bloccoPer(Maestro maestro,
      {String? fraseRipresa, List<ChatMessage> storia = const []}) {
    final s = scheda;
    if (s == null && fraseRipresa == null) return '';
    final righe = <String>[];
    if (s != null) {
      final soloSuo =
          s.daMaestro == maestro && s.pareri.every((p) => p.maestro == maestro);
      final inizio = s.tema.length > 40 ? s.tema.substring(0, 40) : s.tema;
      final giaNellaStoria = soloSuo &&
          storia.any((m) => m.isUser && m.text.trim().startsWith(inizio));
      if (!giaNellaStoria) {
        righe.add('IL FILO DEL CONSULTO, punti fermi scritti dall’app (non '
            'li inventi, non li contraddici):');
        righe.add('- La domanda iniziale, fatta a '
            '${s.daMaestro.displayName}: «${s.tema}»');
        if (s.dato != null) righe.add('- Il dato da cui parte: ${s.dato}');
        for (final p in s.pareri) {
          final chi = p.maestro == maestro ? 'Tu' : p.maestro.displayName;
          righe.add('- $chi ha detto: «${p.parere}»');
        }
        righe.add('');
      }
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
  /// **Il consiglio nuovo e' il passo dopo.** Ordine FE voce 17: al banco
  /// del percorso A il Maestro dava a ogni domanda un rito nuovo al posto
  /// di quello gia' dato (la lettera, poi la meditazione, poi il sacchetto
  /// d'alloro), e nel percorso C spostava un tempo senza dirlo.
  static const String testo = 'LA LEGGE DELLA COERENZA. Dentro questo '
      'consulto non contraddici quello che è già stato detto. Se la '
      'domanda continua il consulto, richiama in poche parole il consiglio '
      'già dato e porta il passo successivo: prosegue quello, non lo '
      'sostituisce con un rito o un gesto diverso. L’elemento già uscito '
      '(la carta, la runa, il segno, il transito) resta quello: non ne '
      'estrai uno nuovo a ogni domanda, lo rileggi. Se cambi parere, dillo '
      'e spiega perché. Se la persona cambia discorso, rispondi al discorso '
      'nuovo senza mescolarlo ai punti fermi.';

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
        'la domanda iniziale, apri con la tua lettura, nella tua voce. Poi '
        'scrivi $riga: il suo consiglio con parole tue (il gesto o il tempo, '
        'non le parole della sua arte) e se concordi o divergi; mai '
        '«concordo» se dici altro. Quella riga non si salta. Non ripetere la '
        'sua risposta: aggiungi quello che vedi solo tu.';
  }

  /// **IL CONTROLLO DEL CONSULTO, IN FONDO.** Ordine FE voce 17: al banco
  /// il secondo Maestro scriveva "Parti." dopo un primo Maestro che diceva
  /// di restare, e un Maestro cambiava il tempo gia' indicato. La regola
  /// stava a meta' istruzione, lontana dallo stile di voce che spinge alle
  /// frasi nette: va accanto al controllo finale, che e' l'ultima cosa che
  /// il modello legge (memoria del progetto: l'istruzione in conflitto
  /// vince solo accanto alla regola).
  static const String controlloFinale = 'ULTIMO CONTROLLO DEL CONSULTO: '
      'rileggi i punti fermi. La tua risposta non dice un tempo, una fase '
      'del cielo o una risposta diversi da quelli già dati senza dirlo: un '
      'tempo già indicato («entro la fine del mese», «stasera») resta quello, '
      'non lo anticipi e non lo sposti senza dire perché. Se '
      'un altro Maestro ha parlato e tu leggi diversamente, la riga col suo '
      'nome lo dice con «io leggo diversamente» e il perché.';

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
