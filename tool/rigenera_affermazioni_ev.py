# -*- coding: utf-8 -*-
"""Rigenera docs/collaudo/EV/affermazioni.md dalla verifica dell'Architetto.

Ordine EV, voce EV.08, 2 ottobre 2026. Parte da docs/collaudo/EU/affermazioni.md
(ordine EU voce 14, scritto sullo stato del commit 67ca80b7) e:

1. a ogni riga che l'Architetto ha verificato in
   docs/corpus/eu/verifica_affermazioni_architetto.md da' il suo esito:
   fonte dichiarata (con la fonte e dove e' scritta), fatto di calcolo,
   scelta dell'app, oppure il testo nuovo;
2. riporta ogni "file:riga" del campo Dove, e le "righe" delle note, allo
   stato di oggi del worktree, con difflib fra il file al commit 67ca80b7 e
   il file di oggi;
3. riscrive il conteggio.

Uso, dalla radice del repository:
    python tool/rigenera_affermazioni_ev.py
"""
from __future__ import annotations

import difflib
import re
import subprocess
from pathlib import Path

RADICE = Path(__file__).resolve().parent.parent
EU = RADICE / 'docs' / 'collaudo' / 'EU' / 'affermazioni.md'
EV = RADICE / 'docs' / 'collaudo' / 'EV' / 'affermazioni.md'
BASE = '67ca80b7'

ARCH = "verifica dell'Architetto, ordine EV"

FONTI = {
    'O-G-005': ("Tolomeo, Tetrabiblos, libro I, cap. 13 (aspetti fra segni)",
                'lib/core/horoscope/il_livello_del_cielo.dart, commento sopra _aspettoDellaCasa'),
    'O-G-006': ("Florence Campbell, Your Days Are Numbered (1931), giorno personale",
                'lib/core/horoscope/il_numero_e_il_colore.dart, commento della classe'),
    'O-G-007': ("Florence Campbell, Your Days Are Numbered (1931), giorno universale",
                'lib/core/horoscope/il_numero_e_il_colore.dart, commento della classe'),
    'O-A-003': ("William Lilly, Christian Astrology (1647), libro I, le dignita' accidentali; dalla casa al livello e' una regola dell'app",
                'lib/core/horoscope/l_annuale.dart, commento sopra la riga di Saturno'),
    'V-G-003': ("Brihat Parashara Hora Shastra, cap. 11 (la settima casa dell'unione); la quinta come cuore e' la lettura moderna di V-M-008",
                'lib/core/horoscope/la_lettura_vedica.dart, commento sopra _temaDelDominio'),
    'V-A-005': ("Phaladeepika, cap. 26 (Saturno buono solo in 3, 6 e 11); la Sade Sati e' una lettura costruita sul gochara",
                'lib/core/horoscope/l_anno_delle_tradizioni.dart, commento sopra la nota dell\'anno vedico, e la nota V-M-011'),
    'C-G-070': ("Wan Minying, Sanming Tonghui (1578): i rapporti classificati fra i rami",
                'docs/corpus/oroscopo_cinese.md, regola del caso 1.8'),
    'C-A-003': ("gli almanacchi annuali cinesi, il Tong Shu",
                'lib/core/horoscope/l_anno_delle_tradizioni.dart, commento e nota C-M-008'),
    'C-A-004': ("gli almanacchi annuali cinesi, il Tong Shu",
                'lib/core/horoscope/l_anno_delle_tradizioni.dart, commento e nota C-M-008'),
}
for s in ('V-G-089', 'V-G-090', 'V-G-091'):
    FONTI[s] = ("Phaladeepika, cap. 26; Brihat Samhita, cap. 104 (la Luna in quinta non e' fra le posizioni buone del gochara); la quinta come cuore e' la lettura moderna di V-M-008",
                'docs/corpus/oroscopo_vedico.md, nota del caso "La Luna nella quinta"')
for s in ('V-G-095', 'V-G-096', 'V-G-097'):
    FONTI[s] = ("Phaladeepika, cap. 26 (la Luna in undicesima e' fra le posizioni buone); Brihat Parashara Hora Shastra, cap. 26 (lo sguardo sulla settima da se')",
                'docs/corpus/oroscopo_vedico.md, nota del caso "La Luna nell\'undicesima guarda la quinta"')
