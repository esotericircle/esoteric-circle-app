# -*- coding: utf-8 -*-
"""Genera lib/core/angels/angel_lore.dart dal Corpus dei 72 Angeli.

Sorgente: docs/corpus/angeli.md, prodotto dai ricercatori con la loro politica
di pubblicazione in testa. Quella politica non e' un preambolo, e' un vincolo:
qui viene applicata alla lettera, e cio' che non si pubblica non entra nemmeno
nel file generato, cosi' non puo' arrivare a schermo per distrazione.

Cosa passa: numero, nome principale, arco di gradi col segno, salmo con la sua
numerazione, dominio secondo la tradizione, chiave di lettura redazionale,
confidenza dichiarata dal ricercatore.

Cosa non passa: guarigione e salute in ogni forma, promesse di esito, nomi
delle entita' avverse, corrispondenze goetiche, nomi alternativi, le finestre
di calendario del custode. Una frase che contenga un termine vietato non viene
ripulita, viene TOLTA intera: correggerla a macchina vorrebbe dire riscrivere
una fonte, che non e' un lavoro da script.

Uso:
  python tool/genera_angeli.py
"""

import io
import re

SORGENTE = 'docs/corpus/angeli.md'
USCITA = 'lib/core/angels/angel_lore.dart'

# I termini che la politica vieta. Il confronto e' su testo normalizzato, senza
# accenti e in minuscolo, cosi' fertilita' e fertilità cadono insieme.
VIETATI = [
    'guarigione', 'guarire', 'guarisce', 'guaritore', 'salute', 'malattia',
    'malattie', 'malato', 'malati', 'fertilita', 'fecondita', 'sterilita',
    'longevita', 'vista', 'udito', 'olfatto', 'medicina', 'medico',
    'panacea', 'pietra filosofale', 'tesori', 'tesoro', 'nemici', 'nemico',
    'prigionieri', 'prigioniero', 'promozione', 'promozioni', 'vittoria',
    'armi', 'demone', 'demoni', 'goetia', 'goetica', 'goetiche',
    'angelo contrario', 'angeli contrari',
]


def senza_accenti(s):
    tavola = {
        'à': 'a', 'á': 'a', 'è': 'e', 'é': 'e',
        'ì': 'i', 'í': 'i', 'ò': 'o', 'ó': 'o',
        'ù': 'u', 'ú': 'u',
    }
    return ''.join(tavola.get(c, c) for c in s.lower())


def frasi_pulite(testo):
    """Toglie le frasi che contengono un termine vietato, tiene le altre."""
    if not testo:
        return '', 0
    pezzi = re.split(r'(?<=[.!?])\s+', testo.strip())
    tenute, tolte = [], 0
    for f in pezzi:
        piatto = senza_accenti(f)
        if any(v in piatto for v in VIETATI):
            tolte += 1
            continue
        tenute.append(f)
    return ' '.join(tenute).strip(), tolte


def campo(blocco, etichetta):
    """Il valore di un campo in elenco, per esempio Arco zodiacale."""
    m = re.search(r'- \*\*' + etichetta + r'\*\*:\s*(.+)', blocco)
    return m.group(1).strip() if m else ''


def paragrafo(blocco, titolo):
    """Il testo di un paragrafo titolato, per esempio Salmo."""
    m = re.search(r'\*\*' + titolo + r'\*\*\.\s*(.+?)(?=\n\n|\Z)', blocco,
                  re.S)
    return ' '.join(m.group(1).split()) if m else ''


def dart_stringa(s):
    return "'" + s.replace('\\', r'\\').replace("'", r"\'").replace('$', r'\$') + "'"


