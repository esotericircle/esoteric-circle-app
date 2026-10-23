# Analisi OFFLINE dei sette pezzi "volta" v3 (file locali _pronti_v3), non e' una prova a video.
# Per ogni animale: frame del pezzo, scarto massimo dalla posa (primo fotogramma) = quanto si gira,
# scarto fra fotogrammi consecutivi all'inizio e alla fine, e il massimo scarto consecutivo (scatto alle giunture).
import subprocess, os, sys, glob, tempfile
import numpy as np
from PIL import Image
R = r'D:\Clienti Roogly\Rituali Cartomanzia\App\Viaggio Sciamano Animali\_pronti_v3'
out = []
for nome in ['lince','volpe','orso','lupo','cavallo','cervo','tartaruga']:
    f = os.path.join(R, nome + '_volta_v3.mp4')
    d = tempfile.mkdtemp()
    subprocess.run(['ffmpeg','-v','error','-i',f,'-vf','scale=216:384','-fps_mode','passthrough',os.path.join(d,'f_%04d.png')],check=True)
    fs = sorted(glob.glob(os.path.join(d,'f_*.png')))
    A = [np.asarray(Image.open(p).convert('L'),dtype=float) for p in fs]
    n = len(A)
    da_posa = [np.abs(a-A[0]).mean() for a in A]
    cons = [np.abs(A[i]-A[i-1]).mean() for i in range(1,n)]
    imax = int(np.argmax(da_posa))
    # frame finale vs primo
    fine = np.abs(A[-1]-A[0]).mean()
    # scatto: rapporto fra il massimo scarto consecutivo e la mediana
    med = float(np.median(cons)); mx = max(cons); imx = cons.index(mx)+1
    # prime 8 e ultime 8 differenze consecutive
    print(f"{nome}|frame {n}|{n/24:.2f} s|scarto massimo dalla posa {max(da_posa):.1f} al frame {imax}|ultimo vs primo {fine:.2f}|consecutivi: mediana {med:.2f} massimo {mx:.2f} al frame {imx}|primi8 {[round(c,1) for c in cons[:8]]}|ultimi8 {[round(c,1) for c in cons[-8:]]}")
    for p in fs: os.remove(p)
    os.rmdir(d)
