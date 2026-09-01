import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/design_system/tokens/spacing_tokens.dart';
import 'package:esoteric_circle/features/shell/spazio_della_barra.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL VUOTO SOTTO I TRE MAESTRI IN HOME. Ordine S voce 10.
///
/// **Aperto dai primi di agosto e mai ordinato.** Fra la riga delle arti del
/// Maestro e il titolo "Le tue arti" restava una fascia vuota di circa duecento
/// punti.
///
/// **PERCHE' NESSUNA MISURA LO AVEVA VISTO.** Il censimento degli spazi conta i
/// vuoti SCRITTI, cioe' i `SizedBox` che qualcuno ha messo nel codice: questo
/// vuoto non era scritto da nessuno, nasceva dalla somma di tre cose ognuna delle
/// quali era giusta da sola. Un vuoto che nessuno ha scritto si vede solo
/// misurando la RESA, ed e' quello che questa prova fa.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  /// L'app vera, alla misura vera del telefono di Mauro.
  Future<void> monta(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  Finder ilCorpo() => find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down);

  testWidgets(
      'fra la riga delle arti e "Le tue arti" non resta una fascia vuota',
      (tester) async {
    await monta(tester);

    // **SI MISURA SULLA RESA, e i due estremi si prendono dai loro riquadri.**
    // Il vuoto e' la distanza fra il FONDO della riga delle arti del Maestro e la
    // CIMA del titolo dello scaffale personale. Nessuno dei due numeri sta nel
    // sorgente: nascono dalla disposizione.
    final righeDelleArti =
        find.byKey(const Key('santuario_domain_arts'), skipOffstage: false);
    expect(righeDelleArti, findsWidgets,
        reason: 'la riga delle arti del Maestro non c\'e\': la prova non ha un '
            'estremo da cui misurare');
    // Il carosello monta i tre Maestri: quella che conta e' la riga del
    // CENTRALE, cioe' quella visibile a schermo.
    final rigaDelleArti = tester
        .renderObjectList<RenderBox>(righeDelleArti)
        .map((s) => s.localToGlobal(Offset.zero) & s.size)
        .reduce((a, b) => a.width >= b.width ? a : b);

    final titolo =
        find.byKey(const Key('tue_arti_titolo'), skipOffstage: false);
    expect(titolo, findsOneWidget);
    final scatolaTitolo = tester.renderObject<RenderBox>(titolo);
    final rettangoloTitolo =
        scatolaTitolo.localToGlobal(Offset.zero) & scatolaTitolo.size;

    final vuoto = rettangoloTitolo.top - rigaDelleArti.bottom;
    debugPrint('VUOTO SOTTO I MAESTRI: ${vuoto.toStringAsFixed(1)} punti '
        '(arti fino a ${rigaDelleArti.bottom.toStringAsFixed(1)}, titolo da '
        '${rettangoloTitolo.top.toStringAsFixed(1)})');

    // **LA SOGLIA E' DERIVATA, non scelta a occhio.** Sotto la riga delle arti
    // ci vuole l'aria della barra, perche' a riposo la barra sta li' e il
    // contenuto non deve nascerci sotto: quella misura la dichiara
    // `SpazioDellaBarraNelloScroll`, e vale circa novanta punti. Piu' di quella,
    // piu' un distacco di sezione, e' vuoto che nessuno ha voluto.
    //
    // Il valore si legge dalla resa e non si riscrive: si prende la stessa
    // funzione che il Santuario usa.
    // **NON SI SOMMA LA BARRA DUE VOLTE, e la prima stesura lo faceva.**
    // `SpazioDellaBarraNelloScroll.quanto` restituisce GIA' la misura piena
    // quando la barra e' visibile, perche' la barra inietta la propria altezza
    // nel padding: aggiungerle a mano l'altezza della barra portava la soglia a
    // 178 punti, e il vuoto di 176 passava. Una soglia che cresce col difetto non
    // giudica niente, ed e' lo stesso inganno del velo nella voce S.09.
    final ariaDellaBarra = SpazioDellaBarraNelloScroll.quanto(
        tester.element(find.byKey(const Key('tue_arti_titolo'))));
    final massimo = ariaDellaBarra + SpacingTokens.xl;
    expect(vuoto, lessThan(massimo),
        reason: 'fra la riga delle arti e "Le tue arti" restano '
            '${vuoto.toStringAsFixed(1)} punti vuoti, e il massimo che ha una '
            'ragione e\' ${massimo.toStringAsFixed(1)}: e\' la fascia morta '
            'aperta dai primi di agosto');
    expect(vuoto, greaterThan(0),
        reason: 'il titolo dello scaffale finisce SOPRA la riga delle arti: '
            'qualcosa si e\' sovrapposto');
  });

  // **LA BARRA NON E' LA FONTE DEL VUOTO, e la misura lo ha detto.** Qui c'era
  // una prova che confrontava l'altezza riservata dalla barra con la sua resa:
  // riserva 134 punti e ne occupa 136, quindi non avanza niente, e il contenuto
  // le finisce sotto di due punti. Quel confronto **esiste gia'**, in
  // `una_barra_sola_test`, con una tolleranza dichiarata di due punti: scriverne
  // un secondo con una tolleranza mia sarebbe stata la seconda porta sulla stessa
  // misura, cioe' due verita' sullo stesso numero. La prova si e' tolta, il fatto
  // resta scritto qui.

  testWidgets('lo scaffale si raggiunge scorrendo, e non e\' coperto',
      (tester) async {
    // Il vuoto si chiude senza portarsi via cio' che serve: lo scaffale resta
    // raggiungibile e leggibile, non incastrato sotto la barra.
    await monta(tester);
    // **SI SCORRE FINCHE' IL TITOLO E' A SCHERMO, e non a passi fissi.** Sei
    // trascinate da quattrocento punti lo portavano SOPRA il bordo alto, a meno
    // 357, e la prova accusava la schermata di averlo perso quando era solo
    // passato oltre.
    final titolo = find.byKey(const Key('tue_arti_titolo'));
    var cima = double.nan;
    for (var i = 0; i < 12; i++) {
      final scatola = tester.renderObject<RenderBox>(titolo);
      cima = scatola.localToGlobal(Offset.zero).dy;
      if (cima > 0 && cima < 400) break;
      await tester.drag(ilCorpo().first, const Offset(0, -120));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 400));
    expect(cima > 0 && cima < 400, isTrue,
        reason: 'scorrendo, il titolo dello scaffale non si fermava mai in una '
            'posizione leggibile: si e\' fermato a $cima');
  });
}
