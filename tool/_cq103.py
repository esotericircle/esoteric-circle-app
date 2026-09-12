# -*- coding: utf-8 -*-
"""CQ1.03: il ventaglio vive subito, il pulsante apre il responso."""
NL = chr(10)
CR = chr(13)
P = 'lib/features/tarot/stesa_tre_carte_screen.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo

# --- 1. il ventaglio non chiede piu' il permesso ------------------------
vecchio = """    // **FINCHE' NESSUNO HA COMINCIATO, IL VENTAGLIO NON RISPONDE.** Ordine CO
    // voce 07: il rito lo comincia chi lo compie, premendo, e non un tocco
    // capitato su una carta mentre si guardava.
    if (!_letturaAvviata) return;
"""
nuovo = """    // **IL VENTAGLIO E' VIVO DA SUBITO.** Ordine CQ voce 1.03, 3 settembre
    // 2026, e ribalta l'ordine CO voce 07 per decisione del fondatore.
    //
    // CO.07 aveva messo un pulsante PRIMA delle carte, perche' la stesa
    // partiva sul primo tocco senza che nessuno l'avesse cominciata. La cura
    // era giusta nel movente e sbagliata nel posto: chiedeva di premere per
    // ottenere il permesso di scegliere. **Il fondatore lo vuole al
    // contrario**: si sceglie subito, e il pulsante sta DOPO le tre carte,
    // dove decide se leggere. Cosi' il gesto che costa e' uno solo, e non e'
    // il tocco su una carta.
"""
assert s.count(vecchio) == 1, s.count(vecchio)
s = s.replace(vecchio, nuovo)

# --- 2. il blocco del compimento esce da _pick --------------------------
apri = s.index('    // LA STESA ENTRA NEL CAMMINO, ordine P voce 35. Qui, e non')
chiudi = s.index('    // Il flip, poi la fioritura dell\'elemento', apri)
blocco = s[apri:chiudi]
assert blocco.count('if (_complete) {') == 1
# si toglie l'involucro `if (_complete) {` e si porta il corpo a due spazi
corpo = blocco.split('if (_complete) {', 1)[1]
corpo = corpo.rstrip()
assert corpo.endswith('}')
corpo = corpo[:-1].rstrip(NL)
corpo = NL.join(r[2:] if r.startswith('  ') else r for r in corpo.split(NL))
premessa = blocco.split('if (_complete) {', 1)[0]
premessa = NL.join(r for r in premessa.split(NL) if r.strip().startswith('//'))
s = s[:apri] + s[chiudi:]

# --- 3. e il filo e il pensiero di Medora seguono lo stesso pulsante ----
vecchio = """    // IL FILO, ordine BN voce 08: dice che le tre carte sono una lettura sola,
    // e lo dice PRIMA che Medora cominci a pensare.
    if (_complete) await _corriIlFilo();
    // MEDORA CI PENSA, ordine P voce 06: solo alla TERZA carta, perche' e' li'
    // che il responso comincia, e prima non c'e' niente da guardare insieme.
    if (_complete) await _medoraCiPensa();
  }
"""
nuovo = """  }

  /// **IL RESPONSO SI APRE QUANDO LO CHIEDI, E SOLO ALLORA SI PAGA.**
  /// Ordine CQ voce 1.03, 3 settembre 2026.
  ///
  /// **Il fatto, parole del fondatore:** *"la stesa deve rimanere viva sin
  /// dall'inizio, l'utente sceglie le 3 carte e poi il pulsante diventa
  /// premibile."*
  ///
  /// **La provenienza e' l'ordine CO voce 07**, che aveva messo il pulsante
  /// prima delle carte. Qui il pulsante torna dopo, e cambia mestiere: non
  /// da' il permesso di scegliere, apre la lettura di cio' che si e' gia'
  /// scelto.
  ///
  /// **E' questo il gesto che costa.** Il cancello del piano si guarda qui e
  /// in nessun altro punto: tre carte posate e poi ripensarci non consuma
  /// niente, ed e' la stessa legge dell'ordine BN voce 09, spostata sul gesto
  /// che adesso la porta.
  Future<void> _apriIlResponso() async {
    if (!_complete || _responsoPronto || _stoPerRiflettere) return;
    if (!_laStesaSiPuoAprire(riprova: _apriIlResponso)) return;
PREMESSA
CORPO
    // IL FILO, ordine BN voce 08: dice che le tre carte sono una lettura sola,
    // e lo dice PRIMA che Medora cominci a pensare.
    await _corriIlFilo();
    // MEDORA CI PENSA, ordine P voce 06: dal pulsante, perche' e' li' che il
    // responso comincia, e prima non c'e' niente da guardare insieme.
    await _medoraCiPensa();
  }
"""
nuovo = nuovo.replace('PREMESSA', premessa.rstrip(NL)).replace('CORPO', corpo)
assert s.count(vecchio) == 1
s = s.replace(vecchio, nuovo)

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('FATTO. _apriIlResponso presente:', '_apriIlResponso()' in s)
print('_letturaAvviata resta in:', s.count('_letturaAvviata'))
