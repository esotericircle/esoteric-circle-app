"""I FASCICOLI DEI LETTORI CIECHI del corpus della Sinastria evolutiva.

Ordine FT voce FT.12, 14 ottobre 2026, col metodo dell'ordine FM
(tool/i_lettori_ciechi_del_corpus.py). I lettori ciechi sono agenti di Code,
mai Gemini (regola R2). Per ogni capitolo dieci testi a caso, cinque suoi e
cinque della gemella da cui lo schedario dice che deve distinguersi,
mescolati; un lettore che non li ha scritti dice a quale capitolo appartiene
ciascuno. Poi dieci testi per dire a quale dei quattro legami parlano, e dieci
per dire se la coppia e' in armonia o in tensione. La soglia, decisa da Code
come nell'ordine FM: otto su dieci per prova, in due giri con campioni
diversi (il seme cambia col giro).

python tool/i_lettori_ciechi_della_sinastria.py prepara <giro>
python tool/i_lettori_ciechi_della_sinastria.py conta <giro> <risposte.json>
"""
import importlib.util
import json
import os
import random
import sys

R = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + '/'
D = R + 'docs/collaudo/FT/lettori_ciechi/'
spec = importlib.util.spec_from_file_location(
    'c', R + 'tool/il_corpus_della_sinastria.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)

# Il nome dell'altra persona nei fascicoli: uno solo, sempre lo stesso, cosi'
# il lettore non riconosce niente dal nome.
NOME = 'Giulia'

CAPITOLI = {
    'attrazione': "L'ATTRAZIONE: il desiderio, il fascino, la scintilla fisica fra due persone.",
    'emozioni': "LE EMOZIONI: il sentire, la tenerezza, il bisogno di sentirsi al sicuro l'uno con l'altra.",
    'mente': "LA MENTE: il dialogo, le idee, il modo di parlarsi e di capirsi.",
    'durata': "LA DURATA: la tenuta nel tempo, gli impegni, la struttura che regge il legame.",
    'destino': "IL DESTINO: il senso dell'incontro, la direzione in cui il legame spinge a crescere.",
}
# La gemella da cui ogni capitolo deve distinguersi, dagli schedari.
PROVE = [('attrazione', 'emozioni'), ('emozioni', 'mente'),
         ('mente', 'attrazione'), ('durata', 'destino'),
         ('destino', 'durata')]


def testi(capitolo, legami=None, toni=None):
    """[(cella, campo, n, testo)] delle aperture e dei fare di un capitolo."""
    dati = c.leggi('capitolo_' + capitolo)
    fuori = []
    for (cella, campo, n), t in dati.items():
        if campo not in ('apertura', 'fare') or not t:
            continue
        legame, tono = cella.split()
        if legami and legame not in legami:
            continue
        if toni and tono not in toni:
            continue
        fuori.append((cella, campo, n, t.replace('{nome}', NOME)))
    return fuori


def prepara(giro):
    rnd = random.Random(2000 + int(giro))
    fasc = [
        '# I LETTORI CIECHI della Sinastria evolutiva, giro %s\n' % giro,
        'Per ogni prova scegli la lettera giusta per ogni testo. Rispondi '
        'con un JSON {"identificativo": "lettera"}.\n',
    ]
    chiave = {}
    n = 0
    for cap, gem in PROVE:
        a = rnd.sample(testi(cap), 5)
        b = rnd.sample(testi(gem), 5)
        voci = [(cap, x) for x in a] + [(gem, x) for x in b]
        rnd.shuffle(voci)
        fasc.append('## PROVA %s\n\nOpzioni:\n- A = %s\n- B = %s\n'
                    % (cap, CAPITOLI[cap], CAPITOLI[gem]))
        for vero, (cella, campo, k, t) in voci:
            n += 1
            ident = '%s-%02d' % (cap, n)
            fasc.append('- %s: %s' % (ident, t))
            chiave[ident] = {'prova': cap, 'giusta': 'A' if vero == cap else 'B',
                             'vera': vero, 'cella': cella, 'campo': campo,
                             'variante': k}
        fasc.append('')

    lettere = {'amore': 'A', 'amicizia': 'B', 'famiglia': 'C', 'lavoro': 'D'}
    tutti = [(cap, x) for cap in CAPITOLI for x in testi(cap)]
    fasc.append('## PROVA legami\n\nA quale legame parla il testo?\n\n'
                'Opzioni:\n- A = amore\n- B = amicizia\n- C = famiglia\n'
                '- D = lavoro\n')
    for cap, (cella, campo, k, t) in rnd.sample(tutti, 10):
        n += 1
        ident = 'legami-%02d' % n
        fasc.append('- %s: %s' % (ident, t))
        legame = cella.split()[0]
        chiave[ident] = {'prova': 'legami', 'giusta': lettere[legame],
                         'vera': legame, 'capitolo': cap, 'cella': cella,
                         'campo': campo, 'variante': k}
    fasc.append('')

    toni = [(cap, x) for cap in CAPITOLI
            for x in testi(cap, toni=('armonico', 'teso'))]
    fasc.append('## PROVA toni\n\nCom\'e\' la coppia in questo capitolo?\n\n'
                'Opzioni:\n- A = in armonia, le cose scorrono\n'
                '- B = in tensione, c\'e\' attrito da lavorare\n')
    for cap, (cella, campo, k, t) in rnd.sample(toni, 10):
        n += 1
        ident = 'toni-%02d' % n
        fasc.append('- %s: %s' % (ident, t))
        tono = cella.split()[1]
        chiave[ident] = {'prova': 'toni',
                         'giusta': 'A' if tono == 'armonico' else 'B',
                         'vera': tono, 'capitolo': cap, 'cella': cella,
                         'campo': campo, 'variante': k}
    fasc.append('')
    open(D + 'fascicolo_%s.md' % giro, 'w', encoding='utf-8',
         newline='\n').write('\n'.join(fasc) + '\n')
    with open(D + 'chiave_%s.json' % giro, 'w', encoding='utf-8',
              newline='\n') as f:
        json.dump(chiave, f, ensure_ascii=False, indent=1)
    print('voci', n)


def conta(giro, risposte):
    chiave = json.load(open(D + 'chiave_%s.json' % giro, encoding='utf-8'))
    ris = json.load(open(risposte, encoding='utf-8'))
    per = {}
    sbagli = []
    for ident, k in chiave.items():
        r = str(ris.get(ident, '?')).strip().upper()[:1]
        ok = r == k['giusta']
        per.setdefault(k['prova'], [0, 0])
        per[k['prova']][0] += ok
        per[k['prova']][1] += 1
        if not ok:
            sbagli.append('%s (%s, %s %s, vera %s, detta %s)' % (
                ident, k['prova'], k.get('capitolo', k['prova']), k['cella'],
                k['vera'], r))
    righe = ['GIRO %s' % giro]
    for p, (o, t) in per.items():
        righe.append('%s: %d su %d %s' % (
            p, o, t, 'PASSA' if o >= 8 else 'SOTTO LA SOGLIA'))
    righe.append('sbagliati: ' + ('; '.join(sbagli) or 'nessuno'))
    print('\n'.join(righe))
    return righe


if __name__ == '__main__':
    os.makedirs(D, exist_ok=True)
    if sys.argv[1] == 'prepara':
        prepara(sys.argv[2])
    else:
        righe = conta(sys.argv[2], sys.argv[3])
        open(D + 'esito_%s.txt' % sys.argv[2], 'w', encoding='utf-8',
             newline='\n').write('\n'.join(righe) + '\n')
