import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// DALLA FESTA SI ESCE SEMPRE. Ordine AN voce 09.
///
/// **Il difetto, e da dove e' saltato fuori.** La voce 08 ha dato a ogni
/// pulsante della condivisione la frase che dice quando arrivano i suoi Eos:
/// tre frasi in piu' dentro una colonna che era gia' alta quanto lo schermo.
/// Il congedo, che stava in fondo alla colonna, e' finito FUORI: su uno
/// schermo di 797 punti il pulsante "Continua il cammino" cominciava a 877,
/// misurato e non stimato. La festa a schermo pieno diventava una stanza
/// senza porta, e chi ci finiva dentro poteva solo toccare a caso.
///
/// **Come si e' visto, e perche' e' importante dirlo.** Non l'ha visto un
/// occhio: sono cadute due prove che non parlano di feste, quella della
/// bolla dei traguardi e quella del volo degli Eos, perche' i loro tocchi
/// finivano sui pulsanti della condivisione rimasti davanti. Un difetto che
/// si manifesta lontano da dove nasce e' esattamente quello che una suite
/// intera serve a prendere.
///
/// **La cura, e la sua forma.** Il congedo esce dallo scorrimento e si
/// ancora in fondo alla scena: qualunque cosa cresca dentro la festa domani,
/// l'uscita resta dov'e'. Questa prova non guarda il codice, guarda i punti:
/// misura il rettangolo del congedo e pretende che stia dentro lo schermo,
/// su tre schermi diversi, incluso uno basso.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// **LA FESTA SI MONTA SOPRA QUALCOSA, e non come casa.** Il congedo fa
  /// `maybePop`, e una scena che e' la radice del Navigator non ha niente
  /// sotto da cui tornare: montandola come `home` il tocco sarebbe innocuo e
  /// la prova accuserebbe il congedo di un difetto che non ha. Nell'app la
  /// festa arriva sempre spinta sopra la schermata da cui si e' acceso il
  /// traguardo, ed e' quello che si riproduce qui.
  Widget attorno(Widget scena, DiarioDelCammino diario) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MaestroScope(child: child!),
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                body: Builder(
                  builder: (interno) => Center(
                    child: TextButton(
                      key: const Key('prova_apri_la_festa'),
                      onPressed: () => Navigator.of(interno).push(
                          MaterialPageRoute<void>(builder: (_) => scena)),
                      child: const Text('apri'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  // **TRE SCHERMI, e il perche' di ciascuno.** Il primo e' quello su cui il
  // difetto e' comparso, cioe' la misura del telefono di prova. Il secondo e'
  // un telefono basso, dove la festa deve scorrere. Il terzo e' alto, dove
  // non c'e' scusa perche' lo spazio avanza.
  const schermi = <String, Size>{
    'quello della prova': Size(360, 797),
    'basso': Size(360, 600),
    'alto': Size(412, 915),
  };

  for (final schermo in schermi.entries) {
    testWidgets('il congedo resta dentro lo schermo ${schermo.key}',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = schermo.value;
      addTearDown(tester.view.reset);
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      final grande = Sentieri.grandiDi(Sentiero.costellazione).first;
      await tester.pumpWidget(attorno(
        CelebrazioneAScermoPieno(
          traguardi: [grande],
          sentieri: const [Sentiero.costellazione],
          serie: 'terzo giorno di seguito',
        ),
        diario,
      ));
      await tester.pump();
      await tester.tap(find.byKey(const Key('prova_apri_la_festa')));
      for (var passo = 0; passo < 6; passo++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      final congedo = find.byKey(const Key('celebrazione_continua'));
      expect(congedo, findsOneWidget,
          reason: 'la festa non ha un congedo: e\' una stanza senza porta');
      final dove = tester.getRect(congedo);
      // ignore: avoid_print
      print('ORDINE AN VOCE 09: schermo ${schermo.key} '
          '${schermo.value.height.toInt()}, congedo da ${dove.top.toInt()} '
          'a ${dove.bottom.toInt()}');
      expect(dove.bottom, lessThanOrEqualTo(schermo.value.height),
          reason: 'il congedo finisce a ${dove.bottom} su uno schermo alto '
              '${schermo.value.height}: sta fuori, e chi e\' dentro la festa '
              'non ha modo di uscirne');
      expect(dove.top, greaterThanOrEqualTo(0.0),
          reason: 'il congedo e\' scivolato sopra il bordo alto');

      // E IL TOCCO LA CHIUDE DAVVERO, che e' la cosa che conta: un pulsante
      // dentro lo schermo ma coperto da qualcos'altro sarebbe la stessa
      // stanza senza porta con una maniglia dipinta.
      await tester.tap(congedo);
      for (var passo = 0; passo < 12; passo++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.byKey(const Key('celebrazione_nome')), findsNothing,
          reason: 'toccato il congedo, la festa e\' ancora li\'');
    });
  }
}
