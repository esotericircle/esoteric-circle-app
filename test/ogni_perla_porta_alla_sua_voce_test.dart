import 'dart:math' as math;

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/disegno_del_sentiero.dart';
import 'package:esoteric_circle/features/sigilli/la_mappa_del_sentiero.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:esoteric_circle/core/sigilli/ancoraggi_dei_sentieri.dart';
import 'package:esoteric_circle/features/sigilli/journal_dall_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// OGNI PERLA PORTA ALLA SUA VOCE. Ordine AV voce 04.
///
/// **Il fatto del fondatore**: "le perle grandi di ogni sentiero non
/// funzionano: se faccio click si illuminano di piu' ma non portano a nessun
/// traguardo nell'elenco piu' sotto".
///
/// **Non e' il difetto del tocco che l'ordine AU voce 09 ha chiuso**: il tocco
/// arriva e la perla si illumina. Manca il collegamento fra la perla e la sua
/// voce.
///
/// **La causa, misurata leggendo il codice prima di provarlo**: l'elenco sotto
/// il disegno costruisce `Sentieri.miniDi(...)`, cioe' i CINQUANTA mini. I
/// cinque grandi non hanno una riga, quindi non hanno una chiave, quindi
/// `offsetDelTraguardo` non trova niente e lo scorrimento non parte.
///
/// **L'ordine chiede di verificare anche le altre invece di assumere di no**, e
/// per questo qui si enumera: cinquantacinque perle per tre sentieri,
/// centosessantacinque tocchi.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<DiarioDelCammino> monta(
      WidgetTester tester, Sentiero sentiero) async {
    silenzia();
    SharedPreferences.setMockInitialValues(const {});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    // Tutto acceso: cosi' ogni voce esiste e ogni perla e' viva, e il difetto
    // non si puo' nascondere dietro un traguardo spento.
    for (final t in Sentieri.di(sentiero)) {
      await diario.accendi(t.id);
    }
    // Nel sentiero si e' gia' entrati: la mappa dell'ordine AU voce 13 si apre
    // da sola al primo ingresso e coprirebbe il disegno che qui si tocca.
    await LaMappaDelSentiero.segnaLIngresso(sentiero);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) =>
            MaestroScope(maestro: sentiero.maestro, child: child!),
        home: SentieroScreen(sentiero: sentiero, senzaVolo: true),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    return diario;
  }

  /// **DOVE STA IL CENTRO DI QUELLA PERLA, in coordinate di schermo.**
  ///
  /// **Il punto da toccare e' l'ANCORAGGIO, non la geometria procedurale.** Dal
  /// 16 agosto 2026 il Journal dall'arte e' acceso e il tocco vive sugli
  /// ancoraggi delle perle DIPINTE; l'arte e' montata con `BoxFit.contain`,
  /// quindi il punto si riporta sulla tela con la stessa scala centrata che usa
  /// chi disegna. **La prima stesura di questa prova moltiplicava la posizione
  /// per la larghezza della tela e basta**, e toccava un petalo qualunque:
  /// dichiarava cinquanta perle scollegate su cinquantacinque, cioe' accusava
  /// anche quelle sane.
  Offset? centroDellaPerla(WidgetTester tester, Sentiero sentiero, int indice) {
    final ancoraggi = AncoraggiDeiSentieri.di(sentiero);
    if (ancoraggi == null || indice >= ancoraggi.length) return null;
    final ancora = ancoraggi[indice];
    final trovati = find.byKey(const Key('sentiero_disegno')).evaluate();
    if (trovati.isEmpty) return null;
    final tela = trovati.first.renderObject! as RenderBox;
    if (!tela.hasSize || !tela.attached) return null;
    final origine = tela.localToGlobal(Offset.zero);
    final wArte = ArteDelSentiero.larghezzaArte(sentiero).toDouble();
    final hArte = ArteDelSentiero.altezzaArte(sentiero).toDouble();
    final scala =
        math.min(tela.size.width / wArte, tela.size.height / hArte);
    return origine +
        Offset((tela.size.width - wArte * scala) / 2 + ancora.x * wArte * scala,
            (tela.size.height - hArte * scala) / 2 + ancora.y * hArte * scala);
  }

  /// L'ordine in cui gli ancoraggi sono elencati: quello del cammino.
  List<Traguardo> nellOrdineDegliAncoraggi(Sentiero sentiero) =>
      Sentieri.di(sentiero).toList()
        ..sort((a, b) =>
            Sentieri.ordineNelCammino(a).compareTo(Sentieri.ordineNelCammino(b)));

  for (final sentiero in Sentiero.values) {
    testWidgets('su ${sentiero.name} tutte e 55 le perle portano alla propria '
        'voce', (tester) async {
      await monta(tester, sentiero);
      final ordinati = nellOrdineDegliAncoraggi(sentiero);
      expect(ordinati, hasLength(55));

      final scollegate = <String>[];
      final grandiScollegate = <String>[];
      for (var indice = 0; indice < ordinati.length; indice++) {
        final traguardo = ordinati[indice];
        // **SI TORNA IN CIMA PRIMA DI OGNI TOCCO.** Dopo il primo, l'elenco
        // scorre e la tela del disegno esce di vista: senza questo la prova
        // misurerebbe se stessa, e infatti la prima stesura dichiarava
        // "la tela non c e" su quaranta perle su cinquantacinque.
        final scorrevoli = find.byType(Scrollable).evaluate();
        if (scorrevoli.isNotEmpty) {
          final posizione =
              (scorrevoli.last.widget as Scrollable).controller?.position;
          if (posizione != null && posizione.pixels != 0) {
            posizione.jumpTo(0);
            await tester.pump();
          }
        }
        final dove = centroDellaPerla(tester, sentiero, indice);
        if (dove == null) {
          scollegate.add('${traguardo.id}: la tela non c e');
          continue;
        }
        await tester.tapAt(dove);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        // **SI GUARDA DOVE E' ANDATO L'ELENCO, non se la perla si illumina.**
        // Il fondatore dice proprio questo: la perla si illumina e l'elenco
        // non si muove. La voce deve essere a schermo dopo il tocco.
        final riga = find.byKey(Key('gradino_${traguardo.id}'));
        final ci = riga.evaluate().isNotEmpty;
        var visibile = false;
        if (ci) {
          final scatola = riga.evaluate().first.renderObject;
          if (scatola is RenderBox && scatola.hasSize && scatola.attached) {
            final cima = scatola.localToGlobal(Offset.zero).dy;
            final alto = tester.view.physicalSize.height /
                tester.view.devicePixelRatio;
            visibile = cima > -scatola.size.height && cima < alto;
          }
        }
        if (!visibile) {
          scollegate.add(traguardo.id);
          if (traguardo.eGrande) grandiScollegate.add(traguardo.id);
        }
      }
      // ignore: avoid_print
      print('ORDINE AV VOCE 04: ${sentiero.name}, perle scollegate '
          '${scollegate.length} su 55, di cui grandi '
          '${grandiScollegate.length}'
          '${scollegate.isEmpty ? "" : ": ${scollegate.take(8).join(", ")}"}');
      expect(scollegate, isEmpty,
          reason: 'su ${sentiero.name} queste perle non portano alla propria '
              'voce, e sono ${scollegate.length}: $scollegate');
    });
  }

  test('l elenco del sentiero contiene tutti e 55 i traguardi', () {
    // **LA CAUSA, sorvegliata alla radice.** Finche' l'elenco costruisce solo
    // i mini, i cinque grandi non hanno una riga a cui portare, e nessuna cura
    // sul tocco puo' rimediare.
    for (final sentiero in Sentiero.values) {
      final tutti = Sentieri.di(sentiero);
      final mini = Sentieri.miniDi(sentiero);
      final grandi = Sentieri.grandiDi(sentiero);
      expect(mini.length + grandi.length, tutti.length,
          reason: 'i mini piu i grandi non fanno il sentiero intero');
      expect(grandi, hasLength(5));
      expect(mini, hasLength(50));
    }
  });

  test('la geometria e l elenco nominano gli stessi traguardi', () {
    for (final sentiero in Sentiero.values) {
      final nelDisegno = GeometriaDelSentiero.punti(sentiero)
          .map((p) => p.traguardo.id)
          .toSet();
      final nelSentiero = Sentieri.di(sentiero).map((t) => t.id).toSet();
      expect(nelDisegno.difference(nelSentiero), isEmpty,
          reason: 'il disegno di ${sentiero.name} ha punti che il sentiero non '
              'conosce');
      expect(nelSentiero.difference(nelDisegno), isEmpty,
          reason: 'il sentiero di ${sentiero.name} ha traguardi che il disegno '
              'non mostra');
    }
  });
}

/// Non usata, ma tenuta perche' la misura del centro dipende da lei: se un
/// domani la tela cambiasse proporzione, il conto qui sopra andrebbe rifatto
/// con la stessa scala che usa il pittore.
double scalaDellaTela(Size tela, double lato) =>
    math.min(tela.width / lato, tela.height / lato);
