"""I FASCICOLI DEI LETTORI CIECHI del corpus dell'Oracolo degli Angeli.

Ordine FU voce FU.05, 15 ottobre 2026, col metodo dell'ordine FM e del
corpus della Sinastria evolutiva (tool/i_lettori_ciechi_della_sinastria.py).
I lettori ciechi sono agenti di Code, mai Gemini (regola R2). In ogni giro:

- PROVA ruoli (due blocchi da dieci): messaggi mescolati delle tre
  posizioni; il lettore dice se ciascuno appartiene all'Angelo Custode (che
  cosa fare), all'Angelo del Cuore (che cosa sentire) o all'Angelo
  dell'Intelletto (che cosa capire).
- PROVA gemelle (quattro coppie, dieci messaggi ciascuna, cinque per
  angelo): messaggi mescolati di due angeli gemelli dello schedario; il
  lettore dice di quale dei due e' ciascuno, leggendo il nucleo dei due.

**Il nome dell'angelo si toglie dal testo** prima di darlo al lettore:
con il nome dentro, la prova delle gemelle sarebbe una lettura del nome.
La soglia, decisa da Code come nell'ordine FM: otto su dieci per prova, in
due giri con campioni diversi (il seme cambia col giro).

python tool/i_lettori_ciechi_dell_oracolo.py prepara <giro>
python tool/i_lettori_ciechi_dell_oracolo.py conta <giro> <risposte.json>
"""
import importlib.util
import io
import json
import os
import random
import re
import sys

R = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + '/'
D = R + 'docs/collaudo/FU/lettori_ciechi/'
spec = importlib.util.spec_from_file_location(
    'c', R + 'tool/il_corpus_dell_oracolo.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)

RUOLI = {
    'custode': "A = l'Angelo Custode: CHE COSA FARE (un'azione, un gesto concreto)",
    'cuore': "B = l'Angelo del Cuore: CHE COSA SENTIRE (un'emozione da accogliere)",
    'intelletto': "C = l'Angelo dell'Intelletto: CHE COSA CAPIRE (una cosa da vedere chiaro)",
}
LETTERA = {'custode': 'A', 'cuore': 'B', 'intelletto': 'C'}


def nuclei():
    """{numero: nucleo} dallo schedario di LEGGIMI.md."""
    t = io.open(R + 'docs/corpus/oracolo_angeli/LEGGIMI.md',
                encoding='utf-8').read()
    fuori = {}
    for m in re.finditer(r'### (\d\d) [^\n]*\n(.*?)(?=\n### |\Z)', t, re.S):
        n = re.search(r'\*\*Il nucleo\*\*[^:]*: (.*)', m.group(2))
        fuori[int(m.group(1))] = n.group(1).strip().rstrip('.')
    return fuori


def senza_nome(numero, testo):
    for nome in c.nomi_degli_angeli()[numero]:
        testo = re.sub(r'(?<![A-Za-zÀ-ÿ])%s(?![A-Za-zÀ-ÿ])' % re.escape(nome),
                       "quest'angelo", testo)
    # A inizio di frase la maiuscola.
    return re.sub(r"(^|[.!?:]\s+)quest'angelo",
                  lambda m: m.group(1) + "Quest'angelo", testo)


def messaggi(ruolo, numero=None):
    fuori = []
    for (cella, campo, n), t in c.leggi(ruolo).items():
        k = int(cella.split()[0])
        if not t or (numero and k != numero):
            continue
        fuori.append((k, cella, n, senza_nome(k, t)))
    return fuori


def prepara(giro):
    rnd = random.Random(7000 + int(giro))
    fasc = [
        '# I LETTORI CIECHI dell\'Oracolo degli Angeli, giro %s\n' % giro,
        'Per ogni prova scegli la lettera giusta per ogni testo. Rispondi con '
        'un JSON {"identificativo": "lettera"}. Il nome dell\'angelo e\' stato '
        'tolto dai testi e sostituito con "quest\'angelo".\n',
    ]
    chiave = {}
    n = 0
    for blocco in (1, 2):
        voci = []
        for ruolo in RUOLI:
            voci += [(ruolo, x) for x in rnd.sample(messaggi(ruolo), 4)]
        rnd.shuffle(voci)
        voci = voci[:10]
        fasc.append('## PROVA ruoli %d\n\nNell\'Oracolo la persona affida una '
                    'domanda a tre angeli: ognuno porta un messaggio da una '
                    'posizione diversa. Da quale posizione parla ciascun '
                    'testo?\n\nOpzioni:\n- %s\n- %s\n- %s\n'
                    % (blocco, RUOLI['custode'], RUOLI['cuore'],
                       RUOLI['intelletto']))
        for ruolo, (k, cella, var, t) in voci:
            n += 1
            ident = 'ruoli%d-%02d' % (blocco, n)
            fasc.append('- %s: %s' % (ident, t))
            chiave[ident] = {'prova': 'ruoli %d' % blocco,
                             'giusta': LETTERA[ruolo], 'vera': ruolo,
                             'cella': cella, 'variante': var}
        fasc.append('')
    nu = nuclei()
    coppie = rnd.sample(c.GEMELLE, 4)
    for a, b in coppie:
        tutti_a = [x for r in RUOLI for x in messaggi(r, a)]
        tutti_b = [x for r in RUOLI for x in messaggi(r, b)]
        voci = ([(a, x) for x in rnd.sample(tutti_a, 5)] +
                [(b, x) for x in rnd.sample(tutti_b, 5)])
        rnd.shuffle(voci)
        prova = 'gemelle %02d-%02d' % (a, b)
        fasc.append('## PROVA %s\n\nDi quale dei due angeli parla ciascun '
                    'testo?\n\nOpzioni:\n- A = l\'angelo il cui nucleo e\': '
                    '%s\n- B = l\'angelo il cui nucleo e\': %s\n'
                    % (prova, nu[a], nu[b]))
        for vero, (k, cella, var, t) in voci:
            n += 1
            ident = 'gemelle-%02d' % n
            fasc.append('- %s: %s' % (ident, t))
            chiave[ident] = {'prova': prova,
                             'giusta': 'A' if vero == a else 'B',
                             'vera': cella, 'cella': cella, 'variante': var}
        fasc.append('')
    os.makedirs(D, exist_ok=True)
    io.open(D + 'fascicolo_%s.md' % giro, 'w', encoding='utf-8',
            newline='\n').write('\n'.join(fasc) + '\n')
    with io.open(D + 'chiave_%s.json' % giro, 'w', encoding='utf-8',
                 newline='\n') as f:
        json.dump(chiave, f, ensure_ascii=False, indent=1)
    print('voci', n)


def conta(giro, risposte):
    chiave = json.load(io.open(D + 'chiave_%s.json' % giro, encoding='utf-8'))
    ris = json.load(io.open(risposte, encoding='utf-8-sig'))
    per = {}
    sbagli = []
    for ident, k in chiave.items():
        r = str(ris.get(ident, '?')).strip().upper()[:1]
        ok = r == k['giusta']
        per.setdefault(k['prova'], [0, 0])
        per[k['prova']][0] += ok
        per[k['prova']][1] += 1
        if not ok:
            sbagli.append('%s (%s, %s variante %s, giusta %s, detta %s)' % (
                ident, k['prova'], k['cella'], k['variante'], k['giusta'], r))
    righe = ['GIRO %s' % giro]
    for p, (o, t) in per.items():
        righe.append('%s: %d su %d %s' % (
            p, o, t, 'PASSA' if o >= 8 else 'SOTTO LA SOGLIA'))
    righe.append('sbagliati: ' + ('; '.join(sbagli) or 'nessuno'))
    print('\n'.join(righe))
    return righe


if __name__ == '__main__':
    if sys.argv[1] == 'prepara':
        prepara(sys.argv[2])
    else:
        righe = conta(sys.argv[2], sys.argv[3])
        io.open(D + 'esito_%s.txt' % sys.argv[2], 'w', encoding='utf-8',
                newline='\n').write('\n'.join(righe) + '\n')