for n in range(232, 262):
    FONTI['C-G-%03d' % n] = ("Shen Xiaozhan, Ziping Zhenquan (XVIII secolo), i capitoli sui dieci dei e sui sei parenti; Xu Dasheng, Yuanhai Ziping (dinastia Song)",
                             'docs/corpus/oroscopo_cinese.md, regola della serie 3.5')

CALCOLO = (['O-G-003', 'O-G-004'] + ['O-S-%03d' % n for n in (1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13)]
           + ['O-A-%03d' % n for n in (8, 9, 10, 11)] + ['O-M-012', 'V-S-001', 'V-S-002',
           'C-G-009', 'C-G-043', 'C-S-001', 'C-S-002', 'C-A-001'])
NOTA_CALCOLO = {
    'O-G-003': "la soglia dei due gradi e' una scelta dell'app, dichiarata dalla nota O-M-006 nuova",
    'O-G-004': "le case solari sono la pratica moderna per chi non ha l'ora di nascita: lo dichiara la nota O-M-004 nuova",
    'V-S-001': "il difetto della parola \"oggi\" sotto la data di un altro giorno e' corretto dall'ordine EV voce EV.09 (LaSettimanaDelCielo.senzaOggi)",
    'V-S-002': "il difetto della parola \"oggi\" sotto la data di un altro giorno e' corretto dall'ordine EV voce EV.09 (LaSettimanaDelCielo.senzaOggi)",
    'C-S-001': "il difetto della parola \"oggi\" sotto la data di un altro giorno e' corretto dall'ordine EV voce EV.09 (LaSettimanaDelCielo.senzaOggi)",
    'C-S-002': "il difetto della parola \"oggi\" sotto la data di un altro giorno e' corretto dall'ordine EV voce EV.09 (LaSettimanaDelCielo.senzaOggi)",
}
SCELTA = ['O-M-013', 'V-M-008']

# Testi nuovi: (testo, esito, fonte o ragione)
NUOVI = {
    'O-M-001': ("Il titolo e il testo sono scelti fra le letture di Medora per il livello di oggi: favorevole, in equilibrio o in salita.",
                'scelta', "dice come l'app sceglie il testo"),
    'O-M-002': ("Il livello viene dai transiti di oggi sulla tua carta natale, calcolati sul telefono dalle effemeridi: i pianeti che passano sui tuoi pianeti di nascita e nelle tue case.",
                'calcolo', 'i transiti calcolati sul telefono'),
    'O-M-003': ("Il livello viene dai transiti di oggi sui tuoi pianeti di nascita, calcolati sul telefono dalle effemeridi. Senza l'ora di nascita le case non si calcolano.",
                'calcolo', 'i transiti calcolati sul telefono'),
    'O-M-004': ("Senza ora e luogo di nascita non c'è una carta: il livello viene dalla Luna di oggi e dal pianeta di questo campo, con le case solari contate dal tuo segno, come fa l'astrologia moderna per chi non ha l'ora di nascita.",
                'scelta', "le case solari, pratica dell'astrologia moderna, dichiarate nel testo"),
    'O-M-005': ("Il livello da due a cinque viene dalla Luna di oggi e dal pianeta di questo campo: dal segno in cui si trovano rispetto al tuo e dalle case solari che attraversano. Tre vuol dire un giorno neutro. È una regola dell'app costruita sugli aspetti fra segni di Tolomeo.",
                'fonte', 'Tolomeo, Tetrabiblos, libro I, cap. 13 (commento nel codice); la regola e\' dichiarata dell\'app'),
    'O-M-006': ("Il livello da due a cinque viene dai passaggi di oggi che parlano a questo campo, entro due gradi: quelli armonici lo alzano e quelli tesi lo abbassano; contano di più quanto sono stretti. È una regola dell'app costruita sugli aspetti di Tolomeo.",
                'fonte', 'Tolomeo, Tetrabiblos, libro I, cap. 13; la soglia dei due gradi e\' dichiarata dell\'app'),
    'O-M-007': ("Il numero è il giorno personale della numerologia moderna, dalla tua data di nascita e da quella di oggi.",
                'fonte', 'Florence Campbell, Your Days Are Numbered (1931), commento nel codice'),
    'V-M-001': ("La Luna di oggi è siderale, con l'ayanamsa di Lahiri, quella adottata dal governo indiano nel 1955; il giorno si legge all'alba del luogo, come nei Panchang.",
                'fonte', "l'ayanamsa di Lahiri adottata dal governo indiano nel 1955; i Panchang"),
    'V-M-004': ("Senza l'ora di nascita la tua stella di nascita può non essere certa, perché la Luna cambia stella circa una volta al giorno: per questo la Tara Bala non si calcola.",
                'calcolo', 'avvertenza di calcolo'),
    'V-M-009': ("L'anno va da compleanno a compleanno: è una scelta dell'app, che guarda Giove e Saturno nel giorno del tuo compleanno.",
                'scelta', 'dichiarata nel testo'),
    'V-M-011': ("La Sade Sati, i sette anni e mezzo di Saturno nella dodicesima, nella prima e nella seconda casa dalla Luna di nascita, è una lettura della tradizione indiana costruita sul gochara: per la Phaladeepika, cap. 26, Saturno dà frutti buoni solo in 3, 6 e 11.",
                'fonte', 'Phaladeepika, cap. 26'),
    'C-G-068': ("Oggi è il giorno di {animale_giorno}, il tuo stesso animale: ritorna ogni dodici giorni.",
                'calcolo', "il ciclo dei dodici rami; \"i rami uguali si rafforzano\" e' tolto perche' non ha fonte"),
    'C-G-069': ("Il ramo di oggi è il tuo: torna ogni dodici giorni; per il tuo animale non è uno dei rapporti che la tradizione classifica.",
                'fonte', 'Wan Minying, Sanming Tonghui (1578), come C-G-070'),
    'C-M-002': ("Il guardiano del giorno è uno dei dodici del calendario, contato dal mese solare.",
                'calcolo', 'fatto di calendario'),
    'C-M-004': ("La scheda prende il livello da quel dio come lo leggono lo Yuanhai Ziping e il Ziping Zhenquan; il testo è scelto per quel livello.",
                'fonte', 'Yuanhai Ziping; Ziping Zhenquan'),
    'C-M-006': ("L'anno cinese va da Capodanno lunare a Capodanno lunare, come nello zodiaco popolare; il BaZi lo fa cominciare invece a Lichun, l'inizio della primavera.",
                'calcolo', 'fatto di calendario, con la differenza fra zodiaco popolare e BaZi dichiarata'),
    'C-M-008': ("il Tai Sui e le cinque relazioni che lo offendono (stesso animale, scontro, punizione, danno, rottura) vengono dagli almanacchi annuali cinesi, il Tong Shu.",
                'fonte', 'gli almanacchi annuali cinesi, il Tong Shu'),
}

