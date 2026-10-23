# -*- coding: utf-8 -*-
"""LA FRENATA DI MEDORA, DENTRO IL FILMATO. 14 ottobre 2026, dopo la 2310.

Il fondatore: "Medora deve fermarsi poco prima della fine del video, quando
ha la mano sul petto e non quando la allontana. Cerca di rallentare l'ultimo
secondo in modo che non si fermi di botto", e sulla 2310 "come se avesse un
movimento piu' naturale di fermata".

Ricostruisce brand_assets/tavolo/medora_mazzo_in_vortice_v2.mp4 dall'originale
del fondatore (commit 48978334, v1): i fotogrammi 0-141 identici, poi 48
fotogrammi in cui il contenuto va dal 142 al 166 (la mano sul petto) con la
velocita' che scende in linea retta da piena a zero, in due secondi. I
fotogrammi fra due originali vengono da ffmpeg minterpolate a 240 al secondo,
il piu' vicino a ogni posizione. Audio originale tagliato alla nuova durata,
mezzo secondo di dissolvenza.

Uso, dalla radice del repo (servono ffmpeg e git):
  python tool/la_frenata_nel_filmato.py CARTELLA_DI_LAVORO
"""
import os
import shutil
import subprocess
import sys

PRIMO_RALLENTATO = 142
ULTIMO = 166
FOTOGRAMMI_DELLA_FRENATA = 48
SECONDI_DELLA_FRENATA = 2.0
USCITA = 'brand_assets/tavolo/medora_mazzo_in_vortice_v2.mp4'


def main(lavoro):
    orig = os.path.join(lavoro, 'orig')
    interp = os.path.join(lavoro, 'interp')
    out = os.path.join(lavoro, 'out')
    for d in (orig, interp, out):
        shutil.rmtree(d, ignore_errors=True)
        os.makedirs(d)
    sorgente = os.path.join(lavoro, 'v1.mp4')
    with open(sorgente, 'wb') as f:
        f.write(subprocess.run(
            ['git', 'show',
             '48978334:brand_assets/tavolo/medora_mazzo_in_vortice_v1.mp4'],
            capture_output=True, check=True).stdout)
    subprocess.run(['ffmpeg', '-v', 'error', '-i', sorgente, '-fps_mode',
                    'passthrough', os.path.join(orig, '%03d.png')], check=True)
    subprocess.run(['ffmpeg', '-v', 'error', '-i', sorgente, '-vf',
                    "select='between(n\\,140\\,167)',setpts=N/24/TB,"
                    'minterpolate=fps=240:mi_mode=mci:mc_mode=aobmc:'
                    'me_mode=bidir:vsbmc=1',
                    '-fps_mode', 'passthrough',
                    os.path.join(interp, '%04d.png')], check=True)
    n = 0
    for i in range(PRIMO_RALLENTATO):
        shutil.copy(os.path.join(orig, f'{i + 1:03d}.png'),
                    os.path.join(out, f'{n:03d}.png'))
        n += 1
    tratto = ULTIMO - PRIMO_RALLENTATO
    for k in range(1, FOTOGRAMMI_DELLA_FRENATA + 1):
        t = k / 24 / SECONDI_DELLA_FRENATA
        posizione = PRIMO_RALLENTATO + tratto * (1 - (1 - t) ** 2)
        j = round((posizione - 140) * 10) + 1
        shutil.copy(os.path.join(interp, f'{j:04d}.png'),
                    os.path.join(out, f'{n:03d}.png'))
        n += 1
    durata = n / 24
    subprocess.run(['ffmpeg', '-v', 'error', '-y', '-framerate', '24', '-i',
                    os.path.join(out, '%03d.png'), '-i', sorgente,
                    '-map', '0:v', '-map', '1:a', '-c:v', 'libx264',
                    '-profile:v', 'high', '-pix_fmt', 'yuv420p', '-crf', '17',
                    '-preset', 'slow', '-r', '24', '-af',
                    f'atrim=0:{durata:.4f},afade=t=out:st={durata - 0.5:.4f}:d=0.5',
                    '-c:a', 'aac', '-b:a', '140k', '-ar', '48000', '-ac', '2',
                    '-shortest', '-movflags', '+faststart', USCITA], check=True)
    print(f'{USCITA}: {n} fotogrammi, {durata:.3f} s')


if __name__ == '__main__':
    main(sys.argv[1])
