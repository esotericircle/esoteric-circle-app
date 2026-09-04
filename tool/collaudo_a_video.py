# -*- coding: utf-8 -*-
"""IL COLLAUDO A VIDEO, sul telefono vero.

**Ordine CQ voce 6.18, 4 settembre 2026.** Nasce da una frase del fondatore:
*"se vuoi puoi verificare da solo le funzionalita' in autonomia"*.

**Perche' esiste, e vale piu' di quanto sembri.** Il conto delle ore di questa
giornata dice che sette voci dichiarate chiuse non lo erano sul telefono, e che
**sette volte su sette la guardia misurava un pezzo sano accanto al pezzo
rotto**: il file e non il tono, la funzione e non il disegno, il pulsante e non
la pagina attorno. Nessuna prova Flutter puo' chiudere quel divario, perche'
gira senza schermo e senza plugin.

Questo strumento apre l'app sul telefono, la tocca dove la toccherebbe una
persona e riporta cosa c'e' a video, leggendo l'albero delle viste. **Non
sostituisce le guardie**: e' l'occhio che manca a monte, quello che dice se
vale la pena scrivere una guardia e dove.
"""
import io
import os
import re
import subprocess
import sys
import time

NL = chr(10)
ADB = os.environ.get(
    'ADB', 'C:/Users/user/AppData/Local/Android/Sdk/platform-tools/adb.exe')
PACCHETTO = 'com.esotericircle.esoteric_circle'
FUORI = os.environ.get('FUORI', 'docs/collaudo')


def adb(*argomenti, binario=False):
    """Un comando adb, con l'uscita gia' pulita."""
    esito = subprocess.run([ADB, *argomenti], capture_output=True,
                           timeout=180)
    if binario:
        return esito.stdout
    return esito.stdout.decode('utf-8', errors='replace')


def telefono():
    """Il dispositivo collegato, o niente. Si dichiara invece di indovinare."""
    righe = [r for r in adb('devices').split(NL)
             if r.strip().endswith('device')]
    return righe[0].split()[0] if righe else None


def schermo():
    """Larghezza e altezza in pixel, per calcolare i tocchi in proporzione."""
    m = re.search(r'(\d+)x(\d+)', adb('shell', 'wm', 'size'))
    return (int(m.group(1)), int(m.group(2))) if m else (1080, 2400)


def tocca(fx, fy):
    """Un tocco in FRAZIONI dello schermo, non in pixel.

    Le frazioni sopravvivono a un telefono diverso; i pixel no, ed e' il modo
    in cui uno strumento come questo diventa inservibile alla prima prova su
    un altro dispositivo.
    """
    w, h = schermo()
    adb('shell', 'input', 'tap', str(int(w * fx)), str(int(h * fy)))
    time.sleep(1.2)


def scorri(da=0.75, a=0.25):
    w, h = schermo()
    adb('shell', 'input', 'swipe', str(w // 2), str(int(h * da)),
        str(w // 2), str(int(h * a)), '400')
    time.sleep(1.0)


def testi():
    """Tutto il testo che l'albero delle viste dichiara, in ordine.

    **E' l'albero e non un'immagine**, e la differenza conta: da un'immagine si
    legge cosa sembra scritto, da qui si legge cosa il sistema dice che c'e'.
    """
    adb('shell', 'uiautomator', 'dump', '/sdcard/vista.xml')
    grezzo = adb('shell', 'cat', '/sdcard/vista.xml')
    fuori = []
    for m in re.finditer(r'text="([^"]*)"', grezzo):
        t = m.group(1).strip()
        if t:
            fuori.append(t)
    return fuori


def cattura(nome):
    """Una fotografia dello schermo, salvata dove si possa guardare."""
    os.makedirs(FUORI, exist_ok=True)
    dati = adb('exec-out', 'screencap', '-p', binario=True)
    percorso = os.path.join(FUORI, nome + '.png')
    io.open(percorso, 'wb').write(dati)
    return percorso, len(dati)


def apri():
    adb('shell', 'monkey', '-p', PACCHETTO, '-c',
        'android.intent.category.LAUNCHER', '1')
    time.sleep(6)


if __name__ == '__main__':
    dispositivo = telefono()
    if dispositivo is None:
        raise SystemExit('nessun telefono collegato: collegalo e sbloccalo')
    print('telefono: ' + dispositivo + ', schermo ' + str(schermo()))
    if len(sys.argv) > 1 and sys.argv[1] == 'apri':
        apri()
    for riga in testi():
        print('  ' + riga)
