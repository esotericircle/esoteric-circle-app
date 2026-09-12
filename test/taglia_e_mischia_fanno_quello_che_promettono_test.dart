import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// TAGLIA E MISCHIA FANNO QUELLO CHE PROMETTONO.
///
/// Ordine 2171, voce 6. Segnalato da Mauro e poi da Dora.
///
/// **COSA FACEVANO PRIMA, verificato leggendo il codice.** `_taglia` e
/// `_mischia` facevano tre cose: suonavano il momento sensoriale, mandavano
/// avanti un controller di animazione, e tornavano a riposo. Nessuna delle due
/// toccava le carte. La stesa era pescata una volta sola all'apertura, con
/// `TarotSpread.draw(seed:)`, e restava quella qualunque cosa facesse la
/// persona: si poteva mischiare dieci volte e ritrovare le stesse tre carte.
/// Un gesto che non tocca il risultato non e' un rito, e' una decorazione.
///
/// **COSA FANNO ADESSO.** Il mazzo ha un ordine vero, settantotto indici, e i
/// due gesti lo cambiano: Mischia lo rimescola, Taglia porta sopra la meta' di
/// sotto. Le tre carte si prendono dalla cima di quell'ordine, come le
/// prenderebbe una mano.
void main() {
  _aSchermo();

  test('MISCHIA cambia l\'ordine del mazzo', () {
    final prima = TarotSpread.mazzoMescolato(seed: 7);
    final dopo = [...prima]..shuffle();

    expect(dopo, isNot(equals(prima)),
        reason: 'il mazzo dopo il mescolamento e\' identico a prima: e\' il '
            'difetto segnalato, il vortice era un\'animazione sopra un mazzo '
            'immobile');
    // E resta un mazzo: stesse carte, nessuna persa e nessuna doppia.
    expect(dopo.toSet(), prima.toSet(),
        reason: 'mescolando sono cambiate le CARTE, non solo il loro ordine');
    expect(dopo.toSet(), hasLength(TarotDeck.cards.length));
  });

  test('e la stesa che ne viene e\' un\'altra', () {
    // La misura che conta per la persona: non l'ordine in se', ma le tre
    // carte che le escono.
    final prima = TarotSpread.mazzoMescolato(seed: 11);
    final stesaPrima = TarotSpread.dalMazzo(prima, seed: 11);

    var diverse = 0;
    for (var giro = 0; giro < 20; giro++) {
      final dopo = [...prima]..shuffle();
      final stesaDopo = TarotSpread.dalMazzo(dopo, seed: 11);
      final nomiPrima = stesaPrima.cards.map((c) => c.card.name).toList();
      final nomiDopo = stesaDopo.cards.map((c) => c.card.name).toList();
      if (!identici(nomiPrima, nomiDopo)) diverse++;
    }
    // ignore: avoid_print
    print('TAROCCHI: su venti mescolamenti, $diverse hanno dato una stesa '
        'diversa');
    expect(diverse, greaterThanOrEqualTo(19),
        reason: 'mescolando venti volte la stesa e\' cambiata solo $diverse '
            'volte: con settantotto carte, ritrovare le stesse tre in cima e\' '
            'praticamente impossibile, quindi il mescolamento non arriva alle '
            'carte');
  });

  test('TAGLIA porta sopra la meta\' di sotto, e non perde niente', () {
    final mazzo = TarotSpread.mazzoMescolato(seed: 3);
    const punto = 26;
    final tagliato = TarotSpread.taglia(mazzo, punto);

    expect(tagliato.first, mazzo[punto],
        reason: 'dopo il taglio in cima non c\'e\' la carta del punto di '
            'taglio: il gesto non ha portato sopra la meta\' di sotto');
    expect(tagliato.last, mazzo[punto - 1],
        reason: 'in fondo non c\'e\' la carta che stava sopra il punto di '
            'taglio: il mazzo non si e\' ricomposto');
    expect(tagliato.toSet(), mazzo.toSet(),
        reason: 'il taglio ha perso o duplicato delle carte');
    expect(tagliato, isNot(equals(mazzo)),
        reason: 'il taglio non ha cambiato niente');
  });

  test('un taglio NON mescola: le carte restano nel loro giro', () {
    // La differenza fra i due gesti e' proprio questa, ed e' cio' che rende
    // il taglio riconoscibile a chi le carte le conosce: dopo un taglio ogni
    // carta ha ancora la stessa vicina di prima, tranne al punto di giunzione.
    final mazzo = TarotSpread.mazzoMescolato(seed: 5);
    final tagliato = TarotSpread.taglia(mazzo, 40);
    var vicinanzeMantenute = 0;
    for (var i = 0; i < tagliato.length - 1; i++) {
      final qui = mazzo.indexOf(tagliato[i]);
      final dopo = mazzo.indexOf(tagliato[i + 1]);
      if ((dopo - qui) == 1) vicinanzeMantenute++;
    }
    // ignore: avoid_print
    print('TAROCCHI: dopo il taglio $vicinanzeMantenute vicinanze su '
        '${tagliato.length - 1} sono rimaste');
    expect(vicinanzeMantenute, tagliato.length - 2,
        reason: 'dopo il taglio le carte non sono piu\' nel loro giro: quello '
            'non e\' un taglio, e\' un mescolamento');
  });

  test('due tagli allo stesso punto riportano il mazzo dove stava', () {
    // Un taglio e' una rotazione: settantotto tagli di un passo riportano al
    // punto di partenza. E' la prova che il gesto non consuma nulla.
    final mazzo = TarotSpread.mazzoMescolato(seed: 9);
    var corrente = mazzo;
    for (var i = 0; i < TarotDeck.cards.length; i++) {
      corrente = TarotSpread.taglia(corrente, 1);
    }
    expect(corrente, equals(mazzo),
        reason: 'girando il mazzo per intero non si torna al punto di '
            'partenza: il taglio sta perdendo o spostando qualcosa');
  });

  test('la stessa cima da\' sempre la stessa stesa', () {
    // Il rovescio della medaglia: il gesto deve cambiare le carte, ma a
    // parita' di mazzo la lettura non puo' ballare da sola.
    final mazzo = TarotSpread.mazzoMescolato(seed: 13);
    final a = TarotSpread.dalMazzo(mazzo, seed: 13);
    final b = TarotSpread.dalMazzo(mazzo, seed: 13);
    expect(a.cards.map((c) => c.displayName).toList(),
        b.cards.map((c) => c.displayName).toList(),
        reason: 'lo stesso mazzo da\' due letture diverse: il verso delle '
            'carte sta ballando a ogni ricostruzione');
  });
}

