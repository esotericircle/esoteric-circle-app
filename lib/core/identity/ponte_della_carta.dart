import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../astro/natal_chart_controller.dart';
import 'natal_identity.dart';

/// IL PONTE FRA CHI CALCOLA LA CARTA E CHI LA LEGGE.
///
/// **Perche' serve, e perche' la correzione di ieri non bastava.** La carta
/// natale vive in due controller, ed e' la seconda porta segnalata
/// nell'Indice: `NatalChartController` la CALCOLA e conserva la risposta
/// grezza sul dispositivo, `BirthIdentityController` la TIENE per chi la
/// legge, cioe' l'Oroscopo, il Soffio, il Passaporto. Il secondo veniva
/// riempito in un punto solo, la fine del Risveglio.
///
/// Con l'ordine 2166 la carta ha imparato a conservarsi e a tornare
/// all'avvio, ma solo per chi il Risveglio lo fa DA ADESSO: chi l'aveva gia'
/// fatto non aveva niente di scritto sul disco, nessuno gli ricalcolava la
/// carta, e l'Oroscopo continuava a dirgli che non aveva dato ora e luogo.
/// Mezza correzione e' peggio di nessuna, perche' sembra fatta.
///
/// Questo ponte chiude il giro: quando i dati di nascita ci sono e la carta
/// no, chiede al motore di assicurarla (che la rilegge dal suo archivio senza
/// toccare la rete, se c'e' gia') e la consegna alla porta di lettura, che la
/// conserva. Da li' in poi ogni riapertura la trova pronta.
///
/// **Non e' una terza porta.** Non calcola niente e non tiene niente: mette
/// in comunicazione le due che esistono. Le due porte restano due, e ridurle
/// a una e' lavoro dichiarato e non ancora ordinato.
class PonteDellaCarta extends StatefulWidget {
  const PonteDellaCarta({super.key, required this.child});

  final Widget child;

  @override
  State<PonteDellaCarta> createState() => _PonteDellaCartaState();
}

class _PonteDellaCartaState extends State<PonteDellaCarta> {
  /// Vero mentre il giro e' in corso: senza, ogni ricostruzione ne
  /// comincerebbe un altro e la rete verrebbe interrogata in cerchio.
  bool _inCorso = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // **A FINE FOTOGRAMMA, e non durante la costruzione dell'albero.** Il
    // ponte consegna la carta alla porta, che NOTIFICA: farlo mentre l'albero
    // si sta costruendo fa cadere Flutter con un errore di stato sporco, e
    // la prova l'ha preso al primo giro. Qui si aspetta che il fotogramma
    // sia finito, poi si lavora.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _colmaSeManca();
    });
  }

  Future<void> _colmaSeManca() async {
    if (_inCorso) return;
    final identita = context.read<BirthIdentityController>();
    final motore = context.read<NatalChartController>();
    final dettagli = identita.details;
    // Senza dati di nascita non c'e' niente da calcolare, e chiederlo
    // sarebbe una chiamata sprecata: l'app ha gia' il suo ripiego per chi
    // non li ha dati, ed e' dichiarato a schermo.
    if (dettagli == null) return;
    if (identita.chart != null) return;

    _inCorso = true;
    try {
      // `assicura` e' idempotente e passa PRIMA dall'archivio: se la carta
      // era gia' stata calcolata una volta, qui non parte nessuna chiamata.
      await motore.assicura(dettagli);
      final calcolata = motore.chart;
      if (!mounted || calcolata == null) return;
      // La consegna alla porta di lettura, che la conserva: da qui in avanti
      // la ritrova all'avvio senza passare di nuovo da questo ponte.
      identita.setBirth(dettagli, calcolata);
    } finally {
      _inCorso = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
