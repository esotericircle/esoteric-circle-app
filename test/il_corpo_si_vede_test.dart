import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/ancoraggio.dart';
import 'package:esoteric_circle/core/maestro/consulto_del_cielo.dart';
import 'package:esoteric_circle/core/maestro/corpo_del_consulto.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/components/zodiac_glyph.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL CORPO E' STATO DIPINTO, e lo si misura sui PIXEL.
///
/// **Perche' questa prova esiste.** La prima stesura della scena del consulto
/// mostrava due righe di testo e nient'altro: nessun corpo, nessuna luce. Dieci
/// prove la coprivano, e nessuna se ne accorse, perche' contavano widget e
/// testo. Un test che conta widget non distingue una scena piena da una vuota:
/// e' esattamente cosi' che una scena vuota passa per fatta.
///
/// La misura e' DIFFERENZIALE: si dipinge la scena col corpo e la stessa scena
/// senza, e si contano i pixel che cambiano. Cosi' non si misura il fondo, che
/// c'e' in tutte e due, ma solo cio' che il corpo aggiunge.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La soglia, TARATA SUI NUMERI VERI e non stimata.
  ///
  /// Il corpo occupa un quadrato di [ConsultoDelCieloView.misuraDelCorpo], cioe'
  /// 96 punti logici a rapporto 1, quindi 9.216 pixel disponibili. Misurati il
  /// 2 agosto 2026, col precarico degli asset attivo:
  ///
  ///   disco lunare       9.216 pixel (riempie il quadrato)
  ///   emblema del segno  4.396 pixel
  ///   punto luminoso     1.207 pixel (il caso PIU' POVERO dei tre)
  ///
  /// La soglia si fissa a 700, cioe' poco meno del sessanta per cento del caso
  /// peggiore: abbastanza bassa da non cadere per un antialiasing diverso,
  /// abbastanza alta da non poter essere raggiunta da un'ombra o da due righe di
  /// testo, che era esattamente cio' che la scena mostrava prima.
  ///
  /// **La prima stesura di questa soglia era 1.500, STIMATA a mente su un
  /// calcolo geometrico, e sbagliata**: il punto ne dipinge 1.207, quindi la
  /// prova bocciava un corpo che c'era. Un numero indovinato in un test e' un
  /// difetto quanto un numero indovinato nel codice.
  const sogliaPixel = 700;

  const misura = ConsultoDelCieloView.misuraDelCorpo;

  Widget _monta(Widget figlio) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MaestroScope(
            maestro: Maestro.medora,
            child: Scaffold(
              backgroundColor: const Color(0xFF080B1A),
              body: Center(child: figlio),
            ),
          ),
        ),
      );

  /// Dipinge [figlio] fuori schermo e restituisce i pixel grezzi.
  Future<({Uint8List byte, int larghezza, int altezza})> _dipingi(
    WidgetTester tester,
    Widget figlio,
  ) async {
    final radice = GlobalKey();
    await tester.pumpWidget(_monta(RepaintBoundary(
      key: radice,
      child: SizedBox(
        width: misura,
        height: misura,
        child: figlio,
      ),
    )));
    await tester.pump();
    // PRECARICO OBBLIGATORIO. In prova headless un'immagine non si decodifica
    // se nessuno la mette in cache prima: senza questa riga l'emblema dipinge
    // ZERO pixel e la prova accusa la scena di essere vuota quando invece e'
    // la misura a non vedere. E' lo stesso inciampo gia' costato un'anteprima.
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(MaterialApp));
      for (final segno in Zodiac.values) {
        await precacheImage(AssetImage(ZodiacArt.emblemPath(segno)), ctx);
      }
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    late final Uint8List byte;
    late final int larghezza;
    late final int altezza;
    // TUTTO dentro runAsync: `toByteData` vuole il ciclo di eventi vero, e
    // fuori di qui nel tempo finto non completa mai, cioe' la prova scade
    // invece di fallire.
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 1.0);
      larghezza = img.width;
      altezza = img.height;
      final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      byte = dati!.buffer.asUint8List();
      img.dispose();
    });
    return (byte: byte, larghezza: larghezza, altezza: altezza);
  }

  /// Quanti pixel differiscono fra due immagini della stessa misura.
  int _pixelDiversi(Uint8List a, Uint8List b) {
    var diversi = 0;
    final quanti = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < quanti; i += 4) {
      // Una tolleranza piccola: l'antialiasing non deve contare come differenza
      // ma una forma dipinta si'.
      final dr = (a[i] - b[i]).abs();
      final dg = (a[i + 1] - b[i + 1]).abs();
      final db = (a[i + 2] - b[i + 2]).abs();
      if (dr + dg + db > 12) diversi++;
    }
    return diversi;
  }

  BattutaDelConsulto _battutaCon(Ancoraggio? ancoraggio) =>
      BattutaDelConsulto(
        corpo: 'prova',
        frase: 'prova',
        eGenerale: false,
        ancoraggio: ancoraggio,
      );

  // Enumerati: i tre tipi di corpo che la scena sa dipingere. Campionarne uno
  // solo avrebbe lasciato scoperti gli altri due, e il piu' povero dei tre e'
  // proprio quello che una soglia sbagliata farebbe passare per vuoto.
  final casi = <String, Ancoraggio>{
    'emblema del segno':
        const Ancoraggio(nome: 'segno solare', valore: 'Cancro'),
    'disco lunare': const Ancoraggio(
        nome: 'fase lunare di nascita', valore: 'Luna crescente'),
    'punto luminoso':
        const Ancoraggio(nome: 'numero della vita', valore: '7'),
  };

  for (final caso in casi.entries) {
    testWidgets('Il corpo dipinge davvero: ${caso.key}', (tester) async {
      // Il fondo da solo: la scena senza nessun corpo.
      final vuoto = await _dipingi(
        tester,
        const SizedBox.shrink(),
      );
      // La stessa scena col corpo.
      final pieno = await _dipingi(
        tester,
        CorpoDelConsultoDipinto(
          battuta: _battutaCon(caso.value),
          misura: misura,
          fermo: true,
        ),
      );

      expect(pieno.larghezza, vuoto.larghezza);
      expect(pieno.altezza, vuoto.altezza);

      final dipinti = _pixelDiversi(pieno.byte, vuoto.byte);
      expect(
        dipinti,
        greaterThanOrEqualTo(sogliaPixel),
        reason: 'il corpo "${caso.key}" ha dipinto $dipinti pixel contro una '
            'soglia di $sogliaPixel: a schermo non si vede niente, e una prova '
            'che conta widget non se ne accorgerebbe',
      );
    });
  }

  test('Ogni ancoraggio sa che corpo mostrare, e nessuno resta senza', () {
    // La regola vive nel dato: la vista non sceglie, dipinge cio' che questo
    // oggetto ha gia' deciso.
    expect(
      CorpoDelConsulto.per(
          const Ancoraggio(nome: 'ascendente', valore: 'Vergine')),
      isA<CorpoSegno>(),
    );
    // LA LUNA SI DISEGNA SOLO SE ARRIVA LA SUA MISURA.
    //
    // Senza, la vista sceglieva una mezza luce per conto suo e il disco diceva
    // primo quarto sotto la parola "crescente". Adesso senza misura si cade sul
    // punto luminoso, che e' il ripiego DICHIARATO: mai un disegno inventato.
    expect(
      CorpoDelConsulto.per(
          const Ancoraggio(nome: 'fase lunare di nascita', valore: 'Luna')),
      isA<CorpoPunto>(),
      reason: 'senza la frazione illuminata non si disegna nessuna Luna',
    );
    expect(
      CorpoDelConsulto.per(
        const Ancoraggio(nome: 'fase lunare di nascita', valore: 'Luna'),
        luna: const MoonIllumination(
            fraction: 0.25, waxing: true, elongationDeg: 60),
      ),
      isA<CorpoLuna>(),
    );
    // Un dato vero senza arte NON resta vuoto: un punto, come nel cielo.
    expect(
      CorpoDelConsulto.per(
          const Ancoraggio(nome: 'numero della vita', valore: '7')),
      isA<CorpoPunto>(),
    );
    // E un segno che non si riconosce cade sul punto invece di indovinare.
    expect(
      CorpoDelConsulto.per(
          const Ancoraggio(nome: 'segno solare', valore: 'Ofiuco')),
      isA<CorpoPunto>(),
    );
  });

  test('I dodici segni hanno tutti il loro emblema', () {
    // Enumerati: se domani un segno perdesse la sua arte, il consulto
    // scivolerebbe sul punto senza che nessuno se ne accorga.
    for (final segno in Zodiac.values) {
      final corpo = CorpoDelConsulto.per(
          Ancoraggio(nome: 'segno solare', valore: segno.italianName));
      expect(corpo, isA<CorpoSegno>(),
          reason: '${segno.italianName} non trova il suo emblema');
    }
  });
}
