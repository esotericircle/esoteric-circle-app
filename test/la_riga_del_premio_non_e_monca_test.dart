import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/bonus_della_condivisione.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// **LA RIGA DEL PREMIO NON E' MONCA SENZA RETE.** Ordine GA voce 11, 20
/// ottobre 2026, difetto 13 della ricognizione.
///
/// Visto nella simulazione FZ (`docs/collaudo/FZ/simulazioni/
/// note_di_percorso.md`, osservazione non curata, `e2_d4_risalita.png`):
/// senza rete il server non ha mai detto quanto vale l'invito, e sotto
/// "Invita qualcuno nel Cerchio" si leggeva *"Quando il tuo amico entra nel
/// Cerchio. In attesa."*, una frase senza soggetto: quando succede che
/// cosa? Lo stesso per le altre due vie, *"A condivisione avvenuta."*.
///
/// Padre (Regola C): ordine BX, che senza il numero ha fatto cominciare la
/// riga dalla frase del modo per non cominciare da "Eos".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
      'senza il numero del server ogni riga dice che cosa arriva e quando',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    // Il borsellino c'e', ma il server non ha mai risposto: il listino della
    // condivisione e' vuoto, come senza rete.
    final borsellino = QuestionAllowance();
    final grande = Sentieri.grandiDi(Sentiero.costellazione).first;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsellino),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: CelebrazioneAScermoPieno(
          traguardi: [grande],
          sentieri: const [Sentiero.costellazione],
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 600));

    // IL CARDINALE MINIMO (Regola A): le vie sono tre, l'invito, il social
    // e il messaggio privato. Senza vie il ciclo qui sotto non guarderebbe
    // niente e la prova resterebbe verde.
    expect(ModoDellaCondivisione.values.length, greaterThanOrEqualTo(3),
        reason: 'le vie della condivisione sono meno di tre: la prova '
            'guarderebbe meno righe di quelle che la persona legge');
    for (final modo in ModoDellaCondivisione.values) {
      expect(borsellino.eosPerLaCondivisione(modo.motivo), isNull,
          reason: 'la prova deve guardare la riga senza il numero');
      final riga = tester
          .widget<Text>(find.byKey(Key('quando_arriva_${modo.motivo}')))
          .data!;
      // ignore: avoid_print
      print('ORDINE GA VOCE 11: senza rete la via ${modo.motivo} dice "$riga"');
      expect(riga, startsWith('Gli Eos arrivano '),
          reason: 'la riga sotto "${modo.etichetta}" e\' monca, non dice che '
              'cosa arriva: "$riga"');
      expect(riga, contains(modo.quandoArriva));
    }
  });
}
