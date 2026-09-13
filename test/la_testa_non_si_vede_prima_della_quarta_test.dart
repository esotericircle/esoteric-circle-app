import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/dove_sta_la_testa.dart';
import 'package:esoteric_circle/core/viaggio/il_velo_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/le_sagome_in_celle.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';

/// **LA GUARDIA DELLA TESTA, sotto la Regola H.** Nata con l'ordine DE voce
/// 03 per la lente, riscritta con l'ordine DI voce 10 per il velo che si
/// scosta, 13 settembre 2026.
///
/// *"La regione della testa, gia' tabulata per i dodici animali, e' protetta
/// fino alla quarta discesa e non si scosta: alla quarta il velo cade da solo,
/// come oggi."*
///
/// **LE DUE META', e la seconda e' quella che fa di questa una guardia.** La
/// prima dimostra che la testa resta coperta. Da sola sarebbe verde anche se
/// il velo non si scostasse mai, e un velo che non si scosta non e' un gesto.
/// La seconda dimostra che **alla quarta il velo cade davvero**, e che prima
/// della quarta **tutto il resto si puo' scostare**.
///
/// **Qui si guarda la regola, cella per cella**; i pixel dipinti li guarda
/// `il_velo_c_e_davvero_sul_telefono_test`, perche' una regola giusta dipinta
/// male e' gia' successa una volta, con la lente sul 767f596c.
void main() {
  /// **QUANTE POSIZIONI DEL DITO SI PROVANO PER OGNI ANIMALE.**
  ///
  /// Quarantuno per quarantuno, e **fuori dai bordi**: da meno mezzo a uno e
  /// mezzo, cosi' la prova include il dito che spinge oltre il confine.
  const quanti = 41;
  const da = -0.5;
  const a = 1.5;

  const scena = Size(390, 844);

  test('REGOLA H, PRIMA META: nessuna cella che si puo scostare tocca il '
      'rettangolo della testa, e la mano non ci arriva da nessun punto, per '
      'tutti e dodici', () {
    // **IL CARDINALE MINIMO, che questa guardia dichiara.** Dodici animali nel
    // catalogo, dodici righe nel file delle teste, dodici sagome: se un giorno
    // ne arrivasse un tredicesimo senza la sua riga, il velo non saprebbe
    // quale parte proteggere, e questa prova cade col numero in mano.
    expect(DoveStaLaTesta.nomi.length, AnimalCatalog.animals.length,
        reason: 'il file delle teste e il catalogo non hanno lo stesso numero '
            'di animali: uno dei due ha una riga che l\'altro non ha');
    expect(DoveStaLaTesta.nomi.length, 12);
    expect(LeSagome.griglie.length, 12);
    expect(LeSagome.misure.length, 12);

    var provate = 0;
    var celle = 0;
    for (final animale in AnimalCatalog.animals) {
      final velo = IlVeloDellAnimale(animale.name);
      final t = DoveStaLaTesta.di(animale.name);
      expect(t, isNotNull,
          reason: '${animale.name} non ha il rettangolo della testa');
      expect(velo.corpo.length, greaterThan(300),
          reason: '${animale.name} ha una sagoma di ${velo.corpo.length} '
              'celle: la griglia non e\' stata letta');
      expect(velo.testa, isNotEmpty,
          reason: '${animale.name}: nessuna cella di testa, e allora la testa '
              'si scosterebbe alla prima discesa');
      const m = DoveStaLaTesta.margineDiSicurezza;
      final testa =
          Rect.fromLTRB(t!.left - m, t.top - m, t.right + m, t.bottom + m);

      // **NESSUNA CELLA SCOSTABILE HA UN PUNTO IN COMUNE COL RETTANGOLO.** Una
      // cella scostata mostra tutti i suoi pixel: se entrasse nella testa
      // anche di un filo, quel filo si vedrebbe prima della quarta.
      for (final i in velo.scostabile) {
        celle++;
        expect(testa.overlaps(velo.cella(i)), isFalse,
            reason: '${animale.name}: la cella $i si puo\' scostare e tocca '
                'il rettangolo della testa ${velo.cella(i)}');
      }

      // **E LA MANO NON LA RAGGIUNGE DA NESSUN PUNTO**, nemmeno spingendo
      // oltre i bordi dell'illustrazione.
      for (var ix = 0; ix < quanti; ix++) {
        for (var iy = 0; iy < quanti; iy++) {
          final dito = Offset(da + (a - da) * ix / (quanti - 1),
              da + (a - da) * iy / (quanti - 1));
          provate++;
          for (final i
              in velo.vicine(dito, IlVeloCheSiScosta.raggioDellaMano)) {
            expect(velo.testa.contains(i), isFalse,
                reason: '${animale.name}: il dito in $dito scosta la cella $i, '
                    'che e\' testa');
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DI VOCE 10, LA TESTA: $celle celle scostabili guardate, '
        '$provate posizioni del dito, nessuna tocca la testa');
    expect(provate, 12 * quanti * quanti,
        reason: 'la prova ha guardato meno posizioni di quante ne aveva '
            "promesse: un ciclo si e' fermato prima");
    expect(celle, greaterThan(12 * 300));
  });

  /// Monta il velo per [nome] alla discesa [quale], con [gia] celle scostate
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
      'REGOLA H, SECONDA META: prima della quarta, scostato tutto il possibile, '
      'resta coperta esattamente la testa; alla quarta il velo cade da solo, '
      'per tutti e dodici', (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final animale in AnimalCatalog.animals) {
      final velo = IlVeloDellAnimale(animale.name);
      for (var quale = 0;
          quale < IlVeloDellAnimale.discesePrimaDellaTesta;
          quale++) {
        final p = await apri(tester, animale, quale, velo.scostabile);
        expect(p.quanta, 1,
            reason: '${animale.name}: alla discesa ${quale + 1} il velo sta '
                'cadendo, e la testa si vedrebbe prima della quarta');
        expect(p.coperte, velo.testa,
            reason: '${animale.name}: alla discesa ${quale + 1}, scostato '
                'tutto il possibile, la cenere non sta esattamente sulla '
                'testa: o scopre un pezzo di testa, o copre un pezzo che si '
                'era scostato');
        expect(find.text('Resta velato soltanto il volto.'), findsOneWidget);
      }

      // **ALLA QUARTA CADE DA SOLO**, anche senza nessuna cella scostata.
      await apri(tester, animale, IlVeloDellAnimale.discesePrimaDellaTesta, {});
      await tester.pump(IlVeloCheSiScosta.quantoDuraLaCaduta);
      await tester.pump(IlVeloCheSiScosta.vitaDellaParticella);
      final dopo = tester
          .widget<CustomPaint>(find.byKey(const Key('viaggio_cenere')))
          .painter! as PittoreDellaCenere;
      expect(dopo.coperte.isEmpty || dopo.quanta == 0, isTrue,
          reason: '${animale.name}: alla quarta discesa il velo non cade, e '
              'la testa non si vede mai');
      expect(find.text('Oggi il velo cade da solo.'), findsOneWidget);
    }
  });
}
