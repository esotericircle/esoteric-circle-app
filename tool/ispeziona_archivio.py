# -*- coding: utf-8 -*-
"""L'ARCHIVIO CONTIENE CIO' CHE PROMETTE. Ordine CH voce 07.

**Il difetto che questo controllo esiste per prendere, e come e' stato
trovato.** La build 2216 e' stata consegnata senza `libflutter.so` e senza
`libapp.so` per ARM a 32 bit, mentre la cartella `lib/armeabi-v7a/` e' rimasta
dentro l'archivio con cinque librerie di plugin. Un'app Flutter senza il suo
motore non ha niente da avviare. **Quella build ha superato 4.175 prove e lo
sbarramento**, ed e' stata trovata dal fondatore che ha letto due pesi su App
Tester e ha chiesto come mai la build fosse dimagrita di venti megabyte.

**Perche' nessuna prova poteva vederlo.** Il cancello guarda il codice: le
prove del client, quelle del server, l'analisi. Nessuna di loro apre mai il
file che il telefono scarica. Fra il codice che passa le prove e l'archivio
che parte c'e' Gradle, ci sono gli AAR dei plugin, ci sono i filtri degli ABI
e le esclusioni del confezionamento: un pezzo puo' sparire li' dentro senza
che una riga di Dart cambi.

**Il vincolo di questo file, e non e' negoziabile: si guarda DENTRO
l'archivio.** Non il comando che lo ha prodotto, non la configurazione che lo
ha governato, non il codice che lo ha generato. Tutte e tre quelle cose erano
giuste il giorno della 2216, e l'archivio no.

**Perche' e' un file suo e non tre righe dentro la consegna.** Cosi' si puo'
lanciare da solo, su un archivio qualunque, senza caricare niente da nessuna
parte: e' il modo in cui la prova del rosso di questa voce si fa senza
spedire.

Uso:
  python tool/ispeziona_archivio.py build/app/outputs/flutter-apk/app-release.apk

Esce 0 se l'archivio dice il vero, 1 se qualcosa non torna, e in quel caso
dice CHE COSA. Si lancia dalla radice del repository, perche' legge
`docs/stato_asset.json`, `docs/versione_distribuita.json` e
`android/app/build.gradle.kts`.
"""

import io
import json
import os
import re
import subprocess
import sys
import zipfile

import verifica_apk

GRADLE = 'android/app/build.gradle.kts'
MANIFEST_ASSET = 'docs/stato_asset.json'
REGISTRO = 'docs/versione_distribuita.json'

# **I DUE PEZZI SENZA I QUALI UNA CARTELLA DI ARCHITETTURA E' UN GUSCIO.**
#
# `libflutter.so` e' il motore, `libapp.so` e' il codice Dart compilato. Le
# altre librerie di quella cartella sono dei plugin, e da sole non avviano
# niente: e' esattamente la forma in cui e' uscita la 2216.
MOTORE = ('libflutter.so', 'libapp.so')


def abi_dichiarati(percorso=GRADLE):
    """Le architetture che il PROGETTO dichiara, lette dal suo file.

    Si legge la lista degli `abiFilters` e si tolgono quelle che il blocco
    del confezionamento esclude: sono due serrature diverse, una su cio' che
    si compila e una su cio' che si copia, e il file lo dice da se'. Un
    controllo che ne guardasse una sola direbbe una cosa non vera.
    """
    testo = io.open(percorso, encoding='utf-8').read()
    m = re.search(r'abiFilters\s*\+=\s*listOf\(([^)]*)\)', testo)
    if not m:
        raise SystemExit('in %s non c\'e\' nessun abiFilters: senza quella '
                         'riga il progetto non dichiara niente, e questo '
                         'controllo non ha un atteso con cui confrontare'
                         % percorso)
    dichiarati = re.findall(r'"([^"]+)"', m.group(1))
    esclusi = set()
    for voce in re.findall(r'"lib/([^/"]+)/\*\*"', testo):
        esclusi.add(voce)
    return [a for a in dichiarati if a not in esclusi], sorted(esclusi)


def architetture(z):
    """Le architetture presenti DENTRO l'archivio, con i loro file."""
    per_abi = {}
    for nome in z.namelist():
        if not nome.startswith('lib/'):
            continue
        pezzi = nome.split('/')
        if len(pezzi) < 3 or not pezzi[2]:
            continue
        per_abi.setdefault(pezzi[1], set()).add(pezzi[2])
    return per_abi


def versione_dall_archivio(archivio):
    """Il versionCode letto DALL'ARCHIVIO con aapt2, mai dal pubspec.

    **Una porta sola.** Anche `tool/consegna.py` ha bisogno di questo numero,
    e due modi di leggerlo sarebbero due numeri che un giorno divergono.
    """
    radice = os.path.join(os.environ.get('LOCALAPPDATA', ''), 'Android',
                          'sdk', 'build-tools')
    aapt2 = None
    if os.path.isdir(radice):
        for versione in sorted(os.listdir(radice), reverse=True):
            candidato = os.path.join(radice, versione, 'aapt2.exe')
            if os.path.isfile(candidato):
                aapt2 = candidato
                break
    if not aapt2:
        raise SystemExit('aapt2 non trovato sotto ' + radice + ': senza di '
                         'lui il numero non si legge dall\'archivio, e un '
                         'numero preso dal pubspec non e\' una misura.')
    fuori = subprocess.run([aapt2, 'dump', 'badging', archivio],
                           capture_output=True, text=True)
    if fuori.returncode != 0:
        raise SystemExit('aapt2 dump badging fallito:\n' + fuori.stderr[:400])
    for pezzo in fuori.stdout.split():
        if pezzo.startswith("versionCode='"):
            return int(pezzo.split("'")[1])
    raise SystemExit('aapt2 non ha stampato un versionCode')


