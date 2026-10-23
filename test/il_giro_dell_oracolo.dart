import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA RISPOSTA FINTA DEL MODELLO, NELLA FORMA NUOVA.** Ordine GA voci
/// GA.03 e GA.07, 20 ottobre 2026: il modello scrive il titolo, la risposta,
/// il riquadro "Cosa fare adesso" e, nella Lunga, l'approfondimento, ognuno
/// da 40 a 50 parole; una risposta fuori misura si scarta e parla il corpus.
/// Nessuna chiamata vera (regola SPESE): le prove che montano l'Oracolo
/// rispondono tutte con questi testi, scritti a misura (47 parole ciascuno).
const String titoloFintoDellOracolo = 'Gli angeli ti chiedono un passo lento';
const String rispostaFintaDellOracolo =
    'Sì, il cambiamento che cerchi è vicino, ma chiede un passo lento e '
    'misurato. Il tuo Angelo Custode ti invita a partire da ciò che già sai '
    'fare bene, il Cuore a sentire dove ti senti a casa, l\'Intelletto a '
    'distinguere il desiderio dalla fretta di oggi.';
const String cosaFareFintoDellOracolo =
    'Scrivi stasera su un foglio tre cose che sai fare meglio di altri e '
    'scegline una da mettere alla prova questa settimana. Non lasciare il '
    'lavoro di oggi prima di aver parlato con chi può aprirti una porta. '
    'Muovi un passo alla volta, senza bruciare le tappe.';
const String approfondimentoFintoDellOracolo =
    'Il passo lento non è una rinuncia: è il modo in cui le tre carte '
    'leggono la tua domanda. Il Custode chiede metodo, il Cuore chiede '
    'ascolto, l\'Intelletto chiede chiarezza. Insieme dicono che la strada '
    'nuova si apre quando smetti di correre e cominci a scegliere davvero.';

/// Il JSON finto per i [campi] chiesti dalla lettura: l'approfondimento solo
/// se lo schema lo chiede, come fa il modello vero.
String jsonFintoDellOracolo(Map<String, Object?> campi,
        {String titolo = titoloFintoDellOracolo}) =>
    jsonEncode({
      'titolo': titolo,
      'risposta': rispostaFintaDellOracolo,
      'cosaFare': cosaFareFintoDellOracolo,
      if (campi.containsKey('approfondimento'))
        'approfondimento': approfondimentoFintoDellOracolo,
    });

/// **IL GIRO DELL'ORACOLO DEGLI ANGELI, COME LO FA UNA PERSONA.** Ordine FY
/// voci FY.15 e FY.16, 16 ottobre 2026: la domanda si affida, poi si
/// scelgono le tre carte dal mazzo coperto col ventaglio della Stesa, poi il
/// pulsante dipinto avvia la lettura. Le prove che montano l'Oracolo passano
/// tutte da qui, cosi' il giro e' uno solo.

/// **I SENSORI DEL COSMO, FINTI**, ordine GC voce GC.16: dietro l'Oracolo
/// adesso c'e' il cosmo della Stesa (`CosmosBackground`), che con la sua
/// parallasse ascolta l'accelerometro e il giroscopio. In una prova non c'e'
/// nessuna piattaforma che li dia: come fanno le prove della Stesa, i canali
/// rispondono vuoti.
void silenziaISensoriDelCosmo() {
  final m = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  m.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null);
  for (final nome in const [
    'dev.fluttercommunity.plus/sensors/accelerometer',
    'dev.fluttercommunity.plus/sensors/user_accel',
    'dev.fluttercommunity.plus/sensors/gyroscope',
    'dev.fluttercommunity.plus/sensors/magnetometer',
  ]) {
    m.setMockStreamHandler(
        EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
  }
}

/// **LA LUNGA SI SCEGLIE**, ordine GC voce GC.19: all'apertura la
/// profondita' e' Breve, e chi ha il piano sceglie la Lunga nel selettore,
/// come nella Stesa di Tarocchi.
Future<void> scegliLaLunga(WidgetTester tester) async {
  final tendina = find.byKey(const Key('oracolo_profondita'));
  await Scrollable.ensureVisible(tester.element(tendina), alignment: 0.2);
  await tester.pump();
  await tester.tap(tendina);
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.tap(find.text('Lunga').last);
  await tester.pump(const Duration(milliseconds: 400));
}

