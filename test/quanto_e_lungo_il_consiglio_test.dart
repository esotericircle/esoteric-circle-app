// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/voce_della_stesa.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **QUANTO E' LUNGO IL CONSIGLIO DOPO L'ORDINE DF.**
///
/// **Perche' questa prova esiste.** Il fondatore, nell'ordine DF: *"la
/// lunghezza dei testi e la divisione dei paragrafi va bene attualmente"*. Un
/// compositore nuovo che scrive piu' varieta' scrive anche piu' caratteri, e
/// oltre il tetto la bolla **viene troncata**: la varieta' si pagherebbe con
/// una frase mozza, che e' il peggiore dei due mali.
///
/// **Il numero si misura e non si stima**, su tutti e sedici gli argomenti per
/// molte estrazioni, e si confronta col tetto: se il caso peggiore arriva al
/// tetto, il tetto e' gia' stato superato in qualche lettura che nessuno ha
/// visto.
///
/// **RIFATTA DALL'ORDINE GA, voci GA.03, GA.05 e GA.07, 20 ottobre 2026.**
/// Il fondatore, 19 ottobre 2026: *"tutte le risposte composte da paragrafi
/// ognuno con tra 40 a 50 parole ognuno"*; il 20 ottobre, decisione "Carte
/// dal corpus": il modello scrive solo il responso principale, e quando non
/// torna parla la lettura di casa (`VoceDellaStesa.responsoDiCasa`), sempre
/// Breve, cioe' la risposta e il "Cosa fare adesso". **La grandezza misurata
/// cambia**: non piu' i caratteri del Consiglio intero contro un tetto, ma
/// le **parole di ogni paragrafo**, contate come le conta chi legge
/// (`LaFormaDelResponso.parole`), fra 40 e 50 in ogni composizione.
///
/// **LA PROVA DI PRIMA ERA CIECA, e lo si e' visto alla Regola B del 20
/// ottobre 2026.** Misurava `TarotReading.consiglio`, che `consiglioDi`
/// tronca al tetto con `TettiDellaStesa.dentro`: una forma lunghissima
/// innestata a mano portava il caso peggiore a 1249 caratteri contro un tetto
/// di 1250, e la pretesa "il caso peggiore sta sotto il tetto" restava verde
/// per costruzione. Cadeva solo il margine. Qui si misura la voce, prima di
/// ogni taglio, e nessun taglio c'e' piu' (GA.07, *"mai troncare"*).
///
/// **COME SI GARANTISCE, e non si stima.** Le composizioni sono il prodotto
/// delle forme di ogni fessura per sedici lenti, centocinquantasei nomi di
/// carta, quattro nature e tre marche del genere: troppe per elencarle, e un
/// campione non basterebbe a dire "in ogni composizione". Ma un paragrafo e'
/// la **somma** delle sue fessure, unite da uno spazio. Quindi la prova
/// misura ogni forma di ogni fessura con ogni marca del genere, la lente e il
/// nome piu' corti e piu' lunghi, e somma i minimi e i massimi: se la somma
/// dei minimi e' almeno 40 e quella dei massimi al piu' 50, **nessuna
/// composizione puo' uscire**. Poi compone davvero migliaia di stese a una,
/// tre, quattro e dieci carte, e pretende che ognuna stia nella misura, per
/// prendere il giorno in cui la composizione smettesse di essere una somma.
void main() {
  // Le marche del genere, tutte e tre, piu' la forma sconosciuta.
  const forme = CourtesyForm.values;

  /// I nomi di carta come si leggono nelle forme: ogni carta nei due versi.
  final nomi = [
    for (final c in TarotDeck.cards)
      for (final rovesciata in [false, true])
        DrawnCard(
                card: c,
                position: SpreadPosition.presente,
                reversed: rovesciata)
            .displayName,
  ];
  final lenti = [for (final t in TarotTopic.values) t.lente];
  int parole(String s) => LaFormaDelResponso.parole(s);
  final nomeMin = nomi.map(parole).reduce((a, b) => a < b ? a : b);
  final nomeMax = nomi.map(parole).reduce((a, b) => a > b ? a : b);
  final lenteMin = lenti.map(parole).reduce((a, b) => a < b ? a : b);
  final lenteMax = lenti.map(parole).reduce((a, b) => a > b ? a : b);

  /// **LE PAROLE FISSE DI UNA FORMA**, cioe' quelle fuori dai segnaposto,
  /// per ognuna delle marche del genere: i segnaposto si riempiono con una
  /// parola sola e si tolgono dal conto.
  List<int> fisse(String forma) {
    final segnaposto =
        RegExp(r'\{(lente|inLente|presente|futuro)\}').allMatches(forma).length;
    final fuori = <int>[];
    final prima = LaMarcaDelGenere.formaCorrente;
    try {
      for (final f in forme) {
        LaMarcaDelGenere.formaCorrente = f;
        fuori.add(parole(VoceDellaStesa.riempi(forma,
                lente: 'Lente', presente: 'Nome', futuro: 'Approdo')) -
            segnaposto);
      }
    } finally {
      LaMarcaDelGenere.formaCorrente = prima;
    }
    return fuori;
  }

  /// **LE FASCE DICHIARATE**, le stesse scritte nell'intestazione di
  /// `VoceDellaStesa`: parole fisse, il minimo e il massimo.
  const fasce = <String, (int, int)>{
    'verdetto': (11, 12),
    'cosa dice': (14, 15),
    'cosa vuol dire': (12, 13),
    'aggancio': (8, 9),
    'gesto': (18, 20),
    'approdo': (13, 14),
    'perche': (14, 16),
  };

  Map<String, List<String>> tavole() => {
        'verdetto': [
          for (final l in VoceDellaStesa.verdettiDelCuore.values) ...l
        ],
        'cosa dice': [
          for (final l in VoceDellaStesa.cosaDiceIlPresente.values) ...l
        ],
        'cosa vuol dire': [
          for (final l in VoceDellaStesa.cosaVuolDire.values) ...l
        ],
        'aggancio': VoceDellaStesa.aggancioDellAzione,
        'gesto': [for (final l in VoceDellaStesa.gestoPerNatura.values) ...l],
        'approdo': [
          for (final l in VoceDellaStesa.formeDellApprodo.values) ...l
        ],
        'perche': VoceDellaStesa.percheFarlo,
      };

  test('OGNI FORMA STA NELLA FASCIA DICHIARATA, con ogni marca del genere', () {
    final fuori = <String>[];
    var guardate = 0;
    for (final e in tavole().entries) {
      final (min, max) = fasce[e.key]!;
      for (final forma in e.value) {
        for (final n in fisse(forma)) {
          guardate++;
          if (n < min || n > max) {
            fuori.add('${e.key}, $n parole fisse invece di $min-$max: '
                '"$forma"');
          }
        }
      }
    }
    print('ORDINE GA: forme misurate con le quattro forme di cortesia '
        '$guardate, fuori dalla fascia ${fuori.length}');
    // 32 verdetti, 32 cosa dice, 32 cosa vuol dire, 12 agganci, 32 gesti,
    // 32 approdi e 8 perche', per quattro forme di cortesia.
    cardinaleMinimo(guardate, 180 * 4,
        cosa: 'forme misurate con ogni forma di cortesia',
        perche: 'Con una tavola vuota la fascia sarebbe rispettata per non '
            'aver guardato niente.');
    expect(fuori, isEmpty, reason: fuori.join('\n'));
  });

  test(
      'LA SOMMA DELLE FASCE STA FRA 40 E 50, con la lente e il nome piu '
      'corti e piu lunghi', () {
    // I minimi e i massimi VERI di ogni fessura, misurati e non dichiarati.
    (int, int) estremi(List<String> tavola) {
      var lo = 1 << 30, hi = 0;
      for (final forma in tavola) {
        for (final n in fisse(forma)) {
          if (n < lo) lo = n;
          if (n > hi) hi = n;
        }
      }
      return (lo, hi);
    }

    final t = tavole();
    final v = estremi(t['verdetto']!);
    final d = estremi(t['cosa dice']!);
    final w = estremi(t['cosa vuol dire']!);
    final a = estremi(t['aggancio']!);
    final g = estremi(t['gesto']!);
    final p = estremi(t['approdo']!);
    final r = estremi(t['perche']!);

    // Ogni verdetto porta una lente e un nome, ogni approdo un nome.
    final rispostaMin = v.$1 + lenteMin + nomeMin + d.$1 + w.$1;
    final rispostaMax = v.$2 + lenteMax + nomeMax + d.$2 + w.$2;
    final faiMin = a.$1 + g.$1 + p.$1 + nomeMin;
    final faiMax = a.$2 + g.$2 + p.$2 + nomeMax;
    final soloMin = a.$1 + g.$1 + r.$1;
    final soloMax = a.$2 + g.$2 + r.$2;
    print('ORDINE GA: lente da $lenteMin a $lenteMax parole, nome della '
        'carta da $nomeMin a $nomeMax. Risposta da $rispostaMin a '
        '$rispostaMax parole; cosa fare con l\'approdo da $faiMin a $faiMax, '
        'senza approdo da $soloMin a $soloMax.');
    for (final (nome, lo, hi) in [
      ('la risposta', rispostaMin, rispostaMax),
      ('il cosa fare con l\'approdo', faiMin, faiMax),
      ('il cosa fare della carta sola', soloMin, soloMax),
    ]) {
      expect(lo, greaterThanOrEqualTo(LaFormaDelResponso.minimo),
          reason: '$nome puo\' scendere a $lo parole');
      expect(hi, lessThanOrEqualTo(LaFormaDelResponso.massimo),
          reason: '$nome puo\' salire a $hi parole');
    }
    // E ogni verdetto porta davvero una lente e un nome, ogni approdo il
    // suo nome: senza, la somma qui sopra conterebbe parole che non ci sono.
    for (final f in t['verdetto']!) {
      expect(RegExp(r'\{(lente|inLente)\}').allMatches(f).length, 1,
          reason: 'il verdetto non porta una lente sola: "$f"');
      expect('{presente}'.allMatches(f).length, 1,
          reason: 'il verdetto non porta il nome della carta: "$f"');
    }
    for (final f in t['approdo']!) {
      expect('{futuro}'.allMatches(f).length, 1,
          reason: 'l\'approdo non porta il nome della carta: "$f"');
    }
    for (final k in [
      'cosa dice',
      'cosa vuol dire',
      'aggancio',
      'gesto',
      'perche'
    ]) {
      for (final f in t[k]!) {
        expect(f.contains('{'), isFalse,
            reason: '$k ha un segnaposto che la somma non conta: "$f"');
      }
    }
  });

  test(
      'LE COMPOSIZIONI VERE, a una, tre, quattro e dieci carte, stanno fra '
      '40 e 50', () {
    // Il cielo porta figure, cosi' la scelta senza ripetere salta davvero.
    const cielo = 'Marte forma una quadratura con il Sole di nascita, un nodo '
        'che si sta sciogliendo sulla strada di oggi.';
    var quante = 0;
    final fuori = <String>[];
    var rMin = 1 << 30, rMax = 0, fMin = 1 << 30, fMax = 0;
    final prima = LaMarcaDelGenere.formaCorrente;
    try {
      for (final f in forme) {
        LaMarcaDelGenere.formaCorrente = f;
        for (final tipo in TarotSpreadType.values) {
          for (final t in TarotTopic.values) {
            for (var seme = 0; seme < 30; seme++) {
              final s = TarotSpread.draw(
                  seed: seme * 31 + t.index, posizioni: tipo.posizioni);
              for (final c in [null, cielo]) {
                for (final domanda in [null, 'Che cosa devo fare adesso?']) {
                  final r = VoceDellaStesa.responsoDiCasa(s, t,
                      domandaScritta: domanda, fattoDelCielo: c);
                  quante++;
                  final pr = parole(r.risposta);
                  final pf = parole(r.cosaFare);
                  if (pr < rMin) rMin = pr;
                  if (pr > rMax) rMax = pr;
                  if (pf < fMin) fMin = pf;
                  if (pf > fMax) fMax = pf;
                  final difetti = ResponsoInterpretato(
                    arte: ArteInterpretata.tarocchi,
                    titolo: r.titolo,
                    risposta: r.risposta,
                    cosaFare: r.cosaFare,
                  ).difetti(conLaFonte: false);
                  if (difetti.isNotEmpty) {
                    fuori.add('${tipo.name} ${t.name} seme $seme: '
                        '${difetti.join("; ")}');
                  }
                }
              }
            }
          }
        }
      }
    } finally {
      LaMarcaDelGenere.formaCorrente = prima;
    }
    print('ORDINE GA: composizioni vere $quante. Risposta da $rMin a $rMax '
        'parole, cosa fare da $fMin a $fMax.');
    cardinaleMinimo(quante, 4 * 4 * 16 * 30 * 4,
        cosa: 'composizioni della lettura di casa',
        perche: 'Con meno stese la prova direbbe "in ogni composizione" '
            'guardandone poche.');
    expect(fuori, isEmpty, reason: fuori.take(8).join('\n'));
  });

  test('I NOMI ESTREMI: la carta piu corta e la piu lunga, con ogni lente', () {
    // **Le estremita' si costruiscono a mano**, perche' il caso le darebbe
    // di rado: L'Appeso e' una parola, La Ruota della Fortuna rovesciata
    // cinque.
    DrawnCard carta(String nome, SpreadPosition p, {bool rovesciata = false}) =>
        DrawnCard(
            card: TarotDeck.cards.firstWhere((c) => c.name == nome),
            position: p,
            reversed: rovesciata);
    final estremi = <TarotSpread>[
      for (final (cuore, approdo) in [
        (('L\'Appeso', false), ('L\'Eremita', false)),
        (('La Ruota della Fortuna', true), ('Cavaliere di Denari', true)),
        (('L\'Appeso', true), ('Il Mondo', false)),
        (('La Ruota della Fortuna', false), ('Tre di Spade', true)),
      ])
        TarotSpread([
          carta('Il Matto', SpreadPosition.passato),
          carta(cuore.$1, SpreadPosition.presente, rovesciata: cuore.$2),
          carta(approdo.$1 == cuore.$1 ? 'Asso di Coppe' : approdo.$1,
              SpreadPosition.futuro,
              rovesciata: approdo.$2),
        ]),
      TarotSpread([carta('L\'Appeso', SpreadPosition.cartaSola)]),
      TarotSpread([
        carta('La Ruota della Fortuna', SpreadPosition.cartaSola,
            rovesciata: true)
      ]),
    ];
    var quante = 0;
    final fuori = <String>[];
    for (final s in estremi) {
      for (final t in TarotTopic.values) {
        final r = VoceDellaStesa.responsoDiCasa(s, t);
        quante++;
        for (final p in [r.risposta, r.cosaFare]) {
          if (!LaFormaDelResponso.aMisura(p)) {
            fuori.add(
                '${t.name}, ${s.cards.map((c) => c.displayName).join(" + ")}: '
                '${parole(p)} parole, "$p"');
          }
        }
      }
    }
    cardinaleMinimo(quante, 6 * 16, cosa: 'letture con i nomi estremi');
    expect(fuori, isEmpty, reason: fuori.take(6).join('\n'));
  });
}
