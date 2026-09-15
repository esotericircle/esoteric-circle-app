// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/viaggio/il_tema_della_domanda_libera.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';

/// **IL BANCO DELLE DOMANDE LIBERE.** Ordine DL voce 09, 14 settembre 2026.
///
/// *"Un banco di almeno trenta domande scritte a mano col tema atteso, e la
/// percentuale di temi giusti senza rete e con rete."*
///
/// **Le domande sono scritte come le scrive una persona**, non come le
/// scriverebbe chi conosce la tabella: col nome di chi c'entra, con la
/// cosa che si aspetta, a volte senza punto di domanda. Ci sono le due della
/// prova a video della build 2250, che hanno fatto nascere la voce.
///
/// **Ogni domanda ha i temi accettabili, non uno solo**: *"Devo lasciare il
/// lavoro in banca per aprire una bottega?"* e' una scelta ed e' una
/// direzione, e chi la legge darebbe ragione a tutte e due. Un tema fuori
/// dall'insieme e' un errore; **nessun tema** non e' un errore della stessa
/// specie, perche' la voce senza tema risponde senza nominare niente, e si
/// conta a parte.
///
/// **SENZA RETE** misura la tabella delle parole, ed e' una guardia: nessuna
/// domanda del banco riceve un tema sbagliato, e i temi giusti non scendono
/// sotto il numero misurato il giorno che il banco e' nato. **CON RETE**
/// misura il classificatore vero, con l'istruzione e lo schema della chiamata
/// dell'app, e riporta anche l'oggetto:
///
///     VERTEX_TOKEN=$(gcloud auth print-access-token) flutter test test/il_banco_delle_domande_libere_test.dart
void main() {
  final token = Platform.environment['VERTEX_TOKEN'] ?? '';

  test('IL BANCO HA ALMENO TRENTACINQUE DOMANDE, e ognuna ha i suoi temi', () {
    // **TRENTACINQUE DALL'ORDINE DQ VOCE 08**, che le vuole portare da
    // trenta a trentacinque. Erano gia' trentasei, col minimo a trenta: le
    // cinque dei due difetti del classificatore si aggiungono, e il minimo
    // sale a quello che l'ordine dice.
    cardinaleMinimo(banco.length, 35,
        cosa: 'domande nel banco',
        perche: 'L ordine DQ ne vuole almeno trentacinque.');
    for (final d in banco) {
      expect(d.accettati, isNotEmpty, reason: d.testo);
    }
    expect({for (final d in banco) d.testo}.length, banco.length,
        reason: 'due domande uguali contano due volte la stessa cosa');
  });

  test('SENZA RETE: la tabella delle parole non sbaglia tema su nessuna '
      'domanda del banco', () {
    final sbagliate = <String>[];
    var giuste = 0;
    var senzaTema = 0;
    for (final d in banco) {
      final t = IlTemaDellaDomandaLibera.perParole(d.testo);
      if (t == null) {
        senzaTema++;
      } else if (d.accettati.contains(t)) {
        giuste++;
      } else {
        sbagliate.add('${d.testo} -> ${t.name}, attesi '
            '${d.accettati.map((x) => x.name).join(' o ')}');
      }
    }
    print('BANCO SENZA RETE: $giuste giuste, ${sbagliate.length} sbagliate, '
        '$senzaTema senza tema, su ${banco.length}: '
        '${(giuste * 100 / banco.length).toStringAsFixed(1)} per cento');
    expect(sbagliate, isEmpty,
        reason: 'la tabella sceglie un tema che non e quello della domanda:\n'
            '${sbagliate.join('\n')}');
    expect(giuste, greaterThanOrEqualTo(giusteDellaTabellaAlMinimo),
        reason: 'la tabella riconosceva $giusteDellaTabellaAlMinimo domande '
            'del banco il giorno che e nato, ordine DL voce 09');
  });

  test('LE DUE DOMANDE DELLA PROVA A VIDEO DELLA BUILD 2250', () {
    expect(
        IlTemaDellaDomandaLibera.perParole(
            'Mia sorella non mi parla da due anni e non so se cercarla'),
        TemaDellaDomanda.persona,
        reason: 'il solo "non so se" ne faceva una scelta, e la risposta '
            'parlava di due strade');
    expect(
        IlTemaDellaDomandaLibera.perParole(
            'Mia sorella diventerà presto mamma?'),
        TemaDellaDomanda.attesa,
        reason: 'parla di una persona, ma chiede se una cosa arriva');
  });

  group('DQ.08, I DUE DIFETTI DEL CLASSIFICATORE', () {
    test('la solitudine non e una domanda su una persona', () async {
      // **DALLA MISURA DELL'ORDINE DN**: *"Mi sento sola anche quando sono
      // con gli altri"* diventava il tema della persona, e la ripresa diceva
      // *"Da un po' ti porti dietro quella persona"*: quale? Nella domanda
      // non c'e' nessuno.
      const sola = 'Mi sento sola anche quando sono con gli altri';
      expect(IlTemaDellaDomandaLibera.perParole(sola), TemaDellaDomanda.blocco);
      expect(LeGuardieDelResponso.parlaDiUnTerzo(sola), isFalse);
      // E quando il modello dice persona lo stesso, vale la tabella.
      final c = await LaDomandaCapita.capisci(sola,
          chiamata: (i, d) async => '{"tema": "persona", "oggetto": ""}');
      expect(c.tema, TemaDellaDomanda.blocco);
      expect(c.fonte, FonteDelTema.parole);
    });

    test('il nome in testa alla domanda e una persona', () async {
      // *"Giulia non risponde piu' ai miei messaggi"*: il nome si
      // riconosceva solo dentro la frase, e la regola dei terzi non valeva.
      const giulia = 'Giulia non risponde più ai miei messaggi';
      expect(LeGuardieDelResponso.parlaDiUnTerzo(giulia), isTrue);
      expect(
          LeGuardieDelResponso.dellaRisposta('Giulia sta aspettando che tu scriva.',
              domanda: giulia, forma: CourtesyForm.neutral),
          MotivoDelloScarto.statoDiUnTerzo);
      // Col nome in testa il modello che dice persona resta.
      final c = await LaDomandaCapita.capisci(giulia,
          chiamata: (i, d) async => '{"tema": "persona", "oggetto": "Giulia"}');
      expect(c.tema, TemaDellaDomanda.persona);
      expect(c.fonte, FonteDelTema.modello);
    });

    test('la parola in testa che non e un nome non diventa una persona', () {
      for (final d in [
        'Oggi non ce la faccio più',
        'Non so più dove sto andando',
        'Tutto mi sembra inutile',
        'Ogni volta che devo parlare in pubblico mi blocco',
        'Adesso non so cosa fare',
        'Sto sbagliando strada con questo lavoro?',
        'Ricado sempre negli stessi errori con i soldi',
      ]) {
        expect(LeGuardieDelResponso.parlaDiUnTerzo(d), isFalse, reason: d);
      }
    });
  });

  test('CON RETE: il classificatore vero sul banco', () async {
    HttpOverrides.global = null;
    var giuste = 0;
    var giusteTabella = 0;
    var dalModello = 0;
    final sbagliate = <String>[];
    final oggetti = <String>[];
    for (final d in banco) {
      String? grezza;
      final c = await LaDomandaCapita.capisci(d.testo,
          chiamata: (i, t) async => grezza = await _classifica(token, i, t),
          prendiUnaChiamata: () async => true,
          seGuasto: (e) => print('guasto su "${d.testo}": $e'));
      if (c.fonte == FonteDelTema.modello) dalModello++;
      if (c.tema != null && d.accettati.contains(c.tema)) {
        giuste++;
      } else {
        sbagliate.add('${d.testo} -> ${c.tema?.name ?? 'nessuno'} '
            '(${c.fonte.name}), attesi ${d.accettati.map((x) => x.name).join(' o ')}');
      }
      final t = IlTemaDellaDomandaLibera.perParole(d.testo);
      if (t != null && d.accettati.contains(t)) giusteTabella++;
      oggetti.add('${d.testo} -> ${c.oggetto == null ? '(nessun oggetto, vale la categoria; il modello: ${grezza?.replaceAll(RegExp(r'\s+'), ' ')})' : 'La domanda riguardava ${c.oggetto}. / Hai portato giù la domanda ${LaVoceDelMondoDiSotto.suLOggetto(c.oggetto!)}.'}');
    }
    print('BANCO CON RETE: $giuste giuste su ${banco.length}, '
        '${(giuste * 100 / banco.length).toStringAsFixed(1)} per cento; '
        'deciso dal modello $dalModello; la tabella da sola '
        '$giusteTabella');
    for (final s in sbagliate) {
      print('  sbagliata: $s');
    }
    for (final o in oggetti) {
      print('  oggetto: $o');
    }
  },
      skip: token.isEmpty
          ? 'con rete gira solo con VERTEX_TOKEN nell\'ambiente'
          : false,
      timeout: const Timeout(Duration(minutes: 5)));
}

