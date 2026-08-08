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

  /// La porta a cui il ponte e' iscritto, tenuta per potersi disiscrivere.
  BirthIdentityController? _ascoltata;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // **IL PONTE SI RIARMA, e la ragione e' una corsa persa.** Con un solo
    // tentativo a fine primo fotogramma, il ponte moriva su una gara: il
    // profilo si carica dal DISCO in modo asincrono, e se il disco arriva
    // dopo quel fotogramma il ponte trova i dati nulli, esce e non riprova
    // piu'. La correzione viveva o moriva a seconda di chi arrivava prima.
    //
    // Adesso il ponte ascolta la porta e rifa' il giro a ogni notifica,
    // sempre a fine fotogramma. **Si ascolta, non si guarda**: con un
    // `context.watch` tutta l'app si ricostruirebbe a ogni notifica dei dati
    // di nascita, e questo widget sta sopra il Navigator.
    final identita = context.read<BirthIdentityController>();
    if (!identical(identita, _ascoltata)) {
      _ascoltata?.removeListener(_allaNotifica);
      identita.addListener(_allaNotifica);
      _ascoltata = identita;
    }
    _allaNotifica();
  }

  void _allaNotifica() {
    // A fine fotogramma e non durante la costruzione dell'albero: il ponte
    // consegna la carta alla porta, che NOTIFICA a sua volta, e farlo mentre
    // l'albero si costruisce fa cadere Flutter con un errore di stato
    // sporco. La prova l'ha preso al primo giro.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _colmaSeManca();
    });
  }

  @override
  void dispose() {
    _ascoltata?.removeListener(_allaNotifica);
    super.dispose();
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
