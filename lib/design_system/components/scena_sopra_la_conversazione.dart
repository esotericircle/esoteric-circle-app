import 'dart:math' as math;

import 'package:flutter/material.dart';

/// LA SCENA OCCUPA QUELLO CHE AVANZA, E NON LO RECLAMA.
///
/// **Il dato che ha fatto nascere questo file.** L'emblema del consulto stava a
/// 96 punti dentro una fascia libera alta centinaia di punti, cioe' circa un
/// ottavo della larghezza dello schermo, con tutto il resto vuoto.
///
/// **Perche' non basta ingrandirlo.** Se la scena prendesse una misura sua e la
/// conversazione si adattasse, ogni risposta nuova farebbe saltare il layout, e
/// una scena che sposta cio' che stai leggendo e' peggio di una scena piccola.
/// Qui l'ordine di misurazione e' rovesciato apposta: **la conversazione si
/// dispone per prima** e prende tutto cio' che le serve, poi alla scena si dice
/// quanto e' rimasto. Non c'e' nessun caso in cui la scena tolga spazio a un
/// messaggio.
///
/// Quando non avanza niente la scena riceve altezza zero, e sta a lei degradare
/// invece di schiacciarsi.
class ScenaSopraLaConversazione extends StatelessWidget {
  const ScenaSopraLaConversazione({
    super.key,
    required this.scena,
    required this.conversazione,
    this.altezzaMinimaDellaScena = 0,
  });

  /// L'ALTEZZA CHE LA SCENA PRETENDE QUANDO E' VIVA, e il perche' e' una
  /// storia di regressione. "Quando non avanza niente la scena riceve
  /// altezza zero, e sta a lei degradare": cosi' diceva questo file, ed era
  /// un RIPIEGO MUTO per costruzione. Sul telefono di Mauro ogni chat ha la
  /// sua storia, la conversazione riempie lo schermo, non avanza mai niente,
  /// e l'emblema con le frasi di riflessione sono spariti da TUTTE le chat
  /// senza che nessuna prova cadesse: le prove montavano chat vuote, dove lo
  /// spazio avanza sempre. Visto da Mauro, ordine 2161 del 7 agosto 2026.
  ///
  /// Con un valore sopra zero la scena VIVA riceve almeno questa altezza e
  /// si stende SOPRA la cima della conversazione, che non si muove di un
  /// punto: i messaggi restano dove stanno, coperti per il tempo dell'attesa
  /// dal velo che la scena porta con se'. Zero conserva il comportamento di
  /// prima, per chi non ha niente da garantire.
  final double altezzaMinimaDellaScena;

  /// L'altezza che il consulto chiede in chat perche' la scena sia INTERA:
  /// il pavimento dell'emblema e' 72, la riserva della riga misurata sulla
  /// frase vera supera i 150 quando c'e' anche l'invito, piu' i margini
  /// verticali. A 240 la vista degradava alla sola riga da 74 punti,
  /// misurato con la sonda: a 320 l'emblema col suo corredo ci sta anche
  /// nel caso peggiore di Aura con l'invito al Test.
  static const double altezzaDelConsulto = 320;

  /// Cosa si dipinge nello spazio che avanza. Riceve i vincoli reali, quindi
  /// legge la sua altezza da `LayoutBuilder` invece di riceverla come numero.
  final Widget scena;

  /// La conversazione. Si dispone per prima e prende cio' che le serve.
  final Widget conversazione;

  static const String idScena = 'scena';
  static const String idConversazione = 'conversazione';

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _QuelloCheAvanza(minima: altezzaMinimaDellaScena),
      children: [
        LayoutId(id: idConversazione, child: conversazione),
        LayoutId(id: idScena, child: scena),
      ],
    );
  }
}

class _QuelloCheAvanza extends MultiChildLayoutDelegate {
  _QuelloCheAvanza({required this.minima});

  final double minima;

  @override
  void performLayout(Size size) {
    // PRIMA LA CONVERSAZIONE, con vincoli larghi: prende cio' che le serve e
    // non un pixel di piu'.
    var altezzaConversazione = 0.0;
    if (hasChild(ScenaSopraLaConversazione.idConversazione)) {
      final misura = layoutChild(
        ScenaSopraLaConversazione.idConversazione,
        BoxConstraints.loose(size),
      );
      altezzaConversazione = misura.height;
    }

    // Cio' che avanza, MA MAI SOTTO LA MINIMA quando una minima c'e': la
    // scena viva si prende il suo posto sopra la conversazione, che resta
    // ferma. La ragione intera sta su altezzaMinimaDellaScena.
    final avanza = math.max(
        math.min(minima, size.height),
        math.max(0.0, size.height - altezzaConversazione));

    if (hasChild(ScenaSopraLaConversazione.idScena)) {
      layoutChild(
        ScenaSopraLaConversazione.idScena,
        BoxConstraints(maxWidth: size.width, maxHeight: avanza),
      );
      // In cima alla fascia libera, non al centro.
      positionChild(ScenaSopraLaConversazione.idScena, Offset.zero);
    }
    if (hasChild(ScenaSopraLaConversazione.idConversazione)) {
      // La conversazione resta ancorata in basso, dove sta gia': lo spazio si
      // toglie da sopra, quindi nessun messaggio si muove.
      positionChild(
        ScenaSopraLaConversazione.idConversazione,
        Offset(0, size.height - altezzaConversazione),
      );
    }
  }

  @override
  bool shouldRelayout(_QuelloCheAvanza oldDelegate) =>
      oldDelegate.minima != minima;
}
