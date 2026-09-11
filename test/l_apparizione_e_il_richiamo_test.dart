// ignore_for_file: avoid_print
import 'dart:math';

import 'package:esoteric_circle/core/viaggio/l_apparizione.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/vocabolario_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'APPARIZIONE FUORI DAL VIAGGIO E LE SCENE CHE SI PARLANO.**
/// Ordine DE voci 10 e 11, 11 settembre 2026.
void main() {
  final adesso = DateTime(2026, 9, 11, 18);

  bool prova({
    bool riconosciuto = true,
    bool senzaMoto = false,
    bool attenzione = false,
    DateTime? ultima,
    bool giaTirata = false,
    double tiro = 0.0,
  }) =>
      LApparizione.siPuoMostrare(
        riconosciuto: riconosciuto,
        senzaMoto: senzaMoto,
        ilMomentoChiedeAttenzione: attenzione,
        ultimaVolta: ultima,
        adesso: adesso,
        giaTirataInQuestaSessione: giaTirata,
        caso: _CasoFinto(tiro),
      );

  group('DE.10, le cinque porte dell apparizione', () {
    test('PRIMA DELLA RIVELAZIONE NON COMPARE MAI', () {
      expect(prova(riconosciuto: false), isFalse,
          reason: 'la sagoma attraversa il cielo di chi non ha ancora un '
              'animale');
    });

    test('CON RIDUCI MOVIMENTO NON COMPARE MAI', () {
      expect(prova(senzaMoto: true), isFalse,
          reason: 'la regola di casa vale anche quando il movimento e bello');
    });

    test('DENTRO UN MOMENTO CHE CHIEDE ATTENZIONE NON COMPARE MAI', () {
      expect(prova(attenzione: true), isFalse,
          reason: 'un apparizione dentro una festa o davanti a un responso in '
              'arrivo non e un regalo, e un disturbo');
    });

    test('MAI DUE VOLTE NELLA STESSA SESSIONE', () {
      expect(prova(giaTirata: true), isFalse,
          reason: 'il tiro si puo fare due volte nella stessa sessione');
    });

    test('MAI DUE VOLTE NELLO STESSO GIORNO', () {
      expect(prova(ultima: DateTime(2026, 9, 11, 9)), isFalse,
          reason: 'si e gia mostrata stamattina e si rimostra stasera');
      expect(prova(ultima: DateTime(2026, 9, 10, 23, 59)), isTrue,
          reason: 'si e mostrata ieri sera e oggi e gia bloccata');
    });

    test('E QUANDO TUTTE E CINQUE LE PORTE SONO APERTE, IL CASO DECIDE', () {
      // **REGOLA H**: una prova che dimostra solo i divieti sarebbe verde
      // anche con l apparizione spenta del tutto.
      expect(prova(tiro: 0.0), isTrue, reason: 'non compare mai');
      expect(prova(tiro: 0.99), isFalse,
          reason: 'compare sempre: la probabilita non e una probabilita');
      expect(prova(tiro: LApparizione.quanteProbabilita - 0.001), isTrue);
      expect(prova(tiro: LApparizione.quanteProbabilita), isFalse);
    });
  });

  test('DE.10: IL NUMERO DICHIARATO E QUELLO CHE ESCE, un paio a settimana',
      () {
    // **Il numero non si crede, si conta.** L ordine chiede *"nell ordine di
    // un paio di volte a settimana"*, e il tetto di una al giorno fa da
    // soffitto: la funzione non e una moltiplicazione.
    final quadro = <String, String>{
      for (final s in [1.0, 1.5, 2.0, 4.0, 8.0])
        '$s sessioni al giorno':
            LApparizione.quanteASettimana(s).toStringAsFixed(2),
    };
    print('ORDINE DE VOCE 10: apparizioni a settimana, per quante volte al '
        'giorno si apre l app: $quadro');
    expect(LApparizione.quanteASettimana(1.5), inInclusiveRange(2.0, 3.0),
        reason: 'chi apre l app una volta e mezza al giorno la vede '
            '${LApparizione.quanteASettimana(1.5).toStringAsFixed(2)} volte a '
            'settimana, e l ordine chiede un paio');
    // **E per chi apre l app otto volte al giorno resta rara**, che e il caso
    // che il tetto giornaliero esiste per coprire.
    expect(LApparizione.quanteASettimana(8), lessThan(7.01),
        reason: 'chi apre l app spesso la vedrebbe piu di una volta al '
            'giorno: non sarebbe piu un apparizione, sarebbe un animazione');
  });

  test('DE.10: SU MILLE SESSIONI IL CONTO STA DOVE DEVE', () {
    // La misura vera, col caso vero: mille sessioni, una al giorno, e si
    // conta quante volte si e mostrata.
    final caso = Random(2026);
    var quante = 0;
    DateTime? ultima;
    for (var giorno = 0; giorno < 1000; giorno++) {
      final oggi = DateTime(2026, 1, 1).add(Duration(days: giorno));
      if (LApparizione.siPuoMostrare(
        riconosciuto: true,
        senzaMoto: false,
        ilMomentoChiedeAttenzione: false,
        ultimaVolta: ultima,
        adesso: oggi,
        giaTirataInQuestaSessione: false,
        caso: caso,
      )) {
        quante++;
        ultima = oggi;
      }
    }
    final aSettimana = quante / 1000 * 7;
    print('ORDINE DE VOCE 10: su mille giorni con una sessione al giorno si e '
        'mostrata $quante volte, cioe ${aSettimana.toStringAsFixed(2)} volte '
        'a settimana');
    expect(aSettimana, inInclusiveRange(1.3, 2.5),
        reason: 'misurate ${aSettimana.toStringAsFixed(2)} apparizioni a '
            'settimana');
  });

  group('DE.11, le scene che si parlano', () {
    List<String> idDi(int luogo, int cosa, int gesto, int momento) => [
          VocabolarioDelViaggio.luoghi[luogo].id,
          VocabolarioDelViaggio.cose[cosa].id,
          VocabolarioDelViaggio.gesti[gesto].id,
          VocabolarioDelViaggio.momenti[momento].id,
        ];

    test('QUANTE SCENE INDIETRO, e il numero e dichiarato', () {
      print('ORDINE DE VOCE 11: il richiamo guarda '
          '${IlRichiamoDelleScene.quanteSceneIndietro} scene indietro');
      expect(IlRichiamoDelleScene.quanteSceneIndietro, 5);
    });

    test('SE L ELEMENTO E TORNATO, il richiamo lo nomina', () {
      final oggi = idDi(0, 3, 2, 1);
      final riga = IlRichiamoDelleScene.laRiga(
        precedenti: [idDi(5, 3, 7, 2), idDi(1, 9, 4, 0)],
        oggi: oggi,
        nomeDellElemento: VocabolarioDelViaggio.cose[3].nome,
        quale: 1,
      );
      print('ORDINE DE VOCE 11: il richiamo dice "$riga"');
      expect(riga, isNotNull,
          reason: 'l elemento era gia comparso e il richiamo tace');
      expect(riga!.toLowerCase(),
          contains(VocabolarioDelViaggio.cose[3].nome.toLowerCase()),
          reason: 'il richiamo non nomina l elemento che riprende');
    });

    test('REGOLA H: SE NON C E NIENTE DA RIPRENDERE, il richiamo TACE', () {
      // **Una continuita inventata vale meno di nessuna continuita**, ed e la
      // riga dell ordine.
      final riga = IlRichiamoDelleScene.laRiga(
        precedenti: [idDi(5, 6, 7, 2), idDi(1, 9, 4, 0)],
        oggi: idDi(0, 3, 2, 1),
        nomeDellElemento: VocabolarioDelViaggio.cose[3].nome,
        quale: 1,
      );
      print('ORDINE DE VOCE 11: senza niente da riprendere il richiamo dice '
          '${riga ?? "niente"}');
      expect(riga, isNull,
          reason: 'il richiamo nomina un elemento che non era mai comparso');
    });

    test('E NON GUARDA PIU INDIETRO DI CINQUE', () {
      final vecchie = [
        for (var i = 0; i < 8; i++) idDi(i % 12, i % 18, i % 10, i % 4),
      ];
      // L elemento della sesta scena indietro non deve valere.
      final riga = IlRichiamoDelleScene.laRiga(
        precedenti: vecchie,
        oggi: [vecchie[6][0], 'mai_visto_cosa', 'mai_visto_gesto', 'mai_visto'],
        nomeDellElemento: 'la porta chiusa',
        quale: 0,
      );
      print('ORDINE DE VOCE 11: un elemento di sei scene fa da richiamo? '
          '${riga ?? "no"}');
      expect(riga, isNull,
          reason: 'il richiamo pesca da sei scene fa: a quella distanza la '
              'persona non si ricorda, e un richiamo che non si riconosce e '
              'una coincidenza');
    });
  });
}

/// Un caso finto che torna sempre lo stesso numero: serve a provare le porte
/// senza dipendere dal caso vero.
class _CasoFinto implements Random {
  _CasoFinto(this.quanto);

  final double quanto;

  @override
  double nextDouble() => quanto;

  @override
  bool nextBool() => quanto < 0.5;

  @override
  int nextInt(int max) => (quanto * max).floor();
}
