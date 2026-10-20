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
///
/// **Dal 20 ottobre 2026, col manifesto v2 e il pezzo `volta`**, il video
/// "gia' sul disco" e' quello della v2: il Lupo della v1, che non ha il
/// pezzo volta, si ritrova ma chiede l'aggiornamento (la prova accanto).
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

/// Il segno `installato.json` del Lupo come lo scrive la [versione] del
/// manifesto: la v2 (20 ottobre 2026) aggiunge il pezzo `volta` e la
/// versione; quello della v1 non la scriveva.
Directory _lupoSulDisco({required int versione}) {
  final dir = Directory.systemTemp.createTempSync('video_cammino_');
  final lupo = Directory('${dir.path}/viaggio_sciamano/lupo')
    ..createSync(recursive: true);
  File('${lupo.path}/installato.json').writeAsStringSync(jsonEncode({
    'file': {
      'arrivo': 'lupo_arrivo_v1.mp4',
      'centro': 'lupo_centro_v1.mp4',
      if (versione >= 2) 'volta': 'lupo_volta_v2.mp4',
      'uscita': versione >= 2 ? 'lupo_uscita_v2.mp4' : 'lupo_uscita_v1.mp4',
      'posa': 'lupo_posa_v1.webp',
    },
    'fineUscita': null,
    'scenaVuota': null,
    if (versione >= 2) 'versione': versione,
  }));
  return dir;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> apriIlSegno(
      WidgetTester tester, IVideoDelCamminoScaricati video) async {
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
  }

  testWidgets(
      'UN LUPO DELLA V1 SUL DISCO NON E\' AGGIORNATO: il segno lo ritrova e '
      'chiede la v2, che porta il pezzo volta', (tester) async {
    final dir = _lupoSulDisco(versione: 1);
    addTearDown(() => dir.deleteSync(recursive: true));
    final video = _VideoDaDisco(dir);
    await apriIlSegno(tester, video);
    for (var i = 0; i < 10 && video.scaricati == 0; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }
    expect(video.installato('lupo'), isTrue,
        reason: 'il Lupo della v1 resta buono senza rete');
    expect(video.scaricati, 1,
        reason: 'un Lupo senza il pezzo volta non chiede l\'aggiornamento: '
            '"si volta" resterebbe sulla posa per sempre');
  });

  testWidgets(
      'IL SEGNO DEL LUPO, CON IL VIDEO GIA\' SUL DISCO E L\'APP APPENA '
      'RIAPERTA, LO RITROVA E NON LO RISCARICA', (tester) async {
    final dir = _lupoSulDisco(versione: 2);
    addTearDown(() => dir.deleteSync(recursive: true));
    final video = _VideoDaDisco(dir);
    expect(video.installato('lupo'), isFalse,
        reason: 'l\'elenco appena nato sa gia\' del disco: la prova non '
            'simula un riavvio');
    await apriIlSegno(tester, video);
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
