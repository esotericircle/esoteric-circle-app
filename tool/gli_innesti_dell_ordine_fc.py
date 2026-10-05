"""LA REGOLA A DELL'ORDINE FC: ogni prova nuova vista rossa sul suo difetto.

Stessa forma del banco dell'ordine FB (`gli_innesti_dell_ordine_fb.py`): per
ogni innesto la copia del file, il difetto messo a mano, il controllo che
l'innesto sia ENTRATO, la prova fatta girare, l'esito letto, il nome della
prova che DEVE cadere cercato fra le cadute, il file rimesso dalla copia e
confrontato al byte.

Uso: PYTHONIOENCODING=utf-8 python tool/gli_innesti_dell_ordine_fc.py [sigla ...]
L'esito si scrive in docs/collaudo/FC/regola_a_fc.txt (in coda).
"""
import io
import os
import shutil
import subprocess
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)

UNO = 'flutter test test/l_oroscopo_e_uno_solo_test.dart -r expanded'
NOME = 'flutter test test/l_oroscopo_si_chiama_universale_test.dart -r expanded'
VERDE = 'flutter test test/il_verde_dice_i_rossi_accettati_test.dart -r expanded'
GESTO = 'flutter test test/il_gesto_in_tutti_i_periodi_test.dart -r expanded'
RUBRICA = 'flutter test test/il_cerchio_si_vede_dalla_rubrica_test.dart -r expanded'
PORTA = 'flutter test test/il_segno_ha_una_porta_sola_test.dart -r expanded'
EMBLEMA = 'flutter test test/l_emblema_dell_amico_test.dart -r expanded'
ORA = 'flutter test test/l_ultimo_dato_vale_un_ora_test.dart -r expanded'
CANCELLO = 'flutter test test/il_cancello_esegue_tutte_le_prove_test.dart -r expanded'
SCHERMATA = 'lib/features/horoscope/oroscopo_screen.dart'
SOGGETTO = 'lib/features/horoscope/il_soggetto_dell_oroscopo.dart'