STATO = {'fonte': 'fonte dichiarata', 'calcolo': 'fatto di calcolo', 'scelta': "scelta dell'app"}


def git_show(percorso: str) -> list[str] | None:
    r = subprocess.run(['git', 'show', f'{BASE}:{percorso}'], cwd=RADICE,
                       capture_output=True)
    if r.returncode != 0:
        return None
    return r.stdout.decode('utf-8').replace('\r\n', '\n').split('\n')


MAPPE: dict[str, dict[int, int]] = {}


def mappa(percorso: str) -> dict[int, int] | None:
    if percorso in MAPPE:
        return MAPPE[percorso]
    vecchio = git_show(percorso)
    f = RADICE / percorso
    if vecchio is None or not f.exists():
        MAPPE[percorso] = None
        return None
    nuovo = f.read_text(encoding='utf-8').replace('\r\n', '\n').split('\n')
    m: dict[int, int] = {}
    sm = difflib.SequenceMatcher(None, vecchio, nuovo, autojunk=False)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        for i in range(i1, i2):
            if tag == 'equal':
                m[i + 1] = j1 + (i - i1) + 1
            else:
                m[i + 1] = min(j1 + (i - i1), max(j1, j2 - 1)) + 1
    MAPPE[percorso] = m
    return m


def riporta(n: int, percorso: str) -> int:
    m = mappa(percorso)
    if not m:
        return n
    return m.get(n, n)


PATH = r'(?:lib|docs)/[A-Za-z0-9_/]+\.(?:dart|md)'


def riporta_dove(testo: str) -> str:
    def sost(mt: re.Match) -> str:
        p = mt.group(1)
        numeri = mt.group(2)

        def uno(x: re.Match) -> str:
            a = riporta(int(x.group(1)), p)
            if x.group(2):
                b = riporta(int(x.group(2)), p)
                return f'{a}-{max(a, b)}'
            return str(a)
        return p + ':' + re.sub(r'(\d+)(?:-(\d+))?', uno, numeri)
    return re.sub(r'(' + PATH + r'):(\d+(?:-\d+)?(?:, \d+(?:-\d+)?)*)', sost, testo)


