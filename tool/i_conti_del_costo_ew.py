# -*- coding: utf-8 -*-
"""I CONTI DEL COSTO PER UTENTE. Ordine EW, voci EW.04, EW.05 ed EW.07.

Legge le chiamate misurate dal banco (`docs/costi/costo_per_funzione_chiamate.jsonl`,
scritte da `tool/il_banco_del_costo.dart` col codice vero dell'app e Gemini in
europe-west1) e fa i conti:

- il costo per uso di ogni funzione, medio e massimo, con la cache implicita
  com'e' stata misurata e senza (il caso peggiore: nessun prefisso in cache);
- la giornata al massimo di ogni piano, coi limiti letti dal codice
  (`plan_catalog.dart`), e i trenta giorni contro il prezzo del piano;
- il minuto del LIVE dalla sessione vera sul Realme del 2 ottobre 2026.

Uso:
  python tool/i_conti_del_costo_ew.py > docs/costi/i_conti_del_costo.txt
"""
import json
import pathlib
import statistics as st
from collections import defaultdict

RADICE = pathlib.Path(__file__).resolve().parent.parent
CHIAMATE = RADICE / 'docs/costi/costo_per_funzione_chiamate.jsonl'

# Prezzi in dollari per milione di token, letti il 2 ottobre 2026.
PREZZI = {
    'gemini-2.5-flash': dict(ingresso=0.30, audio=1.00, uscita=2.50),
    'gemini-2.5-flash-lite': dict(ingresso=0.10, audio=0.30, uscita=0.40),
    'gemini-2.5-flash-tts': dict(ingresso=0.50, audio=0.50, uscita=10.00),
}
EUR_USD = 1.1298  # cambio di riferimento BCE del 1 ottobre 2026


def costo(c, con_cache=True):
    p = PREZZI.get(c['modello'])
    if not p:
        return 0.0
    u = c['usageMetadata']
    ing = u.get('promptTokenCount', 0)
    cache = u.get('cachedContentTokenCount', 0) if con_cache else 0
    audio = sum(d.get('tokenCount', 0) for d in u.get('promptTokensDetails', [])
                if d.get('modality') == 'AUDIO')
    testo = ing - audio - cache
    out = u.get('candidatesTokenCount', 0) + u.get('thoughtsTokenCount', 0)
    return (testo * p['ingresso'] + cache * p['ingresso'] * 0.10
            + audio * p['audio'] + out * p['uscita']) / 1e6


righe = [json.loads(r) for r in CHIAMATE.read_text(encoding='utf-8').splitlines()
         if r.strip()]
# L'ascolto del primo giro aveva 13 usi validi: vale il secondo giro, con 20.
giri_ascolto = sorted({r['giro'] for r in righe
                       if r['caso'].startswith("LIVE, l'ascolto")})
if len(giri_ascolto) > 1:
    righe = [r for r in righe if not (r['caso'].startswith("LIVE, l'ascolto")
                                      and r['giro'] != giri_ascolto[-1])]

usi = defaultdict(lambda: defaultdict(list))
for r in righe:
    usi[r['caso']][(r['giro'], r['uso'])].append(r)

print('== EW.04, IL COSTO PER USO (dollari)')
print(f'chiamate lette {len(righe)}')
PER_USO = {}
for caso, per in usi.items():
    con = [sum(costo(c) for c in v) for v in per.values()]
    senza = [sum(costo(c, False) for c in v) for v in per.values()]
    n = [len(v) for v in per.values()]
    pens = sum(c['usageMetadata'].get('thoughtsTokenCount', 0)
               for v in per.values() for c in v)
    PER_USO[caso] = dict(medio=st.mean(con), massimo=max(con),
                         medio_senza=st.mean(senza), massimo_senza=max(senza))
    print(f'{caso}: usi {len(con)}, chiamate {sum(n)} (per uso media '
          f'{st.mean(n):.2f}, massimo {max(n)}), ragionamento {pens} token; '
          f'medio {st.mean(con):.5f}, massimo {max(con):.5f}; senza cache '
          f'medio {st.mean(senza):.5f}, massimo {max(senza):.5f}')
print()


def per(caso_iniziale, chiave='medio'):
    for k, v in PER_USO.items():
        if k.startswith(caso_iniziale):
            return v[chiave]
    raise KeyError(caso_iniziale)


# I limiti al giorno dal codice (plan_catalog.dart, letti il 2 ottobre 2026):
# Viandante, Iniziato, Adepto, Illuminato.
PIANI = ['Viandante', 'Iniziato', 'Adepto', 'Illuminato']
PREZZO_EUR = [0, 9.99, 19.99, 29.99]
LIMITI = {
    'domande': [3, 5, 10, 50],
    'approfondimenti': [0, 3, 10, 30],
    'confronti': [0, 3, 5, 20],
    'stese': [1, 4, 7, 20],
    'gettate': [1, 20, 30, 50],
    'discese': [1, 1, 1, 2],
    'segni': [1 / 7, 3 / 7, 1, 5],
    # I sigilli si limitano per spazio (1, 2, 3, 5 vivi insieme), non per
    # giorno: si conta che ogni giorno si compiano e si rifacciano tutti,
    # con una riformulazione ciascuno. E' un massimo largo.
    'sigilli': [1, 2, 3, 5],
    'ricordi': [0, 1 / 30, 1 / 30, 1 / 30],
}


