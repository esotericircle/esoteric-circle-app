import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/viaggio/il_segno_dell_animale.dart';
import 'package:esoteric_circle/core/viaggio/la_sequenza_del_cammino.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_cammino_dell_animale.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';

/// **IL CAMMINO DELL'ANIMALE: I PEZZI IN ORDINE, LA POSA SOTTO SEMPRE.**
/// Ordine FZ voce FZ.05, 17 ottobre 2026.
///
/// Un lettore finto per percorso, perche' il test comandi ognuno dei pezzi
/// uno alla volta, come il dito li farebbe arrivare sullo schermo vero.
class _Finta implements LettoreDiScena {
  VoidCallback? _ascolta;
  final bool _fallito = false;
  bool _cominciato = false;
  bool _finito = false;
  bool chiusa = false;

  @override
  bool get pronto => true;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;

  @override
  Future<void> apri() async {}
  @override
  Future<void> volume(double quanto) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const ColoredBox(color: Color(0xFF102030));
  @override
  void chiudi() => chiusa = true;

  void comincia() {
    _cominciato = true;
    _ascolta?.call();
  }

  void finisce() {
    _finito = true;
    _ascolta?.call();
  }
}

void main() {
  const scena = Size(390, 844);

  testWidgets(
      'SI AVVICINA: arrivo poi centro, in ordine, e quandoFinisce arriva '
      'solo alla fine del secondo', (tester) async {
    final finte = <String, _Finta>{};
    var finito = 0;
    await tester.pumpWidget(MaterialApp(
      home: SizedBox.fromSize(
        size: scena,
        child: IlCamminoDellAnimale(
          sequenza: LaSequenzaDelCammino.perIlGesto(GestoDelSegno.siAvvicina,
              haFineUscita: false),
          percorsi: const {
            PezzoDelCammino.arrivo: 'lupo_arrivo',
            PezzoDelCammino.centro: 'lupo_centro',
          },
          posa: 'lupo_posa.webp',
          quandoFinisce: () => finito++,
          fabbrica: (p) => finte[p] = _Finta(),
        ),
      ),
    ));
    await tester.pump();
    expect(finte.keys, ['lupo_arrivo'],
        reason: 'il secondo pezzo non deve aprirsi prima che il primo cominci');
    finte['lupo_arrivo']!.comincia();
    await tester.pump();
    expect(find.byKey(const Key('cammino_posa')), findsOneWidget);
    expect(finito, 0);

    finte['lupo_arrivo']!.finisce();
    await tester.pump();
    expect(finte.keys, ['lupo_arrivo', 'lupo_centro'],
        reason: 'finito arrivo, deve aprirsi centro');
    expect(finito, 0, reason: 'c\'e\' ancora un pezzo da fare');

    finte['lupo_centro']!.comincia();
    await tester.pump();
    finte['lupo_centro']!.finisce();
    await tester.pump();
    expect(finito, 1,
        reason: 'finito anche il secondo pezzo, il cammino e\' finito');
    // La giuntura: il vecchio sfuma e poi si chiude.
    await tester.pump(IlCamminoDellAnimale.giuntura +
        const Duration(milliseconds: 50));
    expect(finte['lupo_arrivo']!.chiusa, isTrue,
        reason: 'il pezzo vecchio non si e\' chiuso dopo la giuntura');
  });

  testWidgets(
      'CON RIDUCI MOVIMENTO: nessun lettore si apre, resta la sola posa, '
      'quandoFinisce arriva subito', (tester) async {
    var finito = 0;
    var aperture = 0;
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: SizedBox.fromSize(
          size: scena,
          child: IlCamminoDellAnimale(
            sequenza: LaSequenzaDelCammino.rivelazione,
            percorsi: const {PezzoDelCammino.centro: 'lupo_centro'},
            posa: 'lupo_posa.webp',
            quandoFinisce: () => finito++,
            fabbrica: (p) {
              aperture++;
              return _Finta();
            },
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(aperture, 0,
        reason: 'con Riduci Movimento non si deve aprire nessun video');
    expect(finito, 1);
    expect(find.byKey(const Key('cammino_posa')), findsOneWidget);
  });

  testWidgets(
      'SENZA RETE, NESSUN PEZZO SCARICATO: resta la sola posa e '
      'quandoFinisce arriva subito, senza bloccarsi in attesa di un video '
      'che non arriva', (tester) async {
    var finito = 0;
    await tester.pumpWidget(MaterialApp(
      home: SizedBox.fromSize(
        size: scena,
        child: IlCamminoDellAnimale(
          sequenza: LaSequenzaDelCammino.perIlGesto(GestoDelSegno.siAvvicina,
              haFineUscita: false),
          percorsi: const {},
          posa: 'lupo_posa.webp',
          quandoFinisce: () => finito++,
          fabbrica: (p) => _Finta(),
        ),
      ),
    ));
    await tester.pump();
    expect(finito, 1);
    expect(find.byKey(const Key('cammino_posa')), findsOneWidget);
  });

  testWidgets(
      'SI ALLONTANA CON FINE_USCITA: dopo il pezzo, la scena vuota dissolve '
      'sopra la posa', (tester) async {
    final finte = <String, _Finta>{};
    await tester.pumpWidget(MaterialApp(
      home: SizedBox.fromSize(
        size: scena,
        child: IlCamminoDellAnimale(
          sequenza: LaSequenzaDelCammino.perIlGesto(GestoDelSegno.siAllontana,
              haFineUscita: true),
          percorsi: const {PezzoDelCammino.uscita: 'gufo_uscita'},
          posa: 'gufo_posa.webp',
          scenaVuota: 'uccelli_scena_vuota.jpg',
          fabbrica: (p) => finte[p] = _Finta(),
        ),
      ),
    ));
    await tester.pump();
    expect(find.byKey(const Key('cammino_scena_vuota')), findsNothing);
    finte['gufo_uscita']!.comincia();
    await tester.pump();
    finte['gufo_uscita']!.finisce();
    await tester.pump();
    expect(find.byKey(const Key('cammino_scena_vuota')), findsOneWidget,
        reason: 'finito con fine_uscita, deve apparire la scena vuota');
  });
}
