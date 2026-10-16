# -*- coding: utf-8 -*-
"""I RAPPORTI CONSEGNATI, ordine FB voce 03.

Un rapporto consegnato riceve solo righe in coda (`**Aggiunta del ...`), mai
correzioni nel corpo. Questo strumento scrive in
`docs/ordini/RAPPORTI_CONSEGNATI.txt` l'impronta del CORPO di un rapporto:
il testo fino alla prima riga che comincia con `**Aggiunta del `, con gli a
capo ridotti a `\\n` e senza spazi in fondo, in SHA-256. La guardia
`i_rapporti_consegnati_non_si_correggono_test.dart` ricalcola l'impronta e
cade se il corpo e' cambiato.

Si usa UNA volta per rapporto, alla consegna:

    python tool/i_rapporti_consegnati.py RAPPORTO_ORDINE_FB.md

Senza argomenti registra i rapporti che nel registro mancano, e non tocca
mai un'impronta gia' scritta: un'impronta si cambia solo a mano, e chi lo fa
deve dire perche' nel rapporto del suo ordine.
"""
import hashlib
import io
import os
import sys

CARTELLA = os.path.join('docs', 'ordini')
REGISTRO = os.path.join(CARTELLA, 'RAPPORTI_CONSEGNATI.txt')
TESTA = (
    "# I RAPPORTI CONSEGNATI, ordine FB voce 03 (4 ottobre 2026).\n"
    "# Un rapporto consegnato riceve solo righe in coda, mai correzioni nel\n"
    "# corpo. Ogni riga: il file e l'impronta SHA-256 del suo corpo (il testo\n"
    "# fino alla prima riga '**Aggiunta del ', a capo ridotti, senza spazi in\n"
    "# fondo). Si scrive con tool/i_rapporti_consegnati.py alla consegna.\n"
)


def corpo(testo):
    righe = testo.replace('\r\n', '\n').split('\n')
    tenute = []
    for r in righe:
        if r.startswith('**Aggiunta del '):
            break
        tenute.append(r)
    return '\n'.join(tenute).rstrip()


def impronta(nome):
    testo = io.open(os.path.join(CARTELLA, nome), encoding='utf-8',
                    newline='').read()
    return hashlib.sha256(corpo(testo).encode('utf-8')).hexdigest()


def leggi():
    if not os.path.exists(REGISTRO):
        return {}
    voci = {}
    for r in io.open(REGISTRO, encoding='utf-8', newline='').read().split('\n'):
        r = r.strip()
        if not r or r.startswith('#'):
            continue
        nome, sha = r.split()
        voci[nome] = sha
    return voci


def main():
    voci = leggi()
    if len(sys.argv) > 1:
        nuovi = sys.argv[1:]
    else:
        nuovi = sorted(f for f in os.listdir(CARTELLA)
                       if f.startswith('RAPPORTO_ORDINE_') and f.endswith('.md'))
    scritti = 0
    for nome in nuovi:
        if nome in voci:
            print('gia\' registrato, non lo tocco:', nome)
            continue
        voci[nome] = impronta(nome)
        scritti += 1
    with io.open(REGISTRO, 'w', encoding='utf-8', newline='') as f:
        f.write(TESTA)
        for nome in sorted(voci):
            f.write('%s %s\n' % (nome, voci[nome]))
    print('registrati ora', scritti, 'in tutto', len(voci))


if __name__ == '__main__':
    main()
