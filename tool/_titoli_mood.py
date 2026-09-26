# -*- coding: utf-8 -*-
"""CQ6.25: i nove titoli diventano risposte, non descrizioni del cielo.

**Il mood del Cerchio, parole del fondatore.** *"un titolo accattivante come
prima risposta che riassuma tutta la risposta"*, e prima: *"le risposte devono
partire con un titolo diretto che riassume tutto, un titolo che a colpo
d'occhio e' gia' una risposta diretta"*.

**Cosa c'era che non andava.** I nove titoli avevano tutti la stessa forma: il
soggetto era il cielo e la parola del giorno arrivava in coda, dopo una
subordinata. *"Oggi il buio e la luce stanno in una proporzione sola, che dice
custodire."* Settantaquattro caratteri per arrivare all'unica cosa che serve.

**Cosa cambia, ed e' una cosa sola.** Il soggetto diventa chi legge, e la
parola del giorno sale in testa invece di chiudere. Il fatto del cielo non
sparisce: scende nella risposta, che e' il suo posto, e la fonte scende ancora
piu' giu' dietro la porta.

**Cosa NON cambia**, ed e' la legge di casa: nessun titolo promette un esito.
Si dice cosa il giorno chiede, mai cosa succedera'.
"""
import sys
sys.path.insert(0, 'tool')
from _innesta_tmp import sostituisci  # noqa: E402

NL = chr(10)
A = chr(39)
F = 'lib/core/rituals/risposta_del_dono.dart'

vecchio = (
"  static const Map<(Maestro, DatoDelCielo), String> _titoli = {" + NL +
"    // --- MEDORA, il tempo e la direzione ---" + NL +
"    (Maestro.medora, DatoDelCielo.oraDellAlba):" + NL +
"        'Il tuo tempo di oggi è già cominciato e chiede {parola}.'," + NL +
"    (Maestro.medora, DatoDelCielo.segnoLunare):" + NL +
"        'Oggi la Luna ti indica una direzione che si chiama {parola}.'," + NL +
"    (Maestro.medora, DatoDelCielo.faseLunare):" + NL +
"        'Oggi il giorno è a un punto preciso del suo giro e vuole {parola}.'," + NL +
"    // --- AURA, il corpo e l'energia ---" + NL +
"    (Maestro.aura, DatoDelCielo.oraDellAlba):" + NL +
"        'Oggi il tuo corpo ha già la luce che gli serve e chiede {parola}.'," + NL +
"    (Maestro.aura, DatoDelCielo.segnoLunare):" + NL +
"        'Oggi la tua energia ha un colore solo: {parola}.'," + NL +
"    (Maestro.aura, DatoDelCielo.faseLunare):" + NL +
"        'Oggi il respiro è la cosa più corta da cambiare e porta {parola}.'," + NL +
"    // --- CALIGO, il simbolo ---" + NL +
"    (Maestro.caligo, DatoDelCielo.oraDellAlba):" + NL +
"        'Oggi la luce è tornata a un" + chr(92) + A + "ora precisa e il segno è {parola}.'," + NL +
"    (Maestro.caligo, DatoDelCielo.segnoLunare):" + NL +
"        'Oggi la Luna porta un segno che ti riguarda: {parola}.'," + NL +
"    (Maestro.caligo, DatoDelCielo.faseLunare):" + NL +
"        'Oggi il buio e la luce stanno in una proporzione sola, che dice '" + NL +
"            '{parola}.'," + NL +
"  };")

nuovo = (
"  /// **IL TITOLO E" + A + " LA RISPOSTA, non l" + A + "annuncio della risposta.**" + NL +
"  /// Ordine CQ voce 6.25, 4 settembre 2026." + NL +
"  ///" + NL +
"  /// **La forma di prima, e perche" + A + " non teneva.** I nove titoli avevano tutti" + NL +
"  /// il cielo come soggetto e la parola del giorno in coda, dopo una" + NL +
"  /// subordinata: *Oggi il buio e la luce stanno in una proporzione sola, che" + NL +
"  /// dice custodire.* Settantaquattro caratteri per arrivare all" + A + "unica cosa" + NL +
"  /// che serve, e chi legge in fretta si perdeva proprio quella." + NL +
"  ///" + NL +
"  /// **La forma di adesso.** Il soggetto e" + A + " chi legge, e la parola sale in" + NL +
"  /// testa. Il fatto del cielo non sparisce: scende nella risposta, che e" + A + " il" + NL +
"  /// suo posto, e la fonte scende ancora piu" + A + " giu" + A + " dietro la porta." + NL +
"  ///" + NL +
"  /// **Restano nove e non uno**: il titolo cambia col Maestro del giorno e" + NL +
"  /// col dato che il rito nomina, perche" + A + " tre Maestri che dicono la stessa" + NL +
"  /// frase non sono tre Maestri." + NL +
"  static const Map<(Maestro, DatoDelCielo), String> _titoli = {" + NL +
"    // --- MEDORA, il tempo e la direzione ---" + NL +
"    (Maestro.medora, DatoDelCielo.oraDellAlba):" + NL +
"        'Oggi il tuo tempo chiede {parola}.'," + NL +
"    (Maestro.medora, DatoDelCielo.segnoLunare):" + NL +
"        'Oggi la tua direzione si chiama {parola}.'," + NL +
"    (Maestro.medora, DatoDelCielo.faseLunare):" + NL +
"        'Oggi il tuo giorno vuole {parola}.'," + NL +
"    // --- AURA, il corpo e l'energia ---" + NL +
"    (Maestro.aura, DatoDelCielo.oraDellAlba):" + NL +
"        'Oggi il tuo corpo chiede {parola}.'," + NL +
"    (Maestro.aura, DatoDelCielo.segnoLunare):" + NL +
"        'Oggi la tua energia ha un colore solo: {parola}.'," + NL +
"    (Maestro.aura, DatoDelCielo.faseLunare):" + NL +
"        'Oggi il tuo respiro porta {parola}.'," + NL +
"    // --- CALIGO, il simbolo ---" + NL +
"    (Maestro.caligo, DatoDelCielo.oraDellAlba):" + NL +
"        'Oggi il tuo segno è {parola}.'," + NL +
"    (Maestro.caligo, DatoDelCielo.segnoLunare):" + NL +
"        'Oggi la Luna ti chiede {parola}.'," + NL +
"    (Maestro.caligo, DatoDelCielo.faseLunare):" + NL +
"        'Oggi tieni insieme luce e ombra, e si dice {parola}.'," + NL +
"  };")

sostituisci(F, vecchio, nuovo)
print('NOVE TITOLI RISCRITTI')