def ispeziona(archivio, con_numero=True):
    """I guai trovati dentro l'archivio, uno per riga. Lista vuota = pulito.

    [con_numero] a falso salta il confronto col registro, che ha bisogno di
    aapt2: serve alle prove, dove l'archivio e' finto e un numero non c'e'.
    """
    guai = []
    righe = []

    if not os.path.exists(archivio):
        return ['l\'archivio non esiste: ' + archivio], righe

    with zipfile.ZipFile(archivio) as z:
        nomi = z.namelist()

        # 1. IL CODICE DELL'APP C'E'.
        #    Un archivio senza flutter_assets e' un guscio Android che non
        #    porta l'app: sembra un APK e non lo e'.
        quanti = sum(1 for n in nomi if n.startswith('assets/flutter_assets/'))
        righe.append('assets/flutter_assets/: %d voci' % quanti)
        if quanti < 100:
            guai.append('assets/flutter_assets/ ha %d voci: l\'app non c\'e\' '
                        'dentro' % quanti)

        # 2. NESSUNA CARTELLA DI ARCHITETTURA E' UN GUSCIO.
        #    E' il difetto della 2216, e questa e' la riga che lo prende.
        per_abi = architetture(z)
        for abi in sorted(per_abi):
            mancanti = [m for m in MOTORE if m not in per_abi[abi]]
            righe.append('lib/%s/: %d librerie%s'
                         % (abi, len(per_abi[abi]),
                            '' if not mancanti else
                            '  <-- SENZA ' + ', '.join(mancanti)))
            if mancanti:
                guai.append('lib/%s/ non ha %s: e\' una cartella di '
                            'architettura senza motore, e su quei telefoni '
                            'l\'app non si avvia' % (abi, ' ne\' '.join(mancanti)))

        # 3. LE ARCHITETTURE SONO ESATTAMENTE QUELLE DICHIARATE.
        attesi, esclusi = abi_dichiarati()
        dentro = sorted(per_abi)
        righe.append('architetture: dentro %s, dichiarate %s'
                     % (', '.join(dentro) or 'nessuna', ', '.join(attesi)))
        di_troppo = [a for a in dentro if a not in attesi]
        assenti = [a for a in attesi if a not in dentro]
        if di_troppo:
            guai.append('nell\'archivio ci sono architetture che il progetto '
                        'non dichiara: ' + ', '.join(di_troppo)
                        + ' (il progetto dichiara ' + ', '.join(attesi)
                        + ' ed esclude ' + (', '.join(esclusi) or 'niente')
                        + ')')
        if assenti:
            guai.append('il progetto dichiara architetture che nell\'archivio '
                        'non ci sono: ' + ', '.join(assenti))

    # 4. LE FAMIGLIE DELL'ARTE, COL LORO CONTEGGIO.
    #    Non si riconta a mano: si passa dalla porta che gia' esiste, perche'
    #    due conti della stessa cosa un giorno divergono.
    manifest = json.load(io.open(MANIFEST_ASSET, encoding='utf-8'))
    attesi_fam = manifest['bundle_versionato']['famiglie_conteggi']
    piene, miniature = verifica_apk.conta_famiglie(archivio)
    incomplete = []
    for famiglia, atteso in sorted(attesi_fam.items()):
        n = int(atteso) if not isinstance(atteso, dict) else int(
            atteso.get('piene', 0))
        trovate = piene.get(famiglia, 0)
        if trovate != n:
            incomplete.append('%s %d invece di %d' % (famiglia, trovate, n))
    righe.append('famiglie dell\'arte: %d dichiarate, %d incomplete'
                 % (len(attesi_fam), len(incomplete)))
    if incomplete:
        guai.append('queste famiglie non sono intere dentro l\'archivio: '
                    + '; '.join(incomplete))

    # 5. IL NUMERO SUPERA L'ULTIMO CONSEGNATO.
    #    Android rifiuta di installare un versionCode piu' basso sopra uno
    #    piu' alto: una build che non supera il registro non si installa e
    #    non lo dice a nessuno.
    if con_numero:
        numero = versione_dall_archivio(archivio)
        registro = json.load(io.open(REGISTRO, encoding='utf-8'))
        ultimo = int(registro.get('ultimo_distribuito', 0))
        righe.append('numero dall\'archivio: %d, ultimo consegnato: %d'
                     % (numero, ultimo))
        if numero <= ultimo:
            guai.append('il numero dell\'archivio, %d, non supera l\'ultimo '
                        'consegnato, %d: sul telefono non si installerebbe '
                        'sopra quella' % (numero, ultimo))

    return guai, righe


def main():
    if len(sys.argv) < 2:
        print('uso: python tool/ispeziona_archivio.py <percorso archivio>')
        return 2
    archivio = sys.argv[1]
    senza_numero = '--senza-numero' in sys.argv
    guai, righe = ispeziona(archivio, con_numero=not senza_numero)
    print('== CIO\' CHE C\'E\' DENTRO %s ==' % archivio)
    for r in righe:
        print('  ' + r)
    if not guai:
        print('\nL\'ARCHIVIO DICE IL VERO: nessun controllo caduto.')
        return 0
    print('\n' + '=' * 70)
    print('  L\'ARCHIVIO NON DICE IL VERO. Non si consegna.')
    print('=' * 70)
    for g in guai:
        print('  - ' + g)
    return 1


if __name__ == '__main__':
    sys.exit(main())
