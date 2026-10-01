import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';

import '../../core/astro/il_cielo_per_il_maestro.dart';
import '../../core/astro/natal_chart.dart';

/// **LE FUNZIONI DEL CIELO: IL MAESTRO CHIEDE, L'APP CALCOLA.** Ordine EV
/// voce 03, il fondatore: *"Medora in chat deve sapere qual è la situazione
/// astrale oggi e di ogni giorno di qualunque mese e anno"*.
///
/// Il modello riceve due funzioni ([cieloDelGiorno] e [cieloDelPeriodo]) e,
/// quando la domanda tocca il cielo di un giorno o di un periodo, le chiama:
/// la libreria del modello (`firebase_ai`, le funzioni automatiche) esegue il
/// calcolo sul telefono con [IlCieloPerIlMaestro], rimanda il risultato al
/// modello e il modello risponde con quei fatti. Vale in chat e nel LIVE, che
/// passano dalla stessa porta.
///
/// La data di oggi sta nella descrizione, perche' il modello sappia che cosa
/// vuol dire "oggi", "domani" o "a dicembre". Ogni chiamata si scrive nel
/// registro del telefono (`Cielo per il Maestro: ...`), ed e' cosi' che si
/// vede, dal registro del Realme, che il dato arriva dal motore e non dal
/// modello.
abstract final class LeFunzioniDelCielo {
  static const String cieloDelGiorno = 'cielo_del_giorno';
  static const String cieloDelPeriodo = 'cielo_del_periodo';

  /// Le chiamate fatte da quando l'app e' aperta: le prove le leggono.
  static final List<String> registro = [];

  /// **I GIORNI DI CUI IL MAESTRO HA CHIESTO IL CIELO**, in ordine. La rete
  /// del cielo detto (`IlCieloDetto.smentite`) li riceve per il turno: un
  /// pianeta detto dove sta in uno di quei giorni non si toglie. Per un
  /// periodo si tengono il primo e l'ultimo giorno e uno ogni cinque.
  static final List<DateTime> giorniChiesti = [];

  /// I giorni chiesti dalla posizione [da] in poi: il turno legge la
  /// posizione prima di chiedere e i giorni dopo.
  static List<DateTime> giorniDa(int da) => da >= giorniChiesti.length
      ? const []
      : List.unmodifiable(giorniChiesti.sublist(da));

  static String _oggi(DateTime adesso) =>
      '${adesso.year.toString().padLeft(4, '0')}-'
      '${adesso.month.toString().padLeft(2, '0')}-'
      '${adesso.day.toString().padLeft(2, '0')}';

  static DateTime? _data(Object? valore) {
    if (valore is! String) return null;
    final m = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(valore.trim());
    if (m == null) return null;
    final anno = int.parse(m.group(1)!);
    final mese = int.parse(m.group(2)!);
    final giorno = int.parse(m.group(3)!);
    if (mese < 1 || mese > 12 || giorno < 1 || giorno > 31) return null;
    return DateTime(anno, mese, giorno);
  }

  /// La risposta di [cieloDelGiorno], fuori dal modello: le prove e il banco
  /// la chiamano direttamente.
  static Map<String, Object?> giorno(Map<String, Object?> args,
      {NatalChart? carta}) {
    final d = _data(args['data']);
    registro.add('$cieloDelGiorno(${args['data']})');
    debugPrint('Cielo per il Maestro: $cieloDelGiorno(${args['data']})');
    if (d == null) {
      return {'errore': 'La data va scritta AAAA-MM-GG, per esempio 2026-10-02.'};
    }
    giorniChiesti.add(DateTime(d.year, d.month, d.day, 12));
    return IlCieloPerIlMaestro.delGiorno(d, carta: carta);
  }

