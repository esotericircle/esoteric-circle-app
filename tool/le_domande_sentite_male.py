# -*- coding: utf-8 -*-
"""LE VENTI DOMANDE SENTITE MALE, PER IL BANCO DELLA TRASCRIZIONE. Ordine ES
voce 22, 30 settembre 2026.

Sul Realme, nel collaudo del LIVE di quel giorno, due domande su venti sono
arrivate a chi trascrive a pezzi: di *"Devo scrivergli io o aspettare che si
faccia vivo lui?"* l'orecchio ha sentito un terzo di secondo, poi un secondo
di quasi silenzio (-78 dB), poi il resto; *"Perché non ho più desiderio con
la persona che ho accanto?"* e' stata detta mentre il Maestro parlava ancora.
Su tutte e due la prima stesura dell'istruzione ha scritto una domanda che
nessuno aveva detto. Le voci "da stanza" del banco (`tool/le_domande_dette.py`)
sono intere, e il difetto li' non si vedeva.

Dalle `stanza_NN.wav` di <cartella> scrive:
- `buco_NN.wav`: il primo terzo di secondo, poi un secondo di solo fruscio al
  posto della voce, poi il resto;
- `coda_NN.wav`: la sola seconda meta' della domanda, come quando il
  microfono si apre tardi.

Uso:
  python tool/le_domande_sentite_male.py <cartella>
"""
import pathlib
import random
import struct
import sys
import wave


def leggi(percorso):
    with wave.open(str(percorso), 'rb') as w:
        n = w.getnframes()
        return list(struct.unpack(f'<{n}h', w.readframes(n))), w.getframerate()


def scrivi(percorso, campioni, frequenza):
    with wave.open(str(percorso), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(frequenza)
        w.writeframes(struct.pack(f'<{len(campioni)}h', *campioni))


def inizio_della_voce(campioni, frequenza):
    """Il primo campione di un decimo di secondo sopra il fruscio."""
    passo = frequenza // 10
    for i in range(0, len(campioni) - passo, passo // 2):
        pezzo = campioni[i:i + passo]
        rms = (sum(x * x for x in pezzo) / len(pezzo)) ** 0.5
        if rms > 600:
            return i
    return 0


def main():
    cartella = pathlib.Path(sys.argv[1])
    fatti = 0
    for stanza in sorted(cartella.glob('stanza_*.wav')):
        numero = stanza.stem.split('_')[1]
        campioni, frequenza = leggi(stanza)
        rnd = random.Random(int(numero))
        voce = inizio_della_voce(campioni, frequenza)
        a = voce + int(0.33 * frequenza)
        b = min(len(campioni), a + frequenza)
        buco = list(campioni)
        for i in range(a, b):
            buco[i] = int(rnd.gauss(0, 4))
        scrivi(cartella / f'buco_{numero}.wav', buco, frequenza)
        meta = voce + (len(campioni) - voce) // 2
        scrivi(cartella / f'coda_{numero}.wav', campioni[meta:], frequenza)
        fatti += 1
    print(f'{fatti} domande col buco e {fatti} code in {cartella}')


if __name__ == '__main__':
    main()
