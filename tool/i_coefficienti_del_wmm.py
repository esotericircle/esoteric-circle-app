"""I COEFFICIENTI DEL WORLD MAGNETIC MODEL 2025, ordine FG parte 2 (voce 2.9).

Dal file WMM.COF della NOAA NCEI (https://www.ncei.noaa.gov/products/
world-magnetic-model/wmm-coefficients, archivio WMM2025COF.zip) scrive
lib/core/astro/real_time_cosmo/coefficienti_wmm2025.dart, la tabella che usa
la declinazione magnetica del Real Time Cosmo.

Il WMM e' materiale del governo degli Stati Uniti, in pubblico dominio
("not licensed or under copyright", pagina dei coefficienti della NOAA); la
nota di 17 U.S.C. 403 sta nel file generato e nel pannello Fonti e metodo.

    python tool/i_coefficienti_del_wmm.py <percorso>/WMM.COF
    python tool/i_coefficienti_del_wmm.py <percorso>/WMM.COF --verifica
"""

import hashlib
import sys

IMPRONTA = 'dfa8597825af4e0b87ff4198a5b4fb661b3c49f4cd090cd0164e0259b075582f'
USCITA = 'lib/core/astro/real_time_cosmo/coefficienti_wmm2025.dart'


def genera(percorso):
    grezzo = open(percorso, 'rb').read()
    impronta = hashlib.sha256(grezzo).hexdigest()
    righe = grezzo.decode('ascii').splitlines()
    testa = righe[0].split()
    epoca = float(testa[0])
    modello = testa[1]
    coeff = []
    for r in righe[1:]:
        p = r.split()
        if not p or p[0].startswith('9999'):
            break
        n, m = int(p[0]), int(p[1])
        g, h, gd, hd = (float(x) for x in p[2:6])
        coeff.append((n, m, g, h, gd, hd))
    corpo = ['// GENERATO da tool/i_coefficienti_del_wmm.py: non si modifica a mano.',
             '//',
             f'// {modello}, epoca {epoca}, dal file WMM.COF della NOAA NCEI',
             f'// (sha256 {impronta}).',
             '// Il World Magnetic Model e\' prodotto dalla NOAA NCEI e dal British',
             '// Geological Survey: materiale del governo degli Stati Uniti incorporato',
             '// in quest\'opera, non soggetto a protezione del diritto d\'autore',
             '// (17 U.S.C. 403).',
             '',
             f'const double kEpocaWmm = {epoca};',
             '',
             '/// Una riga per coefficiente: n, m, g, h, g punto, h punto (nT e nT',
             '/// all\'anno).',
             'const List<List<double>> kCoefficientiWmm = [']
    for n, m, g, h, gd, hd in coeff:
        corpo.append(f'  [{n}, {m}, {g}, {h}, {gd}, {hd}],')
    corpo.append('];')
    return '\n'.join(corpo) + '\n', impronta, len(coeff)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    testo, impronta, quanti = genera(argv[1])
    print(f'coefficienti: {quanti}, impronta: {impronta}')
    if impronta != IMPRONTA:
        print('ATTENZIONE: WMM.COF diverso da quello del repository.')
    if '--verifica' in argv[2:]:
        with open(USCITA, encoding='utf-8', newline='') as f:
            if f.read() != testo:
                print('DIVERSO')
                return 1
        print('identico')
        return 0
    with open(USCITA, 'w', encoding='utf-8', newline='') as f:
        f.write(testo)
    print(f'scritto {USCITA}')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
