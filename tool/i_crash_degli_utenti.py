"""I CRASH DEGLI UTENTI, letti da Crashlytics. Ordine FE voce 04.

L'app raccoglie i crash in produzione con Firebase Crashlytics dal 7 agosto
2026 (`lib/main.dart`, gli errori del framework, quelli fuori dal framework e
i crash nativi). Fino al 5 ottobre 2026 si leggevano solo dalla console
Firebase; il 5 ottobre il fondatore ha fatto accendere l'API di lettura
(`firebasecrashlytics.googleapis.com`), e da qui si leggono senza browser.

Uso, con `gcloud` gia' autenticato:

    python tool/i_crash_degli_utenti.py                 # i problemi e gli eventi
    python tool/i_crash_degli_utenti.py --build 2298    # solo una build
    python tool/i_crash_degli_utenti.py --stack <id>    # lo stack di un evento

Stampa la data, il tipo, il telefono, la build e il titolo del problema; con
--stack i passi di ogni filo. Non stampa e non scrive nessun dato della
persona: Crashlytics non ne riceve (nessun identificativo utente, nessuna
chiave, nessun registro), e la prova `crashlytics_ha_gli_occhi_test.dart`
sorveglia i canali.
"""
import argparse
import json
import subprocess
import urllib.request
import os

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def l_app():
    g = json.load(open(os.path.join(RADICE, 'android', 'app', 'google-services.json')))
    return [c['client_info']['mobilesdk_app_id'] for c in g['client']
            if c['client_info']['android_client_info']['package_name']
            == 'com.esotericircle.esoteric_circle'][0]


def chiedi(percorso, gettone):
    base = ('https://firebasecrashlytics.googleapis.com/v1alpha/projects/'
            f'esoteric-circle/apps/{l_app()}')
    r = urllib.request.Request(base + percorso, headers={
        'Authorization': 'Bearer ' + gettone,
        'x-goog-user-project': 'esoteric-circle'})
    with urllib.request.urlopen(r, timeout=120) as f:
        return json.load(f)


def main():
    a = argparse.ArgumentParser()
    a.add_argument('--build')
    a.add_argument('--stack')
    args = a.parse_args()
    gettone = subprocess.run('gcloud auth print-access-token', shell=True,
                             capture_output=True, text=True).stdout.strip()
    if not gettone:
        raise SystemExit('gcloud non ha dato un gettone')
    problemi = chiedi('/reports/topIssues?page_size=50', gettone)['groups']
    for g in problemi:
        i = g['issue']
        eventi = chiedi(f"/events?filter.issue.id={i['id']}&page_size=100",
                        gettone).get('events', [])
        for e in eventi:
            v = e.get('version', {}).get('buildVersion')
            if args.build and v != args.build:
                continue
            dev = e.get('device', {})
            print(e.get('eventTime', '')[:19], i['errorType'], dev.get('model'),
                  'build', v, '|', i['title'][:90], '| evento',
                  e.get('eventId', '')[:12])
            if args.stack and e.get('eventId', '').startswith(args.stack):
                for t in e.get('threads', []):
                    print('== filo', t.get('name'), '(accusato)' if t.get('blamed') else '')
                    for n, f in enumerate(t.get('frames', [])):
                        print(f"  {n:3} {f.get('symbol', '')} {f.get('file', '')} "
                              f"{f.get('line', '')} [{f.get('library', '')}] "
                              f"{f.get('address', '')}")


if __name__ == '__main__':
    main()
