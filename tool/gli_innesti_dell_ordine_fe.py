"""LA REGOLA A DELL'ORDINE FE: ogni prova nuova vista rossa sul suo difetto.

Stessa forma del banco dell'ordine FC (`gli_innesti_dell_ordine_fd.py`): per
ogni innesto la copia del file, il difetto messo a mano, il controllo che
l'innesto sia ENTRATO, la prova fatta girare, l'esito letto, il nome della
prova che DEVE cadere cercato fra le cadute, il file rimesso dalla copia e
confrontato al byte.

Uso: PYTHONIOENCODING=utf-8 python tool/gli_innesti_dell_ordine_fe.py [sigla ...]
L'esito si scrive in docs/collaudo/FE/regola_a_fe.txt (in coda).
"""
import io
import os
import shutil
import subprocess
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)


CIELO = 'flutter test test/il_cielo_non_ferma_l_interfaccia_test.dart -r expanded'
FUNZIONI = 'lib/services/ai/le_funzioni_del_cielo.dart'

# sigla, voce, file, vecchio, nuovo, comando, la prova che deve cadere
INNESTI = [
    # FE.01, il cielo calcolato sul filo dell'interfaccia.
    ('A1', 'FE.01', FUNZIONI,
     '        callable: periodoFuoriDalFilo,',
     '        callable: periodo,',
     CIELO, 'lascia libero il filo'),
    ('A2', 'FE.01', FUNZIONI,
     '    return fuoriDalFilo(() => _cieloDeiGiorni(giorni, carta));',
     '    return _cieloDeiGiorni(giorni, carta);',
     CIELO, 'passa dalla porta fuori dal filo'),
    # FE.03, la configurazione completa del Maestro nel LIVE.
    ('A3', 'FE.03', 'functions/src/live.ts',
     '  caligo: "av_01KZVB6FCP27NR3GZQ47WJ7QJG",\n',
     '',
     'flutter test test/il_maestro_del_live_ha_tutto_test.dart -r expanded',
     'ogni risorsa del collegamento'),
    ('A4', 'FE.03', 'lib/services/live/porta_del_live.dart',
     "        if (avatar.isEmpty) 'avatar',\n",
     '',
     'flutter test test/il_maestro_del_live_ha_tutto_test.dart -r expanded',
     'una sessione a meta'),
    ('A5', 'FE.03', 'functions/src/live.ts',
     '  if (!I_MODI[maestro]) mancanze.push("modo");\n',
     '',
     'cd functions && npm test',
     'FE.03 ogni Maestro del LIVE'),
    # FE.01, la causa vera: gli eventi in arrivo sul filo dell'interfaccia.
    ('A6', 'FE.01', 'lib/services/ai/maestro_persona.dart',
     '        : IlCieloCheArriva.gia(adesso: DateTime.now(), segno: segno) ??\n'
     '            const <EventoInArrivo>[];',
     '        : ProssimiEventi.da(adesso: DateTime.now(), segno: segno);',
     'flutter test test/il_cielo_che_arriva_non_ferma_l_interfaccia_test.dart -r expanded',
     'non ferma il filo'),
    ('A7', 'FE.01', 'lib/services/ai/firebase_maestro_ai_provider.dart',
     '    await MaestroPersona.preparaIlCielo(natal);\n',
     '',
     'flutter test test/il_cielo_che_arriva_non_ferma_l_interfaccia_test.dart -r expanded',
     'prepara il cielo prima'),
    ('A8', 'FE.01', 'lib/features/calendario/calendario_degli_eventi_screen.dart',
     '    final pronti =\n        IlCieloCheArriva.gia(adesso: quando, carta: carta, segno: segno);',
     '    final pronti = ProssimiEventi.da(adesso: quando, carta: carta, segno: segno);',
     'flutter test test/il_cielo_che_arriva_non_ferma_l_interfaccia_test.dart -r expanded',
     'solo dentro la porta'),
    # FE.08-14, il filo del consulto.
    ('A9', 'FE.09', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '      IlFiloDelConsulto.annota(\n          maestro: chiRisponde, domanda: userText, risposta: reply);\n',
     '',
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'leggono lo stesso filo'),
    ('A10', 'FE.10', 'lib/services/ai/maestro_persona.dart',
     "      if (filo.isNotEmpty) ...['', filo],\n",
     '',
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'non cambia di un carattere'),
    ('A11', 'FE.14', 'lib/core/chat/il_filo_del_consulto.dart',
     '        righe.add(LaLeggeDellaCoerenza.ilSecondoMaestro);\n',
     '',
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'il secondo Maestro riceve'),
    ('A12', 'FE.11', 'lib/core/chat/il_filo_del_consulto.dart',
     '      if (dellaFrase >= 0.5 && dellaDomanda >= 0.6 && dellaFrase > meglio) {',
     '      if (dellaFrase >= 0.99 && dellaDomanda >= 0.6 && dellaFrase > meglio) {',
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'la frase ripresa si riconosce'),
    # FE.22, il filo in cima alla chat.
    ('A13', 'FE.22', 'lib/features/maestri/chat/widgets/il_filo_in_cima.dart',
     '      s != null &&\n',
     '      false &&\n      s != null &&\n',
     'flutter test test/il_filo_in_cima_test.dart -r expanded',
     'la domanda e i pareri ci sono'),
    # Regola B PRIMA del tocco: le guardie degli eventi in arrivo (il crash
    # vero del Redmi, FE.01) e della memoria della chat (parte terza).
    ('B5', 'FE.01', 'lib/services/ai/maestro_persona.dart',
     '        : ProssimiEventi.da(adesso: DateTime.now(), segno: segno);\n',
     '        : const <EventoInArrivo>[];\n',
     'flutter test test/i_maestri_sanno_cosa_arriva_test.dart -r expanded',
     '[E]'),
    ('B6', 'FE.01', 'lib/features/calendario/calendario_degli_eventi_screen.dart',
     '    final tutti = ProssimiEventi.da(adesso: quando, carta: carta, segno: segno);\n',
     '    final tutti = const <EventoInArrivo>[];\n',
     'flutter test test/il_calendario_degli_eventi_test.dart -r expanded',
     '[E]'),
    ('B7', 'FE.01', 'lib/features/passport/cosmic_passport_screen.dart',
     '    ).take(_ProssimiEventiCosmici.quanti).toList();\n',
     '    ).take(0).toList();\n',
     'flutter test test/online_nella_barra_e_gli_eventi_nel_passport_test.dart -r expanded',
     '[E]'),
    ('B8', 'FE.08', 'lib/services/ai/firebase_maestro_ai_provider.dart',
     '  static const int kFinestraDelRiassunto = 20;\n',
     '  static const int kFinestraDelRiassunto = 8;\n',
     'flutter test test/la_memoria_compatta_test.dart -r expanded',
     '[E]'),
    ('B9', 'FE.10', 'lib/services/ai/maestro_persona.dart',
     '    return [\n      parteComune(\n',
     "    return [\n      'PER ${profile.hashCode}',\n      parteComune(\n",
     'flutter test test/la_parte_comune_viene_prima_test.dart -r expanded',
     '[E]'),
    # Regola B delle guardie della porta del LIVE, fatta dopo il tocco della
    # FE.03 e dichiarata.
    ('B3', 'FE.03', 'lib/services/live/porta_del_live.dart',
     "      'resource-exhausted' => PerchePerILiveNonSiApre.minutiFiniti,\n",
     '',
     'flutter test test/la_porta_del_live_non_porta_chiavi_test.dart -r expanded',
     '[E]'),
    ('B4', 'FE.03', 'lib/features/maestri/live/stato_della_schermata_live.dart',
     "          'Per questo mese ho finito il fiato. Resto qui, in silenzio e '\n",
     "          'La voce non arriva, stasera. Scrivimi: quello che ci siamo '\n",
     'flutter test test/il_live_non_e_mai_un_vicolo_cieco_test.dart -r expanded',
     '[E]'),
    # Regola B, fatta dopo il tocco della FE.01 e dichiarata: le due guardie
    # della zona delle funzioni del cielo.
    ('B1', 'FE.01', FUNZIONI,
     '      if (g != null) giorniChiesti.add(DateTime(g.year, g.month, g.day, 12));\n',
     '',
     'flutter test test/medora_sa_il_cielo_e_il_responso_test.dart -r expanded',
     '[E]'),
    ('B2', 'FE.01', FUNZIONI,
     '      giorniChiesti.add(DateTime(d.year, d.month, d.day, 12));\n    }\n    return giorni;',
     '    }\n    return giorni;',
     'flutter test test/i_giorni_nominati_test.dart -r expanded',
     '[E]'),
]


