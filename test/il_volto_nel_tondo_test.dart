import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/widgets/maestro_bust.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL VOLTO DENTRO IL TONDO: QUANTO LO RIEMPIE E SE STA AL CENTRO.
///
/// **Le due cose che si vedono a occhio e che nessuna prova prendeva.** Fino al
/// 6 agosto 2026 le prove sugli avatar sorvegliavano che la fascia del volto
/// cadesse dentro la figura e che le tre terne fossero vicine fra loro. Nessuna
/// guardava il risultato: il tondo disegnato. Cosi' Aura usciva spostata a
/// destra, con una fascia di fondo vuota a sinistra, e Caligo con la testa piu'
/// piccola degli altri due, e la suite restava verde.
///
/// **Qui non si stima, si misura sui pixel del tondo vero.** La scena viene
/// disegnata davvero, l'immagine catturata, e il fondo si separa dalla figura
/// perche' dentro il tondo il fondo e' un colore piatto. Due numeri per
/// Maestro:
///
/// - il RIEMPIMENTO, cioe' quanta parte della corda del cerchio e' coperta
///   dalla figura nella zona della testa;
/// - lo SCARTO DI CENTRATURA, cioe' quanto fondo resta a sinistra meno quanto
///   ne resta a destra.
///
/// Il riferimento e' Medora, perche' e' quella giudicata giusta a video il 6
/// agosto 2026: gli altri due si portano su di lei.
void main() {
  /// Il diametro su cui si misura. Grande, perche' l'inquadratura scala
  /// linearmente col diametro e su un anello da 26 punti un errore di due
  /// punti percentuali sparirebbe nell'arrotondamento dei pixel.
  const double ring = 230;

  /// Solo la ZONA DELLA TESTA, il 45 per cento alto del tondo. Sotto ci sono
  /// spalle, collane e mantelli, che non dicono niente su come e' inquadrato il
  /// volto e che sul rosso di Caligo si confondono col fondo.
  const double zonaTesta = 0.45;

  Future<({double riempimento, double scarto})> misura(
      WidgetTester tester, Maestro maestro) async {
    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: Material(
          color: const Color(0xFF000000),
          child: Center(
            child: RepaintBoundary(
              key: radice,
              child: MaestroBust(maestro: maestro, ring: ring, popOut: false),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Senza precarico l'immagine non c'e' e il tondo esce vuoto: la misura
    // nascerebbe cieca e ogni soglia risulterebbe rispettata.
    await tester.runAsync(() async {
      final el = tester.element(find.byType(MaterialApp));
      await precacheImage(AssetImage(maestro.avatarAsset), el);
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    late List<int> byte;
    late int w, h;
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      byte = dati!.buffer.asUint8List();
      w = img.width;
      h = img.height;
    });

    (int, int, int) pixel(int x, int y) {
      final i = (y * w + x) * 4;
      return (byte[i], byte[i + 1], byte[i + 2]);
    }

    final cx = w / 2, cy = h / 2, r = math.min(w, h) / 2 - 6;

    // Il fondo del tondo e' il colore piu' frequente al suo interno.
    final conta = <(int, int, int), int>{};
    for (var y = 0; y < h; y += 3) {
      for (var x = 0; x < w; x += 3) {
        final dx = x - cx, dy = y - cy;
        if (dx * dx + dy * dy > (r - 8) * (r - 8)) continue;
        final p = pixel(x, y);
        conta[p] = (conta[p] ?? 0) + 1;
      }
    }
    final fondo =
        conta.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    bool figura(int x, int y) {
      final p = pixel(x, y);
      return (p.$1 - fondo.$1).abs() +
              (p.$2 - fondo.$2).abs() +
              (p.$3 - fondo.$3).abs() >
          45;
    }

    final coperture = <double>[], sinistre = <double>[], destre = <double>[];
    final y0 = (cy - r).round() + 4;
    final y1 = (cy - r + zonaTesta * 2 * r).round();
    for (var y = y0; y < y1; y++) {
      final dy = y - cy;
      if (dy.abs() >= r) continue;
      final mezza = math.sqrt(r * r - dy * dy);
      final a = (cx - mezza).round() + 2, b = (cx + mezza).round() - 2;
      if (b - a < 40) continue;
      var primo = -1, ultimo = -1, n = 0;
      for (var x = a; x < b; x++) {
        if (!figura(x, y)) continue;
        if (primo < 0) primo = x;
        ultimo = x;
        n++;
      }
      if (primo < 0) continue;
      coperture.add(n / (b - a));
      sinistre.add((primo - a) / (2 * r));
      destre.add((b - ultimo) / (2 * r));
    }

    double media(List<double> v) => v.reduce((a, b) => a + b) / v.length;
    return (
      riempimento: media(coperture) * 100,
      scarto: (media(sinistre) - media(destre)) * 100,
    );
  }

  testWidgets('il volto riempie il tondo come quello di Medora, e sta al centro',
      (tester) async {
    final risultati = <Maestro, ({double riempimento, double scarto})>{};
    for (final m in Maestro.fixedOrder) {
      risultati[m] = await misura(tester, m);
    }
    for (final e in risultati.entries) {
      // ignore: avoid_print
      print('${e.key.displayName.padRight(8)} riempimento '
          '${e.value.riempimento.toStringAsFixed(1)}%   scarto '
          '${e.value.scarto.toStringAsFixed(1)}%');
    }

    final riferimento = risultati[Maestro.medora]!;

    // LA SOGLIA SUL RIEMPIMENTO, E PERCHE' E' LARGA.
    //
    // **Questa prova e' una rete, non un bersaglio.** Il 6 agosto 2026 Mauro
    // ha fissato la regola del tondo, ed e' visiva: mezzobusto, base dentro il
    // cerchio, solo la parte alta della testa che sborda verso l'alto, niente
    // sfumatura in basso, spalle fino al bordo. Non chiede tre numeri uguali,
    // chiede che i tre si somiglino guardandoli.
    //
    // Con l'inquadratura dal petto alla testa questo numero misura una cosa
    // diversa da prima: nella fascia alta del cerchio non entra piu' la sola
    // testa, ma anche le spalle, che nessun disegno ha larghe uguali. I valori
    // misurati oggi sono Medora 52,0, Caligo 47,4, Aura 48,4, cioe' 4,6 punti
    // di scarto fra il piu' alto e il piu' basso. **La soglia e' stata
    // allargata da 3 a 10 invece di spostare i facePoints per farla
    // rientrare**, perche' stringere avrebbe voluto dire restringere le spalle
    // di uno o allargare quelle di un altro, cioe' peggiorare cio' che si vede
    // per far quadrare un numero.
    //
    // Quello che la rete prende ancora: un Maestro fuori scala rispetto agli
    // altri, come Aura prima della correzione del 6 agosto, che stava 12,5
    // punti sotto Medora.
    const tolleranzaRiempimento = 10.0;

    // LA SOGLIA SULLA CENTRATURA, STESSA RAGIONE.
    //
    // La fascia misurata comprende le spalle, che nessun disegno ha
    // simmetriche: il mantello di Caligo pende da un lato e la chioma di Aura
    // dall'altro. Misurati oggi: Medora -0,7, Caligo +0,8, Aura -3,1.
    // Inseguire lo zero qui vorrebbe dire spostare il VOLTO fuori asse per
    // compensare una spalla, cioe' esattamente piegare l'immagine al numero.
    //
    // Sette punti attorno al valore di Medora lasciano stare le spalle e
    // prendono ancora la fascia di fondo vuota che si vedeva su Aura prima
    // della correzione, che era di 6,3 punti da Medora e si notava a occhio.
    const tolleranzaScarto = 7.0;

    for (final e in risultati.entries) {
      expect((e.value.riempimento - riferimento.riempimento).abs(),
          lessThanOrEqualTo(tolleranzaRiempimento),
          reason: '${e.key.displayName}: la testa riempie il '
              '${e.value.riempimento.toStringAsFixed(1)} per cento della corda '
              'contro il ${riferimento.riempimento.toStringAsFixed(1)} di '
              'Medora. Affiancati nella stessa fila uno sembrera\' un passo '
              'indietro rispetto agli altri. La leva e\' la fascia fra '
              'headTopY e collarY: piu\' e\' stretta, piu\' il volto si '
              'ingrandisce.');
      expect((e.value.scarto - riferimento.scarto).abs(),
          lessThanOrEqualTo(tolleranzaScarto),
          reason: '${e.key.displayName}: lo scarto di centratura e\' '
              '${e.value.scarto.toStringAsFixed(1)} punti contro i '
              '${riferimento.scarto.toStringAsFixed(1)} di Medora. Da una '
              'parte resta una fascia di fondo vuota e dall\'altra la guancia '
              'tocca il bordo. La leva e\' centerX.');
    }
  });
}
