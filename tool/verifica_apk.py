# -*- coding: utf-8 -*-
"""Controllo di integrita' dell'APK costruito.

Il 27 luglio un APK e' partito verso il telefono privo delle settantanove
immagini dei tarocchi, con la suite verde e analyze pulito, e nessuno se ne e'
accorto fino a quando non si e' misurato il peso. Il lucchetto che esisteva
confronta il pubspec col manifest, cioe' due dichiarazioni fra loro: nessuno dei
due guarda dentro l'archivio che finisce sul telefono.

Questo controllo apre l'APK e conta i file davvero presenti in ogni famiglia,
confrontandoli col manifest `docs/stato_asset.json`. Se una famiglia manca o e'
incompleta, esce con codice 1 e dice quale.

Uso:
  python tool/verifica_apk.py build/app/outputs/flutter-apk/app-debug.apk
"""

import io
import json
import os
import sys
import zipfile

PREFISSO = 'assets/flutter_assets/'


def conta_famiglie(apk_path):
    """Quanti file ha ogni famiglia dentro l'archivio, piena e miniatura."""
    piene = {}
    miniature = {}
    with zipfile.ZipFile(apk_path) as z:
        for nome in z.namelist():
            if not nome.startswith(PREFISSO):
                continue
            resto = nome[len(PREFISSO):]
            for radice, dove in (('assets/img/', piene),
                                 ('assets/img_thumb/', miniature)):
                if resto.startswith(radice):
                    coda = resto[len(radice):]
                    if '/' not in coda:
                        continue
                    famiglia = coda.split('/')[0]
                    dove[famiglia] = dove.get(famiglia, 0) + 1
    return piene, miniature


def main():
    if len(sys.argv) < 2:
        print('uso: python tool/verifica_apk.py <percorso apk>')
        return 2
    apk = sys.argv[1]
    if not os.path.exists(apk):
        print('APK non trovato: %s' % apk)
        return 1

    with io.open('docs/stato_asset.json', encoding='utf-8') as f:
        manifest = json.load(f)
    attesi = manifest['bundle_versionato']['famiglie_conteggi']

    piene, miniature = conta_famiglie(apk)
    problemi = []
    print('Famiglia            attesi   piene   miniature')
    for famiglia in sorted(attesi):
        n = attesi[famiglia]
        p = piene.get(famiglia, 0)
        m = miniature.get(famiglia, 0)
        print('%-18s %6d  %6d  %10d' % (famiglia, n, p, m))
        if p != n:
            problemi.append(
                'la famiglia %s ha %d file pieni nell\'APK invece di %d'
                % (famiglia, p, n))
        if m != n:
            problemi.append(
                'la famiglia %s ha %d miniature nell\'APK invece di %d'
                % (famiglia, m, n))

    # I RETRI DELLE RUNE, che non sono una famiglia a due misure.
    #
    # Stanno in una cartella sola, senza miniatura, perche' si vedono coperti o
    # in volo e mai a fuoco: il conteggio a due colonne qui non ha senso, ma il
    # controllo che ci siano tutti si', altrimenti l'app mostrerebbe il sasso
    # dipinto al posto della pietra vera senza che nessuno se ne accorga.
    retri = piene.get('rune_bone_vergine', 0)
    attesiRetri = attesi.get('rune_bone', 0)
    print('%-18s %6d  %6d  %10s'
          % ('rune_bone_vergine', attesiRetri, retri, 'nessuna'))
    if retri != attesiRetri:
        problemi.append('i retri delle rune sono %d nell APK invece di %d'
                        % (retri, attesiRetri))

    peso = os.path.getsize(apk)
    print('\nPeso APK: %d byte (%.2f MiB)' % (peso, peso / 1048576.0))

    if problemi:
        print('\nINTEGRITA\' VIOLATA:')
        for p in problemi:
            print('  - %s' % p)
        return 1
    print('\nIntegrita\' verificata: ogni famiglia dichiarata e\' dentro '
          'l\'archivio col conteggio giusto.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
