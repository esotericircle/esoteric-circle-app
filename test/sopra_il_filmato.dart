import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// **SOPRA IL FILMATO SI VEDE SOLO IL FILMATO.** Ordine FX voce FXA.08, 16
/// ottobre 2026. Il fondatore: *"assicurati che tutto venga sovrapposto dopo
/// aver visto il video di scena e non che il Video si veda coperto da
/// riquadri e testi"*.
///
/// **LA PORTA COMUNE DELLE PROVE DI OGNI SCENA.** Chiamata a video in corso,
/// restituisce cio' che si vede sullo schermo e non e' ammesso, una riga per
/// cosa: vuota, la scena e' pulita.
///
/// **COSA MISURA.** Scorre l'albero del disegno nell'ordine in cui si dipinge
/// e raccoglie ogni testo ([RenderParagraph]), ogni campo da scrivere
/// ([RenderEditable]) e ogni immagine ([RenderImage]) che:
/// - sta dentro lo schermo e ha una misura;
/// - non e' sotto un'opacita' nulla o un `Offstage` (cio' che e' nascosto
///   per davvero non si dipinge);
/// - non e' dentro la barra in alto (`AppBar` e le sue azioni, ammesse dalla
///   voce) ne' dentro il filmato stesso;
/// - non e' DIETRO il filmato: una cosa dipinta prima del filmato e tutta
///   dentro il suo riquadro e' coperta da lui, e non si vede; e
///   un'immagine dipinta prima del filmato che copre almeno meta' del suo
///   riquadro e' il fondale della scena (lo sfondo del tavolo della Stesa e'
///   piu' grande del filmato che ci si posa sopra).
///
/// Un pannello, un pulsante, una carta, un numero o una riga del Maestro sono
/// fatti di testi e di immagini: se uno di loro si vede a video in corso, la
/// riga che lo nomina dice quale.
///
/// **I CONTENITORI SENZA TESTO NON LI VEDE.** Un riquadro vuoto, una
/// cornice o un velo colorato senza un testo o un'immagine dentro passano: la
/// grandezza misurata e' cio' che si legge e si riconosce, che e' quello che
/// il fondatore ha nominato (*"riquadri e testi"*), e un riquadro dell'app
/// porta sempre un testo.
List<String> cioCheSiVedeSopraIlFilmato(
  WidgetTester tester, {
  required Finder filmato,
  bool filmatoPreteso = true,
}) {
  final elementiDelFilmato = filmato.evaluate().toList();
  if (filmatoPreteso) {
    expect(elementiDelFilmato, isNotEmpty,
        reason: 'il filmato non e\' in scena: la prova va presa a video in '
            'corso, col filmato cominciato');
  }
  final radiciDelFilmato = <RenderObject>{
    for (final e in elementiDelFilmato) e.renderObject!,
  };
  final radiciDellaBarra = <RenderObject>{
    for (final e in find.byType(AppBar).evaluate())
      if (e.renderObject != null) e.renderObject!,
  };
  final vista = tester.view;
  final schermo = Offset.zero & (vista.physicalSize / vista.devicePixelRatio);

  Rect? riquadroDelFilmato;
  for (final r in radiciDelFilmato) {
    final rr = _riquadro(r);
    riquadroDelFilmato = riquadroDelFilmato == null
        ? rr
        : riquadroDelFilmato.expandToInclude(rr);
  }

  // Il filmato copre cio' che gli sta dietro solo se si vede: sfumato via
  // (saltato, o finito in una scena che lo dissolve) non copre niente.
  var filmatoVisibile = false;
  for (final r in radiciDelFilmato) {
    var acceso = true;
    RenderObject? su = r;
    while (su != null) {
      if (_spento(su)) acceso = false;
      su = su.parent;
    }
    if (acceso) filmatoVisibile = true;
  }

  final trovati = <String>[];
  var filmatoGiaDipinto = false;

  void visita(RenderObject ro, bool nascosto) {
    if (radiciDelFilmato.contains(ro)) {
      filmatoGiaDipinto = true;
      return;
    }
    if (radiciDellaBarra.contains(ro)) return;
    final qui = nascosto || _spento(ro);
    if (!qui &&
        (ro is RenderParagraph || ro is RenderImage || ro is RenderEditable) &&
        ro.attached &&
        (ro is! RenderBox || ro.hasSize)) {
      final r = _riquadro(ro);
      final dentro = r.width > 0.5 &&
          r.height > 0.5 &&
          r.overlaps(schermo) &&
          r.intersect(schermo).width > 0.5 &&
          r.intersect(schermo).height > 0.5;
      final f = riquadroDelFilmato;
      final dentroAlFilmato = f != null &&
          f.inflate(1).contains(r.topLeft) &&
          f.inflate(1).contains(r.bottomRight);
      // LO SFONDO DELLA SCENA: un'immagine dipinta prima del filmato che
      // copre almeno meta' del suo riquadro e' il fondale su cui il filmato
      // si posa (lo sfondo del tavolo, piu' grande del filmato).
      final fondale = ro is RenderImage &&
          f != null &&
          r.overlaps(f) &&
          r.intersect(f).width * r.intersect(f).height >=
              0.5 * f.width * f.height;
      final dietro =
          filmatoVisibile && !filmatoGiaDipinto && (dentroAlFilmato || fondale);
      if (dentro && !dietro) trovati.add(_nome(ro, r));
    }
    ro.visitChildren((figlio) => visita(figlio, qui));
  }

  for (final radice in tester.binding.renderViews) {
    visita(radice, false);
  }
  return trovati;
}