/// **I TEMI GIUSTI DELLA TABELLA, IL GIORNO CHE IL BANCO E' NATO.** Il numero
/// segue il dato: se la tabella migliora si alza, e non si abbassa mai per
/// far passare una prova.
const int giusteDellaTabellaAlMinimo = 25;

/// Una domanda del banco e i temi che chi la legge le darebbe.
typedef DomandaDelBanco = ({String testo, Set<TemaDellaDomanda> accettati});

DomandaDelBanco _d(String testo, List<TemaDellaDomanda> accettati) =>
    (testo: testo, accettati: accettati.toSet());

const _scelta = TemaDellaDomanda.scelta;
const _persona = TemaDellaDomanda.persona;
const _blocco = TemaDellaDomanda.blocco;
const _attesa = TemaDellaDomanda.attesa;
const _direzione = TemaDellaDomanda.direzione;
const _finito = TemaDellaDomanda.finito;

/// **LE DOMANDE**, sei per tema e qualcuna in piu' dove i temi si toccano.
final List<DomandaDelBanco> banco = [
  // Le due della prova a video della build 2250.
  _d('Devo lasciare il lavoro in banca per aprire una bottega di ceramica',
      [_scelta, _direzione]),
  _d('Mia sorella non mi parla da due anni e non so se cercarla', [_persona]),
  // Una scelta da fare.
  _d('Accetto il trasferimento a Milano o resto qui?', [_scelta]),
  _d('Non so se comprare casa adesso o aspettare', [_scelta, _attesa]),
  _d('Meglio il master all\'estero o il posto fisso che mi hanno offerto?',
      [_scelta]),
  _d('Devo dire di sì alla proposta di Andrea?', [_scelta, _persona]),
  _d('Tengo il cane di mia nonna o lo affido a qualcuno?', [_scelta]),
  // Una persona.
  _d('Che posto ha Giulia nella mia vita?', [_persona]),
  _d('Mio padre e io non riusciamo più a parlarci', [_persona]),
  _d('Posso fidarmi del mio nuovo socio?', [_persona]),
  _d('Perché con mia madre finisce sempre in lite?', [_persona]),
  _d('Cosa prova davvero Marco per me?', [_persona]),
  _d('Il mio migliore amico si è allontanato e non capisco perché',
      [_persona]),
  // Un blocco che non si supera.
  _d('Da mesi non riesco a finire niente di quello che comincio', [_blocco]),
  _d('Ogni volta che devo parlare in pubblico mi blocco', [_blocco]),
  _d('Perché continuo a rimandare la tesi?', [_blocco]),
  _d('Non riesco a smettere di pensare a quello che è successo', [
    _blocco,
    _finito,
  ]),
  _d('Ricado sempre negli stessi errori con i soldi', [_blocco]),
  _d('Mi sento fermo, come se qualcosa mi trattenesse', [_blocco]),
  // Un tempo che non arriva.
  _d('Mia sorella diventerà presto mamma?', [_attesa]),
  _d('Quando arriverà una risposta dal colloquio?', [_attesa]),
  _d('Mio figlio troverà lavoro entro l\'estate?', [_attesa]),
  _d('La mia amica tornerà a scrivermi?', [_attesa, _persona]),
  _d('Aspetto da un anno che si liberi quel posto', [_attesa]),
  _d('Venderò la casa prima dell\'inverno?', [_attesa]),
  // Una direzione da prendere.
  _d('Sto sbagliando strada con questo lavoro?', [_direzione]),
  _d('Che cosa voglio fare davvero della mia vita?', [_direzione]),
  _d('Non so più dove sto andando', [_direzione]),
  _d('Dove devo mettere le mie energie quest\'anno?', [_direzione]),
  _d('Ho quarant\'anni e mi chiedo se sono sulla strada giusta', [_direzione]),
  // Qualcosa che è finito.
  _d('Ho chiuso con Luca dopo sei anni, e adesso?', [_finito]),
  _d('Il negozio ha chiuso e non so cosa fare adesso', [_finito, _direzione]),
  _d('Mio nonno se n\'è andato e non riesco a lasciarlo andare', [
    _finito,
    _blocco,
  ]),
  _d('È finita la mia amicizia più lunga', [_finito]),
  _d('Sono andato in pensione e le giornate sono vuote', [_finito]),
  _d('Il progetto è saltato dopo due anni di lavoro', [_finito]),
  // **I DUE DIFETTI DEL CLASSIFICATORE**, ordine DQ voce 08: la solitudine
  // letta come una persona, e il nome in testa che non era una persona.
  _d('Mi sento sola anche quando sono con gli altri', [_blocco, _direzione]),
  _d('Da quando mi sono trasferito mi sento solo', [_blocco, _direzione]),
  _d('La solitudine mi pesa sempre di più', [_blocco]),
  _d('Giulia non risponde più ai miei messaggi', [_persona, _attesa]),
  _d('Marco dice che ha bisogno di tempo', [_persona, _attesa]),
];