bool identici(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// **LA PROVA A SCHERMO**: il gesto arriva alle carte, non solo al modello.
///
/// Le prove qui sopra misurano il mazzo; questa monta la schermata vera,
/// preme Mischia e guarda che la stesa che ne esce sia un'altra. E' la
/// differenza fra "il modello sa mescolare" e "il pulsante mescola".
void _aSchermo() {
  /// Monta la schermata a riposo, col ventaglio coperto e i due gesti
  /// disponibili, e torna i nomi delle tre carte che il mazzo ha in cima.
  ///
  /// **Perche' non si usa `revealAll`**: con le carte gia' scoperte la scena
  /// e' completa e i pulsanti Taglia e Mischia non ci sono piu', perche' a
  /// stesa fatta non si mescola nulla. Il gesto si prova dov'e' vivo.
  Future<List<String>> cimaDelMazzo(WidgetTester tester,
      {required bool mischiando}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: const MaterialApp(
        home: MaestroScope(child: StesaTreCarteScreen(seed: 4)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 4));

    if (mischiando) {
      expect(find.byKey(const Key('stesa_mischia')), findsOneWidget,
          reason: 'il pulsante Mischia non c\'e\': la prova non misura niente');
      // **SI PORTA IN VISTA PRIMA DI TOCCARLO. Ordine CO voce 07**, 3
      // settembre 2026: il pulsante "Inizia la lettura" e la riga che dice
      // come si prosegue occupano una settantina di punti sopra i gesti del
      // mazzo, e su uno schermo da ottocento punti logici Mischia finisce
      // sotto la piega. Il widget c'e', e infatti la riga qui sopra lo trova:
      // e' il TOCCO che cadeva fuori dal riquadro visibile, e cadeva in
      // silenzio, cioe' il mazzo non si mischiava e la prova leggeva le
      // stesse tre carte di prima.
      await tester.ensureVisible(find.byKey(const Key('stesa_mischia')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('stesa_mischia')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
    }

    // Lo stato della schermata sa quali carte ha in cima: si legge di li',
    // perche' a ventaglio coperto i nomi a schermo non ci sono ancora.
    final stato = tester.state(find.byType(StesaTreCarteScreen));
    // ignore: avoid_dynamic_calls
    final stesa = (stato as dynamic).stesaCorrente as TarotSpread;
    return stesa.cards.map((c) => c.displayName).toList();
  }

  testWidgets('premendo Mischia il mazzo a schermo cambia davvero',
      (tester) async {
    final senza = await cimaDelMazzo(tester, mischiando: false);
    final con = await cimaDelMazzo(tester, mischiando: true);
    // ignore: avoid_print
    print('TAROCCHI a schermo: senza mischiare $senza, dopo Mischia $con');
    expect(con, isNot(equals(senza)),
        reason: 'dopo aver premuto Mischia la schermata ha in cima le stesse '
            'tre carte di prima: il pulsante muove il vortice ma non il mazzo, '
            'ed e\' il difetto segnalato da Mauro e da Dora');
  });
}
