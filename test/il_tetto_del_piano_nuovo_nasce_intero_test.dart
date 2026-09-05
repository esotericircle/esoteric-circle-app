import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **IL TETTO DEL PIANO NUOVO NASCE INTERO.** Ordine CQ voce 6.21,
/// 4 settembre 2026.
///
/// **Parole del fondatore**, dopo aver attivato l'Illuminato sul suo telefono
/// con una gettata gia' fatta: *"non dovrebbero essere 50 nel momento in cui
/// torni alla funzionalita' rune dopo aver attivato il piano? la prima era
/// gratis cioe' compresa."*
///
/// **Il difetto, misurato a video prima di curarlo.** Il collaudo del
/// 4 settembre ha letto *"Ti restano 49 gettate di rune su 50"* subito dopo
/// l'attivazione: il residuo e' `tetto meno gettate fatte oggi`, e il conto
/// giornaliero non sapeva niente dei piani.
///
/// **Perche' e' di sostanza e non un dettaglio.** Chi sale di piano sta
/// comprando QUEL tetto adesso, e trovarlo gia' eroso da consumi fatti sotto
/// un tetto piu' basso e' una promessa non mantenuta nel momento in cui uno ha
/// appena pagato.
///
/// **Cosa NON deve succedere**, ed e' la meta' che rende la cura difendibile:
/// chi scende di piano non deve guadagnare niente, e il condono non deve mai
/// valere piu' del tetto vecchio.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Il tetto delle gettate di un piano, dal listino e non da un numero
  /// scritto qui: se il listino cambia, questa prova segue.
  int tetto(QuestionAllowance borsa, Tier tier) =>
      borsa.limiteGettate(tier) ?? -1;

  test('salendo di piano il tetto nuovo si vede intero', () {
    final borsa = QuestionAllowance();
    final tettoDemo = tetto(borsa, Tier.free);
    final tettoAlto = tetto(borsa, Tier.tier3);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.21: tetto Demo $tettoDemo, tetto Illuminato '
        '$tettoAlto');
    cardinaleMinimo(tettoAlto, 2,
        cosa: 'gettate al giorno del piano alto',
        perche: 'Con un tetto di uno o zero non si distingue un tetto intero '
            'da uno eroso, e la prova direbbe il vero senza misurare niente.');
    expect(tettoAlto, greaterThan(tettoDemo),
        reason: 'il piano alto non ha piu gettate di quello basso: questa '
            'prova non sta misurando una salita');

    // Si comincia dal piano basso e si consuma tutto quello che concede.
    borsa.gettateRimaste(Tier.free);
    for (var i = 0; i < tettoDemo; i++) {
      borsa.registraGettata(Tier.free);
    }
    final finiteSotto = borsa.gettateRimaste(Tier.free);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.21: consumato tutto il piano basso, restano '
        '$finiteSotto');
    expect(finiteSotto, 0,
        reason: 'il piano basso non e finito: la prova non e nella '
            'condizione che il fondatore ha vissuto');

    // E adesso si sale.
    final dopoLaSalita = borsa.gettateRimaste(Tier.tier3);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.21: salito al piano alto, restano $dopoLaSalita '
        'su $tettoAlto');
    expect(dopoLaSalita, tettoAlto,
        reason: 'dopo la salita restano $dopoLaSalita su $tettoAlto: il '
            'consumo fatto sotto il tetto vecchio erode ancora il tetto '
            'nuovo, ed e esattamente cio che il fondatore ha letto a video');
  });

  test('e scendendo di piano non si guadagna niente', () {
    // **LA META CHE RENDE LA CURA DIFENDIBILE.** Un azzeramento a ogni
    // cambio di piano sarebbe una porta aperta: si sale, si consuma, si
    // scende, si risale.
    final borsa = QuestionAllowance();
    final tettoAlto = tetto(borsa, Tier.tier3);
    borsa.gettateRimaste(Tier.tier3);
    for (var i = 0; i < 3; i++) {
      borsa.registraGettata(Tier.tier3);
    }
    final restaAlto = borsa.gettateRimaste(Tier.tier3);
    borsa.gettateRimaste(Tier.free);
    final tornatoAlto = borsa.gettateRimaste(Tier.tier3);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.21: dopo tre gettate restano $restaAlto, dopo '
        'una scesa e risalita $tornatoAlto');
    expect(restaAlto, tettoAlto - 3,
        reason: 'le tre gettate non sono state contate');
    expect(tornatoAlto, lessThanOrEqualTo(restaAlto ?? 0),
        reason: 'scendere e risalire ha restituito gettate: $tornatoAlto '
            'contro $restaAlto, ed e una porta aperta');
  });

  test('e il condono non vale mai piu del tetto vecchio', () {
    // Chi non ha consumato niente sotto non deve ricevere nessun regalo:
    // il condono e' il consumo, non il tetto.
    final borsa = QuestionAllowance();
    final tettoAlto = tetto(borsa, Tier.tier3);
    borsa.gettateRimaste(Tier.free);
    final senzaConsumo = borsa.gettateRimaste(Tier.tier3);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.21: salendo senza aver consumato niente, restano '
        '$senzaConsumo su $tettoAlto');
    expect(senzaConsumo, tettoAlto,
        reason: 'salendo senza consumo il tetto non e intero');
  });
}
