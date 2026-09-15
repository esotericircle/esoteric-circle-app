import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **UN COMANDO SOLO NELLA MEDITAZIONE.** Ordine DD voce 17, 10 settembre
/// 2026, e sono tre decisioni del fondatore in una frase sola:
///
/// *"elimina la possibilita' di tenere il dito premuto, solo pulsante play e
/// stop (stesso pulsante). elimina 'preferisco scegliere io', e' ridondante
/// visto che dal pulsante puo' gia' scegliere sintomo e frequenza."*
///
/// **COSA C'ERA, e va scritto perche' non torni per sbaglio.** La schermata
/// aveva **quattro modi** di comandare la stessa cosa:
///
/// 1. il dito **tenuto premuto** sul fiore, che inspirava ed espirava;
/// 2. il **pulsante play**, che accendeva il suono;
/// 3. *"Preferisco scegliere io"*, che apriva le nove frequenze;
/// 4. *"Respiro da solo, senza tenere il dito"*, che spegneva il primo.
///
/// **Il quarto esisteva solo per riparare il primo.** Tolto il dito, e' rimasto
/// un interruttore che porta dove sei gia'.
///
/// **Adesso il comando e' uno**: si preme e parte, si preme e si ferma. Il
/// fiore fa la stessa cosa del pulsante, e non c'e' nessun gesto nascosto.
///
/// **REGOLA H, e sono due meta'.** Che i comandi vecchi siano spariti e' la
/// prima; che quello nuovo **funzioni** e' la seconda, e senza di lei una
/// schermata senza nessun comando passerebbe.
void main() {
  Future<void> apri(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(
          maestro: Maestro.aura,
          child: MeditationScreen(
              player: const SilentTonePlayer(), now: DateTime(2026, 9, 9)),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('I TRE COMANDI DI TROPPO NON CI SONO PIU', (tester) async {
    await apri(tester);
    final rimasti = <String>[];
    // I due interruttori, cercati per chiave.
    for (final chiave in const [
      'meditation_scegli_tu',
      'meditazione_da_solo',
    ]) {
      if (find.byKey(Key(chiave)).evaluate().isNotEmpty) rimasti.add(chiave);
    }
    // E le loro parole, cercate a video: una chiave si puo' rinominare, le
    // parole no.
    for (final parola in const [
      'Preferisco scegliere io',
      'Respiro da solo, senza tenere il dito',
      'Torno a respirare col dito',
    ]) {
      if (find.text(parola).evaluate().isNotEmpty) rimasti.add('"$parola"');
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: comandi di troppo rimasti ${rimasti.length} '
        '$rimasti');
    expect(rimasti, isEmpty,
        reason: 'questi comandi dovevano sparire e sono ancora a schermo: '
            '${rimasti.join(", ")}');
  });

  testWidgets('IL FIORE NON CHIEDE PIU DI TENERE IL DITO', (tester) async {
    await apri(tester);
    final fiore = find.byKey(const Key('meditation_dito'));
    expect(fiore, findsOneWidget,
        reason: 'il fiore non e a schermo: questa prova non misura niente');
    final gesto = tester.widget<GestureDetector>(fiore);
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: sul fiore onTap '
        '${gesto.onTap != null}, onTapDown ${gesto.onTapDown != null}, '
        'onTapUp ${gesto.onTapUp != null}, onLongPress '
        '${gesto.onLongPress != null}');
    expect(gesto.onTapDown, isNull,
        reason: 'il fiore ascolta ancora il dito che scende: la pressione '
            'prolungata e tornata');
    expect(gesto.onTapUp, isNull,
        reason: 'il fiore ascolta ancora il dito che si alza');
    expect(gesto.onLongPress, isNull,
        reason: 'il fiore ha una pressione lunga: e il gesto che il fondatore '
            'ha tolto');
    // **E il tocco semplice c'e'**, perche' un cerchio grande che ignora il
    // dito e' peggio del difetto da cui quest ordine e nato.
    expect(gesto.onTap, isNotNull,
        reason: 'il fiore non risponde a niente: chi lo tocca non ottiene '
            'nessuna risposta, ed e esattamente "faccio click e non succede '
            'nulla"');
  });

  testWidgets('REGOLA H: IL COMANDO SOLO ACCENDE E SPEGNE, ed e lo stesso',
      (tester) async {
    await apri(tester);
    final play = find.byKey(const Key('meditation_play'));
    final fiore = find.byKey(const Key('meditation_dito'));
    expect(play, findsOneWidget, reason: 'il pulsante play non c e');

    bool inCorso() =>
        find.text('Il respiro è compiuto').evaluate().isEmpty &&
        find.text('Premi play').evaluate().isEmpty;

    // ignore: avoid_print
    print('ORDINE DD VOCE 17: di partenza la sessione gira ${inCorso()}');
    expect(inCorso(), isFalse,
        reason: 'la sessione parte da sola, senza che nessuno abbia premuto');

    // Il pulsante accende.
    await tester.tap(play);
    await tester.pump(const Duration(milliseconds: 200));
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: premuto play, la sessione gira ${inCorso()}');
    expect(inCorso(), isTrue,
        reason: 'premuto play la sessione non parte');

    // **Lo stesso pulsante spegne**, che e' cio' che l ordine chiede per nome.
    await tester.tap(play);
    await tester.pump(const Duration(milliseconds: 200));
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: ripremuto play, la sessione gira ${inCorso()}');
    expect(inCorso(), isFalse,
        reason: 'lo stesso pulsante non ferma la sessione: servono due '
            'comandi diversi per accendere e spegnere');

    // E il fiore fa la stessa identica cosa.
    await tester.tap(fiore, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: toccato il fiore, la sessione gira ${inCorso()}');
    expect(inCorso(), isTrue,
        reason: 'toccato il fiore non succede niente: e il difetto da cui '
            'quest ordine e nato');
  });

  testWidgets('IL PLAY STA SUBITO SOTTO IL FIORE, non in fondo alla colonna',
      (tester) async {
    // **TROVATO SUL TELEFONO 767f596c, guardando la build appena costruita.**
    // Ordine DD voce 17.
    //
    // Il fiore dice **PREMI PLAY** e il pulsante play stava **in fondo alla
    // colonna**: sotto il testo del centro, sotto il pulsante grande, quasi
    // fuori campo. Chi leggeva quell'invito doveva **cercare** il comando che
    // l'invito nomina.
    //
    // **Un'istruzione che manda a cercare non e' un'istruzione**, ed e' la
    // stessa famiglia del difetto da cui quest'ordine e' nato: un comando che
    // c'e' e non si trova vale quanto un comando che non risponde.
    //
    // **La grandezza misurata e' la distanza in punti** fra il fondo del
    // fiore e la cima del pulsante, non l'ordine delle righe nel sorgente: e'
    // la distanza che l'occhio percorre.
    await apri(tester);
    final fiore = tester.getRect(find.byKey(const Key('meditation_dito')));
    final play = tester.getRect(find.byKey(const Key('meditation_play')));
    final libreria =
        tester.getRect(find.byKey(const Key('meditazione_apri_libreria')));
    final distanza = play.top - fiore.bottom;
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: il fiore finisce a '
        '${fiore.bottom.toStringAsFixed(0)}, il play comincia a '
        '${play.top.toStringAsFixed(0)}, distanza '
        '${distanza.toStringAsFixed(0)} punti; il pulsante del sintomo sta a '
        '${libreria.top.toStringAsFixed(0)}');

    expect(play.top, lessThan(libreria.top),
        reason: 'il play sta SOTTO il pulsante del sintomo: chi legge "premi '
            'play" nel fiore deve scavalcare un altro pulsante per trovarlo');
    // **Meno di duecento punti**, cioe' meno di un quarto di schermo: oltre,
    // fra l'invito e il comando entra dell'altro e l'occhio si perde.
    expect(distanza, lessThan(200),
        reason: 'fra il fiore e il play ci sono '
            '${distanza.toStringAsFixed(0)} punti: l invito e il comando che '
            'nomina non si vedono insieme');
  });

  testWidgets('LA CARD ARRIVA A SESSIONE COMPIUTA, e porta il numero vero',
      (tester) async {
    // **TROVATO SUL TELEFONO 767f596c l 11 settembre 2026**, con la build in
    // mano: dopo due minuti di sessione, sotto il disclaimer non c era
    // niente. Nessuna card, nessun pulsante di condivisione.
    //
    // **DUE DIFETTI, uno dentro l altro.**
    //
    // **Il primo**: la card compariva sotto `_quantoEDurata.inSeconds >= 60`,
    // letta **dentro il build**, e la colonna della schermata **non si
    // ricostruisce mentre la sessione gira**. Quella condizione veniva
    // valutata una volta sola, al tocco del play, con la durata a zero.
    //
    // **Il secondo, che ha trovato questa prova**: la durata veniva
    // **dedotta** da `widget.now ?? DateTime.now()` meno l ora di inizio. Nei
    // test `widget.now` e un ora **iniettata e ferma**, e la sessione comincia
    // proprio a quell ora: la differenza faceva **sempre zero**. Nell app vera
    // era sbagliato in un altro modo, peggiore: l orologio da parete conta
    // anche i minuti passati con l app in tasca e lo schermo spento, che non
    // sono minuti respirati. **Adesso i secondi si contano, uno per uno.**
    //
    // **E LA CARD E IL PREMIO DI CHI ARRIVA IN FONDO**, non di chi si ferma:
    // vive dentro il blocco del compimento, come la riga *"la meditazione e
    // portata a compimento"*. E la stessa legge che il fondatore ha dato al
    // gesto, *"fermarsi a meta non e compiere"*, e da' una ragione per
    // arrivare alla fine.
    await apri(tester);
    final card = find.byKey(const Key('card_del_respiro'));
    final condividi = find.byKey(const Key('meditazione_condividi_respiro'));

    expect(card, findsNothing,
        reason: 'la card e a schermo prima che qualcuno abbia respirato');

    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump(const Duration(milliseconds: 200));
    // A meta strada non c e ancora niente da portarsi via.
    await tester.pump(const Duration(seconds: 40));
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: a quaranta secondi la card e '
        '${card.evaluate().length}');
    expect(card, findsNothing,
        reason: 'la card arriva a meta sessione: si guarda un riquadro mentre '
            'si dovrebbero avere gli occhi socchiusi');

    // E si arriva in fondo: dodici cicli da undici secondi.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(seconds: 11));
    }
    await tester.pump(const Duration(milliseconds: 400));

    // ignore: avoid_print
    print('ORDINE DD VOCE 17: a sessione compiuta la card e '
        '${card.evaluate().length}, il condividi e '
        '${condividi.evaluate().length}');
    expect(card, findsOneWidget,
        reason: 'compiuta la sessione la card non arriva: chi ha respirato '
            'fino in fondo non ha niente da portarsi via');
    expect(condividi, findsOneWidget,
        reason: 'la card c e e non si puo condividere');

    // **E PORTA IL NUMERO VERO**: due minuti e dodici, non "un momento".
    final titolo = tester
        .widget<Text>(find.byKey(const Key('card_respiro_titolo')))
        .data!;
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: il titolo della card dice "$titolo"');
    expect(titolo.contains('MOMENTO'), isFalse,
        reason: 'dopo una sessione intera il titolo dice ancora "un momento": '
            'i secondi respirati non arrivano alla card');
    expect(RegExp(r'\d').hasMatch(titolo), isTrue,
        reason: 'il titolo non porta nessun numero: "$titolo"');
  });

  testWidgets('REGOLA H: CHI SI FERMA A META NON HA NESSUNA CARD',
      (tester) async {
    // **La meta opposta, ed e' la legge del fondatore applicata alla card**:
    // *"fermarsi a meta non e compiere"*. Una card che arriva comunque
    // toglierebbe la ragione per arrivare in fondo.
    await apri(tester);
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 20));
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump(const Duration(milliseconds: 300));
    // ignore: avoid_print
    print('ORDINE DD VOCE 17: fermata a venti secondi, card '
        '${find.byKey(const Key('card_del_respiro')).evaluate().length}');
    expect(find.byKey(const Key('card_del_respiro')), findsNothing,
        reason: 'chi si ferma dopo venti secondi ottiene la card lo stesso: '
            'non e un traguardo, e chi la spedisce se ne accorge');
  });
}