# sigla, voce, file, vecchio, nuovo, comando, la prova che deve cadere
INNESTI = [
    ('A1', 'FC.02', SCHERMATA,
     '                      if (_inCima.unlocked) ...[',
     '                      if (_inCima.unlocked && !_soggetto.eUnAmico) ...[',
     UNO, 'stesse cose'),
    ('A2', 'FC.02', SCHERMATA,
     '    final mio = IlSoggettoDellOroscopo.segnoDiChiGuarda(context);',
     '    final mio = context.read<ProfileController>().identity.isExample\n'
     '        ? null\n        : IlSoggettoDellOroscopo.segnoDiChiGuarda(context);',
     UNO, 'non legge i dati di nascita'),
    ('A3', 'FC.03', SCHERMATA,
     '  _FaseDelConsulto _fase = _FaseDelConsulto.attesa;',
     '  late _FaseDelConsulto _fase = widget.amico == null\n'
     '      ? _FaseDelConsulto.attesa\n      : _FaseDelConsulto.responso;',
     UNO, 'non compare mai da solo'),
    ('A4', 'FC.03', SCHERMATA,
     '    return switch (_fase) {',
     '    if (_soggetto.eUnAmico) return lettura;\n    return switch (_fase) {',
     GESTO, '(amico)'),
    ('A5', 'FC.05', SCHERMATA,
     '                              ore: _oreDelGiorno(cards,',
     '                              ore: _soggetto.eUnAmico ? null : _oreDelGiorno(cards,',
     UNO, 'stesse cose'),
    ('A6', 'FC.05', SOGGETTO,
     '      amico != null\n          ? null\n          : Provider.of<BirthIdentityController>(context, listen: ascolta)\n              .cartaCompleta;',
     '      Provider.of<BirthIdentityController>(context, listen: ascolta)\n              .cartaCompleta;',
     UNO, 'stesse cose'),
    ('A7', 'FC.06', 'lib/core/horoscope/gli_anni_aperti.dart',
     "      soggetto == null ? _chiave : '$_chiave|$soggetto';",
     "      _chiave;",
     UNO, "l'anno aperto con gli Eos"),
    ('A8', 'FC.01', 'lib/core/chat/immersive_intents.dart',
     "      buttonLabel: 'Apri l\\'Oroscopo Universale',",
     "      buttonLabel: 'Apri l\\'Oroscopo ' 'Personalizzato',",
     NOME, 'nessun testo a video'),
    ('A9', 'FC.01', 'lib/core/arts/art_catalog.dart',
     "        title: 'Oroscopo Universale',",
     "        title: 'Oroscopo Personalizzato',",
     NOME, 'nessun testo a video'),
    ('A10', 'FC.08', '.github/workflows/verde.yml',
     '        run: bash tool/il_verdetto_del_cancello.sh /tmp/sbarramento.txt verde',
     '        run: echo verde',
     VERDE, 'il flusso pubblica'),
    ('A11', 'FC.08', 'tool/il_verdetto_del_cancello.sh',
     '    echo "::warning title=Il verde ha dei rossi accettati::$FUGATO"',
     '    echo "verde"',
     VERDE, 'lo script dice'),
    ('A13', 'FC.02', SCHERMATA,
     '                : FittedBox(\n                    fit: BoxFit.scaleDown,\n                    child: Text(_soggetto.titolo!,',
     '                : SizedBox(\n                    width: 150,\n                    child: Text(_soggetto.titolo!,\n'
     '                        overflow: TextOverflow.ellipsis,',
     UNO, 'stesse cose'),
    ('A14', 'FC', 'docs/ordini/ORDINE_FC_MANIFESTO.md',
     'VOCI_TOTALI: 9\n', 'VOCI_TOTALI: 10\n',
     'flutter test test/ordine_fc_guard_test.dart -r expanded', 'ogni voce'),
    # Regola B recuperata: le tre prove che pretendevano il nome nel catalogo,
    # cambiate senza averle viste rosse prima (dichiarato nel rapporto).
    ('A15', 'FC.01', 'lib/core/arts/art_catalog.dart',
     "        title: 'Oroscopo Universale',",
     "        title: 'Oroscopo Personalizzato',",
     'flutter test test/il_nome_breve_dell_oroscopo_test.dart '
     'test/i_domini_a_schede_test.dart test/le_schede_dell_arte_test.dart -r expanded',
     'Universale'),
    # Le prove riscritte sulla porta unica, viste rosse sul loro difetto.
    ('A16', 'FC.02', SOGGETTO,
     '      return NascitaDeiSegni(\n          locale: a.momento, oraNota: a.oraNota, fuso: a.fuso);',
     '      return null;',
     'flutter test test/gli_amici_offline_test.dart -r expanded',
     'al neutro'),
    ('A17', 'FC.02', SCHERMATA,
     '    final chi = _soggetto.chiave(t.name);',
     '    if (_soggetto.eUnAmico) return;\n    final chi = _soggetto.chiave(t.name);',
     'flutter test test/il_segno_si_rivela_la_prima_volta_test.dart -r expanded',
     'dell\'amico la rivela'),
    ('A18', 'FC.02', SCHERMATA,
     '                      _TraditionTabs(',
     '                      if (!_soggetto.eUnAmico)\n                      _TraditionTabs(',
     'flutter test test/l_oroscopo_visto_nelle_anteprime_test.dart -r expanded',
     'tradizioni dell\'amico'),
    ('A19', 'FC.02', SCHERMATA,
     '                              premiumUnlocked: PlanCatalog.haProfondita(context',
     '                              premiumUnlocked: !_soggetto.eUnAmico &&\n'
     '                                  PlanCatalog.haProfondita(context',
     'flutter test test/la_profondita_sta_su_ogni_scheda_test.dart -r expanded',
     'oroscopo di un amico'),
    ('A20', 'FC.02', SCHERMATA,
     '    if (!_soggetto.eUnAmico) {\n      unawaited(RegiaDelCammino.dopoUnGesto(',
     '    if (true) {\n      unawaited(RegiaDelCammino.dopoUnGesto(',
     UNO, 'non entra nel Cammino'),
    # FC.09, gli amici online nella rubrica. A21, A22 e A23 provavano la
    # prima forma (la riga che portava al Cerchio, il file
    # il_ponte_verso_il_cerchio.dart): il fondatore l'ha cambiata la stessa
    # sera nei due pulsanti, il file e' tolto, e i loro esiti restano nel
    # registro. La forma nuova si prova con A24-A28.
    ('A24', 'FC.09', 'lib/features/amici/gli_amici_online.dart',
     '      !tendinaFresca(s, adesso);',
     '      true;',
     RUBRICA, 'al piu\' una chiamata'),
    ('A25', 'FC.09', 'lib/features/amici/gli_amici_online.dart',
     '    if (t == null) return null;',
     '    if (t == null) return 0;',
     RUBRICA, 'al piu\' una chiamata'),
    ('A26', 'FC.09', 'lib/features/amici/amici_screen.dart',
     '  bool _suOnline = false;',
     '  bool _suOnline = true;',
     RUBRICA, 'Offline di default'),
    ('A27', 'FC.09', 'lib/features/amici/amici_screen.dart',
     'onOffline: () => setState(() => _suOnline = false),',
     'onOffline: () {},',
     RUBRICA, 'Offline li nasconde'),
    ('A28', 'FC.09', 'lib/features/amici/gli_amici_online.dart',
     '          onTap: onRiprova,',
     '          onTap: () {},',
     RUBRICA, 'le strade'),
    # FC.09, il tetto condiviso e i testi del fondatore.
    ('A29', 'FC.09', 'lib/core/cerchio/il_cerchio_sociale.dart',
     '      if (_tendina == null) await _rileggiLUltimaTendina();',
     '      _tendina = null;',
     RUBRICA, 'tetto condiviso'),
    ('A30', 'FC.09', 'lib/features/cerchio/la_tendina_del_cerchio.dart',
     '                            if (sociale.tendinaNonAggiornata &&',
     '                            if (false &&',
     RUBRICA, 'tetto condiviso'),
    ('A31', 'FC.09', 'lib/core/cerchio/il_cerchio_sociale.dart',
     '      final testo = p.getString(chiaveDellUltimaTendina);',
     '      const String? testo = null;',
     RUBRICA, 'tetto condiviso'),
    ('A32', 'FC.09', 'lib/features/amici/gli_amici_online.dart',
     '        Text(IlCerchioSociale.rigaDellaTendinaCheNonArriva,',
     '        Text(EsitoDelGesto.silenzio.riga!,',
     RUBRICA, 'le strade'),
    ('A33', 'FC.09', 'lib/features/amici/gli_amici_online.dart',
     "      Text('Chi del tuo Cerchio è qui con te, adesso.',",
     "      Text('I tuoi amici del Cerchio che sono qui adesso.',",
     RUBRICA, 'Offline li nasconde'),
    # La causa (b) dell'icona nera, innestata: la riga perde l'icona.
    # A34 e' stata provata sulla riga com'era prima dell'ordine FC voce 10,
    # che le ha aggiunto il nome per la lettera nel tondo: il pezzo e' quello
    # di adesso.
    ('A34', 'FC.09', 'lib/features/cerchio/il_tuo_cerchio_screen.dart',
     '                IconaTonda(icona: persona.icona, lato: 44, nome: persona.nome),',
     "                IconaTonda(icona: '', lato: 44, nome: persona.nome),",
     RUBRICA, 'Offline li nasconde'),
    # FC.10, la porta sola del segno e l'emblema dell'amico.
    ('A35', 'FC.10', 'lib/core/astro/night_sky.dart',
     '  const NightSky._();',
     '  const NightSky._();\n\n'
     '  static Zodiac sunSign(DateTime date) =>\n'
     '      Zodiac.values[(sunEclipticLongitude(date) / 30).floor() % 12];',
     PORTA, 'solo nella porta'),
    ('A36', 'FC.10', 'lib/core/cerchio/le_icone_del_cerchio.dart',
     "      '${FamigliaDelleIcone.segno.name}:${segno.index}';",
     "      '${FamigliaDelleIcone.segno.name}:${(segno.index + 1) % 12}';",
     EMBLEMA, 'dodici nascite'),
    ('A37', 'FC.10', 'lib/core/astro/il_segno_del_cielo.dart',
     '    final v = gradi % 360.0;',
     '    final v = (gradi + 1.5) % 360.0;',
     EMBLEMA, 'le cuspidi'),
    ('A38', 'FC.10', 'lib/features/cerchio/widgets/disegni_del_cerchio.dart',
     '          fotogramma == null && !subito ? lettera() : figlio,',
     '          figlio,',
     EMBLEMA, 'nessun tondo vuoto'),
    ('A39', 'FC.10', 'lib/core/astro/il_segno_del_cielo.dart',
     "      'nascita. In assenza dell\\'ora di nascita si usa mezzogiorno.';",
     "      'nascita.';",
     EMBLEMA, 'il metodo'),
    # FC.10, parte prima: l'ultimo dato e l'ora del telefono.
    ('A40', 'FC.10', 'lib/core/cerchio/il_cerchio_sociale.dart',
     '  static const Duration vitaDellUltimoDato = Duration(hours: 1);',
     '  static const Duration vitaDellUltimoDato = Duration(hours: 2);',
     ORA, 'sessantuno minuti'),
    ('A41', 'FC.10', 'lib/features/cerchio/l_ora_del_telefono.dart',
     '  if (MediaQuery.alwaysUse24HourFormatOf(context)) {',
     '  if (true) {',
     ORA, 'dodici ore'),
    ('A42', 'FC.10', 'lib/core/cerchio/il_cerchio_sociale.dart',
     '    await _dimenticaLUltimaTendina();',
     '    // dimenticata la cancellazione',
     ORA, 'si cancella'),
    # FC.11, le rosse curate e il cancello.
    ('A43', 'FC.11', 'docs/ordini/ORDINE_EK_MANIFESTO.md',
     'ASPETTA: lo sguardo del fondatore sui volti nel LIVE',
     'Lo sguardo del fondatore sui volti nel LIVE',
     'flutter test test/ordine_ek_guard_test.dart -r expanded',
     'quale gesto aspetta'),
    ('A44', 'FC.11', 'lib/core/face/soglie_della_scansione.dart',
     '/// ASPETTA: una persona davanti al Realme',
     '/// Aspetta una persona davanti al Realme',
     'flutter test test/le_soglie_della_scansione_sono_provvisorie_test.dart -r expanded',
     'quale gesto aspettano'),
    ('A45', 'FC.11', 'tool/sbarramento.sh',
     '  if [ "$SALTATE_DEI_PEZZI" -gt 0 ]; then',
     '  if false; then',
     CANCELLO, 'un caso saltato'),
    ('A46', 'FC.11', 'functions/package.json',
     'node --test --test-reporter=spec lib/',
     'node --test lib/',
     CANCELLO, 'rapporto spec'),
    ('A47', 'FC.11', 'test/anteprima_card_della_rivelazione_test.dart',
     "    final scrivi = Platform.environment['ANTEPRIMA_CARD'] == '1';",
     "    markTestSkipped('di nuovo saltata');\n"
     "    final scrivi = Platform.environment['ANTEPRIMA_CARD'] == '1';",
     CANCELLO, 'si salta da sola'),
    ('A12', 'FC.02', SOGGETTO,
     '      amico == null ? s : s.dettoDi(nomeAmico!);',
     '      s;',
     'flutter test test/il_nome_del_segno_non_si_spezza_test.dart -r expanded',
     'il segno di Lucia'),
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
        n = testo.count(vecchio)
        if n != 1:
            return '%s (%s) INNESTO NON ENTRATO: il pezzo vecchio compare %d volte' % (sigla, voce, n)
        testo = testo.replace(vecchio, nuovo)
        scrivi(percorso, testo.replace('\n', '\r\n') if crlf else testo)
        dopo = leggi(percorso).replace('\r\n', '\n')
        if nuovo and vecchio in nuovo:
            entrato = dopo.count(nuovo) == 1
        else:
            entrato = (nuovo in dopo if nuovo else True) and dopo.count(vecchio) == 0
        if not entrato:
            return '%s (%s) INNESTO NON ENTRATO al controllo' % (sigla, voce)
        esito = subprocess.run(comando, shell=True, capture_output=True,
                               text=True, encoding='utf-8', errors='replace')
        uscita = esito.stdout + esito.stderr
        rossa = esito.returncode != 0
        cadute = [r.strip()[:170] for r in uscita.splitlines() if '[E]' in r]
        nel_bersaglio = any(bersaglio in c for c in cadute)
        misure = [r.strip()[:220] for r in uscita.splitlines()
                  if r.startswith('ORDINE FC')][:2]
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
    os.makedirs('docs/collaudo/FC', exist_ok=True)
    registro = 'docs/collaudo/FC/regola_a_fc.txt'
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
