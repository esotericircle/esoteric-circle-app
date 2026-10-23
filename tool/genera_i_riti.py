# -*- coding: utf-8 -*-
"""GENERA I RITI PROPIZIATORI. Ordine GA voce GA.04, 20 ottobre 2026.

I riti del quarto paragrafo della Lunga stanno in `docs/corpus/riti/*.md`,
uno per raccolta: gli inni orfici e i mantra dei Navagraha per l'Oroscopo
occidentale e vedico, i gesti del Tong Shu per il cinese, i salmi di Lenain
nella traduzione di Martini per l'Oracolo degli Angeli, i galdr per le Rune,
la contemplazione per i Tarocchi. Questo strumento li porta carattere per
carattere in `lib/core/responsi/i_riti_propiziatori_dati.dart`.

La forma di ogni file:
- una sezione `## Da dove viene` con righe `- <Chiave>: <testo>` (una per
  pianeta, graha o ufficiale) oppure un paragrafo unico per tutta la
  raccolta;
- le sezioni `### <chiave>, <chiave>, ...` con sotto le righe
  `- <Campo>: <testo>`; il campo `Rito` e' il testo del riquadro, e un campo
  `Da dove viene` dentro la sezione vale solo per lei (i salmi).

Ogni rito si controlla con le regole di `tool/le_parole_dei_responsi.py`
(da 40 a 50 parole, la lingua di casa): se uno sbaglia lo strumento si ferma
e non scrive niente.

    python tool/genera_i_riti.py
"""
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from le_parole_dei_responsi import MASSIMO, MINIMO, difetti_di_lingua, parole  # noqa: E402

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CARTELLA = os.path.join(RADICE, 'docs', 'corpus', 'riti')
USCITA = os.path.join(RADICE, 'lib', 'core', 'responsi',
                      'i_riti_propiziatori_dati.dart')
RACCOLTE = ['inni_orfici', 'mantra_navagraha', 'gesti_tong_shu',
            'salmi_martini', 'galdr_delle_rune', 'contemplazione_dei_tarocchi']
# Le parti del rito che stanno fra virgolette basse e vengono dalla fonte
# (il versetto di Martini, il verso orfico): la lingua di casa non le tocca.
CITAZIONE = re.compile(r'«[^»]*»')


# **ORDINE GA VOCE GA.06, I RITI DELL'OROSCOPO SEGUONO IL PERIODO.** Le tre
# raccolte dell'Oroscopo hanno, per ogni reggente e dominio, un rito per il
# Giorno, la Settimana, il Mese e l'Anno: prima un solo rito "periodo" valeva
# per tutti e tre, e la Settimana e l'Anno con lo stesso reggente mostravano lo
# stesso rito parola per parola (lettore cieco, oroscopo-7 e 15, 37 e 45, 39 e
# 47), mentre un rito scritto per un periodo che comincia oggi ("Al primo
# mattino del periodo", "Inaugura il tratto") finiva sotto un Anno cominciato
# da sette mesi (oroscopo-32, 45, 47).
REGGENTI = {
    'inni_orfici': ['Sole', 'Luna', 'Marte', 'Mercurio', 'Giove', 'Venere',
                    'Saturno'],
    'mantra_navagraha': ['Surya', 'Chandra', 'Mangala', 'Budha', 'Guru',
                         'Shukra', 'Shani'],
    'gesti_tong_shu': ['Jian', 'Chu', 'Man', 'Ping', 'Ding', 'Zhi', 'Po',
                       'Wei', 'Cheng', 'Shou', 'Kai', 'Bi'],
}
DOMINI = ['Generale', 'Amore', 'Carriera', 'Fortuna']
PERIODI = ['giorno', 'settimana', 'mese', 'anno']
# Il rito dell'Anno vale in qualunque punto dell'anno: niente inizi, niente
# stagioni o mesi, niente "periodo" che non dice quale.
FUORI_DALL_ANNO = re.compile(
    r"\b(inizi\w*|inaugur\w*|primo mattino|comincia\w*|si apre|apre|"
    r"prim[oa] giorn[oi]|mesi|ogni mese|met[àa] (dell.)?anno|"
    r"fine dell.anno|periodo|primavera|estate|autunno|inverno|stagion\w*|"
    r"gennaio|febbraio|marzo|aprile|maggio|giugno|luglio|agosto|settembre|"
    r"ottobre|novembre|dicembre)\b", re.IGNORECASE)
