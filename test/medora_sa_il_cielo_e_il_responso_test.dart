// ignore_for_file: avoid_print, prefer_const_constructors
import 'dart:io';

import 'package:esoteric_circle/core/astro/effemeridi.dart';
import 'package:esoteric_circle/core/astro/il_cielo_detto.dart';
import 'package:esoteric_circle/core/astro/il_cielo_per_il_maestro.dart';
import 'package:esoteric_circle/core/chat/i_responsi_di_oggi.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/sorgente_natale.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/ricordi/azioni_del_responso.dart';
import 'package:esoteric_circle/services/ai/le_funzioni_del_cielo.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **MEDORA SA IL CIELO DI OGNI GIORNO E NON NEGA IL RESPONSO.** Ordine EV
/// voci 03 e 04.
///
/// Il fondatore: *"Medora in chat deve sapere qual è la situazione astrale
/// oggi e di ogni giorno di qualunque mese e anno"*, e *"Medora nega il
/// transito del responso dell'oroscopo o altra funzionalità da cui parte la
/// domanda."* Sulle catture dei fondatori, il 1 ottobre 2026, Medora diceva
/// di non avere tra le sue note che Urano fosse retrogrado, a chi l'aveva
/// appena letto nell'Oroscopo.
///
/// Qui si misura la meta' che vive nel codice: il cielo che le funzioni
/// restituiscono e' quello delle effemeridi (oggi, nel passato, nel futuro),
/// il modello le riceve, la regola di non nominare Urano non c'e' piu', la
/// rete del cielo detto non smentisce un'altra data, e il responso letto
/// arriva nell'istruzione con il suo "Da dove viene". La meta' che vive nel
/// modello (che le chiami e non neghi) si misura al banco, con le risposte
/// vere: `docs/collaudo/EV/medora_e_il_cielo.txt` e
/// `docs/collaudo/EV/medora_e_il_responso.txt`.
void main() {
  test('il cielo del 1 ottobre 2026: Urano retrogrado nei Gemelli', () {
    final g = IlCieloPerIlMaestro.delGiorno(DateTime(2026, 10, 1));
    final pianeti = (g['pianeti']! as List).cast<Map<String, Object?>>();
    final urano = pianeti.firstWhere((p) => p['corpo'] == 'Urano');
    print('ORDINE EV VOCE 03: il 2026-10-01 Urano in ${urano['segno']} a '
        '${urano['gradi']} gradi, retrogrado ${urano['retrogrado']}; '
        'retrogradi ${g['retrogradi']}');
    expect(pianeti, hasLength(10));
    expect(urano['segno'], 'Gemelli');
    expect(urano['retrogrado'], isTrue,
        reason: 'il cielo detto al Maestro nega il retrogrado che l\'Oroscopo '
            'mostra');
    expect(g['retrogradi'] as List, contains('Urano'));
  });

  test('ogni corpo detto e\' quello delle effemeridi, passato e futuro', () {
    var diversi = 0;
    var contati = 0;
    for (final giorno in [
      DateTime(2020, 12, 21),
      DateTime(2024, 4, 8),
      DateTime(2026, 10, 1),
      DateTime(2027, 3, 15),
      DateTime(2030, 1, 1),
    ]) {
      final g = IlCieloPerIlMaestro.delGiorno(giorno);
      final jd = IlCieloPerIlMaestro.giornoGiulianoDi(giorno);
      final pos = Effemeridi.tutte(jd);
      for (final p in (g['pianeti']! as List).cast<Map<String, Object?>>()) {
        final c = CorpoCeleste.values.firstWhere((c) => c.nome == p['corpo']);
        contati++;
        if (p['gradi'] != (pos[c]! % 30).floor()) diversi++;
      }
    }
    print('ORDINE EV VOCE 03: corpi detti diversi dalle effemeridi $diversi '
        'su $contati');
    expect(contati, greaterThanOrEqualTo(50));
    expect(diversi, 0);
  });

  test('la Grande Congiunzione del 21 dicembre 2020 c\'e\'', () {
    final g = IlCieloPerIlMaestro.delGiorno(DateTime(2020, 12, 21));
    final aspetti = (g['aspetti_fra_i_pianeti']! as List).join('; ');
    print('ORDINE EV VOCE 03: 2020-12-21 $aspetti');
    expect(aspetti, contains('Giove congiunzione Saturno'));
  });

  test('l\'anno 2026: Urano entra nei Gemelli e diventa retrogrado', () {
    final p = IlCieloPerIlMaestro.delPeriodo(
        DateTime(2026, 1, 1), DateTime(2026, 12, 31));
    final eventi = (p['eventi']! as List).cast<String>();
    final urano = eventi.where((e) => e.contains('Urano')).toList();
    print('ORDINE EV VOCE 03: eventi del 2026 ${eventi.length}; di Urano '
        '$urano');
    expect(urano.any((e) => e.contains('Urano entra in Gemelli')), isTrue);
    expect(urano.any((e) => e.contains('Urano diventa retrogrado')), isTrue);
    expect(eventi.where((e) => e.contains('Luna piena')).length,
        inInclusiveRange(12, 13));
  });

  test('le funzioni del cielo: il modello le riceve e rispondono', () {
    final strumenti = LeFunzioniDelCielo.perIlMaestro(
        adesso: DateTime(2026, 10, 1));
    expect(strumenti, hasLength(1));
    final giorno = LeFunzioniDelCielo.giorno({'data': '2026-10-01'});
    expect(giorno['data'], '2026-10-01');
    final sbagliato = LeFunzioniDelCielo.giorno({'data': 'domani'});
    expect(sbagliato['errore'], isNotNull);
    // E la porta del modello le passa: senza `tools` il modello non le vede.
    final provider =
        File('lib/services/ai/firebase_maestro_ai_provider.dart')
            .readAsStringSync();
    expect(provider, contains('tools: LeFunzioniDelCielo.perIlMaestro('),
        reason: 'il modello della chat e del LIVE non riceve le funzioni del '
            'cielo: torna a inventare o a negare');
  });

  test('il cielo di oggi per il modello nomina Urano e non lo vieta', () {
    final oggi = IlCieloDetto.pianetiDiOggi(DateTime(2026, 10, 1, 12));
    print('ORDINE EV VOCE 03: $oggi');
    expect(oggi, isNot(contains('Non nominare Urano')));
    expect(oggi, contains('Urano in Gemelli'));
    expect(oggi, contains('cielo_del_giorno'));
  });

  test('la rete del cielo detto lascia stare le altre date', () {
    final adesso = DateTime(2026, 10, 1, 12);
    String segno(DateTime giorno, String corpo) =>
        ((IlCieloPerIlMaestro.delGiorno(giorno)['pianeti']! as List)
                .cast<Map<String, Object?>>()
                .firstWhere((p) => p['corpo'] == corpo))['segno']!
            .toString();
    // Al presente storico, la forma che la rete legge: con un segno diverso
    // da quello di oggi, perche' senza la data la rete la smentirebbe.
    final giove2020 = segno(DateTime(2020, 12, 21), 'Giove');
    final saturno2000 = segno(DateTime(2000, 1, 1), 'Saturno');
    final marte2027 = segno(DateTime(2027, 10, 15), 'Marte');
    expect(giove2020, isNot(segno(adesso, 'Giove')));
    expect(saturno2000, isNot(segno(adesso, 'Saturno')));
    expect(marte2027, isNot(segno(adesso, 'Marte')));
    final vere = [
      'Oggi Urano è retrogrado in Gemelli e ti chiede di rivedere.',
      'Il 21 dicembre 2020 Giove è in $giove2020, accanto a Saturno.',
      'Nel 2000 Saturno è in $saturno2000.',
      'A ottobre 2027 Marte è in $marte2027.',
    ];
    final prese = [
      for (final f in vere)
        if (IlCieloDetto.smentite(f, adesso: adesso).isNotEmpty) f,
    ];
    print('ORDINE EV VOCE 03: frasi vere smentite ${prese.length} su '
        '${vere.length}');
    expect(prese, isEmpty);
    // E oggi resta sorvegliato.
    expect(
        IlCieloDetto.smentite('Oggi Urano è in Toro.', adesso: adesso),
        isNotEmpty);
  });

  test('la rete prende la Luna detta "oggi" nel segno sbagliato', () {
    // Dal banco del 1 ottobre 2026, risposta 2: la Luna era nei Gemelli.
    final adesso = DateTime(2026, 10, 1, 12);
    final prese = IlCieloDetto.smentite(
        'La Luna oggi si trova nel segno del Capricorno, nella sua fase '
        'calante.',
        adesso: adesso);
    print('ORDINE EV VOCE 03: Luna di oggi detta in Capricorno, smentite '
        '${prese.length}');
    expect(prese, isNotEmpty);
  });

  test('"la tua Luna" si confronta con la Luna di nascita', () {
    // Dal banco del 1 ottobre 2026, risposta 13: la Luna di nascita era in
    // Bilancia, quella del giorno nei Gemelli.
    final adesso = DateTime(2026, 10, 1, 12);
    const frase = 'Osserva oggi, con l\'aiuto della tua Luna in Gemelli, come '
        'il tuo bisogno di sicurezza si esprime.';
    final sbagliata = IlCieloDetto.smentite(frase,
        adesso: adesso, diNascita: const {'Sole': 'Cancro', 'Luna': 'Bilancia'});
    final giusta = IlCieloDetto.smentite(frase,
        adesso: adesso, diNascita: const {'Luna': 'Gemelli'});
    final senzaNascita = IlCieloDetto.smentite(frase, adesso: adesso);
    print('ORDINE EV VOCE 03: "la tua Luna in Gemelli" con la Luna di nascita '
        'in Bilancia smentite ${sbagliata.length}, in Gemelli '
        '${giusta.length}, senza nascita ${senzaNascita.length}');
    expect(sbagliata, isNotEmpty);
    expect(giusta, isEmpty);
    expect(senzaNascita, isEmpty);
  });

  test('un pianeta detto dove sta nel giorno chiesto non si toglie', () {
    // Dal banco del 1 ottobre 2026, risposta 20: sul 1 gennaio 2028 la rete
    // toglieva "Il transito di Giove in Vergine", che era giusto.
    final adesso = DateTime(2026, 10, 1, 12);
    const frase = 'Il transito di Giove in Vergine porta un\'attenzione '
        'particolare all\'organizzazione.';
    final senza = IlCieloDetto.smentite(frase, adesso: adesso);
    final con = IlCieloDetto.smentite(frase,
        adesso: adesso, altriGiorni: [DateTime(2028, 1, 1, 12)]);
    print('ORDINE EV VOCE 03: Giove in Vergine del 2028, smentito senza il '
        'giorno chiesto ${senza.length}, col giorno chiesto ${con.length}');
    expect(senza, isNotEmpty);
    expect(con, isEmpty);
    // E le funzioni del cielo segnano i giorni chiesti.
    final da = LeFunzioniDelCielo.giorniChiesti.length;
    LeFunzioniDelCielo.giorno({'data': '2028-01-01'});
    LeFunzioniDelCielo.periodo({'dal': '2026-12-01', 'al': '2026-12-31'});
    final giorni = LeFunzioniDelCielo.giorniDa(da);
    expect(giorni.first, DateTime(2028, 1, 1, 12));
    expect(giorni, contains(DateTime(2026, 12, 31, 12)));
    expect(giorni, contains(DateTime(2026, 12, 24, 12)),
        reason: 'il giorno della Luna piena di dicembre manca');
  });

  test('la risposta che rimanda si riconosce, quella che risponde no', () {
    // Dal banco del 1 ottobre 2026, seconda persona, risposte 15 e 19.
    final rinvii = [
      (
        'Quando torna diretto Urano?',
        'Per sapere quando Urano tornerà diretto, devo consultare il cielo '
            'del prossimo periodo.'
      ),
      (
        'Mercurio sarà retrogrado a novembre 2026?',
        'Per sapere se Mercurio sarà retrogrado a novembre 2026, devo '
            'consultare il cielo di quel periodo. Dimmi, per favore, quali '
            'sono le date precise che ti interessano.'
      ),
    ];
    // E il terzo, dal quinto giro: "mi serve la data esatta".
    rinvii.add((
      'Com\'è il cielo domani?',
      '[[CHIEDO]] Per il cielo di domani mi serve la data esatta, nel '
          'formato AAAA-MM-GG.'
    ));
    // E dal sesto: il cielo di un altro tempo detto a memoria, senza
    // chiamata (il provider chiede `rimanda` solo quando non c'e' stata).
    rinvii.add((
      'Ci sono eclissi nel 2027?',
      'La prima eclissi solare sarà il 2027-02-06, la seconda il 2027-02-20.'
    ));
    final risposte = [
      // Il cielo di oggi la descrizione lo porta gia': nessun sollecito.
      ('Dov\'è Venere oggi?', 'Venere oggi è a 8 gradi in Scorpione.'),
      // Una domanda che non parla del cielo non si sollecita mai.
      ('Come posso dormire meglio?', 'Dimmi in che giorno ti senti peggio.'),
    ];
    final presi = rinvii
        .where((r) => LeFunzioniDelCielo.rimanda(domanda: r.$1, risposta: r.$2))
        .length;
    final falsi = risposte
        .where((r) => LeFunzioniDelCielo.rimanda(domanda: r.$1, risposta: r.$2))
        .length;
    print('ORDINE EV VOCE 03: rinvii riconosciuti $presi su ${rinvii.length}, '
        'risposte prese per rinvii $falsi su ${risposte.length}');
    expect(presi, rinvii.length);
    expect(falsi, 0);
    // E il provider sollecita: senza questa riga il rinvio arriva a video.
    final provider = File('lib/services/ai/firebase_maestro_ai_provider.dart')
        .readAsStringSync();
    expect(provider, contains('LeFunzioniDelCielo.rimanda(domanda: userMessage'));
    expect(provider, contains('Content.text(LeFunzioniDelCielo.sollecito)'));
  });

  test('la Luna nuova di un giorno chiesto non si toglie', () {
    // Settimo giro dei banchi, seconda persona, risposta 19.
    final adesso = DateTime(2026, 10, 1, 12);
    const frase = '✦ Rileggi un messaggio importante prima di inviarlo, '
        'specialmente il mattino del 9 novembre, quando la Luna è nuova in '
        'Scorpione.';
    final da = LeFunzioniDelCielo.giorniChiesti.length;
    LeFunzioniDelCielo.periodo({'dal': '2026-11-01', 'al': '2026-11-30'});
    final con = IlCieloDetto.smentite(frase,
        adesso: adesso, altriGiorni: LeFunzioniDelCielo.giorniDa(da));
    print('ORDINE EV VOCE 03: "il 9 novembre la Luna è nuova in Scorpione" '
        'col mese chiesto smentite ${con.length}');
    expect(con, isEmpty);
  });

  test('"il tuo segno" e "quale carta" dal quinto giro dei banchi', () {
    final adesso = DateTime(2026, 10, 1, 12);
    final segno = IlCieloDetto.smentite(
        'Il Sole, nel tuo segno di Bilancia, forma un trigono con la Luna.',
        adesso: adesso,
        diNascita: const {'Sole': 'Cancro', 'Luna': 'Bilancia'});
    final giusto = IlCieloDetto.smentite(
        'Il tuo segno di Cancro sente la Luna di oggi.',
        adesso: adesso,
        diNascita: const {'Sole': 'Cancro'});
    final quale = IResponsiDiOggi.chiedeQuale('[[CHIEDO]] Per poterti dire '
        'cosa significa la carta al centro della stesa, dovrei sapere quale '
        'carta ti è uscita.');
    final nonChiede = IResponsiDiOggi.chiedeQuale(
        'Al centro della tua stesa è uscito l\'Imperatore.');
    print('ORDINE EV VOCI 03 E 04: "nel tuo segno di Bilancia" a un Cancro '
        'smentite ${segno.length}, "tuo segno di Cancro" ${giusto.length}; '
        'chiede quale $quale, risposta piena $nonChiede');
    expect(segno, isNotEmpty);
    expect(giusto, isEmpty);
    expect(quale, isTrue);
    expect(nonChiede, isFalse);
    final provider = File('lib/services/ai/firebase_maestro_ai_provider.dart')
        .readAsStringSync();
    expect(provider, contains('IResponsiDiOggi.chiedeQuale(text)'));
  });

  test('la descrizione porta il cielo di oggi e dice di non chiedere la data',
      () {
    final strumenti =
        LeFunzioniDelCielo.perIlMaestro(adesso: DateTime(2026, 10, 1, 12));
    final json = strumenti.first.toJson().toString();
    expect(json, contains('Urano a 5 gradi in Gemelli, retrogrado'));
    expect(json, contains('non chiederla di nuovo'));
    expect(json, contains('domani è 2026-10-02'));
  });

  testWidgets('il responso letto arriva a Medora col suo Da dove viene',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    IResponsiDiOggi.dimentica();
    const testo = 'Lavoro\nOggi rivedi un accordo prima di firmarlo.';
    const daDove = 'Da dove viene: Urano retrogrado nei Gemelli sulla tua '
        'Casa X.';
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AzioniDelResponso(
          palette: MaestroPalette.medora,
          maestro: Maestro.medora,
          responso: const ResponsoDaCustodire(
            arte: 'oroscopo',
            titolo: 'Il tuo oroscopo, Cancro',
            testo: testo,
            perIlMaestro: '$testo\n$daDove',
          ),
          aperturaDellaChat: 'Cosa dice il mio oroscopo di oggi?',
        ),
      ),
    ));
    // Senza toccare "Parlane": la persona ha letto e poi scrive a Medora.
    String istruzione() => MaestroPersona.systemInstruction(
          maestro: Maestro.medora,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
          natal: SorgenteNatale.daIdentita(BirthIdentityController()),
        );
    final letta = istruzione();
    expect(letta, contains(daDove),
        reason: 'Medora non riceve il responso che la persona ha appena '
            'letto: lo nega');
    expect(letta, contains('Non dire mai di non saperli'));
    // E toccando "Parlane con Medora" il responso diventa la partenza.
    await tester.tap(find.byKey(const Key('responso_parlane')));
    await tester.pump();
    final partita = istruzione();
    print('ORDINE EV VOCE 04: responso nell\'istruzione letto '
        '${letta.contains(daDove)}, dalla partenza '
        '${partita.contains('PARTENDO DA QUESTO RESPONSO')}');
    expect(partita, contains('PARTENDO DA QUESTO RESPONSO'));
    IResponsiDiOggi.dimentica();
  });

  test('con i dati di nascita il Maestro sa quali pianeti sono della persona',
      () {
    final istruzione = MaestroPersona.systemInstruction(
      maestro: Maestro.medora,
      profile: UserProfile.empty,
      memory: MaestroMemory.empty,
      natal: const NatalContext(sunSign: 'Cancro', moonSign: 'Bilancia'),
    );
    expect(istruzione, contains('del cielo di oggi, e quelli dei responsi di '
        'oggi, non sono i suoi'));
  });

  test('senza responsi oggi l\'istruzione non cambia', () {
    IResponsiDiOggi.dimentica();
    final natal = SorgenteNatale.daIdentita(BirthIdentityController());
    expect(natal.responsiDiOggi, isNull);
    expect(natal.carta, isNull);
  });

  test('l\'Oroscopo passa a Medora le schede con Da dove viene', () {
    final oroscopo =
        File('lib/features/horoscope/oroscopo_screen.dart').readAsStringSync();
    expect(oroscopo, contains("'Da dove viene: \${c.rigaDelLivello}'"),
        reason: 'il responso dell\'Oroscopo arriva a Medora senza il '
            'transito da cui nasce');
    expect(oroscopo, contains('perIlMaestro: perIlMaestro'));
  });
}
