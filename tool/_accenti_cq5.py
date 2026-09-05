# -*- coding: utf-8 -*-
"""CQ5: tre difetti miei, entrati con questo stesso ordine.

Due sono accenti scritti con l'apostrofo dentro stringhe che una persona legge,
il terzo e' una prova nuova che legge l'orologio vero senza dichiararlo.
"""
import sys
sys.path.insert(0, 'tool')
from _innesta_tmp import sostituisci  # noqa: E402

A = chr(39)
B = chr(92)

# 1. Il blocco che i Maestri ricevono: l'accento e' un accento.
F = 'lib/core/maestro/cio_che_arriva.dart'
sostituisci(
    F,
    "      'CIO" + B + A + " CHE ARRIVA. Lo sai perche" + B + A + " e" + B + A +
    " calcolato dal cielo vero e dal '" + chr(10) +
    "          'suo Cammino:',",
    "      'CIÒ CHE ARRIVA. Lo sai perché è calcolato dal cielo "
    "vero e dal '" + chr(10) +
    "          'suo Cammino:',")

sostituisci(
    F,
    "      'Nominane al massimo uno. Solo se c" + B + A + "entra con cio" + B +
    A + " che ti sta '" + chr(10) +
    "          'chiedendo. Non promettere nessun esito: di" + B + A +
    " che cosa succede e '" + chr(10) +
    "          'quando, mai che cosa produrra" + B + A + ".',",
    "      'Nominane al massimo uno. Solo se c" + B + A + "entra con ciò "
    "che ti sta '" + chr(10) +
    "          'chiedendo. Non promettere nessun esito: di" + B + A +
    " che cosa succede e '" + chr(10) +
    "          'quando, mai che cosa produrrà.',")

# 2. L'Arcano: "sara un altra" aveva perso l'accento E l'elisione.
sostituisci(
    'lib/features/rituals/day_oracle_screen.dart',
    "                    'giorno. Non da un caso: domani sara un altra.'",
    "                    'giorno. Non da un caso: domani sarà un" + A +
    "altra.'")

# 3. La prova nuova leggeva l'orologio vero. Un istante fermo, e la prova
#    smette di dipendere dal giorno in cui gira.
sostituisci(
    'test/i_maestri_sanno_cosa_arriva_test.dart',
    "    final eventi = ProssimiEventi.da(adesso: DateTime.now(), "
    "segno: Zodiac.leo);",
    "    // **L" + A + "ISTANTE E" + A + " FERMO, ordine U voce 00.** Con "
    "l" + A + "orologio vero questa prova" + chr(10) +
    "    // misurava un cielo diverso ogni giorno, e il giorno che ne "
    "capitasse uno" + chr(10) +
    "    // con meno di tre eventi il tetto non sarebbe stato messo alla "
    "prova." + chr(10) +
    "    final eventi = ProssimiEventi.da(" + chr(10) +
    "        adesso: DateTime.utc(2026, 9, 4), segno: Zodiac.leo);")

print('TRE DIFETTI CURATI')