def riporta_note(testo: str, primo: str | None) -> str:
    # "(percorso, commento righe A-B)"
    def con_percorso(mt: re.Match) -> str:
        p = mt.group(1)

        def uno(x: re.Match) -> str:
            a = riporta(int(x.group(1)), p)
            if x.group(2):
                return f'{a}-{max(a, riporta(int(x.group(2)), p))}'
            return str(a)
        return f'{p}, commento ' + mt.group(2) + ' ' + re.sub(r'(\d+)(?:-(\d+))?', uno, mt.group(3))
    t = re.sub(r'(' + PATH + r'), commento (righe|riga) (\d+(?:-\d+)?(?:, \d+(?:-\d+)?)*)', con_percorso, testo)
    if primo:
        def nude(mt: re.Match) -> str:
            def uno(x: re.Match) -> str:
                a = riporta(int(x.group(1)), primo)
                if x.group(2):
                    return f'{a}-{max(a, riporta(int(x.group(2)), primo))}'
                return str(a)
            return mt.group(1) + ' ' + re.sub(r'(\d+)(?:-(\d+))?', uno, mt.group(2))
        t = re.sub(r'(?<!commento )\b(righe|riga) (\d+(?:-\d+)?(?:, \d+(?:-\d+)?)*)', nude, t)
    return riporta_dove(t)


