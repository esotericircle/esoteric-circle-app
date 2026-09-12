import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/identity/identity_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/rivelazione_in_video.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/onboarding/maestro_reveal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// L'IMPALCATURA MINIMA ATTORNO ALLA RIVELAZIONE DEL MAESTRO.
///
/// **Perche' esiste, ed e' il costo della voce BR.01.** Finche' il video stava
/// dentro la carta, le prove montavano la carta e nient'altro: due righe di
/// `MediaQuery` e via. Da quando il filmato e' lo sfondo della SCHERMATA, la
/// misura deve montare la schermata, e la schermata legge due controller dal
/// contesto. Scritta in ogni file di prova, questa impalcatura avrebbe
/// divergito al primo controller aggiunto; qui vive in un punto solo.
///
/// Non finge niente: sono i controller veri, quelli che l'app monta in
/// `app.dart`, allo stato iniziale.
Widget attornoAllaRivelazione(Widget scena, {bool riduciMovimento = false}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => IdentityController()),
      ChangeNotifierProvider(create: (_) => NatalChartController()),
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => ParallaxController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: riduciMovimento),
        child: MaestroScope(child: Scaffold(body: scena)),
      ),
    ),
  );
}

/// LO SCHERMO SU CUI L'ORDINE BR DA' I SUOI NUMERI: 360 per 797 punti logici,
/// il telefono di riferimento di Mauro.
///
/// **Si pinna, non si eredita.** La finestra predefinita di una prova e'
/// 800x600, che nessuno ha in tasca: una misura presa li' non dice niente di
/// cio' che si vede, e questo repository lo ha gia' pagato una volta.
const Size schermoDiRiferimento = Size(360, 797);

void pinnaLoSchermo(WidgetTester tester, {Size misura = schermoDiRiferimento}) {
  tester.view.physicalSize = misura;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// IL RITO DEL SOFFIO, PORTATO A TERMINE COL DITO.
///
/// La Rivelazione non si apre da sola: senza il gesto la carta col Maestro non
/// compare e il filmato non nasce, quindi ogni misura nascerebbe cieca. Un
/// trascinamento solo, lungo abbastanza da riempire il progresso in un colpo.
Future<void> svelaIlMaestro(WidgetTester tester) async {
  await tester.drag(find.byType(MaestroRevealScreen), const Offset(0, 1200));
  await tester.pump();
  await tester.pump();
}

/// IL BANCO DEI LETTORI FINTI: chi nasce, chi muore, cosa gli e' stato chiesto.
///
/// **Perche' le misure passano da un lettore finto.** In una prova headless non
/// c'e' nessuna piattaforma che decodifichi un filmato, quindi col lettore vero
/// ogni misura sarebbe stata "il video non parte": il ritardo di avvio, il
/// fermo sull'ultimo fotogramma e i lettori liberati non si sarebbero potuti
/// misurare affatto. Il finto sta dietro la stessa porta del vero, quindi cio'
/// che si misura e' il comportamento della SCENA, non quello del lettore.
class BancoDeiLettori {
  final List<String> chiesti = [];
  final List<LettoreFinto> vivi = [];
  int nati = 0;
  int chiusi = 0;
  int aperti = 0;

  LettoreDiRivelazione crea(String asset) {
    chiesti.add(asset);
    nati++;
    final l = LettoreFinto(this);
    vivi.add(l);
    return l;
  }

  /// Un lettore che non ce la fa mai: il file non c'e', oppure il codec e'
  /// rifiutato. Non lancia, dichiara solo che non e' pronto.
  LettoreDiRivelazione creaCieco(String asset) {
    chiesti.add(asset);
    nati++;
    final l = LettoreFinto(this)..cieco = true;
    vivi.add(l);
    return l;
  }
}

class LettoreFinto implements LettoreDiRivelazione {
  LettoreFinto(this.banco);

  final BancoDeiLettori banco;
  bool cieco = false;

  @override
  bool pronto = false;
  bool _finito = false;
  int riavvii = 0;
  VoidCallback? _quandoCambia;

  @override
  bool get finito => _finito;

  @override
  Future<void> apri() async {
    if (banco.aperti > 0) riavvii++;
    banco.aperti++;
    if (!cieco) pronto = true;
    _quandoCambia?.call();
  }

  void finisci() {
    _finito = true;
    _quandoCambia?.call();
  }

  @override
  void ascolta(VoidCallback quandoCambia) => _quandoCambia = quandoCambia;

  /// Un rettangolo riconoscibile: le prove lo cercano per tipo, cosi' sanno
  /// dire se il velo sta disegnando qualcosa oppure il nulla.
  @override
  Widget disegna() => const ColoredBox(color: Color(0xFF000000));

  @override
  void chiudi() {
    banco.chiusi++;
    banco.vivi.remove(this);
    _quandoCambia = null;
  }
}
