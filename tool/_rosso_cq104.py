# -*- coding: utf-8 -*-
"""Prova del rosso della guardia dell'effetto. Ordine CQ voce 1.04, Regola A."""
import os
import re
import subprocess

M = 'lib/core/sensi/motore_audio.dart'
GUARDIA = 'test/l_effetto_non_aspetta_la_piattaforma_test.dart'
NL = chr(10)
CR = chr(13)

INNESTI = [
    ('l effetto torna ad aspettare la piattaforma',
     "      unawaited(_effetti" + NL + "          .stop()" + NL +
     "          .then((_) => _effetti.play(AssetSource(percorsoAsset)))",
     "      await _effetti.play(AssetSource(percorsoAsset));" + NL +
     "      unawaited(_effetti" + NL + "          .stop()" + NL +
     "          .then((_) => _effetti.play(AssetSource(percorsoAsset)))",
     'nessun play di audioplayers si attende'),
    ('il tono torna ad aspettare la piattaforma',
     "      unawaited(_toni.play(BytesSource(byte)).catchError((Object e) {",
     "      await _toni.play(BytesSource(byte));" + NL +
     "      unawaited(_toni.play(BytesSource(byte)).catchError((Object e) {",
     'nessun play di audioplayers si attende'),
    ('gli effetti tornano a chiedere il fuoco esclusivo',
     "          audioFocus: AndroidAudioFocus.none," + NL +
     "        )," + NL + "        iOS: AudioContextIOS(" + NL +
     "          category: AVAudioSessionCategory.playback," + NL +
     "          options: const {AVAudioSessionOptions.mixWithOthers}," + NL +
     "        )," + NL + "      ));" + NL + "    } catch (e) {" + NL +
     "      // Il contesto non si e' potuto impostare",
     "          audioFocus: AndroidAudioFocus.gain," + NL +
     "        )," + NL + "        iOS: AudioContextIOS(" + NL +
     "          category: AVAudioSessionCategory.playback," + NL +
     "          options: const {AVAudioSessionOptions.mixWithOthers}," + NL +
     "        )," + NL + "      ));" + NL + "    } catch (e) {" + NL +
     "      // Il contesto non si e' potuto impostare",
     'il lettore degli effetti dichiara il suo contesto audio'),
    ('il contesto non si prepara piu prima di suonare',
     "      await _preparaGliEffetti();",
     "      // niente contesto",
     'il lettore degli effetti dichiara il suo contesto audio'),
]


def leggi(p):
    return open(p, 'rb').read().decode('utf-8')


def scrivi(p, s):
    open(p, 'wb').write(s.encode('utf-8'))


def main():
    originale = leggi(M)
    crlf = CR in originale
    esiti = []
    try:
        for nome, vecchio, nuovo, attesa in INNESTI:
            s = originale.replace(CR + NL, NL) if crlf else originale
            if s.count(vecchio) != 1:
                raise SystemExit('INNESTO MANCATO "%s": %d occorrenze'
                                 % (nome, s.count(vecchio)))
            s = s.replace(vecchio, nuovo)
            scrivi(M, s.replace(NL, CR + NL) if crlf else s)
            if nuovo not in leggi(M).replace(CR + NL, NL):
                raise SystemExit('INNESTO NON VERIFICATO: %s' % nome)
            print('INNESTO VERIFICATO col grep: %s' % nome)
            prova = subprocess.run(
                ['flutter', 'test', GUARDIA], capture_output=True, text=True,
                encoding='utf-8', errors='replace',
                env=dict(os.environ, TZ='Europe/Rome'), shell=True)
            cadute = sorted(set(re.findall(
                r'^\s+.*_test\.dart: (.+)$',
                prova.stdout.split('Failing tests:')[-1], re.M)))
            esiti.append((nome, attesa,
                          'ROSSA' if attesa in cadute else 'VERDE', cadute))
    finally:
        scrivi(M, originale)

    fuori = ['LA PROVA DEL ROSSO DELLA GUARDIA DELL EFFETTO',
             'Ordine CQ voce 1.04, Regola A.', '=' * 72]
    for nome, attesa, esito, cadute in esiti:
        fuori.append('%-8s  %-50s' % (esito, nome))
        fuori.append('          attesa: %s' % attesa)
        for c in cadute:
            fuori.append('          caduta: %s' % c)
    quante = sum(1 for e in esiti if e[2] == 'ROSSA')
    fuori.append('=' * 72)
    fuori.append('INNESTI CHE HANNO FATTO ROSSA LA PRETESA ATTESA: %d su %d'
                 % (quante, len(esiti)))
    testo = NL.join(fuori)
    with open('docs/ordini/CQ_prova_del_rosso.txt', 'a',
              encoding='utf-8') as f:
        f.write(testo + NL + NL)
    print(testo.encode('ascii', 'replace').decode('ascii'))


if __name__ == '__main__':
    main()
