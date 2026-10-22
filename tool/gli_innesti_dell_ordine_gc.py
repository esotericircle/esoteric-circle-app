"""Regola A dell'ordine GC: gli innesti che fanno cadere le guardie nuove.

Uso: python innesti_gc.py <radice> metti|togli
Ogni innesto e' (file, testo giusto, testo col difetto, guardia attesa).
'metti' sostituisce e verifica col grep che il difetto sia entrato;
'togli' rimette il testo giusto e verifica che il difetto sia uscito.
"""
import os
import sys

QUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, QUI)
from scrivi_sicuro_gc import scrivi  # noqa: E402

INNESTI = [
    # GC.01: la carta torna a decodificarsi sempre piena.
    ('lib/features/tarot/tarot_card_art.dart',
     "    if (pixel <= latoDellaMiniatura) {\n      return (miniatura: true, decodifica: null);\n    }",
     "    if (pixel < 0) {\n      return (miniatura: true, decodifica: null);\n    }\n    return (miniatura: false, decodifica: null);",
     'gc_la_stesa_di_tarocchi GC.01'),
    # GC.01: la girata torna a ricostruire l'intera schermata.
    ('lib/features/tarot/stesa_tre_carte_screen.dart',
     "  void _cambiaIlTavolo(VoidCallback cambio) {\n    cambio();",
     "  void _cambiaIlTavolo(VoidCallback cambio) {\n    setState(cambio);",
     'gc_la_stesa_di_tarocchi GC.01 ricostruzioni'),
    # GC.02: la scena della Stesa torna a cominciare sotto la barra.
    ('lib/features/tarot/stesa_tre_carte_screen.dart',
     "    final scena = _laScena(palette, cieloSopra: margineAlto);",
     "    final scena = _laScena(palette, cieloSopra: 0);",
     'nessuna_fascia_sotto_la_barra_della_stesa GC.02'),
    # GC.03: il salto torna sulla posa scontornata.
    ('lib/features/tarot/stesa_tre_carte_screen.dart',
     "                fotogrammaDiArrivo:\n                    _posaDiMedora == GeometriaDelTavolo.posaDellInvito,",
     "                fotogrammaDiArrivo: false,",
     'la_scena_della_stesa_e_un_filmato GC.03'),
    # GC.04: scritta la domanda, la scelta resta.
    ('lib/features/tarot/tarot_selectors.dart',
     "        argomentoScelto: testo.trim().isEmpty,",
     "        argomentoScelto: true,",
     'gc_la_stesa_di_tarocchi GC.04'),
    # GC.05: la singola torna col riquadro.
    ('lib/core/responsi/la_forma_del_responso.dart',
     "        risposta: risposta,\n        cosaFare: '',\n        daDoveViene: daDoveViene,\n        singola: true,",
     "        risposta: risposta,\n        cosaFare: cosaFare,\n        daDoveViene: daDoveViene,\n        singola: false,",
     'gc_la_stesa_di_tarocchi GC.05'),
    # GC.06: il conto dei semi sbaglia seme.
    ('lib/features/tarot/le_barre_dei_semi.dart',
     "          s: carte.where((c) => c.card.seme == s).length,",
     "          s: carte.where((c) => c.card.seme != s).length,",
     'gc_la_stesa_di_tarocchi GC.06'),
    # GC.06 e GC.18: il colpo d'occhio della Stesa sparisce.
    ('lib/features/tarot/le_barre_dei_semi.dart',
     "            key: const Key('stesa_colpo_d_occhio'),",
     "            key: const Key('stesa_colpo_d_occhio_spento'),",
     'ogni_responso_apre_col_colpo_d_occhio Tarocchi'),
    # GC.07: il filmato dell'Oracolo torna a fermarsi a un istante scritto.
    ('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart',
     "        () => LettoreDiScena.vero(GeometriaDellAltare.filmato))",
     "        () => LettoreDiScena.vero(GeometriaDellAltare.filmato,\n            finoA: const Duration(milliseconds: 400)))",
     'l_oracolo_si_apre_senza_carte GC.07'),
    # GC.08: l'angelo dell'ora torna all'apertura.
    ('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart',
     "                  const SizedBox(height: SpacingTokens.sm),\n                  _LeOpzioni(",
     "                  _LAngeloDellOra(\n                    palette: palette,\n                    adesso: _ora(),\n                    triade: _triade,\n                    corpus: _corpus,\n                  ),\n                  const SizedBox(height: SpacingTokens.sm),\n                  _LeOpzioni(",
     'gc_l_oracolo_degli_angeli GC.08'),
    # GC.09: il ventaglio e' acceso gia' all'apertura.
    ('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart',
     "            opacity: affidata ? 1 : 0.4,",
     "            opacity: 1,",
     'gc_l_oracolo_degli_angeli GC.09'),
    # GC.14: la scritta della carta del Custode sbaglia.
    ('lib/features/angels/oracolo/la_scala_del_responso.dart',
     "      RuoloDellAngelo.custode => 'Fare',",
     "      RuoloDellAngelo.custode => 'Agire',",
     'gc_l_oracolo_degli_angeli GC.14'),
    # GC.17: la stesa a una carta non conta.
    ('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart',
     "    _forse<QuestionAllowance>()?.registraOracolo(tier);",
     "    if (_quante == 3) _forse<QuestionAllowance>()?.registraOracolo(tier);",
     'gc_l_oracolo_degli_angeli GC.17'),
    # GC.10: la scena non sale.
    ('lib/features/angels/oracolo/la_geometria_dell_altare.dart',
     "  static const double pixelDaAlzare = 10;",
     "  static const double pixelDaAlzare = 0;",
     'gc_l_oracolo_degli_angeli GC.10'),
    # GC.11: il simbolo torna la stellina.
    ('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart',
     "  static const IconData simboloDellInvio = Icons.keyboard_return_rounded;",
     "  static const IconData simboloDellInvio = Icons.auto_awesome_rounded;",
     'gc_l_oracolo_degli_angeli GC.11'),
    # GC.12: il volo non suona.
    ('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart',
     "      unawaited(PaletteSensoriale.suona(context, SuonoDelCerchio.carta));",
     "      // innesto: niente suono al volo",
     'gc_l_oracolo_degli_angeli GC.12'),
    # GC.13: dopo la riflessione nessun suono.
    ('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart',
     "    _sensi.momento(context, MomentoSensoriale.reveal);",
     "    // innesto: nessun suono dopo la riflessione",
     'gc_l_oracolo_degli_angeli GC.13'),
    # GC.15: la carta dell'Oracolo torna col riquadro.
    ('lib/core/oracolo_angeli/la_lettura_dell_oracolo.dart',
     "      cosaFare: '',\n      singola: true,\n    );\n  }",
     "      cosaFare: consiglioDellaCarta(corpus, c, variante) ?? '',\n      singola: false,\n    );\n  }",
     'gc_l_oracolo_degli_angeli GC.15'),
    # GC.16: lo sfondo torna piatto.
    ('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart',
     "          key: const Key('oracolo_sfondo'),",
     "          key: const Key('oracolo_sfondo_spento'),",
     'gc_l_oracolo_degli_angeli GC.16'),
    # GC.18: un gradino solo, sempre al centro.
    ('lib/features/angels/oracolo/la_scala_del_responso.dart',
     "  static int gradinoDi(CartaDellOracolo c) {\n    if (c.delMomento) return 1;",
     "  static int gradinoDi(CartaDellOracolo c) {\n    if (c.delMomento || true) return 1;",
     'gc_l_oracolo_degli_angeli GC.18'),
    # GC.19: la Lunga torna automatica dal piano.
    ('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart',
     "    final profonda = _profondita == AnswerDepth.profonda &&\n        PlanCatalog.apre(RigaDelPiano.oracoloLunga, tier);",
     "    final profonda = PlanCatalog.apre(RigaDelPiano.oracoloLunga, tier);",
     'gc_l_oracolo_degli_angeli GC.19'),
]


def main():
    radice, verso = sys.argv[1], sys.argv[2]
    per_file = {}
    for f, giusto, difetto, guardia in INNESTI:
        per_file.setdefault(f, []).append((giusto, difetto, guardia))
    for f, coppie in per_file.items():
        p = os.path.join(radice, f)
        s = open(p, encoding='utf-8').read()
        for giusto, difetto, guardia in coppie:
            da, a = (giusto, difetto) if verso == 'metti' else (difetto, giusto)
            assert s.count(da) == 1, (f, guardia, verso, s.count(da))
            s = s.replace(da, a)
        scrivi(p, s)
        s = open(p, encoding='utf-8').read()
        for giusto, difetto, guardia in coppie:
            dentro = difetto in s
            print('%s %s: difetto %s (%s)' % (
                verso, guardia, 'DENTRO' if dentro else 'fuori', f))
            assert dentro == (verso == 'metti')


if __name__ == '__main__':
    main()
