import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/viaggio/il_tetto_delle_chiamate.dart';
import 'package:esoteric_circle/core/viaggio/la_domanda_capita.dart';
import 'package:esoteric_circle/core/viaggio/tetti_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **I LIMITI DEL VIAGGIO STANNO NELLA MATRICE, E NON SI MOSTRA UN MURO.**
/// Ordine DI voce 15, 12 settembre 2026.
///
/// **Le parole dell'ordine:** *"La matrice in lib/core/entitlement/
/// plan_catalog.dart resta la fonte unica"*, con i valori scritti per esteso:
/// discese al giorno 1, 1, 1 e 2; segni 1 a settimana, 3 a settimana, 1 al
/// giorno, 5 al giorno; nutrimento sempre; un tetto tecnico di dieci chiamate
/// al modello al giorno; e al tetto *"non si mostra un muro: si dice quando
/// torna disponibile e si offre il nutrimento"*.
///
/// **I VALORI SONO SCRITTI QUI, NON LETTI DALLA MATRICE**: la prova confronta
/// la matrice con l'ordine, e poi pretende che chi impone i limiti legga la
/// matrice. Una cella sbagliata non deve poter far passare se stessa.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const ordine = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];

  List<String> celle(RigaDelPiano r) =>
      PlanCatalog.matrix.firstWhere((f) => f.chiave == r).values;

  test('LE TRE RIGHE DELL ORDINE SONO NELLA MATRICE, parola per parola', () {
    expect(celle(RigaDelPiano.discese),
        ['1 al giorno', '1 al giorno', '1 al giorno', '2 al giorno']);
    expect(celle(RigaDelPiano.segni),
        ['1 a settimana', '3 a settimana', '1 al giorno', '5 al giorno']);
    expect(celle(RigaDelPiano.nutrimento), everyElement('Sempre'),
        reason: 'il nutrimento non chiama nessun modello e l ordine lo vuole '
            'aperto in tutti i piani');
    // ignore: avoid_print
    print('ORDINE DI VOCE 15: discese ${celle(RigaDelPiano.discese)}, segni '
        '${celle(RigaDelPiano.segni)}, nutrimento '
        '${celle(RigaDelPiano.nutrimento)}');
  });

  test('I TETTI DEL VIAGGIO LEGGONO LA MATRICE, e prima del riconoscimento '
      'resta uno per tutti', () {
    final dopo = [
      for (final t in ordine)
        TettiDelViaggio.quanteAlGiorno(giaRiconosciuto: true, tier: t, demo: false),
    ];
    final prima = [
      for (final t in ordine)
        TettiDelViaggio.quanteAlGiorno(
            giaRiconosciuto: false, tier: t, demo: false),
    ];
    // ignore: avoid_print
    print('ORDINE DI VOCE 15: discese al giorno prima del riconoscimento '
        '$prima, dopo $dopo');
    expect(dopo, [1, 1, 1, 2]);
    expect(prima, [1, 1, 1, 1],
        reason: 'prima del riconoscimento l Illuminato scende due volte al '
            'giorno: i quattro viaggi in quattro giorni sono il metodo');
    for (final t in ordine) {
      expect(TettiDelViaggio.discesePerIlPiano(t),
          PlanCatalog.limiteGiornaliero(RigaDelPiano.discese, t),
          reason: 'il tetto del ${t.label} non viene dalla matrice');
    }
  });

  test('I SEGNI SI CONTANO NEL LORO PERIODO, al giorno o alla settimana', () {
    final letti = {
      for (final t in ordine) t.label: TettiDelViaggio.segniPerIlPiano(t),
    };
    // ignore: avoid_print
    print('ORDINE DI VOCE 15: segni per piano $letti');
    expect(TettiDelViaggio.segniPerIlPiano(Tier.free),
        (quanti: 1, allaSettimana: true));
    expect(TettiDelViaggio.segniPerIlPiano(Tier.tier1),
        (quanti: 3, allaSettimana: true));
    expect(TettiDelViaggio.segniPerIlPiano(Tier.tier2),
        (quanti: 1, allaSettimana: false));
    expect(TettiDelViaggio.segniPerIlPiano(Tier.tier3),
        (quanti: 5, allaSettimana: false));

    final adesso = DateTime(2026, 9, 12, 12);
    bool puo(Tier t, List<DateTime> chiesti) =>
        TettiDelViaggio.siPuoChiedereUnSegno(
            segniChiesti: chiesti, adesso: adesso, tier: t, demo: false);
    // Il Viandante: uno a settimana, e la settimana scorre.
    expect(puo(Tier.free, [adesso.subtract(const Duration(days: 6))]), isFalse,
        reason: 'il Viandante chiede un secondo segno dentro la settimana');
    expect(puo(Tier.free, [adesso.subtract(const Duration(days: 8))]), isTrue);
    // L'Adepto: uno al giorno.
    expect(puo(Tier.tier2, [adesso.subtract(const Duration(hours: 1))]),
        isFalse);
    expect(puo(Tier.tier2, [adesso.subtract(const Duration(days: 1))]), isTrue,
        reason: 'l Adepto non puo chiedere il segno di oggi per quello di ieri');
    // L'Illuminato: cinque al giorno.
    expect(
        puo(Tier.tier3,
            List.generate(4, (i) => adesso.subtract(Duration(minutes: i)))),
        isTrue);
    expect(
        puo(Tier.tier3,
            List.generate(5, (i) => adesso.subtract(Duration(minutes: i)))),
        isFalse);
  });

  test('AL TETTO NON C E UN MURO: si dice quando si torna, si offre il '
      'nutrimento, e nessuna promessa di Eos', () {
    final discese = TettiDelViaggio.percheNonOggi(
        giaRiconosciuto: true,
        quanteOggi: 1,
        tier: Tier.free,
        demo: false,
        conArticolo: 'la Volpe')!;
    final segno = TettiDelViaggio.quandoTornaUnSegno(
        segniChiesti: [DateTime(2026, 9, 10, 9)],
        adesso: DateTime(2026, 9, 12, 12),
        tier: Tier.free,
        conArticolo: 'la Volpe');
    // ignore: avoid_print
    print('ORDINE DI VOCE 15: al tetto delle discese "$discese"; al tetto dei '
        'segni "$segno"');
    for (final riga in [discese, segno]) {
      expect(riga.toLowerCase().contains('eos'), isFalse,
          reason: 'si promette di comprare con gli Eos una cosa che nessuna '
              'strada vende: $riga');
      expect(riga, contains('nutrire la Volpe'),
          reason: 'al tetto non si offre il nutrimento: $riga');
      expect(riga, isNot(matches(RegExp(r'\b(nutrirlo|chiedergli)\b'))),
          reason: 'il pronome maschile sbaglia sulla Volpe: $riga');
      expect(riga, isNot(matches(RegExp(r'\d'))),
          reason: 'la riga dice il tempo in cifre: $riga');
    }
    expect(discese, contains('domani'),
        reason: 'al tetto delle discese non si dice quando si torna');
    // Il segno chiesto giovedi 10 torna giovedi 17.
    expect(segno, contains('giovedì'),
        reason: 'al tetto dei segni non si dice quando torna: $segno');
  });

  group('IL TETTO TECNICO DELLE DIECI CHIAMATE', () {
    test('dieci si prendono, l undicesima no, e il giorno dopo si riparte',
        () async {
      final oggi = DateTime(2026, 9, 12, 10);
      final esiti = <bool>[
        for (var i = 0; i < 11; i++)
          await IlTettoDelleChiamate.prendiUnaChiamata(adesso: oggi, demo: false),
      ];
      // ignore: avoid_print
      print('ORDINE DI VOCE 15: undici chiamate nello stesso giorno danno '
          '$esiti');
      expect(esiti.where((e) => e).length,
          TettiDelViaggio.chiamateAlModelloAlGiorno);
      expect(esiti.last, isFalse,
          reason: 'l undicesima chiamata del giorno arriva al modello');
      expect(TettiDelViaggio.chiamateAlModelloAlGiorno, 10);
      expect(
          await IlTettoDelleChiamate.prendiUnaChiamata(
              adesso: oggi.add(const Duration(days: 1)), demo: false),
          isTrue,
          reason: 'il tetto di ieri vale anche oggi');
    });

    test('oltre il tetto la domanda libera la capisce la tabella, senza '
        'chiamare il modello', () async {
      var chiamato = false;
      final (tema, fonte) = await LaDomandaCapita.tema(
        'Devo scegliere fra due lavori',
        chiamata: (_, __) async {
          chiamato = true;
          return 'scelta';
        },
        prendiUnaChiamata: () async => false,
      );
      // ignore: avoid_print
      print('ORDINE DI VOCE 15: oltre il tetto il tema e $tema, dalla via '
          '${fonte.name}, e il modello chiamato: $chiamato');
      expect(chiamato, isFalse, reason: 'oltre il tetto si chiama il modello');
      expect(fonte, isNot(FonteDelTema.modello));
    });

    test('in Demo il tetto tecnico non conta', () async {
      final oggi = DateTime(2026, 9, 12, 10);
      for (var i = 0; i < 20; i++) {
        expect(
            await IlTettoDelleChiamate.prendiUnaChiamata(adesso: oggi, demo: true),
            isTrue);
      }
    });
  });
}
