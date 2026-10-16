# -*- coding: utf-8 -*-
"""Ascolta il Realme: tocca X Y, poi per S secondi legge il registro delle
tracce di audio_flinger (AT::add, le tracce nuove) del processo dell'app e
stampa ogni traccia nuova con l'ora del telefono, accanto all'ora del tocco.
Uso: python ascolta.py X Y SECONDI [FILE_USCITA]"""
import re
import subprocess
import sys
import time

ADB = r'C:\Users\user\AppData\Local\Android\Sdk\platform-tools\adb.exe'
DEV = '767f596c'


def sh(*a):
    return subprocess.run([ADB, '-s', DEV, 'shell', *a], capture_output=True,
                          text=True, encoding='utf-8', errors='replace').stdout


pid = sh('pidof', 'com.esotericircle.esoteric_circle').strip()
x, y, durata = sys.argv[1], sys.argv[2], float(sys.argv[3])
uscita = sys.argv[4] if len(sys.argv) > 4 else None


def aggiunte():
    out = sh('dumpsys', 'media.audio_flinger')
    return [r.strip() for r in out.splitlines()
            if 'AT::add' in r and (' ' + pid + ' ') in r]


prima = set(aggiunte())
ora_tocco = sh('date', '+%H:%M:%S.%N').strip()[:12]
sh('input', 'tap', x, y)
t0 = time.time()
nuove = []
while time.time() - t0 < durata:
    for r in aggiunte():
        if r not in prima and r not in nuove:
            nuove.append(r)
    time.sleep(0.3)
righe = ['pid dell\'app %s; tocco in %s,%s alle %s (ora del telefono)' % (pid, x, y, ora_tocco),
         'tracce audio nuove dell\'app nei %d secondi dopo il tocco: %d' % (durata, len(nuove))]
for r in nuove:
    m = re.match(r'(\S+ \S+)\s+AT::add\s+\(\S+\)\s+(\d+)', r)
    righe.append('  %s traccia %s' % ((m.group(1), m.group(2)) if m else (r, '')))
testo = '\n'.join(righe)
print(testo)
if uscita:
    open(uscita, 'a', encoding='utf-8', newline='').write(testo + '\n')