/// **LA PROVA DI UNA SCENA, INTERA.** Chiamata a video cominciato e non
/// finito: pretende che sopra il video non si veda niente
/// ([cioCheSiVedeSopraIlFilmato] vuota), poi fa finire il video con
/// [finisci] e pretende che, passata la dissolvenza, il resto si veda.
/// [poi] e' l'attesa in piu' delle scene che a video finito sostano
/// sull'ultimo fotogramma prima di far salire il resto. La seconda meta'
/// tiene viva la prima: una scena che nascondesse tutto per
/// sempre sarebbe pulita anche lei.
Future<void> soloIlFilmatoFinche(
  WidgetTester tester, {
  required String scena,
  required Finder filmato,
  required VoidCallback finisci,
  Duration poi = Duration.zero,
}) async {
  final sopra = cioCheSiVedeSopraIlFilmato(tester, filmato: filmato);
  expect(sopra, isEmpty,
      reason: 'FXA.08, $scena: a video in corso sopra la scena si vede '
          '${sopra.length} cose: $sopra');
  finisci();
  await tester.pump();
  await tester.pump(IlFilmatoCheSfuma.dissolvenza);
  await tester.pump(const Duration(milliseconds: 50));
  // Le scene che a video finito sostano sull'ultimo fotogramma prima di far
  // salire il resto (l'Oroscopo, coi suoi emblemi) dicono quanto in [poi].
  for (var t = Duration.zero; t < poi; t += const Duration(milliseconds: 100)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  // A video finito una scena puo' togliere il filmato e lasciare sotto il
  // suo ultimo fotogramma dipinto (il Calendario Lunare): qui non si
  // pretende.
  final dopo = cioCheSiVedeSopraIlFilmato(tester,
      filmato: filmato, filmatoPreteso: false);
  expect(dopo.where((r) => r.startsWith('testo ')), isNotEmpty,
      reason: 'FXA.08, $scena: a video finito il resto della schermata deve '
          'comparire sopra l\'ultimo fotogramma, e non compare niente');
}

/// Un nodo che non dipinge cio' che porta: opacita' nulla o fuori scena.
bool _spento(RenderObject ro) =>
    (ro is RenderOpacity && ro.opacity < 0.01) ||
    (ro is RenderAnimatedOpacity && ro.opacity.value < 0.01) ||
    (ro is RenderSliverOpacity && ro.opacity < 0.01) ||
    (ro is RenderSliverAnimatedOpacity && ro.opacity.value < 0.01) ||
    (ro is RenderOffstage && ro.offstage) ||
    (ro is RenderSliverOffstage && ro.offstage);

Rect _riquadro(RenderObject ro) =>
    MatrixUtils.transformRect(ro.getTransformTo(null), ro.paintBounds);

String _nome(RenderObject ro, Rect r) {
  final dove = '(${r.left.toStringAsFixed(0)},${r.top.toStringAsFixed(0)} '
      '${r.width.toStringAsFixed(0)}x${r.height.toStringAsFixed(0)})';
  final creatore = ro.debugCreator;
  var chi = '';
  if (creatore is DebugCreator) {
    final catena = <String>[];
    creatore.element.visitAncestorElements((e) {
      final k = e.widget.key;
      if (k is ValueKey<String>) catena.add(k.value);
      return catena.isEmpty;
    });
    chi = catena.isEmpty ? '' : ' sotto ${catena.first}';
  }
  if (ro is RenderParagraph) {
    final t = ro.text.toPlainText().replaceAll('\n', ' ');
    final corto = t.length > 40 ? '${t.substring(0, 40)}...' : t;
    return 'testo "$corto" $dove$chi';
  }
  if (ro is RenderEditable) return 'campo da scrivere $dove$chi';
  return 'immagine $dove$chi';
}
