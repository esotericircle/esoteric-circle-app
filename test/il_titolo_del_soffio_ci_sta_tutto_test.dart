// ignore_for_file: avoid_print
import 'package:esoteric_circle/design_system/components/titolo_che_non_si_rompe.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attorno_al_soffio.dart';

/// **IL TITOLO DEL SOFFIO CI STA TUTTO.** Ordine EF, 23 settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"Ti faccio anche notare il titolo in
/// alto troncato con dei puntini 'Soffio del destin...', questo capita per
/// tutti i titoli di ogni funzionalita' in schermi android medi e piccoli, ma
/// anche in schermi grandi iphone"*.
///
/// **AGGANCIARE IL COMPONENTE GIUSTO NON BASTA, ed e' la ragione per cui
/// questa prova esiste.** `TitoloCheNonSiRompe` evita che una parola si spezzi
/// a meta', ma quando il titolo intero vuole piu' righe di quelle concesse
/// **restituisce lo stesso una misura**: il testo non si rompe, l'ultima riga
/// viene tagliata via. L'ordine DQ voce 14 l'ha gia' pagato sul Viaggio dello
/// Sciamano, dove la barra si leggeva *"Il Viaggio dello"* e *"Sciamano"* non
/// c'era piu'. Sostituire il widget e fermarsi li' sarebbe stato dichiarare
/// una cura senza misurarne l'esito.
///
/// **La larghezza si calcola, non si misura al banco.** Al banco il cuore
/// della barra resta vuoto finche' non ha reclamato l'arte, e al titolo avanza
/// larghezza che sul telefono non ha. Quindi si parte dalla barra e si tolgono
/// la freccia e le due azioni che il Soffio ha davvero: le fonti e il cuore.
///
/// **E la geometria e' quella del Realme**, 1080 per 2400 a densita' 3, cioe'
/// **360 punti** e non i 390 del banco: su 390 il titolo ci sta, e una guardia
/// montata li' sarebbe stata verde davanti alla cattura del fondatore.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('sul Realme il titolo del Soffio non perde nessuna parola',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(attornoAlSoffio(
      BreathDestinyScreen(now: DateTime(2026, 8, 7, 10, 30)),
      finestra: const Size(360, 800),
      rientri: const EdgeInsets.only(top: 40, bottom: 24),
      scala: 1.0,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    const titolo = 'Soffio del Destino';
    final reso = tester.widget<Text>(find.text(titolo));

    const freccia = 56.0, azione = 48.0, azioni = 2;
    final larghezza =
        tester.getSize(find.byType(AppBar)).width - freccia - azione * azioni;
    final righe = reso.maxLines ?? 2;
    final misura = TitoloCheNonSiRompe.misuraChePermetteDiLeggere(
      testo: titolo,
      stile: reso.style!,
      larghezza: larghezza,
      righe: righe,
    );

    final dipinto = TextPainter(
      text:
          TextSpan(text: titolo, style: reso.style!.copyWith(fontSize: misura)),
      textDirection: TextDirection.ltr,
      maxLines: righe,
      textAlign: TextAlign.center,
    )..layout(maxWidth: larghezza);

    print('ORDINE EF, IL TITOLO DEL SOFFIO: con due azioni restano '
        '${larghezza.toStringAsFixed(0)} punti, il titolo scende a '
        '${misura.toStringAsFixed(1)} su $righe righe');

    expect(dipinto.didExceedMaxLines, isFalse,
        reason: 'il titolo non ci sta nelle $righe righe concesse a '
            '${larghezza.toStringAsFixed(0)} punti: a video perde l\'ultima '
            'riga, che e\' il difetto visto dal fondatore');
    expect(misura, greaterThanOrEqualTo(TypographyTokens.pavimento),
        reason: 'per farcelo stare la misura e\' scesa a '
            '${misura.toStringAsFixed(1)}, sotto il pavimento tipografico '
            'dell\'app');
  });

  testWidgets('e non e\' un Text nudo, che i puntini li mette per forza',
      (tester) async {
    // **La meta' che tiene onesta l'altra.** La misura qui sopra parla della
    // resa; questa parla della strada: un `Text` nudo in una barra stretta
    // non ha altra scelta che i puntini, qualunque cosa dica il calcolo.
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(attornoAlSoffio(
      BreathDestinyScreen(now: DateTime(2026, 8, 7, 10, 30)),
      finestra: const Size(360, 800),
      rientri: const EdgeInsets.only(top: 40, bottom: 24),
      scala: 1.0,
    ));
    await tester.pump();

    expect(find.byType(TitoloCheNonSiRompe), findsOneWidget,
        reason: 'la barra del Soffio non passa da TitoloCheNonSiRompe: con un '
            'Text nudo il titolo torna a troncarsi coi puntini');
  });
}
