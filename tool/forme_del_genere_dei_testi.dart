// IL CRITERIO DEL GENERE, DA RIGA DI COMANDO. Ordine FT voce FT.12.
//
// Lo strumento del corpus della Sinastria approfondita
// (tool/il_corpus_della_sinastria.py) non riscrive il criterio del genere in
// Python: lo chiede qui, cosi' e' lo stesso identico criterio della guardia
// di casa `il_genere_non_si_indovina` (lib/core/chat/le_forme_del_genere.dart).
// Due criteri per la stessa regola divergono al primo che ne cambia uno.
//
// Uso: dart run tool/forme_del_genere_dei_testi.dart <testi.json>
// Il file e' una lista di stringhe; stampa una lista JSON, per ogni testo le
// forme del genere trovate (vuota se il testo non dice il genere di chi
// legge). Le marche [m|f|n] ben formate non contano: la guardia le accetta.
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';

void main(List<String> argomenti) {
  final testi = (jsonDecode(File(argomenti.first).readAsStringSync()) as List)
      .cast<String>();
  final marca = RegExp(r'\[[^\[\]]*\|[^\[\]]*\|[^\[\]]*\]');
  final esito = [
    for (final t in testi) formeDelGenere(t.replaceAll(marca, ' ')),
  ];
  stdout.write(jsonEncode(esito));
}
