import 'dart:convert';

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/lunario/il_dial_a_moon.dart';
import 'package:esoteric_circle/core/lunario/il_respiro_della_luna.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/respiro_della_luna/il_respiro_della_luna_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_collana_delle_lune_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/la_geometria_della_luna_dipinta.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sopra_il_filmato.dart';

/// **LA LUNA DI QUEST'ORA E' UNA SOLA, NEL SUO DISCO.** Ordine FX aggiunta
/// FXA.09, 16 ottobre 2026. Il fondatore, sull'anteprima della build 2312:
/// "sul viso c'è un cerchio semitrasparente non ben definito". La foto vera
/// della NASA stava centrata a meta' schermo, sul viso di Medora, mentre
/// l'ultimo fotogramma mostrava la Luna dipinta nel cielo: due Lune.
///
/// Qui si misura dove la foto finisce davvero a schermo contro il disco
/// misurato sulla pittura, rimappato sul taglio vero della scena, a 360 per
/// 797 e a 430 per 932; e che a scena ferma il fondo sia il cielo senza Luna,
/// senza nessun fotogramma che porti la sua Luna dipinta.
///
/// **E PRIMA LA SCENA, POI TUTTO IL RESTO** (FXA.08): mentre il video gira
/// si vede solo il video, poi il resto compare.
///
/// **E NESSUN TESTO COI PUNTINI** (FXA.09, punto 5): a ogni larghezza fra
/// 320 e 430 punti e col testo ingrandito fino a 1,3, nessun paragrafo della
/// schermata supera le sue righe.
class _Piacenza extends SkyLocation {
  const _Piacenza();
  static const _p = SkyPlace(latitude: 45.0526, longitude: 9.693);
  @override
  bool get available => true;
  @override
  Future<SkyPlace?> resolve() async => _p;
  @override
  Future<RispostaPosizione> chiedi() async =>
      const RispostaPosizione(EsitoPosizione.concessa, _p);
  @override
  Future<SkyPlace?> resolveSeConcesso() async => _p;
  @override
  Future<String?> nomeDelLuogo(double latitudine, double longitudine) async =>
      'Piacenza';
}

/// Un video di scena che parte e gira, finche' qualcuno non lo salta.
class _VideoCheGira implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _pronto = false;
  bool _cominciato = false;
  bool _finito = false;

  /// Il video arriva all'ultimo fotogramma.
  void finisci() {
    _finito = true;
    _ascolta?.call();
  }

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => false;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    _pronto = true;
    _cominciato = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const ColoredBox(
      key: Key('finta_del_filmato_del_respiro'), color: Color(0xFF102030));
  @override
  void chiudi() {}
}

IlDialAMoon _offline() =>
    IlDialAMoon(client: MockClient((_) async => http.Response('', 503)));

Widget _host(Widget figlia, {double scala = 1}) => MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scala)),
          child: child!,
        ),
        home: MaestroScope(child: figlia),
      ),
    );

Future<void> _apri(WidgetTester tester, Size misura,
    {double scala = 1, FabbricaDiScena? scena, DateTime? adesso}) async {
  SharedPreferences.setMockInitialValues({'respiro.primaAperturaVista': true});
  tester.view.physicalSize = misura;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_host(
      IlRespiroDellaLunaScreen(
          now: adesso ?? DateTime(2026, 10, 16, 21),
          dialAMoon: _offline(),
          posizione: const _Piacenza(),
          fabbricaDellaScena: scena),
      scala: scala));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 2));
}

/// I nomi degli asset di tutte le immagini montate.
List<String> _assetMontati(WidgetTester tester) => [
      for (final e in find.byType(Image).evaluate())
        if ((e.widget as Image).image is AssetImage)
          ((e.widget as Image).image as AssetImage).assetName,
    ];