def leggi(p):
    return io.open(p, encoding='utf-8', newline='').read()


def scrivi(p, s):
    io.open(p, 'w', encoding='utf-8', newline='').write(s)


def un_innesto(sigla, voce, percorso, vecchio, nuovo, comando, bersaglio):
    copia = percorso + '.copia_regola_a'
    shutil.copyfile(percorso, copia)
    try:
        dati = leggi(percorso)
        crlf = '\r\n' in dati
        testo = dati.replace('\r\n', '\n')
        # Un innesto puo' essere fatto di piu' pezzi nello stesso file: allora
        # `vecchio` e' un elenco di coppie (vecchio, nuovo) e `nuovo` e' None.
        coppie = vecchio if isinstance(vecchio, list) else [(vecchio, nuovo)]
        for v, _ in coppie:
            n = testo.count(v)
            if n != 1:
                return '%s (%s) INNESTO NON ENTRATO: il pezzo vecchio compare %d volte' % (sigla, voce, n)
        for v, nv in coppie:
            testo = testo.replace(v, nv)
        scrivi(percorso, testo.replace('\n', '\r\n') if crlf else testo)
        dopo = leggi(percorso).replace('\r\n', '\n')
        entrato = True
        for v, nv in coppie:
            if nv and v in nv:
                entrato = entrato and dopo.count(nv) == 1
            else:
                entrato = entrato and (nv in dopo if nv else True) and dopo.count(v) == 0
        if not entrato:
            return '%s (%s) INNESTO NON ENTRATO al controllo' % (sigla, voce)
        esito = subprocess.run(comando, shell=True, capture_output=True,
                               text=True, encoding='utf-8', errors='replace')
        uscita = esito.stdout + esito.stderr
        rossa = esito.returncode != 0
        # Le cadute di flutter test portano [E]; quelle del server, col
        # rapporto spec di node, cominciano con la crocetta pesante.
        cadute = [r.strip()[:170] for r in uscita.splitlines()
                  if '[E]' in r or r.lstrip().startswith('✖')]
        nel_bersaglio = any(bersaglio in c for c in cadute)
        misure = [r.strip()[:220] for r in uscita.splitlines()
                  if r.startswith('ORDINE FE')][:2]
        return ('%s (%s) %s: innesto entrato (grep del pezzo nuovo 1, del vecchio 0); '
                '%s; bersaglio "%s" %s; cadute: %s; misure lette: %s') % (
                    sigla, voce, percorso,
                    'ROSSA' if rossa else 'VERDE (la prova NON vede il difetto)',
                    bersaglio, 'colpito' if nel_bersaglio else 'NON COLPITO',
                    ' | '.join(cadute[:2]) if cadute else '(nessuna riga di caduta letta)',
                    ' | '.join(misure) if misure else '(nessuna)')
    finally:
        shutil.copyfile(copia, percorso)
        os.remove(copia)


def main():
    scelte = set(sys.argv[1:])
    os.makedirs('docs/collaudo/FE', exist_ok=True)
    registro = 'docs/collaudo/FE/regola_a_fe.txt'
    for innesto in INNESTI:
        if scelte and innesto[0] not in scelte:
            continue
        prima = open(innesto[2], 'rb').read()
        riga = un_innesto(*innesto)
        dopo = open(innesto[2], 'rb').read()
        riga += '; file rimesso dalla copia: %s.' % (
            'uguale al byte (cmp)' if prima == dopo else 'DIVERSO, CONTROLLARE')
        print(riga, flush=True)
        with io.open(registro, 'a', encoding='utf-8', newline='\n') as f:
            f.write(riga + '\n')


if __name__ == '__main__':
    main()
