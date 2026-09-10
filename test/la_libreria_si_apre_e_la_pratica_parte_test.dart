import 'package:esoteric_circle/core/maestro/libreria_dei_respiri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/pannello_della_libreria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA LIBRERIA SI APRE E LA PRATICA PARTE.** Ordine DD voce 12,
/// 10 settembre 2026.
///
/// **REGOLA D: cosa funzionava prima, e cosa funziona adesso.**
///
/// **Prima** questa guardia sorvegliava *il rito che ti costruisci* dell'ordine
/// DB voce 05: la libreria chiusa di partenza, il numero delle pratiche
/// dichiarato all'apertura, la fonte sotto ogni voce, e poi la composizione,
/// cioe' toccare da tre a cinque pratiche, dare un nome alla sequenza e
/// salvarla. **Sei prove, tutte verdi.**
///
/// **Adesso** la composizione non c'e' piu', per decisione del fondatore:
/// *"all'utente non importa memorizzare quattro pratiche se non sa cosa farne
/// e perche'"*. Le tre prove che la sorvegliavano non si aggirano e non si
/// cancellano: **spariscono col loro soggetto**, e questa nota dice dove sono
/// andate.
///
/// **Quello che resta funziona ancora e si prova qui**: la libreria e' chiusa
/// di partenza, all'apertura dichiara quante pratiche ci sono, ogni voce porta
/// la sua fonte. **E quello che e' nuovo**: ogni voce porta il sintomo in
/// testa, e toccarla fa partire la pratica.
void main() {
  void telefono(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  /// L'ultima pratica scelta, oppure nulla se nessuna lo e'.
  Respiro? scelta;

  Widget scena() => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PannelloDellaLibreria(
              palette: MaestroPalette.aura,
              centroDiOggi: 3,
              onSceglie: (r) => scelta = r,
            ),
          ),
        ),
      );

  Future<void> apri(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('meditazione_apri_libreria')));
    await tester.pump();
  }

  setUp(() => scelta = null);

  testWidgets('LA LIBRERIA E CHIUSA DI PARTENZA, e Aura sceglie',
      (tester) async {
    telefono(tester);
    await tester.pumpWidget(scena());
    // Ordine CZ voce 06: *"un menu di frequenze davanti a chi non ha criterio
    // per scegliere e la forma sbagliata"*. Il pannello si apre a richiesta.
    expect(find.byKey(const Key('meditazione_ampiezza_libreria')), findsNothing,
        reason: 'la libreria e gia aperta quando la scena compare: la porta '
            'principale non e piu quella di Aura');
    expect(find.byKey(const Key('meditazione_apri_libreria')), findsOneWidget);
  });

  testWidgets('IL PULSANTE DICE SCEGLI SINTOMO E FREQUENZA', (tester) async {
    // **Ordine DD voce 12**, che lo detta parola per parola: *"un pulsante in
    // evidenza, maiuscolo e in grassetto: SCEGLI SINTOMO E FREQUENZA"*.
    telefono(tester);
    await tester.pumpWidget(scena());
    final testo = tester
        .widget<Text>(find.descendant(
            of: find.byKey(const Key('meditazione_apri_libreria')),
            matching: find.byType(Text)))
        .data;
    // ignore: avoid_print
    print('ORDINE DD VOCE 12: il pulsante della libreria dice "$testo"');
    expect(testo, 'SCEGLI SINTOMO E FREQUENZA');
    final misura =
        tester.getSize(find.byKey(const Key('meditazione_apri_libreria')));
    expect(misura.height, greaterThanOrEqualTo(52),
        reason: 'il pulsante e alto ${misura.height}: non e in evidenza, e un '
            'tratto di testo come quello di prima');
  });

  testWidgets('APERTA, DICHIARA QUANTE PRATICHE CI SONO', (tester) async {
    telefono(tester);
    await tester.pumpWidget(scena());
    await apri(tester);
    expect(
        find.textContaining('${LibreriaDeiRespiri.quantePronte} pratiche'),
        findsOneWidget,
        reason: 'la libreria non dice piu quante pratiche ha');
  });

  testWidgets('OGNI VOCE PORTA IL SINTOMO IN TESTA, E LA SUA FONTE',
      (tester) async {
    telefono(tester);
    await tester.pumpWidget(scena());
    await apri(tester);
    // **I SINTOMI CI SONO TUTTI QUELLI CHE LE PRATICHE NOMINANO**, e non uno
    // di piu': un sintomo a schermo senza una pratica dietro sarebbe una
    // promessa vuota.
    final attesi = {
      for (final r in LibreriaDeiRespiri.pronte) r.sintomo.etichetta
    };
    expect(attesi.length, greaterThanOrEqualTo(4),
        reason: 'le pratiche nominano meno di quattro sintomi diversi: questa '
            'prova sta guardando una libreria che non distingue niente');
    for (final e in attesi) {
      expect(find.textContaining(e), findsWidgets,
          reason: 'il sintomo "$e" non compare a schermo');
    }
    // La fonte resta sotto ogni pratica, come dall'ordine DB voce 02.
    for (final r in LibreriaDeiRespiri.pronte.take(3)) {
      expect(find.textContaining(r.tradizione.fonte), findsWidgets,
          reason: 'la pratica ${r.nome} ha perso la sua fonte');
    }
  });

  testWidgets('TOCCARE UNA VOCE FA PARTIRE LA PRATICA, E CHIUDE LA LIBRERIA',
      (tester) async {
    // **E' la voce dell'ordine, e nasce da una misura sul telefono**: prima,
    // toccando una voce cambiavano 603 pixel, cioe' si riempiva un cerchietto
    // e non partiva niente.
    telefono(tester);
    await tester.pumpWidget(scena());
    await apri(tester);
    final prima = LibreriaDeiRespiri.pronte.first;
    final riga = find.byKey(Key('meditazione_respiro_${prima.id}'));
    await tester.ensureVisible(riga);
    await tester.pump();
    await tester.tap(riga);
    await tester.pump();
    // ignore: avoid_print
    print('ORDINE DD VOCE 12: toccata la voce ${prima.id}, e partita '
        '${scelta?.id ?? "nessuna"}');
    expect(scelta?.id, prima.id,
        reason: 'toccando una voce non parte nessuna pratica: e esattamente il '
            'difetto che il fondatore ha misurato sul telefono');
    // **REGOLA H: e la libreria si chiude.** E' l'unico segno visibile quando
    // la sessione gira gia' sulla stessa frequenza, e senza di lui il tocco
    // cambia zero pixel.
    expect(find.byKey(const Key('meditazione_ampiezza_libreria')), findsNothing,
        reason: 'la libreria resta aperta dopo la scelta: chi tocca non vede '
            'nessuna risposta');
  });

  testWidgets('LA COMPOSIZIONE DEL RITO NON C E PIU', (tester) async {
    // **REGOLA H: si prova anche l'assenza.** La composizione e' stata tolta
    // per decisione del fondatore, e una funzione tolta in silenzio e' la cosa
    // che questo progetto vieta: qui si dichiara che non c'e' piu, cosi'
    // nessuno la rimette per distrazione.
    telefono(tester);
    await tester.pumpWidget(scena());
    await apri(tester);
    expect(find.byKey(const Key('meditazione_nome_del_rito')), findsNothing,
        reason: 'il campo del nome del rito e tornato');
    expect(find.byKey(const Key('meditazione_salva_il_rito')), findsNothing,
        reason: 'il pulsante che salva il rito e tornato');
  });
}
