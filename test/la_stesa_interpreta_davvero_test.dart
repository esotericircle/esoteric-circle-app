import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/le_forme_del_genere.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/confine_del_responso.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/la_chiave_di_lettura.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione_dati.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';
import 'la_lettura_finta_della_stesa.dart';

/// **LA STESA INTERPRETA DAVVERO.** Ordine EQ voce 04, 27 settembre 2026.
///
/// Il fondatore: *"LE RISPOSTE SONO TROPPO CRIPTICHE, SONO QUASI SENZA
/// SENSO"* e *"Ma una interpretazione la fa veramente o sono testi buttati li'
/// tanto per accontentare?"*. Erano testi fissi: il consiglio composto da
/// elenchi di frasi, e sotto ogni carta il significato del suo verso, lo
/// stesso nel passato, nel presente e nel futuro e per qualunque domanda.
///
/// Qui si pretende la strada nuova, pezzo per pezzo:
/// - il corpus delle carte nella loro posizione e' intero, e nessun suo
///   testo e' il significato generale;
/// - senza modello, ogni carta si legge col testo della sua posizione;
/// - al modello arrivano la domanda, l'argomento, la carta chiave e per ogni
///   carta il suo significato tradizionale (il testo della posizione no: lo
///   parafrasava);
/// - la lettura del modello diventa la lettura a schermo, con la risposta per
///   prima; le guardie scartano quella che non regge, si ritenta col motivo,
///   le frasi col genere si riscrivono o, finiti i tentativi, si tolgono;
/// - la schermata la aspetta e la mostra, e senza modello legge di casa.
///
/// Se la lettura **risponde** e se **interpreta** lo misura il collaudo con
/// Gemini vero, `tool/collaudo_eq04.dart`: una prova di casa non puo'
/// giudicare un testo libero.
///
/// **ORDINE GA, 20 ottobre 2026, voci GA.03, GA.05, GA.06 e GA.07.** La
/// decisione del fondatore "Carte dal corpus": in ogni stesa le singole
/// carte vengono dal corpus (titolo, paragrafo e "Cosa fare adesso" per
/// carta, verso, posizione e ambito) e il modello scrive il solo responso
/// principale, ogni paragrafo da 40 a 50 parole. LAPIDE: un campo per carta
/// (`passato`, `presente`, `futuro`), il legame e il consiglio "una frase
/// sola", dall'ordine EQ voce 04 all'ordine GA; le prove di quella forma qui
/// sono riscritte sulla forma nuova. Le guardie scartano adesso un paragrafo
/// fuori misura, un responso che non nomina nessuna carta, la cifra, il
/// confine e il genere; la cura del genere che toglie una frase non deve
/// rompere la misura. Nessuna chiamata vera: le letture sono finte
/// (`la_lettura_finta_della_stesa.dart`).
void main() {
  // --- Il corpus ---

  test('ogni carta ha i suoi tre testi, in tutti e due i versi', () {
    final mancanti = <String>[];
    for (final posizione in SpreadPosition.treCarte) {
      for (final c in TarotDeck.cards) {
        for (final verso in const ['dritta', 'capovolta']) {
          final testi =
              scheletriDelleCarte['${posizione.name}|${c.name}|$verso'];
          if (testi == null ||
              testi.isEmpty ||
              testi.any((t) => t.trim().isEmpty)) {
            mancanti.add('${posizione.name}|${c.name}|$verso');
          }
        }
      }
    }
    // Dall'ordine FI la chiave porta la posizione: le tre della stesa a tre
    // carte sono 468 chiavi, e ciascuna almeno una variante.
    cardinaleMinimo(
        scheletriDelleCarte.keys
            .where((k) =>
                SpreadPosition.treCarte.any((p) => k.startsWith('${p.name}|')))
            .length,
        468,
        cosa: 'chiavi del corpus delle carte nella posizione',
        perche: 'settantotto carte per due versi: se il corpus si svuota, '
            'ogni carta torna al testo uguale per tutte le posizioni');
    expect(mancanti, isEmpty,
        reason: 'carte senza i loro tre testi: $mancanti');
    final nomi = {
      for (final p in SpreadPosition.values)
        for (final c in TarotDeck.cards)
          for (final v in const ['dritta', 'capovolta'])
            '${p.name}|${c.name}|$v'
    };
    expect(scheletriDelleCarte.keys.where((k) => !nomi.contains(k)), isEmpty,
        reason: 'il corpus porta chiavi che il mazzo non conosce');
  });

  test('i tre testi di una carta sono diversi fra loro e dal significato', () {
    final colpe = <String>[];
    for (final c in TarotDeck.cards) {
      for (final capovolta in const [false, true]) {
        final verso = capovolta ? 'capovolta' : 'dritta';
        final testi = [
          for (final p in SpreadPosition.treCarte)
            scheletriDelleCarte['${p.name}|${c.name}|$verso']!.first,
        ];
        if (testi.toSet().length != testi.length) {
          colpe.add('${c.name}: due posizioni con lo stesso testo');
        }
        final significato = capovolta ? c.reversed : c.upright;
        if (testi.contains(significato)) {
          colpe.add('${c.name}: una posizione ripete il significato generale');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  // --- Le carte, sempre dal corpus ---

  test(
      'ogni carta si legge col responso della sua posizione, col modello o '
      'senza', () {
    final colpe = <String>[];
    var guardate = 0;
    for (var seme = 0; seme < 60; seme++) {
      final stesa = TarotSpread.draw(seed: seme);
      for (final dalModello in [null, letturaFinta(stesa)]) {
        final lettura = TarotReading.of(stesa, TarotTopic.momentoCheVivo,
            dalModello: dalModello);
        for (final p in lettura.posizioni) {
          guardate++;
          final g = TarotTopic.momentoCheVivo.group;
          if (p.testo != LeCarteNellaPosizione.letturaDiCasa(p.drawn, g)) {
            colpe.add('seme $seme, ${p.drawn.displayName}: non e\' il testo '
                'della sua posizione');
          }
          if (p.testo == p.drawn.meaning) {
            colpe.add('seme $seme, ${p.drawn.displayName}: e\' il significato '
                'uguale per tutte le posizioni');
          }
          final r = p.responso!;
          if (r.titolo != LeCarteNellaPosizione.titoloDi(p.drawn) ||
              r.cosaFare != LeCarteNellaPosizione.cosaFareDi(p.drawn, g)) {
            colpe.add('seme $seme, ${p.drawn.displayName}: il titolo o il '
                'cosa fare non sono quelli del corpus');
          }
          if (r.lungo) {
            colpe.add('seme $seme, ${p.drawn.displayName}: una carta e\' '
                'lunga');
          }
        }
      }
    }
    cardinaleMinimo(guardate, 360,
        cosa: 'carte lette',
        perche: 'sessanta stese per tre carte, col modello e senza');
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('la stessa carta dice cose diverse nel passato e nel futuro', () {
    final torre = TarotDeck.cards.firstWhere((c) => c.name == 'La Torre');
    final nelPassato = LeCarteNellaPosizione.di(DrawnCard(
        card: torre, position: SpreadPosition.passato, reversed: false));
    final nelFuturo = LeCarteNellaPosizione.di(DrawnCard(
        card: torre, position: SpreadPosition.futuro, reversed: false));
    expect(nelPassato, isNot(nelFuturo));
    expect(nelPassato, isNot(torre.upright));
  });

  // --- Cio' che arriva al modello ---

  test('la richiesta porta la domanda, l\'argomento e ogni carta', () {
    final stesa = TarotSpread.draw(seed: 11);
    const domanda = 'Devo accettare l\'offerta di lavoro a Milano?';
    final r = LaLetturaDellaStesa.richiesta(stesa,
        domanda: domanda, argomento: TarotTopic.lavoroTrovare.label);
    expect(r, contains(domanda));
    expect(r, contains(TarotTopic.lavoroTrovare.label));
    expect(
        r,
        contains('Carta chiave: '
            '${TarotReading.chiaveDi(stesa).drawn.displayName}'),
        reason: 'la chiave del modello e\' quella della schermata');
    for (final d in stesa.cards) {
      expect(r, contains(d.displayName));
      expect(r, contains(d.meaning),
          reason: 'il modello parte dal significato tradizionale');
      expect(r, contains(LaLetturaDellaStesa.cosaDiceLaPosizione[d.position]),
          reason: 'ogni carta dice che cosa vuol dire la sua posizione');
      // Il testo della posizione non ci va: il modello lo parafrasava invece
      // di leggere la carta sulla domanda (sonde 13 e 14).
      expect(r, isNot(contains(LeCarteNellaPosizione.di(d))));
    }
    expect(r, isNot(contains('Campo:')),
        reason: 'dall\'ordine GA nessuna carta ha un campo del modello');
  });

  test('l\'istruzione chiede il solo responso principale nella forma nuova',
      () {
    final i = LaLetturaDellaStesa.istruzione(CourtesyForm.neutral);
    expect(
        i,
        contains(LaFormaDelResponso.perIlModello(
            arte: ArteInterpretata.tarocchi, lunga: false)));
    expect(i, contains('La prima frase risponde subito alla domanda'));
    expect(i, contains('La risposta parte dalla carta chiave che ti indico'));
    expect(i, contains('Nessun futuro dato per certo'));
    expect(LaLetturaDellaStesa.campiPer(TarotSpread.draw(seed: 1)).keys,
        ['risposta', 'cosaFare', 'titolo']);
    expect(
        LaLetturaDellaStesa.campiPer(TarotSpread.draw(seed: 1), profonda: true)
            .keys,
        ['risposta', 'cosaFare', 'approfondimento', 'titolo']);
  });

  // --- La lettura del modello ---

  test('la lettura del modello diventa il responso principale', () {
    final stesa = TarotSpread.draw(seed: 3);
    final l = letturaFinta(stesa);
    final r = TarotReading.of(stesa, TarotTopic.lavoroTrovare,
        domandaScritta: 'Devo accettare l\'offerta di lavoro a Milano?',
        dalModello: l);
    expect(r.principale.risposta, l.risposta,
        reason: 'la risposta e\' la prima cosa che si legge');
    expect(r.principale.cosaFare, l.cosaFare);
    expect(r.consiglio, startsWith(l.risposta));
    expect(r.principale.difetti(), isEmpty);
    // **LAPIDE: "le tre carte sono quelle del modello".** Dall'ordine GA le
    // carte vengono dal corpus anche quando il modello risponde.
    expect(r.posizioni.map((p) => p.testo).toList(), [
      for (final d in stesa.cards)
        LeCarteNellaPosizione.letturaDiCasa(d, TarotTopic.lavoroTrovare.group)
    ]);
  });

  test('la domanda di chiusura resta un dato, fuori dai paragrafi', () {
    final stesa = TarotSpread.draw(seed: 4);
    for (final dalModello in [null, letturaFinta(stesa)]) {
      final r = TarotReading.of(stesa, TarotTopic.momentoCheVivo,
          dalModello: dalModello);
      expect(r.domanda, isNotEmpty, reason: 'torna nel dono del mattino');
      for (final p in r.principale.paragrafi) {
        expect(p, isNot(contains(r.domanda)),
            reason: 'la forma di GA.03 non le da\' un paragrafo');
      }
    }
  });

  test('il cielo di oggi sta nel "Da dove viene", non nei paragrafi', () {
    final stesa = TarotSpread.draw(seed: 5);
    const cielo = 'La Luna oggi passa sul tuo Sole.';
    for (final dalModello in [null, letturaFinta(stesa)]) {
      final r = TarotReading.of(stesa, TarotTopic.momentoCheVivo,
          fattoDelCielo: cielo, dalModello: dalModello);
      expect(r.fonte, contains(cielo));
      expect(r.consiglio, isNot(contains(cielo)));
    }
  });

  test('le guardie scartano la lettura che non regge', () {
    final stesa = TarotSpread.draw(seed: 6);
    final l = letturaFinta(stesa);
    expect(LaLetturaDellaStesa.scarto(l, stesa), isNull,
        reason: 'una lettura buona deve passare, o la prova sotto non '
            'distingue niente');
    LetturaDelModello con({String? risposta, String? cosaFare}) =>
        LetturaDelModello(
          risposta: risposta ?? l.risposta,
          cosaFare: cosaFare ?? l.cosaFare,
        );
    final parole = l.risposta.split(' ');
    expect(
        LaLetturaDellaStesa.scarto(
            con(risposta: parole.take(39).join(' ')), stesa),
        contains('la risposta ha 39 parole'),
        reason: 'una risposta sotto la misura');
    expect(
        LaLetturaDellaStesa.scarto(
            con(cosaFare: '${l.cosaFare} ${parole.take(4).join(' ')}'), stesa),
        contains('il cosa fare ha 51 parole'),
        reason: 'un cosa fare sopra la misura');
    expect(
        LaLetturaDellaStesa.scarto(
            con(
                risposta: l.risposta
                    .replaceFirst('Prima di firmare,', 'Fra 3 giorni,')),
            stesa),
        'una cifra nella lettura');
    final senzaCarte = l.risposta
        .replaceFirst(TarotReading.chiaveDi(stesa).drawn.card.name, 'la carta');
    expect(LaLetturaDellaStesa.scarto(con(risposta: senzaCarte), stesa),
        'il responso non nomina nessuna carta della stesa');
    expect(
        LaLetturaDellaStesa.scarto(
            con(
                cosaFare: l.cosaFare.replaceFirst(
                    'Non accettare a voce', 'Se ti senti sopraffatto,')),
            stesa,
            forma: CourtesyForm.neutral),
        startsWith(LaLetturaDellaStesa.motivoDelGenere),
        reason: 'un genere dato a chi legge, con la forma neutra');
  });

  test('"solo" che vuol dire "soltanto" non da\' un genere a chi legge', () {
    // Dalla sonda 5 del collaudo: una lettura buona scartata tre volte per
    // "essere solo esteriore". Il criterio si restringe sull'avverbio e
    // continua a prendere l'aggettivo.
    for (final avverbio in const [
      'La gioia che provi potrebbe essere solo esteriore.',
      'Ti lascia solo una domanda.',
    ]) {
      expect(formeContrarieAllaForma(avverbio, CourtesyForm.neutral), isEmpty,
          reason: avverbio);
    }
    for (final aggettivo in const [
      'Rischi di restare solo con i tuoi pensieri.',
      'Non vuoi essere solo.',
    ]) {
      expect(
          formeContrarieAllaForma(aggettivo, CourtesyForm.neutral), isNotEmpty,
          reason: aggettivo);
    }
  });

  test('ogni radice del confine sta nelle parole dette al modello', () {
    // La guardia a valle scarta la frase rivolta alla persona che contiene una
    // di queste radici: se il modello non le conosce, la lettura cade per
    // niente. Una radice nuova nel confine fa cadere questa prova finche'
    // non arriva anche al modello.
    for (final radice in ConfineDelResponso.temiDelicati) {
      expect(LaLetturaDellaStesa.paroleDelConfine, contains(radice),
          reason: 'il modello non sa che "$radice" fa cadere la lettura');
    }
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.neutral),
        contains(LaLetturaDellaStesa.paroleDelConfine));
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.neutral),
        contains(ConfineDelResponso.perIlModello));
  });

  test('la riga senza genere arriva solo a chi non ha scelto una forma', () {
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.neutral),
        contains(LaLetturaDellaStesa.senzaGenere));
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.unknown),
        contains(LaLetturaDellaStesa.senzaGenere));
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.feminine),
        isNot(contains(LaLetturaDellaStesa.senzaGenere)));
    expect(LaLetturaDellaStesa.istruzione(CourtesyForm.masculine),
        isNot(contains(LaLetturaDellaStesa.senzaGenere)));
  });

  test('una lettura scartata si chiede di nuovo, col motivo', () async {
    final stesa = TarotSpread.draw(seed: 9);
    final l = letturaFinta(stesa);
    final richieste = <String>[];
    // Un difetto che non e' il genere: per il genere c'e' la riscrittura,
    // provata qui sotto.
    final conCifra = {
      ...l.toJson(),
      'risposta': l.risposta.replaceFirst('Prima di firmare,', 'Fra 3 giorni,'),
    };
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async {
        richieste.add(r);
        return jsonEncode(richieste.length == 1 ? conCifra : l.toJson());
      },
    );
    expect(letta, isNotNull, reason: '${LaLetturaDellaStesa.ultimiScarti}');
    expect(richieste.length, 2);
    expect(LaLetturaDellaStesa.ultimiTentativi, 2);
    expect(richieste.first, isNot(contains('non si può mostrare')));
    expect(richieste.last, contains('non si può mostrare'));
    expect(richieste.last, contains('una cifra'),
        reason: 'il motivo arriva al modello');
  });

  test('un paragrafo fuori misura si richiede, mai si tronca', () async {
    final stesa = TarotSpread.draw(seed: 15);
    final l = letturaFinta(stesa);
    final richieste = <String>[];
    final lunga = {
      ...l.toJson(),
      'cosaFare': '${l.cosaFare} Fallo prima di sera, con calma.',
    };
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async {
        richieste.add(r);
        return jsonEncode(richieste.length == 1 ? lunga : l.toJson());
      },
    );
    expect(letta, isNotNull);
    expect(letta!.cosaFare, l.cosaFare,
        reason: 'si mostra la lettura a misura, non quella tagliata');
    expect(richieste.last, contains('il cosa fare ha 53 parole'));
  });

  test('finiti i tentativi, la frase col genere si toglie e la lettura resta',
      () async {
    final stesa = TarotSpread.draw(seed: 12);
    final l = letturaFinta(stesa);
    // 45 parole, e con la frase col genere 49: tolta la frase, il cosa fare
    // resta nella misura.
    final corto = l.cosaFare.replaceFirst(
        'davvero a quello che cerchi adesso.', 'a quello che cerchi.');
    final conGenere = {
      ...l.toJson(),
      'cosaFare': '$corto Ti ha lasciato stanco.',
    };
    var chiamate = 0;
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async {
        // Le riscritture non contano: qui tornano senza il campo delle
        // frasi, e la lettura va avanti coi tentativi.
        if (i != LaLetturaDellaStesa.istruzioneDellaRiscrittura) chiamate++;
        return jsonEncode(conGenere);
      },
    );
    expect(chiamate, LaLetturaDellaStesa.tentativi,
        reason: 'la cura viene dopo i tentativi, non al loro posto');
    expect(letta, isNotNull, reason: '${LaLetturaDellaStesa.ultimiScarti}');
    expect(LaLetturaDellaStesa.ultimaCurata, isTrue);
    expect(letta!.cosaFare, corto,
        reason: 'si toglie la sola frase col genere');
    expect(letta.risposta, l.risposta);
  });

  test('la cura che toglie una frase non rompe la misura', () async {
    final stesa = TarotSpread.draw(seed: 16);
    final l = letturaFinta(stesa);
    // Il cosa fare con la frase col genere ha 42 parole; senza, 38: sotto la
    // misura, e la lettura curata non si mostra (parla quella di casa).
    final conGenere = {
      ...l.toJson(),
      'cosaFare': 'Questa settimana chiedi per iscritto orari, compenso e '
          'durata del contratto, poi rileggi tutto prima di rispondere. Non '
          'accettare a voce e non lasciarti mettere fretta: una sera di '
          'riflessione ti aiuta a capire se l\'offerta va bene. Ti ha '
          'lasciato stanco.',
    };
    expect(LaFormaDelResponso.aMisura(conGenere['cosaFare']!), isTrue);
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async => jsonEncode(conGenere),
    );
    expect(
        LaLetturaDellaStesa.senzaLeFrasiColGenere(
            LetturaDelModello.daJson(conGenere)!, CourtesyForm.neutral),
        isNotNull,
        reason: 'la cura toglie la frase');
    expect(letta, isNull,
        reason: 'ma il cosa fare curato e\' sotto le quaranta parole');
    expect(LaLetturaDellaStesa.ultimaCurata, isFalse);
  });

  test('le frasi col genere si riscrivono, e la carta resta nominata',
      () async {
    final stesa = TarotSpread.draw(seed: 14);
    final l = letturaFinta(stesa);
    final corto = l.cosaFare.replaceFirst(
        'davvero a quello che cerchi adesso.', 'a quello che cerchi.');
    final riscritture = <String>[];
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async {
        if (i == LaLetturaDellaStesa.istruzioneDellaRiscrittura) {
          riscritture.add(r);
          return jsonEncode({'frasi': 'Oggi senti un peso.'});
        }
        return jsonEncode({
          ...l.toJson(),
          'cosaFare': '$corto Oggi ti senti sopraffatto.',
        });
      },
    );
    expect(letta, isNotNull, reason: '${LaLetturaDellaStesa.ultimiScarti}');
    expect(LaLetturaDellaStesa.ultimaRiscritta, isTrue);
    expect(LaLetturaDellaStesa.ultimiTentativi, 1,
        reason: 'la riscrittura viene prima di rigenerare');
    expect(riscritture.single, contains('ti senti sopraffatto'),
        reason: 'si manda al correttore la sola frase col genere');
    expect(letta!.cosaFare, '$corto Oggi senti un peso.');
    expect(letta.risposta, l.risposta, reason: 'la carta resta nominata');
    expect(
        formeContrarieAllaForma(letta.cosaFare, CourtesyForm.neutral), isEmpty);
  });

  test('il genere nella risposta non si cura: parla la lettura di casa',
      () async {
    final stesa = TarotSpread.draw(seed: 13);
    final l = letturaFinta(stesa);
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async => jsonEncode({
        ...l.toJson(),
        'risposta': l.risposta
            .replaceFirst('Prima di firmare, però,', 'Sei pronto, però, prima'),
      }),
    );
    expect(letta, isNull,
        reason: 'la risposta alla domanda non si taglia per curarla');
    expect(LaLetturaDellaStesa.ultimaCurata, isFalse);
  });

  test('dopo tre letture scartate parla la lettura di casa', () async {
    final stesa = TarotSpread.draw(seed: 10);
    var chiamate = 0;
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async {
        chiamate++;
        return jsonEncode({'risposta': 'Solo questa.'});
      },
    );
    expect(letta, isNull);
    expect(chiamate, LaLetturaDellaStesa.tentativi);
  });

  test('il trattino lungo e la virgola con la e si correggono, non si buttano',
      () async {
    final stesa = TarotSpread.draw(seed: 7);
    final l = letturaFinta(stesa);
    final grezza = {
      ...l.toJson(),
      'cosaFare': l.cosaFare
          .replaceFirst('compenso e durata', 'compenso, e durata')
          .replaceFirst('rispondere. Non', 'rispondere — non'),
    };
    final letta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async => jsonEncode(grezza),
    );
    expect(letta, isNotNull, reason: '${LaLetturaDellaStesa.ultimoScarto}');
    expect(letta!.cosaFare, isNot(contains('—')));
    expect(letta.cosaFare, isNot(contains(', e ')));
  });

  test('una chiamata che non torna lascia parlare la lettura di casa',
      () async {
    final stesa = TarotSpread.draw(seed: 8);
    final rotta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async => throw const SocketException('niente rete'),
    );
    expect(rotta, isNull);
    final lenta = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) => Completer<String?>().future,
      entro: const Duration(milliseconds: 20),
    );
    expect(lenta, isNull);
    final mezza = await LaLetturaDellaStesa.leggi(
      spread: stesa,
      domanda: 'Il momento che vivo',
      argomento: TarotTopic.momentoCheVivo.label,
      forma: CourtesyForm.neutral,
      chiamata: (i, r, c) async => jsonEncode({'risposta': 'Solo questa.'}),
    );
    expect(mezza, isNull, reason: 'una lettura a meta\' non si mostra');
  });

  // --- La schermata ---

  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  Future<void> pesca(WidgetTester tester, int indice) async {
    final carta = find.byKey(Key('stesa_fan_$indice'));
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
  }

  Future<void> premi(WidgetTester tester) async {
    final pulsante = find.byKey(const Key('stesa_inizia'));
    for (var i = 0; i < 40; i++) {
      if (pulsante.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(pulsante).onPressed != null) {
        await tester.tap(pulsante, warnIfMissed: false);
        return;
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    fail('il pulsante che apre il responso non si e\' mai acceso');
  }

  /// Monta la stesa, pesca tre carte e preme "Leggi le Carte". [chiamata]
  /// riceve la stesa vera, letta dalla schermata dopo il pescaggio.
  Future<TarotSpread> leggiLeCarte(WidgetTester tester,
      Future<String?> Function(TarotSpread stesa, String richiesta) chiamata,
      {ReadingKey? chiave,
      void Function(String istruzione)? istruzione}) async {
    silenzia();
    // Alta abbastanza da costruire tutto il responso: la lista e' pigra, e
    // una bolla fuori dalla finestra non c'e' proprio.
    tester.view.physicalSize = const Size(402, 6000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    late TarotSpread stesa;
    await tester.pumpWidget(attorno(StesaTreCarteScreen(
      seed: 2,
      skipIntro: true,
      topic: TarotTopic.bivio,
      chiave: chiave,
      chiamata: (i, r, c) {
        istruzione?.call(i);
        return chiamata(stesa, r);
      },
    )));
    await tester.pump();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    for (final indice in const [38, 39, 40]) {
      await pesca(tester, indice);
    }
    stesa = tester
        .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen))
        .stesaCorrente;
    await premi(tester);
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    return stesa;
  }

  /// Gli spazi si contano come uno: la lettura va a capo in paragrafi suoi
  /// (`spezzaInParagrafi`), e un a capo non e' una parola diversa.
  String piano(String t) => t.replaceAll(RegExp(r'\s+'), ' ').trim();

  String testoDi(WidgetTester tester, String chiave) => piano([
        for (final r in tester.widgetList<RichText>(find.descendant(
            of: find.byKey(Key(chiave)), matching: find.byType(RichText))))
          r.text.toPlainText(),
      ].join(' '));

  testWidgets('la schermata aspetta la lettura del modello e la mostra',
      (tester) async {
    var richieste = 0;
    LetturaDelModello? mandata;
    final stesa = await leggiLeCarte(tester, (s, richiesta) async {
      richieste++;
      mandata = letturaFinta(s);
      return jsonEncode(mandata!.toJson());
    });
    expect(richieste, 1, reason: 'una chiamata sola per stesa');
    expect(find.byKey(const Key('stesa_consiglio')), findsOneWidget);
    expect(
        testoDi(tester, 'stesa_principale_risposta'), piano(mandata!.risposta),
        reason: 'il responso principale non e\' la risposta del modello');
    expect(testoDi(tester, 'stesa_principale_cosa_fare'),
        piano(mandata!.cosaFare));
    for (final d in stesa.cards) {
      expect(testoDi(tester, 'stesa_letta_${d.position.name}'),
          contains(piano(LeCarteNellaPosizione.di(d))),
          reason: '${d.position.label}: la carta viene dal corpus anche col '
              'modello (ordine GA, "Carte dal corpus")');
    }
  });

  testWidgets('senza modello la schermata legge le carte nella posizione',
      (tester) async {
    final stesa = await leggiLeCarte(
        tester, (s, r) async => throw const SocketException('niente rete'));
    expect(find.byKey(const Key('stesa_consiglio')), findsOneWidget);
    for (final d in stesa.cards) {
      expect(testoDi(tester, 'stesa_letta_${d.position.name}'),
          contains(piano(LeCarteNellaPosizione.di(d))),
          reason: '${d.position.label}: senza modello si legge il testo della '
              'sua posizione');
    }
  });

  // LE CHIAVI DI LETTURA ARRIVANO AL MODELLO, E LA LETTURA DI CASA SI DICHIARA.
  // Ordine FI voci 07 e 08: la chiave entra nell'istruzione come voce (la
  // Predittiva non aggiunge niente), e quando il modello non risponde la
  // lettura di casa, che e' nella chiave Predittiva, lo dice a chi ha scelto
  // un'altra chiave.
  testWidgets('la chiave scelta arriva al modello come voce', (tester) async {
    final istruzioni = <String>[];
    await leggiLeCarte(
        tester, (s, r) async => jsonEncode(letturaFinta(s).toJson()),
        chiave: ReadingKey.riflessione, istruzione: istruzioni.add);
    expect(istruzioni, isNotEmpty);
    expect(istruzioni.first, contains(ReadingKey.riflessione.voce!));
    expect(istruzioni.first, contains('mai come un annuncio'));
    // Col modello che risponde la riga della lettura di casa non c'e'.
    expect(find.byKey(const Key('stesa_lettura_di_casa')), findsNothing);
  });

  testWidgets('senza modello la lettura di casa dice la sua chiave',
      (tester) async {
    await leggiLeCarte(
        tester, (s, r) async => throw const SocketException('niente rete'),
        chiave: ReadingKey.esoterica);
    final riga = find.byKey(const Key('stesa_lettura_di_casa'));
    expect(riga, findsOneWidget);
    expect(tester.widget<Text>(riga).data,
        ReadingKey.esoterica.rigaDellaLetturaDiCasa);
    expect(tester.widget<Text>(riga).data, contains('Predittiva'));
  });

  testWidgets('con la Predittiva la lettura di casa non ha niente da dire',
      (tester) async {
    final istruzioni = <String>[];
    await leggiLeCarte(
        tester, (s, r) async => throw const SocketException('niente rete'),
        istruzione: istruzioni.add);
    expect(find.byKey(const Key('stesa_lettura_di_casa')), findsNothing);
    expect(istruzioni.first, isNot(contains('LA CHIAVE DI LETTURA')));
  });
}
