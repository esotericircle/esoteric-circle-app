# -*- coding: utf-8 -*-
"""APPLICA LE RISCRITTURE DEL CORPUS DELLE RUNE. Ordine GA voce GA.07,
20 ottobre 2026.

I campi di docs/corpus/rune/ (risposta, verdetto, pietra, legame, gesto e il
campo nuovo consiglio) si riscrivono nella forma della voce GA.03 da piu'
scrittori in parallelo, su gruppi disgiunti. Ognuno scrive le sue voci in un
file di parte nella stessa forma del corpus:

    ## Fehu, dritta
    3. <testo nuovo della voce 3>
    17.
    30. <voce nuova>

- "N. testo" con N gia' nel gruppo SOSTITUISCE la voce N (l'identificativo
  resta, cosi' la memoria dei 60 giorni resta giusta);
- "N." senza testo TOGLIE la voce N: il numero resta vuoto e non si riusa
  (SPECIFICA.md, sezione 3);
- "N. testo" con N oltre l'ultima voce AGGIUNGE una voce nuova: i numeri
  nuovi partono dal primo libero e si seguono senza buchi.

Lo strumento si ferma senza scrivere niente se un numero da sostituire non
c'e', se una voce tolta si riusa, se i numeri nuovi hanno buchi, o se il
controllo (tool/controlla_il_corpus_delle_rune.py, la stessa funzione del
comando --parte) trova un difetto nelle voci toccate: misura in parole con
ogni valore degli spazi, spazi permessi, paragrafo composto RISPOSTA +
VERDETTO, regole di lingua, voci e frasi uguali.

Sul modello di tool/applica_le_riscritture.py dell'Oroscopo.

    python tool/applica_le_riscritture_delle_rune.py <campo> <parte.md> [...]

Dopo: python tool/genera_corpus_del_presagio.py, che porta il corpus nel
codice. La cartella del corpus si cambia con CARTELLA_DEL_CORPUS (le prove su
una copia).
"""
import io
import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import controlla_il_corpus_delle_rune as controllo  # noqa: E402


def applica(campo, parti):
    difetti, parte, gruppi = controllo.controlla_le_parti(campo, parti,
                                                          stampa=False)
    if difetti:
        print(f'{campo}: {len(difetti)} difetti, NESSUNA voce scritta')
        for d in difetti:
            print('  ' + d)
        return 1
    percorso = controllo.CARTELLA / f'{campo}.md'
    testo = io.open(percorso, encoding='utf-8', newline='').read()
    a_capo = '\r\n' if '\r\n' in testo else '\n'
    righe = testo.split(a_capo)
    fuori = []
    g = None
    usati = set()
    sostituite = tolte = aggiunte = 0

    def chiudi_il_gruppo():
        # Le voci nuove del gruppo appena finito, dopo la sua ultima voce.
        nonlocal aggiunte
        if g is None or g not in parte:
            return
        nuove = sorted(n for n in parte[g] if n > len(gruppi.get(g, [])))
        if not nuove:
            return
        # Le righe vuote in coda al gruppo restano in coda.
        coda = []
        while fuori and fuori[-1].strip() == '':
            coda.append(fuori.pop())
        for n in nuove:
            fuori.append(f'{n}. {parte[g][n]}')
            aggiunte += 1
        fuori.extend(coda)

    for riga in righe:
        t = re.match(r'^## (.+)$', riga)
        if t:
            chiudi_il_gruppo()
            g = controllo.gruppo_da_titolo(campo, t.group(1))
            usati.add(g)
            fuori.append(riga)
            continue
        v = re.match(r'^(\d+)\.\s?(.*)$', riga)
        if v and g is not None and g in parte and int(v.group(1)) in parte[g]:
            n = int(v.group(1))
            nuovo = parte[g][n]
            if nuovo:
                fuori.append(f'{n}. {nuovo}')
                sostituite += 1
            else:
                fuori.append(f'{n}.')
                tolte += 1
            continue
        fuori.append(riga)
    chiudi_il_gruppo()
    mancanti = sorted(set(parte) - usati)
    if mancanti:
        print(f'{campo}: gruppi della parte che il corpus non ha: {mancanti}, '
              f'NESSUNA voce scritta')
        return 1
    io.open(percorso, 'w', encoding='utf-8', newline='').write(a_capo.join(fuori))
    print(f'{percorso}: {sostituite} voci sostituite, {aggiunte} aggiunte, '
          f'{tolte} tolte')
    print('adesso: python tool/controlla_il_corpus_delle_rune.py e '
          'python tool/genera_corpus_del_presagio.py')
    return 0


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    sys.exit(applica(sys.argv[1], sys.argv[2:]))
