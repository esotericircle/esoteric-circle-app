# -*- coding: utf-8 -*-
"""LA TELEVISIONE PER IL BANCO DELLA TRASCRIZIONE. Ordine ES voce 22.

L'istruzione nuova della trascrizione dice a chi trascrive che la persona fa
di solito una domanda sulla sua vita: bisogna sapere che non gli fa
trascrivere la televisione, che l'ordine EM voce 04 ha insegnato a lasciare
fuori. Questo script taglia dall'audio della televisione finta dell'ordine
EM (`tv_finta.wav`, 48 kHz) sei pezzi di quattro secondi, li porta a 16 kHz e
al livello di una televisione sentita dal telefono (-30 dB), e li scrive come
`tv_NN.wav` nella cartella del banco.

Uso:
  python tool/la_televisione_da_banco.py <tv_finta.wav> <cartella del banco>
"""
import math
import pathlib
import struct
import sys
import wave


def main():
    sorgente = pathlib.Path(sys.argv[1])
    cartella = pathlib.Path(sys.argv[2])
    with wave.open(str(sorgente), 'rb') as w:
        frequenza = w.getframerate()
        n = w.getnframes()
        campioni = [x / 32768.0 for x in
                    struct.unpack(f'<{n * w.getnchannels()}h', w.readframes(n))]
    passo = frequenza // 16000
    for i, inizio in enumerate(range(0, 36, 6), start=1):
        pezzo = campioni[inizio * frequenza:(inizio + 4) * frequenza]
        # Da 48 a 16 kHz: la media di tre campioni, che basta a non far
        # ripiegare le frequenze alte in un pezzo di parlato.
        ridotto = [sum(pezzo[j:j + passo]) / passo
                   for j in range(0, len(pezzo) - passo, passo)]
        rms = math.sqrt(sum(x * x for x in ridotto) / len(ridotto)) or 1e-9
        scala = 10 ** (-30 / 20) / rms
        uscita = cartella / f'tv_{i:02d}.wav'
        with wave.open(str(uscita), 'wb') as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(16000)
            w.writeframes(struct.pack(
                f'<{len(ridotto)}h',
                *[max(-32768, min(32767, int(x * scala * 32767)))
                  for x in ridotto]))
    print(f'sei pezzi di televisione in {cartella}')


if __name__ == '__main__':
    main()