# L'Amore vale per chi ha un legame e per chi non lo ha (oroscopo-10).
SOLO_COPPIA = re.compile(r'(chi ami|persona amata|il partner|la partner)',
                         re.IGNORECASE)
ALTRA_STRADA = re.compile(
    r'(o a chi|o chi|o per chi|o di chi|o con chi|chi desideri|chi vorresti|'
    r'senza legame|se cerchi|se non hai|se hai un legame)', re.IGNORECASE)


ESENTI_DEI_RAMI = [
    'a chi ami o a chi desideri incontrare',
    'chi ami o a chi desideri incontrare',
    'chi ami o chi desideri incontrare',
    'se hai un legame',
    'se sei senza legame',
]


def frasi_del_rito(testo):
    """Le frasi di cinque parole o piu', senza le citazioni fra virgolette
    basse (la formula torna in ogni rito del suo reggente, di proposito)."""
    t = CITAZIONE.sub('«»', testo)
    return [f.strip().lower() for f in re.split(r'(?<=[.?:;])\s+', t)
            if len(f.split()) >= 5]


def difetti_dell_oroscopo(raccolta, riti):
    """I difetti GA.06 di una raccolta dell'Oroscopo."""
    fuori = []
    for reggente in REGGENTI[raccolta]:
        for dominio in DOMINI:
            for periodo in PERIODI:
                if f'{raccolta}|{reggente}|{dominio}|{periodo}' not in riti:
                    fuori.append(f'{raccolta}|{reggente}|{dominio}|{periodo}: '
                                 'manca')
    viste = {}
    for k, testo in riti.items():
        parti = k.split('|')
        if len(parti) != 4 or parti[3] not in PERIODI:
            fuori.append(f'{k}: il periodo dev\'essere uno di {PERIODI}')
            continue
        senza = CITAZIONE.sub('', testo)
        if parti[3] == 'anno':
            m = FUORI_DALL_ANNO.search(senza)
            if m:
                fuori.append(f'{k}: il rito dell\'anno dice «{m.group(0)}»')
        if parti[2] == 'Amore' and SOLO_COPPIA.search(senza) \
                and not ALTRA_STRADA.search(senza):
            fuori.append(f'{k}: l\'Amore parla solo a chi ha un legame')
        for f in frasi_del_rito(testo):
            if f in viste and viste[f] != k:
                fuori.append(f'{k}: frase gia\' in {viste[f]}: «{f[:50]}»')
            viste.setdefault(f, k)
    # Ordine GA voce GA.06, il secondo lettore cieco: fra i sedici riti dello
    # stesso reggente nessuna sequenza di sei parole in comune (la glossa di
    # Kai, lo stesso gesto di Cheng in quattro riti), fuori dalla formula e
    # dalle formule dei due rami dell'Amore.
    per_reggente = {}
    for k, testo in riti.items():
        reggente = '|'.join(k.split('|')[:2])
        t = CITAZIONE.sub(' | ', testo.lower())
        for x in ESENTI_DEI_RAMI:
            t = t.replace(x, ' | ')
        parole_ = re.sub(r"[^a-zàèéìòù'| ]", ' ', t).split()
        for i in range(len(parole_) - 5):
            g = parole_[i:i + 6]
            if '|' in g:
                continue
            per_reggente.setdefault((reggente, ' '.join(g)), set()).add(k)
    for (reggente, g), chiavi in sorted(per_reggente.items()):
        if len(chiavi) > 1:
            fuori.append(f'{reggente}: «{g}» in {sorted(chiavi)}')
    return fuori


