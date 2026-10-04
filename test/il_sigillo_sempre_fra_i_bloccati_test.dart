// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/cerchio/il_tuo_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/la_tendina_del_cerchio.dart';
import 'package:esoteric_circle/features/cerchio/profilo_nel_cerchio_screen.dart';
import 'package:esoteric_circle/features/cerchio/widgets/disegni_del_cerchio.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';
import 'porta_finta_del_cerchio_sociale.dart';

/// **IL SIGILLO SEMPRE FRA I BLOCCATI, ordine FB voce 02.**
///
/// L'elenco delle persone bloccate e' l'unico in cui un errore di persona fa
/// un danno: sbloccare la persona sbagliata riapre la porta a chi si era
/// voluto tenere fuori. Li' il sigillo sta sotto OGNI nome, anche senza
/// nomi uguali. Negli altri elenchi resta la regola dell'ordine FA voce 04:
/// senza nomi uguali, nessun sigillo. La prova guarda le due cose sulle
/// schermate vere, con nomi tutti diversi.
void main() {
  const bloccati = {
    'u-x': ('Velo Nodo Vigile', 'Z9P0'),
    'u-y': ('Brina Lupo Quieto', 'H3TW'),
    'u-z': ('Fiamma Cervo Lento', 'Q8LM'),
  };

  Future<void> monta(WidgetTester tester, Widget schermata) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final finta = _TreBloccati();
    final sociale = IlCerchioSociale(porta: finta);
    await sociale.sincronizza(
        identita: BirthIdentity(birthMoment: DateTime(1990, 5, 12, 10)));
    await sociale.caricaIlCerchio();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
        Provider<AppServices>.value(value: AppServices.offline(null, finta)),
      ],
      child: MaterialApp(
        theme: AppTheme.dark(),
        builder: (c, figlio) => MediaQuery(
          data: MediaQuery.of(c).copyWith(disableAnimations: true),
          child: MaestroScope(neutro: true, child: figlio!),
        ),
        home: schermata,
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  bool siVede(String sigillo) =>
      find.textContaining(sigillo, findRichText: true).evaluate().isNotEmpty;

  testWidgets(
      'FB.02: fra i bloccati il sigillo sta accanto a ogni nome, anche '
      'senza nomi uguali', (tester) async {
    await monta(tester, const ProfiloNelCerchioScreen());
    final visti = <String>[];
    for (final MapEntry(key: uid, value: (nome, sigillo)) in bloccati.entries) {
      await tester.scrollUntilVisible(find.byKey(Key('bloccata_$uid')), 300,
          scrollable: find.byType(Scrollable).first);
      final riga = find.byKey(Key('bloccata_$uid'));
      final accanto = find.descendant(
          of: riga, matching: find.byKey(Key('sigillo_accanto_a_$nome')));
      final testo = find.descendant(
          of: riga, matching: find.textContaining(sigillo, findRichText: true));
      if (accanto.evaluate().isEmpty || testo.evaluate().isEmpty) continue;
      // **NELL'ALBERO NON BASTA: il sigillo si deve VEDERE.** La prima
      // stesura passava col sigillo nell'albero e tagliato a video dai
      // puntini del nome. Si misura il paragrafo che lo disegna: intero
      // (largo quanto il suo testo, nessuna riga oltre il massimo), dentro
      // la riga e prima di "Sblocca".
      final paragrafo = tester.renderObject<RenderParagraph>(find
          .descendant(
              of: riga,
              matching: find.byWidgetPredicate((w) =>
                  w is RichText && w.text.toPlainText().contains(sigillo)))
          .first);
      final intero = paragrafo.getMaxIntrinsicWidth(double.infinity);
      final dove = tester.getRect(testo.first);
      final sblocca = tester.getRect(find.byKey(Key('sblocca_$uid')));
      final rigaRect = tester.getRect(riga);
      // E il nome si legge intero: senza nome il sigillo non basta.
      final delNome = tester.renderObject<RenderParagraph>(find
          .descendant(
              of: riga,
              matching: find.byWidgetPredicate(
                  (w) => w is RichText && w.text.toPlainText() == nome))
          .first);
      final siVedeIntero = !paragrafo.didExceedMaxLines &&
          !delNome.didExceedMaxLines &&
          paragrafo.size.width + 0.5 >= intero &&
          !paragrafo.debugHasOverflowShader &&
          dove.left >= rigaRect.left &&
          dove.right <= sblocca.left;
      print(
          'FB.02 IL SIGILLO $sigillo: largo ${paragrafo.size.width.toStringAsFixed(1)} '
          'su ${intero.toStringAsFixed(1)}, finisce a ${dove.right.toStringAsFixed(1)}, '
          '"Sblocca" comincia a ${sblocca.left.toStringAsFixed(1)}; il nome '
          '${delNome.didExceedMaxLines ? "tagliato" : "intero"}');
      if (siVedeIntero) visti.add(sigillo);
    }
    print('FB.02 FRA I BLOCCATI: righe ${bloccati.length}, col sigillo '
        '${visti.length} $visti');
    cardinaleMinimo(visti.length, bloccati.length,
        cosa: 'righe dei bloccati col sigillo',
        perche: 'Tre persone bloccate dai nomi tutti diversi: il sigillo deve '
            'stare su tutte e tre.');
    expect(visti, [for (final v in bloccati.values) v.$2]);
  });

  testWidgets(
      'FB.02: due nomi uguali in una riga stretta, il sigillo resta intero '
      '(il difetto dell\'ordine FA voce 04)', (tester) async {
    // Con l'ordine FA nome e sigillo stavano in un solo testo coi puntini in
    // coda: in una riga stretta i puntini mangiavano il sigillo, e le prove
    // FA.04 passavano perche' guardavano l'albero, non i pixel.
    const nome = 'Fiamma Cervo Lento del Mattino';
    final persone = [
      const PersonaDelCerchio(
          uid: 'a', nome: nome, icona: 'segno:0', sigillo: 'R7KQ'),
      PersonaDelCerchio(
          uid: 'b',
          nome: nome.toLowerCase(),
          icona: 'segno:0',
          sigillo: 'M4XR'),
    ];
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: ElencoDelCerchio(
          persone: persone,
          child: Column(children: [
            for (final p in persone)
              SizedBox(
                width: 160,
                child: NomeDellaPersona(
                    nome: p.nome,
                    sigillo: p.sigillo,
                    stile: const TextStyle(fontSize: 18)),
              ),
          ]),
        ),
      ),
    ));
    final interi = <String>[];
    for (final s in ['R7KQ', 'M4XR']) {
      final paragrafo = tester.renderObject<RenderParagraph>(find
          .byWidgetPredicate(
              (w) => w is RichText && w.text.toPlainText().contains(s))
          .first);
      final largo = paragrafo.getMaxIntrinsicWidth(double.infinity);
      print('FB.02 OMONIMI NELLA RIGA STRETTA: $s largo '
          '${paragrafo.size.width.toStringAsFixed(1)} su '
          '${largo.toStringAsFixed(1)}, oltre il massimo '
          '${paragrafo.didExceedMaxLines}');
      if (!paragrafo.didExceedMaxLines && paragrafo.size.width + 0.5 >= largo) {
        interi.add(s);
      }
    }
    expect(interi, ['R7KQ', 'M4XR']);
  });

  testWidgets(
      'FB.02: negli altri elenchi, senza nomi uguali, nessun sigillo (la '
      'regola FA.04 resta)', (tester) async {
    // Il tuo Cerchio: un amico, chi ti cerca, chi hai cercato, tutti diversi.
    await monta(tester, const IlTuoCerchioScreen());
    final nelCerchio = [
      for (final s in ['M4XR', 'R7KQ', 'P2DV'])
        if (siVede(s)) s,
    ];
    // La tendina: l'amico presente e i due simili, tutti diversi.
    await monta(
        tester,
        Builder(
            builder: (c) => Scaffold(
                body: Center(
                    child: TextButton(
                        onPressed: () => apriLaTendinaDelCerchio(c),
                        child: const Text('apri'))))));
    await tester.tap(find.text('apri'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('la_tendina_del_cerchio')), findsOneWidget);
    final nellaTendina = [
      for (final s in ['M4XR', 'S1AB', 'S2CD'])
        if (siVede(s)) s,
    ];
    final chiavi = find
        .byWidgetPredicate((w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('sigillo_accanto_a_'))
        .evaluate()
        .length;
    print('FB.02 NEGLI ALTRI ELENCHI: sigilli nel tuo Cerchio $nelCerchio, '
        'nella tendina $nellaTendina, righe col sigillo nella tendina $chiavi');
    expect(nelCerchio, isEmpty);
    expect(nellaTendina, isEmpty);
    expect(chiavi, 0);
  });
}