def main() -> None:
    righe = EU.read_text(encoding='utf-8').replace('\r\n', '\n').split('\n')
    fuori = []
    toccate = []
    conti: dict[str, dict[str, int]] = {}
    for r in righe:
        m = re.match(r'^\| ([OVC])-([GSAM])-(\d{3}) \|', r)
        if not m:
            fuori.append(r)
            continue
        # Le celle: il testo puo' contenere "\|", che non separa.
        celle = re.split(r'(?<!\\)\|', r)[1:-1]
        celle = [c.strip() for c in celle]
        sigla, frase, dove, fonte, livello, stato, nota = celle[:7]
        primo = None
        pm = re.search(PATH, dove)
        if pm:
            primo = pm.group(0)
        dove = riporta_dove(dove)
        fonte = riporta_note(fonte, primo)
        nota = riporta_note(nota, primo)
        esito = None
        if sigla in NUOVI:
            testo, esito, ragione = NUOVI[sigla]
            frase = testo.replace('|', '\\|')
            stato = STATO[esito]
            if esito == 'fonte':
                fonte = ragione
                livello = 'caso'
            else:
                fonte = f'nessuna opera: {ragione}'
                livello = 'calcolo' if esito == 'calcolo' else 'scelta'
            adattato = ('; riscritto dall\'Architetto il 2 ottobre 2026 senza la '
                        'virgola prima della "e" (EV Aggiunta)'
                        if sigla in ('O-M-006', 'V-M-001', 'C-G-069') else '')
            nota = (f'TESTO NUOVO dell\'Architetto ({ARCH}), al posto di quello '
                    f'dell\'ordine EU{adattato}' + (f'; {nota}' if nota else ''))
            toccate.append((sigla, 'testo nuovo, ' + STATO[esito], frase))
        elif sigla in FONTI:
            f, dove_scritta = FONTI[sigla]
            fonte = f'{f} ({ARCH}; scritta in {dove_scritta})'
            livello = 'caso'
            stato = STATO['fonte']
            toccate.append((sigla, 'fonte', f))
        elif sigla in CALCOLO:
            fonte = f'nessuna opera: fatto calcolato dall\'app, detto bene ({ARCH})'
            livello = 'calcolo'
            stato = STATO['calcolo']
            extra = NOTA_CALCOLO.get(sigla)
            if extra:
                nota = f'{nota}; {extra}' if nota else extra
            toccate.append((sigla, 'fatto di calcolo', extra or ''))
        elif sigla in SCELTA:
            fonte = f'nessuna opera: scelta dell\'app, gia\' dichiarata dalla frase ({ARCH})'
            livello = 'scelta'
            stato = STATO['scelta']
            toccate.append((sigla, "scelta dell'app", ''))
        if 'SENZA FONTE' in stato:
            raise SystemExit(f'{sigla}: SENZA FONTE e nessun esito dell\'Architetto')
        trad = {'O': 'Occidentale', 'V': 'Vedica', 'C': 'Cinese'}[sigla[0]]
        chiave = ('fonte dichiarata' if 'fonte' in stato else
                  'fatto di calcolo' if 'calcolo' in stato else "scelta dell'app")
        conti.setdefault(trad, {}).setdefault(chiave, 0)
        conti[trad][chiave] += 1
        fuori.append('| ' + ' | '.join([sigla, frase, dove, fonte, livello, stato, nota]) + ' |')

    testo = '\n'.join(fuori)
    # L'intestazione.
    testo = testo.replace(
        '# Le affermazioni di Da dove viene e del metodo, ordine EU voce 14\n\n1 ottobre 2026.',
        '# Le affermazioni di Da dove viene e del metodo, ordine EV voce EV.08\n\n'
        '2 ottobre 2026. Rigenerato da `tool/rigenera_affermazioni_ev.py` a partire da '
        '`docs/collaudo/EU/affermazioni.md` (ordine EU voce 14) e dalla verifica '
        'dell\'Architetto, `docs/corpus/eu/verifica_affermazioni_architetto.md`: le 88 '
        'righe SENZA FONTE e le due note del metodo superate (C-M-002, C-M-004) hanno '
        'adesso il loro esito, e i testi nuovi sono quelli dell\'Architetto carattere per '
        'carattere. Ogni "file:riga" del campo Dove, e le righe citate nelle note, sono '
        f'riportate allo stato del worktree di oggi con difflib dal commit `{BASE}`, su '
        'cui il file dell\'ordine EU era stato scritto. Il testo che segue, fino a '
        '"Come si legge", e\' quello dell\'ordine EU.')
    # Lo stato in "Come si legge".
    testo = testo.replace(
        '- **Stato**: "fonte dichiarata" quando',
        '- **Stato, dall\'ordine EV**: "fonte dichiarata", "fatto di calcolo" (la frase '
        'dice un fatto calcolato dall\'app, e l\'Architetto l\'ha guardato detto bene) '
        'oppure "scelta dell\'app" (la frase dichiara una regola dell\'app). Nessuna riga '
        'e\' piu\' SENZA FONTE. Prima, nell\'ordine EU: "fonte dichiarata" quando')
    # Le osservazioni e il conteggio.
    i = testo.index('## Osservazioni per l\'Architetto')
    coda = ['## Che cosa e\' cambiato dall\'ordine EU',
            '',
            'Le quattro osservazioni del file EU per l\'Architetto sono chiuse: O-M-001 e '
            'O-M-002 hanno i testi nuovi; C-M-002 e C-M-004 anche; il difetto di "oggi" '
            'sotto la data di un altro giorno (V-S-001, V-S-002, C-S-001, C-S-002) e\' '
            'corretto dalla voce EV.09; il venerdi\' vedico dice "screziato" nei due posti '
            '(voce EV.09).',
            '',
            '## Conteggio',
            '',
            '| Tradizione | Frasi | Fonte dichiarata | Fatto di calcolo | Scelta dell\'app | SENZA FONTE |',
            '|---|---|---|---|---|---|']
    tot = {'fonte dichiarata': 0, 'fatto di calcolo': 0, "scelta dell'app": 0}
    for trad in ('Occidentale', 'Vedica', 'Cinese'):
        c = conti.get(trad, {})
        n = sum(c.values())
        for k in tot:
            tot[k] += c.get(k, 0)
        coda.append(f'| {trad} | {n} | {c.get("fonte dichiarata", 0)} | '
                    f'{c.get("fatto di calcolo", 0)} | {c.get("scelta dell\'app", 0)} | 0 |')
    coda.append(f'| Totale | {sum(tot.values())} | {tot["fonte dichiarata"]} | '
                f'{tot["fatto di calcolo"]} | {tot["scelta dell\'app"]} | 0 |')
    coda += ['', f'### Le {len(toccate)} righe verificate dall\'Architetto', '']
    for sigla, esito, extra in toccate:
        e = extra if len(extra) < 160 else extra[:157] + '...'
        coda.append(f'- {sigla}: {esito}' + (f'. {e}' if e else ''))
    testo = testo[:i] + '\n'.join(coda) + '\n'
    EV.parent.mkdir(parents=True, exist_ok=True)
    EV.write_text(testo, encoding='utf-8', newline='\n')
    print(f'scritto {EV}: righe verificate {len(toccate)}, totale '
          f'{sum(tot.values())}, conti {tot}')


if __name__ == '__main__':
    main()
