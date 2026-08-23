import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/card_del_traguardo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA DATA E L'ORA SULLA CARD DEL TRAGUARDO. Ordine BD voce 06.
///
/// **Richiesta del fondatore del 17 agosto 2026, mai eseguita fino a qui**:
/// "quando il traguardo viene raggiunto, la descrizione viene inserita in un
/// riquadro con breve descrizione, ma vorrei che ci fosse anche una scritta
/// con 'obiettivo raggiunto il [data e ora]'".
///
/// **E il vincolo gia' registrato**: l'istante e' salvato dal diario
/// dall'ordine AP; i Sigilli accesi prima non hanno data, e non se ne inventa
/// una. La card senza data NON mostra la scritta.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sentiero = Sentiero.values.first;
  final traguardo = Sentieri.di(sentiero).first;

  Future<void> monta(WidgetTester tester, DateTime? quando) {
    return tester.pumpWidget(MaterialApp(
      home: MaestroScope(
        maestro: sentiero.maestro,
        child: Scaffold(
          body: CardDelTraguardo(
              traguardo: traguardo, sentiero: sentiero, quando: quando),
        ),
      ),
    ));
  }

  testWidgets('BD.06: col quando, la card dice obiettivo raggiunto il...',
      (tester) async {
    await monta(tester, DateTime(2026, 8, 23, 19, 4));
    final scritta = tester
        .widget<Text>(find.byKey(const Key('card_quando_raggiunto')))
        .data;
    // ignore: avoid_print
    print('ORDINE BD VOCE 06: la card dice "$scritta"');
    expect(scritta, 'Obiettivo raggiunto il 23/08/2026 alle 19:04',
        reason: 'la scritta non porta data e ora nella forma promessa, con '
            'le due cifre fisse');
  });

  testWidgets('BD.06: senza il quando, nessuna data inventata',
      (tester) async {
    await monta(tester, null);
    expect(find.byKey(const Key('card_quando_raggiunto')), findsNothing,
        reason: 'la card mostra una scritta di data per un Sigillo acceso '
            'prima dell\'ordine AP: quella data sarebbe inventata');
    // ignore: avoid_print
    print('ORDINE BD VOCE 06: senza istante nel diario la scritta non c\'e\'');
  });

  test('BD.06: il diario segna l\'istante quando un Sigillo si accende',
      () async {
    // **LA SCRITTA VIVE SOLO SE IL DATO NASCE**: qui si prova che accendere
    // oggi segna il quando, cosi' ogni traguardo futuro avra' la sua data.
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(
        orologio: () => DateTime(2026, 8, 23, 19, 30));
    await diario.carica();
    diario.accendi(traguardo.id);
    final quando = diario.quandoSiEAcceso(traguardo.id);
    // ignore: avoid_print
    print('ORDINE BD VOCE 06: acceso adesso, il diario segna $quando');
    expect(quando, DateTime(2026, 8, 23, 19, 30),
        reason: 'il diario non segna l\'istante dell\'accensione: ogni '
            'traguardo futuro resterebbe senza data');
  });
}
