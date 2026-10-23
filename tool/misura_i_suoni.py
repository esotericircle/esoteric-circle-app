# -*- coding: utf-8 -*-
"""MISURA I SUONI DEL CERCHIO, e riscrive il registro con cio' che ha letto.

Ordine CO voce 04, 3 settembre 2026. **Questo strumento mancava.** Il registro
`docs/sonorita.json` dichiara da CN il proprio metodo di misura, e nessuno
strumento in repo lo eseguiva: le misure erano state prese a mano, una volta,
e nessuno poteva rifarle senza rifare a mano anche i comandi. Un registro che
dichiara un metodo che nessuno puo' ripetere e' una promessa, non una misura.

**La grandezza e' la sonorita' momentanea massima, finestra di 400 ms.** Non la
sonorita' integrata: quella scarta i blocchi silenziosi sotto una soglia, e su
un effetto di mezzo secondo scarta quasi tutto, tornando indietro un numero che
non dice niente. E' la stessa scelta gia' scritta nel registro.

Uso:
    python tool/misura_i_suoni.py                 misura tutto e stampa
    python tool/misura_i_suoni.py --scrivi        e riscrive docs/sonorita.json
"""
import hashlib
import io
import json
import os
import re
import subprocess
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
EFFETTI = os.path.join(RADICE, 'assets', 'audio')
MUSICHE = os.path.join(RADICE, 'assets', 'music')
REGISTRO = os.path.join(RADICE, 'docs', 'sonorita.json')


def _ffmpeg(argomenti):
    fatto = subprocess.run(argomenti, stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT)
    return fatto.stdout.decode('utf-8', 'replace')


def misura(percorso):
    """Sonorita' momentanea massima, picco vero, durata e peso di un file."""
    # **Le M si leggono dai metadati, non dal registro a schermo.** Le righe
    # per fotogramma di `framelog=verbose` non escono in tutte le versioni di
    # ffmpeg, e una misura che dipende da quale versione sta sulla macchina
    # non e' una misura. I metadati ci sono sempre.
    uscita = _ffmpeg(['ffmpeg', '-nostats', '-hide_banner', '-i', percorso,
                      '-af',
                      'ebur128=peak=true:metadata=1,'
                      'ametadata=print:key=lavfi.r128.M:file=-',
                      '-f', 'null', '-'])
    momentanee = [float(x) for x in
                  re.findall(r'lavfi\.r128\.M=(-?\d+\.\d+)', uscita)
                  if float(x) > -70]
    picchi = [float(x) for x in re.findall(r'Peak:\s*(-?\d+\.\d+)', uscita)]
    durata = _ffmpeg(['ffprobe', '-v', 'error', '-show_entries',
                      'format=duration', '-of', 'csv=p=0', percorso]).strip()
    with open(percorso, 'rb') as f:
        byte = f.read()
    return {
        'sha1': hashlib.sha1(byte).hexdigest(),
        'peso': len(byte),
        'durata': round(float(durata), 3),
        # **Sotto la finestra**: un suono piu' corto di 400 ms non ha
        # nemmeno una finestra momentanea intera, e per lui vale il picco.
        'sonorita': round(max(momentanee), 2) if momentanee else None,
        'picco': round(max(picchi), 1) if picchi else None,
        'sottoLaFinestra': not momentanee,
    }


def main():
    scrivi = '--scrivi' in sys.argv
    registro = json.load(io.open(REGISTRO, encoding='utf-8'))
    for chiave, cartella in (('effetti', EFFETTI), ('musiche', MUSICHE)):
        if chiave not in registro:
            continue
        for nome in sorted(registro[chiave]):
            percorso = os.path.join(cartella, nome)
            if not os.path.exists(percorso):
                print('MANCA %s' % nome)
                continue
            nuova = misura(percorso)
            vecchia = registro[chiave][nome]
            cambiato = any(nuova[k] != vecchia.get(k)
                           for k in ('sha1', 'sonorita', 'picco'))
            print('%-22s son %-8s picco %-6s %s' % (
                nome, nuova['sonorita'], nuova['picco'],
                'CAMBIATO' if cambiato else ''))
            registro[chiave][nome] = nuova
    if scrivi:
        io.open(REGISTRO, 'w', encoding='utf-8', newline='\n').write(
            json.dumps(registro, ensure_ascii=False, indent=1) + '\n')
        print('registro riscritto')


if __name__ == '__main__':
    main()
