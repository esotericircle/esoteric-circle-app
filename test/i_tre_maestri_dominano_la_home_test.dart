import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'monta_la_home.dart';

/// I TRE MAESTRI DOMINANO LA HOME. Ordine BX voce 04.
///
/// **Il fatto del fondatore**: "in home i tre Maestri sono troppo piccoli e le
/// arti che offrono sono poco evidenti", e i fondatori hanno aggiunto che la
/// home al primo impatto sembra eccessiva e che deve risultare evidente che
/// l'app e' anzitutto oroscopo, cartomanzia e rune.
///
/// **LE DUE GRANDEZZE MISURATE, dichiarate prima di misurarle.**
///
/// **Prima: quanto della prima schermata i tre Maestri DIPINGONO.** Non
/// l'altezza del carosello e non il suo rettangolo: le figure escono dal
/// proprio riquadro con `Clip.none`, e l'ordine BA lo ha gia' imparato a
/// caro prezzo. Si dipinge la home, si ridipinge senza la vernice dei
/// Maestri, si contano i pixel che cambiano. **Alla partenza di questa voce
/// erano 87.602 su 329.160, il 26,6 per cento.**
///
/// **Seconda: quanti dei tre dichiarano a schermo le proprie arti.** Alla
/// partenza era UNO, quello al centro: per sapere cosa offrono gli altri due
/// bisognava girare il carosello.
///
/// **Il vincolo che non si tocca**: la copertura del testo del cielo resta
/// sotto i tetti dell'ordine BD, che sorveglia
/// `i_maestri_sui_pixel_e_non_sui_rettangoli`. Ingrandire i Maestri fino a
/// coprire cio' che si legge non sarebbe una cura, sarebbe uno scambio.
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

  Future<ByteData> dipingi(WidgetTester tester) async {
    late ByteData dati;
    await tester.runAsync(() async {
      final ro = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('la_home_intera')));
      final immagine = await ro.toImage(pixelRatio: 1.0);
      dati = (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      immagine.dispose();
    });
    return dati;
  }

  testWidgets('I tre Maestri dipingono almeno il trenta per cento della prima '
      'schermata', (tester) async {
    silenzia();
    maestriSpentiPerLaProva = false;
    addTearDown(() => maestriSpentiPerLaProva = false);
    // Il telefono di riferimento del progetto, 390 per 844.
    await montaLaHomePerLaMisura(tester, (const Size(1170, 2532), 3.0));
    final con = await dipingi(tester);

    // **LA CONTROPROVA DELLA MISURA, come nella prova sorella dell'ordine
    // BA**: due catture identiche devono dare zero differenze, altrimenti si
    // misurerebbe il cosmo che scorre invece dei Maestri.
    final ancora = await dipingi(tester);
    var mossi = 0;
    for (var i = 0; i + 3 < con.lengthInBytes; i += 4) {
      if (con.getUint32(i) != ancora.getUint32(i)) mossi++;
    }
    expect(mossi, 0,
        reason: 'fra due catture identiche cambiano gia\' $mossi pixel: la '
            'scena si muove da sola e la misura direbbe quello');

    maestriSpentiPerLaProva = true;
    await tester.pump(Duration.zero);
    final senza = await dipingi(tester);

    var dipinti = 0;
    var totali = 0;
    for (var i = 0; i + 3 < con.lengthInBytes; i += 4) {
      totali++;
      if (con.getUint32(i) != senza.getUint32(i)) dipinti++;
    }
    final quota = dipinti / totali;
    // ignore: avoid_print
    print('ORDINE BX VOCE 4: i tre Maestri dipingono $dipinti pixel su '
        '$totali, cioe\' il ${(quota * 100).toStringAsFixed(1)} per cento '
        'della prima schermata; alla partenza era il 26,6');
    expect(quota, greaterThanOrEqualTo(0.30),
        reason: 'i tre Maestri dipingono solo il '
            '${(quota * 100).round()} per cento della prima schermata: sono '
            'tornati piccoli come li ha visti il fondatore');
  });

  testWidgets('Tutti e tre dicono le proprie arti, senza girare il carosello',
      (tester) async {
    silenzia();
    maestriSpentiPerLaProva = false;
    addTearDown(() => maestriSpentiPerLaProva = false);
    await montaLaHomePerLaMisura(tester, (const Size(1170, 2532), 3.0));
    final schermo = tester.view.physicalSize / tester.view.devicePixelRatio;

    // Le arti del Maestro al centro, per esteso.
    final centro = find.byKey(const Key('santuario_domain_arts'));
    expect(centro, findsOneWidget,
        reason: 'la riga delle arti del Maestro al centro non c\'e\' piu\'');

    // E il nome breve delle arti degli altri due, uno per Maestro.
    final detti = <String>[];
    for (final m in Maestro.fixedOrder) {
      final f = find.byKey(Key('santuario_arti_${m.id}'));
      if (f.evaluate().isEmpty) continue;
      final r = tester.getRect(f);
      // Vale solo cio' che si vede davvero dentro lo schermo.
      if (r.top < 0 || r.bottom > schermo.height) continue;
      if (r.left < 0 || r.right > schermo.width) continue;
      final testo = tester.widget<Text>(f).data ?? '';
      if (testo.trim().isEmpty) continue;
      detti.add('${m.id}=$testo');
    }
    final quanti = detti.length + 1;
    // ignore: avoid_print
    print('ORDINE BX VOCE 4: a schermo dichiarano le proprie arti $quanti '
        'Maestri su tre; i due di lato dicono $detti; alla partenza era uno');
    expect(quanti, 3,
        reason: 'solo $quanti Maestri su tre dicono cosa offrono: per sapere '
            'le altre arti bisogna ancora girare il carosello');

    // **E NON SONO TRONCATI.** Il primo tentativo metteva due parole per
    // lato e a schermo si leggeva "Orosco...": una prova che conta i testi
    // non vede i puntini, quindi qui si guarda la larghezza vera contro
    // quella che il testo chiederebbe.
    for (final m in Maestro.fixedOrder) {
      final f = find.byKey(Key('santuario_arti_${m.id}'));
      if (f.evaluate().isEmpty) continue;
      final widget = tester.widget<Text>(f);
      final pittore = TextPainter(
        text: TextSpan(text: widget.data, style: widget.style),
        textDirection: TextDirection.ltr,
      )..layout();
      final vera = tester.getRect(f).width;
      // ignore: avoid_print
      print('ORDINE BX VOCE 4: "${widget.data}" chiede '
          '${pittore.width.toStringAsFixed(1)} punti e ne ha '
          '${vera.toStringAsFixed(1)}');
      expect(vera + 0.5, greaterThanOrEqualTo(pittore.width),
          reason: 'il nome delle arti di ${m.id} e\' troncato a schermo: tre '
              'puntini al posto di meta\' parola sono peggio del silenzio');
    }
  });
}
