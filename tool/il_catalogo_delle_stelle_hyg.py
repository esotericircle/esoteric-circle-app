"""IL CATALOGO DELLE STELLE DEL REAL TIME COSMO, ordine FG parte 1.

Dal CSV del catalogo HYG v4.1 di astronexus (licenza CC BY-SA 4.0,
https://github.com/astronexus/HYG-Database, file hyg/CURRENT/hygdata_v41.csv)
produce i file di dati derivati in assets/astro/:

- stelle_hyg_v41.bin: intestazione piu' dodici byte per stella (ra e dec in
  millesimi di grado, mag e ci in centesimi; ci = -32768 se il catalogo non ha
  l'indice di colore). Le stelle sono ordinate per magnitudine crescente, a
  parita' per id del catalogo: l'indice di una stella nel binario e' la sua
  posizione in quest'ordine.
- stelle_hyg_v41_nomi.json: per le sole stelle col nome proprio (campo
  proper), l'indice nel binario e il nome.
- stelle_hyg_v41_costellazioni.json: per ogni costellazione IAU (campo con)
  gli indici delle sue stelle, gia' in ordine di magnitudine crescente; e la
  sigla di Bayer o di Flamsteed per chi ce l'ha ("α Leo", "88 Aqr"). Il
  record da dodici byte e' quello fissato dall'ordine (voce 1.4) e non
  cambia: la costellazione vive qui accanto perche' serve al velo (voce 4.4)
  e alla scheda del tocco.
- LICENZA_HYG_v41.txt: la licenza e l'attribuzione del file derivato.

Il CSV di partenza NON entra nel repository. Si scarica a mano e si passa
come argomento:

    python tool/il_catalogo_delle_stelle_hyg.py <percorso>/hygdata_v41.csv
    python tool/il_catalogo_delle_stelle_hyg.py <percorso>/hygdata_v41.csv --verifica

Con --verifica non scrive niente: rifa' i file in memoria e li confronta al
byte con quelli in assets/astro/, cosi' si prova che il generatore li rifa'
identici.

Il Sole sta nel CSV come riga 0 (proper "Sol", magnitudine -26,7) e NON entra
nel catalogo delle stelle fisse: il Sole lo calcola IlCieloDiMeeus. Per questo
al taglio 6,0 le righe del CSV sono 5.071 e le stelle del binario 5.070.

In HYG l'ascensione retta e' in ORE: qui si moltiplica per 15.
"""

import csv
import hashlib
import json
import os
import struct
import sys

# L'impronta del CSV da cui sono stati cotti i file del repository, misurata
# l'8 ottobre 2026 sul file scaricato da raw.githubusercontent.com (ramo main).
# Un CSV diverso non e' un errore: e' un catalogo nuovo, e il generatore lo
# dice invece di cuocerlo in silenzio.
IMPRONTA_DEL_CSV = (
    'd9f69fd86bbf90a4e4d52b4c5c53eacfa6dfc0bfdef85bfd94f095e0bebe4ebd')

FIRMA = b'ECHY'
VERSIONE = 1
TAGLIO_MAG = 6.0
# L'epoca delle coordinate, J2000.0, come giorno giuliano.
EPOCA_JD = 2451545.0
CI_ASSENTE = -32768
# Intestazione: firma (4), versione (u16), riserva (u16), numero di stelle
# (u32), taglio in centesimi (i16), riserva (i16), epoca come giorno giuliano
# (f64). Ventiquattro byte, little endian come il record.
FORMATO_INTESTAZIONE = '<4sHHIhhd'
FORMATO_STELLA = '<Iihh'

CARTELLA = os.path.join('assets', 'astro')
BINARIO = 'stelle_hyg_v41.bin'
NOMI = 'stelle_hyg_v41_nomi.json'
COSTELLAZIONI = 'stelle_hyg_v41_costellazioni.json'
LICENZA = 'LICENZA_HYG_v41.txt'

GRECHE = {
    'Alp': 'α', 'Bet': 'β', 'Gam': 'γ', 'Del': 'δ', 'Eps': 'ε',
    'Zet': 'ζ', 'Eta': 'η', 'The': 'θ', 'Iot': 'ι', 'Kap': 'κ',
    'Lam': 'λ', 'Mu': 'μ', 'Nu': 'ν', 'Xi': 'ξ', 'Omi': 'ο',
    'Pi': 'π', 'Rho': 'ρ', 'Sig': 'σ', 'Tau': 'τ', 'Ups': 'υ',
    'Phi': 'φ', 'Chi': 'χ', 'Psi': 'ψ', 'Ome': 'ω',
}
APICI = {'1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵',
         '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'}

TESTO_DELLA_LICENZA = """\
Catalogo delle stelle del Real Time Cosmo di Esoteric Circle

I file stelle_hyg_v41.bin, stelle_hyg_v41_nomi.json e
stelle_hyg_v41_costellazioni.json di questa cartella sono un'opera derivata
dal catalogo HYG v4.1 (Hipparcos, Yale Bright Star, Gliese) di astronexus,
https://github.com/astronexus/HYG-Database, file hyg/CURRENT/hygdata_v41.csv.

Il catalogo HYG v4.1 e' distribuito sotto licenza Creative Commons
Attribution-ShareAlike 4.0 International (CC BY-SA 4.0),
http://creativecommons.org/licenses/by-sa/4.0/

Questi file derivati sono distribuiti sotto la stessa licenza, CC BY-SA 4.0.

Modifiche rispetto all'originale: tenute le sole stelle fino alla magnitudine
6,0 compresa, tolto il Sole; ascensione retta convertita da ore a gradi;
ascensione retta e declinazione arrotondate al millesimo di grado, magnitudine
e indice di colore al centesimo; stelle ordinate per magnitudine crescente;
tenuti i soli campi ra, dec, mag, ci, proper, bayer, flam e con.

La licenza riguarda questi file di dati e non il codice dell'applicazione.
Il generatore e' tool/il_catalogo_delle_stelle_hyg.py.
"""


