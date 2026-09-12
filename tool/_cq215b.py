# -*- coding: utf-8 -*-
"""CQ2.15: la sorgente unica porta anche il prossimo passo del Cammino."""
NL = chr(10)
CR = chr(13)
P = 'lib/core/maestro/sorgente_natale.dart'


def cambia(percorso, vecchio, nuovo, quante=1):
    grezzo = open(percorso, 'rb').read().decode('utf-8')
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    assert s.count(vecchio) == quante, (percorso, s.count(vecchio),
                                        vecchio[:70])
    s = s.replace(vecchio, nuovo)
    open(percorso, 'wb').write(
        (s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
    assert nuovo.split(NL)[0].strip() in \
        open(percorso, 'rb').read().decode('utf-8'), percorso
    print('FATTO', percorso)


cambia(P, """  static NatalContext daIdentita(BirthIdentityController identita) {
    if (!identita.hasBirth) return NatalContext.none;
    final base = NatalContext.fromNatal(
      chart: identita.chart,
      facts: identita.facts,
    );""",
       """  /// **E IL PROSSIMO PASSO DEL CAMMINO PASSA DA QUI.**
  /// Ordine CQ voce 2.15, 4 settembre 2026.
  ///
  /// [diario] e' facoltativo perche' non tutte le superfici ce l'hanno, e una
  /// sorgente che lo PRETENDE farebbe cadere le prove che montano una
  /// schermata da sola: e' la stessa tolleranza che il progetto usa gia' per
  /// i servizi del guscio. Senza diario il contesto esce come prima, e nel
  /// prompt non compare nessuna riga sul Cammino.
  static NatalContext daIdentita(BirthIdentityController identita,
      {DiarioDelCammino? diario}) {
    final (nome, apre) = _prossimoPasso(diario);
    if (!identita.hasBirth) {
      return nome == null
          ? NatalContext.none
          : NatalContext(
              prossimoTraguardo: nome, cosaApreIlProssimoTraguardo: apre);
    }
    final base = NatalContext.fromNatal(
      chart: identita.chart,
      facts: identita.facts,
      prossimoTraguardo: nome,
      cosaApreIlProssimoTraguardo: apre,
    );""")

cambia(P, """        moonIllumination: base.moonIllumination,
      );
    }
    return base;
  }
}""",
       """        moonIllumination: base.moonIllumination,
        prossimoTraguardo: base.prossimoTraguardo,
        cosaApreIlProssimoTraguardo: base.cosaApreIlProssimoTraguardo,
      );
    }
    return base;
  }

  /// Il prossimo gradino da prendere, scelto fra i tre sentieri: quello piu'
  /// vicino a chi cammina, cioe' col numero di posizione piu' basso.
  ///
  /// **Uno e non tre.** Il contesto di una conversazione non e' un cruscotto:
  /// tre nomi di gradino dentro un'istruzione di sistema diventano un elenco
  /// che il modello ripete, e la regola dei due strati vuole che il Maestro
  /// parli, non che legga il Cammino.
  static (String?, String?) _prossimoPasso(DiarioDelCammino? diario) {
    if (diario == null) return (null, null);
    Traguardo? migliore;
    for (final s in Sentiero.values) {
      final t = diario.prossimoDi(s);
      if (t == null) continue;
      if (migliore == null || t.posizione < migliore.posizione) migliore = t;
    }
    return (migliore?.nome, migliore?.cosaApre);
  }
}""")

# gli import della sorgente
grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo
for imp in ("import '../sigilli/diario_del_cammino.dart';",
            "import '../sigilli/sentieri.dart';",
            "import '../sigilli/traguardo.dart';"):
    if imp not in s:
        s = s.replace("import 'natal_context.dart';",
                      imp + NL + "import 'natal_context.dart';", 1)
open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('IMPORT AGGIUNTI')