def giornata(i, chiave):
    memoria = 'chat, memoria vuota' if i == 0 else 'chat, memoria piena'
    voci = {
        'domande (risposta del Maestro)': LIMITI['domande'][i] * per(memoria, chiave),
        'titoli delle conversazioni (uno per domanda, al massimo)':
            LIMITI['domande'][i] * per('Il titolo', chiave),
        'Vai piu\' a fondo': LIMITI['approfondimenti'][i] * per('chat, Vai', chiave),
        'confronti (Interroga i Maestri)': LIMITI['confronti'][i] * per('Interroga i Maestri', chiave),
        'stese dei tarocchi': LIMITI['stese'][i] * per('Tarocchi', chiave),
        'gettate di rune': LIMITI['gettate'][i] * per('Rune', chiave),
        'discese del Viaggio': LIMITI['discese'][i] * per('Viaggio, una discesa', chiave),
        'segni dell\'animale': LIMITI['segni'][i] * per('Viaggio, un segno', chiave),
        'sigilli (fatti, riformulati, compiuti)': LIMITI['sigilli'][i] * (
            per('Sigillo, titolo', chiave) + per('Sigillo, la riform', chiave)
            + per('Sigillo, il compim', chiave)),
        'lettura del mese dei Ricordi': LIMITI['ricordi'][i] * per('Ricordi', chiave),
    }
    return voci


print('== EW.05, LA GIORNATA AL MASSIMO SENZA LIVE (dollari)')
for i, piano in enumerate(PIANI):
    for chiave, nome in (('medio', 'costo medio per uso, cache misurata'),
                         ('medio_senza', 'costo medio per uso, senza cache'),
                         ('massimo_senza', 'ogni uso al suo massimo, senza cache')):
        v = giornata(i, chiave)
        g = sum(v.values())
        print(f'{piano}, {nome}: al giorno {g:.4f}, in 30 giorni {30 * g:.2f}')
    for k, x in giornata(i, 'medio_senza').items():
        print(f'   {k}: {x:.5f}')
print()

# Il minuto del LIVE dalla sessione vera del 2 ottobre 2026 (EW.07).
SECONDI_FATTURATI = 562 - 139          # due righe "Uso di Protoface nel mese"
CREDITI = 11 - 3
VOCE_SECONDI = 113.3                    # 12 chiamate di voce, byte / 48000
VOCE_CARATTERI = 1276
RISPOSTE = 4
ASCOLTI = 66                            # dal registro del telefono
minuti = SECONDI_FATTURATI / 60
pezzi = {
    'Protoface (volto)': CREDITI * 0.01,
    'voce del Maestro (Gemini TTS)': VOCE_SECONDI * 25 * 10 / 1e6
    + VOCE_CARATTERI / 4 * 0.5 / 1e6,
    'risposte (chat nel LIVE)': RISPOSTE * per('LIVE, la risposta', 'medio_senza'),
    'ascolto (trascrizioni)': ASCOLTI * per("LIVE, l'ascolto", 'medio_senza'),
    'LiveKit (piano Build, se confermato)': 0.0,
}
print('== EW.07, LA SESSIONE LIVE VERA (dollari)')
tot = sum(pezzi.values())
for k, x in pezzi.items():
    print(f'{k}: {x:.4f} nella sessione, {x / minuti:.4f} al minuto')
print(f'totale {tot:.4f} in {minuti:.2f} minuti fatturati: {tot / minuti:.4f} al minuto')
# Il minuto di LIVE in silenzio o col rumore: volto e ascolto, niente
# risposte ne' voce.
muto = 0.01 + ASCOLTI / minuti * per("LIVE, l'ascolto", 'medio_senza')
print(f'minuto senza risposte (volto e ascolto): {muto:.4f}')
for i, piano in enumerate(PIANI):
    mese = [0, 0, 100, 250][i]
    print(f'{piano}: {mese} minuti al mese dal codice, se tutti usati '
          f'{mese * tot / minuti:.2f} dollari')
print()

print('== EW.05, I TRENTA GIORNI CONTRO IL PREZZO')
for i, piano in enumerate(PIANI):
    g_medio = sum(giornata(i, 'medio_senza').values())
    g_max = sum(giornata(i, 'massimo_senza').values())
    live = [0, 0, 100, 250][i] * tot / minuti
    prezzo_usd = PREZZO_EUR[i] * EUR_USD
    print(f'{piano}: modello al massimo 30 giorni {30 * g_medio:.2f} (ogni uso al '
          f'massimo {30 * g_max:.2f}); LIVE coi minuti del piano {live:.2f}; '
          f'totale {30 * g_medio + live:.2f} (fino a {30 * g_max + live:.2f}); '
          f'prezzo {PREZZO_EUR[i]:.2f} euro = {prezzo_usd:.2f} dollari')
g_ini = sum(giornata(1, 'medio_senza').values()) * 30
print(f'Iniziati al massimo che fanno 95 dollari al mese: {95 / g_ini:.0f}')
g_ini_max = sum(giornata(1, 'massimo_senza').values()) * 30
print(f'... con ogni uso al suo massimo: {95 / g_ini_max:.0f}')
