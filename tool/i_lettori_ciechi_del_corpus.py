"""I FASCICOLI DEI LETTORI CIECHI del corpus posizionale, e il loro conto.

Ordine FM voce 05, 12 ottobre 2026: per ogni posizione scritta da Code dieci
testi a caso, cinque suoi e cinque della gemella, mescolati; un lettore che non
li ha scritti dice a quale posizione appartiene ciascuno. Per i registri, a
quale dei tre ambiti. La soglia, decisa da Code: otto su dieci, in due giri
con campioni diversi (il seme cambia col giro).

python tool/i_lettori_ciechi_del_corpus.py prepara <giro>
python tool/i_lettori_ciechi_del_corpus.py conta <giro> <risposte.json>
"""
import importlib.util
import json
import os
import random
import sys

R = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + '/'
D = R + 'docs/collaudo/FM/lettori_ciechi/'
spec = importlib.util.spec_from_file_location('g', R + 'tool/genera_carte_nella_posizione.py')
g = importlib.util.module_from_spec(spec)
spec.loader.exec_module(g)

NOMI = {
    'passato': "IL PASSATO della stesa a tre carte: ciò che è già accaduto e ha portato la domanda fin qui.",
    'presente': "IL PRESENTE della stesa a tre carte: ciò che stai vivendo adesso nella domanda.",
    'futuro': "IL FUTURO della stesa a tre carte: verso dove tende la domanda se le cose proseguono.",
    'se_stesso': "TE STESSO (Croce Celtica): il tuo atteggiamento, la posizione che prendi nella faccenda.",
    'consultante': "IL CONSULTANTE (croce a quattro): la situazione reale, il punto in cui si trova chi chiede.",
    'la_casa': "LA TUA CASA (Croce Celtica): l'ambiente intorno a te, le persone vicine, il posto fra gli altri.",
    'speranze_o_timori': "SPERANZE O TIMORI (Croce Celtica): ciò che speri o temi nella faccenda.",
    'esito': "L'ESITO: ciò che la faccenda tende a diventare, il punto d'arrivo della stesa.",
    'dietro': "CIÒ CHE È DIETRO (Croce Celtica): ciò che è appena passato o sta svanendo adesso.",
    'sotto': "CIÒ CHE STA SOTTO (Croce Celtica): il fondamento, il passato diventato tuo che regge la faccenda.",
}
PROVE = [('passato', 'presente'), ('presente', 'futuro'), ('futuro', 'presente'),
         ('se_stesso', 'consultante'), ('la_casa', 'se_stesso'),
         ('speranze_o_timori', 'esito'), ('dietro', 'sotto')]


def testi(file, chiavi):
    carte = g.carte_del_mazzo()
    dati = g.leggi_file(R + 'docs/corpus/tarocchi_posizione/%s.md' % file, chiavi, carte)
    return [(c, v, k, t) for (c, v), d in dati.items() for k, t in d.items() if t]


def prepara(giro):
    rnd = random.Random(1000 + int(giro))
    fasc, chiave = [], {}
    n = 0
    for pos, gem in PROVE:
        a = rnd.sample(testi(pos, g.VARIANTI), 5)
        b = rnd.sample(testi(gem, g.VARIANTI), 5)
        voci = [(pos, x) for x in a] + [(gem, x) for x in b]
        rnd.shuffle(voci)
        fasc.append('## PROVA %s\n\nOpzioni:\n- A = %s\n- B = %s\n' % (pos, NOMI[pos], NOMI[gem]))
        for vero, (c, v, k, t) in voci:
            n += 1
            ident = '%s-%02d' % (pos, n)
            fasc.append('- %s: %s' % (ident, t))
            chiave[ident] = {'prova': pos, 'giusta': 'A' if vero == pos else 'B',
                             'vera': vero, 'carta': c, 'verso': v, 'variante': k}
        fasc.append('')
    reg = testi('registri', g.GRUPPI)
    fasc.append('## PROVA registri\n\nOpzioni:\n- A = amore e sentimenti\n- B = lavoro e denaro\n- C = vita e cammino\n')
    for c, v, k, t in rnd.sample(reg, 10):
        n += 1
        ident = 'registri-%02d' % n
        fasc.append('- %s: %s' % (ident, t))
        chiave[ident] = {'prova': 'registri', 'giusta': {'amore': 'A', 'lavoro': 'B', 'vita': 'C'}[k],
                         'vera': k, 'carta': c, 'verso': v}
    open(D + 'fascicolo_%s.md' % giro, 'w', encoding='utf-8', newline='\n').write('\n'.join(fasc) + '\n')
    json.dump(chiave, open(D + 'chiave_%s.json' % giro, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
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
            sbagli.append('%s (%s, %s %s, vera %s, detta %s)' % (ident, k['prova'], k['carta'], k['verso'], k['vera'], r))
    righe = ['GIRO %s' % giro]
    for p, (o, t) in per.items():
        righe.append('%s: %d su %d %s' % (p, o, t, 'PASSA' if o >= 8 else 'SOTTO LA SOGLIA'))
    righe.append('sbagliati: ' + '; '.join(sbagli))
    print('\n'.join(righe))
    return righe


if __name__ == '__main__':
    os.makedirs(D, exist_ok=True)
    if sys.argv[1] == 'prepara':
        prepara(sys.argv[2])
    else:
        righe = conta(sys.argv[2], sys.argv[3])
        open(D + 'esito_%s.txt' % sys.argv[2], 'w', encoding='utf-8').write('\n'.join(righe) + '\n')
