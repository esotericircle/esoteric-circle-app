import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_carta_in_quattro_pezzi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';

/// **OGNI PEZZO SI GRATTA, NESSUNO CADE DA SOLO.** Ordine FZ voce FZ.04, 17
/// ottobre 2026. Sostituisce `la_testa_non_si_vede_prima_della_quarta_test`
/// (ordine DI voce 10): quella guardia misurava che la testa restasse
/// protetta fino alla quarta discesa, e che alla quarta cadesse da sola.
/// **L'ordine FZ.04 toglie proprio questa regola**: *"Ogni volta che la
/// persona segue l'ombra di quell'animale, gratta con il dito un pezzo della
/// sua carta. Il volto dell'animale sta nel quarto pezzo e si scopre per
/// ultimo"*, non perche' un cumulo lo protegga e lo lasci cadere da solo, ma
/// perche' e' l'ultimo pezzo a essere grattato.
///
/// **LE DUE META'**, come la guardia che sostituisce. La prima dimostra che
/// ogni discesa puo' scostare soltanto il suo pezzo, mai un altro: il dito
/// non raggiunge gli altri tre pezzi da nessun punto, nemmeno il quarto. La
/// seconda dimostra che **nessun pezzo cade da solo**: aperto senza aver
/// scostato niente, anche al quarto pezzo la cenere resta piena.
void main() {
  /// **QUANTE POSIZIONI DEL DITO SI PROVANO PER OGNI ANIMALE E PER OGNI
  /// PEZZO.** Ventuno per ventuno, fuori dai bordi compresi.
  const quanti = 21;
  const da = -0.5;
  const a = 1.5;
  const scena = Size(390, 844);
  const misura = Size(1080, 1920);

  test(
      'REGOLA H NUOVA, PRIMA META: ogni discesa scosta soltanto il suo pezzo, '
      'il dito non raggiunge gli altri tre da nessun punto, per tutti e '
      'dodici e tutti i quattro pezzi', () {
    expect(AnimalCatalog.animals.length, 12);

    var provate = 0;
    var celle = 0;
    for (final animale in AnimalCatalog.animals) {
      for (var pezzo = 0; pezzo < LaCartaInQuattroPezzi.pezzi; pezzo++) {
        final velo = LaCartaInQuattroPezzi(animale.name, pezzo);
        expect(velo.scostabile, isNotEmpty,
            reason: '${animale.name} pezzo $pezzo: nessuna cella scostabile');
        celle += velo.scostabile.length;
        // **OGNI CELLA SCOSTABILE APPARTIENE AL PEZZO ATTIVO**, e a nessun
        // altro.
        for (final i in velo.scostabile) {
          expect(velo.pezzoDi(i), pezzo,
              reason: '${animale.name}: la cella $i e\' scostabile al pezzo '
                  '$pezzo ma appartiene a un\'altra fascia');
        }
        // **E LA MANO NON RAGGIUNGE NESSUN'ALTRA FASCIA**, da nessun punto,
        // nemmeno spingendo oltre i bordi dell'illustrazione.
        for (var ix = 0; ix < quanti; ix++) {
          for (var iy = 0; iy < quanti; iy++) {
            final dito = Offset(da + (a - da) * ix / (quanti - 1),
                da + (a - da) * iy / (quanti - 1));
            provate++;
            for (final i in velo.scoperteDa(dito, dito,
                IlVeloCheSiScosta.doveStaLIllustrazione(scena, misura).size)) {
              expect(velo.pezzoDi(i), pezzo,
                  reason: '${animale.name}: il dito in $dito scosta la '
                      'cella $i, che non e\' del pezzo attivo $pezzo');
            }
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE FZ VOCE FZ.04, I QUATTRO PEZZI: $celle celle scostabili '
        'guardate, $provate posizioni del dito, nessuna fuori dal suo pezzo');
    expect(provate, 12 * 4 * quanti * quanti,
        reason: 'la prova ha guardato meno posizioni di quante ne aveva '
            "promesse: un ciclo si e' fermato prima");
    expect(celle, greaterThan(12 * 4 * 150));
  });

  /// Monta il velo per [nome] al pezzo [quale], con [gia] celle scostate
  /// nelle discese di prima, e torna il pittore della cenere.
  Future<PittoreDellaCenere> apri(
      WidgetTester tester, GuideAnimal animale, int quale, Set<int> gia) async {
    await tester.pumpWidget(MaterialApp(
      home: SizedBox(
        width: scena.width,
        height: scena.height,
        child: IlVeloCheSiScosta(
          key: ValueKey('${animale.name}$quale${gia.length}'),
          nome: animale.name,
          immagine: animale.fullPath,
          quale: quale,
          giaScoperte: gia,
          quandoCambia: (_) {},
          palette: MaestroPalette.caligo,
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
    return tester
        .widget<CustomPaint>(find.byKey(const Key('viaggio_cenere')))
        .painter! as PittoreDellaCenere;
  }

  testWidgets(
      'REGOLA H NUOVA, SECONDA META: senza aver scostato niente la cenere '
      'resta piena a ogni pezzo, anche al quarto: nessun pezzo cade da solo, '
      'per tutti e dodici', (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final animale in AnimalCatalog.animals) {
      for (var pezzo = 0; pezzo < LaCartaInQuattroPezzi.pezzi; pezzo++) {
        final p = await apri(tester, animale, pezzo, const {});
        // **UN TEMPO INTERO DI ATTESA**: se qualcosa cadesse da solo, questo
        // tempo basterebbe a vederlo caduto.
        await tester.pump(const Duration(seconds: 2));
        final velo = LaCartaInQuattroPezzi(animale.name, pezzo);
        expect(p.quanta, 1,
            reason: '${animale.name} pezzo $pezzo: la cenere non e\' piena, '
                'e nessun pezzo di questa carta dovrebbe mai cadere da solo');
        expect(p.coperte, velo.velato,
            reason: '${animale.name} pezzo $pezzo: senza aver grattato '
                'niente, qualche cella e\' gia\' scoperta');
        expect(find.text('Scosta la cenere con il dito.'), findsOneWidget,
            reason: '${animale.name} pezzo $pezzo: l\'istruzione non e\' '
                'quella del gesto, come se il velo stesse cadendo da solo');
      }
    }
  });
}
