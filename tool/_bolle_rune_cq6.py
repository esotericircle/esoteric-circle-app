# -*- coding: utf-8 -*-
"""CQ6.19 e CQ6.22: le bolle delle rune, tre paragrafi e la prosa ampia.

**Parole del fondatore, 4 settembre 2026.** *"Per le bolle singole delle Rune:
Intestazione con immagine runa OK. Poi sotto 3 paragrafi: Giallo, Bianco,
Giallo. Mi raccomando UNIFORMA i testi."* E prima: *"E per quanto riguarda le
mie nuove regole della dimensione del testo e della quantita' di testo nelle
bolle delle singole rune, non hai fatto nulla?"*

**Aveva ragione su tutti e due i punti.** Sulla quantita' avevo messo la porta
alla sola runa singola, con una decisione mia scritta cosi': *a tre e a cinque
rune restano dove erano, perche' li' sono il corpo della lettura*. I suoi
screenshot dicono di no: **1833 caratteri per la gettata a tre, 3055 per la
Croce delle Cinque.**

**E la soluzione e' piu' pulita di quanto sembrasse.** Mettendo dietro la porta
la materia storica e la strofa, che sono la FONTE, restano esattamente **tre
paragrafi**: il significato, la risposta, il cielo con la domanda. Sono i tre
che il fondatore chiede, e i colori si posano da soli.
"""
import sys
sys.path.insert(0, 'tool')
from _innesta_tmp import sostituisci  # noqa: E402

NL = chr(10)
A = chr(39)
F = 'lib/features/maestri/caligo/rune/rune_draw_screen.dart'

# --- 1. La scheda riceve la voce gia' divisa in due -----------------------
sostituisci(
    F,
    "      this.sola = false," + NL +
    "      this.voce," + NL +
    "      this.giuntura});",
    "      this.sola = false," + NL +
    "      this.voce," + NL +
    "      this.daDoveNasce," + NL +
    "      this.giuntura});")

sostituisci(
    F,
    "  /// Nel getto libero le rune lette sono in luce, non hanno il verso "
    "d'ombra." + NL +
    "  final bool libera;",
    "  /// **LA MATERIA STORICA, che sta dietro la porta. Ordine CQ voce 6.19,"
    + NL +
    "  /// 4 settembre 2026.**" + NL +
    "  ///" + NL +
    "  /// La voce della runa arriva in due pezzi: la risposta, che resta a" + NL +
    "  /// vista, e **da dove nasce**, che e" + A + " la fonte e per la legge dei testi" + NL +
    "  /// va breve e in fondo. Qui c" + A + "e" + A + " il secondo." + NL +
    "  final String? daDoveNasce;" + NL + NL +
    "  /// Nel getto libero le rune lette sono in luce, non hanno il verso "
    "d'ombra." + NL +
    "  final bool libera;")

print('SCHEDA PRONTA A RICEVERE LA FONTE')
