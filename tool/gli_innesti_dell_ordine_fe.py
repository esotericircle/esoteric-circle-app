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
import time

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
     '        righe.add(LaLeggeDellaCoerenza.ilSecondoMaestro(altri));\n',
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
    # FE.12, il filo vive quanto il consulto.
    ('A14', 'FE.12', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '        _filoDiPrima = entroLOra\n',
     '        _filoDiPrima = false\n',
     'flutter test test/il_filo_vive_quanto_il_consulto_test.dart -r expanded',
     'entro l\'ora il Maestro riceve le battute di prima'),
    ('A15', 'FE.12', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '            _adesso.difference(ultimo) <= IlFiloDelConsulto.vita;\n',
     '            _adesso.difference(ultimo) <= const Duration(days: 1);\n',
     'flutter test test/il_filo_vive_quanto_il_consulto_test.dart -r expanded',
     'oltre l\'ora il consulto e\' nuovo'),
    ('A16', 'FE.12', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '  static const int _battuteDelFilo = 20;\n',
     '  static const int _battuteDelFilo = 200;\n',
     'flutter test test/il_filo_vive_quanto_il_consulto_test.dart -r expanded',
     'il filo porta al piu'),
    # FE.13, i pareri del Consiglio entrano nel filo (il file ha i fine
    # riga di Windows: i pezzi stanno su una riga sola, senza il suo a capo).
    ('A17', 'FE.13', 'lib/features/maestri/ask/ask_maestri_screen.dart',
     '    if (!lens.ripiego) {',
     '    if (false) {',
     'flutter test test/ask_maestri_test.dart -r expanded',
     'i pareri del Consiglio entrano nel filo'),
    ('A18', 'FE.13', 'lib/features/maestri/ask/ask_maestri_screen.dart',
     '    if (!lens.ripiego) {',
     '    if (true) {',
     'flutter test test/ask_maestri_test.dart -r expanded',
     'il ripiego dell\'oracolo non entra nel filo'),
    # FE.14, i nomi nella regola del secondo Maestro.
    ('A19', 'FE.14', 'lib/core/chat/il_filo_del_consulto.dart',
     "        ? 'una riga che comincia con il nome di ${altri.single}'",
     "        ? 'una riga'",
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'il secondo Maestro riceve'),
    # FE.07, il tempo senza voce non si scala; e il conto scritto per intero
    # (difetto dell'ordine EX voce 01 trovato lavorando alla voce 07).
    ('A20', 'FE.07', 'functions/src/live.ts',
     '      if (senzaVoce[s.id] === true && s.secondi <= SECONDI_SENZA_VOCE) {',
     '      if (senzaVoce[s.id] === true) {',
     'cd functions && npm test',
     'oltre il tetto si'),
    ('A21', 'FE.07', 'functions/src/live.ts',
     '      if (senzaVoce[s.id] === true && s.secondi <= SECONDI_SENZA_VOCE) {',
     '      if (false) {',
     'cd functions && npm test',
     'la sessione senza voce non scala'),
    ('A22', 'FE.07', 'functions/src/live.ts',
     '    conto.daContare[sessione] = mese;\n    t.set(rif, conto, {mergeFields: I_CAMPI_DEL_CONTO});',
     '    conto.daContare[sessione] = mese;\n    t.set(rif, conto, {merge: true});',
     'cd functions && npm test',
     'non si somma una seconda volta'),
    ('A23', 'FE.07', 'lib/features/maestri/live/schermata_live.dart',
     '      if (!sentito) {\n        await _laVoceNonParte(senzaVoce: true);',
     '      if (!sentito) {\n        await _laVoceNonParte(senzaVoce: false);',
     'flutter test test/la_voce_che_non_parte_test.dart -r expanded',
     'il saluto che non si sente'),
    ('A24', 'FE.07', 'lib/features/maestri/live/stato_della_schermata_live.dart',
     "      'La voce non riesce a raggiungerti. Continuo a scriverti.';",
     "      'La voce non arriva. Continuo a scriverti.';",
     'flutter test test/la_voce_che_non_parte_test.dart -r expanded',
     'quella dell\'ordine'),
    # FE.17, il parere sul tema resta il punto fermo.
    ('A25', 'FE.17', 'lib/core/chat/il_filo_del_consulto.dart',
     '            pareri.any((x) => x.maestro == p.maestro) ? pareri : [...pareri, p],',
     '            [for (final x in pareri) if (x.maestro != p.maestro) x, p],',
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'una digressione non cancella'),
    ('A26', 'FE.17', 'lib/services/ai/maestro_persona.dart',
     "      if (filo.isNotEmpty) ...['', LaLeggeDellaCoerenza.controlloFinale],\n",
     '',
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'senza consulto'),
    ('A27', 'FE.17', 'lib/core/chat/il_filo_del_consulto.dart',
     "    return '${corto(prima, 160)} ${corto(riga, 160)}';",
     "    return corto(riga, 220);",
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'il primo turno apre la scheda'),
    ('A28', 'FE.20', 'lib/core/chat/il_filo_del_consulto.dart',
     '      if (!giaNellaStoria) {',
     '      if (true) {',
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'non riceve la scheda'),
    ('A29', 'FE.05', 'lib/features/maestri/live/la_voce_ricevuta.dart',
     '        if (lungo >= LaVoceCheTace.quiete) r.add((da, lungo));',
     '        if (lungo >= const Duration(seconds: 2)) r.add((da, lungo));',
     'flutter test test/la_voce_ricevuta_test.dart -r expanded',
     'a meta\' risposta e\' una rottura'),
    ('A30', 'FE.17', 'lib/core/chat/il_filo_del_consulto.dart',
     "      'estrai uno nuovo a ogni domanda, lo rileggi. Se cambi parere, dillo '\n",
     "      'Se cambi parere, dillo '\n",
     'flutter test test/il_filo_del_consulto_test.dart -r expanded',
     'non riceve la scheda'),
    ('A31', 'FE.08', 'lib/features/maestri/ask/ask_maestri_screen.dart',
     "    // FE.13). Il Maestro scelto ritrova il consulto dal filo.\n    if (!mounted) return;",
     "    // FE.13). Il Maestro scelto ritrova il consulto dal filo.\n"
     "    final mem = await services.memory.loadMemory(maestro);\n"
     "    await services.memory.saveMemory(maestro, mem.copyWith(sessionSummary: "
     "'Nel Consiglio la persona ti ha chiesto: «$theme».'));\n    if (!mounted) return;",
     'flutter test test/ask_maestri_test.dart -r expanded',
     'Chiusura del cerchio'),
    ('A32', 'FE.05', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '    if (natal != null) {\n      unawaited(MaestroPersona.preparaIlCielo(natal).catchError(',
     '    if (false) {\n      unawaited(MaestroPersona.preparaIlCielo(natal!).catchError(',
     'flutter test test/la_chat_prepara_il_cielo_test.dart -r expanded',
     'il cielo diventa pronto'),
    ('A33', 'FE.22', 'lib/features/maestri/chat/maestro_chat_screen.dart',
     "                      testo: 'Chat precedenti',",
     "                      testo: 'I giorni prima',",
     'flutter test test/i_nomi_del_menu_e_del_diario_test.dart -r expanded',
     'i nomi vecchi non restano'),
    ('A34', 'FE.22', 'lib/features/ricordi/ricordi_screen.dart',
     "Text('Diario Cosmico',",
     "Text('Cosmic Journal',",
     'flutter test test/i_nomi_del_menu_e_del_diario_test.dart -r expanded',
     'i nomi vecchi non restano'),
    ('A35', 'FE.22', 'lib/features/maestri/chat/maestro_chat_screen.dart',
     "  static String di(Maestro maestro) => 'LIVE con ${maestro.nomeAVideo}';",
     "  static String di(Maestro maestro) => 'LIVE con Medora';",
     'flutter test test/i_nomi_del_menu_e_del_diario_test.dart -r expanded',
     'porta il nome del Maestro'),
    ('A36', 'FE.22', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '    _filoDiPrima = const [];\n    IlFiloDelConsulto.chiudi();\n',
     '',
     'flutter test test/la_nuova_chat_chiude_il_filo_test.dart -r expanded',
     'niente filo di prima'),
    # FE.22, il Diario Cosmico sul server: le prove d) - k) e le voci
    # 22.10, 22.15 e 22.17.
    ('A37', 'FE.22.6', 'lib/features/ricordi/azioni_del_responso.dart',
     '    WidgetsBinding.instance.addPostFrameCallback((_) => _annota());\n',
     '',
     'flutter test test/custodisci_e_parlane_test.dart -r expanded',
     'il responso entra nel Diario da se'),
    ('A38', 'FE.22.7', 'lib/features/ricordi/azioni_del_responso.dart',
     '    setState(() => _custodito = stella);\n    await registro.mettiLaStella(',
     '    setState(() => _custodito = stella);\n    if (stella == !stella) await registro.mettiLaStella(',
     'flutter test test/custodisci_e_parlane_test.dart -r expanded',
     'una stella sola'),
    ('A39', 'FE.22.7', 'lib/features/ricordi/ricordi_screen.dart',
     '/// LE TUE CARTE. Ordine CG voce 07.\n',
     "const String unaSecondaStella = 'stellaNelDiario';\n\n/// LE TUE CARTE. Ordine CG voce 07.\n",
     'flutter test test/custodisci_e_parlane_test.dart -r expanded',
     'da UNA porta sola'),
    ('A40', 'FE.22.8', 'lib/core/ricordi/registro_dei_ricordi.dart',
     '      return mesi.values.any((v) => v.stella && v.giorno == giorno);',
     '      return mesi.values.any((v) => v.giorno == giorno);',
     'flutter test test/il_diario_cosmico_sul_server_test.dart -r expanded',
     'il giorno eredita la stella'),
    ('A41', 'FE.22.10', 'lib/features/ricordi/ricordi_screen.dart',
     '    if (!_stella || riga == _salvata) return;',
     '    if (!_stella) return;',
     'flutter test test/il_diario_cosmico_sul_server_test.dart -r expanded',
     'si salva una volta'),
    ('A42', 'FE.22.10', 'lib/services/ai/maestro_persona.dart',
     'class MaestroPersona {',
     "Object? laRigaDellaPersona(Map<String, Object?> voce) => voce['nota'];\n\nclass MaestroPersona {",
     'flutter test test/il_diario_cosmico_sul_server_test.dart -r expanded',
     'non va a nessun modello'),
    ('A43', 'FE.22.12', 'lib/core/ricordi/ricordo_custodito.dart',
     "    if (versione >= 1) return daMappa(voce['c']);\n    return daMappa(voce);",
     "    return daMappa(voce['c'] ?? versione);",
     'flutter test test/il_diario_cosmico_sul_server_test.dart -r expanded',
     'formato 0 si ridisegna'),
    ('A44', 'FE.22.18', 'lib/core/ricordi/registro_dei_ricordi.dart',
     '    await ripesca(VoceDelRicordo.chiaveDelMese(adesso));',
     '    for (var i = 0; i < 12; i++) {\n      await ripesca(VoceDelRicordo.chiaveDelMese(\n          DateTime(adesso.year, adesso.month - i)));\n    }',
     'flutter test test/il_diario_cosmico_sul_server_test.dart -r expanded',
     'costa al massimo'),
    ('A45', 'FE.22.15', 'lib/features/ricordi/ricordi_screen.dart',
     "                : (vecchia ? _LaVoceCheTorna.rigaDellArchivio : ''),",
     "                : (vecchia ? '' : ''),",
     'flutter test test/il_diario_cosmico_sul_server_test.dart -r expanded',
     'Sto riprendendo questo'),
    ('A46', 'FE.22.16', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '      _dalDiario = await leggi();',
     '      _dalDiario = [\n        for (final m in _archivio)\n          ConversazionePassata(\n              id: m.conversazione,\n              titolo: m.text,\n              ultimoMomento: m.at,\n              primaDomanda: m.text),\n      ];',
     'flutter test test/la_porta_delle_conversazioni_e_una_test.dart -r expanded',
     'nascono solo dalla lettura del Diario'),
    ('A47', 'FE.22.17', 'lib/features/maestri/chat/maestro_chat_screen.dart',
     '    registro?.togli(RegistroDeiRicordi.chiaveDellaConversazione(\n        controller.maestro.id, c.id));\n',
     '',
     'flutter test test/chat_initial_message_test.dart -r expanded',
     'si cancella una conversazione'),
    ('A48', 'FE.22.9', 'lib/core/ricordi/vista_dei_ricordi.dart',
     '    if (_filtri.contains(FiltroDeiRicordi.segnati) && !v.stella) return false;\n',
     '',
     'flutter test test/custodisci_e_parlane_test.dart -r expanded',
     'una stella sola'),
    ('A49', 'FE.22.13', 'lib/core/ricordi/registro_dei_ricordi.dart',
     '    if (righe.isEmpty) return;\n',
     '',
     'flutter test test/il_diario_cosmico_sul_server_test.dart -r expanded',
     'una risposta vuota del server'),
    ('A50', 'FE.22.1', 'lib/features/maestri/chat/maestro_chat_screen.dart',
     '                itemBuilder: (context) => [\n                  const PopupMenuItem<Object>(\n                    key: Key(\'chat_conversazione_nuova\'),',
     '                itemBuilder: (context) => [\n                  const PopupMenuDivider(height: 9),\n                  const PopupMenuItem<Object>(\n                    key: Key(\'chat_conversazione_nuova\'),',
     'flutter test test/chat_initial_message_test.dart -r expanded',
     'non comincia con un separatore'),
    # La guardia BX del Calendario, riscritta con la lapide dopo la FE.01.
    ('A51', 'FE.01', 'lib/core/astro/il_cielo_che_arriva.dart',
     'Isolate.run(() => ProssimiEventi.da(',
     'Isolate.run(() => ProssimiEventi .da(',
     'flutter test test/il_centro_della_barra_dice_eventi_cosmici_test.dart -r expanded',
     'il conto alla rovescia e\' uscito dalla barra'),
    # Le due guardie del LIVE riscritte con la lapide dopo la FE.07.
    ('A52', 'FE.07', 'lib/features/maestri/live/schermata_live.dart',
     '    _chiudiLaSessione(senzaVoce: senzaVoce);\n',
     '',
     'flutter test test/il_live_chiude_la_sessione_e_tiene_lo_schermo_test.dart -r expanded',
     'OGNI STRADA CHE ESCE DAL LIVE'),
    ('A53', 'FE.07', 'lib/features/maestri/live/schermata_live.dart',
     '            ? LeTreFrasiDelLive.di(scritto, domanda: _domandaDelTurno)',
     '            ? scritto',
     'flutter test test/il_live_dice_tre_frasi_e_le_scrive_a_macchina_test.dart -r expanded',
     'la voce e il testo passano dalle tre frasi'),
    ('A54', 'FE.07', 'lib/features/maestri/live/schermata_live.dart',
     '      await _aspettaCheTaccia(s.lavoratore);\n    } catch (errore) {',
     '      await Future<void>.delayed(Duration.zero);\n    } catch (errore) {',
     'flutter test test/il_microfono_aspetta_che_la_voce_taccia_test.dart -r expanded',
     'passa dalla regola'),
    ('A55', 'FE.07', 'lib/features/maestri/live/schermata_live.dart',
     '            anticipata.testo == pezzo &&',
     '            anticipata.testo.isNotEmpty &&',
     'flutter test test/la_voce_della_prima_frase_si_compone_prima_test.dart -r expanded',
     'parte solo dalla risposta intera'),
    # Le cure della suite intera del 6 ottobre: l'apertura della chat che
    # aspettava il filo (padre 946a51ed), la chiave del filo fuori dai dati
    # della persona, l'informativa del Diario.
    ('A56', 'FE.09', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '    unawaited(IlFiloDelConsulto.carica());',
     '    await IlFiloDelConsulto.carica();',
     'flutter test test/la_memoria_non_zittisce_un_maestro_test.dart test/il_maestro_non_resta_muto_test.dart -r expanded',
     'NESSUNA MEMORIA SI ASPETTA'),
    ('A57', 'FE.09', 'lib/core/identity/cio_che_e_tuo.dart',
     "    'consulto.',\n",
     '',
     'flutter test test/niente_resta_di_te_test.dart -r expanded',
     'coperta dalla verita'),
    ('A58', 'FE.22', 'lib/core/legal/privacy_policy.dart',
     "        'resta finché vive il tuo account; dopo 12 mesi il contenuto delle '",
     "        'resta 24 mesi; dopo 12 mesi il contenuto delle '",
     'flutter test test/la_policy_nomina_i_dati_nuovi_test.dart -r expanded',
     'il Diario NON scade'),
    # Le cure delle anteprime FE.22 a 360x797: la stanza mai collegata, la
    # data corta, il dialogo alto quanto il suo testo, il cambio d'ora, il
    # singolare.
    ('A59', 'FE.07', 'lib/features/maestri/live/schermata_live.dart',
     '          await daLiberare.dispose();\n',
     '',
     'flutter test test/le_anteprime_dell_ordine_fe_test.dart -r expanded',
     'la voce che non parte'),
    ('A60', 'FE.22.1', 'lib/features/maestri/chat/maestro_chat_screen.dart',
     '                            corto: true),',
     '                            corto: false),',
     'flutter test test/le_anteprime_dell_ordine_fe_test.dart -r expanded',
     'coi nomi nuovi'),
    ('A61', 'FE.22.17', 'lib/features/maestri/chat/maestro_chat_screen.dart',
     '        // Lo scorrimento gli da\' l\'altezza del suo testo.\n        content: SingleChildScrollView(\n          child: ParagrafiDiLettura(\n            testo: domanda,',
     '        // Lo scorrimento gli da\' l\'altezza del suo testo.\n        content: SizedBox(\n          height: 900,\n          child: ParagrafiDiLettura(\n            testo: domanda,',
     'flutter test test/le_anteprime_dell_ordine_fe_test.dart -r expanded',
     'la conferma del cestino'),
    ('A62', 'FE.22', 'lib/core/ricordi/riassunti_del_tempo.dart',
     '      DateTime(giorno.year, giorno.month, giorno.day + quanti);',
     '      giorno.add(Duration(days: quanti));',
     'flutter test test/il_diario_cosmico_sul_server_test.dart -r expanded',
     'col cambio'),
    ('A63', 'FE.22', 'lib/features/ricordi/ricordi_screen.dart',
     "'${riassunto.quanteVoci == 1 ? 'momento' : 'momenti'}, '",
     "'momenti, '",
     'flutter test test/il_diario_cosmico_sul_server_test.dart -r expanded',
     'la settimana mostra la stella'),
    ('A64', 'FE.07', 'lib/features/maestri/live/schermata_live.dart',
     "                child: const Text('Continua per iscritto'),",
     "                child: const Text('Chiudi'),",
     'flutter test test/le_anteprime_dell_ordine_fe_test.dart -r expanded',
     'non raggiungibile'),
    # FE.08 e FE.11: il filo a ogni strada, la frase ripresa in tutto il
    # consulto.
    ('A65', 'FE.11', 'lib/core/chat/il_filo_del_consulto.dart',
     '    for (final t in testi) {',
     '    for (final t in testi.take(1)) {',
     'flutter test test/il_filo_arriva_a_ogni_strada_test.dart -r expanded',
     "che non e' l'ultima"),
    ('A66', 'FE.11', 'lib/core/chat/il_filo_del_consulto.dart',
     "            if ((m.seguito ?? '').trim().isNotEmpty) m.seguito!,\n",
     '',
     'flutter test test/il_filo_arriva_a_ogni_strada_test.dart -r expanded',
     'si trova nel seguito'),
    ('A67', 'FE.11', 'lib/core/chat/il_filo_del_consulto.dart',
     '    ricordaLaFrase(risposta);\n',
     '',
     'flutter test test/il_filo_arriva_a_ogni_strada_test.dart -r expanded',
     'ogni risposta annotata'),
    ('A68', 'FE.08', 'lib/core/viaggio/il_segno_dell_animale.dart',
     '    return testo.isEmpty ? riserva : _nelFilo(riserva, testo);',
     '    return riserva;',
     'flutter test test/il_filo_arriva_a_ogni_strada_test.dart -r expanded',
     'animale guida entra nel filo'),
    ('A69', 'FE.08', 'lib/core/chat/il_filo_del_consulto.dart',
     "    return blocco.isEmpty ? istruzione : '$istruzione\\n\\n$blocco';",
     '    return istruzione;',
     'flutter test test/il_filo_arriva_a_ogni_strada_test.dart -r expanded',
     'fuori dal provider'),
    # FE.10 e 17: la rete della coerenza, nella forma scelta dal fondatore.
    ('A70', 'FE.17', 'lib/core/chat/la_rete_della_coerenza.dart',
     '    if (!serve(chi)) return null;\n',
     '',
     'flutter test test/la_rete_della_coerenza_test.dart -r expanded',
     'non chiama il modello'),
    ('A71', 'FE.17', 'lib/core/chat/la_rete_della_coerenza.dart',
     '    for (final t in dalFilo) {',
     '    for (final t in dalFilo.take(0)) {',
     'flutter test test/la_rete_della_coerenza_test.dart -r expanded',
     'legge e, se contraddice'),
    ('A72', 'FE.17', 'lib/core/chat/la_rete_della_coerenza.dart',
     "      if (j is! Map || j['contraddice'] != true) return null;",
     '      if (j is! Map) return null;',
     'flutter test test/la_rete_della_coerenza_test.dart -r expanded',
     'non si legge, non corregge'),
    ('A73', 'FE.17', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '      reply = await _laReteDellaCoerenza(',
     '      reply = await (_laReteDellaCoerenza)(',
     'flutter test test/la_rete_della_coerenza_test.dart -r expanded',
     'passa dal controllore'),
    # FE.22.10: la riga della persona entra nel filo del consulto, che va
    # al modello e alla rete della coerenza.
    ('A74', 'FE.22.10', 'lib/core/ricordi/registro_dei_ricordi.dart',
     [("import 'voce_del_ricordo.dart';",
       "import 'voce_del_ricordo.dart';\nimport '../chat/il_filo_del_consulto.dart';"),
      ("      {String? nota}) async {\n",
       "      {String? nota}) async {\n    if (nota != null) IlFiloDelConsulto.ricordaLaFrase(nota);\n")],
     None,
     'flutter test test/la_riga_della_persona_non_parte_test.dart -r expanded',
     "nella chiamata al modello la riga non c'e'"),
    # FE.20, la correzione della rete su Flash-Lite.
    ('A75', 'FE.20', 'lib/features/maestri/chat/maestro_chat_controller.dart',
     '      leggera: true,\n',
     '',
     'flutter test test/la_rete_della_coerenza_test.dart -r expanded',
     'passa dal controllore'),
    ('A76', 'FE.20', 'lib/services/ai/firebase_maestro_ai_provider.dart',
     '      model: leggera\n          ? kMaestroBreveModel\n',
     '      model: leggera\n          ? kMaestroChatModel\n',
     'flutter test test/la_rete_della_coerenza_test.dart -r expanded',
     'passa dal controllore'),
    # FE.22.6, ogni lettura entra nel Diario da se'.
    ('A77', 'FE.22.6', 'lib/features/ricordi/azioni_del_responso.dart',
     '  void initState() {\n    super.initState();\n    _annota();\n  }\n',
     '  void initState() {\n    super.initState();\n  }\n',
     'flutter test test/ogni_lettura_entra_nel_diario_test.dart -r expanded',
     'entra senza scorrere'),
    ('A78', 'FE.22.6', 'lib/features/ricordi/azioni_del_responso.dart',
     '  late final DateTime _quando = widget.quando ?? _adesso;',
     '  late final DateTime _quando = _adesso;',
     'flutter test test/ogni_lettura_entra_nel_diario_test.dart -r expanded',
     'entra senza scorrere'),
    ('A79', 'FE.22.6', 'lib/features/angels/angels_screen.dart',
     "                  arte: 'angeli',",
     "                  arte: 'angelo',",
     'flutter test test/ogni_lettura_entra_nel_diario_test.dart -r expanded',
     'punto di annotazione'),
    # Regola B fatta DOPO il tocco della FE.07, e dichiarata: la guardia EG
    # del rifiuto del LIVE, che conta le ragioni e le loro frasi.
    ('B10', 'FE.07', 'lib/features/maestri/live/stato_della_schermata_live.dart',
     '        PerchePerILiveNonSiApre.vocePerduta => rigaDellaVocePerduta,',
     '        PerchePerILiveNonSiApre.vocePerduta =>\n          rigaDelMaestroNonRaggiungibile,',
     'flutter test test/il_live_non_e_mai_un_vicolo_cieco_test.dart -r expanded',
     'le tre ragioni del rifiuto'),
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


def con_pazienza(fai):
    """Windows tiene a volte un file chiuso per qualche istante (Errno 22 o
    13, mentre l'analizzatore o la suite lo leggono): si riprova per due
    minuti prima di arrendersi. Il 6 ottobre 2026 lo strumento e' caduto due
    volte cosi', a meta' innesto."""
    for _ in range(240):
        try:
            return fai()
        except OSError:
            time.sleep(0.5)
    return fai()


def scrivi(p, s):
    con_pazienza(lambda: io.open(p, 'w', encoding='utf-8', newline='').write(s))


def un_innesto(sigla, voce, percorso, vecchio, nuovo, comando, bersaglio):
    copia = percorso + '.copia_regola_a'
    con_pazienza(lambda: shutil.copyfile(percorso, copia))
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
        con_pazienza(lambda: shutil.copyfile(copia, percorso))
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
