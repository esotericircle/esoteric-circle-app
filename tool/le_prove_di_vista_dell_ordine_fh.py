"""LE PROVE DI VISTA DELL'ORDINE FH, voce 15.9, piu' l'aggiunta della Macchina del tempo.

Per ognuna delle otto guardie della parte 15, e per un_solo_tempo
dell'aggiunta: si rimette il difetto nel codice, si verifica che l'iniezione
sia ENTRATA (il pezzo nuovo c'e', o il file tolto non c'e'), si lancia la
guardia, si legge l'esito e la riga che nomina, poi si ripristinano i byte
originali e si verifica il ripristino. Il registro va in
docs/collaudo/FH/prove_di_vista.txt. E' la forma di
tool/le_prove_di_vista_dell_ordine_fg.py.

    PYTHONIOENCODING=utf-8 python tool/le_prove_di_vista_dell_ordine_fh.py

Non usa mai git checkout: ripristina dalla copia in memoria dei byte.
"""

import datetime
import os
import re
import shutil
import subprocess
import sys

REGISTRO = 'docs/collaudo/FH/prove_di_vista.txt'

VELO = 'lib/features/real_time_cosmo/il_velo_delle_costellazioni.dart'
VIA_LATTEA = 'lib/features/real_time_cosmo/la_via_lattea_in_scena.dart'
LINEE = 'lib/features/real_time_cosmo/le_linee_in_scena.dart'
FIGURE = 'lib/core/astro/real_time_cosmo/le_linee_delle_figure.dart'
PROFONDO = 'lib/features/real_time_cosmo/il_cielo_profondo_in_scena.dart'
SCHERMATA = 'lib/features/real_time_cosmo/cielo_reale_screen.dart'

A_CAPO = chr(10)

PROVE = [
    {
        'voce': "15.1, il velo e' sempre uno solo (il velo nuovo si accende col vecchio ancora acceso)",
        'guardia': 'test/real_time_cosmo_un_velo_solo_test.dart',
        'file': VELO,
        'vecchio': '  if (scelto != null && !altroAcceso) {' + A_CAPO,
        'nuovo': '  if (scelto != null) {' + A_CAPO,
    },
    {
        'voce': '15.2, il cielo si dipinge una volta (una lista nuova nella maglia della Via Lattea)',
        'guardia': 'test/real_time_cosmo_il_cielo_si_dipinge_una_volta_test.dart',
        'file': VIA_LATTEA,
        'vecchio': '    var quanti = 0;' + A_CAPO,
        'nuovo': '    var quanti = 0;' + A_CAPO
        + '    final innesto = List.filled(2, 0);' + A_CAPO
        + '    quanti += innesto.length - 2;' + A_CAPO,
    },
    {
        'voce': "15.3, nessuna linea inventata (l'ultima coppia del file non si disegna)",
        'guardia': 'test/real_time_cosmo_nessuna_linea_inventata_test.dart',
        'file': LINEE,
        'vecchio': '    for (var k = 0; k < linee.numeroDiLinee; k++) {' + A_CAPO,
        'nuovo': '    for (var k = 0; k < linee.numeroDiLinee - 1; k++) {' + A_CAPO,
    },
    {
        'voce': '15.4, il peso segue il dato (la forza rovesciata)',
        'guardia': 'test/real_time_cosmo_il_peso_segue_il_dato_test.dart',
        'file': FIGURE,
        'vecchio': 'math.sqrt(conto / math.max(1, contoPiuRicco))',
        'nuovo': 'math.sqrt((contoPiuRicco - conto + 1) / math.max(1, contoPiuRicco))',
    },
    {
        'voce': '15.5, ogni asset ha il suo file (tolta la Laguna)',
        'guardia': 'test/real_time_cosmo_ogni_asset_ha_il_suo_file_test.dart',
        'togli': 'assets/img/cosmo/laguna.webp',
    },
    {
        'voce': '15.6, le schede non vengono dal modello (il file della scena nomina gemini)',
        'guardia': 'test/real_time_cosmo_le_schede_non_vengono_dal_modello_test.dart',
        'file': PROFONDO,
        'vecchio': 'library;' + A_CAPO,
        'nuovo': 'library;' + A_CAPO + A_CAPO + '// gemini' + A_CAPO,
    },
    {
        'voce': '15.7, i due cataloghi restano separati (il Real Time Cosmo legge bright_stars.json)',
        'guardia': 'test/real_time_cosmo_i_due_cataloghi_non_si_incrociano_test.dart',
        'file': SCHERMATA,
        'vecchio': '  DateTime get _adesso => _tempo.adesso();' + A_CAPO,
        'nuovo': '  DateTime get _adesso => _tempo.adesso();' + A_CAPO
        + "  static const String _vecchio = 'assets/data/bright_stars.json';" + A_CAPO,
    },
    {
        'voce': "15.8, il Sole porta il suo avviso (l'avviso tolto)",
        'guardia': 'test/real_time_cosmo_il_sole_porta_il_suo_avviso_test.dart',
        'file': SCHERMATA,
        'vecchio': '      avviso: soleSopra ? kAvvisoDelSole : null,' + A_CAPO,
        'nuovo': '      avviso: null,' + A_CAPO,
    },
    {
        'voce': 'aggiunta C2, un solo tempo (DateTime.now nella scena del cielo profondo)',
        'guardia': 'test/un_solo_tempo_test.dart',
        'file': PROFONDO,
        'vecchio': 'library;' + A_CAPO,
        'nuovo': 'library;' + A_CAPO + A_CAPO + 'final _orologioPerso = DateTime.now;' + A_CAPO,
    },
]


