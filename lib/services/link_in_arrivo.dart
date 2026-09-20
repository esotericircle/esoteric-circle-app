/// I LINK CHE ARRIVANO DA FUORI. Ordine EA voce 19, 20 settembre 2026.
///
/// **Perche' esiste una porta e non una chiamata diretta.** Il link
/// d'ingresso arriva dal sistema operativo, che e' la cosa meno provabile che
/// ci sia: qui dentro c'e' l'unico punto che parla col pacchetto nativo, e
/// tutto il resto dell'app parla con questa porta. Nelle prove si passa la
/// porta finta, e nessuna finestra si apre.
///
/// **Due momenti, non uno.** Il link puo' aver APERTO l'app, e allora arriva
/// come *primo link*; oppure puo' arrivare mentre l'app e' gia' viva, e
/// allora passa dal flusso. Chi ascolta deve gestirli tutti e due, o chi
/// tocca il link ad app chiusa resta fuori.
library;

import 'dart:async';

import 'package:app_links/app_links.dart';

/// La porta, per chi ascolta.
abstract class PortaDeiLinkInArrivo {
  /// Il link che ha aperto l'app, se ce n'e' uno.
  Future<String?> primoLink();

  /// I link che arrivano mentre l'app e' viva.
  Stream<String> flusso();
}

/// La porta vera, sul pacchetto nativo.
class PortaVeraDeiLinkInArrivo implements PortaDeiLinkInArrivo {
  PortaVeraDeiLinkInArrivo({AppLinks? appLinks})
      : _links = appLinks ?? AppLinks();

  final AppLinks _links;

  @override
  Future<String?> primoLink() async {
    try {
      final uri = await _links.getInitialLink();
      return uri?.toString();
    } catch (errore) {
      // Senza sistema operativo che risponda non c'e' nessun link: non e'
      // un guasto, e' un'app aperta a mano.
      return null;
    }
  }

  @override
  Stream<String> flusso() => _links.uriLinkStream.map((u) => u.toString());
}

/// La porta spenta: nessun link, mai. E' quella delle prove e delle
/// anteprime, dove aprire una porta di sistema vorrebbe dire aprire una
/// finestra vera.
class PortaSpentaDeiLinkInArrivo implements PortaDeiLinkInArrivo {
  const PortaSpentaDeiLinkInArrivo();

  @override
  Future<String?> primoLink() async => null;

  @override
  Stream<String> flusso() => const Stream<String>.empty();
}
