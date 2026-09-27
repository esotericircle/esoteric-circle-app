import 'package:flutter/painting.dart';

/// **IL TITOLO CHE VA A CAPO COL TRATTINO.** Ordine ER voce 09, 27 settembre
/// 2026.
///
/// Il fondatore ha rimpicciolito le schede della home (128 punti le verticali
/// e le quadrate, 137 le orizzontali) e ha portato i loro titoli a dodici
/// punti, al massimo su due righe e mai piu' piccoli: *"La home mi convince
/// adesso."* L'ordine aggiunge che *la parola che non sta nella riga va a capo
/// col trattino*, e che nessun titolo resta tagliato.
///
/// **Flutter non sa sillabare**: una parola piu' larga della riga la spezza
/// dove capita, fra due lettere qualsiasi e senza trattino. Qui il titolo si
/// compone a mano, riga per riga, e le righe si danno gia' fatte al `Text`.
///
/// **Il trattino si usa solo quando serve**, e le regole sono due, in ordine:
/// 1. **a capo fra le parole**: se cosi' il titolo sta nelle sue righe e ogni
///    parola sta nella sua riga, non si spezza niente;
/// 2. **altrimenti si riempie ogni riga** e la parola che non ci sta si spezza
///    a una sillaba, col trattino in fondo alla riga.
///
/// Una sillaba sola in fondo o in cima alla riga non si lascia: il pezzo che
/// resta sopra e quello che va sotto hanno almeno due lettere, come nella
/// tipografia italiana.
abstract final class IlTitoloColTrattino {
  /// Le righe del [testo], composte nella [larghezza] con lo [stile].
  ///
  /// Restituisce al massimo [maxRighe] righe; se il titolo non ci sta
  /// nemmeno col trattino restituisce le righe che ha composto, anche se
  /// sono di piu', cosi' che una prova lo possa contare invece di vederlo
  /// tagliato in silenzio.
  static List<String> righe(
    String testo, {
    required TextStyle stile,
    required double larghezza,
    TextScaler scala = TextScaler.noScaling,
    int maxRighe = 2,
  }) {
    bool sta(String riga) => larghezzaDi(riga, stile, scala) <= larghezza;
    final parole =
        testo.split(' ').where((p) => p.isNotEmpty).toList(growable: false);

    // 1. A capo fra le parole.
    final fraLeParole = <String>[];
    var corrente = '';
    var ogniParolaSta = true;
    for (final p in parole) {
      if (!sta(p)) ogniParolaSta = false;
      final prova = corrente.isEmpty ? p : '$corrente $p';
      if (corrente.isEmpty || sta(prova)) {
        corrente = prova;
      } else {
        fraLeParole.add(corrente);
        corrente = p;
      }
    }
    if (corrente.isNotEmpty) fraLeParole.add(corrente);
    if (ogniParolaSta && fraLeParole.length <= maxRighe) return fraLeParole;

    // 2. Si riempie ogni riga, e la parola che non ci sta si spezza.
    final colTrattino = <String>[];
    corrente = '';
    for (final p in parole) {
      var resto = p;
      while (resto.isNotEmpty) {
        final prima = corrente.isEmpty ? '' : '$corrente ';
        if (sta('$prima$resto')) {
          corrente = '$prima$resto';
          resto = '';
          break;
        }
        final taglio = _ilTaglioPiuLungo(resto, prima, sta);
        if (taglio != null) {
          colTrattino.add('$prima${taglio.testa}');
          corrente = '';
          resto = taglio.coda;
        } else if (corrente.isNotEmpty) {
          colTrattino.add(corrente);
          corrente = '';
        } else {
          // Una parola che non si puo' spezzare in modo che un pezzo stia:
          // resta intera, e la prova la conta.
          corrente = resto;
          resto = '';
        }
      }
    }
    if (corrente.isNotEmpty) colTrattino.add(corrente);
    return colTrattino;
  }

  /// La larghezza di una riga dipinta, in punti.
  static double larghezzaDi(String riga, TextStyle stile, TextScaler scala) {
    final p = TextPainter(
      text: TextSpan(text: riga, style: stile),
      textDirection: TextDirection.ltr,
      textScaler: scala,
      maxLines: 1,
    )..layout();
    final w = p.width;
    p.dispose();
    return w;
  }

  /// Il taglio di [parola] che riempie di piu' la riga che comincia con
  /// [prima]: la testa col trattino (o senza, se il taglio cade dopo un
  /// apostrofo o un trattino che c'e' gia'), e la coda che va sotto.
  ///
  /// **Sotto vanno almeno quattro lettere, se si puo'**: *Astrocarto- /
  /// grafia* e non *Astrocartogra- / fia*, che e' giusto per la grammatica ma
  /// lascia sotto un moncherino. Se nessun taglio lo permette, vale il piu'
  /// lungo che sta.
  static ({String testa, String coda})? _ilTaglioPiuLungo(
      String parola, String prima, bool Function(String) sta) {
    final punti = LeSillabe.puntiDiTaglio(parola);
    ({String testa, String coda})? ripiego;
    for (final i in punti.reversed) {
      final testa = parola.substring(0, i);
      final coda = parola.substring(i);
      final segno = testa.endsWith('\'') || testa.endsWith('-') ? '' : '-';
      if (!sta('$prima$testa$segno')) continue;
      final taglio = (testa: '$testa$segno', coda: coda);
      if (RegExp(r'[A-Za-zÀ-ÿ]').allMatches(coda).length >= 4) return taglio;
      ripiego ??= taglio;
    }
    return ripiego;
  }
}