def main():
    testo = io.open(SORGENTE, encoding='utf-8').read()
    schede = re.split(r'\n### (?=\d+\.)', testo)[1:]
    voci, tolte_totali, senza_salmo = [], 0, 0

    for scheda in schede:
        intestazione = scheda.split('\n', 1)[0]
        m = re.match(r'(\d+)\.\s*(.+)', intestazione.strip())
        numero, nome = int(m.group(1)), m.group(2).strip()

        arco = campo(scheda, 'Arco zodiacale')
        segno = ''
        ms = re.search(r'segno\s+([A-Za-zÀ-ſ]+)', arco)
        if ms:
            segno = ms.group(1).strip()
        gradi = ''
        mg = re.search(r'da\s+(\d+)\s+a\s+(\d+)\s+gradi', arco)
        if mg:
            gradi = 'da %s a %s gradi' % (mg.group(1), mg.group(2))

        confidenza = campo(scheda, 'Confidenza dichiarata dal ricercatore')

        salmo, t1 = frasi_pulite(paragrafo(scheda, 'Salmo'))
        dominio, t2 = frasi_pulite(
            paragrafo(scheda, 'Dominio secondo la tradizione'))
        chiave, t3 = frasi_pulite(
            paragrafo(scheda, 'Chiave di lettura, redazionale'))
        tolte_totali += t1 + t2 + t3
        if not salmo:
            senza_salmo += 1

        voci.append({
            'n': numero, 'nome': nome, 'gradi': gradi, 'segno': segno,
            'salmo': salmo, 'dominio': dominio, 'chiave': chiave,
            'confidenza': confidenza,
        })

    visti = {}
    for v in voci:
        base = v['nome']
        visti[base] = visti.get(base, 0) + 1
        if visti[base] > 1:
            v['nome'] = '%s %s' % (base, 'I' * visti[base])

    righe = [
        "// GENERATO da tool/genera_angeli.py dal Corpus in docs/corpus/angeli.md.",
        "// Non si modifica a mano: si rigenera.",
        "//",
        "// La politica di pubblicazione del Corpus e' applicata qui, alla",
        "// sorgente: guarigione e salute in ogni forma, promesse di esito, nomi",
        "// delle entita' avverse, corrispondenze goetiche, nomi alternativi e",
        "// finestre di calendario NON entrano in questo file, quindi non possono",
        "// arrivare a schermo per distrazione. Una frase che contenesse un termine",
        "// vietato viene tolta intera, non ripulita: correggerla a macchina",
        "// vorrebbe dire riscrivere una fonte.",
        "library;",
        "",
        "/// Il contenuto di un angelo, per come il Corpus lo documenta.",
        "class AngelLore {",
        "  const AngelLore({",
        "    required this.number,",
        "    required this.name,",
        "    required this.degrees,",
        "    required this.sign,",
        "    required this.psalm,",
        "    required this.tradition,",
        "    required this.reading,",
        "    required this.confidence,",
        "  });",
        "",
        "  final int number;",
        "",
        "  /// Il nome principale come lo attesta il Corpus. Puo' non coincidere",
        "  /// con lo stem dell'immagine, che segue una grafia diversa della stessa",
        "  /// tradizione: Ieliel e Jeliel sono lo stesso angelo. A schermo vale",
        "  /// questo, il file resta quello che e'.",
        "  final String name;",
        "",
        "  /// L'arco di cinque gradi che l'angelo governa, contato da zero Ariete.",
        "  final String degrees;",
        "",
        "  /// Il segno in cui cade quell'arco.",
        "  final String sign;",
        "",
        "  /// Il salmo con la numerazione dichiarata, che cambia fra le edizioni.",
        "  final String psalm;",
        "",
        "  /// Il dominio secondo la tradizione, dalle fonti.",
        "  final String tradition;",
        "",
        "  /// La chiave di lettura, scritta in redazione: e' voce del Maestro, non",
        "  /// tradizione documentata, e a schermo va tenuta distinta dalle fonti.",
        "  final String reading;",
        "",
        "  /// Quanto la fonte regge, dichiarato dal ricercatore. Dove e' bassa si",
        "  /// mostra meno invece di mostrare male.",
        "  final String confidence;",
        "",
        "  bool get confidenzaBassa => confidence.toLowerCase().contains('bassa');",
        "}",
        "",
        "/// Il contenuto dei settantadue, per numero d'ordine.",
        "const Map<int, AngelLore> kAngelLore = {",
    ]
    for v in voci:
        righe.append('  %d: AngelLore(' % v['n'])
        righe.append('    number: %d,' % v['n'])
        righe.append('    name: %s,' % dart_stringa(v['nome']))
        righe.append('    degrees: %s,' % dart_stringa(v['gradi']))
        righe.append('    sign: %s,' % dart_stringa(v['segno']))
        righe.append('    psalm: %s,' % dart_stringa(v['salmo']))
        righe.append('    tradition: %s,' % dart_stringa(v['dominio']))
        righe.append('    reading: %s,' % dart_stringa(v['chiave']))
        righe.append('    confidence: %s,' % dart_stringa(v['confidenza']))
        righe.append('  ),')
    righe.append('};')
    righe.append('')

    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(
        '\n'.join(righe))

    print('angeli letti: %d' % len(voci))
    print('frasi tolte per la politica: %d' % tolte_totali)
    print('angeli senza salmo pubblicabile: %d' % senza_salmo)
    nomi = [v['nome'] for v in voci]
    print('nomi distinti: %d' % len(set(nomi)))
    senza_gradi = [v['n'] for v in voci if not v['gradi']]
    senza_segno = [v['n'] for v in voci if not v['segno']]
    print('senza arco: %s' % (senza_gradi or 'nessuno'))
    print('senza segno: %s' % (senza_segno or 'nessuno'))


if __name__ == '__main__':
    main()