def _numero(testo):
    testo = (testo or '').strip()
    return float(testo) if testo else None


def _sigla(riga):
    bayer = riga['bayer'].strip()
    con = riga['con'].strip()
    if bayer:
        lettera, _, numero = bayer.partition('-')
        greca = GRECHE.get(lettera)
        if greca is None:
            raise ValueError(f'lettera di Bayer sconosciuta: {bayer!r}')
        apice = ''.join(APICI[c] for c in numero) if numero else ''
        return f'{greca}{apice} {con}'
    flam = riga['flam'].strip()
    if flam:
        return f'{flam} {con}'
    return None


def cuoci(percorso_csv):
    with open(percorso_csv, 'rb') as f:
        grezzo = f.read()
    impronta = hashlib.sha256(grezzo).hexdigest()
    with open(percorso_csv, encoding='utf-8', newline='') as f:
        righe = list(csv.DictReader(f))

    scelte = []
    for r in righe:
        mag = _numero(r['mag'])
        if mag is None or mag > TAGLIO_MAG:
            continue
        if r['proper'].strip() == 'Sol':
            continue
        scelte.append(r)
    scelte.sort(key=lambda r: (float(r['mag']), int(r['id'])))

    binario = bytearray(struct.pack(
        FORMATO_INTESTAZIONE, FIRMA, VERSIONE, 0, len(scelte),
        round(TAGLIO_MAG * 100), 0, EPOCA_JD))
    nomi = []
    costellazioni = {}
    sigle = {}
    for i, r in enumerate(scelte):
        ra = round(float(r['ra']) * 15 * 1000) % 360000
        dec = round(float(r['dec']) * 1000)
        mag = round(float(r['mag']) * 100)
        ci_valore = _numero(r['ci'])
        ci = CI_ASSENTE if ci_valore is None else round(ci_valore * 100)
        binario += struct.pack(FORMATO_STELLA, ra, dec, mag, ci)
        if r['proper'].strip():
            nomi.append({'i': i, 'nome': r['proper'].strip()})
        con = r['con'].strip()
        if con:
            costellazioni.setdefault(con, []).append(i)
        sigla = _sigla(r)
        if sigla:
            sigle[str(i)] = sigla

    def _json(dati):
        # Compatto: sono dati per la macchina, e l'indentazione triplicava
        # il peso del file delle costellazioni.
        return (json.dumps(dati, ensure_ascii=False,
                           separators=(',', ':')) + '\n').encode('utf-8')

    file = {
        BINARIO: bytes(binario),
        NOMI: _json({
            'fonte': 'HYG v4.1, astronexus, CC BY-SA 4.0',
            'stelle': len(scelte),
            'nomi': nomi,
        }),
        COSTELLAZIONI: _json({
            'fonte': 'HYG v4.1, astronexus, CC BY-SA 4.0',
            'stelle': len(scelte),
            'costellazioni': {k: costellazioni[k]
                              for k in sorted(costellazioni)},
            'sigle': sigle,
        }),
        LICENZA: TESTO_DELLA_LICENZA.encode('utf-8'),
    }
    misure = {
        'righe_del_csv': len(righe),
        'righe_al_taglio_col_sole': len(scelte) + 1,
        'stelle': len(scelte),
        'byte_del_binario': len(binario),
        'nomi_propri_nel_catalogo': sum(1 for r in righe
                                        if r['proper'].strip()),
        'nomi_propri_al_taglio': len(nomi),
        'senza_indice_di_colore': sum(1 for r in scelte
                                      if _numero(r['ci']) is None),
        'costellazioni': len(costellazioni),
        'sigle': len(sigle),
        'impronta_del_csv': impronta,
    }
    return file, misure


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    verifica = '--verifica' in argv[2:]
    file, misure = cuoci(argv[1])
    for chiave, valore in misure.items():
        print(f'{chiave}: {valore}')
    if misure['impronta_del_csv'] != IMPRONTA_DEL_CSV:
        print('ATTENZIONE: il CSV non e\' quello da cui sono cotti i file '
              'del repository (impronta diversa).')
    if verifica:
        diversi = []
        for nome, contenuto in file.items():
            percorso = os.path.join(CARTELLA, nome)
            if not os.path.exists(percorso):
                diversi.append(f'{nome} (manca)')
                continue
            with open(percorso, 'rb') as f:
                if f.read() != contenuto:
                    diversi.append(nome)
        if diversi:
            print('DIVERSI: ' + ', '.join(diversi))
            return 1
        print(f'identici al byte: {len(file)} file su {len(file)}')
        return 0
    os.makedirs(CARTELLA, exist_ok=True)
    for nome, contenuto in file.items():
        with open(os.path.join(CARTELLA, nome), 'wb') as f:
            f.write(contenuto)
    print(f'scritti {len(file)} file in {CARTELLA}')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
