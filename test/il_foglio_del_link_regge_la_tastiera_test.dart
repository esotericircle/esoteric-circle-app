// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/identity/account_del_cerchio.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/account/custodia_del_cielo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL FOGLIO DEL LINK REGGE LA TASTIERA. Ordine EA, difetto visto a video
/// sulla build 2273 del 20 settembre 2026.
///
/// **COME E' STATO TROVATO, e conta.** Nessuna prova l'ha visto. L'ho visto
/// guardando lo schermo del telefono dopo aver consegnato la 2273: toccato
/// *Preferisco un'email*, toccato il campo, **e appena la tastiera e' salita
/// i due pulsanti sono finiti SOPRA il testo**. *Piu' tardi* copriva la
/// frase che spiega cosa succede, *Mandami il link* copriva il campo e
/// l'indirizzo appena scritto. Una persona che si registra vede il proprio
/// indirizzo sparire sotto un pulsante.
///
/// **E' lo stesso male della voce 21**, l'invito degli Eos tagliato dal
/// bordo: un foglio con dentro piu' roba di quanta ne entra nell'altezza che
/// gli resta. Li' l'altezza la mangiava la barra, qui la mangia la tastiera.
/// **Padre del difetto: EA voce 19**, che ha scritto questo foglio con tre
/// righe di spiegazione sopra il campo, dove prima c'erano due campi e nessun
/// discorso.
///
/// **COSA MISURA, e non e' una somiglianza.** Monta il foglio con la tastiera
/// alzata e confronta i rettangoli veri di cio' che sta a schermo: il
/// pulsante che conferma **non tocca** il campo dell'indirizzo, e il campo
/// resta dentro lo schermo. Due rettangoli che si intersecano sono un fatto,
/// non un'impressione.
void main() {
  // **I NUMERI VENGONO DAL TELEFONO SU CUI IL DIFETTO SI VEDE, non da una
  // finestra comoda.** Letti sul Realme 767f596c il 20 settembre 2026:
  //   adb shell wm size      -> 1080x2400
  //   adb shell wm density   -> 480, cioe' tre pixel per punto
  //   dumpsys window displays -> ImeInsetsSourceProvider bottom=918 px
  // Quindi la finestra vale 360 per 800 punti e la tastiera ne prende 306.
  // **Larghezza e altezza contano tutte e due**: a 360 punti la frase sopra
  // il campo va a capo quattro volte invece di tre, e il titolo su due righe
  // invece di una. La prima stesura di questa prova girava a 390 per 844 e
  // restava VERDE su un difetto che sul telefono si vedeva a occhio.
  const larghezza = 360.0;
  const altezza = 800.0;
  const tastiera = 306.0;
  // **E I BORDI, che sono la meta' mancante.** Il foglio non vive in una
  // finestra nuda: sopra c'e' la barra dell'identita', che dichiara la
  // propria altezza nel `padding.top` proprio perche' le aree sicure la
  // rispettino, e sotto c'e' la barra del Cerchio, che fa lo stesso col
  // `padding.bottom`. Misurati sui pixel della cattura del Realme, divisi
  // per tre: la riga d'oro sotto "Eventi Cosmici" cade a 222 px, il bordo
  // sopra "Esplora" a 1932 px su 2400.
  const bordoSopra = 74.0;
  const bordoSotto = 156.0;

  Future<void> apriIlFoglio(WidgetTester tester,
      {required double insetto}) async {
    final chiave = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<AccountDelCerchio>(
          create: (_) => AccountDelCerchio(porta: const IdentitaAssente()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          // **LA TASTIERA E' QUESTO**: Flutter la dichiara come un insetto in
          // fondo alla finestra, ed e' cio' che il foglio deve leggere per
          // sapere quanta altezza gli resta davvero.
          data: MediaQuery.of(ctx).copyWith(
            viewInsets: EdgeInsets.only(bottom: insetto),
            padding: const EdgeInsets.only(top: bordoSopra, bottom: bordoSotto),
            viewPadding:
                const EdgeInsets.only(top: bordoSopra, bottom: bordoSotto),
          ),
          child: MaestroScope(child: child!),
        ),
        home: Scaffold(body: SizedBox(key: chiave)),
      ),
    ));
    mostraInvitoACustodire(chiave.currentContext!, momenti: 3);
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    await tester.tap(find.byKey(const Key('custodia_email')),
        warnIfMissed: false);
    await tester.pumpAndSettle();
  }

  testWidgets('con la tastiera alzata il pulsante non copre il campo',
      (tester) async {
    // **La finestra e' quella di un telefono vero**: col vecchio 800x600 di
    // casa la tastiera lascerebbe un'altezza che nessun telefono ha.
    tester.view.physicalSize = const Size(larghezza * 3, altezza * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await apriIlFoglio(tester, insetto: tastiera);
    expect(find.byKey(const Key('custodia_email_form')), findsOneWidget,
        reason: 'il foglio non si e\' aperto: la prova misurerebbe il vuoto');

    final campo = tester.getRect(find.byKey(const Key('custodia_email_campo')));
    final conferma =
        tester.getRect(find.byKey(const Key('custodia_email_conferma')));
    final piuTardi = tester.getRect(find.byKey(const Key('link_piu_tardi')));
    final foglio = tester.getRect(find.byKey(const Key('custodia_email_form')));
    print('ORDINE EA, tastiera alzata: FOGLIO $foglio');
    print('ORDINE EA, tastiera alzata: campo $campo');
    print('ORDINE EA, tastiera alzata: conferma $conferma');
    print('ORDINE EA, tastiera alzata: piu tardi $piuTardi');

    expect(conferma.overlaps(campo), isFalse,
        reason: 'il pulsante che conferma sta SOPRA il campo dell\'indirizzo: '
            'chi scrive vede sparire quello che ha scritto');
    expect(piuTardi.overlaps(campo), isFalse,
        reason: '"Piu\' tardi" sta sopra il campo dell\'indirizzo');
    expect(conferma.overlaps(piuTardi), isFalse,
        reason: 'i due pulsanti si sovrappongono fra loro');

    // E il campo resta dentro lo schermo, sopra la tastiera.
    final schermo =
        tester.view.physicalSize.height / tester.view.devicePixelRatio;
    expect(campo.bottom, lessThanOrEqualTo(schermo - tastiera),
        reason: 'il campo dell\'indirizzo finisce sotto la tastiera');
    expect(campo.top, greaterThanOrEqualTo(0.0));

    // **E il pulsante si raggiunge.** Un pulsante che non si sovrappone a
    // niente perche' e' finito fuori dal foglio non e' una cura: qui il
    // foglio scorre, e questo lo prova facendolo scorrere per davvero.
    await tester
        .ensureVisible(find.byKey(const Key('custodia_email_conferma')));
    await tester.pumpAndSettle();
    final dopo =
        tester.getRect(find.byKey(const Key('custodia_email_conferma')));
    print('ORDINE EA, conferma dopo lo scorrimento $dopo');
    expect(dopo.bottom, lessThanOrEqualTo(altezza - tastiera),
        reason: 'il pulsante non si raggiunge nemmeno scorrendo');
  });

  testWidgets('e senza tastiera resta come prima', (tester) async {
    // **La seconda meta' della misura**: la cura non deve rompere il caso
    // normale, che e' quello che il fondatore ha gia' guardato a video.
    tester.view.physicalSize = const Size(larghezza * 3, altezza * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await apriIlFoglio(tester, insetto: 0);
    final campo = tester.getRect(find.byKey(const Key('custodia_email_campo')));
    final conferma =
        tester.getRect(find.byKey(const Key('custodia_email_conferma')));
    print('ORDINE EA, senza tastiera: campo $campo, conferma $conferma');
    expect(conferma.overlaps(campo), isFalse);
    expect(conferma.top, greaterThan(campo.bottom),
        reason: 'senza tastiera il pulsante deve stare SOTTO il campo');
  });
}
