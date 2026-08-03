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
  });

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
      delegate: _QuelloCheAvanza(),
      children: [
        LayoutId(id: idConversazione, child: conversazione),
        LayoutId(id: idScena, child: scena),
      ],
    );
  }
}

class _QuelloCheAvanza extends MultiChildLayoutDelegate {
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

    final avanza = math.max(0.0, size.height - altezzaConversazione);

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
  bool shouldRelayout(_QuelloCheAvanza oldDelegate) => false;
}