def dart(testo):
    return "'" + testo.replace('\\', '\\\\').replace("'", "\\'") \
        .replace('$', '\\$') + "'"


def chiave(intestazione):
    return '|'.join(p.strip() for p in intestazione.split(','))


def leggi(raccolta):
    testo = io.open(os.path.join(CARTELLA, raccolta + '.md'),
                    encoding='utf-8').read()
    riti, fonti, difetti = {}, {}, []
    sezione = None
    intestazione = None
    for riga in testo.splitlines():
        if riga.startswith('## '):
            sezione = riga[3:].strip()
            intestazione = None
            continue
        if riga.startswith('### '):
            intestazione = chiave(riga[4:])
            continue
        if sezione == 'Da dove viene' and intestazione is None:
            m = re.match(r'^- ([^:]+): (.+)$', riga)
            if m:
                fonti[f'{raccolta}|{chiave(m.group(1))}'] = m.group(2).strip()
            elif riga.strip() and not riga.startswith('#'):
                fonti.setdefault(raccolta, riga.strip())
            continue
        if intestazione is None:
            continue
        m = re.match(r'^- ([^:]+): (.*)$', riga)
        if not m:
            continue
        campo, valore = m.group(1).strip(), m.group(2).strip()
        k = f'{raccolta}|{intestazione}'
        if campo == 'Rito':
            if k in riti:
                difetti.append(f'{k}: rito doppio')
            riti[k] = valore
            n = parole(valore)
            if not MINIMO <= n <= MASSIMO:
                difetti.append(f'{k}: {n} parole')
            for d in difetti_di_lingua(CITAZIONE.sub('«»', valore)):
                difetti.append(f'{k}: {d}')
        elif campo == 'Da dove viene' and valore:
            fonti[k] = valore
    return riti, fonti, difetti


def main():
    riti, fonti, difetti = {}, {}, []
    for r in RACCOLTE:
        if not os.path.exists(os.path.join(CARTELLA, r + '.md')):
            difetti.append(f'manca la raccolta {r}.md')
            continue
        a, b, c = leggi(r)
        riti.update(a)
        fonti.update(b)
        difetti.extend(c)
        if r in REGGENTI:
            difetti.extend(difetti_dell_oroscopo(r, a))
        print(f'{r}: {len(a)} riti, {len(b)} righe di "Da dove viene"')
    if difetti:
        print('\n'.join(difetti[:60]))
        raise SystemExit(f'DIFETTI: {len(difetti)}, non scrivo niente')
    righe = [
        '// GENERATO da tool/genera_i_riti.py dai file di docs/corpus/riti/.',
        '// Non si tocca a mano: si cambia la raccolta e si rigenera. Ordine GA',
        '// voce GA.04, 20 ottobre 2026.',
        '// ignore_for_file: lines_longer_than_80_chars',
        '',
        '/// I riti propiziatori e le loro fonti, per raccolta e chiave',
        '/// (`<raccolta>|<chiave>|<chiave>...`). Si leggono da',
        '/// `IRitiPropiziatori`.',
        'abstract final class IRitiPropiziatoriDati {',
        '  static const Map<String, String> riti = {',
    ]
    for k in sorted(riti):
        righe.append(f'    {dart(k)}: {dart(riti[k])},')
    righe.append('  };')
    righe.append('')
    righe.append('  static const Map<String, String> fonti = {')
    for k in sorted(fonti):
        righe.append(f'    {dart(k)}: {dart(fonti[k])},')
    righe.append('  };')
    righe.append('}')
    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(
        '\n'.join(righe) + '\n')
    print(f'{USCITA}: {len(riti)} riti, {len(fonti)} fonti')


if __name__ == '__main__':
    main()
