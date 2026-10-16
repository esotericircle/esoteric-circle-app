# -*- coding: utf-8 -*-
"""LE VENTI DOMANDE DETTE, PER IL BANCO DELLA TRASCRIZIONE. Ordine ES voce 22.

Scrive in <cartella> le venti domande del collaudo del LIVE (ordine ET voce
04, `docs/collaudo/ET/trascrizione.txt`) dette da Elsa, la voce italiana di
Windows, come nel collaudo sul Realme: `pulita_NN.wav` com'esce dalla voce, e
`stanza_NN.wav` come la sente il telefono dall'altra parte della scrivania,
cioe' piu' bassa (circa -26 dB, il livello sentito sul Realme), con l'eco di
una stanza e un fruscio a 15 dB sotto la voce. La stanza non e' quella vera:
il banco serve a confrontare due istruzioni sugli stessi audio, e la prova
vera resta il Realme.

Uso:
  python tool/le_domande_dette.py <cartella>
"""
import math
import pathlib
import random
import struct
import subprocess
import sys
import wave

DOMANDE = [
    'Lui mi ama davvero?',
    'Ma mi ama ancora, dopo tutto quello che è successo?',
    'Il mio ex tornerà da me?',
    'Devo scrivergli io o aspettare che si faccia vivo lui?',
    'Il mio compagno mi tradisce?',
    'Perché non ho più desiderio con la persona che ho accanto?',
    "Troverò l'amore quest'anno?",
    'Quando incontrerò la persona giusta?',
    'Sono innamorata di due persone: chi devo scegliere?',
    'Perché attiro sempre persone che mi fanno soffrire?',
    'È giusto che lo sposi?',
    'Mi sento sola anche in coppia: che cosa mi manca?',
    'Mia madre non accetta la persona che amo: come faccio?',
    'Riuscirò ad avere un figlio?',
    'Posso fidarmi di nuovo dopo un tradimento?',
    'Gli piaccio? Mi guarda sempre ma non mi dice niente.',
    'Come faccio a dimenticare chi mi ha lasciata?',
    'Sono felice nella mia relazione o mi sto accontentando?',
    'Quando cambierà la mia fortuna?',
    'Questa settimana mi conviene giocare?',
]


def dici(testo, percorso):
    script = (
        'Add-Type -AssemblyName System.Speech; '
        '$s = New-Object System.Speech.Synthesis.SpeechSynthesizer; '
        '$v = $s.GetInstalledVoices() | Where-Object { $_.VoiceInfo.Culture.Name -eq "it-IT" } | Select-Object -First 1; '
        'if ($v) { $s.SelectVoice($v.VoiceInfo.Name) }; '
        '$f = New-Object System.Speech.AudioFormat.SpeechAudioFormatInfo(16000, '
        '[System.Speech.AudioFormat.AudioBitsPerSample]::Sixteen, '
        '[System.Speech.AudioFormat.AudioChannel]::Mono); '
        f'$s.SetOutputToWaveFile("{percorso}", $f); '
        f'$s.Speak([System.IO.File]::ReadAllText("{percorso}.txt", [System.Text.Encoding]::UTF8)); '
        '$s.Dispose()')
    pathlib.Path(f'{percorso}.txt').write_text(testo, encoding='utf-8')
    subprocess.run(['powershell', '-NoProfile', '-Command', script], check=True)
    pathlib.Path(f'{percorso}.txt').unlink()


def leggi(percorso):
    with wave.open(str(percorso), 'rb') as w:
        n = w.getnframes()
        dati = struct.unpack(f'<{n}h', w.readframes(n))
        return [x / 32768.0 for x in dati], w.getframerate()


def scrivi(percorso, campioni, frequenza):
    with wave.open(str(percorso), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(frequenza)
        w.writeframes(struct.pack(
            f'<{len(campioni)}h',
            *[max(-32768, min(32767, int(x * 32767))) for x in campioni]))


def stanza(campioni, frequenza, seme):
    rnd = random.Random(seme)
    # L'eco: tre riflessioni della stanza, a 23, 41 e 67 millesimi.
    eco = list(campioni)
    for ritardo, forza in ((0.023, 0.35), (0.041, 0.22), (0.067, 0.12)):
        d = int(ritardo * frequenza)
        for i in range(d, len(eco)):
            eco[i] += campioni[i - d] * forza
    rms = math.sqrt(sum(x * x for x in eco) / len(eco))
    obiettivo = 10 ** (-26 / 20)
    eco = [x * obiettivo / rms for x in eco]
    fruscio = 10 ** ((-26 - 15) / 20)
    return [x + rnd.gauss(0, fruscio) for x in eco]


def main():
    cartella = pathlib.Path(sys.argv[1])
    cartella.mkdir(parents=True, exist_ok=True)
    for i, d in enumerate(DOMANDE, start=1):
        pulita = cartella / f'pulita_{i:02d}.wav'
        dici(d, str(pulita.resolve()))
        campioni, frequenza = leggi(pulita)
        scrivi(cartella / f'stanza_{i:02d}.wav', stanza(campioni, frequenza, i),
               frequenza)
    (cartella / 'domande.txt').write_text('\n'.join(DOMANDE) + '\n',
                                          encoding='utf-8')
    print(f'{len(DOMANDE)} domande dette in {cartella}')


if __name__ == '__main__':
    main()
