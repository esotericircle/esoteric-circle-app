# -*- coding: utf-8 -*-
"""DOVE SI ROMPE LA VOCE DEL LIVE. Ordine FE voce 05, 6 ottobre 2026.

Legge una cartella registrata da `fe05_registra.py` (registro.txt del
telefono, microfono.wav del PC, turni.txt) e trova, dentro ogni tratto in cui
il Maestro parla, i silenzi lunghi: la voce che si interrompe a meta'
risposta. Il tratto del Maestro va dal "primo suono al volto" per la durata
dell'audio mandato (la riga del registro dice quanto), sull'orologio del
telefono, che e' quello del PC (verificato con `adb shell date`).

Un silenzio e' una rottura quando dura almeno SOGLIA_MS con voce prima e
dopo: le pause fra le frasi della voce sintetica stanno sotto i 700 ms.

    python tool/dove_si_rompe_la_voce.py docs/collaudo/FE/voci/prima_2298_medora
"""
import datetime
import io
import math
import os
import re
import struct
import sys
import wave

SOGLIA_MS = 800
PASSO_MS = 20


def main(cartella):
    turni = io.open(os.path.join(cartella, 'turni.txt'), encoding='utf-8').read()
    inizio = re.search(r'inizio (\d\d:\d\d:\d\d)', turni).group(1)
    giorno = datetime.date.today()
    t0 = datetime.datetime.combine(
        giorno, datetime.datetime.strptime(inizio, '%H:%M:%S').time())
    w = wave.open(os.path.join(cartella, 'microfono.wav'))
    tasso = w.getframerate()
    dati = w.readframes(w.getnframes())
    campioni = struct.unpack('<%dh' % (len(dati) // 2), dati)
    n = tasso * PASSO_MS // 1000
    db = []
    for i in range(0, len(campioni) - n, n):
        pezzo = campioni[i:i + n]
        rms = math.sqrt(sum(x * x for x in pezzo) / n) or 1
        db.append(20 * math.log10(rms / 32768))
    fondo = sorted(db)[len(db) // 10]
    soglia = fondo + 12
    registro = io.open(os.path.join(cartella, 'registro.txt'),
                       encoding='utf-8', errors='replace').read()
    righe = []
    rotture = 0
    for m in re.finditer(r'(\d\d:\d\d:\d\d\.\d+) I/flutter.*?primo suono al '
                         r'volto dopo (\d+) ms, audio di (\d+) ms, scritto in '
                         r'(\d+) ms', registro):
        ora = datetime.datetime.combine(
            giorno, datetime.datetime.strptime(m.group(1), '%H:%M:%S.%f').time())
        scritto = int(m.group(4))
        primo = int(m.group(2))
        audio = int(m.group(3))
        # La riga si scrive quando la voce e' stata tutta mandata: il primo
        # suono e' "scritto - primo" millisecondi prima.
        da = (ora - t0).total_seconds() - (scritto - primo) / 1000
        a = da + audio / 1000
        i0, i1 = int(da * 1000 / PASSO_MS), int(a * 1000 / PASSO_MS)
        tratto = db[max(0, i0):min(len(db), i1)]
        silenzi = []
        corsa = 0
        voce_vista = False
        for k, v in enumerate(tratto):
            if v < soglia:
                corsa += 1
            else:
                if voce_vista and corsa * PASSO_MS >= SOGLIA_MS:
                    fine = da + (k * PASSO_MS) / 1000
                    silenzi.append((fine - corsa * PASSO_MS / 1000, corsa * PASSO_MS))
                corsa = 0
                voce_vista = True
        rotture += len(silenzi)
        # Quanta parte del tratto e' voce: se il tratto non cade sulla voce
        # del Maestro, l'assenza di rotture non vuol dire niente.
        voce = sum(1 for v in tratto if v >= soglia) / max(1, len(tratto))
        righe.append(
            f'risposta di {audio / 1000:.1f} s dal secondo {da:.1f} al {a:.1f}, '
            f'voce nel {voce * 100:.0f} per cento del tratto, '
            f'scritta in {scritto / 1000:.1f} s: '
            + (', '.join(f'silenzio di {ms} ms al secondo {s:.1f}'
                         for s, ms in silenzi) or 'nessuna rottura'))
    testo = (f'DOVE SI ROMPE LA VOCE, {cartella}\n'
             f'fondo della stanza {fondo:.0f} dB, soglia della voce '
             f'{soglia:.0f} dB, rottura da {SOGLIA_MS} ms di silenzio\n'
             + '\n'.join(righe)
             + f'\nORDINE FE VOCE 05: {rotture} rotture in {len(righe)} '
               f'tratti di voce\n')
    print(testo)
    io.open(os.path.join(cartella, 'dove_si_rompe.txt'), 'w',
            encoding='utf-8', newline='\n').write(testo)


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    main(sys.argv[1])
