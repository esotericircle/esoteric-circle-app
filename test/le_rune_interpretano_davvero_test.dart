// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/domande/cornici_del_presagio.dart';
import 'package:esoteric_circle/core/rituals/la_lettura_delle_rune.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ESTRAZIONE RUNE INTERPRETA DAVVERO.** Ordine ER voce 01, 27 settembre
/// 2026.
///
/// Il fondatore: *"Adesso ho il dubbio che anche le estrazioni rune non
/// abbiano l'interpretazione come i tarocchi"*.
///
/// **La grandezza misurata qui e' cio' che il modello riceve e cio' che si
/// lascia mostrare**: ogni pietra arriva con la sua posizione e la sua riga
/// del corpus nel verso uscito, la domanda con la sua cornice; la lettura ha
/// una lettura per pietra, e le guardie scartano quella che non nomina la
/// sua runa, che nomina le rune nella risposta, che parla di astri. **Il
/// merito delle letture** lo misurano il banco `tool/collaudo_rune_er.dart`
/// col modello vero e la lettura alla cieca.
void main() {
  final norne = gettate.firstWhere((g) => g.id == 'norne');
  final esito = RuneCast.getta(norne, random: Random(1006));

  test(
      'ER.01: l\'istruzione chiede la risposta diretta e una lettura per '
      'pietra', () {
    final i = MaestroPersona.presagioInstruction(
        profile: UserProfile.empty, memory: MaestroMemory.empty);
    final vecchia = i.contains('tu non ripetere le loro schede');
    print('ORDINE ER VOCE 1: istruzione vecchia ${vecchia ? 1 : 0}, '
        'risposta diretta ${i.contains('La prima risponde alla domanda in modo diretto') ? 1 : 0}, '
        'una lettura per pietra ${i.contains('una lettura per ogni pietra') ? 1 : 0}');
    expect(vecchia, isFalse);
    expect(i, contains('La prima risponde alla domanda in modo diretto'));
    expect(i, contains('una lettura per ogni pietra'));
    expect(i, contains('"legame"'));
    expect(i, contains('"cosaPuoiFare"'));
    expect(i, contains('SOLO NELLA TERZA PARTE'));
    expect(i, contains('"posizione": PRIMA DELLA RISPOSTA'));
  });

  test(
      'ER.01: la richiesta porta ogni pietra nella sua posizione, con la sua '
      'riga, e la cornice della domanda', () {
    const domanda = 'Una scelta mi blocca: cosa la scioglie?';
    final r = LaLetturaDelleRune.richiesta(esito, domanda);
    for (final p in esito.rune) {
      expect(r, contains(p.rune.name));
      expect(r, contains(p.posizione.titolo));
      expect(r, contains(p.riga));
    }
    expect(r, contains('Domanda posta dalla persona: «$domanda»'));
    expect(r, contains('È una delle domande che l\'app propone'));
    final senza = LaLetturaDelleRune.richiesta(esito, '');
    expect(senza, contains('non ha scelto nessuna domanda'));
    final scritta =
        LaLetturaDelleRune.richiesta(esito, 'Devo scrivere a Luca?');
    expect(scritta, isNot(contains('È una delle domande')));
  });

  test('ER.01: le guardie della lettura', () {
    const domanda = 'Una scelta mi blocca: cosa la scioglie?';
    final nomi = [for (final p in esito.rune) p.rune.name];
    // **LAPIDE, ordine ET voce 07**: la pietra buona diceva "nella sua
    // posizione"; adesso ogni pietra nomina la posizione vera, come chiede la
    // guardia nuova (alla lettura alla cieca le pietre senza posizione erano
    // quelle lette "alcune").
    final posti = [for (final p in esito.rune) p.posizione.titolo];
    Map<String, Object> lettura({
      String posizione = 'sì a una condizione',
      String risposta = 'Le pietre indicano di sì, se prima chiarisci cosa '
          'ti trattiene. La scelta si scioglie quando dai un nome al dubbio.',
      List<Object>? pietre,
      String legame = 'Le tre pietre vanno dalla difesa al passo.',
      String consiglio = 'Domani mattina scegli una delle due strade e fai '
          'la prima telefonata.',
    }) =>
        {
          'posizione': posizione,
          'risposta': risposta,
          'pietre': pietre ??
              [
                for (var i = 0; i < nomi.length; i++)
                  {
                    'lettura': '${nomi[i]}, nella posizione ${posti[i]}, '
                        'parla di un passo preciso.',
                    'sullaDomanda': 'Sulla scelta che ti blocca indica il '
                        'passo numero ${i + 1}.',
                  }
              ],
          'legame': legame,
          'cosaPuoiFare': consiglio,
        };
    final buona = LaLetturaDelleRune.scarto(lettura(), esito, domanda: domanda);
    final corta = LaLetturaDelleRune.scarto(
        lettura(pietre: ['solo una']), esito,
        domanda: domanda);
    final senzaNome = LaLetturaDelleRune.scarto(
        lettura(pietre: [for (final _ in nomi) 'Una pietra che parla.']), esito,
        domanda: domanda);
    final nomeNellaRisposta = LaLetturaDelleRune.scarto(
        lettura(risposta: '${nomi.first} ti dice di sì.'), esito,
        domanda: domanda);
    final astri = LaLetturaDelleRune.scarto(
        lettura(legame: 'Il tuo ascendente lega le pietre.'), esito,
        domanda: domanda);
    print('ORDINE ER VOCE 1: buona $buona; pietre mancanti "$corta"; senza '
        'nome "$senzaNome"; nome nella risposta "$nomeNellaRisposta"; astri '
        '"$astri"');
    expect(buona, isNull);
    expect(corta, isNotNull);
    expect(senzaNome, isNotNull);
    // **LA PIETRA SENZA NOME, CON LA SUA FRASE SULLA DOMANDA.** Alla Regola B
    // dell'ordine ET, tolto il controllo del nome, la prova restava verde:
    // il caso di sopra ha pietre scritte come testo solo, e lo ferma la
    // regola della frase sulla domanda.
    final senzaNomeConLaFrase = LaLetturaDelleRune.scarto(
        lettura(pietre: [
          for (var i = 0; i < nomi.length; i++)
            {
              'lettura': 'Una pietra, nella sua posizione, parla di forza.',
              'sullaDomanda': 'Sulla scelta che ti blocca indica il passo '
                  'numero ${i + 1}.',
            }
        ]),
        esito,
        domanda: domanda);
    expect(senzaNomeConLaFrase, contains('non nomina'));
    // Il nome nella risposta non butta la lettura: diventa "la runa", e il
    // simbolo resta nella terza parte (ordine ER voce 01, dal banco di
    // Flash).
    expect(nomeNellaRisposta, isNull);
    final ripulita = LaLetturaDelleRune.daJson(
        lettura(
            risposta: '${nomi.first} ti dice di sì. Guarda il consiglio di '
                '${nomi.last}.'),
        esito)!;
    print('ORDINE ER VOCE 1: risposta ripulita "${ripulita.risposta}"');
    expect(ripulita.risposta, startsWith('La runa ti dice di sì.'));
    expect(ripulita.risposta, contains('il consiglio della runa'));
    for (final n in nomi) {
      expect(LaLetturaDelleRune.nomina(ripulita.risposta, n), isFalse);
    }
    expect(astri, isNotNull);
    // **DAL GIUDIZIO ALLA CIECA DEL SECONDO BANCO**: la prima frase che
    // parla per immagini, la posizione scelta e non detta, la pietra senza la
    // sua frase sulla domanda, e due pietre con la stessa frase.
    // **LAPIDE, dal banco della sera**: qui la prova voleva che ogni pietra
    // nominasse una parola della domanda; al banco quella guardia scartava
    // cinquantacinque letture su cento, perche' all'amore si risponde col
    // legame e col cuore. Adesso la frase sulla domanda e' un campo.
    final perImmagini = LaLetturaDelleRune.scarto(
        // Con "un passo da fare" la guardia della posizione non si applica:
        // la regola A l'ha vista verde col caso di prima, che prendeva
        // quella guardia invece di questa.
        lettura(
            posizione: 'un passo da fare',
            risposta: 'Il cammino è velato. La scelta aspetta.'),
        esito,
        domanda: domanda);
    final nonDetta = LaLetturaDelleRune.scarto(
        lettura(
            posizione: 'sì',
            risposta: 'Le rune indicano la scelta giusta. Perché è tua.'),
        esito,
        domanda: domanda);
    final senzaSulla = LaLetturaDelleRune.scarto(
        lettura(pietre: [
          for (final n in nomi) {'lettura': '$n parla di forza.'}
        ]),
        esito,
        domanda: domanda);
    final sulleUguali = LaLetturaDelleRune.scarto(
        lettura(pietre: [
          for (final n in nomi)
            {
              'lettura': '$n parla di forza.',
              'sullaDomanda': 'Sulla scelta indica di aspettare.',
            }
        ]),
        esito,
        domanda: domanda);
    // "Cammino" non e' un'immagine vietata: alla domanda su dove si va, dire
    // dove va il cammino risponde.
    final colCammino = LaLetturaDelleRune.scarto(
        lettura(
            risposta: 'Il tuo cammino in amore va verso un sì, se parli '
                'chiaro. Perché le pietre aprono.'),
        esito,
        domanda: domanda);
    final conLaCondizione = LaLetturaDelleRune.scarto(
        lettura(
            risposta: 'Le rune indicano che la scelta si scioglie se ne '
                'parli domani. Perché il blocco è la paura.'),
        esito,
        domanda: domanda);
    print('ORDINE ER VOCE 1: per immagini "$perImmagini"; posizione non '
        'detta "$nonDetta"; senza la frase sulla domanda "$senzaSulla"; '
        'frasi uguali "$sulleUguali"; col cammino $colCammino; con la '
        'condizione $conLaCondizione');
    expect(perImmagini, isNotNull);
    expect(nonDetta, isNotNull);
    expect(senzaSulla, isNotNull);
    expect(sulleUguali, isNotNull);
    expect(colCammino, isNull);
    expect(conLaCondizione, isNull);
    // **DAL REALME ALLA 2285**: la condizione detta col "ma" e' la risposta
    // diretta, e la guardia la scartava sempre su quella gettata.
    expect(
        LaLetturaDelleRune.scarto(
            lettura(
                risposta: 'Accetta l\'offerta di lavoro, ma poni una '
                    'condizione chiara sul tuo tempo. La scelta si scioglie '
                    'cosi\'.'),
            esito,
            domanda: domanda),
        isNull);
    // **DAL BANCO DELLA SERA, TERZO GIRO**: la cornice ricopiata come prima
    // frase, le aperture di formula, l'articolo davanti al parente, la
    // congiunzione rimasta sola dopo il taglio.
    final apertura = CorniciDelPresagio.perDomanda(domanda)!.apertura;
    final primaDellaCornice =
        apertura.split(RegExp(r'(?<=[.!?])\s+')).first.trim();
    final ricopiata = LaLetturaDelleRune.scarto(
        lettura(
            posizione: 'un passo da fare',
            risposta: '$primaDellaCornice Parla domani.'),
        esito,
        domanda: domanda);
    final diFormula = LaLetturaDelleRune.scarto(
        lettura(
            posizione: 'un passo da fare',
            risposta: 'La tua scelta è un invito al cambiamento. Parla '
                'domani.'),
        esito,
        domanda: domanda);
    final parenti = LaLetturaDelleRune.daJson(
        lettura(
            risposta: 'Chiedi un incontro alla tua sorella. La tua madre '
                'aspetta.',
            consiglio: 'Stasera chiama tua sorella e, come dice '
                '${nomi.first}, prima di cena.'),
        esito)!;
    print('ORDINE ER VOCE 1: cornice ricopiata "$ricopiata"; di formula '
        '"$diFormula"; parenti "${parenti.risposta}"; consiglio '
        '"${parenti.cosaPuoiFare}"');
    expect(ricopiata, isNotNull);
    expect(diFormula, isNotNull);
    expect(parenti.risposta,
        'Chiedi un incontro a tua sorella. Tua madre aspetta.');
    expect(parenti.cosaPuoiFare, 'Stasera chiama tua sorella prima di cena.');
    final telo = gettate.firstWhere((g) => g.id == 'telo');
    final conTitoli = LaLetturaDelleRune.richiesta(
        RuneCast.getta(telo, random: Random(4)), '');
    expect(conTitoli, isNot(contains('nella posizione Al centro')));
    expect(conTitoli, isNot(contains('nella posizione Ai margini')));
    // Il consiglio e' solo il gesto: la parte che parla delle pietre si
    // toglie, il gesto resta.
    final tagliato = LaLetturaDelleRune.daJson(
            lettura(
                consiglio: 'Domani parla con tua sorella, come chiede '
                    '${nomi.first}. Il presagio va onorato.'),
            esito)!
        .cosaPuoiFare;
    print('ORDINE ER VOCE 1: consiglio tagliato "$tagliato"');
    expect(tagliato, 'Domani parla con tua sorella.');
    // Se non resta niente, il consiglio manca e la lettura non passa.
    for (final consiglio in [
      'Domani decidi il passo successivo con ${nomi.first}.',
      'Stasera accendi il sigillo della scelta.',
    ]) {
      expect(
          LaLetturaDelleRune.scarto(lettura(consiglio: consiglio), esito,
              domanda: domanda),
          isNotNull,
          reason: consiglio);
    }
    // **LA RIPARAZIONE DEI NOMI ACCORDA CIO' CHE STA DAVANTI**: la prima
    // scriveva "la tua la runa", "ogni la runa", "alla runa la runa".
    final riparate = LaLetturaDelleRune.daJson(
            lettura(
                risposta: 'Sarà la tua ${nomi[0]}, ogni ${nomi[1]} e la runa '
                    '${nomi[2]}. Lasciando ad ${nomi[0]} il sigillo ${nomi[1]}, '
                    'dell\'${nomi[2]} resta il tuo ${nomi[0]}.'),
            esito)!
        .risposta;
    print('ORDINE ER VOCE 1: riparata "$riparate"');
    expect(
        riparate,
        'Sarà la tua runa, ogni runa e la runa. Lasciando alla runa il '
        'sigillo, della runa resta la tua runa.');
    expect(
        RegExp(r'(?:la|tua|ogni|alla) la runa|runa la runa').hasMatch(riparate),
        isFalse);
    // La lettura arriva a schermo nelle tre parti: le rune nella terza.
    final r = LaLetturaDelleRune.daJson(lettura(), esito)!;
    for (final n in nomi) {
      expect(r.daDoveViene, contains(n));
      expect(LaLetturaDelleRune.nomina(r.risposta, n), isFalse);
    }
  });

  test(
      'ER.01: il provider chiede i campi con lo schema e passa dalle '
      'guardie', () {
    final s = File('lib/services/ai/firebase_maestro_ai_provider.dart')
        .readAsStringSync();
    expect(s, contains('LaLetturaDelleRune.richiesta(esito, d)'));
    expect(s, contains('LaLetturaDelleRune.scarto(j, esito, domanda: d)'));
    expect(s, contains("'sullaDomanda': Schema.string()"));
    expect(s, contains("'lettura': Schema.string()"));
    expect(
        s,
        contains(
            'Schema.enumString(enumValues: LaLetturaDelleRune.posizioni)'));
    expect(s, contains('temperature: LaLetturaDelleRune.temperatura'));
    expect(LaLetturaDelleRune.campi.first, 'posizione');
  });
}
