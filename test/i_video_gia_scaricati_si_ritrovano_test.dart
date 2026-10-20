import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/i_video_del_cammino_scaricati.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_segno_che_risponde.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **I VIDEO GIA' SCARICATI SI RITROVANO DOPO UN RIAVVIO.** Ordine FZ voce
/// FZ.06: *"si scaricano ... solo quando servono ... poi restano in cache"*.
///
/// **Il fatto**, dalla simulazione da persona del 20 ottobre 2026:
/// `IVideoDelCamminoScaricati.leggiIInstallati()` non lo chiamava nessuno.
/// A ogni riavvio l'app dimenticava i video sul disco: il segno li
/// riscaricava, e senza rete non li trovava mai (restava la posa). Padre:
/// ordine FZ voce FZ.06.
///
/// **Cosa misura**: con un video del Lupo gia' sul disco e un elenco appena
/// nato (cioe' un'app appena riaperta), il segno del Lupo lo ritrova e non
/// chiede nessuno scaricamento.
class _VideoDaDisco extends IVideoDelCamminoScaricati {
  _VideoDaDisco(Directory dir) : super(cartella: () async => dir);
  int scaricati = 0;

  @override
  Future<EsitoDelDownload> scaricaAnimale(String nome,
      {void Function(int fatti, int totali)? avanzamento,
      AnnullaDownload? annulla}) async {
    scaricati++;
    return EsitoDelDownload.nonRiuscito;
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'IL SEGNO DEL LUPO, CON IL VIDEO GIA\' SUL DISCO E L\'APP APPENA '
      'RIAPERTA, LO RITROVA E NON LO RISCARICA', (tester) async {
    final dir = Directory.systemTemp.createTempSync('video_cammino_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final lupo = Directory('${dir.path}/viaggio_sciamano/lupo')
      ..createSync(recursive: true);
    File('${lupo.path}/installato.json').writeAsStringSync(jsonEncode({
      'file': {
        'arrivo': 'lupo_arrivo_v1.mp4',
        'centro': 'lupo_centro_v1.mp4',
        'uscita': 'lupo_uscita_v1.mp4',
        'posa': 'lupo_posa_v1.webp',
      },
      'fineUscita': null,
      'scenaVuota': null,
    }));
    final video = _VideoDaDisco(dir);
    expect(video.installato('lupo'), isFalse,
        reason: 'l\'elenco appena nato sa gia\' del disco: la prova non '
            'simula un riavvio');
    final animale = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        home: MaestroScope(
          child: Scaffold(
            body: IlSegnoCheRisponde(
              animale: animale,
              palette: MaestroPalette.caligo,
              siPuoChiedere: false,
              quandoTorna: '',
              chiedi: (_) async => throw StateError('non si chiede'),
              quandoTorni: () {},
              quandoNutri: () {},
              videoScaricati: video,
            ),
          ),
        ),
      ),
    ));
    // **IL DISCO E' VERO**: si lascia correre l'ingresso e uscita e si
    // svuotano le code, qualche giro.
    for (var i = 0; i < 10 && !video.installato('lupo'); i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    expect(video.installato('lupo'), isTrue,
        reason: 'il segno non ha riletto dal disco il video gia\' scaricato');
    expect(video.scaricati, 0,
        reason: 'il video gia\' sul disco si riscarica a ogni riapertura');
  });
}