  /// La risposta di [cieloDelPeriodo], fuori dal modello.
  static Map<String, Object?> periodo(Map<String, Object?> args) {
    final dal = _data(args['dal']);
    final al = _data(args['al']);
    registro.add('$cieloDelPeriodo(${args['dal']}, ${args['al']})');
    debugPrint('Cielo per il Maestro: $cieloDelPeriodo(${args['dal']}, '
        '${args['al']})');
    if (dal == null || al == null) {
      return {
        'errore': 'Le date vanno scritte AAAA-MM-GG, per esempio dal '
            '2026-12-01 al 2026-12-31.'
      };
    }
    final esito = IlCieloPerIlMaestro.delPeriodo(dal, al);
    final primo = DateTime.parse('${esito['dal']}');
    final ultimo = DateTime.parse('${esito['al']}');
    for (var g = primo;
        !g.isAfter(ultimo);
        g = DateTime(g.year, g.month, g.day + 5)) {
      giorniChiesti.add(DateTime(g.year, g.month, g.day, 12));
    }
    giorniChiesti.add(DateTime(ultimo.year, ultimo.month, ultimo.day, 12));
    // E i giorni degli eventi: la Luna piena in Toro e' in Toro quel giorno.
    for (final e in (esito['eventi']! as List).cast<String>()) {
      final g = DateTime.tryParse(e.split(':').first);
      if (g != null) giorniChiesti.add(DateTime(g.year, g.month, g.day, 12));
    }
    return esito;
  }

  /// **LA RISPOSTA CHE RIMANDA INVECE DI CHIEDERE.** Ordine EV voce 03,
  /// banco del 1 ottobre 2026, seconda persona: a "Quando torna diretto
  /// Urano?" e a "Mercurio sarà retrogrado a novembre 2026?" Medora ha
  /// risposto "devo consultare il cielo" e "dimmi le date precise", senza
  /// chiamare la funzione: 2 domande su 20. Vero quando la domanda parla del
  /// cielo e la risposta rimanda alla consultazione o chiede le date.
  static bool rimanda({required String domanda, required String risposta}) {
    final cielo = RegExp(
            r'\b(pianet\w*|luna|sole|retrograd\w*|eclissi|cielo|mercurio|'
            r'venere|marte|giove|saturno|urano|nettuno|plutone|transit\w*)\b',
            caseSensitive: false)
        .hasMatch(domanda);
    if (!cielo) return false;
    // **UN ALTRO GIORNO SENZA CHIAMATA**, sesto giro dei banchi: a "Ci sono
    // eclissi nel 2027?" Medora ha risposto a memoria con due eclissi su
    // quattro. Una domanda sul cielo di un altro tempo a cui il modello
    // risponde senza chiamare la funzione si sollecita sempre: quel cielo il
    // modello non lo sa.
    if (RegExp(
            r'\b(domani|dopodomani|ieri|quando|prossim\w*|gennaio|febbraio|'
            r'marzo|aprile|maggio|giugno|luglio|agosto|settembre|ottobre|'
            r'novembre|dicembre|1[5-9]\d\d|2\d\d\d)\b',
            caseSensitive: false)
        .hasMatch(domanda)) {
      return true;
    }
    return RegExp(
            r'\b(devo|dovrei|posso|vado a|ho bisogno di) (prima )?consultare\b|'
            r'\bmi serv(?:e|ono)\b[^.?!]*\b(date|data|giorn[oi]|periodo)\b|'
            r'\b(dimmi|indicami|indica|precisami)\b[^.?!]*\b(date|data|'
            r'giorn[oi]|periodo|mese|anno)\b|'
            r'\bho bisogno di (sapere|conoscere)\b[^.?!]*\b(date|data|'
            r'giorn[oi]|periodo|mese|anno)\b',
            caseSensitive: false)
        .hasMatch(risposta);
  }

  /// La seconda richiesta, quando la prima risposta [rimanda].
  static const String sollecito = 'Chiama adesso la funzione del cielo e '
      'rispondi alla mia domanda con i fatti che restituisce. Le date le '
      'scegli tu: un mese dal primo all\'ultimo giorno, un anno dal primo '
      'gennaio al trentuno dicembre, "quando" da oggi a un anno da oggi.';