/// I dorsi che si toccano, nell'ordine: Custode, Cuore, Intelletto. Stanno
/// nella finestra iniziale del ventaglio (il centro e' a meta' dei 72).
const List<int> dorsiDelGiro = [33, 36, 39];

/// Scrive la domanda e chiude la tastiera: il mazzo coperto si e' gia'
/// acceso da solo (ordine GD voce GD.06; LAPIDE: si toccava il pulsante
/// rotondo che la affidava).
///
/// **LA DOMANDA STA SOTTO IL TAVOLO**, ordine GC voce GC.09: il riquadro e'
/// nella lista, e prima di scriverci si porta in vista.
Future<void> affidaLaDomanda(WidgetTester tester, String domanda) async {
  final campo = find.byKey(const Key('oracolo_campo_domanda'));
  await Scrollable.ensureVisible(tester.element(campo), alignment: 0.5);
  await tester.pump();
  await tester.enterText(campo, domanda);
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// **UNA CARTA O TRE** (GC.09, GC.17): sceglie la stesa nella tendina.
Future<void> scegliQuanteCarte(WidgetTester tester, int quante) async {
  final tendina = find.byKey(const Key('oracolo_quante_carte'));
  await Scrollable.ensureVisible(tester.element(tendina), alignment: 0.2);
  await tester.pump();
  await tester.tap(tendina);
  // Il menu si apre in piu' fotogrammi: si tocca la voce a menu aperto.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.tap(find.text(quante == 1 ? 'Una carta' : 'Tre carte').last);
  await tester.pump(const Duration(milliseconds: 400));
}

/// Tocca un dorso del ventaglio sul suo lembo sinistro: il dorso accanto,
/// disegnato sopra, ne copre il centro.
Future<void> toccaIlDorso(WidgetTester tester, int indice) async {
  final dorso = find.byKey(Key('stesa_fan_$indice'));
  // Come una persona: si tocca quando la pagina ha smesso di scorrere (uno
  // scorrimento in corso prende il tocco per se').
  final pagina =
      tester.state<ScrollableState>(find.byType(Scrollable).first).position;
  for (var i = 0; i < 30 && pagina.isScrollingNotifier.value; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  // La schermata ha gia' portato il mazzo in fondo alla finestra, con
  // l'altare in vista sopra: si scorre solo se il dorso non si vede, e
  // allora al centro (in cima starebbe sotto la barra del titolo, che prende
  // il tocco).
  final finestra = tester.view.physicalSize / tester.view.devicePixelRatio;
  var r = tester.getRect(dorso);
  if (r.top < 100 || r.bottom > finestra.height) {
    await Scrollable.ensureVisible(tester.element(dorso), alignment: 0.5);
    await tester.pump();
    r = tester.getRect(dorso);
  }
  await tester.tapAt(Offset(r.left + 12, r.center.dy));
  // Il dorso toccato vola sull'altare (GC.12): 620 millisecondi.
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Sceglie le tre carte dal mazzo coperto.
Future<void> scegliLeTreCarte(WidgetTester tester,
    [List<int> dorsi = dorsiDelGiro]) async {
  for (final d in dorsi) {
    await toccaIlDorso(tester, d);
  }
}

/// Tocca il pulsante dipinto e lascia andare la lettura fino al responso:
/// le lettere (2,4 s), la riflessione di Medora (GC.13), le carte che si
/// girano una alla volta e si alzano (GC.14) e lo scorrimento. Si aspetta il
/// responso, non un numero di secondi scritto qui.
Future<void> avviaLaLettura(WidgetTester tester) async {
  final pulsante = find.byKey(const Key('oracolo_avvia_la_lettura'));
  await Scrollable.ensureVisible(tester.element(pulsante), alignment: 0.5);
  await tester.pump();
  await tester.tap(pulsante);
  for (var i = 0;
      i < 400 && find.byKey(const Key('oracolo_responso')).evaluate().isEmpty;
      i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Il giro intero: domanda, tre carte, pulsante.
Future<void> consultaLOracolo(WidgetTester tester, String domanda) async {
  await affidaLaDomanda(tester, domanda);
  await scegliLeTreCarte(tester);
  await avviaLaLettura(tester);
}
