# GA.08: in quale istante del filmato dell'Oracolo compaiono i dorsi dipinti
# sull'altare. Si legge la fascia dell'altare (pixel 1505-1715 del fotogramma
# 1080x1920, cioe' 1003-1143 nel file 720x1280), in grigio, fotogramma per
# fotogramma, e si misura lo scarto medio dal primo fotogramma (altare
# sgombro) e dall'ultimo (i tre dorsi).
import subprocess, sys
FILM = sys.argv[1]
W, H = 144, 28
cmd = ['ffmpeg', '-v', 'error', '-i', FILM, '-vf',
       'crop=720:140:0:1003,scale=%d:%d,format=gray' % (W, H),
       '-f', 'rawvideo', '-']
dati = subprocess.run(cmd, capture_output=True).stdout
n = W * H
quadri = [dati[i:i + n] for i in range(0, len(dati), n) if len(dati[i:i + n]) == n]
primo, ultimo = quadri[0], quadri[-1]
def scarto(a, b):
    return sum(abs(x - y) for x, y in zip(a, b)) / n
# Anche la sola zona delle carte (x 105-615 su 720 -> 21-123 su 144)
def scarto_carte(a, b):
    s = c = 0
    for r in range(H):
        for x in range(21, 123):
            s += abs(a[r * W + x] - b[r * W + x]); c += 1
    return s / c
print('fotogrammi', len(quadri), 'a 24 al secondo')
for i, q in enumerate(quadri):
    print('%3d  %5.2f s  dal primo %6.2f  carte dal primo %6.2f  dall\'ultimo %6.2f'
          % (i, i / 24, scarto(q, primo), scarto_carte(q, primo), scarto_carte(q, ultimo)))
