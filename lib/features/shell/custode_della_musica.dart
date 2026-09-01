import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/sensi/regia_della_musica.dart';
import '../../core/settings/settings_controller.dart';
import 'barra_del_cerchio.dart';
import 'quale_musica_suona.dart';

/// IL CUSTODE DELLA MUSICA: l'unico punto che decide cosa suona.
/// Ordine CN voce 03, 1 settembre 2026.
///
/// **Sta sopra il Navigator**, come la barra e per la stessa ragione: da li'
/// vede anche le rotte spinte sopra il guscio, comprese le chat, i domini e le
/// immersive, che hanno un proprio Scaffold. Una schermata non sa quale musica
/// suona e non deve saperlo.
///
/// **Legge la pila che esiste gia'.** L'ordine BE ha costruito
/// `OsservatoreDellaPila` per la barra, che sa qual e' la schermata in cima e
/// quale Maestro dichiara. Costruirne un secondo per la musica vorrebbe dire
/// due elenchi delle stesse rotte, che e' il difetto piu' numeroso di questo
/// progetto: **due conti della stessa cosa**.
class CustodeDellaMusica extends StatefulWidget {
  const CustodeDellaMusica({
    super.key,
    required this.pila,
    required this.child,
  });

  final OsservatoreDellaPila pila;
  final Widget child;

  @override
  State<CustodeDellaMusica> createState() => _CustodeDellaMusicaState();
}

class _CustodeDellaMusicaState extends State<CustodeDellaMusica> {
  @override
  void initState() {
    super.initState();
    widget.pila.cambi.addListener(_guarda);
    // Il primo giro dopo il frame: alla costruzione la pila e' ancora vuota,
    // e chiedere adesso vorrebbe dire chiedere del nulla.
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardaOra());
  }

  @override
  void dispose() {
    widget.pila.cambi.removeListener(_guarda);
    super.dispose();
  }

  void _guarda() {
    // **SI GUARDA DOPO IL FRAME, NON NELL'ISTANTE DEL PUSH.**
    //
    // **Questo e' il difetto che ha reso l'app muta nella build 2218**, e la
    // sua forma merita di restare scritta. Il nome della schermata in cima si
    // ricava CAMMINANDO L'ALBERO della rotta: `tipoDellaRotta` scende dentro
    // `rotta.subtreeContext` e cerca un nome conosciuto. Ma quando
    // `didPush` arriva **quella rotta non e' ancora stata costruita**, quindi
    // il suo albero e' vuoto, il nome torna NULLO, e la regia legge "nessuna
    // schermata dichiara niente", cioe' continua quel che suona, cioe'
    // niente.
    //
    // **La barra non aveva il problema**, e non per fortuna: legge
    // `schermataInCima()` dentro un `addPostFrameCallback`, ed e' scritto nel
    // suo codice dall'ordine BE. Ho riusato la sua pila senza riusare il suo
    // momento.
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardaOra());
  }

  void _guardaOra() {
    if (!mounted) return;
    final settings = context.read<SettingsController?>();
    if (settings == null) return;

    final voce = cosaSuonaSu(
      widget.pila.schermataInCima(),
      widget.pila.maestroInCima(),
    );

    switch (voce.cosa) {
      case CosaSuonaQui.cioCheGiaSuona:
        // I Doni del Giorno passano di qui: non si tocca niente, e il tappeto
        // che accompagnava resta.
        return;
      case CosaSuonaQui.silenzio:
        RegiaDellaMusica.sola.vaiA(null, settings);
      case CosaSuonaQui.unaTraccia:
        RegiaDellaMusica.sola.vaiA(voce.traccia, settings);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
