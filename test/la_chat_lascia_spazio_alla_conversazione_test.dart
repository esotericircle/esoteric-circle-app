import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_empty_state.dart';
import 'package:esoteric_circle/features/ricordi/ricordi_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA CHAT LASCIA SPAZIO ALLA CONVERSAZIONE. Ordine CT, voci da 01 a 06.
///
/// **Il principio che governa tutte queste voci**, parole del fondatore del 4
/// settembre 2026: *"bisogna guadagnare spazio al centro quindi ridurre al
/// massimo le parti occupate sopra e sotto"*. Ogni pretesa qui dentro si
/// giudica su quella.
///
/// **Cio' che si misura sono i rettangoli veri**, presi con `getRect` a
/// schermata montata, non gli stili ne' i numeri scritti nel codice: un
/// componente puo' dichiarare l'altezza che vuole, chi lo stringe decide lo
/// stesso, e questo progetto l'ha gia' pagato col cerchio fantasma della voce
/// CT.02.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzio() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> passo(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> apriLaChat(WidgetTester tester, Maestro maestro) async {
    // **LA FINESTRA E' UN TELEFONO.** Sul default largo e corto la chat non ha
    // la geometria su cui il fondatore ha misurato il difetto.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await passo(tester);
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(maestro);
    await passo(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await passo(tester);
    await passo(tester);
    await tester.ensureVisible(find.text('Consulta ${maestro.displayName}'));
    await tester.pump();
    await tester.tap(find.text('Consulta ${maestro.displayName}'));
    await passo(tester);
  }

  // ------------------------------------------------------------ CT.01
  for (final maestro in Maestro.values) {
    testWidgets(
        'CT.01 Le due righe di ${maestro.id} stanno dentro il cerchietto',
        (tester) async {
      silenzio();
      await apriLaChat(tester, maestro);
      final cerchietto =
          tester.getRect(find.byKey(const Key('chat_cerchietto_del_maestro')));
      final nome =
          tester.getRect(find.byKey(const Key('chat_nome_del_maestro')));
      final arti =
          tester.getRect(find.byKey(const Key('chat_arti_del_maestro')));

      final blocco = arti.bottom - nome.top;
      expect(blocco, lessThanOrEqualTo(cerchietto.height + 0.5),
          reason: 'le due righe misurano ${blocco.toStringAsFixed(1)} punti '
              'contro i ${cerchietto.height.toStringAsFixed(1)} del '
              'cerchietto: il fondatore ha chiesto che occupino ESATTAMENTE '
              'lo spazio del cerchietto, non di piu\'');

      // **IL CERCHIETTO STA A SINISTRA, e le righe accanto.** Prima il volto
      // stava sopra il nome, ed e' per quello che la barra era alta il doppio.
      expect(cerchietto.right, lessThanOrEqualTo(nome.left),
          reason: 'il cerchietto non e\' alla sinistra del nome: finisce a '
              '${cerchietto.right.toStringAsFixed(1)} e il nome comincia a '
              '${nome.left.toStringAsFixed(1)}');
      expect(cerchietto.right, lessThanOrEqualTo(arti.left),
          reason: 'il cerchietto non e\' alla sinistra delle arti');

      // E le due righe sono una sopra l'altra, non affiancate.
      expect(arti.top, greaterThanOrEqualTo(nome.top),
          reason: 'le arti non stanno sotto il nome');
    });
  }

  // ------------------------------------------------------------ CT.03
  testWidgets('CT.03 Il menu\' della barra porta ai giorni prima',
      (tester) async {
    silenzio();
    await apriLaChat(tester, Maestro.medora);
    final menu = find.byKey(const Key('chat_menu_della_barra'));
    expect(menu, findsOneWidget,
        reason: 'l\'icona in alto a destra non e\' un menu\'');

    // **L'ICONA E\' PIU\' GRANDE**, parole del fondatore: "l'icona di nuova
    // conversazione deve essere un pochino piu' grande". Il confronto e' con
    // la misura predefinita di Material, ventiquattro punti.
    final icona = tester.widget<Icon>(
        find.descendant(of: menu, matching: find.byType(Icon)).first);
    expect(icona.size, isNotNull,
        reason: 'l\'icona del menu\' non dichiara nessuna misura, quindi '
            'prende quella predefinita e non e\' piu\' grande di niente');
    expect(icona.size!, greaterThan(24),
        reason: 'l\'icona misura ${icona.size} punti, cioe\' non piu\' della '
            'predefinita di Material');

    await tester.tap(menu);
    // **NIENTE pumpAndSettle:** il cosmo di sfondo anima in continuo, quindi
    // l'albero non si posa mai e l'attesa scade. Si pompa a passi.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final giorni = find.byKey(const Key('chat_i_giorni_prima'));
    expect(giorni, findsOneWidget,
        reason: 'nel menu\' non c\'e\' la voce dei giorni prima: quella riga '
            'e\' sparita dal corpo con la voce CT.04, e se non e\' qui la '
            'funzione non e\' piu\' raggiungibile da nessuna parte');

    await tester.tap(giorni);
    // **NIENTE pumpAndSettle:** il cosmo di sfondo anima in continuo, quindi
    // l'albero non si posa mai e l'attesa scade. Si pompa a passi.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(RicordiScreen), findsOneWidget,
        reason: 'la voce dei giorni prima si tocca e non apre i Ricordi');
  });

  // ------------------------------------------------------- CT.04 e CT.05
  testWidgets('CT.04 e CT.05 I conteggi stanno in cima e non coprono il testo',
      (tester) async {
    silenzio();
    await apriLaChat(tester, Maestro.medora);
    final domande = find.byKey(const Key('chat_residuo_domande'));
    final approfondimenti =
        find.byKey(const Key('chat_residuo_approfondimenti'));
    expect(domande, findsOneWidget,
        reason: 'la riga del residuo delle domande non c\'e\'');
    expect(approfondimenti, findsOneWidget,
        reason: 'la riga del residuo degli approfondimenti non c\'e\'');

    // **IL RIQUADRO DELLA CONVERSAZIONE, in tutti e due gli stati.** A
    // conversazione vuota non esiste nessuna lista: al suo posto c'e' lo
    // stato vuoto, che occupa lo stesso spazio e che i conteggi non devono
    // coprire allo stesso modo. Cercare la sola lista avrebbe fatto cadere
    // la prova per come e' scritta, non per cio' che misura.
    final lista = find.byType(ListView);
    final vuoto = find.byType(ChatEmptyState);
    final conversazione = lista.evaluate().isNotEmpty ? lista.first : vuoto;
    expect(conversazione, findsWidgets,
        reason: 'non c\'e\' nessun riquadro della conversazione da '
            'confrontare, quindi questa prova non sta misurando niente');
    final riquadroDellaLista = tester.getRect(conversazione);

    for (final (nome, riga) in [
      ('domande', domande),
      ('approfondimenti', approfondimenti),
    ]) {
      final r = tester.getRect(riga);
      // **NESSUNA INTERSEZIONE.** In basso queste due righe passavano SOPRA le
      // parole del Maestro, e si vede in quattro delle cinque schermate del
      // collaudo: il testo che scorre finiva sotto di loro e non si leggeva
      // piu' ne' l'uno ne' l'altro.
      final incrocio = r.intersect(riquadroDellaLista);
      expect(incrocio.height <= 0 || incrocio.width <= 0, isTrue,
          reason: 'la riga dei $nome si sovrappone al riquadro della '
              'conversazione per ${incrocio.height.toStringAsFixed(1)} punti: '
              'riga $r, conversazione $riquadroDellaLista');
      expect(r.bottom, lessThanOrEqualTo(riquadroDellaLista.top + 0.5),
          reason: 'la riga dei $nome non sta sopra la conversazione: finisce '
              'a ${r.bottom.toStringAsFixed(1)} e la conversazione comincia a '
              '${riquadroDellaLista.top.toStringAsFixed(1)}');
    }
  });

  // ------------------------------------------------------------ CT.06
  testWidgets('CT.06 Suggerimenti, campo e invio stanno su una riga sola',
      (tester) async {
    silenzio();
    await apriLaChat(tester, Maestro.medora);
    final stelline = tester.getRect(find.byKey(const Key('chat_stelline')));
    final campo = tester.getRect(find.byKey(const Key('chat_campo')));
    final invio = tester.getRect(find.byKey(const Key('chat_invio')));

    // **UNA RIGA SOLA vuol dire che i tre si guardano in faccia.** Prima i
    // Suggerimenti stavano SOPRA il campo, larghi tutto lo schermo, e la
    // barra sotto occupava due righe.
    expect(stelline.center.dy, closeTo(campo.center.dy, 6),
        reason: 'i Suggerimenti non sono in riga col campo: stanno a '
            '${stelline.center.dy.toStringAsFixed(1)} contro '
            '${campo.center.dy.toStringAsFixed(1)}');
    expect(invio.center.dy, closeTo(campo.center.dy, 6),
        reason: 'la freccia di invio non e\' in riga col campo');

    // E l'ordine e' quello chiesto: cerchietto a sinistra, campo al centro,
    // freccia a destra.
    expect(stelline.right, lessThanOrEqualTo(campo.left),
        reason: 'i Suggerimenti non stanno a sinistra del campo');
    expect(campo.right, lessThanOrEqualTo(invio.left),
        reason: 'la freccia di invio non sta a destra del campo');
  });

  test('CT.06 Il microfono della dettatura resta dentro il campo', () {
    // **NON FARLO SPARIRE, dice l'ordine.** Il microfono e' un modo di
    // scrivere, quindi vive dentro il campo dove si scrive, e non accanto
    // alla freccia che manda. Comprimendo la barra in una riga sola era il
    // pezzo piu' facile da perdere.
    //
    // Si legge il sorgente perche' a video il microfono compare solo dove la
    // piattaforma sa ascoltare, e sotto le prove non sa: una prova a video
    // sarebbe verde anche cancellandolo.
    final sorgente =
        File('lib/features/maestri/chat/widgets/chat_composer.dart')
            .readAsStringSync();
    final campo = sorgente.indexOf("key: const Key('chat_campo')");
    final microfono = sorgente.indexOf('_MicrofonoDellaDettatura(');
    final invio = sorgente.indexOf('_SendButton(enabled: canSend');
    expect(campo, greaterThan(-1), reason: 'il campo non c\'e\' piu\'');
    expect(microfono, greaterThan(-1),
        reason: 'il microfono della dettatura e\' sparito dal compositore');
    expect(microfono, greaterThan(campo),
        reason: 'il microfono non e\' piu\' dentro il campo');
    expect(microfono, lessThan(invio),
        reason: 'il microfono e\' finito dopo la freccia di invio, cioe\' '
            'fuori dal campo');
  });
}