def scrivi(percorso, dati):
    """Scrive i byte, e riprova finche' Windows non scioglie il blocco sul
    file (errno 22 o 1224, mentre un altro processo lo tiene mappato): il
    primo giro e' caduto proprio sul ripristino."""
    import time
    for prova in range(40):
        try:
            with open(percorso, 'wb') as f:
                f.write(dati)
            return
        except OSError:
            time.sleep(0.5)
    raise OSError('non riesco a scrivere ' + percorso)


def lancia(guardia):
    r = subprocess.run(
        ['flutter', 'test', '-r', 'expanded', guardia],
        capture_output=True, text=True, encoding='utf-8', errors='replace',
        shell=(os.name == 'nt'))
    uscita = r.stdout + r.stderr
    caduta = r.returncode != 0
    righe = [l.strip() for l in uscita.splitlines()
             if re.search(r"riga \d+|Expected|Actual|reason|manca|non c'e'", l)]
    return caduta, righe[:6]


def main():
    registro = [f"LE PROVE DI VISTA DELL'ORDINE FH, {datetime.datetime.now():%d/%m/%Y %H:%M}", '']
    tutte_cadute = True
    for p in PROVE:
        registro.append(f"== {p['voce']}")
        if 'togli' in p:
            percorso = p['togli']
            copia = percorso + '.prova_di_vista'
            shutil.move(percorso, copia)
            entrata = not os.path.exists(percorso)
            registro.append(f"iniezione: tolto {percorso}; entrata: {'si' if entrata else 'NO'}")
            try:
                caduta, righe = lancia(p['guardia'])
            finally:
                shutil.move(copia, percorso)
            ripristinato = os.path.exists(percorso)
        else:
            percorso = p['file']
            originale = open(percorso, 'rb').read()
            testo = originale.decode('utf-8').replace(chr(13) + chr(10), chr(10))
            if testo.count(p['vecchio']) != 1:
                registro.append(f"ANCORA NON TROVATA in {percorso}: la prova non si fa")
                tutte_cadute = False
                continue
            iniettato = testo.replace(p['vecchio'], p['nuovo'])
            scrivi(percorso, iniettato.encode('utf-8'))
            riletto = open(percorso, 'rb').read().decode('utf-8')
            entrata = riletto == iniettato and p['nuovo'] in riletto
            registro.append(f"iniezione in {percorso}; entrata: {'si' if entrata else 'NO'}")
            try:
                caduta, righe = lancia(p['guardia'])
            finally:
                scrivi(percorso, originale)
            ripristinato = open(percorso, 'rb').read() == originale
        registro.append(f"guardia {p['guardia']}: {'CADUTA' if caduta else 'RESTATA VERDE'}")
        for r in righe:
            registro.append(f"   {r}")
        registro.append(f"ripristino verificato al byte: {'si' if ripristinato else 'NO'}")
        registro.append('')
        tutte_cadute = tutte_cadute and caduta and entrata and ripristinato
        print('\n'.join(registro[-(len(righe) + 4):]))
    registro.append('ESITO: ' + ("ogni iniezione e' entrata, ogni guardia e' caduta, ogni file e' ripristinato"
                                 if tutte_cadute else 'QUALCOSA NON TORNA, leggere sopra'))
    os.makedirs(os.path.dirname(REGISTRO), exist_ok=True)
    with open(REGISTRO, 'w', encoding='utf-8', newline='') as f:
        f.write('\n'.join(registro) + '\n')
    print(registro[-1])
    return 0 if tutte_cadute else 1


if __name__ == '__main__':
    sys.exit(main())
