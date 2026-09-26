import 'dart:math' as math;

import 'package:esoteric_circle/features/sigilli/spirale_di_stelle.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA SPIRALE SI VEDE COME SPIRALE. Ordine CE voce 14.
///
/// **Il fatto, trovato guardando.** Il fondatore ha aperto
/// `docs/preview/festa-costellazione.png` e al culmine della festa ha visto un
/// tappeto d'oro uniforme, senza bracci e senza verso di rotazione.
///
/// **CIO' CHE SI MUOVE SI PROVA SULLA FORMA, non sulla presenza.** Un tappeto e
/// una spirale hanno le stesse stelle, la stessa quantita' e lo stesso costo:
/// contarle non distingue le due cose, e infatti le prove che le contavano
/// erano verdi mentre il difetto era a video. Qui si misurano due grandezze,
/// dichiarate:
///
/// **1. IL CONTRASTO ANGOLARE.** Si prendono le stelle di una corona e si
/// guarda quanto la loro distribuzione attorno al centro si stacca
/// dall'uniforme, con l'ampiezza dell'armonica che corrisponde al numero dei
/// bracci. Vale 0 per un disco uniforme e sale verso 1 quando le stelle si
/// raccolgono in bracci. **Il rumore non e' zero**: per N stelle sparse a caso
/// vale circa 1 su radice di N, cioe' 0,05 per quattrocento stelle, e la soglia
/// sta molto sopra quel rumore.
///
/// **2. L'AVVOLGIMENTO.** Il contrasto da solo non distingue una spirale da un
/// ventaglio a tre pale, che ha bracci ma non gira: la differenza e' che in una
/// spirale i bracci sono SPOSTATI a raggi diversi. Si misura la fase della
/// stessa armonica su due corone, dentro e fuori, e si chiede che non
/// coincidano.
///
/// **LA MISURA DI PRIMA, per il rapporto.** Prima della cura le ampiezze delle
/// prime sei armoniche stavano fra 0,01 e 0,15 su tre corone e quattro
/// istanti: tutte al livello del rumore, nessuna dominante. Un disco uniforme,
/// esattamente cio' che il fondatore ha visto.
void main() {
  /// Le corone su cui si guarda, in quote del raggio pieno.
  const dentro = [0.15, 0.35];
  const mezzo = [0.35, 0.6];
  const fuori = [0.6, 0.9];

  /// Gli istanti: la spirale e' viva per tutto il suo tempo, non a un momento.
  const istanti = [600, 1000, 1400];

  /// Sotto questa ampiezza la corona e' un tappeto. Il rumore per qualche
  /// centinaio di stelle vale circa 0,05: qui si sta sei volte sopra.
  const sogliaDelContrasto = 0.30;

  /// Due corone che portano i bracci nello stesso punto sono un ventaglio, non
  /// una spirale. Un decimo di radiante e' gia' piu' del giro che il rumore
  /// puo' spostare con qualche centinaio di stelle.
  const sogliaDellAvvolgimento = 0.10;

  (double, double) armonica(List<DoveStaUnaStella> vive, List<double> corona) {
    final scelte = vive
        .where((s) => s.raggio >= corona[0] && s.raggio < corona[1])
        .toList();
    if (scelte.length < 40) return (0, 0);
    var c = 0.0;
    var s = 0.0;
    for (final st in scelte) {
      c += math.cos(SpiraleDiStelleState.bracci * st.angolo);
      s += math.sin(SpiraleDiStelleState.bracci * st.angolo);
    }
    final ampiezza = math.sqrt(c * c + s * s) / scelte.length;
    final fase = math.atan2(s, c) / SpiraleDiStelleState.bracci;
    return (ampiezza, fase);
  }

  test('a ogni raggio e a ogni istante i bracci si vedono', () {
    final semi = SpiraleDiStelleState.semiPerLeProve();
    final deboli = <String>[];
    var minimo = 1.0;
    for (final ms in istanti) {
      final vive = stelleVive(semi, ms);
      for (final corona in [dentro, mezzo, fuori]) {
        final (ampiezza, _) = armonica(vive, corona);
        if (ampiezza == 0) continue;
        if (ampiezza < minimo) minimo = ampiezza;
        if (ampiezza < sogliaDelContrasto) {
          deboli.add('a $ms millesimi, corona ${corona[0]}-${corona[1]}: '
              '${ampiezza.toStringAsFixed(3)}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 14: contrasto angolare piu\' basso '
        '${minimo.toStringAsFixed(3)}, soglia $sogliaDelContrasto');
    expect(deboli, isEmpty,
        reason: 'qui le stelle sono sparse come un tappeto invece di '
            'raccogliersi nei bracci: $deboli');
  });

  test('e i bracci sono avvolti, non dritti come le pale di un ventaglio', () {
    final semi = SpiraleDiStelleState.semiPerLeProve();
    final dritti = <String>[];
    var minimo = math.pi;
    for (final ms in istanti) {
      final vive = stelleVive(semi, ms);
      final (aDentro, faseDentro) = armonica(vive, dentro);
      final (aFuori, faseFuori) = armonica(vive, fuori);
      if (aDentro == 0 || aFuori == 0) continue;
      // La fase dell'armonica dei bracci si ripete ogni giro diviso i bracci:
      // la distanza fra due fasi si misura dentro quel passo, e la via piu'
      // corta e' quella che conta.
      const passo = 2 * math.pi / SpiraleDiStelleState.bracci;
      var scarto = (faseFuori - faseDentro) % passo;
      if (scarto > passo / 2) scarto = passo - scarto;
      if (scarto < minimo) minimo = scarto;
      if (scarto < sogliaDellAvvolgimento) {
        dritti.add('a $ms millesimi: ${scarto.toStringAsFixed(3)} radianti');
      }
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 14: avvolgimento piu\' piccolo fra dentro e fuori '
        '${minimo.toStringAsFixed(3)} radianti, soglia $sogliaDellAvvolgimento');
    expect(dritti, isEmpty,
        reason: 'i bracci stanno nello stesso punto dentro e fuori: e\' un '
            'ventaglio che gira, non una spirale: $dritti');
  });

  test('e i vincoli gia\' misurati dall\'ordine AV restano in piedi', () {
    // **LA CURA NON DEVE PEGGIORARE CIO' CHE ERA GIA' MISURATO.** L'ordine AV
    // aveva fissato 2.600 stelle vive al culmine e una sola chiamata di
    // disegno: qui si guarda la quantita', che e' la grandezza che la
    // seminatura poteva cambiare senza che nessuno se ne accorgesse.
    final semi = SpiraleDiStelleState.semiPerLeProve();
    final alCulmine =
        stelleVive(semi, SpiraleDiStelle.istanteDelCulmine.inMilliseconds);
    // ignore: avoid_print
    print('ORDINE CE VOCE 14: stelle vive al culmine ${alCulmine.length}, '
        'semi ${semi.length}');
    expect(alCulmine.length, greaterThanOrEqualTo(400),
        reason: 'la cura ha spento le stelle: al culmine ne restano '
            '${alCulmine.length}');
  });
}