/// **LE SILLABE DELL'ITALIANO**, quanto basta per andare a capo bene.
///
/// Le regole della grammatica, nella forma che serve a un titolo:
/// - una consonante fra due vocali va con la seconda (*ca-sa*);
/// - le doppie si dividono (*Si-gil-lo*);
/// - la *s* seguita da consonante va con la sillaba dopo (*O-ro-sco-po*);
/// - una consonante seguita da *l* o *r* va con loro (*A-stro*, *ca-pra*),
///   come *ch*, *gh*, *gn*, *gl*, *sc*;
/// - negli altri gruppi di consonanti il taglio cade dopo la prima
///   (*par-te*, *In-ten-zio-ne*);
/// - due vocali forti vicine si dividono (*Ma-e-stro*), le altre restano
///   insieme (*zio-ne*, *Bio-rit-mo*);
/// - dopo un apostrofo o un trattino che ci sono gia' si puo' sempre andare
///   a capo.
abstract final class LeSillabe {
  static const String _vocali = 'aeiouàèéìíòóùúAEIOUÀÈÉÌÍÒÓÙÚyY';
  static const String _forti = 'aeoàèéòóAEOÀÈÉÒÓ';
  static bool _vocale(String c) => _vocali.contains(c);
  static bool _lettera(String c) => RegExp(r'[A-Za-zÀ-ÿ]').hasMatch(c);

  /// Le posizioni dentro [parola] dove si puo' andare a capo: il pezzo prima
  /// e quello dopo hanno almeno due lettere.
  static List<int> puntiDiTaglio(String parola) {
    final punti = <int>{};
    // Dopo un apostrofo o un trattino.
    for (var i = 1; i < parola.length - 1; i++) {
      if (parola[i - 1] == '\'' || parola[i - 1] == '-') punti.add(i);
    }
    // Dentro ogni pezzo fatto solo di lettere.
    final pezzo = RegExp(r"[A-Za-zÀ-ÿ]+");
    for (final m in pezzo.allMatches(parola)) {
      for (final t in _sillabe(m.group(0)!)) {
        punti.add(m.start + t);
      }
    }
    int lettere(String s) => s.split('').where(_lettera).length;
    return (punti
            .where((i) =>
                i > 0 &&
                i < parola.length &&
                lettere(parola.substring(0, i)) >= 2 &&
                lettere(parola.substring(i)) >= 2)
            .toList()
          ..sort())
        .toList(growable: false);
  }

  /// I tagli fra sillabe dentro una parola di sole lettere.
  static List<int> _sillabe(String w) {
    final tagli = <int>[];
    final n = w.length;
    var i = 0;
    // Si salta l'attacco: le consonanti prima della prima vocale.
    while (i < n && !_vocale(w[i])) {
      i++;
    }
    while (i < n) {
      // Il nucleo: la vocale, e le vocali che le stanno attaccate.
      var j = i + 1;
      while (j < n && _vocale(w[j])) {
        if (_forti.contains(w[j - 1]) && _forti.contains(w[j])) {
          tagli.add(j); // iato: due vocali forti si dividono
        }
        j++;
      }
      // Le consonanti fino alla vocale dopo.
      var k = j;
      while (k < n && !_vocale(w[k])) {
        k++;
      }
      if (k >= n) break; // consonanti finali: restano con l'ultima sillaba
      final gruppo = w.substring(j, k).toLowerCase();
      tagli.add(j + _taglioNelGruppo(gruppo));
      i = k;
    }
    return tagli;
  }

  /// Dove si taglia un gruppo di consonanti fra due vocali: quante ne
  /// restano con la sillaba prima.
  static int _taglioNelGruppo(String g) {
    if (g.length <= 1) return 0;
    if (g[0] == g[1]) return 1; // le doppie si dividono
    if (g[0] == 's') return 0; // la s impura va con la sillaba dopo
    const attacchi = {'ch', 'gh', 'gn', 'gl', 'sc', 'qu'};
    if (g.length == 2) {
      if (attacchi.contains(g)) return 0;
      if ('lr'.contains(g[1]) && !'lmnr'.contains(g[0])) return 0;
      return 1;
    }
    // Tre o piu': la prima resta sopra, se le altre fanno un attacco.
    final dopo = g.substring(1);
    if (dopo[0] == 's' ||
        attacchi.contains(dopo.substring(0, 2)) ||
        ('lr'.contains(dopo[1]) && !'lmnr'.contains(dopo[0]))) {
      return 1;
    }
    return g.length - 1;
  }
}
