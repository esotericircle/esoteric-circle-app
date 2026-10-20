import 'dart:async';

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/horoscope/la_scena_dell_oroscopo.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL VIDEO CHE ARRIVA TARDI NON RINASCONDE IL RESTO.** Ordine GA voce 11,
/// 20 ottobre 2026, difetto 3 della ricognizione.
///
/// Dalla build 2314 la regia comune delle scene, passata l'attesa massima
/// senza un video pronto, mostrava il resto della schermata (giusto, FXA.08),
/// ma se il video arrivava pronto dopo, rimetteva la scena "in corso": il
/// resto gia' comparso spariva (la Porta della Sinastria VIP, che legge
/// `ferma` senza aggancio; la Chat senza messaggi), il video copriva le
/// carte, e il velo del tocco che salta si stendeva sopra pulsanti che la
/// persona stava gia' toccando, mangiandole il tocco.
///
/// Padre (Regola C): ordine FY, commit `8ac4f41c` ("l'attesa della scena a
/// 12 secondi col video tardivo che parte").
class _LettoreLento implements LettoreDiScena {
  final _apertura = Completer<void>();
  VoidCallback? _ascolta;
  bool _pronto = false;
  int avvii = 0;

  /// Il video si prepara adesso, dopo l'attesa massima.
  void prontoAdesso() {
    _pronto = true;
    _apertura.complete();
    _ascolta?.call();
  }

  @override
  Future<void> apri() => _apertura.future;
  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;
  @override
  Future<void> volume(double quanto) async {}
  @override
  Future<void> avvia() async => avvii++;
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox.shrink();
  @override
  void chiudi() {}
}

/// Una schermata con la scena, montata come la Porta della Sinastria VIP:
/// il resto si vede quando la scena e' ferma, e il velo del tocco che salta
/// sta sopra tutto mentre il video gira.
class _Schermata extends StatefulWidget {
  const _Schermata(this.regia);
  final RegiaDellaScena regia;

  @override
  State<_Schermata> createState() => _SchermataState();
}

class _SchermataState extends State<_Schermata> {
  @override
  void initState() {
    super.initState();
    widget.regia.addListener(_cambia);
  }

  void _cambia() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.regia.avvia(context);
  }

  @override
  void dispose() {
    widget.regia.removeListener(_cambia);
    widget.regia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IlToccoCheSalta(
      inCorso: widget.regia.inCorso,
      onSalta: widget.regia.salta,
      child: Center(
        child: widget.regia.ferma
            ? const Text('il resto', textDirection: TextDirection.ltr)
            : const SizedBox.shrink(),
      ),
    );
  }
}

