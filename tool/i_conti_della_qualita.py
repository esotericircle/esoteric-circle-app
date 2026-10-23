# -*- coding: utf-8 -*-
"""I CONTI DEI GIRI DEL BANCO DELLA QUALITA'. Ordine EX, 2 ottobre 2026.

Legge docs/collaudo/EX/qualita/<giro>.jsonl (tool/il_banco_della_qualita.dart)
e stampa, per ogni giro: chiamate per risposta e per tocco del "Vai più a
fondo", costo medio di una risposta e di un tocco coi prezzi Vertex di
europe-west1 (gli stessi di tool/i_conti_del_costo_ew.py: Flash 0,30 / 2,50,
Flash-Lite 0,10 / 0,40 dollari al milione; la cache al 10% del prezzo
d'ingresso; il ragionamento si paga come uscita), la quota d'ingresso presa
dalla cache, le chiamate per le domande sul cielo di oggi e di altre date, e
le reti che hanno chiesto di nuovo la risposta.

Il costo "a freddo" non conta la cache: e' il caso di un utente solo, che
non trova mai il prefisso gia' caldo.

  python tool/i_conti_della_qualita.py prima2 fine2
"""
import json
import pathlib
import sys

RADICE = pathlib.Path(__file__).resolve().parent.parent
CARTELLA = RADICE / 'docs/collaudo/EX/qualita'
PREZZI = {
    'gemini-2.5-flash': (0.30, 2.50),
    'gemini-2.5-flash-lite': (0.10, 0.40),
}


def costo(x, con_cache=True):
    pi, pu = PREZZI[x['modello']]
    cache = x.get('cache') or 0 if con_cache else 0
    testo = x['ingresso'] - cache
    uscita = x['uscita'] + (x.get('ragionamento') or 0)
    return (testo * pi + cache * pi * 0.10 + uscita * pu) / 1e6


def media(v):
    return sum(v) / len(v) if v else 0.0


def conti(giro):
    righe = [json.loads(r) for r in
             (CARTELLA / f'{giro}.jsonl').read_text(encoding='utf-8').splitlines()
             if r.strip()]
    chat = [r for r in righe if not r['nelLive']]
    live = [r for r in righe if r['nelLive']]
    risp = [x for r in chat for x in r['chiamateRisposta']]
    reti = {}
    for r in righe:
        for k, v in (r.get('reti') or {}).items():
            reti[k] = reti.get(k, 0) + v
    return {
        'giro': giro,
        'casi': len(righe),
        'chiamate_risposta': media([len(r['chiamateRisposta']) for r in chat]),
        'chiamate_tocco': media([len(r['chiamateSeguito']) for r in chat]),
        'costo_risposta': media([sum(costo(x) for x in r['chiamateRisposta'])
                                 for r in chat]),
        'costo_tocco': media([sum(costo(x) for x in r['chiamateSeguito'])
                              for r in chat]),
        'costo_risposta_freddo': media([
            sum(costo(x, False) for x in r['chiamateRisposta']) for r in chat]),
        'costo_tocco_freddo': media([
            sum(costo(x, False) for x in r['chiamateSeguito']) for r in chat]),
        'ingresso_medio': media([x['ingresso'] for x in risp]),
        'dalla_cache': (sum(x.get('cache') or 0 for x in risp)
                        / max(1, sum(x['ingresso'] for x in risp))),
        'cielo_oggi': media([len(r['chiamateRisposta']) for r in righe
                             if r['tipo'] == 'cielo_oggi']),
        'cielo_data': media([len(r['chiamateRisposta']) for r in righe
                             if r['tipo'] == 'cielo_data']),
        'live': media([len(r['chiamateRisposta']) for r in live]),
        'costo_live': media([sum(costo(x) for x in r['chiamateRisposta'])
                             for r in live]),
        'reti': reti,
    }


def main():
    for giro in sys.argv[1:]:
        c = conti(giro)
        print(f"{c['giro']} ({c['casi']} casi)")
        print(f"  chat: {c['chiamate_risposta']:.2f} chiamate per risposta, "
              f"{c['chiamate_tocco']:.2f} per tocco; costo risposta "
              f"{c['costo_risposta']:.5f} $ (a freddo "
              f"{c['costo_risposta_freddo']:.5f}), tocco {c['costo_tocco']:.5f}"
              f" $ (a freddo {c['costo_tocco_freddo']:.5f})")
        print(f"  ingresso medio {c['ingresso_medio']:.0f} token, dalla cache "
              f"{c['dalla_cache']:.0%}")
        print(f"  cielo di oggi {c['cielo_oggi']:.2f} chiamate, altre date "
              f"{c['cielo_data']:.2f}; LIVE {c['live']:.2f} chiamate, "
              f"{c['costo_live']:.5f} $")
        print(f"  reti: {c['reti']}")


if __name__ == '__main__':
    main()
