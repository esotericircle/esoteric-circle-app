/// **IL LETTORE DEI SORGENTI** della guardia `il_genere_non_si_indovina`. Il
/// dizionario e il criterio stanno in `lib/core/chat/le_forme_del_genere.dart`,
/// perche' li usano anche le guardie dei testi del modello.
library;

export 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';

/// **I LETTERALI DI UN SORGENTE**, coi commenti saltati e le concatenazioni
/// riunite: *'a ' 'b'* su due righe e' una frase sola, e una forma spezzata a
/// capo si deve leggere intera. Torna la riga dove comincia e il testo.
List<({int riga, String testo})> letteraliDi(String src) {
  final out = <({int riga, String testo})>[];
  var i = 0;
  var riga = 1;
  int? ultimaFine;
  final n = src.length;
  while (i < n) {
    final c = src[i];
    if (c == '\n') {
      riga++;
      i++;
      continue;
    }
    if (src.startsWith('//', i)) {
      final j = src.indexOf('\n', i);
      i = j < 0 ? n : j;
      continue;
    }
    if (src.startsWith('/*', i)) {
      var j = src.indexOf('*/', i + 2);
      j = j < 0 ? n : j + 2;
      riga += '\n'.allMatches(src.substring(i, j)).length;
      i = j;
      continue;
    }
    var grezzo = false;
    var q = c;
    var apertura = i;
    if ((c == 'r' || c == 'R') &&
        i + 1 < n &&
        (src[i + 1] == "'" || src[i + 1] == '"') &&
        !(i > 0 && RegExp(r'[A-Za-z0-9_]').hasMatch(src[i - 1]))) {
      grezzo = true;
      i++;
      q = src[i];
    }
    if (q == "'" || q == '"') {
      final tri = src.startsWith(q * 3, i);
      final chiusura = tri ? q * 3 : q;
      var j = i + chiusura.length;
      final buf = StringBuffer();
      while (j < n) {
        if (!grezzo && src[j] == r'\' && j + 1 < n) {
          final dopo = src[j + 1];
          buf.write(dopo == 'n' ? '\n' : dopo);
          j += 2;
          continue;
        }
        if (src.startsWith(chiusura, j)) break;
        if (!tri && src[j] == '\n') break;
        buf.write(src[j]);
        j++;
      }
      final tra = ultimaFine == null ? null : src.substring(ultimaFine, apertura);
      if (out.isNotEmpty && tra != null && tra.trim().isEmpty) {
        final ultimo = out.removeLast();
        out.add((riga: ultimo.riga, testo: ultimo.testo + buf.toString()));
      } else {
        out.add((riga: riga, testo: buf.toString()));
      }
      riga += '\n'.allMatches(src.substring(i, j)).length;
      i = j + chiusura.length;
      ultimaFine = i;
      continue;
    }
    i++;
  }
  return out;
}
