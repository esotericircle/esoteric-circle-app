# -*- coding: utf-8 -*-
"""Il testo dei PDF dell'anno, ordine EU voce 12, 1 ottobre 2026.

Estrae il testo di ogni PDF di docs/collaudo/EU/pdf/ in un .txt accanto,
pagina per pagina, e scrive in titoli.txt l'elenco delle schede di ogni
documento: l'etichetta (la riga tutta maiuscola, fuori da "DA DOVE VIENE"),
il titolo che la segue, la pagina, quante volte il titolo compare e se sotto
ha del testo sulla stessa pagina. In fondo i conti: titoli ripetuti, titoli
senza testo, segnalibri (l'indice del documento).
Uso: python tool/il_testo_dei_pdf.py
"""
import io
import os
import sys

from pypdf import PdfReader

CARTELLA = os.path.join('docs', 'collaudo', 'EU', 'pdf')


def etichetta(riga):
    return riga.isupper() and riga != 'DA DOVE VIENE' and len(riga) < 30


def main():
    elenco = sorted(f for f in os.listdir(CARTELLA) if f.endswith('.pdf'))
    if not elenco:
        print('nessun PDF in', CARTELLA)
        return 1
    rapporto = []
    for nome in elenco:
        lettore = PdfReader(os.path.join(CARTELLA, nome))
        pagine = [[r.strip() for r in (p.extract_text() or '').split('\n')
                   if r.strip()] for p in lettore.pages]
        with io.open(os.path.join(CARTELLA, nome[:-4] + '.txt'), 'w',
                     encoding='utf-8', newline='\n') as f:
            for n, righe in enumerate(pagine):
                f.write('===== PAGINA %d =====\n' % (n + 1))
                f.write('\n'.join(righe) + '\n')
        rapporto.append('%s: %d pagine, %d segnalibri' %
                        (nome, len(pagine), len(lettore.outline)))
        tutte = [r for righe in pagine for r in righe]
        ripetuti = senza_testo = 0
        for n, righe in enumerate(pagine):
            for i, riga in enumerate(righe):
                if not etichetta(riga):
                    continue
                titolo = righe[i + 1] if i + 1 < len(righe) else ''
                sotto = righe[i + 2] if i + 2 < len(righe) else ''
                volte = tutte.count(titolo) if titolo else 0
                if volte > 1:
                    ripetuti += 1
                if not titolo or not sotto:
                    senza_testo += 1
                rapporto.append(
                    '  pagina %d, %s: titolo "%s", compare %d volte, sotto: %s'
                    % (n + 1, riga, titolo or 'NESSUNO', volte,
                       (sotto[:50] + '...') if sotto else 'NIENTE'))
        rapporto.append('  titoli ripetuti %d, titoli senza testo %d' %
                        (ripetuti, senza_testo))
    with io.open(os.path.join(CARTELLA, 'titoli.txt'), 'w', encoding='utf-8',
                 newline='\n') as f:
        f.write('\n'.join(rapporto) + '\n')
    print('\n'.join(rapporto))
    return 0


if __name__ == '__main__':
    sys.exit(main())
