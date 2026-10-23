import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_lettura_finta_della_stesa.dart';

/// **I DUE PARAGRAFI DELLA LUNGA PASSANO DALLA CURA. Ordine FS, 13 ottobre
/// 2026.**
///
/// Misurato col modello vero sulla Croce Celtica alla profondita' Lunga
/// (`docs/collaudo/FS/la_croce_celtica_lunga.txt`): quando l'ultima lettura
/// cadeva per una frase col genere sbagliato, la cura toglieva quella frase
/// e ricostruiva la lettura senza i due paragrafi, e a video arrivavano i
/// soli tre paragrafi: il fondatore, "la profondita' Lunga non funziona".
///
/// **ORDINE GA, 20 ottobre 2026, voci GA.03 e GA.07.** La Lunga ha un
/// approfondimento solo (il quarto paragrafo, la contemplazione, viene dal
/// corpus dei riti): la cura lo conserva, e la frase tolta non deve portare
/// un paragrafo fuori dalla misura di 40-50 parole. LAPIDE: i due paragrafi
/// `approfondimento1` e `approfondimento2` dell'ordine FN.
void main() {
  test('la lettura curata conserva l\'approfondimento della Lunga', () {
    final s = TarotSpread.draw(seed: 3);
    final buona = letturaFinta(s, lunga: true);
    // 45 parole, e con la frase col genere 49.
    final corto = buona.cosaFare.replaceFirst(
        'davvero a quello che cerchi adesso.', 'a quello che cerchi.');
    final l = LetturaDelModello(
      risposta: buona.risposta,
      cosaFare: '$corto Sei pronto a partire.',
      titolo: 'Un passo concreto adesso',
      approfondimento: buona.approfondimento,
    );
    final curata =
        LaLetturaDellaStesa.senzaLeFrasiColGenere(l, CourtesyForm.neutral);
    expect(curata, isNotNull,
        reason: 'la frase col genere ("Sei pronto") doveva essere tolta e '
            'il resto mostrato');
    expect(curata!.cosaFare, corto,
        reason: 'la cura non ha tolto la frase col genere');
    expect(curata.approfondimento, approfondimentoFinto,
        reason: 'la cura ha perso il paragrafo della Lunga');
    expect(LaFormaDelResponso.aMisura(curata.cosaFare), isTrue,
        reason: 'la cura ha portato il cosa fare fuori misura');
    expect(LaLetturaDellaStesa.scarto(curata, s, forma: CourtesyForm.neutral),
        isNull);
  });

  test('la frase col genere nell\'approfondimento si toglie anche li\'', () {
    final s = TarotSpread.draw(seed: 4);
    final buona = letturaFinta(s, lunga: true);
    final l = LetturaDelModello(
      risposta: buona.risposta,
      cosaFare: buona.cosaFare,
      approfondimento:
          '${buona.approfondimento.replaceFirst(' senza commentarla subito.', '.')} Ti ha lasciato stanco.',
    );
    final curata =
        LaLetturaDellaStesa.senzaLeFrasiColGenere(l, CourtesyForm.neutral);
    expect(curata, isNotNull);
    expect(curata!.approfondimento, isNot(contains('stanco')));
    expect(curata.approfondimento, isNotEmpty);
  });
}
