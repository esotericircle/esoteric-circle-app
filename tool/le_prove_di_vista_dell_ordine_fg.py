"""LE PROVE DI VISTA DELL'ORDINE FG, parte 8.

Per ogni guardia della parte 7: si rimette il difetto nel codice, si verifica
che l'iniezione sia ENTRATA (il pezzo nuovo c'e', o il file tolto non c'e'),
si lancia la guardia, si legge l'esito e la riga che la guardia nomina, poi si
ripristinano i byte originali e si verifica il ripristino. Il registro va in
docs/collaudo/FG/prove_di_vista.txt.

    PYTHONIOENCODING=utf-8 python tool/le_prove_di_vista_dell_ordine_fg.py

Non usa mai git checkout: ripristina dalla copia in memoria dei byte.
"""

import datetime
import os
import re
import shutil
import subprocess
import sys

REGISTRO = 'docs/collaudo/FG/prove_di_vista.txt'

PITTORE = 'lib/features/real_time_cosmo/pittore_del_cielo.dart'
SCENA = 'lib/features/real_time_cosmo/la_scena_del_cielo.dart'
SCHERMATA = 'lib/features/real_time_cosmo/cielo_reale_screen.dart'
CATALOGO = 'lib/core/astro/real_time_cosmo/catalogo_delle_stelle.dart'

ANCORA_PAINT = '    canvas.drawRect(Offset.zero & size, _fondo);\n'

PROVE = [
    {
        'voce': '7.1 a, il cielo si dipinge una volta (MaskFilter nel fotogramma)',
        'guardia': 'test/real_time_cosmo_il_cielo_si_dipinge_una_volta_test.dart',
        'file': PITTORE,
        'vecchio': ANCORA_PAINT,
        'nuovo': ANCORA_PAINT + '    canvas.drawCircle(Offset.zero, 1, Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));\n',
    },
    {
        'voce': '7.1 b, gli strati pesanti esistono nella cache (Luna senza toImageSync)',
        'guardia': 'test/real_time_cosmo_il_cielo_si_dipinge_una_volta_test.dart',
        'file': SCHERMATA,
        'vecchio': '    _fotogramma.luna = registratore.endRecording().toImageSync(px, px);\n',
        'nuovo': '    _fotogramma.luna = null; registratore.endRecording();\n',
    },
    {
        'voce': '7.2, nessuna seconda porta sull\'astronomia',
        'guardia': 'test/real_time_cosmo_nessuna_seconda_porta_sull_astronomia_test.dart',
        'file': SCENA,
        'vecchio': 'const double kMargineDelQuadro = 24;\n',
        'nuovo': 'const double kMargineDelQuadro = 24;\n\ndouble altezzaFatta(double dec, double lat) => math.sin(dec) * math.sin(lat);\n',
    },
    {
        'voce': '7.3, il catalogo e\' letto e non inventato (ascensione retta spostata di 0,01 gradi)',
        'guardia': 'test/real_time_cosmo_il_catalogo_e_letto_non_inventato_test.dart',
        'file': CATALOGO,
        'vecchio': '      ra[i] = binario.getUint32(o, Endian.little) / 1000.0;\n',
        'nuovo': '      ra[i] = binario.getUint32(o, Endian.little) / 1000.0 + 0.01;\n',
    },
    {
        'voce': '7.4, il velo non si disegna senza il suo asset (velo del Toro tolto)',
        'guardia': 'test/real_time_cosmo_il_velo_ha_il_suo_asset_test.dart',
        'togli': 'assets/img/zodiac_velo/velo_toro.webp',
    },
    {
        'voce': '7.5, nessuna linea di asterismo (drawLine nel pittore)',
        'guardia': 'test/real_time_cosmo_nessuna_linea_di_asterismo_test.dart',
        'file': PITTORE,
        'vecchio': ANCORA_PAINT,
        'nuovo': ANCORA_PAINT + '    canvas.drawLine(Offset.zero, const Offset(1, 1), _anello);\n',
    },
    {
        'voce': '7.6, i due cataloghi non si incrociano (il Real Time Cosmo legge bright_stars.json)',
        'guardia': 'test/real_time_cosmo_i_due_cataloghi_non_si_incrociano_test.dart',
        'file': SCHERMATA,
        'vecchio': "  DateTime get _adesso => (widget.orologio ?? DateTime.now)();\n",
        'nuovo': "  DateTime get _adesso => (widget.orologio ?? DateTime.now)();\n  static const String _vecchio = 'assets/data/bright_stars.json';\n",
    },
    {
        'voce': '7.8, si ferma fuori scena (la bussola non si spegne)',
        'guardia': 'test/real_time_cosmo_si_ferma_fuori_scena_test.dart',
        'file': SCHERMATA,
        'vecchio': '      if (_ticker.isActive) _ticker.stop();\n      _telefono?.spegni();\n',
        'nuovo': '      if (_ticker.isActive) _ticker.stop();\n',
    },
]


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
    registro = [f"LE PROVE DI VISTA DELL'ORDINE FG, {datetime.datetime.now():%d/%m/%Y %H:%M}", '']
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
            testo = originale.decode('utf-8')
            if testo.count(p['vecchio']) != 1:
                registro.append(f"ANCORA NON TROVATA in {percorso}: la prova non si fa")
                tutte_cadute = False
                continue
            iniettato = testo.replace(p['vecchio'], p['nuovo'])
            open(percorso, 'wb').write(iniettato.encode('utf-8'))
            riletto = open(percorso, 'rb').read().decode('utf-8')
            entrata = riletto == iniettato and riletto != testo
            registro.append(f"iniezione in {percorso}; entrata: {'si' if entrata else 'NO'}")
            try:
                caduta, righe = lancia(p['guardia'])
            finally:
                open(percorso, 'wb').write(originale)
            ripristinato = open(percorso, 'rb').read() == originale
        registro.append(f"guardia {p['guardia']}: {'CADUTA' if caduta else 'RESTATA VERDE'}")
        for r in righe:
            registro.append(f"   {r}")
        registro.append(f"ripristino verificato al byte: {'si' if ripristinato else 'NO'}")
        registro.append('')
        tutte_cadute = tutte_cadute and caduta and entrata and ripristinato
        print('\n'.join(registro[-(len(righe) + 4):]))
    registro.append('ESITO: ' + ('ogni iniezione e\' entrata, ogni guardia e\' caduta, ogni file e\' ripristinato'
                                 if tutte_cadute else 'QUALCOSA NON TORNA, leggere sopra'))
    os.makedirs(os.path.dirname(REGISTRO), exist_ok=True)
    with open(REGISTRO, 'w', encoding='utf-8', newline='') as f:
        f.write('\n'.join(registro) + '\n')
    print(registro[-1])
    return 0 if tutte_cadute else 1


if __name__ == '__main__':
    sys.exit(main())
