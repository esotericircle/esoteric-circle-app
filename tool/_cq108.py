# -*- coding: utf-8 -*-
"""CQ1.08: nessun suono che il fondatore non abbia scelto."""
import re

NL = chr(10)
CR = chr(13)
T = 'lib/design_system/theme/app_theme.dart'

# --- 1. il tema spegne il ritorno di sistema su tutti i comandi Material
grezzo = open(T, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo

vecchio = """      iconTheme: const IconThemeData(color: ColorTokens.textPrimary),"""
nuovo = """      iconTheme: const IconThemeData(color: ColorTokens.textPrimary),
      // **NESSUN SUONO CHE IL FONDATORE NON ABBIA SCELTO.**
      // Ordine CQ voce 1.08, 3 settembre 2026.
      //
      // **Il fatto, parole del fondatore:** *"togli ogni effetto sonoro che
      // non ho scelto io."*
      //
      // **La causa, misurata e non dedotta.** Ogni comando Material chiama
      // `Feedback.forTap` quando lo si preme, e su Android quel richiamo fa
      // suonare al SISTEMA il suo click e vibrare il telefono. Non e' un
      // suono di questa app: non sta nel catalogo, non passa dalla porta
      // unica, non conosce l'interruttore del silenzio del Cerchio, e nessuna
      // guardia del catalogo poteva vederlo perche' non e' un file negli
      // asset. **In tutta l'app non c'era un solo `enableFeedback` scritto**,
      // quindi valeva ovunque il vero di fabbrica.
      //
      // Si spegne QUI, sul tema, e non comando per comando: un interruttore
      // per comando vorrebbe dire che il primo che si dimentica riporta il
      // click di sistema, e nessuno saprebbe dove cercarlo. Gli `InkWell`
      // scritti a mano non leggono il tema e portano il loro, ed e' una
      // guardia a contarli.
      //
      // **PROVENIENZA IGNOTA.** Il comportamento e' quello di fabbrica di
      // Flutter: non c'e' una voce che lo abbia introdotto, c'e' un ordine
      // che non lo ha mai spento.
      filledButtonTheme: const FilledButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      outlinedButtonTheme: const OutlinedButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      segmentedButtonTheme: const SegmentedButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),
      listTileTheme: const ListTileThemeData(enableFeedback: false),
      dropdownMenuTheme: const DropdownMenuThemeData(
          inputDecorationTheme: InputDecorationTheme()),
      menuButtonTheme: const MenuButtonThemeData(
          style: ButtonStyle(enableFeedback: false)),"""

assert s.count(vecchio) == 1
s = s.replace(vecchio, nuovo)
open(T, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('FATTO il tema')

# --- 2. gli InkWell scritti a mano portano il loro interruttore ---------
import subprocess
uscita = subprocess.run(['grep', '-rln', 'InkWell(\\|InkResponse(', 'lib/'],
                        capture_output=True, text=True, shell=False)
toccati = 0
for percorso in uscita.stdout.split():
    g = open(percorso, 'rb').read().decode('utf-8')
    c = CR in g
    t = g.replace(CR + NL, NL) if c else g
    nuovo_t = re.sub(r'(Ink(?:Well|Response)\()(?!\s*\n?\s*enableFeedback)',
                     r'\1' + NL + '          enableFeedback: false,', t)
    if nuovo_t != t:
        toccati += 1
        open(percorso, 'wb').write(
            (nuovo_t.replace(NL, CR + NL) if c else nuovo_t).encode('utf-8'))
print('FATTO gli InkWell in %d sorgenti' % toccati)