void main() {
  for (final misura in const [Size(360, 797), Size(430, 932)]) {
    final nome = '${misura.width.toInt()} per ${misura.height.toInt()}';

    testWidgets('$nome: la Luna vera sta nel disco dipinto', (tester) async {
      await _apri(tester, misura);
      final cielo =
          tester.getRect(find.byKey(const Key('respiro_cielo_senza_luna')));
      final disco = GeometriaDellaLunaDipinta.discoSulloSchermo(cielo.size)
          .shift(cielo.topLeft);
      final foto = tester.getRect(find.byKey(const Key('respiro_luna_vera')));
      // Il centro della foto e' il centro del disco, entro un punto.
      expect((foto.center - disco.center).distance, lessThan(1.0),
          reason: 'la Luna vera $foto esce dal disco dipinto $disco');
      // Il disco della foto (il 93 per cento del suo lato) e' il disco
      // dipinto, entro un punto.
      expect(
          (foto.width * GeometriaDellaLunaDipinta.discoNellaFoto - disco.width)
              .abs(),
          lessThan(1.0),
          reason: 'la Luna vera non ha la misura del disco dipinto');
    });

    testWidgets('$nome: a scena ferma la Luna e\' una sola', (tester) async {
      await _apri(tester, misura);
      final asset = _assetMontati(tester);
      expect(asset.where((a) => a.contains('respiro_cielo_senza_luna')),
          isNotEmpty,
          reason: 'il fondo a scena ferma deve essere il cielo senza Luna');
      final conLaLunaDipinta = asset
          .where((a) =>
              a.contains('respiro_ultimo_fotogramma') ||
              a.contains('respiro_primo_fotogramma'))
          .toList();
      expect(conLaLunaDipinta, isEmpty,
          reason: 'a scena ferma resta un fotogramma con la sua Luna dipinta: '
              'sullo schermo le Lune sono due ($conLaLunaDipinta)');
      expect(find.byKey(const Key('respiro_luna_vera')), findsOneWidget);
    });
  }

  testWidgets('a video in corso si vede solo il video, poi il resto',
      (tester) async {
    late _VideoCheGira video;
    await _apri(tester, const Size(360, 797),
        scena: () => video = _VideoCheGira());
    expect(
        find.byKey(const Key('finta_del_filmato_del_respiro')), findsOneWidget);
    // **NIENTE SOPRA IL VIDEO.** Ogni testo montato nel corpo della scena
    // (fuori dalla barra in alto) dev'essere invisibile o assente.
    final corpo = find.byType(IlToccoCheSalta);
    final visibili = <String>[];
    for (final e
        in find.descendant(of: corpo, matching: find.byType(Text)).evaluate()) {
      final testo = (e.widget as Text).data ?? '';
      double opacita = 1;
      e.visitAncestorElements((a) {
        if (a.widget is Opacity) opacita *= (a.widget as Opacity).opacity;
        return a.widget is! IlToccoCheSalta;
      });
      if (opacita > 0) visibili.add(testo);
    }
    expect(visibili, isEmpty,
        reason: 'a video in corso sopra la scena si leggono: $visibili');
    for (final chiave in const [
      'respiro_luna_vera',
      'luna_righello_del_tempo',
      'luna_i_dati',
      'luna_barra_in_basso',
    ]) {
      expect(find.byKey(Key(chiave)), findsNothing,
          reason: '$chiave copre il video mentre gira');
    }
    // Il tocco salta il video: il resto compare.
    expect(video.cominciato, isTrue);
    await tester.tapAt(const Offset(180, 400));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const Key('respiro_luna_vera')), findsOneWidget);
    expect(find.byKey(const Key('luna_barra_in_basso')), findsOneWidget);
  });

  testWidgets('la consegna della collana: a video in corso niente pannello',
      (tester) async {
    // Un giorno respirato nel ciclo chiuso alla Luna nuova del 10 ottobre
    // 2026: la consegna e' in attesa, e la sua scena parte.
    SharedPreferences.setMockInitialValues({
      'respiro.giorniRespirati':
          jsonEncode([IlRespiroDellaLuna.data(DateTime(2026, 10, 1))]),
    });
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(LaCollanaDelleLuneScreen(
        now: DateTime(2026, 10, 16, 9),
        fabbricaDellaScena: () => _VideoCheGira())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    expect(
        find.byKey(const Key('finta_del_filmato_del_respiro')), findsOneWidget,
        reason: 'la scena della consegna non parte');
    // La prova comune delle scene (FXA.08, `sopra_il_filmato.dart`): sopra
    // il video della consegna niente, finche' gira.
    expect(
        cioCheSiVedeSopraIlFilmato(tester,
            filmato: find.byKey(const Key('finta_del_filmato_del_respiro'))),
        isEmpty,
        reason: 'sopra il video della consegna si vede qualcosa mentre gira');
    expect(find.byKey(const Key('consegna_continua')), findsNothing,
        reason: 'il pulsante della consegna copre il video mentre gira');
    expect(find.textContaining('La tua collana è completa'), findsNothing,
        reason: 'il pannello della consegna copre il video mentre gira');
    await tester.tapAt(const Offset(180, 400));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('consegna_continua')), findsOneWidget);
  });

  for (final larghezza in const [320.0, 360.0, 390.0, 430.0]) {
    for (final scala in const [1.0, 1.3]) {
      testWidgets('nessun testo coi puntini, largo $larghezza, testo a $scala',
          (tester) async {
        await _apri(tester, Size(larghezza, 900), scala: scala);
        final tagliati = <String>[];
        var guardati = 0;
        for (final e in find.byType(RichText).evaluate()) {
          final p = e.renderObject as RenderParagraph?;
          if (p == null || !p.hasSize) continue;
          guardati++;
          if (p.didExceedMaxLines) tagliati.add(p.text.toPlainText());
        }
        // Il cardinale minimo: le righe dei dati, la fase, la citta', la
        // Luna, il righello e la barra fanno ben piu' di venti paragrafi.
        expect(guardati, greaterThan(20),
            reason: 'troppo pochi paragrafi: la prova non guarda niente');
        expect(tagliati, isEmpty, reason: 'testi tagliati: $tagliati');
      });
    }
  }

  // **LA PROVA COMUNE DELLE SCENE** (FXA.08, `soloIlFilmatoFinche`), per
  // le due scene del Respiro: a video in corso sopra non si vede niente, a
  // video finito il resto compare.
  testWidgets('il Respiro: solo il filmato mentre gira', (tester) async {
    late _VideoCheGira video;
    await _apri(tester, const Size(360, 797),
        scena: () => video = _VideoCheGira());
    expect(find.byType(IlRespiroDellaLunaScreen), findsOneWidget);
    await soloIlFilmatoFinche(tester,
        scena: 'il Respiro della Luna',
        filmato: find.byKey(const Key('finta_del_filmato_del_respiro')),
        finisci: () => video.finisci(),
        poi: const Duration(milliseconds: 1500));
  });

  testWidgets('la consegna della collana: solo il filmato mentre gira',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'respiro.giorniRespirati':
          jsonEncode([IlRespiroDellaLuna.data(DateTime(2026, 10, 1))]),
    });
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    late _VideoCheGira video;
    await tester.pumpWidget(_host(LaCollanaDelleLuneScreen(
        now: DateTime(2026, 10, 16, 9),
        fabbricaDellaScena: () => video = _VideoCheGira())));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    await soloIlFilmatoFinche(tester,
        scena: 'la consegna della collana',
        filmato: find.byKey(const Key('finta_del_filmato_del_respiro')),
        finisci: () => video.finisci(),
        poi: const Duration(milliseconds: 800));
  });
}
