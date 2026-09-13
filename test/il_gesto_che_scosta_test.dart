import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/dove_sta_la_testa.dart';
import 'package:esoteric_circle/core/viaggio/il_velo_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/le_sagome_in_celle.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_velo_che_si_scosta.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:esoteric_circle/services/ai/registro_dei_guasti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;
import 'sorgenti_di_lib.dart';

/// **IL GESTO CHE SCOSTA, AL POSTO DELLA LENTE.** Ordine DI voce 10,
/// 13 settembre 2026.
///
/// **La misura dell'ordine:** *"la lente scopre fasce orizzontali larghe tutta
/// l'immagine [...] Il bordo netto orizzontale taglia zampe e coda, e si
/// vede."* E il da fare: la maschera non e' piu' geometrica, il bordo lo
/// disegna la mano, un quarto dell'area del corpo per discesa, la testa mai
/// prima della quarta, cio' che si e' scostato resta scostato e si ritrova.
///
/// La testa ha la sua guardia, `la_testa_non_si_vede_prima_della_quarta`; i
/// pixel la loro, `il_velo_c_e_davvero_sul_telefono`. Qui il gesto.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const scena = Size(390, 844);

  Future<void> monta(WidgetTester tester, GuideAnimal animale, int quale,
      Set<int> gia, void Function(Set<int>) quandoCambia) async {
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
          quandoCambia: quandoCambia,
          palette: MaestroPalette.caligo,
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));
  }

  /// **UN DITO CHE PASSA OVUNQUE**: riga per riga a zig zag su tutta
  /// l'illustrazione, e oltre i bordi fin dove c'e' schermo.
  Future<void> passaOvunque(WidgetTester tester, GuideAnimal animale) async {
    final velo = IlVeloDellAnimale(animale.name);
    final r = IlVeloCheSiScosta.doveStaLIllustrazione(
        scena, LeSagome.misure[animale.name]!);
    final sinistra = (r.left - 10).clamp(1.0, scena.width - 1);
    final destra = (r.right + 10).clamp(1.0, scena.width - 1);
    final g = await tester.startGesture(Offset(sinistra, r.top));
    for (var riga = 0; riga <= velo.righe; riga++) {
      final y = r.top + r.height * riga / velo.righe;
      final xs = riga.isEven ? [sinistra, destra] : [destra, sinistra];
      for (final x in xs) {
        await g.moveTo(Offset(x, y));
      }
    }
    await g.up();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets(
      'OGNI DISCESA SCOSTA ESATTAMENTE UN QUARTO DEL CORPO, poi il dito non '
      'scopre piu, e la testa resta, per tutti e dodici', (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    expect(AnimalCatalog.animals.length, 12);

    final righe = <String>[];
    for (final animale in AnimalCatalog.animals) {
      final velo = IlVeloDellAnimale(animale.name);
      expect(velo.perDiscesa, (velo.corpo.length / 4).ceil(),
          reason: 'la quantita\' per discesa non e\' un quarto del corpo');
      var gia = <int>{};
      final perDiscesa = <int>[];
      for (var quale = 0;
          quale < IlVeloDellAnimale.discesePrimaDellaTesta;
          quale++) {
        Set<int>? ultime;
        await monta(tester, animale, quale, gia, (c) => ultime = c);
        await passaOvunque(tester, animale);
        // **E UN SECONDO PASSAGGIO, che non deve scoprire piu' niente.**
        await passaOvunque(tester, animale);
        expect(ultime, isNotNull,
            reason: '${animale.name}: il gesto finito non consegna le celle');
        final nuove = ultime!.difference(gia);
        final restavano = velo.scostabile.difference(gia).length;
        final attese =
            restavano < velo.perDiscesa ? restavano : velo.perDiscesa;
        expect(nuove.length, attese,
            reason: '${animale.name} alla discesa ${quale + 1}: scostate '
                '${nuove.length} celle, l\'ordine ne concede $attese');
        expect(nuove.intersection(velo.testa), isEmpty,
            reason: '${animale.name}: il dito ha scostato la testa');
        expect(ultime!.containsAll(gia), isTrue,
            reason: '${animale.name}: cio\' che era scostato ieri oggi e\' '
                'di nuovo coperto');
        expect(
            find.text(attese < velo.perDiscesa ||
                    ultime!.containsAll(velo.scostabile)
                ? 'Resta velato soltanto il volto.'
                : 'Per oggi hai scostato abbastanza.'),
            findsOneWidget);
        perDiscesa.add(nuove.length);
        gia = ultime!;
      }
      righe.add('${animale.name} ${perDiscesa.join('+')} su '
          '${velo.corpo.length}, testa ${velo.testa.length}');
    }
    // ignore: avoid_print
    print('ORDINE DI VOCE 10, LA QUANTITA\': ${righe.join('; ')}');
  });

  testWidgets(
      'IL BORDO LO DISEGNA LA MANO: un tratto verticale scopre soltanto '
      'attorno al dito, e nessuna fascia', (tester) async {
    await tester.binding.setSurfaceSize(scena);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    var controllati = 0;
    for (final animale in AnimalCatalog.animals) {
      final velo = IlVeloDellAnimale(animale.name);
      final r = IlVeloCheSiScosta.doveStaLIllustrazione(
          scena, LeSagome.misure[animale.name]!);
      Set<int>? ultime;
      await monta(tester, animale, 0, {}, (c) => ultime = c);
      // Il tratto: dall'alto in basso, nella colonna del corpo piu' piena
      // fuori dalla testa.
      final perColonna = List.filled(velo.colonne, 0);
      for (final i in velo.scostabile) {
        perColonna[i % velo.colonne]++;
      }
      final colonna = perColonna.indexOf(perColonna.reduce((a, b) => a > b ? a : b));
      final x = r.left + r.width * (colonna + 0.5) / velo.colonne;
      await tester.dragFrom(Offset(x, r.top + 2), Offset(0, r.height - 4));
      await tester.pump(const Duration(milliseconds: 50));
      expect(ultime, isNotEmpty,
          reason: '${animale.name}: il tratto non ha scostato niente');
      final righeToccate = <int>{};
      for (final i in ultime!) {
        controllati++;
        righeToccate.add(i ~/ velo.colonne);
        final dx = (i % velo.colonne + 0.5) - (colonna + 0.5);
        expect(dx.abs(), lessThanOrEqualTo(IlVeloCheSiScosta.raggioDellaMano),
            reason: '${animale.name}: la cella $i sta a ${dx.abs()} colonne '
                'dal dito. Il velo si apre dove il dito non e\' passato: '
                'e\' una fascia, non una mano');
      }
      expect(righeToccate.length, greaterThanOrEqualTo(6),
          reason: '${animale.name}: il tratto verticale ha scostato solo '
              '${righeToccate.length} righe');
    }
    expect(controllati, greaterThan(12 * 20));
  });

  test(
      'LA CENERE COPRE OGNI CELLA COPERTA PER INTERO: il pezzo di ogni cella la '
      'contiene coi suoi angoli, e il tracciato contiene il pezzo, per tutti e '
      'dodici e a tre misure', () {
    var celle = 0;
    var nelTracciato = 0;
    for (final animale in AnimalCatalog.animals) {
      final velo = IlVeloDellAnimale(animale.name);
      for (final telefono in const [
        Size(320, 568),
        Size(390, 844),
        Size(1080, 2400),
      ]) {
        final r = IlVeloCheSiScosta.doveStaLIllustrazione(
            telefono, LeSagome.misure[animale.name]!);
        for (final i in velo.velato) {
          celle++;
          final pezzo = PittoreDellaCenere.pezzo(velo, i, r.size);
          final c = velo.cella(i);
          final inPunti = Rect.fromLTRB(c.left * r.width, c.top * r.height,
              c.right * r.width, c.bottom * r.height);
          for (final angolo in [inPunti.topLeft, inPunti.topRight,
              inPunti.bottomLeft, inPunti.bottomRight]) {
            expect(pezzo.contains(angolo), isTrue,
                reason: '${animale.name} a $telefono: l\'angolo $angolo della '
                    'cella $i resta fuori dal suo pezzo di cenere, e fra due '
                    'celle vicine resta un filo di manto');
          }
        }
        // **E IL TRACCIATO CONTIENE DAVVERO I PEZZI**: un campione di celle,
        // perche' il tracciato intero ha migliaia di figure.
        final forma =
            PittoreDellaCenere.forma(velo, velo.velato, r.size);
        for (final i in velo.velato.where((i) => i % 17 == 0)) {
          nelTracciato++;
          final c = PittoreDellaCenere.pezzo(velo, i, r.size).deflate(0.7);
          for (final p in [c.center, c.topLeft, c.bottomRight]) {
            expect(forma.contains(p), isTrue,
                reason: '${animale.name}: il tracciato della cenere non '
                    'contiene la cella $i');
          }
        }
      }
    }
    expect(celle, greaterThan(12 * 3 * 500));
    expect(nelTracciato, greaterThan(12 * 3 * 25));
  });

  /// **LA CENERE NON DISEGNA LA TESTA.** Trovato guardando le catture, il
  /// 13 settembre 2026: con la testa coperta dalle sole celle della sua
  /// sagoma, alla prima discesa il Cervo aveva **due palchi di cenere**, e il
  /// nome si leggeva tre discese prima. Il cumulo deve coprire tutto il
  /// rettangolo tabulato, vuoto compreso: si prova su una griglia di punti
  /// fitta, ventuno per ventuno, dentro il rettangolo di ogni animale.
  test(
      'IL CUMULO COPRE TUTTO IL RETTANGOLO DELLA TESTA, vuoto compreso, e non '
      'la sua forma, per tutti e dodici', () {
    var punti = 0;
    for (final animale in AnimalCatalog.animals) {
      final velo = IlVeloDellAnimale(animale.name);
      final r = IlVeloCheSiScosta.doveStaLIllustrazione(
          scena, LeSagome.misure[animale.name]!);
      final forma = PittoreDellaCenere.forma(velo, velo.velato, r.size);
      final t = DoveStaLaTesta.di(animale.name)!;
      final scoperti = <Offset>[];
      for (var ix = 0; ix <= 20; ix++) {
        for (var iy = 0; iy <= 20; iy++) {
          final p = Offset((t.left + t.width * ix / 20) * r.width,
              (t.top + t.height * iy / 20) * r.height);
          punti++;
          if (!forma.contains(p)) scoperti.add(p);
        }
      }
      expect(scoperti, isEmpty,
          reason: '${animale.name}: ${scoperti.length} punti del rettangolo '
              'della testa restano senza cenere alla prima discesa. Se la '
              'cenere segue la sagoma della testa, la sagoma dice il nome.');
    }
    expect(punti, 12 * 21 * 21);
  });

  test(
      'IL GESTO NON SI CHIAMA GRATTA E VINCI in nessun punto del codice e '
      'dell\'interfaccia', () {
    // La parola si compone qui, o questa prova la conterrebbe.
    final vietate = RegExp('grat${'ta'}\\s+e\\s+vinci|scratch', caseSensitive: false);
    // **DALLA PORTA COMUNE**, che porta con se' il suo cardinale minimo.
    final file = sorgentiDiLib();
    final colpevoli = [
      for (final f in file)
        if (vietate.hasMatch(f.readAsStringSync())) f.path,
    ];
    expect(colpevoli, isEmpty,
        reason: 'l\'ordine DI voce 10: il gesto non si chiama cosi\' in '
            'nessun punto dell\'interfaccia ne\' del codice');
  });

  test(
      'CIO CHE SI E SCOSTATO SI RITROVA RIAPRENDO, ed e dell animale che lo '
      'ha, non di un altro', () async {
    final prima = DiarioDeiViaggi();
    await prima.carica();
    await prima.segnaCelleScoperte('Lupo', {3, 41, 402});
    final dopo = DiarioDeiViaggi();
    await dopo.carica();
    expect(dopo.celleScoperteDi('Lupo'), {3, 41, 402});
    expect(dopo.celleScoperteDi('Aquila'), isEmpty,
        reason: 'la cenere scostata sul Lupo compare scostata su un altro');
    await dopo.ricomincia();
    final daCapo = DiarioDeiViaggi();
    await daCapo.carica();
    expect(daCapo.celleScoperteDi('Lupo'), isEmpty);
  });

  testWidgets(
      'LA SCHERMATA DEL VIAGGIO PASSA AL VELO LE CELLE DEL DIARIO, e ci '
      'conserva quelle nuove', (tester) async {
    tester.view.physicalSize = scena;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelloSciamanoDiProva(1);
    await diario.segnaCelleScoperte('Lupo', {580, 581, 582});
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider.value(value: RegistroDeiGuasti()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.cancer,
            now: DateTime(2026, 9, 13, 12),
            diario: diario,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Una scelta da fare'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
    await tester.pump(const Duration(seconds: 1));
    final nebbia = find.byKey(const Key('viaggio_nebbia'));
    for (var i = 0; i < 80 && nebbia.evaluate().isNotEmpty; i++) {
      await tester.drag(nebbia, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('viaggio_ombra_Lupo')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final velo = tester.widget<IlVeloCheSiScosta>(
        find.byKey(const Key('viaggio_lente_Lupo')));
    expect(velo.giaScoperte, {580, 581, 582},
        reason: 'la schermata non passa al velo cio\' che si era scostato');
    expect(velo.quale, 1);
    // **LA FRASE DELL'INGRESSO AL VELO**, ordine DJ voce 04: dice il gesto e
    // la materia, e non spiega niente di superfluo.
    expect(find.text('Scosta la cenere con il dito.'), findsOneWidget,
        reason: 'la frase che accoglie al velo non e\' quella del fondatore');

    // Un tratto orizzontale a tre quinti dell'illustrazione: sul Lupo e' il
    // ventre, fuori dalla testa.
    final animale = tester.getRect(find.byKey(const Key('viaggio_animale_vero')));
    await tester.dragFrom(
        Offset(animale.left + animale.width * 0.3,
            animale.top + animale.height * 0.6),
        Offset(animale.width * 0.5, 0));
    await tester.pump(const Duration(milliseconds: 100));
    expect(diario.celleScoperteDi('Lupo').length, greaterThan(3),
        reason: 'il gesto finito non arriva al Diario');
    expect(diario.celleScoperteDi('Lupo').containsAll({580, 581, 582}),
        isTrue);
  });
}
