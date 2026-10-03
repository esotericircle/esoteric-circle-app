import 'package:flutter/material.dart';

/// **UNA CARD CHE ESCE DAL TELEFONO SI DISEGNA A MISURA FISSA.**
/// Ordine CN voce 12, 1 settembre 2026, decisione del fondatore.
///
/// **La domanda che chiude.** L'ordine CM aveva lasciato aperta una scelta: una
/// card da condividere deve seguire la misura del testo di chi la crea? La
/// risposta e' no, e la ragione non e' tecnica.
///
/// **E' un'immagine guardata da altri, sui loro schermi.** La scala del testo e'
/// un'impostazione personale di accessibilita': serve agli occhi di chi la
/// imposta, su quel telefono. Cuocerla dentro un'immagine condivisa
/// produrrebbe card di proporzioni diverse per ogni persona che le crea, e
/// l'identita' visiva del Cerchio smetterebbe di essere una.
///
/// **Non toglie accessibilita' a nessuno.** Chi ha il testo grande continua a
/// vedere grande tutta l'app, compresa la schermata in cui la card sta: e'
/// **l'immagine da esportare** a restare alla scala uno, non cio' che la
/// circonda.
///
/// **E chiude tre schermate rotte.** A testo massimo le tre catture che passano
/// dalla card delle Rune sfondavano di 137 punti, perche' la cornice ha una
/// misura sua e il testo dentro cresceva. Adesso non cresce piu'.
class CardAMisuraFissa extends StatelessWidget {
  const CardAMisuraFissa({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.noScaling,
      ),
      child: child,
    );
  }
}