/// La porta finta con tre persone bloccate dai nomi diversi, e negli altri
/// elenchi persone coi sigilli noti e nessun nome uguale.
class _TreBloccati extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    final e = await super.sociale(porta, corpo);
    if (e == null) return e;
    if (porta == 'ilMioCerchio') {
      return EsitoSociale(dati: {
        ...e.dati,
        'amici': [PortaFintaDelCerchioSociale.amico],
        'ricevuti': [
          {
            'uid': 'u-corvo',
            'nome': 'Eco Corvo Mite',
            'icona': 'animale:3',
            'sigillo': 'R7KQ',
            'semaforo': 'arancionePieno',
          },
        ],
        'inviati': [
          {
            'uid': 'u-falco',
            'nome': 'Ala Falco Chiaro',
            'icona': 'animale:2',
            'sigillo': 'P2DV',
            'semaforo': 'arancioneChiaro',
          },
        ],
        'bloccati': [
          for (final b in const {
            'u-x': ('Velo Nodo Vigile', 'Z9P0'),
            'u-y': ('Brina Lupo Quieto', 'H3TW'),
            'u-z': ('Fiamma Cervo Lento', 'Q8LM'),
          }.entries)
            {'uid': b.key, 'nome': b.value.$1, 'sigillo': b.value.$2},
        ],
      });
    }
    if (porta == 'laTendinaDelCerchio') {
      final somiglianti = (e.dati['somiglianti'] as List).cast<Map>();
      return EsitoSociale(dati: {
        ...e.dati,
        'amiciPresenti': [
          {...PortaFintaDelCerchioSociale.amico, 'arte': 'tarocchi'},
        ],
        'somiglianti': [
          {...somiglianti[0], 'sigillo': 'S1AB'},
          {...somiglianti[1], 'sigillo': 'S2CD'},
        ],
      });
    }
    return e;
  }
}