  /// Gli strumenti da dare al modello del Maestro.
  ///
  /// [carta] e' la carta natale della persona, quando c'e': serve ai transiti
  /// sulla carta. [adesso] dice al modello che giorno e' oggi.
  ///
  /// **Le descrizioni dicono al modello che il cielo non lo sa.** Ordine EV
  /// voce 03, banco del 1 ottobre 2026: con una descrizione che diceva solo
  /// quando chiamarle, il modello rispondeva da se' a cinque domande su venti
  /// ("la Luna oggi in Capricorno" con la Luna nei Gemelli, i gradi del 21
  /// dicembre 2020 inventati, il cielo di domani inventato) e a due chiedeva
  /// di nuovo la data che la persona aveva gia' scritto. Adesso la
  /// descrizione dice che ogni fatto del cielo viene solo da qui, che la data
  /// detta dalla persona si usa senza chiederla, e porta il cielo di oggi gia'
  /// calcolato, per chi ha i dati di nascita e per chi non li ha.
  static List<Tool> perIlMaestro({NatalChart? carta, DateTime? adesso}) {
    final ora = adesso ?? DateTime.now();
    final oggi = _oggi(ora);
    final domani = _oggi(DateTime(ora.year, ora.month, ora.day + 1));
    final cieloDiOggi = IlCieloPerIlMaestro.oggiInRighe(ora, carta: carta);
    return [
      Tool.functionDeclarations([
        AutoFunctionDeclaration(
          name: cieloDelGiorno,
          description: 'Il cielo vero di un giorno, calcolato dalle '
              'effemeridi dell\'app: segno e grado del Sole, della Luna e dei '
              'pianeti da Mercurio a Plutone, quali sono retrogradi, segno e '
              'fase della Luna, gli aspetti fra i pianeti, le eclissi e, se la '
              'persona ha la carta natale, i transiti sulla sua carta. '
              'Tu non conosci il cielo di nessun giorno: ogni segno, grado, '
              'fase, retrogrado, aspetto o eclissi di oggi, di domani, del '
              'passato o del futuro lo sai solo da qui. Oggi è $oggi, domani '
              'è $domani. Chiamala ogni volta che la persona chiede del cielo '
              'di un giorno o di un pianeta, di un transito, di un '
              'retrogrado, della Luna, prima di rispondere. Se la persona ha '
              'scritto la data, usala: non chiederla di nuovo. Rispondi solo '
              'con i fatti che restituisce, non dire mai un fatto del cielo '
              'che non viene da qui e non negare mai un fatto che viene da '
              'qui. I corpi che restituisce sono quelli del cielo del '
              'giorno, non quelli di nascita della persona: la Luna del '
              'giorno non è la sua Luna, e non le dai il segno o gli aspetti '
              'della Luna del giorno. Il cielo di oggi, già calcolato da '
              'questa funzione: '
              '$cieloDiOggi',
          parameters: {
            'data': Schema.string(
                description: 'Il giorno, nella forma AAAA-MM-GG. Oggi è '
                    '$oggi.'),
          },
          callable: (args) => giorno(args, carta: carta),
        ),
        AutoFunctionDeclaration(
          name: cieloDelPeriodo,
          description: 'Il cielo vero di un periodo, fino a un anno: le '
              'posizioni al primo giorno e gli eventi giorno per giorno '
              '(pianeti che cambiano segno, che diventano retrogradi o '
              'tornano diretti, lune nuove e piene, eclissi). Oggi è $oggi. '
              'Chiamala quando la persona chiede del cielo di un mese, di un '
              'anno o di un periodo, o di quando succede qualcosa (quando '
              'torna diretto un pianeta, la prossima Luna piena, le eclissi): '
              'per un mese chiedi dal primo all\'ultimo giorno del mese, per '
              'un anno dal primo gennaio al trentuno dicembre, per "quando" '
              'da oggi a un anno da oggi. Non chiedere alla persona di '
              'precisare il periodo: scegli tu queste date e chiama.',
          parameters: {
            'dal': Schema.string(
                description: 'Il primo giorno, nella forma AAAA-MM-GG.'),
            'al': Schema.string(
                description: 'L\'ultimo giorno, nella forma AAAA-MM-GG.'),
          },
          callable: periodo,
        ),
      ]),
    ];
  }
}