void main() {
  testWidgets(
      'passata l\'attesa il resto compare, e un video pronto dopo non lo '
      'rinasconde ne\' gli prende i tocchi', (tester) async {
    final lettore = _LettoreLento();
    final regia = RegiaDellaScena(() => lettore);
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: Directionality(
          textDirection: TextDirection.ltr, child: _Schermata(regia)),
    ));

    expect(find.text('il resto'), findsNothing,
        reason: 'mentre il video si prepara il resto aspetta');
    await tester.pump(RegiaDellaScena.attesaMassima);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('il resto'), findsOneWidget,
        reason: 'passata l\'attesa massima il resto non e\' comparso');

    // La persona legge e comincia a toccare. Il video arriva adesso.
    await tester.pump(const Duration(seconds: 2));
    lettore.prontoAdesso();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('il resto'), findsOneWidget,
        reason: 'il video arrivato dopo l\'attesa ha rinascosto il resto '
            'che la persona stava gia\' leggendo');
    expect(regia.ferma, isTrue);
    expect(find.byKey(const Key('il_tocco_che_salta')), findsNothing,
        reason: 'il velo del tocco che salta e\' tornato sopra un resto gia\' '
            'comparso: il prossimo tocco della persona non arriva ai pulsanti');
    expect(lettore.avvii, 0,
        reason: 'il video e\' partito sopra un resto gia\' comparso');
  });

  testWidgets('un video pronto entro l\'attesa parte come sempre',
      (tester) async {
    // La meta' buona della cura dell'ordine FY resta: dentro l'attesa il
    // video parte. Qui il video era pronto a sei secondi, dentro i dodici
    // dell'ordine FY; dalla decisione del fondatore del 20 ottobre 2026
    // l'attesa e' di quattro, e il video pronto in tempo arriva a tre.
    final lettore = _LettoreLento();
    final regia = RegiaDellaScena(() => lettore);
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: Directionality(
          textDirection: TextDirection.ltr, child: _Schermata(regia)),
    ));
    await tester.pump(const Duration(seconds: 3));
    lettore.prontoAdesso();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(lettore.avvii, 1,
        reason: 'il video pronto in tempo non e\' partito');
    expect(regia.inCorso, isTrue);
    expect(find.text('il resto'), findsNothing);
  });

  // **L'ATTESA TORNA A QUATTRO SECONDI, POI LA POSA DEL MAESTRO.** Decisione
  // del fondatore del 20 ottobre 2026, alla lettera: "l'attesa delle scene
  // torna a 4 secondi, poi la scena ferma con la posa del Maestro." Si
  // misura su un palco vero, quello dell'Oroscopo (la scena di Medora col
  // suo primo e il suo ultimo fotogramma): prima dei quattro secondi il
  // primo fotogramma che aspetta il video, dopo la posa ferma, e un video
  // pronto a sei secondi non parte.
  testWidgets(
      'l\'attesa e\' di quattro secondi, poi la scena ferma con la posa del '
      'Maestro', (tester) async {
    expect(RegiaDellaScena.attesaMassima, const Duration(seconds: 4),
        reason: 'il fondatore: "l\'attesa delle scene torna a 4 secondi"');
    final lettore = _LettoreLento();
    final regia = RegiaDellaScena(() => lettore);
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: Directionality(
          textDirection: TextDirection.ltr, child: _IlPalco(regia)),
    ));
    const primo = Key('oroscopo_scena_primo_fotogramma');
    const posa = Key('oroscopo_scena_ferma');
    await tester.pump(const Duration(milliseconds: 3900));
    expect(find.byKey(primo), findsOneWidget,
        reason: 'prima dei quattro secondi la scena aspetta il video');
    expect(find.byKey(posa), findsNothing);
    expect(regia.ferma, isFalse,
        reason: 'la scena si e\' arresa prima dei quattro secondi');
    await tester.pump(const Duration(milliseconds: 200));
    expect(regia.ferma, isTrue,
        reason: 'passati i quattro secondi la scena non e\' ferma');
    expect(find.byKey(posa), findsOneWidget,
        reason: 'passati i quattro secondi non si vede la posa ferma del '
            'Maestro');
    expect(find.byKey(primo), findsNothing);
    // Il video arriva pronto a sei secondi: resta fermo, la posa resta.
    await tester.pump(const Duration(seconds: 2));
    lettore.prontoAdesso();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(lettore.avvii, 0, reason: 'il video tardivo e\' partito');
    expect(find.byKey(posa), findsOneWidget);
    expect(find.byKey(const Key('oroscopo_scena_filmato')), findsNothing);
  });
}

/// Il palco dell'Oroscopo con la sua regia, avviata come la avvia la
/// schermata vera.
class _IlPalco extends StatefulWidget {
  const _IlPalco(this.regia);
  final RegiaDellaScena regia;

  @override
  State<_IlPalco> createState() => _IlPalcoState();
}

class _IlPalcoState extends State<_IlPalco> {
  @override
  void initState() {
    super.initState();
    widget.regia.addListener(_cambia);
  }

  void _cambia() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.regia.avvia(context);
  }

  @override
  void dispose() {
    widget.regia.removeListener(_cambia);
    widget.regia.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IlPalcoDellOroscopo(
        regia: widget.regia,
        palette: MaestroPalette.medora,
        emblemaAlCentro: null,
        alCentroUnEmblema: false,
        emblemiDelleSedi: null,
        emblemiAccesi: false,
        dissolvenzaDegliEmblemi: Duration.zero,
        scura: false,
        letturaAnimata: false,
      );
}