/// **LA CHIAMATA VERA AL CLASSIFICATORE**, per REST, con la configurazione
/// della chiamata dell'app: stesso modello, stessa regione, stesso schema.
Future<String?> _classifica(
    String token, String istruzione, String testo) async {
  const regione = LaDomandaCapita.regione;
  final url = Uri.parse('https://$regione-aiplatform.googleapis.com/v1/'
      'projects/esoteric-circle/locations/$regione/publishers/google/models/'
      '${LaDomandaCapita.modello}:generateContent');
  final corpo = {
    'systemInstruction': {
      'parts': [
        {'text': istruzione}
      ]
    },
    'contents': [
      {
        'role': 'user',
        'parts': [
          {'text': testo}
        ]
      }
    ],
    'generationConfig': {
      'temperature': 0,
      'maxOutputTokens': 96,
      'responseMimeType': 'application/json',
      'responseSchema': {
        'type': 'OBJECT',
        'properties': {
          'tema': {
            'type': 'STRING',
            'enum': [for (final t in TemaDellaDomanda.values) t.name],
          },
          'oggetto': {'type': 'STRING'},
        },
        // Come lo scrive `firebase_ai` da se': ogni campo e' obbligatorio.
        'required': ['tema', 'oggetto'],
      },
      'thinkingConfig': {'thinkingBudget': 0},
    },
  };
  final client = HttpClient();
  try {
    final req = await client.postUrl(url);
    req.headers.set('Authorization', 'Bearer $token');
    req.headers.contentType = ContentType.json;
    req.write(jsonEncode(corpo));
    final res = await req.close();
    final testoRisposta = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      throw HttpException('Vertex ${res.statusCode}: $testoRisposta');
    }
    final j = jsonDecode(testoRisposta) as Map<String, dynamic>;
    return ((j['candidates'] as List).first['content']['parts'] as List)
        .first['text'] as String?;
  } finally {
    client.close();
  }
}
