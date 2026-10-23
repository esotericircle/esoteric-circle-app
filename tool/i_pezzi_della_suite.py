# -*- coding: utf-8 -*-
"""I PEZZI DELLA SUITE: quali file di prova fa girare ogni macchina.

**Perche' esiste.** Il 26 settembre 2026 il fondatore ha chiesto: *"Ma non
c'e' modo di accelerare Suite, sbarramenti, ecc?"*, e poi *"Ma se
l'accelerazione e' sempre disponibile, usala sempre"*. Lo sbarramento di
GitHub girava su una macchina sola in circa 33 minuti. Adesso la suite si
divide su piu' macchine che lavorano insieme.

**Si divide per FILE, non per prova.** La divisione di Flutter
(`--total-shards`) spezza le prove dentro ogni file: ogni macchina
compilerebbe comunque tutti i file, e la compilazione e' la parte piu' lunga.
Qui ogni file va intero su una macchina sola: compila solo i suoi, e le prove
di uno stesso file restano insieme, nel loro ordine.

**I pezzi hanno peso simile.** Ogni file pesa i secondi misurati in
`tool/pesi_delle_prove.json` (un file nuovo, non ancora misurato, pesa la
mediana), e si assegna al pezzo piu' leggero cominciando dal piu' pesante. Il
risultato dipende solo dai nomi dei file e dai pesi: tutte le macchine
calcolano la stessa divisione.

Uso:
  python tool/i_pezzi_della_suite.py <quanti pezzi> <indice>   stampa i file del pezzo
  python tool/i_pezzi_della_suite.py --pesi-da <registro>     rifa' i pesi da un registro
"""
import io
import json
import os
import re
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PESI = os.path.join(RADICE, 'tool', 'pesi_delle_prove.json')


def tutti_i_file():
    """Tutti i file `*_test.dart` sotto test/, come li trova `flutter test`."""
    trovati = []
    for cartella, _, nomi in os.walk(os.path.join(RADICE, 'test')):
        for nome in nomi:
            if nome.endswith('_test.dart'):
                percorso = os.path.relpath(os.path.join(cartella, nome), RADICE)
                trovati.append(percorso.replace(os.sep, '/'))
    return sorted(trovati)


def pesi():
    if not os.path.exists(PESI):
        return {}
    return json.load(io.open(PESI, encoding='utf-8'))


def pezzi(quanti):
    """La divisione intera: una lista di `quanti` liste di file."""
    file = tutti_i_file()
    misurati = pesi()
    noti = sorted(v for k, v in misurati.items() if 'test/' + k in file)
    mediana = noti[len(noti) // 2] if noti else 1
    peso = {f: misurati.get(f[len('test/'):], mediana) for f in file}
    ordine = sorted(file, key=lambda f: (-peso[f], f))
    carichi = [0] * quanti
    risultato = [[] for _ in range(quanti)]
    for f in ordine:
        i = min(range(quanti), key=lambda k: (carichi[k], k))
        risultato[i].append(f)
        carichi[i] += peso[f]
    return [sorted(p) for p in risultato], carichi


def pesi_da_registro(percorso):
    """Il peso di ogni file: dalla prima all'ultima riga del rapporto esteso
    di `flutter test` che lo nomina, caricamento compreso, almeno 2 secondi."""
    prima, ultima = {}, {}
    for riga in io.open(percorso, encoding='utf-8', errors='replace'):
        m = re.search(r'(\d+):(\d\d) \+\d+[^:]*: .*?/test/([^:]+?_test\.dart)', riga)
        if not m:
            continue
        secondi = int(m.group(1)) * 60 + int(m.group(2))
        nome = m.group(3)
        prima.setdefault(nome, secondi)
        ultima[nome] = secondi
    return {n: max(2, ultima[n] - prima[n]) for n in sorted(prima)}


def main():
    if len(sys.argv) == 3 and sys.argv[1] == '--pesi-da':
        misurati = pesi_da_registro(sys.argv[2])
        io.open(PESI, 'w', encoding='utf-8', newline='\n').write(
            json.dumps(misurati, indent=1, ensure_ascii=False, sort_keys=True) + '\n')
        print('pesi scritti: %d file' % len(misurati))
        return
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    quanti, indice = int(sys.argv[1]), int(sys.argv[2])
    if not 0 <= indice < quanti:
        raise SystemExit('indice %d fuori dai pezzi 0..%d' % (indice, quanti - 1))
    divisione, _ = pezzi(quanti)
    print(' '.join(divisione[indice]))


if __name__ == '__main__':
    main()
