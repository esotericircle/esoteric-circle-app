import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/viaggio/i_video_del_cammino_scaricati.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **IL VIDEO DELLA CARTA SI SCARICA MENTRE SI SCOPRE.** Ordine FZ voce
/// FZ.06: *"si scaricano solo quando servono, cioe' il video dell'animale
/// della persona e quelli delle carte che sta scoprendo"*.
///
/// **Il fatto**: il video si scaricava solo nella schermata del segno, che si
/// apre dopo il riconoscimento. Alla rivelazione, quando cade l'ultimo pezzo
/// della carta, il video non c'era mai: la carta restava ferma invece di
/// animarsi (FZ.05) e "Condividi come video" non compariva (FZ.08). Trovato
/// leggendo il codice durante la simulazione da persona del 20 ottobre 2026.
/// Padre: ordine FZ voce FZ.06.
///
/// **Cosa misura**: chi segue un'ombra di cui non ha ancora il video ne
/// chiede lo scaricamento, una volta; chi lo ha gia' non lo richiede.
class _VideoDiProva extends IVideoDelCamminoScaricati {
  _VideoDiProva(this.giaQui);

  final Set<String> giaQui;
  final List<String> chiesti = [];

  @override
  bool installato(String nome) => giaQui.contains(nome);

  @override
  Future<EsitoDelDownload> scaricaAnimale(
    String nome, {
    void Function(int fatti, int totali)? avanzamento,
    AnnullaDownload? annulla,
  }) async {
    chiesti.add(nome);
    throw StateError('senza rete nella prova');
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> finoAllaLente(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // **UNA DISCESA SOLA, COL CAVALLO**: la persona e' in cammino e non ha
    // ancora riconosciuto nessuno, quindi seguendo un'ombra scopre una carta;
    // e il Cavallo, gia' seguito, torna di sicuro fra le nove.
    final diario = DiarioDelloSciamanoDiProva(1, nome: 'Cavallo');
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ViaggioDelloSciamanoScreen(
            userSign: Zodiac.sagittarius,
            now: DateTime(2026, 9, 12, 12),
            diario: diario,
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.text('Una scelta da fare'));
    await tester.tap(find.text('Una scelta da fare'));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
    await tester.tap(find.byKey(const Key('viaggio_scendi')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
    await tester.pump(const Duration(seconds: 1));
    final nebbia = find.byKey(const Key('viaggio_nebbia'));
    for (var i = 0; i < 80 && nebbia.evaluate().isNotEmpty; i++) {
      await tester.drag(nebbia, const Offset(120, 40));
      await tester.pump(const Duration(milliseconds: 60));
    }
    await tester.pump(const Duration(milliseconds: 300));
    final ombra = find.byKey(const Key('viaggio_ombra_Cavallo'));
    expect(ombra, findsOneWidget, reason: 'la nebbia non porta all incontro');
    await tester.tap(ombra);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
      'CHI SEGUE UN\'OMBRA DI CUI NON HA IL VIDEO ne chiede lo scaricamento, '
      'una volta, e un guasto non fa cadere niente', (tester) async {
    final prima = IVideoDelCamminoScaricati.diCasa;
    final finto = _VideoDiProva(const {});
    IVideoDelCamminoScaricati.diCasa = finto;
    addTearDown(() => IVideoDelCamminoScaricati.diCasa = prima);
    await finoAllaLente(tester);
    expect(finto.chiesti, ['Cavallo'],
        reason: 'seguendo il Cavallo il suo video non si scarica: alla '
            'rivelazione la carta non si animera e non si potra condividere '
            'come video');
  });

  testWidgets('CHI HA GIA\' IL VIDEO non lo scarica di nuovo', (tester) async {
    final prima = IVideoDelCamminoScaricati.diCasa;
    final finto = _VideoDiProva(const {'cavallo'});
    IVideoDelCamminoScaricati.diCasa = finto;
    addTearDown(() => IVideoDelCamminoScaricati.diCasa = prima);
    await finoAllaLente(tester);
    expect(finto.chiesti, isEmpty,
        reason: 'il video gia scaricato si richiede di nuovo a ogni discesa');
  });
}
