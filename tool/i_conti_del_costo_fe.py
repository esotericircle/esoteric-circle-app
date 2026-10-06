# -*- coding: utf-8 -*-
"""I CONTI DEL COSTO A FREDDO. Ordine FE voce 20, 6 ottobre 2026.

Il costo per consulto di `tool/il_costo_del_filo.dart` usa la cache implicita
che Vertex concede in quel giro, e quella cambia da un giro all'altro: il 6
ottobre il prefisso letto dalla cache e' stato di circa 5.100 token nei giri
del mattino e di circa 4.080 in quello del pomeriggio, e il "prima" dello
stesso codice e' salito da 0,0024 a 0,0031 dollari senza che niente
cambiasse. Qui il costo si rifa' a freddo, a prezzo pieno senza cache, dagli
stessi file: e' il caso peggiore, quello del tetto del trenta per cento.

Per ogni consulto: il secondo e il terzo turno (il primo e' uguale nei due
stati). PRIMA = due turni senza filo (l'ingresso del secondo turno senza filo
vale per tutti e due, perche' lo strumento non stampa il terzo); DOPO = il
secondo turno col filo, il terzo turno col filo, la rete e le correzioni che
il file dichiara.

    python tool/i_conti_del_costo_fe.py docs/collaudo/FE/costo/il_costo_del_filo_<giro>.txt [...]
"""
import re
import statistics
import sys

P_IN, P_OUT = 0.30, 2.50  # gemini-2.5-flash, dollari per milione

RIGA = re.compile(
    r'consulto (\d+) \(([^)]*)\): ingresso senza filo (\d+) \(cache \d+\), '
    r'col filo (\d+) \(cache \d+\), turno dopo (\d+) di cui \d+ dalla cache; '
    r'costo prima [\d.]+ dollari, dopo [\d.]+(?:, di cui rete e correzioni '
    r'([\d.]+))?.*?uscita \(di cui ragionamento\) senza filo (\d+) \(\d+\) e '
    r'(\d+) \(\d+\), col filo (\d+) \(\d+\) e (\d+) \(\d+\)')


def conta(percorso):
    prima, dopo, ingressi_prima, ingressi_dopo = [], [], [], []
    for r in open(percorso, encoding='utf-8'):
        m = RIGA.search(r)
        if not m:
            continue
        senza, con, terzo = int(m[3]), int(m[4]), int(m[5])
        rete = float(m[6] or 0)
        us_a, us_b, uc_a, uc_b = (int(m[i]) for i in (7, 8, 9, 10))
        prima.append((2 * senza * P_IN + (us_a + us_b) * P_OUT) / 1e6)
        dopo.append(((con + terzo) * P_IN + (uc_a + uc_b) * P_OUT) / 1e6 + rete)
        ingressi_prima.append(senza)
        ingressi_dopo.append(con)
    return prima, dopo, ingressi_prima, ingressi_dopo


def main():
    for p in sys.argv[1:]:
        prima, dopo, ip, idp = conta(p)
        if not prima:
            print(f'{p}: nessun consulto letto')
            continue
        mp, md = statistics.median(prima), statistics.median(dopo)
        print(f'{p}: {len(prima)} consulti a freddo; mediana prima '
              f'{mp:.5f} dollari, dopo {md:.5f} ({(md / mp - 1) * 100:+.1f} per '
              f'cento); somma prima {sum(prima):.4f}, dopo {sum(dopo):.4f} '
              f'({(sum(dopo) / sum(prima) - 1) * 100:+.1f} per cento); ingresso '
              f'mediano del secondo turno senza filo {statistics.median(ip):.0f}, '
              f'col filo {statistics.median(idp):.0f}')


if __name__ == '__main__':
    main()
