import 'dart:async';

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
    // La meta' buona della cura dell'ordine FY resta: il Realme a freddo
    // chiede piu' di quattro secondi, e dentro l'attesa il video parte.
    final lettore = _LettoreLento();
    final regia = RegiaDellaScena(() => lettore);
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(390, 844)),
      child: Directionality(
          textDirection: TextDirection.ltr, child: _Schermata(regia)),
    ));
    await tester.pump(const Duration(seconds: 6));
    lettore.prontoAdesso();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(lettore.avvii, 1,
        reason: 'il video pronto in tempo non e\' partito');
    expect(regia.inCorso, isTrue);
    expect(find.text('il resto'), findsNothing);
  });
}
